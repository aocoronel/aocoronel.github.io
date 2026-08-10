---
title: cc-sh
description: simple wrapper for gcc and clang with convenient flags
source: ./cc
---

`cc.sh` is a very simple wrapper for `gcc` and `clang` using recommendations provided by [C Compiler Security by Airbus-Seclab](https://airbus-seclab.github.io/c-compiler-security/).

## Usage

```bash
cc.sh

Usage: gcc/clang --CC=OPTION ...

Options:
  analyze          Enable analyzer (gcc only)
  debug            Enable most debug flags
  help             Display this message and exits
  integer          Enable integer protections
  leak             Enable leak sanitizer
  release          Enable optimizations
  stack            Enable stack sanitizer
  stack-protector  Enable stack protector
  thread           Enable thread sanitizer
```

## License

This project is available as public-domain under the CC0 License.
