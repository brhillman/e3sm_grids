#!/bin/bash

set -e

function usage () {
    echo "usage: `basename $0` <machine config> <grid config> [-m|--mpirun CMD]"
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

# Parse optional arguments
mpirun=
while [ "$3" != "" ]; do
    case $3 in
        -m | --mpirun )
            shift
            mpirun=$3
            ;;
        *)
            usage
            exit 1
            ;;
    esac
    shift
done

# Set paths
datestring=`date +'%Y%m%d'`
topo_unsmoothed=${output_root}/${atm_grid_name}/topo/USGS-gtopo30_ne${atm_resolution}np4_unsmoothed.nc
topo_smoothed=USGS-gtopo30_ne${atm_resolution}np4pg2_smoothed_phis

# Get machine-specific modules
eval $( ${e3sm_root}/cime/CIME/Tools/get_case_env )
 
# Apply dycore-specific smoothing
echo "Run homme_tool to apply smoothing"
cd ${output_root}/${atm_grid_name}/topo
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
$mpirun ${tools_root}/homme_tool/src/tool/homme_tool < input_topo.nl
echo "Done applying dycore smoothing."
