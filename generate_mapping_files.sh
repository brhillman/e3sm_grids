#!/bin/bash

# Parse command line arguments
if [ $# -eq 1 ]; then
    configuration_file=$1
    source ${configuration_file}
else
    echo "usage: `basename $0` <configuration_file>"
    exit 1
fi

# Load a common conda environment for E3SM pre and post processing tools
#source /global/project/projectdirs/acme/software/anaconda_envs/load_latest_e3sm_unified.sh
#conda activate e3sm-unified

# Append path to include TempestRemap path
tempest_path=${PWD}/tempestremap/bin
PATH=${tempest_path}:${PATH}

# Need to override hard-coded paths in NCO scripts
export NCO_PATH_OVERRIDE='No'

# Generate mapping files between atmosphere and ocean grids
datestring=`date +'%y%m%d'`
mapping_root=${output_root}/tempest_maps
mkdir -p ${mapping_root} && cd ${mapping_root}
ncremap -P mwf \
    -s ${ocn_scrip_file} -g ${atm_mesh_file} \
    --nm_src=${ocn_grid_name} --nm_dst=${atm_grid_name} \
    --dt_sng=${datestring}
