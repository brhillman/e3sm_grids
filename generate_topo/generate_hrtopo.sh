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

# Resolution for high-resolution binned topo
if [ ${atm_resolution} -lt 8 ]; then
    ncube=512
else
    ncube=3000
fi

# Set paths
datestring=`date +'%Y%m%d'`
input_topography_file=${inputdata_root}/atm/cam/gtopo30data/usgs-rawdata.nc
#output_topography_file=${inputdata_root}/atm/cam/hrtopo/USGS-topo-cube${ncube}.nc
output_topography_file=${output_root}/topo/USGS-topo-cube${ncube}.nc
 
# Get machine-specific modules
eval $( ${e3sm_root}/cime/CIME/Tools/get_case_env )

# run the code
echo "Run bin_to_cube to bin raw USGS data to cube-sphere grid..."
mkdir -p `dirname ${output_topography_file}` && cd `dirname ${output_topography_file}`
if [ ! -e ${output_topography_file} ]; then
    ${tools_root}/bin_to_cube \
        --inputfile ${input_topography_file} \
        --outputfile ${output_topography_file} \
        --ncube ${ncube}
else
    echo "${output_topography_file} exists, skipping."
    exit 0
fi
echo "Done running bin_to_cube."
