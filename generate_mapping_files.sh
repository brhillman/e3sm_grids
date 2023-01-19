#!/bin/bash

# Parse command line arguments
if [ $# -ge 1 ]; then
    configuration_file=$1
    source ${configuration_file}
    shift
else
    echo "usage: `basename $0` <configuration_file> [--method={method name}]"
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
#source /global/project/projectdirs/acme/software/anaconda_envs/load_latest_e3sm_unified.sh
module load python
source activate e3sm-unified

# Append path to include TempestRemap path
tempest_path=${PWD}/tempestremap/bin
PATH=${tempest_path}:${PATH}

# Need to override hard-coded paths in NCO scripts
#export NCO_PATH_OVERRIDE='No'

# Generate mapping files between all grids
datestring=`date +'%y%m%d'`

if [ "${method}" == "esmf" ] || [ "${method}" == "nco" ]; then
    atm_grid_file=${output_root}/${atm_grid_name}_scrip.nc #${atm_scrip_file}
else
    atm_grid_file=${output_root}/${dyn_grid_name}.g
fi
echo "Using atmosphere grid file ${atm_grid_file}"
mapping_root=${output_root}/mapping_files
mkdir -p ${mapping_root} && cd ${mapping_root}

# Map atm to ocn
map_file=${mapping_root}/map_${atm_grid_name}_to_${ocn_grid_name}_${method}_${datestring}.nc
if [ ! -e ${map_file} ]; then
    cd ${mapping_root}
    ncremap -s ${atm_grid_file} -g ${ocn_grid_file} -m ${map_file} -a ${method}
fi
# Map ocn to atm
map_file=${mapping_root}/map_${ocn_grid_name}_to_${atm_grid_name}_${method}_${datestring}.nc
if [ ! -e ${map_file} ]; then
    cd ${mapping_root}
    ncremap -s ${ocn_grid_file} -g ${atm_grid_file} -m ${map_file} -a ${method}
fi
echo "Done."

# Maps between atmosphere and ocean
#if [ "${ocn_grid_name}" != "${atm_grid_name}" ]; then
#    echo "Map ocean to atmosphere..."
#    cd ${mapping_root}
#    ncremap -P mwf \
#        -s ${ocn_scrip_file} -g ${atm_grid_file} \
#        --nm_src=${ocn_grid_name} --nm_dst=${atm_grid_name} \
#        --dt_sng=${datestring}
#fi

## Maps between atmosphere and land (for tri-grid)
#if [ "${atm_grid_name}" != "${lnd_grid_name}" ]; then
#    echo "Map land to atmosphere..."
#    cd ${mapping_root}
#    ncremap -P mwf \
#        -s ${lnd_scrip_file} -g ${atm_grid_file} \
#        --nm_src=${lnd_grid_name} --nm_dst=${atm_grid_name} \
#        --dt_sng=${datestring}
#fi
#
## Maps between ocean and land (for domain files if running tri-grid)
#if [ "${atm_grid_name}" != "${lnd_grid_name}" ]; then
#    echo "Map ocean to land..."
#    cd ${mapping_root}
#    ncremap -P mwf \
#        -s ${ocn_scrip_file} -g ${lnd_scrip_file} \
#        --nm_src=${ocn_grid_name} --nm_dst=${lnd_grid_name} \
#        --dt_sng=${datestring} 
#fi
