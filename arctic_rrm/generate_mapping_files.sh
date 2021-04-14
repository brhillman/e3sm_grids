#!/bin/bash

# Set paths
source config.sh
atm_grid_file=${output_root}/${atm_grid_name}pg2.g
ocn_grid_file=${inputdata_root}/ocn/mpas-o/oARRM60to10/ocean.ARRM60to10.scrip.200413.nc
lnd_grid_file=${atm_grid_file}

# Set date for output file names
date=`date +'%Y%m%d'`

# Generate overlap mesh
echo "Generate overlap mesh..."
overlap_mesh=${output_root}/overlap_${ocn_grid_name}_to_${atm_grid_name}.nc
if [ ! -e ${overlap_mesh} ]; then
    GenerateOverlapMesh --a ${ocn_grid_file} --b ${atm_grid_file} --out ${overlap_mesh}
fi

# Generate maps
echo "Generate atm -> ocn map.."
GenerateOfflineMap \
    --in_mesh ${atm_grid_file} --out_mesh ${ocn_grid_file} --ov_mesh ${overlap_mesh} \
    --in_type fv --in_np 1 --out_type fv --out_np 1 --correct_areas \
    --out_map ${output_root}/map_${atm_grid_name}_to_${ocn_grid_name}_mono.${date}.nc
echo "Generate ocn -> atm map.."
GenerateOfflineMap \
    --in_mesh ${ocn_grid_file} --out_mesh ${atm_grid_file} --ov_mesh ${overlap_mesh} \
    --in_type fv --in_np 1 --out_type fv --out_np 1 --correct_areas \
    --out_map ${output_root}/map_${ocn_grid_name}_to_${atm_grid_name}_mono.${date}.nc
