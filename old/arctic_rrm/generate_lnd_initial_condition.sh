#!/bin/bash

# Interpolate existing inital condition to target grid

source config.sh

# First, build initial condition interpolator
rm env_mach_specific.xml
${e3sm_root}/cime/tools/configure --machine ${machine} || exit 1
source .env_mach_specific.sh || exit 1
cd ${e3sm_root}/components/elm/tools/clm4_5/interpinic/src
USER_FC=${fortran_compiler} LIB_NETCDF="`nc-config --libdir`" INC_NETCDF="`nf-config --includedir`" make VERBOSE=2

# Next, run using a well-spun-up initial condition
source_inic_file=/global/cscratch1/sd/bhillma/e3sm/cases/v2rc3.piControl.ne30pg2_EC30to60E2r2/archive/rest/1001-01-01-00000/20210528.v2rc3c.piControl.ne30pg2_EC30to60E2r2.chrysalis.elm.r.1001-01-01-00000.nc
target_inic_file=~/codes/e3sm/cases/add-arcticx4v1-rrm.arcticx4v1pg2_oARRM60to10.ICRUELM.spinup1/run/add-arcticx4v1-rrm.arcticx4v1pg2_oARRM60to10.ICRUELM.spinup1.elm.r.0091-01-01-00000.nc
output_inic_file=${output_root}/${lnd_grid_name}.elm.r.1001-01-01-00000.nc
cp ${target_inic_file} ${output_inic_file}
cd ${e3sm_root}/components/elm/tools/clm4_5/interpinic
./interpinic -i ${source_inic_file} -o ${output_inic_file}
