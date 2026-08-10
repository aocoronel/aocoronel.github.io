---
title: embed-bash
description: tiny example on how to embed executable in bash
source: .
---

This is a proof-of-concept project that aims to give a tiny example ony how to embed executables in bash scripts.

```bash
#!/bin/sh

# embed-bash.sh

output=hello_output.sh

write_to() {
  echo "$1" >> "$output"
}

cc hello.c -o hello

write_to "#!/bin/bash"
write_to "bin=\$(cat <<'EOF'"
base64 hello >> "$output"
write_to "EOF"
write_to ")"
write_to "echo \"\$bin\" | base64 -d > \"myexe\""
write_to "chmod +x myexe"
write_to "exec ./myexe"

# Output:
# !/bin/bash
# bin=$(cat <<'EOF'
# base64 encoded binary...
# EOF
# )
# echo "$bin" | base64 -d > "myexe"
# chmod +x myexe
# exec ./myexe
```

```c
// hello.c

#include <stdio.h>

int main(void) {
  printf("Hello, world!\n");
  return 0;
}
```

Usage:

```bash
./embed-bash.sh
```

## License

This project is available as public-domain under the CC0 License.
