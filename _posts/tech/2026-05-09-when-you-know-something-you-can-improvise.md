---
title: When you know something you can improvise
description: The only way to make yourself free from tutorials
date: May 9, 2026 08:00
---

It has been a year since I managed to install Arch Linux without the `archinstall` utility, not only to mention I installed NixOS, Void and Artix the same hardcore terminal only way.

Today I have a system running `xfs`, which cannot shrink, but I needed somehow to take a new partition off my system somehow...

Well I know `mkfs` and `cfdisk` and I'm used to use them while setting a new Linux system, setting up the boot, swap, root and home partitions.

To make this new partition I made a backup of my 170G home partition to the root one. Booted my system using the Artix Linux ISO, and deleted the home partition, created a tinier one and passed the backup over, then rebooted.

Once I booted in my system again, everything was OK, working just fine. And it's the first time doing this kind of thing, first try success. When you know something you can improvise, no gparted or GUI, just the plain old commands I learned a very long time ago.

Now that I gave some context. I want to argument more about the title of this post. When could I do something like this without knowing about those tools and how to install a Linux system like that? The popular style of installing a Linux distro like it's done with Arch Linux is not a bad user experience. Booting with the installer ISO is just the most underrated skill a Linux user could have. You can troubleshoot and do some operations that would, otherwise, be impractical in a running system.

It's fairly interesting... once one like me would look into a tutorial or YouTube video to teach me how to do this, but I can just take it myself! It hits different, just wanted to share this moment.

See ya!
