---
title: I'm done with C
description: After keep pushing it, I'm done
date: Aug 10, 2026 15:00
---

Over the course of 1 year writing C code, which dates the moment I started programming altogether, I'm done with C.

I like the language, but as I already said, what makes a language bad or great is a collection of tiny things that add together. C isn't just a language people make dependable software, but is also a language that brings me frustration.

At the beginning anything was good for me, but as I've been getting more knowledgeable, I've been increasing my standards on what I consider to be a good API, library or program. This way I noticed how the language barely provides me the tools I need to meet my own paranoiac criteria. The thing is that C can be slightly amended with the preprocessor, but it's just a question of time until the implementation is almost just macros.

The fact that I wanted to make debugging easier, while only achievable through macros in my third allocator interface attempt, was driving me crazy. The lack of must have features is something that bothers me the most. And even if I ever wanted to stay C-ish, C++ wasn't there to actually solve my problems, while taking all these macros away.

At this point, I'm sure greatest part of `aoclibs` is now made by macros, as a way to make the API easier to use and have less boilerplate. But not just that, some macros where there to change the behavior of some keywords, such as `inline`, or for documentation only purposes like `null` (meaning the pointer may be NULL). And for me this is like addressing the limitations of the language, in terms of how the type system is capable of telling the user, about the usage of a certain function by itself without a documentation. This is relevant, because the user can just assume the usage and don't have friction on being forced to read documentation or the source code.

We need better programming languages. Even if C may be the language with the biggest set of tooling ever, it's not enough to make it better, even if I've been writing `aoclibs` for one year now, to make writing C fun, it wasn't enough. Even the languages that stand on the shoulders of C like Nim and V, they have to do some high level tricks on top of C, which lead to unreadable C code, even if they advertise emitting readable C. This is just a limitation of C itself which is unlikely to change.

We can always make an implementation of something in C, but at a certain point I noticed that I was shaping the language, rather than using it the way it is. This was my red flag to rethink if it was really worth it to continue like this. And it is my fault, since I already had this feeling before, but kept pushing it.

So my end decision was to move away from C, for the sake of don't hurting my genuine joy for writing code for hobby purposes.

So if I'm done, what's next? Well, C certainly made me care about implementation details, and in fact I take my allocations seriously. I care if I do malloc just for printing a string and freeing it, in this case I would rather have some recyclable memory, instead of wasting a syscall. I try to implement APIs that are versatile, and that can be structured in ways that "providing" a public API can't do. By that I mean, I write code thinking about exposing the code that would often be private.

This alone takes garbage collected languages and languages that have private by default from my options.

> Although I prefer manual memory management, I acknowledge that some projects have no reason to be written in C, and would just be better to be Python, for example

There is only one language that comes in mind, when the thing is public by default, manual memory management, and great design: Odin.

In fact, the deeper I go in it, the more I like it. It's by far the most C like language, that **actually** solves the main problems with C, and leaves thes same power of C at your hands. So here I am, an Odin user who doesn't uses it for game development.
