#!/bin/bash
set -euo pipefail
OUTFILE="$(date +"%m-%d-%H-%M-%S")_out"
BUILD_DIR=build/
NO_SIMD_BUILD_DIR=build_no_simd/

ninja -C ${BUILD_DIR}
ninja -C ${NO_SIMD_BUILD_DIR}

run() {
  sudo ./$1/$2 -- -p 1 -t 3 | tail -1 | tr -d '\n' >> ${OUTFILE}
  echo >> ${OUTFILE}
}

for name in 'notrampoline' 'nofxsave' 'fxsave' 'rust'
do
  for burst in 1 4 8 16 32
  do
    bin_name="nfv-${name}-${burst}"
    run ${BUILD_DIR} ${bin_name}
    run ${NO_SIMD_BUILD_DIR} ${bin_name}
  done
done

python3 parse.py ${OUTFILE}