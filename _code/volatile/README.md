---
title: volatile
description: Wipe files using a whitelist or blacklist
source: ./volatile.c
---

`volatile` is a **destructive program** that removes files based on a whitelist or blacklist. Use with caution.

It's use case is meaningful when dealing with volatile directories, where many leftovers often reside, like the `.cache` directory.

## Features

- Remove files based on whitelist or blacklist
- Remove empty directories
- Supports regex

## Usage

```text
volatile | Wipe files using a whitelist or blacklist

Usage:  volatile [OPTIONS] [DIR]

Options:
  -D, --debug
          Enable debug mode
  -V, --verbose
          Enable verbosity
  -d, --dry
          Preview actions
  -f, --file <FILE>
          Use an alternative allowlist file
  -h, --help
          Displays this message and exits
  -i, --invert
          Enable blacklist mode
```

### Examples

`volatile` defaults it's working directory to the current directory. If an allowlist file is not found, it'll exit preventing destructive actions. The default allowlist file is `allowlist.txt`.

An allowlist consists of filenames with regex support:

```bash
.*\.c$
.*\.h$
README\.md
data_[0-9]+\.txt
```

The file above will allow files ending with `.c`, `.h`, a file named `README.md`, and files named like `data_2.txt`. If no flags are passed to change `volatile` behaviour, this should **eliminate all** files, except the ones listed in this file, including the file itself. However, if the `-i` option is passed, the behaviour is inverted. In this case, `volatile` will remove all files included in this allowlist file.

**Example:**

```bash
❯ tree -L 1
.
├── fontconfig
├── glycin
├── librewolf
├── mesa_shader_cache
├── nvim
├── rofi-4.runcache
├── rofi-entry-history.txt
├── rustup
├── swww
├── swww-wallpaper.jpg
├── tree-sitter
├── ueberzugpp
├── wine
└── yay
```

```bash
# ~/myblacklist.txt

# Empty lines or lines starting with '#' are ignored.

^rofi-*
glycin
event*
```

```bash
volatile "$HOME/.cache" -i -f "myblacklist.txt"
```

```bash
❯ tree -L 1
.
├── fontconfig
├── librewolf
├── mesa_shader_cache
├── nvim
├── rustup
├── swww
├── swww-wallpaper.jpg
├── tree-sitter
├── ueberzugpp
├── wine
└── yay
```

## Compiling

```bash
gcc volatile.c -o volatile
```

## License

This repository is licensed under the 3-clause BSD license.
