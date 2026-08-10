---
title: aoclibs now runs in FreeBSD
description: FreeBSD is our second home, case something horrible happens to Linux
date: May 30, 2026 08:00
---

> TL;DR If you clicked because of the title, only one line in aoclibs was made to run in FreeBSD. Now aoclibs supports Linux x86_64, aarch64 and FreeBSD x86_64 (currently tested)

I decided to give other operational systems a try, including a second chance for Windows. I wonder if I could write code and run aoclibs in order to see how portable it is.

Then I installed Windows in bare-metal again, after almost three years I moved to Linux. Since I've became a Linux user, I started to say Windows sucks, that didn't change. I got `wsl` working with Arch Linux, installed Emacs and in my first C hello world I noticed how input in Windows is so slow. Apparently nothing can be done about that. Then I had the bold idea to compile the C program in the Windows style, just to see how it's done. After one hour of hitting my head against the wall, I finally discovered that I needed Visual Studio Build Tools, and then install 3GB of C++ Desktop whatever. Did I go that route? Obviously no! Who am I to download 3GB of bloat to compile my C program?

C isn't that complicated. What it does is preprocess the file and basically provide the compiler a single file, which is the translation unit. The compiler will lex, parse, some may also generate AST, and then emit assembly. After that the compiler will call the assembler to turn assembly into binary, which can be ran by the machine. What is 3GB for this simple task? But of course, Microsoft doesn't even name the package like "C" but "C++", because why not, right?

I went the `MinGW` route, but that's honestly bizarre. I'm in Windows running Linux to compile using `mingw` to compile a PE to run in Windows...

I also did slightly tried `windows.h`. This API is probably based in C++ code. I can't really tell, but it's a Microsoft thing like C# and C++ to make an entry point called `WinMain`, so you can make your GUI Windows program, just so I realized when I was resizing the window, that it doesn't live resize like in Linux. What OS is even this?

I still hold my words. Windows gives the worst user experience for installing drivers, software, customization, window management, overall performance and updating the system. Not only to mention it's powered by most corporate proprietary garbage. In my early days I would never note these, because Windows was just the gatekeeper for my games, but now that I care about usability, I just can't stand it. Microsoft officially declared Windows lost to Linux for desktop, by their new Linux distro called Azure Linux 4.0 for **GENERAL AND DESKTOP USAGE**. You shall now use `wine` to run the favorite apps that vendor locked you in.

Anyways. I decided to never ever write a Windows program, neither support it in my libraries including `aoclibs`. I don't have time, neither want to deal with it. I'm always told people need a system for them to do things, even if they are not nerds like me, and also hear developers write software for it, because the majority of users are at Windows, and it's the system where developers can make most money from. It's fine if you think about this side of the coin, but I just don't care.

MacOS? I don't have, neither want to have Apple hardware to be vendor locked in it as well. Not happening.

Now that I excluded the corporate operational system (I don't have to tall about ChromeOS, right?), I have actual nice other options to try: NetBSD, OpenBSD, FreeBSD, DragonflyBSD and Haiku. And maybe some others I still don't know about.

It has been a time I wanted to try FreeBSD out. I decided to give it a try first. From all the Linux distros I ever tried, none compares to the ease of install and speed to install it. It took around 7 minutes to install in my old laptop. Installing packages was also a breeze, and after messing a little bit with the ports system, this OS is very daily driveable for me.

The only oddity I found was that conky and btop were showcasing high memory usage, that was demystified by htop. But still the system takes more RAM than Linux.

Have I already mentioned the installation was easy? Even to setup Wifi was a breeze, which usually gives me a little bit problems in Arch and Artix installs.

I also tried to compile aoclibs from FreeBSD, and for my surprise I only took removing a line that was including alloca.h, and it worked. I committed and pushed this single change from FreeBSD, and now I'm officially supporting FreeBSD, as of tested OS.

FreeBSD seems to be the most desktop friendly among the different BSDs that are not a fork of it. I'm still gonna give a try to the other ones anyway.

You should also try it out.
