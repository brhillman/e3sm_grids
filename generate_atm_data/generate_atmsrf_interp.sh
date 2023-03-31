#!/bin/bash

# Parse arguments to get configuration file
if [ $# -ge 1 ]; then
    source $1
else
    echo "usage: `basename $0` <configuration file> [options]"
    exit 1
fi

# Parse optional arguments
# TODO: add options to override default source data and grid
source_data=${inputdata_root}/atm/cam/chem/trop_mam/atmsrf_ne30np4_110920.nc
#source_grid=${mapdata_root}/grids/ne30np4_pentagons.091226.nc
source_grid=/project/projectdirs/acme/bhillma/grids/ne30np4/descriptor_files/ne30np4_pentagons_20190621.nc

# Define output file and destination
datestring=`date +'%Y%m%d'`
regridded_data=${output_root}/atmsrf/atmsrf_${atm_grid_name}_${datestring}.nc
mkdir -p `dirname ${regridded_data}`

# Regrid using Tempest
export PATH=${HOME}/bin:${PATH}
map_file=map_ne30np4_to_${atm_grid_name}.nc
GenerateOverlapMesh --a ${source_grid} --b ${atm_mesh_file} --out overlap_mesh.nc
GenerateOfflineMap \
    --in_mesh ${source_grid} --out_mesh ${atm_mesh_file} \
    --in_type fv --out_type cgll \
    --ov_mesh overlap_mesh.nc \
    --out_map ${map_file}
ApplyOfflineMap \
    --map ${map_file} \
    --in_data ${source_data} \
    --out_data ${regridded_data}

# Clean up
rm overlap_mesh.nc ${map_file}
