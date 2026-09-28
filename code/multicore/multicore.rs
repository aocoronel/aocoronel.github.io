/*
This is an experimental program, thus doesn't have a versioning

This file is released as public-domain under the CC0 license
*/

use std::{
    cell::Cell,
    mem::MaybeUninit,
    sync::atomic::{
        AtomicPtr, AtomicUsize,
        Ordering::{self, AcqRel, Acquire, Relaxed, Release, SeqCst},
    },
    thread::{self, Thread},
};

thread_local! {
    /// Set once per thread
    pub static THREAD_ID: Cell<usize> = const { Cell::new(usize::MAX) };
}

/// Set once in main()
pub static mut THREAD_COUNT: usize = 0;

/// This is used to make static arrays
///
/// Assume computers can't have more than 64 CPUs
pub const MAX_THREAD_COUNT: usize = 64;

pub static mut THREADS: [MaybeUninit<Thread>; MAX_THREAD_COUNT] =
    [const { MaybeUninit::uninit() }; MAX_THREAD_COUNT];

/// To blocks all threads
pub static GLOBAL_BARRIER: Barrier = Barrier::new();

// Used in the Barrier. Instead of having several variables, we have only one atomic.
pub const COUNT_BITS: usize = 8;
pub const ARRIVED_BITS: usize = 8;
pub const COUNT_MASK: usize = 0xff;
pub const ARRIVED_MASK: usize = 0xff << COUNT_BITS;
pub const GEN_SHIFT: usize = COUNT_BITS + ARRIVED_BITS;

/// The user entry point isn't main()
///
/// Currently we call the user entry point "master()", but subject to change. The idea is that the
/// user starts the program with all threads by default
///
/// main() keeps responsability to:
///
/// - Initialize global GLOBAL_BARRIER
/// - Initialize global THREAD_COUNT
/// - Start all threads and initialize thread local THREAD_ID
/// - Exit the program
///
/// As a C developer I made master() return i32, instead of the common `Result<(), Box<dyn Error>>`
/// pattern for simplicity. Also for the fact "dyn Error" can't be used in threads. You will have to
/// print errors before aborting.
///
/// I assume programs that use this multi-core style of programming, may run under a single-threaded
/// or multi-threaded environment.
///
/// Note: I tried to use proc-macro to avoid defining main(), but compiler error messages start to
/// make no sense afterwards.
pub fn main() {
    let count = nproc();
    unsafe {
        THREAD_COUNT = count;
    }

    GLOBAL_BARRIER.init(count);

    let mut threads = Vec::with_capacity(thread_count());

    for id in 0..thread_count() {
        threads.push(std::thread::spawn(move || thread_call_main(id)));
    }

    for handle in threads {
        match handle.join() {
            Ok(code) => {
                std::process::exit(code as i32);
            }
            Err(_) => {
                std::process::exit(1 as i32);
            }
        }
    }
}

/// Used to block threads
pub struct Barrier {
    state: AtomicUsize,
}

impl Barrier {
    pub const fn new() -> Self {
        Self {
            state: AtomicUsize::new(0),
        }
    }

    /// number_threads: How many threads are necessary to break the barrier
    pub fn init(&self, number_threads: usize) {
        self.state.store(number_threads, Release);
    }

    pub fn sync(&self) {
        loop {
            let old = self.state.load(Acquire);

            let count = count(old);
            let arrived = arrived(old);
            let generation_var = generation(old);

            if arrived + 1 == count {
                let new = ((generation_var + 1) << GEN_SHIFT) | count;

                if self
                    .state
                    .compare_exchange_weak(old, new, AcqRel, Acquire)
                    .is_ok()
                {
                    unsafe {
                        for id in 0..THREAD_COUNT {
                            // The only limitation here, is that we unpark everyone
                            // Storing a vec of all the indexes we need to unpark may be more costly
                            // than keeping this as is
                            THREADS[id].assume_init_ref().unpark();
                        }
                    }

                    return;
                }
            } else {
                let new = (generation_var << GEN_SHIFT) | ((arrived + 1) << COUNT_BITS) | count;

                if self
                    .state
                    .compare_exchange_weak(old, new, AcqRel, Acquire)
                    .is_ok()
                {
                    while generation(self.state.load(Acquire)) == generation_var {
                        thread::park();
                    }

                    return;
                }
            }
        }
    }
}

#[inline]
pub fn count(state: usize) -> usize {
    state & COUNT_MASK
}

#[inline]
pub fn arrived(state: usize) -> usize {
    (state & ARRIVED_MASK) >> COUNT_BITS
}

#[inline]
pub fn generation(state: usize) -> usize {
    state >> GEN_SHIFT
}

