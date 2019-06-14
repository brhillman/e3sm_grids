#!/bin/bash

if [ $# -ge 1 ]; then
    configuration=$1
    source ${configuration}
    shift
else
    echo "usage: `basename $0` <configuration file>"
    exit 1
fi

# Parse optional arguments
method=""
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


# Set paths to code root
e3sm_root="${HOME}/codes/e3sm/branches/master"

# Make sure code and directory exists; if not, clone the git repo and make the directory 
if [ ! -d ${e3sm_root} ]; then
    mkdir -p ${e3sm_root}
    git clone git@github.com:E3SM-Project/E3SM.git ${e3sm_root}

    # Change to directory. 
    cd ${e3sm_root} 
fi


#-------------------------------------------------------------------------------
# Build domain tool

# Setup environment
module load python; source activate e3sm-unified
e3sm_root=${HOME}/codes/e3sm/branches/master

# Build gen_domain tool
export USER_FFLAGS='-traceback -g -O0'
gen_domain=${e3sm_root}/cime/tools/mapping/gen_domain_files/gen_domain
cd `dirname ${gen_domain}`/src
../../../configure --macros-format Makefile --mpilib mpi-serial
(. ./.env_mach_specific.sh ; gmake clean && gmake)

#-------------------------------------------------------------------------------
# Generate domain files for ocean to atmos and ocean to land
if [ "${atm_grid_name}" != "${lnd_grid_name}" ]; then
    destination_grids=(${atm_grid_name} ${lnd_grid_name})
else
    destination_grids=(${atm_grid_name})
fi
mapping_root=${output_root}/mapping_files
for destination_grid in ${destination_grids[@]}; do

    # Find mapping files
    if [ "${method}" != "" ]; then
        if `ls ${mapping_root}/map_${ocn_grid_name}_to_${destination_grid}_${method}.*.nc &> /dev/null`; then
            map_ocn_to_lnd=`ls ${mapping_root}/map_${ocn_grid_name}_to_${destination_grid}_${method}.*.nc | tail -n1`
        else
            "No valid mapping files found for ${ocn_grid_name} to ${destination_grid}"
            exit 0
        fi
    else
        if `ls ${mapping_root}/map_${ocn_grid_name}_to_${destination_grid}_monotr.*nc &> /dev/null`; then
            map_ocn_to_lnd=`ls ${mapping_root}/map_${ocn_grid_name}_to_${destination_grid}_monotr.*.nc | tail -n1`
        elif `ls ${mapping_root}/map_${ocn_grid_name}_to_${destination_grid}_mono.*.nc &> /dev/null`; then
            map_ocn_to_lnd=`ls ${mapping_root}/map_${ocn_grid_name}_to_${destination_grid}_mono.*.nc | tail -n1`
        elif `ls ${mapping_root}/map_${ocn_grid_name}_to_${destination_grid}_aave.*.nc &> /dev/null`; then
            map_ocn_to_lnd=`ls ${mapping_root}/map_${ocn_grid_name}_to_${destination_grid}_aave.*.nc | tail -n1`
        else
            "No valid mapping files found for ${ocn_grid_name} to ${destination_grid}"
            exit 1
        fi
    fi

    # Generate domain files
    domain_root=${output_root}/domain_files
    mkdir -p ${domain_root} && cd ${domain_root}
    ${gen_domain} \
        -m ${map_ocn_to_lnd} \
        -o ${ocn_grid_name} \
        -l ${destination_grid} \
        --fminval 0.001 --fmaxval 1.0
    if [ $? -ne 0 ]; then
        echo "gen_domain failed"
        exit 1
    fi

done
