#!/bin/bash
set -euo pipefail
OUTDIR="log"
OUTFILE="${OUTDIR}/$(date +"%m-%d-%H-%M-%S")_out"
BUILD_DIR=build/
NO_SIMD_BUILD_DIR=build_no_simd/

mkdir -p ${OUTDIR}

if [ ! -d ${BUILD_DIR} ] 
then
    meson ${BUILD_DIR}
fi
ninja -C ${BUILD_DIR}

if [ ! -d ${NO_SIMD_BUILD_DIR} ] 
then
    meson -Dsimd=false ${NO_SIMD_BUILD_DIR}
fi
ninja -C ${NO_SIMD_BUILD_DIR}

run() {
  sudo ./$1/$2 -- --portmask=1 --max_timer_period=3 | tail -2 >> ${OUTFILE}
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