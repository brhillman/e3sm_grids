#!/bin/bash

set -e

function usage () {
    echo "usage: $0 <machine config file> <resolution> [options]"
}

# Get positional arguments
if [ $# -ge 2 ]; then
    source $1
    atm_resolution=$2
else
    usage
    exit 1
fi

# Get optional arguments
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
    esac
    shift
done
atm_grid_name=ne${atm_resolution}
mkdir -p ${output_root}/${atm_grid_name}/grids
cd ${output_root}/${atm_grid_name}/grids

# Run homme_tool
eval $( ${e3sm_root}/cime/CIME/Tools/get_case_env ) #&& source .env_mach_specific.sh
cat > input.nl <<EOF
&ctl_nl
ne = ${atm_resolution}
mesh_file = "none"
/
&vert_nl
/
&analysis_nl
tool = 'grid_template_tool'
output_dir = "./"
output_timeunits=1
output_frequency=1
output_varnames1='area','corners','cv_lat','cv_lon'
output_type='netcdf'
!output_type='netcdf4p'  ! needed for ne1024
io_stride = 16
/
EOF
${mpirun} ${tools_root}/homme_tool/src/tool/homme_tool < input.nl

# make the 'scrip' file for target GLL grid
ncks -O -v lat,lon,area,cv_lat,cv_lon ne${atm_resolution}np4_tmp1.nc ne${atm_resolution}np4_tmp.nc
ncl ${e3sm_root}/components/homme/test/tool/ncl/HOMME2SCRIP.ncl  name=\"ne${atm_resolution}np4\"  ne=${atm_resolution}  np=4
