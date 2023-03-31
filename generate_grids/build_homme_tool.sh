#!/bin/bash

if [ $# -eq 1 ]; then
    source $1
else
    echo "usage: $0 <config>"
    exit 1
fi

tools_root=${PWD}/tools

# Build homme_tool
eval $( ${e3sm_root}/cime/CIME/Tools/get_case_env ) #&& source .env_mach_specific.sh
ntasks=4
homme_tool_root=${e3sm_root}/components/homme/test/tool
mkdir -p ${tools_root}/homme_tool
cd ${tools_root}/homme_tool
cmake \
    -C ${homme_tool_root}/../../cmake/machineFiles/perlmutter-nocuda-gnu.cmake \
    -DBUILD_HOMME_WITHOUT_PIOLIBRARY=OFF \
    -DPREQX_PLEV=26 \
    -DUSE_NUM_PROCS=${ntasks} \
    ${homme_tool_root}/../../
make -j4 homme_tool
