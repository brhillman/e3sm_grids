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
e3sm_root="${HOME}/codes/e3sm/branches/master"
datestring=`date +'%Y%m%d'`
topo_unsmoothed=${output_root}/topo/USGS-gtopo30_ne${atm_resolution}np4_unsmoothed.nc
topo_smoothed=USGS-gtopo30_ne${atm_resolution}np4pg2_smoothed_phis

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
	infilenames = '${topo_unsmoothed}', '${topo_smoothed}'
	/
EOF
cmd="srun --nodes=1 --ntasks=${ntasks} --constraint=cpu --qos=interactive --account=e3sm --time 00:30:00"
$cmd ${script_root}/tools/homme_tool/src/tool/homme_tool < input_topo.nl
echo "Done applying dycore smoothing."
