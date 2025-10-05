+++
title = "NixOS - Usage Review" 
description = """Here are my thoughts on the amazing NixOS distro, which takes system configuration to another level, plus it's main principles of reproducibility and reliability."""
date = 2025-07-01
[taxonomies]
categories = ["tech", "linux"]
tags = ["cli", "nix", "opinion"]
+++

Here are my thoughts on the amazing NixOS distro, which takes system configuration to another level, plus it's main principles of reproducibility and reliability.

<!-- more -->

I have been using NixOS for some time now as a daily driver, so I'm here to tell my experience with it.

I expect this post to allow you to know the benefits of NixOS, its main issues and who would benefit the most from this distro.

From my whole experience of distro hoping, I've learned that each Linux distro has a purpose. There is not perfect distro for everything, but there are highly specific ones that will excel in a field. So NixOS has its own.

## TLDR

This is only related to NixOS. Since any Linux distro can install the nix package manager and Home Manager.

Pros:

1. NixOS is perfect for who want to rice their desktop system and make it effortless to enable or disable parts of the config. It also allows you to have different profiles for different machines using the same config.
2. It's also powerful for servers, so updating the config will synchronize the changes among all your servers.
3. Deploying a pre-configured system in multiple devices/servers. Even over SSH.
4. Declaring your system will allow you to never forget how to setup a program or a service, since it's all a file.
5. It's a immutable system. Running `nixos-rebuild` will regenerate all files that were changed to their original files from your config.
6. Breaking your system is possible, but the solution is: Rollback to a previous generation of your system.
7. You can go stable or bleeding edge.
8. Creativity is the limit.

Cons:

1. You will have to learn the Nix programming language basics. I'm not a expert in that language, but I made very far!
2. Rebuilding your system gets slower when your config gets large. It will have to evaluate your whole config and create a new generation from your system, even if you just added `git` to your environment packages.
3. Finding resources to guide you to setup X program or Y service may be hard for the lack of documentation.
4. Diagnose errors in your config can be very cumbersome, sometimes. It makes you almost give up.
5. It does not follow the FHS, so some things will not work out of the box, because they rely on that. You will have to adapt your scripts to run in NixOS by using `env`.
6. You can declare a lot of settings, but not everything. A good example is the lack of declarative partitioning, which is addressed by `disko`.
7. Expect to have a large disk usage.
8. NixOS is a time investment. This is a fact.

## My thoughts on NixOS

I initially used NixOS, because I had the idea of "The Lifetime Distro". By that I mean: I no longer will have to know all the steps to setup my system the way it is, therefore no chance to forget about setting up a program or service. So, all my changes to the config would never degrade overtime, for example: I reinstalled my distro and I forgot to enable my firewall with that particular config. This is a real problem when you use several tools. No way I can remember the whole setup process after a year. For four months of using NixOS I definitively can tell its a amazing distro. But I didn't knew I was about to change my thoughts on it. As I already mentioned, each distro has its perks for each field. And my goals changed to be more inclined to Arch Linux, because NixOS was becoming too overkill to me. The reason? Well:

Some of the issues I pointed in the TLDR section is the full config evaluation to just install `git`. NixOS does a great job, but in my view it is not efficient. It will be surely faster, than a full system upgrade, but it's still slower than using another package manager. Someone could point out to use the `nix-env` command, but I use NixOS the nix way.

If you ever got curious how long I took to make my NixOS config good enough to use it as daily driver, well it took me a whole week to replicate my previous setup from my Arch Linux install. You can look my config in here: [aocoronel/nix](https://github.com/aocoronel/nix). I definitively took my way up until here to turn back to NixOS... at least it helped me build a modular and well structured repository. It does not have a guideline file to explain how I organize the files, but you can guess it by reading it. At least I think so.

## My thoughts on Home Manager

Well, I used Home Manager just because I wanted to try it. It makes part of my config, but there is no truly reason to that to be there. Home Manager is a user based nix-like configuration without relying on root privileges. It allows you to install and configure programs and manage your `$HOME` directory from a single or modular config. I get the point of Home Manager, but it is a struggle to setup, just like NixOS. I use `stow` to manage my dotfiles, btw. Doing so I have an agnostic config without relying on Home Manager. For the user programs, just adding them to my NixOS config would be enough, and then Home Manager is useless to me.

## My thoughts on the Nix Package Manager

This is surely one of the coolest package managers I ever used. I can try any software without really installing it in my system, create development shells to end the dependency hell, and it also allows developers to ship flakes so the users that have the nix package manager can install their programs without headaches of thinking about dependencies. Everything just works. NixOS empowers the nix package manager experience by allowing you to configure what programs are installed, something that you can only have in other distros, if you have Home Manager. Not even the software themselves suffer from dependency hell, when a X program need Y dependency at this version and W program needs Y at that other version. This package manager may not be beneficial for everyone, but it's a must for every developer that program using languages like Python and C, since imports are got from installing programs in the system. So create a `shell.nix` with all dependencies will allow your Python code to run and your C code to compile.

## Conclusion

NixOS is not a bad distro, it's pretty good, actually, but it can be overwhelming if you are not ready to put your time into it, since there is a lot to do, to make it a daily driver, at least for a desktop experience.

If the idea of reproducibility, declarative and reliability resonates with you and you want to try NixOS, you can check on someone's else configuration to get started with, it helps a lot.

I greatly recommend you to give a look at Emmet's (LibrePhoenix) configuration at [librephoenix/nixos-config](https://gitlab.com/librephoenix/nixos-config). I totally took a lot of inspiration from him in my NixOS journey. Really appreciate!
