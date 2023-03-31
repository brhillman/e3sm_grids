#!/bin/bash

set -e

source config.sh

mkdir -p ${output_root} && cd ${output_root}
datestring=`date +%Y%m%d`

job_cmd="" #"srun -C knl --account e3sm --time 01:00:00 -K -c 1 -N 1 --ntasks 1 --partition regular"

# Make ocn <-> atm maps
if [ ${ocn_grid_name} != ${atm_grid_name} ]; then
    echo "Make ocn <-> atm maps..."
    $job_cmd ncremap -P mwf \
        -s ${ocn_grid_file} -g ${atm_grid_file} \
        --nm_src=${ocn_grid_name} --nm_dst=${atm_grid_name} \
        --dt_sng=${datestring}
fi

# Make lnd <-> atm maps
if [ ${lnd_grid_name} != ${atm_grid_name} ]; then
    echo "Make lnd <-> atm maps..."
    $job_cmd ncremap -P mwf \
        -s ${lnd_grid_file} -g ${atm_grid_file} \
        --nm_src=${lnd_grid_name} --nm_dst=${atm_grid_name} \
        --dt_sng=${datestring}
fi
