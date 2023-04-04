#!/bin/bash

set -e

# Check input arguments
if [ $# -eq 1 ]; then
    source $1
else
    echo "usage: `basename $0` <machine config>"
    exit 1
fi

mkdir -p ${tools_root}

# build the code
eval $( ${e3sm_root}/cime/CIME/Tools/get_case_env )
cd ${e3sm_root}/components/eam/tools/topo_tool/cube_to_target
export FC=gfortran  INC_NETCDF=${NETCDF_DIR}/include LIB_NETCDF=${NETCDF_DIR}/lib
make
cp cube_to_target ${tools_root}/
echo "Done building cube_to_target."
