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
    exit 1
fi
atm_grid_name="ne${atm_resolution}"

# Parse optional arguments
mpirun=
while [ "$3" != "" ]; do
    case in $3
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

if [ ${atm_resolution} -lt 8 ]; then
    usgs_topography_file=${inputdata_root}/atm/cam/hrtopo/USGS-topo-cube512.nc
else
    usgs_topography_file=${inputdata_root}/atm/cam/hrtopo/USGS-topo-cube3000.nc
fi

# run cube_to_target again to compute SGH and SGH30
echo "Run cube_to_target to interpolate topography..."
smooth_phis_numcycle=6
datestr=`date '+%Y%m%d'`
smoothed_topography_file=${output_root}/${atm_grid_name}/topo/USGS-gtopo30_ne${atm_resolution}np4pg2_smoothed_phis1.nc
unsmoothed_topography_file=${output_root}/${atm_grid_name}/topo/USGS-gtopo30_ne${atm_resolution}np4_unsmoothed.nc
output_topography_file=${output_root}/${atm_grid_name}/topo/USGS-gtopo30_ne${atm_resolution}np4pg2_x${smooth_phis_numcycle}t_${datestr}.nc
mkdir -p `dirname ${output_topography_file}`
${mpirun} ${tools_root}/cube_to_target \
    --target-grid ${output_root}/${atm_grid_name}/grids/ne${atm_resolution}pg2_scrip.nc \
    --smoothed-topography ${smoothed_topography_file} \
    --input-topography ${usgs_topography_file} \
    --output-topography ${output_topography_file}
echo "Done running cube_to_target."

# Append GLL PHIS data
ncks -A ${smoothed_topography_file} ${output_topography_file}
