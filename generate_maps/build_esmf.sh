#!/bin/bash

# ESMF version to build
ESMF_VERSION=8_0_0

# Source environment settings used when building/running E3SM
MACHINE=cori-knl
rm -f env_mach_specific.xml
${HOME}/codes/e3sm/branches/master/cime/tools/configure --machine=${MACHINE} || exit 1
source .env_mach_specific.sh || exit 1

# Set paths needed to build ESMF
export ESMF_DIR=${HOME}/software/esmf_${ESMF_VERSION}
export ESMF_COMM=mpi
export ESMF_COMPILER=intel
export ESMF_INSTALL_PREFIX=/project/projectdirs/acme/software/esmf/esmf_${ESMF_VERSION}/${MACHINE}
export ESMF_NETCDF="nc-config"

# Build
cd ${ESMF_DIR}
gmake clean || exit 1
gmake || exit 1
gmake install || exit 1

# Exit gracefully
echo "Done building ESMF; installed to ${ESMF_INSTALL_PREFIX}."
exit 0
