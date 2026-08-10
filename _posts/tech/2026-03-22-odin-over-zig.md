---
title: Odin over Zig
description: A brief comparasion and how I look at programming languages
date: Mar 22, 2026 08:00
---

I always thought Zig was a very superior programming language, specially in the systems programming niche, as the true C Killer. I'll talk about the many features that Zig has, and what makes it appealing, but before that, just look this beautiful code:

```odin
package main

import "core:fmt"
import "core:c"
import "core:strings"

IniKey :: struct {
        key: rc,
        value: rc,
}

IniKeys :: struct {
        len: c.size_t,
        cap: c.size_t,
        data: [^]IniKey,
}

IniSection :: struct {
        keys: IniKeys,
        name: rc,
}

IniSections :: struct {
        len: c.size_t,
        cap: c.size_t,
        data: [^]IniSection,
}

rc :: struct {
        cap:  c.size_t,
        len:  c.size_t,
        data: ^u8,
}

Slice :: struct {
        len: c.size_t,
        data: ^u8,
}

Region :: struct {
        next: ^Region,
        len: c.size_t,
        cap: c.size_t,
        data: []c.uintptr_t,
}

Arena :: struct {
        begin: ^Region,
        end: ^Region,
}

foreign import libc "system:c"

foreign libc {
        @(link_name="ini_read") read :: proc(a: ^Arena, file_path: cstring) -> IniSections ---
	      printf    :: proc(format: cstring, #c_vararg args: ..any) -> int ---
        fflush    :: proc(stream: ^c.FILE) -> int ---
}

foreign libc {
	stderr: ^c.FILE
	stdin:  ^c.FILE
	stdout: ^c.FILE
}

main :: proc() {
    arena: Arena
    file: cstring = "test.ini"
    sections: IniSections = read(&arena, file)

    slice := sections.data[:sections.len]

    for i: c.size_t = 0; i < sections.len; i += 1 {
            printf("Section %s:\n", sections.data[i].name.data)
            for j: c.size_t = 0; j < sections.data[i].keys.len; j += 1 {
                printf("  Key = %s\n  Value = %s\n", sections.data[i].keys.data[j].key.data, sections.data[i].keys.data[j].value.data)
            }
    }
}
```

This code is a very simple example on how to interface with C using Odin, in this case I'm using my C INI parser library, which depends in a custom Arena implementation and other functions. Although it has a boilerplate to start working with C code, but at least it just works. I tried doing the same interface with Zig and somehow I failed miserably (due to alignment mismatches in my arena implementation).

A Zig breakdown:

