#!/bin/bash
source config.sh
#source_initial_condition="/sems-data-store/ACME/inputdata/atm/cam/inic/homme/cami_mam3_Linoz_0000-01-ne120np4_L72_c160318.nc"
#topo_source=${inputdata_root}/atm/cam/topo/USGS-gtopo30_ne120np4_32xdel2-PFC-consistentSGH.nc
#source_grid_name="ne120np4"
source_initial_condition="/sems-data-store/ACME/inputdata/atm/cam/inic/homme/cami_mam3_Linoz_ne30np4_L72_c160214.nc"
topo_source="/sems-data-store/ACME/inputdata/atm/cam/topo/USGS-gtopo30_ne30np4pg2_16xdel2.c20200108.nc"
#source_grid_file="/sems-data-store/ACME/mapping/grids/ne120np4_pentagons.100310.nc"
source_grid_name="ne30np4"
source_grid_file=${output_root}/ne30.g
# NOTE: initial conditions read in on DYNAMICS grids
date_string=`date +%Y%m%d`
target_initial_condition="${output_root}/cami_mam3_Linoz_0000-01-${dyn_grid_name}np4_L72_c${date_string}.nc"
target_grid_file="${output_root}/${dyn_grid_name}.g"
target_grid_name="${dyn_grid_name}"

# Create exodus file for source grid
if [ ! -e ${source_grid_file} ]; then
    ${tempest_root}/bin/GenerateCSMesh --alt --res 30 --file ${source_grid_file}
fi

# Generate overlap mesh
overlap_mesh=${output_root}/overlap_${source_grid_name}_to_${target_grid_name}.nc
if [ ! -e ${overlap_mesh} ]; then
    echo "Generate overlap mesh..."
    ${tempest_root}/bin/GenerateOverlapMesh --a ${source_grid_file} --b ${target_grid_file} --out ${overlap_mesh}
fi
# Generate maps
map_file=${output_root}/map_${source_grid_name}_to_${target_grid_name}_mono_${date_string}.nc
if [ ! -e ${map_file} ]; then
    echo "Generate mapping file.."
    ${tempest_root}/bin/GenerateOfflineMap \
        --in_mesh ${source_grid_file} --out_mesh ${target_grid_file} --ov_mesh ${overlap_mesh} \
        --in_type cgll --in_np 4 \
        --out_type cgll --out_np 4 \
        --mono --correct_areas \
        --out_map ${map_file}
fi
# Apply mapping weights to initial condition file
target_initial_condition_unadjusted="${output_root}/`basename ${target_initial_condition} .nc`_unadjusted.nc"
rm ${target_initial_condition_unadjusted}
if [ ! -e ${target_initial_condition_unadjusted} ]; then
    echo "Remap initial condition..."
    ncremap -m ${map_file} ${source_initial_condition} ${target_initial_condition_unadjusted}
fi

# Do surface adjustment for topography difference; note that HICCUP surface adjustment
# code wants PHIS to be present in the input initial condition file
topo_remapped=${output_root}/`basename ${topo_source} .nc`_remapped_to_${dyn_grid_name}np4.nc
topo_consistent=${output_root}/USGS-gtopo30_${atm_grid_name}_12xdel2_20210527.nc
rm ${topo_remapped}
if [ ! -e ${topo_remapped} ]; then
    echo "Remap topo..."
    ncremap -v PHIS_d -m ${map_file} ${topo_source} ${topo_remapped}
    ncrename -d ncol_d,ncol -v PHIS_d,PHIS ${topo_remapped}
    echo "Append PHIS from remapped topo to unadjusted IC..."
    ncks -A -v PHIS ${topo_remapped} ${target_initial_condition_unadjusted}
fi
echo "Adjust surface pressure..."
./adjust_surface.py ${target_initial_condition_unadjusted} ${topo_consistent} ${target_initial_condition}
echo "Done generating ${target_initial_condition}."
