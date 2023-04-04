#!/bin/bash

set -e

function usage () {
    echo "usage: `basename $0` <machine config> <resolution> [-m|--mpirun CMD]"
}

# Check input arguments
if [ $# -ge 2 ]; then
    source $1
    atm_resolution=$2
else
    usage
    exit 1
fi
atm_grid_name="ne${atm_resolution}"

# Optional arguments
mpirun=
while [ "$3" != "" ]; do
    case $3 in
        -m | --mpirun)
            shift
            mpirun=$3
            ;;
        *)
            usage
            exit 1
    esac
    shift
done

# Set default paths
datestring=`date +'%Y%m%d'`
if [ ${atm_resolution} -lt 8 ]; then
    ncube=512
    input_topography_file=${inputdata_root}/atm/cam/hrtopo/USGS-topo-cube${ncube}.nc
else
    input_topography_file=${inputdata_root}/atm/cam/hrtopo/USGS-topo-cube3000.nc
fi
output_topography_file=${output_root}/${atm_grid_name}/topo/USGS-gtopo30_ne${atm_resolution}np4_unsmoothed.nc

# Allow overriding defaults with command line?
 
# Get machine-specific modules
eval $( ${e3sm_root}/cime/CIME/Tools/get_case_env )

# run the code
echo "Run cube_to_target to interpolate topography..."
mkdir -p `dirname ${output_topography_file}` && cd `dirname ${output_topography_file}`
${mpirun} ${tools_root}/cube_to_target \
    --target-grid ${output_root}/${atm_grid_name}/grids/ne${atm_resolution}np4_scrip.nc \
    --input-topography ${input_topography_file} \
    --output-topography ${output_topography_file}
echo "Done running cube_to_target."
