#!/bin/bash

source config.sh

# Set paths
datestring=`date +'%y%m%d'`
cube_to_target_root=${e3sm_root}/components/eam/tools/topo_tool/cube_to_target
input_topography_file=${inputdata_root}/atm/cam/hrtopo/USGS-topo-cube3000.nc
output_topography_file=${output_root}/topo/USGS-gtopo30_${atm_grid_name}_unsmoothed_${datestring}.nc
 
# Make sure environment matches E3SM
eval $(${e3sm_root}/cime/CIME/Tools/get_case_env)
 
# build the code
cd ${cube_to_target_root}
export FC=ifort INC_NETCDF=${NETCDF_DIR}/include LIB_NETCDF=${NETCDF_DIR}/lib
make
echo "Done building cube_to_target."

# Command for submitting to batch system
job_cmd="srun -C knl --account e3sm --time 01:00:00 -K -c 1 -N 1 --ntasks 1 --partition regular"
 
# run the code
echo "Run cube_to_target to interpolate topography..."
mkdir -p `dirname ${output_topography_file}`
${job_cmd} ${cube_to_target_root}/cube_to_target \
    --target-grid ${atm_scrip_file} \
    --input-topography ${input_topography_file} \
    --output-topography ${output_topography_file}
echo "Done running cube_to_target."