/// Waits for all threads to reach this function.
/// Do not use this where the codepath doesn't guarantee all threads will call this.
pub fn barrier_sync_all() {
    loop {
        let old = GLOBAL_BARRIER.state.load(Acquire);

        let count = count(old);
        let arrived = arrived(old);
        let generation_var = generation(old);

        if arrived + 1 == count {
            let new = ((generation_var + 1) << GEN_SHIFT) | count;

            if GLOBAL_BARRIER
                .state
                .compare_exchange_weak(old, new, AcqRel, Acquire)
                .is_ok()
            {
                unsafe {
                    for id in 0..THREAD_COUNT {
                        THREADS[id].assume_init_ref().unpark();
                    }
                }

                return;
            }
        } else {
            let new = (generation_var << GEN_SHIFT) | ((arrived + 1) << COUNT_BITS) | count;

            if GLOBAL_BARRIER
                .state
                .compare_exchange_weak(old, new, AcqRel, Acquire)
                .is_ok()
            {
                while generation(GLOBAL_BARRIER.state.load(Acquire)) == generation_var {
                    thread::park();
                }

                return;
            }
        }
    }
}

pub const fn thread_count() -> usize {
    unsafe {
        return THREAD_COUNT;
    }
}

pub fn thread_call_main(id: usize) -> u8 {
    THREAD_ID.with(|x| x.set(id));
    unsafe {
        THREADS[id].write(std::thread::current());
    }
    master()
}

pub fn thread_id() -> usize {
    let id = THREAD_ID.get();
    assert!(
        id != usize::MAX,
        "thread_id() called outside of managed thread"
    );
    id
}

pub fn main_thread() -> bool {
    return thread_id() == 0;
}

pub fn main_thread_id() -> usize {
    return 0;
}

/// Returns number of processing units available
///
/// Trivia: Named after the [nproc](https://www.man7.org/linux/man-pages/man1/nproc.1.html) command
pub fn nproc() -> usize {
    return std::thread::available_parallelism()
        .map(|n| n.get())
        .unwrap_or(1)
        .min(MAX_THREAD_COUNT);
}

/// Holds metadata for running uniform tasks
///
/// We have to connect multiple threads together about their state and progress in a given task.
/// This struct may be initialized the following way, all times a task must be performed.
///
/// ```rust
/// task!(TASK, TaskUniform);
/// ```
pub struct TaskUniform {
    pub ctx: AtomicUsize,
    pub tasks_done: AtomicUsize,
    pub barrier: Barrier,
}

/// Holds metadata for running dynamic tasks
///
/// We have to connect multiple threads together about their state and progress in a given task.
/// This struct may be initialized the following way, all times a task must be performed.
///
/// ```rust
/// task!(TASK, TaskDynamic);
/// ```
pub struct TaskDynamic {
    pub ctx: AtomicUsize,
    pub tasks_done: AtomicUsize,
    pub count: AtomicUsize,
}

impl TaskUniform {
    pub const fn new() -> Self {
        Self {
            ctx: AtomicUsize::new(0),
            tasks_done: AtomicUsize::new(0),
            barrier: Barrier::new(),
        }
    }

    pub fn init(&self, required_threads: usize) {
        self.barrier.state.store(required_threads, Relaxed);
    }

    /// Range-based task execution
    ///
    /// If the maximum amount of threads is reached, all remaining threads are going to skip this task.
    /// They are fine to wait or do another task. In case the maximum amount of threads isn't reached,
    /// because another task is using almost all threads prior to it, when the previous task finishes
    /// those threads can join the subsequent tasks that needs more workers.
    ///
    /// ```rust
    /// task!(TASK, TaskUniform);
    /// TASK.start(task_count, |range, barrier| {
    ///     for i in range {
    ///         // do something with 'i'
    ///     }
    ///     barrier.sync();
    /// });
    /// ```
    pub fn start<F>(&self, task_count: usize, f: F)
    where
        F: Fn(Range, &Barrier),
    {
        let slot = self.ctx.fetch_add(1, AcqRel);

        let old = self.barrier.state.load(Acquire);
        let count = count(old);

        if slot >= count {
            return;
        }

        let range = thread_range_by(task_count, slot, count);
        f(range, &self.barrier);
    }
}

impl TaskDynamic {
    pub const fn new() -> Self {
        Self {
            ctx: AtomicUsize::new(0),
            tasks_done: AtomicUsize::new(0),
            count: AtomicUsize::new(0),
        }
    }

    pub fn init(&self, required_threads: usize) {
        self.count.store(required_threads, Ordering::Relaxed);
    }

