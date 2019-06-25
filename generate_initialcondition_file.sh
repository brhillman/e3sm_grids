#!/bin/bash


# Parse command line arguments
if [ $# -ge 1 ]; then
    configuration_file=$1
    source ${configuration_file}
    shift
else
    echo "usage: `basename $0` <configuration_file>"
    exit 1
fi

# Load a common conda environment for E3SM pre and post processing tools
source /global/project/projectdirs/acme/software/anaconda_envs/load_latest_e3sm_unified.sh

# Build and add tempest to path
tempest_path=~bhillma/codes/e3sm/e3sm_grids/tempestremap/bin
PATH=${tempest_path}:${PATH}


# Add Charlie Zender's latest NCO tool builds on Cori to path
zender_path=~zender/bin_cori
PATH=${zender_path}:${PATH}


# Need to override hard-coded paths in NCO scripts
export NCO_PATH_OVERRIDE='No'


# Generate mapping files between all grids
datestring=`date +'%y%m%d'`

# Change directory to output_root
cd ${output_root}

# Generate source mesh file and resolution
rm -f ${source_mesh_file}
GenerateCSMesh --alt --res ${source_mesh_file_atm_resolution} --file ${source_mesh_file}

  
# Generate overlap mesh
GenerateOverlapMesh --a ${source_mesh_file} --b ${atm_mesh_file} --out overlap_mesh.nc

  
# Generate mapping weights
GenerateOfflineMap \
    --in_mesh ${source_mesh_file} --out_mesh ${atm_mesh_file} --ov_mesh overlap_mesh.nc \
    --in_np 4 --out_np 4 --in_type cgll --out_type cgll --out_map mapping_weights.nc

 
# Apply mapping weights
source_initial_condition="${inputdata_root}/atm/cam/inic/homme/cami_mam3_Linoz_0000-01-ne120np4_L72_c160318.nc"
atm_initial_condition="${output_root}/initial_conditions/cami_0000-01_${atm_grid_name}${atm_resolution}_L72_c${datestring}.nc"
mkdir -p `dirname ${atm_initial_condition}`
ncremap \
    -4 -m mapping_weights.nc \
    ${source_initial_condition} ${atm_initial_condition}
