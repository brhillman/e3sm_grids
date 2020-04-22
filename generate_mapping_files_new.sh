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

# Parse optional arguments
method="tempest"
for arg in "$@"; do
    case $arg in
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

# Load a common conda environment for E3SM pre and post processing tools
#source .env_mach_specific.sh
export PATH=~bhillma/bin:${PATH}
export LD_LIBRARY_PATH=~bhillma/lib:${LD_LIBRARY_PATH}
#export PATH=~zender/bin_cori:${PATH}
#export LD_LIBRARY_PATH=~zender/lib_cori:${LD_LIBRARY_PATH}

# Generate mapping files between all grids
datestring=`date +'%y%m%d'`

if [ "${method}" == "esmf" ]; then
    atm_grid_file=${atm_scrip_file}
elif [ "${method}" == "nco_con" ]; then
    atm_grid_file=${atm_scrip_file}
else
    atm_grid_file=${atm_mesh_file}
fi
lnd_grid_file=${lnd_scrip_file}
ocn_grid_file=${ocn_scrip_file}

echo "Using atmosphere grid file ${atm_grid_file}"
mapping_root=${output_root}/mapping_files
mkdir -p ${mapping_root} && cd ${mapping_root}

# Maps between atmosphere and ocean
if [ "${ocn_grid_name}" != "${atm_grid_name}" ]; then
    echo "Map ocean to atmosphere..."
    cd ${mapping_root}
    #ncremap -P mwf \
    #    -6 -s ${ocn_scrip_file} -g ${atm_grid_file} \
    #    --nm_src=${ocn_grid_name} --nm_dst=${atm_grid_name} \
    #    --dt_sng=${datestring} --alg_typ=${method}
    overlap_ocn_to_atm=${mapping_root}/overlap_${ocn_grid_name}_to_${atm_grid_name}.nc
    if [ ! -e ${overlap_ocn_to_atm} ]; then
        echo "Generating `basename ${overlap_ocn_to_atm}`..."
        GenerateOverlapMesh \
            --a ${ocn_scrip_file} \
            --b ${atm_grid_file} \
            --out ${overlap_ocn_to_atm}
    fi
    map_ocn_to_atm=${mapping_root}/map_${ocn_grid_name}_to_${atm_grid_name}_mono_${datestring}.nc
    if [ ! -e ${map_ocn_to_atm} ]; then
        echo "Generating `basename ${map_ocn_to_atm}`..."
        GenerateOfflineMap \
            --in_mesh ${ocn_grid_file} --out_mesh ${atm_grid_file} \
            --ov_mesh ${overlap_ocn_to_atm} \
            --in_type fv --in_np 1 --out_type cgll --out_np 4 \
            --mono --volumetric --correct_areas \
            --out_map ${map_ocn_to_atm}
    fi
    map_atm_to_ocn=${mapping_root}/map_${atm_grid_name}_to_${ocn_grid_name}_mono_${datestring}.nc
    if [ ! -e ${map_atm_to_ocn} ]; then
        echo "Generating `basename ${map_atm_to_ocn}`..."
        GenerateOfflineMap \
            --in_mesh ${atm_grid_file} --out_mesh ${ocn_grid_file} \
            --ov_mesh ${overlap_ocn_to_atm} \
            --in_type cgll --in_np 4 --out_type fv \
            --mono --correct_areas \
            --out_map ${map_atm_to_ocn}
    fi
fi

if [ "${lnd_grid_name}" != "${atm_grid_name}" ]; then
    echo "Map land to atmosphere..."
    cd ${mapping_root}
    overlap_lnd_to_atm=${mapping_root}/overlap_${lnd_grid_name}_to_${atm_grid_name}.nc
    if [ ! -e ${overlap_lnd_to_atm} ]; then
        echo "Generating `basename ${overlap_lnd_to_atm}`..."
        GenerateOverlapMesh \
            --a ${lnd_scrip_file} \
            --b ${atm_grid_file} \
            --out ${overlap_lnd_to_atm}
    fi
    map_lnd_to_atm=${mapping_root}/map_${lnd_grid_name}_to_${atm_grid_name}_mono_${datestring}.nc
    if [ ! -e ${map_lnd_to_atm} ]; then
        echo "Generating `basename ${map_lnd_to_atm}`..."
        GenerateOfflineMap \
            --in_mesh ${lnd_grid_file} --out_mesh ${atm_grid_file} \
            --ov_mesh ${overlap_lnd_to_atm} \
            --in_type fv --in_np 1 --out_type cgll --out_np 4 \
            --mono --volumetric --correct_areas \
            --out_map ${map_lnd_to_atm}
    fi
    map_atm_to_lnd=${mapping_root}/map_${atm_grid_name}_to_${lnd_grid_name}_mono_${datestring}.nc
    if [ ! -e ${map_atm_to_lnd} ]; then
        echo "Generating `basename ${map_atm_to_lnd}`..."
        GenerateOfflineMap \
            --in_mesh ${atm_grid_file} --out_mesh ${lnd_grid_file} \
            --ov_mesh ${overlap_lnd_to_atm} \
            --in_type cgll --in_np 4 --out_type fv \
            --mono --correct_areas \
            --out_map ${map_atm_to_lnd}
    fi
fi

if [ "${lnd_grid_name}" != "${ocn_grid_name}" ]; then
    echo "Map land to ocnosphere..."
    cd ${mapping_root}
    overlap_ocn_to_lnd=${mapping_root}/overlap_to_${ocn_grid_name}_${lnd_grid_name}.nc
    if [ ! -e ${overlap_ocn_to_lnd} ]; then
        echo "Generating `basename ${overlap_ocn_to_lnd}`..."
        GenerateOverlapMesh \
            --a ${ocn_grid_file} \
            --b ${lnd_scrip_file} \
            --out ${overlap_ocn_to_lnd}
    fi
    map_lnd_to_ocn=${mapping_root}/map_${lnd_grid_name}_to_${ocn_grid_name}_mono_${datestring}.nc
    if [ ! -e ${map_lnd_to_ocn} ]; then
        echo "Generating `basename ${map_lnd_to_ocn}`..."
        GenerateOfflineMap \
            --in_mesh ${lnd_grid_file} --out_mesh ${ocn_grid_file} \
            --ov_mesh ${overlap_ocn_to_lnd} \
            --in_type fv --in_np 1 --out_type fv --out_np 1 \
            --correct_areas \
            --out_map ${map_lnd_to_ocn}
    fi
    map_ocn_to_lnd=${mapping_root}/map_${ocn_grid_name}_to_${lnd_grid_name}_mono_${datestring}.nc
    if [ ! -e ${map_ocn_to_lnd} ]; then
        echo "Generating `basename ${map_ocn_to_lnd}`..."
        GenerateOfflineMap \
            --in_mesh ${ocn_grid_file} --out_mesh ${lnd_grid_file} \
            --ov_mesh ${overlap_ocn_to_lnd} \
            --in_type fv --in_np 1 --out_type fv --out_np 1 \
            --correct_areas \
            --out_map ${map_ocn_to_lnd}
    fi
fi

