#!/bin/bash

set -e

# Check input arguments
if [ $# -eq 1 ]; then
    source $1
else
    echo "usage: `basename $0` <configuration file>"
    exit 1
fi

# Set paths
script_root=${PWD}

if [ ${atm_resolution} -lt 8 ]; then
    usgs_topography_file=${output_root}/topo/USGS-topo-cube512.nc
else
    usgs_topography_file=${inputdata_root}/atm/cam/hrtopo/USGS-topo-cube3000.nc
fi

# run cube_to_target again to compute SGH and SGH30
echo "Run cube_to_target to interpolate topography..."
datestr=`date '+%Y%m%d'`
smoothed_topography_file=${output_root}/topo/USGS-gtopo30_ne${atm_resolution}np4pg2_smoothed_phis1.nc
unsmoothed_topography_file=${output_root}/topo/USGS-gtopo30_ne${atm_resolution}np4_unsmoothed.nc
smooth_phis_numcycle=6
output_topography_file=${output_root}/topo/USGS-gtopo30_ne${atm_resolution}np4pg2_x${smooth_phis_numcycle}t_${datestr}.nc
mkdir -p `dirname ${output_topography_file}`
${script_root}/tools/cube_to_target \
    --target-grid ${output_root}/grids/ne${atm_resolution}pg2_scrip.nc \
    --smoothed-topography ${smoothed_topography_file} \
    --input-topography ${usgs_topography_file} \
    --output-topography ${output_topography_file}
echo "Done running cube_to_target."

# Append GLL PHIS data
ncks -A ${smoothed_topography_file} ${output_topography_file}
