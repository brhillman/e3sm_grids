#!/bin/bash

set -e

# Check input arguments
if [ $# -eq 1 ]; then
    source $1
else
    echo "usage: `basename $0` <configuration file>"
    exit 1
fi

tools_root=$PWD/tools
mkdir -p ${tools_root}

# build the code
eval $( ${e3sm_root}/cime/CIME/Tools/get_case_env )
cd ${e3sm_root}/components/eam/tools/topo_tool/bin_to_cube
export FC=gfortran  INC_NETCDF=${NETCDF_DIR}/include LIB_NETCDF=${NETCDF_DIR}/lib
make
cp bin_to_cube ${tools_root}/
echo "Done building bin_to_cube."
