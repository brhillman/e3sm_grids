#!/bin/bash

# Check input arguments
if [ $# -eq 1 ]; then
    configuration_file=$1
else
    echo "usage: `basename $0` <configuration file>"
    exit 1
fi

# Source configuration that was read from command line arguments
source ${configuration_file}
 
# Set paths
e3sm_root="${HOME}/codes/e3sm/branches/master"
datestring=`date +'%y%m%d'`
cube_to_target_root=${e3sm_root}/components/cam/tools/topo_tool/cube_to_target
input_topography_file=${inputdata_root}/atm/cam/hrtopo/USGS-topo-cube3000.nc
output_topography_file=${output_root}/topo/USGS_${grid_name}_unsmoothed_${datestring}.nc
 
# Get machine-specific modules
${e3sm_root}/cime/tools/configure && source .env_mach_specific.sh
 
# build the code
cd ${cube_to_target_root}
export FC=ifort INC_NETCDF=${NETCDF_DIR}/include LIB_NETCDF=${NETCDF_DIR}/lib
make
echo "Done building cube_to_target."
 
# run the code
echo "Run cube_to_target to interpolate topography..."
mkdir -p `dirname ${output_topography_file}`
${cube_to_target_root}/cube_to_target \
    --target-grid ${atm_scrip_file} \
    --input-topography ${input_topography_file} \
    --output-topography ${output_topography_file}
echo "Done running cube_to_target."
