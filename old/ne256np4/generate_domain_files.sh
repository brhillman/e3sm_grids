#!/bin/bash
set -e

source config.sh

# Path to gen_domain tool
gen_domain=${e3sm_root}/cime/tools/mapping/gen_domain_files/gen_domain

# Configure and build
cd `dirname ${gen_domain}`/src
eval $(${e3sm_root}/cime/CIME/Tools/get_case_env)
${e3sm_root}/cime/CIME/scripts/configure --macros-format Makefile --mpilib mpi-serial
gmake

# Run gen_domain from output directory
cd ${output_root}

# Find conservative mapping files, use latest file generated
map_ocn_to_target=`ls ${output_root}/map_${ocn_grid_name}_to_${atm_grid_name}_mono.*.nc | tail -n1`

# Run gen_domain
${gen_domain} -m ${map_ocn_to_target} -o ${ocn_grid_name} -l ${atm_grid_name}
