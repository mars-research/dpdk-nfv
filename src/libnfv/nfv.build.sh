#!/usr/bin/bash

set -xeuo pipefail
cd $(dirname "$0")
gcc -g -O3 -fno-stack-protector -shared -nostdlib -o nf1.so nf1.c
gcc -g -O3 -fno-stack-protector -shared -nostdlib -o nf2.so nf2.c hashmap.c packettool.c
gcc -g -O3 -fno-stack-protector -shared -nostdlib -o nf3.so nf3.c hashmap.c packettool.c
gcc -g -O3 -fno-stack-protector -shared -nostdlib -o nf4.so nf4.c maglev.c packettool.c
echo success!