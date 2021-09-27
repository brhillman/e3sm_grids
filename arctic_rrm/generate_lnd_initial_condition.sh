#!/bin/bash

# Interpolate existing inital condition to target grid

source config.sh

# First, build initial condition interpolator
${e3sm_root}/cime/tools/configure --machine ${machine} || exit 1
source .env_mach_specific.sh || exit 1
cd ${e3sm_root}/components/elm/tools/clm4_5/interpinic/src
USER_FC=${fortran_compiler} LIB_NETCDF="`nc-config --libdir`" INC_NETCDF="`nf-config --includedir`" make VERBOSE=1
