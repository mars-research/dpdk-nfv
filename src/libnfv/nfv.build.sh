#!/usr/bin/bash

set -xeuo pipefail
cd $(dirname "$0")
/users/BUXD/SFI/dpdk-nfv/user-trampoline/sxfi/build/rewriter/sxfi-clang -fno-stack-protector -shared -nostdlib -o nf1.so nf1.c
/users/BUXD/SFI/dpdk-nfv/user-trampoline/sxfi/build/rewriter/sxfi-clang -fno-stack-protector -shared -nostdlib -o nf2.so nf2.c hashmap.c packettool.c
/users/BUXD/SFI/dpdk-nfv/user-trampoline/sxfi/build/rewriter/sxfi-clang -fno-stack-protector -shared -nostdlib -o nf3.so nf3.c hashmap.c packettool.c
/users/BUXD/SFI/dpdk-nfv/user-trampoline/sxfi/build/rewriter/sxfi-clang -fno-stack-protector -shared -nostdlib -o nf4.so nf4.c maglev.c packettool.c
#/users/BUXD/SFI/dpdk-nfv/user-trampoline/sxfi/build/rewriter/sxfi-clang -emit-llvm -fno-stack-protector -nostdlib -c -o nf4.o nf4.c
echo success!