#!/bin/bash

set -e

# Check input arguments
if [ $# -eq 1 ]; then
    configuration_file=$1
else
    echo "usage: `basename $0` <configuration file>"
    exit 1
fi

tools_root=$PWD/tools
mkdir -p ${tools_root}

# Source configuration that was read from command line arguments
source ${configuration_file}
 
# Set paths
e3sm_root="${HOME}/codes/e3sm/branches/master"
datestring=`date +'%Y%m%d'`
cube_to_target_root=${e3sm_root}/components/eam/tools/topo_tool/cube_to_target
input_topography_file=${inputdata_root}/atm/cam/hrtopo/USGS-topo-cube3000.nc
output_topography_file=${output_root}/topo/USGS_ne${atm_resolution}np4_unsmoothed.nc
 
# Get machine-specific modules
${e3sm_root}/cime/CIME/scripts/configure && source .env_mach_specific.sh
 
# build the code
cd ${cube_to_target_root}
export FC=gfortran  INC_NETCDF=${NETCDF_DIR}/include LIB_NETCDF=${NETCDF_DIR}/lib
make
cp cube_to_target ${tools_root}/
echo "Done building cube_to_target."
 
# run the code
atm_scrip_file=${output_root}/grids/ne2np4_scrip.nc
echo "Run cube_to_target to interpolate topography..."
mkdir -p `dirname ${output_topography_file}` && cd `dirname ${output_topography_file}`
${tools_root}/cube_to_target \
    --target-grid ${output_root}/grids/ne${atm_resolution}np4_scrip.nc \
    --input-topography ${input_topography_file} \
    --output-topography ${output_topography_file}
echo "Done running cube_to_target."
