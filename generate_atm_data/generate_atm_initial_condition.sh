#!/bin/bash

function print_usage () {
    echo "usage: `basename $0` <configuration file> [options]"
    echo "                                                                              "
    echo "Purpose: interpolate existing initial conditions to target grid               "
    echo "                                                                              "
    echo "Options (required):                                                           "
    echo "                                                                              "
    echo "    --source-inic-file  Full pathname to an existing initial condition        "
    echo "    --source-grid-file  Exodus-format grid file for source initial condition  "
    echo "    --source-grid-name  Name of grid for source initial condition (eg ne30np4)"
    echo "                                                                              "
    echo "Author: Ben Hillman (bhillma@sandia.gov)                                      "
}
 
# Parse arguments
if [ $# -ge 1 ]; then
    configuration_file=$1
    source ${configuration_file}
    shift
else
    print_usage
    exit 1
fi

# Parse named arguments
source_inic_file=${atm_source_inic_file}
source_grid_file=${atm_source_inic_grid_file}
source_grid_name=${atm_source_inic_grid_name}
method="tempest"
for arg in "$@"; do
    case $arg in
        --source-inic-file=*)
            source_inic_file="${arg#*=}"
            shift
            ;;
        --source-grid-file=*)
            source_grid_file="${arg#*=}"
            shift
            ;;
        --source-grid-name=*)
            source_grid_name="${arg#*=}"
            shift
            ;;
        --target-grid-file=*)
            atm_mesh_file="${arg#*=}"
            shift
            ;;
        --target-grid-name=*)
            atm_grid_name="${arg#*=}"
            shift
            ;;
        --vertical-coordinate-file=*)
            vertical_coordinate_file="${arg#*=}"
            shift
            ;;
        --method=*)
            method="${arg#*=}"
            shift
            ;;
        *)
            echo "Error parsing ${arg}. See usage."
            exit 1
            ;;
    esac
done

# Check arguments
if [ "${source_grid_file}" == "" ] || [ "${source_grid_name}" == "" ] || [ "${source_inic_file}" == "" ]; then
    print_usage
    exit 1
fi
 
# Add tempest to path
#module load python; source activate e3sm-unified
export LD_LIBRARY_PATH=~zender/lib_cori:${LD_LIBRARY_PATH}
export PATH=~zender/bin_cori:${PATH}
export NCO_PATH_OVERRIDE=yes

# Generate mapping weights
overlap_mesh=${output_root}/overlap_mesh_${source_grid_name}_to_${atm_grid_name}.nc
mapping_wgts=${output_root}/mapping_wgts_${source_grid_name}_to_${atm_grid_name}.nc
cd `dirname ${mapping_wgts}`
if [ "${method}" == "tempest" ]; then
    export PATH=${HOME}/bin:${PATH}
    if [ ! -e ${overlap_mesh} ]; then
        GenerateOverlapMesh \
            --a ${source_grid_file} --b ${atm_mesh_file} \
            --out ${overlap_mesh}
    fi
    GenerateOfflineMap \
        --in_mesh ${source_grid_file} --out_mesh ${atm_mesh_file} \
        --ov_mesh ${overlap_mesh} \
        --in_type fv --out_type cgll --out_np 4 \
        --out_map ${mapping_wgts}
elif [ "${method}" == "ESMF" ]; then
    ESMF_RegridWeightGen \
        --source ${source_grid_file} --destination ${atm_scrip_file} \
        --weight ${mapping_wgts} --method bilinear
else
    echo "Unrecognized mapping method."
    exit 1
fi
if [ $? -ne 0 ]; then
    echo "Weight gen failed, exiting."
    exit 1
fi
 
# Apply mapping weights
atm_initial_condition=${output_root}/initial_conditions/`basename ${source_inic_file} | sed "s/${source_grid_name}/${atm_grid_name}/"`
atm_initial_condition=`dirname ${atm_initial_condition}`/`basename ${atm_initial_condition} .nc`_remapped.nc
#ApplyOfflineMap \
#    --map mapping_weights.nc \
#    --in_data ${source_inic_file} \
#    --out_data ${atm_initial_condition}

mkdir -p `dirname ${atm_initial_condition}`
ncremap \
    -4 -m ${mapping_wgts} \
    ${source_inic_file} ${atm_initial_condition}

