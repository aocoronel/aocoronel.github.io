---
title: bsp
description: simple bash preprocessor
source: ./bsp
---

`bsp` is a very simple script, which aims to allow users to write shell scripts that span multiple files, without the worry to still put it all into a single script file.

## Installing and Using

Just copy the `bsp` file over, and run: `bsp yourshellscript.sh`.

There is also an example below, which is available at `./test`.

```bash
❯ cat shell1.sh
#!/usr/bin/env bash

. shell.sh

echo "$myscript"
echo "$current_dir"

❯ cat shell.sh
. current_dir.sh
myscript=myscript

❯ cat current_dir.sh
current_dir="$(dirname "$(realpath $0)")"

❯ make
../bsp -V -o main test/shell1.sh
>>> compiling /home/aoc/dev/disroot/bsp/test/shell1.sh
>>> compiling /home/aoc/dev/disroot/bsp/test/shell.sh
>>> compiling /home/aoc/dev/disroot/bsp/test/current_dir.sh
>>> finished compiling main
```

The output:

```bash
❯ cat main
#!/usr/bin/env bash

current_dir="$(dirname "$(realpath $0)")"

myscript=myscript


echo "$myscript"
echo "$current_dir"

```

## License

This project is available as public-domain under the CC0 License.
