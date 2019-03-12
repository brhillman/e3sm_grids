#!/bin/bash

# Parse arguments and load grid configuration
if [ $# -ge 1 ]; then
    configuration=$1
    source ${configuration}
else
    echo "usage: `basename $0` <grid configuration file>"
    exit 1
fi

# Set paths to code root
PreAndPostProcessingScripts="${HOME}/codes/e3sm/PreAndPostProcessingScripts/branches/add-grid-scripts"
dualgrid_root="${PreAndPostProcessingScripts}/regridding/spectral_elements_grid_utilities/compute_dualgrid"

# Make sure code exists; if not, we need to clone the git repo
if [ ! -d ${PreAndPostProcessingScripts} ]; then
    git clone git@github.com:ACME-Climate/PreAndPostProcessingScripts.git
${PreAndPostProcessingScripts}

    # For now, need a specific branch
    cd ${PreAndPostProcessingScripts} && checkout brhillman/add-grid-scripts
fi

# Load modules so that we can run the Matlab code:
module load matlab

# And now we can run the code using Matlab
# NOTE: may need to run this using salloc on batch systems
cd ${dualgrid_root}
./run_dualgrid.sh ne${atm_resolution} ${atm_mesh_file}

# Move the output to where we want it
mkdir -p ${output_root}/descriptor_files/
mv *_scrip.nc ${output_root}/descriptor_files/
mv *_latlon.nc ${output_root}/descriptor_files/
