---
title: Programs I Use
description: A collection of all the programs I use daily
---

> Last update: 2026-08-29

## Philosophy

I choose software based on the following criteria:

- If a tool has remote syncing, all data should be still available locally, instead of blocked by an internet connection.
- I must have access to all my data, no matter what.
- If I decide to switch tools, they must allow me to export my data.
- I should be able to tinker with the tools, to shape them to fit my needs best.
- The usage must be clean and simple.
- 90% of the software I choose has its source open, often free to fork and change.
- Most tools I use does not have an interface, which turns them scriptable in many ways.
- I prefer lightweight solutions.

### Proprietary Software

I'm okay with having one or two proprietary software, but I do not accept myself relying on them, for essential things.

## Programs I Use

For a full list of all the programs I use, you can check on [aocoronel/pacmirror-config](https://github.com/aocoronel/pacmirror-config). This list is always updated.

The following list of packages are the ones I have a personal preference over. It doesn't mean their are the best ever.

- **Display manager**: None. I just run `startx`
- **Display server**: Xorg
- **Filesystem**: xfs
- **Init system**: dinit
- **Operational system**: Artix Linux
- **Window manager**: dwm without patches

Arch-based specific:

- **AUR helper**: None. I vendor PKGBUILDs from AUR, instead.
- **Declarative package management**: [pacmirror](https://github.com/aocoronel/pacmirror.c)

Theme:

- **Cursor**: adwaita-cursors
- **Font**: jetbrains-mono
- **Icons**: adwaita-icon-theme
- **Pallete color**: [elegantvagrant](https://github.com/aocoronel/elegantvagrant)

Software:

- **Audio editor**: tenacity
- **Backup**: restic
- **Bookmark manager**: [bmark](https://github.com/aocoronel/bmark)
- **Clipboard manager**: clipmenu
- **Document converter**: pandoc
- **Dotfile manager**: [neostow](https://github.com/aocoronel/neostow)
- **File encryption**: gnupg
- **File manager**: ranger
- **File syncing**: sync files using sftp, and rsync over ssh
- **Firewall**: ufw
- **Graphical debugger**: gf2
- **Image editor**: GIMP
- **Keybinding manager (or something like that)**: sxhkd
- **Media converter**: ffmpeg
- **Media player**: mpv
- **Notification daemon**: dunst
- **Office**: libreoffice
- **PDF viewer**: zathura
- **Password manager**: `pass` to store OTP, and [tinypass](https://aocoronel.github.io/tinypass/index.html) as my stateless password manager
- **Screenshoter**: ksnip
- **Shell**: zsh
- **Terminal emulator**: st without patches
- **Video editor**: shotcut
- **Web browser**: brave with SurfingKeys and Tampermonkey
- **Window swithcer**: rofi

Emacs:

- **Accounting**: ledger-mode
- **Email Client**: mu4e
- **File manager**: dired
- **Git Interface**: magit
- **Image viewer**: image-dired for gallery display
- **Music player**: emms
- **PDF viewer**: pdf-tools
- **RSS Client**: elfeed
- **Task management**: org-mode
- **Text editor**: emacs

Other:

- **Note-taking**: black pen and A4 white paper, or org-roam in Emacs
