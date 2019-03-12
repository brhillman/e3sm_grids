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
e3sm_root=${HOME}/codes/e3sm/branches/update-mksurfdata #${HOME}/codes/e3sm/branches/fix-mksurfdatamap-build
${e3sm_root}/cime/tools/configure --macros-format=Makefile && source .env_mach_specific.sh
export LIB_NETCDF=$NETCDF_DIR/lib 
export INC_NETCDF=$NETCDF_DIR/include 
export USER_FC=ifort 
export USER_CC=icc 
cd $e3sm_root/components/clm/tools/clm4_5/mksurfdata_map/src/ 
gmake clean && gmake

# Find date string from most recent mapping files
mapping_file=`ls ${inputdata_root}/lnd/clm2/mappingdata/maps/${grid_name}/map_0.5x0.5_AVHRR_to_* | tail -n1`
datestring=`basename ${mapping_file} .nc | rev | cut -d_ -f1 | rev | sed 's/c//'`
echo ${datestring}

# Run code
cd $e3sm_root/components/clm/tools/clm4_5/mksurfdata_map 
./mksurfdata.pl -res usrspec \
    -usr_gname ne512np4 -usr_gdate ${datestring} -y 2000 \
    -dinlc ${inputdata_root} \
    -usr_mapdir ${inputdata_root}/lnd/clm2/mappingdata/maps/ne512np4

# For upsupported, user-specified resolutions (need an example)

# Setup environment
#export PATH=${HOME}/software/miniconda3/bin:${PATH}
#source activate e3sm-unified