Zig error handling is quite unique, but I may not have understood it correctly yet. Maybe the problem is just me, but this whole Error types, `try`, `catch`, `orelse` and so on, is more complicated than a simplification of error handling. You can read my thoughts on the C error handling here [Is C error handling bad?](./2026-03-02-is-c-error-handling-bad.md). I'm somehow on favor of Odin's approach. And in fact, the only thing Odin does to support error handling are a few keywords like `or_return`, `or_break`, `or_continue` (which I haven't even tried yet) and that's pretty much it. The convention in named errors in Odin is just a enum, often called `Error`.

Zig also supports methods, if that's how their are defined... recently, I was playing with C to try to bring this syntatic sugar, but the only thing I got was `math().add(&s, 20)` (find it [here](https://codeberg.org/aocoronel/c-interfaces). However, the Zig compiler does it better. What are the pros of this? We can type less, but because Zig can infer the types, and often Zig developers will infer types, it's more of a nightmare than really that useful. Odin also does aid in this C neck-pain, but it's only through namespacing the packages. Although, one's could simply not use Zig's methods, it doesn't guarantee that others will do the same, and as my hypothesis of developers will always seek the hardest way to do things (Rust... cough) they will do.

The build system is another pain. It simply doesn't make any sense to exist, and in fact if you structure your Zig source code properly, you can compile an entire project without `build.zig`, so what is the point?

Zig is too strict. If you include some C headers and start using `printf`, you will be slapped with tons of error messages, telling you are forgetting to check the return values of `printf`. Yes, I know `printf` can fail, but I don't care. So then, goes you: `_ = c.printf("Hello, world!\n")`. Just to print to standard output with just Zig's standard library, it takes a least 3 lines of initialization and requires to flush. For a good reason, but come on!

Pointers and types are to rule out all normies from the language. While learning Zig through the [Ziglings](https://codeberg.org/ziglings/exercises/), I saved this thing. Thanks to them for this awesome cheatsheet.

```console
u8            ::  one u8
*u8           ::  pointer to one u8
[2]u8         ::  two u8s
[*]u8         ::  pointer to unknown number of u8s
[*]const u8   ::  pointer to unknown number of immutable u8s
*[2]u8        ::  pointer to an array of 2 u8s
*const [2]u8  ::  pointer to an immutable array of 2 u8s
[]u8          ::  slice of u8s
[]const u8    ::  slice of immutable u8s
```

This is just to show up how complex the types can go. In C we can either `const char *` or `char *const` and it means the same, but in Zig the position of `const` changes everything.

But after all of this downsides, there is something we can take from Zig:

```zig
const std = @import("std");
const Arena = std.heap.ArenaAllocator;

export fn arena_create() ?*anyopaque {
    const arena_ptr = gpa_allocator.create(Arena) catch return null;
    arena_ptr.* = Arena.init(gpa_allocator);
    return arena_ptr;
}

export fn arena_alloc(arena_handle: ?*anyopaque, size: usize) ?*anyopaque {
    const arena_ptr: *Arena = @ptrCast(@alignCast(arena_handle));
    const allocator = arena_ptr.allocator();

    const buf = allocator.alloc(u8, size) catch return null;
    return buf.ptr;
}

export fn arena_destroy(arena_handle: ?*anyopaque) void {
    if (arena_handle) |h| {
        const arena_ptr: *Arena = @ptrCast(@alignCast(h));
        arena_ptr.deinit();
        gpa_allocator.destroy(arena_ptr);
    }
}

// zig build-obj arena.zig -fPIE -O ReleaseSmall
```

Now we can use the Zig arena allocator in C. Don't tell this to anyone.

What did I wanted to mean with all of these? Zig has A learning curve. It's not just pick and play, and to properly write anything in it, you will need to know what the compiler does. Odin is just a better alternative, because if you know how to program, you can simply just start using it and things will work of how simple it is. I picked Odin, and from 0 knowledge I went to a multi-threaded grep clone in 5 hours, having just C as a background language.

Things like this matters. I like C so much I had put myself into so many projects like `cstar` (my abandoned project). The idea was to bring a second preprocessor to the language that is small enough to be embedded in any project, but at what cost? I planned automatic header generation, comptime code generation and execution, fancier macros, a module system that would integrate with another project of mine to build the entirety of the project without a build system. I also engaged in my own sort of C standard library. But in the end I just realized, that I was just doing it because I was uncomfortable with the language in the first place. I wanted C, but not C. Languages like Zig, Rust, Odin, Go, C3, Jai and many more have so many interesting features, I wanted them in C, into this language where it's the closest to assembly and bare minimum features. No language so far have ever brought a language in the same level of simplicity as C, but at little bit more lower level, and that could allow to, somehow, tinker with the compiler directly in any project. That's my programming language of the dreams.

> Edit from 2026-04-07:

Honestly, I really think C isn't really for me. I've been working in a C interface implementation, and I ended up coming with this: [permalink](https://codeberg.org/aocoronel/c-interfaces/src/commit/35223533c2cc7ffd64e5c517f8e3106068a702dc/main.c).

```c
// main.c
#include <assert.h>
#include <stdio.h>
#include <stdlib.h>

#define definitions
#include "add.h"

#define add(...) add(using, __VA_ARGS__)
#define err error(using)
#define orelse(...) orelse(using, __VA_ARGS__)

#define use(x) using = x

#define let __auto_type

int main(int argc, char *argv[]) {
    void *using;

    // Warning: __auto_type is a GNU extension. A portable approach would be:
    //
    // #define interface(name) __typeof__(const struct name##_vtable)
    let x = vector2(.x = 190.0, .y = 0.0 );
    let b = vector2(.x = 20.0, .y = 0.0 );

    use(&x); // expands in add()

    x.add(b).add(b); // use interface

    $vector2.add(b); // global

#define str $vector2
    str.add(b); // renamed global

    vector2().add(b); // init and use

    assert(x.x == 190.0 + (20.0 * 5.0));

    let z = vector2( .x = 0.0, .y = 0.0);

    {
        use(NULL);
        z = z.add(b).orelse(b); // add fails, return b
        assert(z.x == b.x);

        // try
        if (z.add(b).err) return 1;
    }

    abort(); // unreachable
}

// gcc main.c -O3 -flto -S
```

This is way too much. Any C developer that look at this will have a heart attack. And in fact this is a valid C program that compiles with `gcc`, `clang` and `zig cc`, and the generated assembly just returns 1. The vtable can be devirtualized and everything is inlined we if we don't make `x` volatile.

Always, after a while I give a look at other programming languages, like Zig, Odin, C++, D and Rust, just to name a few. Lastly when I looked up to C++ (which has all the features I would love C to have, but unfortunately has way too much), and I made a simple program that returns 0 right away. I compiled it and ran valgrind, then I got surprised, because with just that the program allocated 73kb. Just right now I discovered a interesting flag you can pass to the C++ compiler, the `-nostdlib++`. This is enough to remove that weird 73kb allocation, and now apparently I can use C++ as C... we will see, if it's a good idea to use it like that, or use this even insaner C implementation or just give up to Zig or Rust already.
