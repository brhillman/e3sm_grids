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


# Parse optional arguments.  Tempest takes grid file.  E3SM takes scrip file.  
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

if [ "${method}" == "esmf" ]; then
    atm_grid_file=${atm_scrip_file}
else
    atm_grid_file=${atm_mesh_file}
fi



# Load a common conda environment for E3SM pre and post processing tools
source /global/project/projectdirs/acme/software/anaconda_envs/load_latest_e3sm_unified.sh


# Append path to include TempestRemap path
tempest_path=~bhillma/codes/e3sm/e3sm_grids/tempestremap/bin
PATH=${tempest_path}:${PATH}


# Update to Charlie Zender's latest builds on Cori
zender_path=~zender/bin_cori
PATH=${zender_path}:${PATH}


# Override hard-coded paths in NCO scripts
export NCO_PATH_OVERRIDE='No'



# Make mapping folder exists.  If not, make it!
if [ ! -d ${mapping_root} ]; then
   mkdir -p ${mapping_root} 
   mkdir -p ${mapping_root}
fi
cd ${mapping_root}


# Maps between atmosphere and ocean
if [ "${ocn_grid_name}" != "${atm_grid_name}" ]; then
    echo "Map ocean to atmosphere..."
    cd ${mapping_root}
    ncremap -P mwf \
        -s ${ocn_scrip_file} -g ${atm_grid_file} \
        --nm_src=${ocn_grid_name} --nm_dst=${atm_grid_name} \
        --dt_sng=${datestring}
fi

# Maps between atmosphere and land (for tri-grid)
if [ "${atm_grid_name}" != "${lnd_grid_name}" ]; then
    echo "Map land to atmosphere..."
    cd ${mapping_root}
    ncremap -P mwf \
        -s ${lnd_scrip_file} -g ${atm_grid_file} \
        --nm_src=${lnd_grid_name} --nm_dst=${atm_grid_name} \
        --dt_sng=${datestring}
fi

# Maps between ocean and land (for domain files if running tri-grid)
if [ "${atm_grid_name}" != "${lnd_grid_name}" ]; then
    echo "Map ocean to land..."
    cd ${mapping_root}
    ncremap -P mwf \
        -s ${ocn_scrip_file} -g ${lnd_scrip_file} \
        --nm_src=${ocn_grid_name} --nm_dst=${lnd_grid_name} \
        --dt_sng=${datestring} 
fi
