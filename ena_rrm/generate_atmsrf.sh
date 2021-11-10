#!/bin/bash

# Load config
source config.sh

# Set full name for physics grid
physics_grid=${atm_grid_name}

# assuming mkatmsrffile has already been built ...
cd ${e3sm_root}/components/eam/tools/mkatmsrffile || exit 1
# ../../../../cime/tools/configure --macros-format=Makefile || exit 1
# source .env_mach_specific.sh || exit 1
# NETCDF_ROOT=$NETCDF_DIR FC=ftn
# make

# Create a mapping file
if [ ! -e ${output_root}/map_1x1_to_${physics_grid}_mono.nc ]; then
    ncremap -a tempest \
        --src_grd=${mapping_root}/grids/1x1d.nc --dst_grd=${output_root}/${physics_grid}.g \
        -m ${output_root}/map_1x1_to_${physics_grid}_mono.nc \
        -W '--in_type fv --in_np 1 --out_type fv --out_np 1 --out_format Classic'
fi

# echo ${mapping_root}/grids/1x1d.nc
# echo ${inputdata_root}/atm/cam/chem/trop_mozart/dvel/regrid_vegetation.nc
# echo ${inputdata_root}/atm/cam/chem/trop_mozart/dvel/clim_soilw.nc
# echo ${output_root}/${physics_grid}_scrip.nc
# echo ${output_root}/map_1x1_to_${physics_grid}_mono.nc

# Edit nml_atmsrf namelist file
date=20211110
output_prefix=${output_root}/atmsrf_${physics_grid}_${date}
output_filename=${output_prefix}_n4.nc
cat <<EOF > nml_atmsrf
&input
srfFileName = '${mapping_root}/grids/1x1d.nc'
landFileName = '${inputdata_root}/atm/cam/chem/trop_mozart/dvel/regrid_vegetation.nc'
soilwFileName = '${inputdata_root}/atm/cam/chem/trop_mozart/dvel/clim_soilw.nc'
atmFileName = '${output_root}/${physics_grid}_scrip.nc'
srf2atmFmapname = '${output_root}/map_1x1_to_${physics_grid}_mono.nc'
outputFileName = '${output_filename}'
/
EOF

# Run the tool from compute node
if [ ! -e $output_filename ]; then
    echo "Generating ${output_filename} with mkatmsrffile"
    cd $script_dir
    sbatch -A ${project} slurm_gen_atmsrf.sh
fi

# Convert the file to netcdf3 format if necessary:
if [ ! -e ${output_prefix}.nc ]; then
    echo "Converting to netcdf3"
    ncks -3 $output_filename ${output_prefix}.nc
fi
