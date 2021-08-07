#!/bin/bash
set -euo pipefail
OUTDIR="log/papi/"
OUTDIR="${OUTDIR}/$(date +"%m-%d-%H-%M-%S")_papi_out/"
BUILD_DIR=build_papi/

mkdir -p ${OUTDIR}

if [ ! -d ${BUILD_DIR} ] 
then
    meson -Dpapi=true ${BUILD_DIR}
fi
ninja -C ${BUILD_DIR}

run() {
  sudo PAPI_OUTPUT_DIRECTORY=$2 ./$1/$2 -- --portmask=1 --max_packets=2 --network_functions=$3 | tail -2 >> ${OUTFILE}
}

for nf in 1 2 3 4
do
  echo "NF${nf}" >> ${OUTFILE}
  for name in 'notrampoline' 'rust'
  do
    for burst in 1 32
    do
      bin_name="nfv-${name}-${burst}"
      run ${BUILD_DIR} ${bin_name} ${nf}
    done
  done
done
