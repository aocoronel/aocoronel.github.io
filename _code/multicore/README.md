---
title: multicore
description: Multi-core by default
source: ./multicore.rs
---

This is a, not so simple, implementation from the ideas presented in this article: [Multi-core by default](https://www.dgtlgrove.com/p/multi-core-by-default) by Ryan Fleury.

Running the project:

```bash
rustc multicore.rs && ./multicore
```

This little project took me four days to make. My own conclusion on this article follows.

The idea of little synchronization was very interesting at first glance, and indeed many patterns applied in the article can be expanded further. However, most importantly than telling the good points, there are some caveats I just realized.

This approach involves too much static and global variables to connect memory between threads, which makes it very painful to write any library in this style. There is no way to know when a function would require 'n' numbers of threads or a specific thread. It's also annoying, because functions that define static must have a initialization stage that also serves as resetting and followed by a thread barrier. Sometimes duplication is necessary, otherwise we would need to have some sort of global stack allocator, and, even thought, would also be a terrible idea. Or unsafely return the static variable itself. Once I did a little mistake and my CPU was at 100%. It never happened to me before. It's too much power!

I'm a C developer by heart, but I decided to try this project with Rust for the sake of having myself not have to deal with 8 footguns at the same time. I have 8 cores, and two feet, so, no way! If I did this in C I was be swearing to be writing Rust, and because I chosen Rust, I'm swearing I could be writing in a better language than Rust, because this style of programming is extremely hard to deal with, and not even Rust is good enough to aid me on one of the deadlock issues present in this codebase.

Technically, upon what I can tell, this approach is nicer for end programs, but bear with me. This is not scalable.

## License

This project is available as public-domain under the CC0 License.
