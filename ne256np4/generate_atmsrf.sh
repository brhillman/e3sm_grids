#!/bin/bash

set -e

# Load config
source config.sh

# Set full name for physics grid
physics_grid=${atm_grid_name}

# Build mkatmsrffile
cd ${e3sm_root}/components/eam/tools/mkatmsrffile || exit 1
eval $(${e3sm_root}/cime/CIME/Tools/get_case_env)
${e3sm_root}/cime/CIME/scripts/configure --macros-format=Makefile || exit 1
source .env_mach_specific.sh || exit 1
NETCDF_ROOT=${NETCDFROOT} FC=gfortran make

# Create a mapping file
mkdir -p ${output_root}/atmsrf && cd ${output_root}/atmsrf
if [ ! -e ${output_root}/atmsrf/map_1x1_to_${physics_grid}_mono.nc ]; then
    ncremap -a tempest \
        --src_grd=${mapping_root}/grids/1x1d.nc --dst_grd=${atm_grid_file} \
        -m ${output_root}/map_1x1_to_${physics_grid}_mono.nc \
        -W '--in_type fv --in_np 1 --out_type cgll --out_np 4 --out_format Offset64Bits'
    #ncremap -a bilin \
    #    --src_grd=${mapping_root}/grids/1x1d.nc --dst_grd=${atm_scrip_file} \
    #    -m ${output_root}/map_1x1_to_${physics_grid}_bilin
fi

echo ${mapping_root}/grids/1x1d.nc
echo ${inputdata_root}/atm/cam/chem/trop_mozart/dvel/regrid_vegetation.nc
echo ${inputdata_root}/atm/cam/chem/trop_mozart/dvel/clim_soilw.nc
echo ${output_root}/map_1x1_to_${physics_grid}_mono.nc

# Edit namelist
date=`date +%Y%m%d`
cat <<EOF > nml_atmsrf
&input
srfFileName = '${mapping_root}/grids/1x1d.nc'
landFileName = '${inputdata_root}/atm/cam/chem/trop_mozart/dvel/regrid_vegetation.nc'
soilwFileName = '${inputdata_root}/atm/cam/chem/trop_mozart/dvel/clim_soilw.nc'
atmFileName = '${atm_scrip_file}'
srf2atmFmapname = '${output_root}/map_1x1_to_${physics_grid}_mono.nc'
outputFileName = '${output_root}/atmsrf_${physics_grid}_${date}_n4.nc'
/
EOF

# Run the tool
mkatmsrffile=${e3sm_root}/components/eam/tools/mkatmsrffile/mkatmsrffile
${mkatmsrffile}

# Convert the file format:
if [ -e atmsrf_${physics_grid}_${date}_n4.nc ]; then
    ncks -5 atmsrf_${physics_grid}_${date}_n4.nc atmsrf_${physics_grid}_${date}.nc
fi

# Exit gracefully
exit 0
