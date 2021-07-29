#!/bin/bash
set -euo pipefail
rm -f out
run() {
  sudo ./build/$1 -- -p 1 | tail -1 | tr -d '\n' >> out
  echo >> out
}
run nfv-notrampoline-4
run nfv-nofxsave-4
run nfv-fxsave-4
run nfv-notrampoline-8
run nfv-nofxsave-8
run nfv-fxsave-8
run nfv-notrampoline-16
run nfv-nofxsave-16
run nfv-fxsave-16
run nfv-notrampoline-32
run nfv-nofxsave-32
run nfv-fxsave-32

run() {
  echo -n "no_simd_" >> out
  sudo ./build_no_simd/$1 -- -p 1 | tail -1 | tr -d '\n' >> out
  echo >> out
}
run nfv-notrampoline-4
run nfv-nofxsave-4
run nfv-fxsave-4
run nfv-notrampoline-8
run nfv-nofxsave-8
run nfv-fxsave-8
run nfv-notrampoline-16
run nfv-nofxsave-16
run nfv-fxsave-16
run nfv-notrampoline-32
run nfv-nofxsave-32
run nfv-fxsave-32