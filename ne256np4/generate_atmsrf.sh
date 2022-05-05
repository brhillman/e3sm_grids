#!/bin/bash
set -e

# Load config
source config.sh

# Build mkatmsrffile
cd ${e3sm_root}/components/eam/tools/mkatmsrffile || exit 1
eval $(${e3sm_root}/cime/CIME/Tools/get_case_env)
NETCDF_ROOT=${NETCDF_DIR} FC=ifort make

# Create a mapping file
map_file="map_1x1d_to_${atm_grid_name}_mono.nc"
if [ ! -e ${map_file} ]; then
    ncremap -a tempest \
        --src_grd=${mapping_root}/grids/1x1d.nc --dst_grd=${atm_grid_file} \
        -m ${map_file} \
        -W '--in_type fv --in_np 1 --out_type cgll --out_np 4 --mono --correct_areas --out_format Classic'
fi

echo ${mapping_root}/grids/1x1d.nc
echo ${inputdata_root}/atm/cam/chem/trop_mozart/dvel/regrid_vegetation.nc
echo ${inputdata_root}/atm/cam/chem/trop_mozart/dvel/clim_soilw.nc
echo ${map_file}

# Edit namelist
date=`date +%Y%m%d`
cat <<EOF > nml_atmsrf
&input
srfFileName = '${mapping_root}/grids/1x1d.nc'
landFileName = '${inputdata_root}/atm/cam/chem/trop_mozart/dvel/regrid_vegetation.nc'
soilwFileName = '${inputdata_root}/atm/cam/chem/trop_mozart/dvel/clim_soilw.nc'
atmFileName = '${atm_scrip_file}'
srf2atmFmapname = '${map_file}'
outputFileName = '${output_root}/atmsrf_${atm_grid_name}_${date}_n4.nc'
/
EOF

# Run the tool
mkatmsrffile=${e3sm_root}/components/eam/tools/mkatmsrffile/mkatmsrffile
${mkatmsrffile}

# Convert the file to cdf5 format:
if [ -e atmsrf_${atm_grid_name}_${date}_n4.nc ]; then
    ncks -5 atmsrf_${atm_grid_name}_${date}_n4.nc atmsrf_${atm_grid_name}_${date}.nc
fi

# Exit gracefully
exit 0
