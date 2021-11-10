#!/bin/bash
#SBATCH -N 1
#SBATCH --time=00:30:00
#SBATCH --job-name=gen_atmsrf
#SBATCH --qos=debug
#SBATCH -C knl

source config.sh
source .env_mach_specific.sh

# Set full name for physics grid
physics_grid=${atm_grid_name}

# Build mkatmsrffile
cd ${e3sm_root}/components/eam/tools/mkatmsrffile || exit 1

# Run the tool from compute node
mkatmsrffile=${e3sm_root}/components/eam/tools/mkatmsrffile/mkatmsrffile
${mkatmsrffile}

# Convert the file to netcdf3 format:
# if [ -e atmsrf_${physics_grid}_${date}_n4.nc ]; then
#     ncks -3 atmsrf_${physics_grid}_${date}_n4.nc atmsrf_${physics_grid}_${date}.nc
# fi

# Exit gracefully
# exit 0