    /// Index-based task execution
    ///
    /// If the maximum amount of threads is reached, all remaining threads are going to skip this task.
    /// They are fine to wait or do another task. In case the maximum amount of threads isn't reached,
    /// because another task is using almost all threads prior to it, when the previous task finishes
    /// those threads can join the subsequent tasks that needs more workers.
    ///
    /// ```rust
    /// task!(TASK, TaskDynamic);
    /// TASK.start(task_count, |i| {
    ///     // do something with 'i'
    /// });
    /// ```
    ///
    /// It's assumed that dynamic tasks don't need synchronization, since they are always working
    /// with little bits from the task.
    pub fn start<F>(&self, task_count: usize, f: F)
    where
        F: Fn(usize),
    {
        let slot = self.ctx.fetch_add(1, AcqRel);

        if slot >= self.count.load(Relaxed) {
            return;
        }

        while self.tasks_done.load(SeqCst) < task_count {
            let i = self.tasks_done.fetch_add(1, SeqCst);
            f(i);
        }
    }
}

/// Ranges for working with data
pub struct Range {
    pub min: usize,
    pub max: usize,
}

impl Iterator for Range {
    type Item = usize;

    fn next(&mut self) -> std::option::Option<Self::Item> {
        if self.min >= self.max {
            None
        } else {
            let item = self.min;
            self.min += 1;
            Some(item)
        }
    }
}

/// Returns range each thread should work on
///
/// Note: only use this if the task is performed by all threads, otherwise use thread_range_by
///
/// ```rust
/// // Say we need to iterate over this array:
/// let a = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
/// // We have to iterate over:
/// let count = a.len();
/// // Since we can iterate with each thread:
/// let range = thread_range(count);
/// for i in range {
///     println!("{}", a[i]);
/// }
/// ```
pub fn thread_range(count: usize) -> Range {
    let thread_count = thread_count();
    let thread_id = thread_id();

    let values_per_thread = count / thread_count;
    let leftover_values_count = count % thread_count;

    let thread_has_leftover = thread_id < leftover_values_count;

    let leftovers_before_this_thread_idx = if thread_has_leftover {
        thread_id
    } else {
        leftover_values_count
    };

    let thread_first_value_idx = values_per_thread * thread_id + leftovers_before_this_thread_idx;

    let thread_opl_value_idx =
        thread_first_value_idx + values_per_thread + usize::from(thread_has_leftover);

    Range {
        min: thread_first_value_idx,
        max: thread_opl_value_idx,
    }
}

/// Returns range each thread should work on
///
/// ```rust
/// // Say we need to iterate over this array:
/// let a = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
/// // We have to iterate over:
/// let count = a.len();
/// // Since we can iterate with each thread:
/// let range = thread_range_by(count, thread_id(), thread_count());
/// for i in range {
///     println!("{}", a[i]);
/// }
/// ```
pub fn thread_range_by(count: usize, thread: usize, required_threads: usize) -> Range {
    let thread_count = required_threads;
    let thread_id = thread;

    let values_per_thread = count / thread_count;
    let leftover_values_count = count % thread_count;

    let thread_has_leftover = thread_id < leftover_values_count;

    let leftovers_before_this_thread_idx = if thread_has_leftover {
        thread_id
    } else {
        leftover_values_count
    };

    let thread_first_value_idx = values_per_thread * thread_id + leftovers_before_this_thread_idx;

    let thread_opl_value_idx =
        thread_first_value_idx + values_per_thread + usize::from(thread_has_leftover);

    Range {
        min: thread_first_value_idx,
        max: thread_opl_value_idx,
    }
}

pub struct SharedPointer<T> {
    value: AtomicPtr<T>,
    len: AtomicUsize,
}

#[derive(Copy, Clone)]
pub struct SharedPointerRef<T> {
    ptr: *mut T,
    len: usize,
}

impl<T> SharedPointer<T> {
    pub const fn new() -> SharedPointer<T> {
        SharedPointer {
            value: AtomicPtr::new(std::ptr::null_mut()),
            len: AtomicUsize::new(0),
        }
    }

    pub unsafe fn store(&self, value: *mut T, len: usize, ordering: Ordering) {
        self.value.store(value, ordering);
        self.len.store(len, ordering);
    }

    pub unsafe fn load(&self, ordering: Ordering) -> SharedPointerRef<T> {
        SharedPointerRef {
            ptr: self.value.load(ordering),
            len: self.len.load(ordering),
        }
    }
}

impl<T> SharedPointerRef<T> {
    pub fn len(&self) -> usize {
        self.len
    }

    pub fn is_empty(&self) -> bool {
        self.len == 0
    }

    pub unsafe fn as_ptr(&self) -> *const T {
        self.ptr
    }

