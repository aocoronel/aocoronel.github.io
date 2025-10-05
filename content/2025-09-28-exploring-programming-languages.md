+++
title = "Exploring Programming Languages"
description = """My journey on trying different programming languages as non-programmer featuring Bash, Python, JavaScript, HTML, CSS, C, C++, Rust, Zig, Odin, Go, Nim and Lua."""
date = 2025-09-28
[taxonomies]
categories = ["tech", "programming"]
tags = ["timeline", "opinion"]
+++

My journey on trying different programming languages as non-programmer featuring Bash, Python, JavaScript, HTML, CSS, C, C++, Rust, Zig, Odin, Go, Nim and Lua.

<!-- more -->

## Introduction

> I'm not a programmer, so expect this post to be very optionated, and fun. I guess.

My very first contact with programming was when I was trying Qtile, which is configured in Python. I still don't know Python today, besides the basic syntax and features all programming languages has.

I started to like about programming after watching a video of [Cloud Native Corner](https://www.youtube.com/@cloud-native-corner) about Taskwarrior, where his terminal workflow just drove me crazy. He made me rethink the way I was using my computer. Very soon, I started my bash scripting journey.

## Bash

My real experience with creating something was in Bash. I do not consider Bash a programming language, but a scripting language. It's possible to a lot with Bash, but it cannot go way too far. Certainly, my favorite language.

Bash scripting is a glue language, just like Python, that allows you to run different programs that takes an argument and outputs something, similar to how a function works.

Essentially you can give a shell script a name "John Doe", and it can do a lot of things with it, for example, output just "Doe" by running: `echo "John Doe" | awk '{print $2}'`.

I made several scripts and actual programs in Bash, which you can find all of them in my GitHub. A brief collection:

- `forg` - File Organizer written in Bash, which was rewritten in C.
- `eureka` - A idea manager program inspired by a program of the [same name](https://github.com/simeg/eureka), written in Rust.
- `pass` - A clone of passwordstore which uses `age`, instead of `gpg`.
- `neostow` - Stow, but operations are instructed by a file.
- `repox` - Bulk operations with git, mainly clone, fetch, pull and push.
- `media-converter` - A simple script that figures out what you are trying to convert, with support to compression, powered by FFmpeg.
- `tmux-manager` - A tmux sessionizer powered by `fzf`, `find`, `zoxide` and `tmuxp` to create sessions, and a preview of each session.
- `rofipass` - A rofi script to interact with passwordstore and it's `otp` and `tomb` plugins.
- `bmark` - A bookmark manager powered by `sqlite3` with support to bulk operations like editing a plain text file.
- `build-pages` - A script that uses `pandoc` to produce this blog.
- `mirror` - A way to declare what programs are installed in a Arch system, like NixOS.
- `jn` - A journalling helper that uses `fzf` and `rg` to search notes.
- `doppel` - Run commands in a different directory(ies).

All of these are available in my GitHub, some are at my `dotfiles` repository.

Bash can do anything, by living in the shoulders of other programming languages.

Many can say, Bash is a weird language, or, even complex and difficult, but I find bash extremely easy compared to any other programming language, by the simple fact it's very stripped down in features.

Besides Bash, there is POSIX compliant scripts, that have maximum compatibility with other shells, has less features, but introduce better performance.

This language is at my heart, but I learned to not use Bash for some tasks, when I needed more features and control.

I've always seem programming languages like collectables to show up in a shelf like trophies, but it's so much more than that. I have many prejudices to some languages, while admiring others.

Bash is the only language I have confidence to say it's great, because I've been using it for almost a year.

## Python

Python is the easiest programming language, mainly because it's just a language that glue the work of other programming languages, just like Bash, but in a more integrated way.

Python is used everywhere from backend to machine learning, it does abstract a lot, to make you more productive and ship faster.

There are two main flaws that Python programmers always complain about: It's a interpreted language, and it has GIL. Basically, any performance-critical task must not be done in Python, it wasn't made for that.

Python for me is just a programming language to express your ideas and get feedback quickly by prototyping.

Besides that, it's also the language with the biggest amount of resources for you to learn. But, even if it's put as the easiest programming language, it's very easy to fall to delusion you will get a job in one month, be realistic.

I don't have any sort of expertise in Python, but I use it when my ideas are so simple, they don't need to be written in a "low-level" programming language.

Some projects in my GitHub written in Python:

- `sear` - It's a tool to interact with Kagi Bangs, essentially a JSON file, to search directly in the search from websites, rather than a search engine like Google.
- `webshare` - A simple http server to download and upload files.
- `bmark-bulk` - The bmark extension to make bulk operations (in bmark repository).

I personally do not like Python, but it's perfect to find out very fast, that your idea was not that great.

## Go

Basically a balance of C and Python to produce code that scales, is easy to maintain and it's fast.

Everything about Go is good to me, except for the fact it's too easy to add external dependencies to projects, no optimizations are allowed in the binary, and the binary sizes are huge (2 MB for a hello world program). Even if go projects can end up like 60 MB of binary size, it's still extremely fast and efficient.

The main reason something may not be written in Go is because the GC is obligatory. You cannot take it out, thus large projects may have GC spikes. No huge server wants that.

The only thing I have in Go is `bmark-importer` which allows to import and export bookmarks from HTML to SQLite, and vice-versa.

The simplicity of Go just rocks, but I do not see myself writing real work in it.

## Nim

This one is Python on steroids, really. Python syntax and C-like speed. Promises to be very good, but my experience with Nim was very bad.

If you cannot live without LSPs and Tree-sitter, so this language will pose against you. Tree-sitter for Nim is the slowest I ever saw, taking more 1 second in Neovim, and 1 second in Helix to load. The `nimlanguageserver` just devours RAM and CPU.

The result of a program in Nim is just a little bit faster than Go, but it's just C with garbage collection and Python syntax.

Nim can transpile to C, C++ and JavaScript. Really, if you want to write C, C++ or JavaScript, just learn them.

While Nim can look extremely appealing, there isn't a clear place where it fits better, than other known languages.

My only project in Nim is `neostow-nim` a rewrite of neostow in Nim. So good it was archived.

## Odin

I talked about Python on steroids, this is Go on steroids. It's just feels like Go but all memory is manually managed.

Odin feels like the right language for me, once it's fully released and has a better documentation for the core library. The reason why Odin is good, is due to it's simplicity, while producing high performant code.

Odin has a philosophy to never support package managers. I didn't understimated that take, but once I understood the point of view from the creator, it just makes sense. Odin was my main reason to turn my back to many other programming languages like Ruby, Go and Rust. The beauty of this language, is that it forces you to take control, not only on memory management, but the project as a whole.

## Zig

Zig is simpler than Rust, but not as simple as C. It poses very hard to learn with few resources, not only to mention it's not fully released yet. It's also a good replacement to C with more safety features. The main thing about Zig is explicitness, where nothing is hidden from you.

Compared to Odin, I feel Zig is way too much, but there isn't many languages with drop-in replacement to C, specially how on Zig does it.

This language has a huge potential. Can't wait to see the first release.

## Lua

Quite enjoyable to write Lua. It can be used to any tasks where you need higher abstractions while building a program with a subtle loss in performance, while not perfect though. My experience with Lua was by modifiying configuration files in Neovim, which is one of the good reasons to use Lua in a project, it does immediatelly becomes scriptable without direct changes to the main program.

Lua is not good for standalone programs, since it's a interpreted language. It's often embedded in another language + the interpreter to allow complex extensibilities.

## JavaScript

Reigns over the web. JavaScript developers are everywhere building everything in it. Want frontend? Got it. Want backend? Got it. Want static-types? Got it (TypeScript). Want several frameworks to choose, debate and argue? Got it. Want to make games? Got it.

I often see Brazillian developers choosing the JavaScript path, learn Typescript, Node.js, many frameworks and say they are full-stack developers... shesh.

> This take, was based on several profiles I visited on GitHub. The chances for you to find a JS engineer is very easy, specially in Brazil.

I'm extremelly opionated about JavaScript. It was made for the web, and they put in the backend. JavaScript was made dynamically typed, and they made it statically-typed.

By the way, I love the UNIX philosophy, where programs should do one thing, and do it very well. But I take it to programming languages as well, and there is not reason why you would do everything in one language, ignoring all the trade-offs, just because it's the easiest path. You may get your work done, that's fine! However, what if the work had better results? Just my opinion here.

## HTML and CSS

Not a programming language.

If it's web, you bring both. I think if you want to produce interactive and graphical applications, the web path is the easiest way to do that. Not a surprise JavaScript developers made a way to write desktop applications using JavaScript as well...

HTML and CSS are everything about what we can preview in a browser, it can be as minimal as a CSS-less page, or as bloated to the point of getting slow to render.

## C and C++

The most used programming language for decades. This language is why we have other programming languages. C is the father of Bash and Python and several other languages, directly or indirectly.

Everything is possible, coding in it is very bare-bones, manual memory management backed by Math, all sorts of undefined behaviour (UB) are allowed, and if you need resources to learn C, just embrace manpages.

From all of the languages I've mentioned so far, C is the language that brought me a real joy in programming. I made just one program so far in C, I have no ideas how many security holes, UBs and problems it has, but it was an amazing experience to write it whatsoever.

C is the face of programming in a year, where many modern concepts and features were not a thing. When you reach to learn C, you get the very fundamentals of learning programming, and what you absolutely need to get a "Hello, World" in the stdout, or millions of lines to make a kernel which powers almost everything known to mankind related to digital devices. This allows me to talk about the next language: C++.

C with all the modern features I told C does not have. It's fairly easy to find YouTubers pointing out that C++ is a very complicated language. That's the decision of the developer, since C++ can be written like C, with a feature or other from C++.

From all of the collection of C languages, the fundamentals is the same. You have full control over what you are doing, and if something goes wrong, it's your responsability. The compiler will always take, that the developer does know what they are doing, but if you don't know... well, guess we are screwed.

The C status today is up-to-debate since there are always more people saying it's an unsafe language that should be deprecated.

I do not believe that. If C was that unsafe, surely 99% of all devices we use would just explode (hacked, crash...). While that happens, it's still not a good argument alone to move billions of lines of code to a "safer" language, that happens to use of unsafe features to get the very same result (performance). It is the effort of taking a bolder and putting another one in the place.

Those who write C are particularly good at writing C, while newcomers are insanely prone to commit vulnerabilities, it's a phase of programming all C developers have passed by, and does still passes. That's fine! We aren't perfect after all, but we can, sure, improve.

I do strictly believe that learning Rust does no replace the need for learning C. Specially, because in the end you will just enjoy Rust way more if you know why it exists in the first place.

## Rust

In my opinion, it's by far the hardest programming language you can learn today. If you follow along with the official Rust Programming Language Book, everything goes happily fine until you reach the Chapter that talks about Error Handling, Traits and Lifetimes. Suddenly everything get's too complicated and I don't even know why I'm learning it anymore. I read the whole chapter about Traits, and understood no single word. Skill issue, mostly. I get it.

While Rust does not have a memory management like in C, powered by Math, it's equally complicated.

I have no idea why it's insanely praised among programmers (written in Rust, btw) and it's being constantly adopted as a replacement to other languages... guess I'll have to learn it by a way or another? Really?

I like Rust, don't get me wrong, but I do not enjoy how Cargo works. Add a dependency is as easy as running a command in the terminal. Does it bring one dependency? Yes, but it does also have dependencies. So in the end you added one, and you got 20. The result? Your program was compiling in a blink, now it takes 2 minutes. Have I mentioned that developers may create APIs in the license they want? Then, you are working in a closed sourced project, and then, you accidentally got a GPL library in it...

We got a modern language and modern issues. Not going to Rust, I guess. Maybe I'll stick with the old and very well known UBs in C already documentated over decades by experts exploring the language.

## Conclusion

So I've onboarded all the languages I've tried and know a little bit about. Surely there are plenties of others. I'm developing CLIs, so I don't have to bother about languages like Haskell, Lisp, Erlang, Elixir, OCaml and many others.

Choosing a language is more about: This is the right language for the job, rather than just do it in Rust or JavaScript. It may feel very hard to pick one, and that's true. That's also another reason why I've chosen C. All the other languages offer some sort of compatibility with the C ABI, somehow, so learning C is a step to any other language.

After a quite long journey, that took me some several months trying, researching and exploring these languages, I landed on C. The only programming languages that are appealling enough to me are Zig and Odin.

That's my view for these languages, from the perspective of a non-programmer human with no real job at IT and no CS degree. Hope you enjoyed it.
