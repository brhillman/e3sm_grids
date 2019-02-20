#!/bin/bash

# Parse arguments
if [ $# -eq 1 ]; then
    configuration_file=$1
    source ${configuration_file}
else
    echo "usage: `basename $0` <configuration file>"
    exit 1
fi

# Build mksurfdata_map
e3sm_root=${HOME}/codes/e3sm/branches/master
${e3sm_root}/cime/tools/configure --macros-format=Makefile && source .env_mach_specific.sh

export LIB_NETCDF=$NETCDF_DIR/lib 
export INC_NETCDF=$NETCDF_DIR/include 
export USER_FC=ifort 
export USER_CC=icc 
cd $e3sm_root/components/clm/tools/clm4_5/mksurfdata_map/src/ 
# Change Makefile.common as nf-config is not installed in the usual location on Edison/Cori based on Gautam's email. 
# Should submit a PR to fix this 
# Manually change line 251 in Makefile.common to LDFLAGS := \$(shell \$(LIB_NETCDF)/../../../bin/nf-config --flibs) 
gmake clean && gmake

# Run code in debug mode
cd $e3sm_root/components/clm/tools/clm4_5/mksurfdata_map 
./mksurfdata.pl -res ne120np4 -y 2010 -d \
    -dinlc ${inputdata_root} \
    -usr_mapdir ${inputdata_root}/lnd/clm2/mappingdata/maps/ne120np4

# For upsupported, user-specified resolutions (need an example)

# Setup environment
#export PATH=${HOME}/software/miniconda3/bin:${PATH}
#source activate e3sm-unified

