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
e3sm_root="${HOME}/codes/e3sm/branches/master"
datestring=`date +'%Y%m%d'`
cube_to_target_root=${e3sm_root}/components/cam/tools/topo_tool/cube_to_target
input_topography_file=${inputdata_root}/atm/cam/hrtopo/USGS-topo-cube3000.nc
output_topography_file=${output_root}/topo/USGS-gtopo30_${atm_grid_name}_16xdel2_consistentSGH_${datestring}.nc
smoothed_topography_file=${output_root}/topo/USGS-gtopo30_${atm_grid_name}_16xdel2.nc

# Get machine-specific modules
eval $( ${e3sm_root}/cime/CIME/Tools/get_case_env ) 
 
# Apply dycore-specific smoothing
ntasks=4
echo "Run homme_tool to apply smoothing"
cd ${output_root}/topo
smooth_phis_numcycle=6
cat > input_topo.nl <<-EOF
	&ctl_nl
	ne = ${atm_resolution}
	smooth_phis_p2filt = 0
	smooth_phis_numcycle = ${smooth_phis_numcycle}
	smooth_phis_nudt = 4e-16
	hypervis_scaling = 2
	se_ftype = 2
	/
	&vert_nl
	/
	&analysis_nl
	tool = 'topo_pgn_to_smoothed'
	infilenames = '${output_root}/topo/USGS-gtopo30_ne${atm_resolution}np4_unsmoothed.nc', 'ne${atm_resolution}np4pg2_smoothed_phis'
	/
EOF
srun --nodes=1 --ntasks=${ntasks} ${output_root}/homme_tool/src/tool/homme_tool < input_topo.nl

# run cube_to_target again to compute SGH and SGH30
echo "Run cube_to_target to interpolate topography..."
datestr=`date '+%Y%m%d'`
smoothed_topography_file=${output_root}/topo/ne${atm_resolution}np4pg2_smoothed_phis1.nc
unsmoothed_topography_file=${output_root}/topo/USGS-gtopo30_ne${atm_resolution}np4_unsmoothed.nc
output_topography_file=${output_root}/topo/USGS-gtopo30_ne${atm_resolution}np4pg2_x${smooth_phis_numcycle}t_${datestr}.nc
mkdir -p `dirname ${output_topography_file}`
${cube_to_target_root}/cube_to_target \
    --target-grid ${output_root}/grids/ne${atm_resolution}pg2_scrip.nc \
    --smoothed-topography ${smoothed_topography_file} \
    --input-topography ${unsmoothed_topography_file} \
    --output-topography ${output_topography_file}
echo "Done running cube_to_target."
