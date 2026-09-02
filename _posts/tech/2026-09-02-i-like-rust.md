---
title: I like Rust
description: I like Rust so much, I regret not rewritting my Rust projects to another language earlier
date: Sep 02, 2026 17:00
---

Today I've rewritten my only Rust project, that isn't an experiment, in Odin. I've not only rewritten it, but also added a couple of new features the original didn't had.

I'm really happy with that, not only for the result, but the experience of doing it. Odin is such an enjoyable language, which completely does it's main goal of "Joy of Programming" very well done.

But. Fine, what were the real benefits of doing it? My Rust version was fully independent, which means I was only using the standard library to make it true. It led me to write my own INI parser, which isn't really a big of deal. Rust by default doesn't come with a CLI parsing library, so many Rust developers go use `clap` instead, and it's a totally overkill library for anything not like `cargo`. The problem is that now I have to manually parse the arguments and write the help function.

In terms of safety. This is a batch program, and only opens files, removes files and symlink files. It's never supposed to be ran as `root`. I get no benefit out of it.

In terms of ergonomics. The language is extremely noisy, and doesn't stop to get on my way. I almost get a heart attack of how many useless warnings the compiler throws at me, absolutely spamming my console. Give me the real errors.

I barely had to implement much things by hand in Odin, in this rewrite. The INI parsers was already there, but I had to make some modifications to it, mostly for the sake of giving a better user experience. There is already a flag parser library, which skipped me needs to hand write a help function and parse args manually.

In terms of ergonomics. This language gives an ability to write code in a way no other language I tried so far can, thanks to many keywords and operator overloadings builtin. And I'm serious to the point, this language is nicer to write than Python. We are talking about a systems programming language, and that's huge.

The core library of Odin may fail me some times, however I'm delighted to see how customizable it can be, specially `core:log`. You can customize the `Level` strings, which information is provided, all in an interface that is cross-platform.

Final veredict. While there are still an ascending number of Rust developers, I can only get more reasons to don't use it.

Note: Through the whole rewrite I used AI twice, to help me fix bad behavior in `expand_env` and in `change_dir`, the rest was hand written around 4 hours.
