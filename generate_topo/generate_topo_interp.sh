#!/bin/bash

set -e

# Check input arguments
if [ $# -eq 1 ]; then
    configuration_file=$1
    source ${configuration_file}
else
    echo "usage: `basename $0` <configuration file>"
    exit 1
fi

tools_root=$PWD/tools
mkdir -p ${tools_root}

# Set paths
e3sm_root="${HOME}/codes/e3sm/branches/master"
datestring=`date +'%Y%m%d'`
if [ ${atm_resolution} -lt 8 ]; then
    ncube=512
    input_topography_file=${output_root}/topo/USGS-topo-cube${ncube}.nc
else
    input_topography_file=${inputdata_root}/atm/cam/hrtopo/USGS-topo-cube3000.nc
fi
output_topography_file=${output_root}/topo/USGS-gtopo30_ne${atm_resolution}np4_unsmoothed.nc
 
# Get machine-specific modules
eval $( ${e3sm_root}/cime/CIME/Tools/get_case_env )

# run the code
echo "Run cube_to_target to interpolate topography..."
mkdir -p `dirname ${output_topography_file}` && cd `dirname ${output_topography_file}`
logfile=`basename $0 .sh`.log
echo ${logfile}
rm -f ${logfile}
${tools_root}/cube_to_target \
    --target-grid ${output_root}/grids/ne${atm_resolution}np4_scrip.nc \
    --input-topography ${input_topography_file} \
    --output-topography ${output_topography_file} >> ${logfile}
echo "Done running cube_to_target."
