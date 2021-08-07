#!/bin/bash
set -euo pipefail
OUTDIR="log/"
OUTDIR="${OUTDIR}/$(date +"%m-%d-%H-%M-%S")_papi_out/"
OUTFILE="${OUTDIR}/$(date +"%m-%d-%H-%M-%S")_out"
BUILD_DIR=build_papi/
PAPI_EVENTS="PAPI_TOT_INS,PAPI_TOT_CYC,PAPI_BR_MSP,PAPI_BR_PRC,PAPI_BR_CN"

mkdir -p ${OUTDIR}

if [ ! -d ${BUILD_DIR} ] 
then
    meson -Dpapi=true ${BUILD_DIR}
fi
ninja -C ${BUILD_DIR}

run() {
  sudo PAPI_OUTPUT_DIRECTORY=$OUTDIR/$2 PAPI_EVENTS=$PAPI_EVENTS ./$1/$2 -- --portmask=1 --max_packets=2 --network_functions=$3 | tail -2 >> ${OUTFILE}
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
