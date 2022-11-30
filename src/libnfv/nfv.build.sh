#!/usr/bin/bash

# set -xeuo pipefail
# cd $(dirname "$0")
# gcc -g -O3 -fno-stack-protector -shared -nostdlib -o nf1.so nf1.c
# gcc -g -O3 -fno-stack-protector -shared -nostdlib -o nf2.so nf2.c hashmap.c packettool.c
# gcc -g -O3 -fno-stack-protector -shared -nostdlib -o nf3.so nf3.c hashmap.c packettool.c
# gcc -g -O3 -fno-stack-protector -shared -nostdlib -o nf4.so nf4.c maglev.c packettool.c
# echo success!

set -xeuo pipefail
cd $(dirname "$0")
./../../llvm-SFI/build/bin/clang -fPIC -fuse-ld=$PWD/../../llvm-SFI/build/bin/ld.lld $NIX_CFLAGS_COMPILE $NIX_LDFLAGS_FOR_BUILD -g -O3 -Wl,-Bshareable -Wl,-Bstatic -fno-stack-protector -shared -nostdlib -o nf1.so nf1.c
./../../llvm-SFI/build/bin/clang -fPIC -fuse-ld=$PWD/../../llvm-SFI/build/bin/ld.lld $NIX_CFLAGS_COMPILE $NIX_LDFLAGS_FOR_BUILD -g -O3 -Wl,-Bshareable -Wl,-Bstatic -fno-stack-protector -shared -nostdlib -o nf2.so nf2.c hashmap.c packettool.c
./../../llvm-SFI/build/bin/clang -fPIC -fuse-ld=$PWD/../../llvm-SFI/build/bin/ld.lld $NIX_CFLAGS_COMPILE $NIX_LDFLAGS_FOR_BUILD -g -O3 -Wl,-Bshareable -Wl,-Bstatic -fno-stack-protector -shared -nostdlib -o nf3.so nf3.c hashmap.c packettool.c
./../../llvm-SFI/build/bin/clang -fPIC -fuse-ld=$PWD/../../llvm-SFI/build/bin/ld.lld $NIX_CFLAGS_COMPILE $NIX_LDFLAGS_FOR_BUILD -g -O3 -Wl,-Bshareable -Wl,-Bstatic -fno-stack-protector -shared -nostdlib -o nf4.so nf4.c maglev.c packettool.c
echo success!