---
title: A better AUR
description: Why care about aur.archlinux.org? Have your own.
date: Jun 14, 2026 08:00
---

## I found an alternative to the AUR and AUR helpers

After quite a long time, I finally found my alternative to AUR helpers. If you are not a Arch Linux user, the AUR is a repository users can provide a shell script that contains the instructions to download a binary or compile software and install them with full support with the `pacman` package maanger.

Last month I've been playing with the idea of the Crux Linux port system, and lately I was playing with the FreeBSD one as well. This is not that unique to them. Actually, Gentoo, Void, Arch, Alpine and so many other linux distros does something similar, but in a different way. Gentoo may be the most powerful out of the bunch, for people who want to customize all software in their system, without having to tweak program by program and manage their dependencies theirselves, unlike Crux Linux. But what made me like Crux Linux specifically? It's the simplest port system I've ever seen. Here is a copy-pasted example on how they ship `bash`.

```shell
# Description: An sh-compatible command language interpreter
# URL: https://tiswww.case.edu/php/chet/bash/bashtop.html
# Maintainer: CRUX System Team, core-ports at crux dot nu
# Depends on: readline

name=bash
version=5.3.15
release=1
source=(https://ftpmirror.gnu.org/gnu/$name/$name-${version:0:3}.tar.gz
    $name-$version.patch.gz profile)

build() {
    cd $name-${version:0:3}

    gunzip -c $SRC/$name-$version.patch.gz | patch -p0

    ./configure \
        --prefix=/usr \
        --exec-prefix= \
        --disable-nls \
        --with-curses \
        --with-installed-readline
    make -j1

    install -D -m 755 bash $PKG/bin/bash
    install -D -m 644 doc/bash.1 $PKG/usr/share/man/man1/bash.1
    install -D -m 644 $SRC/profile $PKG/etc/profile
}
```

The equivalent Gentoo ebuild is 100+ lines long, and it includes other shell scripts for other files. Here everything is self contained.

This made me continue working on my quite old project: `dpm`. The idea was to provide this kind of packaging to any linux distribution. This still not usable in production, and the project is currently halted. Mostly because I rely on `aoclibs`, and I always have go to implement something I need, before continuing, but after I'm done I forget about what I was doing previously. I'm going to finish it.

"But, ok, what about the AUR thingy you mentioned in the tittle?". The latest news on AUR malware gave me the last dopamine hit to implement my own sort of AUR helper. `pacmirror` was previously using an AUR helper that the user provides, but now it's deprecated. What does it do instead?

Taking all of what I said so far, why not to use the infrastructure `pacman` already has to deliver the "same" experience Crux Linux has to Arch-based linux distros? What a beautiful idea, isn't it? Crux Linux is all about you putting your ports in a git repository and them syncing them with `httpup`, if you want. Here is what I did.

The `makepkg` program reads the `PKGBUILD` file in the current working directory (all AUR helper do this, btw). There is the instruction to download, build and install software. And in fact you can write a hello world in C locally and install it with this.

Now, `pacmirror` does looks into `pkg/` where you should vendor all the PKGBUILDs that you want to install, so now I have control over what you install, I can modify it freely and adjust it to my needs. As an example I use Artix Linux, and the `anydesk-bin` package install some files for `systemd`, which Artix doesn't support, so I stripped it all. I never realized how much better this approach is, rather than using `yay`. Of course, Arch's packaging system is more complicated than Crux's ports, but it does the trick.

Specifically for the malware problems AUR is facing. People are suggesting to stop using the AUR momentously, but only if you are a rockie and can't read shell. If anyone even considers using Arch solely for the AUR, you should at least know it. And here is my take on this: Vendor you PKGBUILDs. Control it, maintain it yourself. It's one less dependency you will have, and you are covering your #!@#, against a blind `yay -Syu` that install the legendary `npm` to backdoor your system. Or, am I wrong?

My main goal in this post is done. But I'll take this opportunity to talk more about package managers in general.

## Package managers to install software

Or you are either an Archman (Arch Linux) or an Sleekman (Slackware) user. This means you don't have to care about upgrading, nor care about dependencies, and to care, respectively. Each approach has it's advantages and tradeoffs, per usual. The hype of Slackware is that we manage all software and dependencies ourselves. Absolute nothing is automated, we gotta get the source code or the binary and install it. This gives us the power to choose to get customized software or not. And since we're less prone to upgrade the system, we will end up breaking our system less often. The Arch hype, however is that you can install 3.000+ packages, and still chill, because `pacman` takes the rest. The Gentoo hype is that it's as automated as Arch, but we can programatically ask how the program are going to be compiled, stripping everything we don't need, and optimizing everything to our hardware. The Void hype is that it's more stable than Arch, and still let's you source-compile by using `xbps-src`. The Bedrock Linux hype is that you can enjoy many linux distros without dual booting, by using Arch + Void + Gentoo. The Crux Linux hype is that you have the same experience as Slackware, but at least things are more centralized, so you can easily update your software and add new ones. The NixOS/Guix hype is that you write a configuration file and it can reproduce your system anywhere.

There is not best way to do it, each approach has it's tradeoffs. Or you abandon dependency hell automation to be in control, and them loose hours of your day when you decide to update your system, or give in to dependency hell automation and get those hours to do something else. Artix Linux works perfectly for me, I feel productive in it, and it works for me. All the issues I had so far could be solved with updating some software I thought were having issues, and in fact it did. I didn't bother move from Artix in a long time, not only for the fact that I have a lot of niceties, including first-class support by Artix for some software that are often left aside by other distros to be user maintained.

My take is balance. Mostly automating this is fine, but I would rather like to see modern package managers let users choose to install software will all their dependencies in isolation like NixOS does, but for a specific program you don't want polluting your libraries and binaries, potentially causing mismatched dependency versions somewhere else, specially for bloated software.

## Package managers for libraries

We already know that `npm` is a good example why package managers are evil. This is not just a toy program that aids facilitating dependency resolution. This is a very sensible piece of software. If you put a malware there, all the code that uses it are infected. Many other package managers that behave like it are prone to the same issues. And still new languages are baking their own `npm`-like package managers to do the same mistake.

For library dependencies, it's better to vendor them. Vendor either the compiled library, the source code or even both, if you can. It's not just matter of protecting yourself against `npm` like issues, but also to reduce moving parts in your projects. The more libraries you depend on, using this tactic, the less you will want to add another one, because they are not automated.Then, we can even say this helps you think when you actually need a library, or you can implement what you need yourself.

Is there a moment where it's actually okay? Maybe, I don't have such use case.
