#!/bin/bash

function usage () {
    echo "usage: $0 <machine config> [--ntasks N]"
}

# Check command line arguments
if [ $# -ge 1 ]; then
    source $1
else
    usage
    exit 1
fi

# Parse optional arguments
ntasks=4  # Default number of mpi ranks to build tool for
while [ "$2" != "" ]; do
    case $2 in
        -n | --ntasks )
            shift
            ntasks=$2
            ;;
        *)
            usage
            exit 1
    esac
    shift
done

# Build homme_tool
echo "Building homme_tool for ${ntasks} ranks..."
eval $( ${e3sm_root}/cime/CIME/Tools/get_case_env ) #&& source .env_mach_specific.sh
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
