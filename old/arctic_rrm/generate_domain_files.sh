#!/bin/bash
source config.sh

# Path to gen_domain tool
gen_domain=${e3sm_root}/cime/tools/mapping/gen_domain_files/gen_domain

# Configure and build
cd `dirname ${gen_domain}`/src
../../../configure --macros-format Makefile --mpilib mpi-serial
source .env_mach_specific.sh
gmake
#(. ./.env_mach_specific.sh ; gmake)

# Run gen_domain from output directory
cd ${output_root}

# Find conservative mapping files, use latest file generated
map_ocn_to_target=`ls ${output_root}/map_${ocn_grid_name}_to_${atm_grid_name}_mono.*.nc | tail -n1`

# Run gen_domain
${gen_domain} -m ${map_ocn_to_target} -o ${ocn_grid_name} -l ${atm_grid_name}
