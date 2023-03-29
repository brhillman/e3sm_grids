#!/bin/bash

set -e

if [ $# -eq 1 ]; then
    source $1
else
    echo "usage: $0 <config file>"
    exit 1
fi

# Build homme_tool
${e3sm_root}/cime/CIME/scripts/configure && source .env_mach_specific.sh
eval $( ${e3sm_root}/cime/CIME/Tools/get_case_env ) #&& source .env_mach_specific.sh

ntasks=4
homme_tool_root=${e3sm_root}/components/homme/test/tool
mkdir -p ${output_root}/grids
cd ${output_root}/grids
#cd ${homme_tool_root}
cmake \
    -C ${homme_tool_root}/../../cmake/machineFiles/perlmutter-nocuda-gnu.cmake \
    -DBUILD_HOMME_WITHOUT_PIOLIBRARY=OFF \
    -DPREQX_PLEV=26 \
    -DUSE_NUM_PROCS=${ntasks} \
    ${homme_tool_root}/../../
make -j4 homme_tool

# Run homme_tool
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
srun --nodes=1 --ntasks=${ntasks} ./src/tool/homme_tool < input.nl

# make the 'scrip' file for target GLL grid
ncks -O -v lat,lon,area,cv_lat,cv_lon ne${atm_resolution}np4_tmp1.nc ne${atm_resolution}np4_tmp.nc
ncl ${e3sm_root}/components/homme/test/tool/ncl/HOMME2SCRIP.ncl  name=\"ne${atm_resolution}np4\"  ne=${atm_resolution}  np=4