    pub unsafe fn as_mut_ptr(&self) -> *mut T {
        self.ptr
    }

    pub unsafe fn get_unchecked(&self, index: usize) -> &T {
        unsafe { &*self.ptr.add(index) }
    }

    pub unsafe fn get_unchecked_mut(&self, index: usize) -> &mut T {
        unsafe { &mut *self.ptr.add(index) }
    }

    pub unsafe fn get(&self, index: usize) -> std::option::Option<&T> {
        if index < self.len {
            unsafe { Some(self.get_unchecked(index)) }
        } else {
            None
        }
    }

    pub unsafe fn get_mut(&mut self, index: usize) -> std::option::Option<&mut T> {
        if index < self.len {
            unsafe { Some(self.get_unchecked_mut(index)) }
        } else {
            None
        }
    }
}

impl<T: Copy> SharedPointerRef<T> {
    pub fn copy_to_vec(&self) -> Vec<T> {
        unsafe { std::slice::from_raw_parts(self.ptr, self.len).to_vec() }
    }
}

impl<T: Clone> SharedPointerRef<T> {
    pub fn to_vec(&self) -> Vec<T> {
        unsafe { std::slice::from_raw_parts(self.ptr, self.len).to_vec() }
    }
}

#[macro_export]
macro_rules! task {
    ($i:ident, $t:ident) => {
        static $i: $t = $crate::$t::new();
        $i.init($crate::thread_count());
    };
    ($i:ident, $t:ident, $n:expr) => {
        static $i: $t = $crate::$t::new();
        $i.init($n);
    };
}

// Example:
pub fn master() -> u8 {
    if main_thread() {
        println!("Main Thread:\n  thread_count = {}", thread_count());
    }

    static SHARED_VECTOR: SharedPointer<usize> = SharedPointer::new();

    // So we don't have extra headaches, we can just declare the vector here
    let mut v: Vec<usize>;

    // Initialize vector in thread 0
    if main_thread() {
        v = Vec::with_capacity(10);
        for i in 1..11 {
            v.push(i as usize);
        }

        unsafe {
            SHARED_VECTOR.store(v.as_mut_ptr(), v.len(), Release);
        }
    }

    // Synchronize everyone, before loading
    barrier_sync_all();

    // Mutations in this variable will reflect across all threads. Unsafe!
    let mut shared_ptr = unsafe { SHARED_VECTOR.load(Acquire) };

    // Here all mutations to do not affect the shared_ptr, local to each thread
    let mut local_ptr = shared_ptr.copy_to_vec();

    // Each thread has a local_sum, and we add it to SUM later
    let mut local_sum: usize = 0;

    {
        let ptr = local_ptr.get_mut(thread_id()).unwrap();
        *ptr *= 2;
        println!("t[{}]: local_ptr --> {}", thread_id(), *ptr);
        local_sum += *ptr;
    }

    // This is fine, since each thread only writes to it's own index and never read anything else
    // Changes made here are visible to all threads without synchronization
    unsafe {
        let ptr = shared_ptr.get_mut(thread_id()).unwrap();
        *ptr *= 2;
        println!("t[{}]: shared_ptr --> {}", thread_id(), *ptr);
        local_sum += *ptr;
    }

    // Since all threads have to write back to a single variable, atomic may be the best solution
    static SUM: AtomicUsize = AtomicUsize::new(0);
    SUM.fetch_add(local_sum, AcqRel);

    // Synchronize, so main_thread() is ready to print the sum
    barrier_sync_all();

    if main_thread() {
        println!("Sum: {}", SUM.load(Acquire));
    }

    let a = [
        4, 3, 3, 3, 3, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 1, 2, 1, 2, 1, 2,
    ];

    task!(TASKS1, TaskDynamic);
    task!(TASKS2, TaskDynamic, thread_count() - 1);
    task!(TASKS3, TaskDynamic);
    task!(TASKS4, TaskUniform, 2);

    let task_count = a.len();
    TASKS4.start(task_count, |range, barrier| {
        for i in range {
            println!("task4[{}] idx: {} --> {}", thread_id(), i, a[i]);
        }
        // this sometimes deadlock, and I have no idea why
        barrier.sync();
    });

    TASKS3.start(task_count, |i| {
        println!("task3[{}] idx: {} --> {}", thread_id(), i, a[i]);
    });

    TASKS1.start(task_count, |i| {
        println!("task1[{}] idx: {} --> {}", thread_id(), i, a[i]);
    });

    TASKS2.start(task_count, |i| {
        println!("needs help t[{}] idx: {} --> {}", thread_id(), i, a[i]);
    });

    barrier_sync_all();

    0
}
