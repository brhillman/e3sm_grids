#!/bin/bash

set -e

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


#-------------------------------------------------------------------------------
# Build domain tool
gen_domain=${e3sm_root}/cime/tools/mapping/gen_domain_files/gen_domain
cd `dirname ${gen_domain}`/src

# Setup environment (should work on any E3SM-supported machine)
eval $(${e3sm_root}/cime/CIME/Tools/get_case_env)
${e3sm_root}/cime/CIME/scripts/configure --macros-format Makefile --mpilib mpi-serial
source .env_mach_specific.sh

# Build gen_domain tool
#export USER_FFLAGS='-traceback -g -O0'
(. ./.env_mach_specific.sh ; gmake clean && OS=LINUX gmake)

#-------------------------------------------------------------------------------
# Generate domain files for ocean to atmos and ocean to land
if [ "${atm_grid_name}" != "${lnd_grid_name}" ]; then
    destination_grids=(${atm_grid_name} ${lnd_grid_name})
else
    destination_grids=(${atm_grid_name})
fi
mapping_root=${output_root}/mapping_files
for destination_grid in ${destination_grids[@]}; do
    echo "destination_grid = ${destination_grid}"

    # Find mapping files
    if [ "${method}" != "" ]; then
        if `ls ${mapping_root}/map_${ocn_grid_name}_to_${destination_grid}_${method}_*.nc &> /dev/null`; then
            map_ocn_to_lnd=`ls ${mapping_root}/map_${ocn_grid_name}_to_${destination_grid}_${method}_*.nc | tail -n1`
        else
            "No valid mapping files found for ${ocn_grid_name} to ${destination_grid}"
            exit 0
        fi
    else
        if `ls ${mapping_root}/map_${ocn_grid_name}_to_${destination_grid}_monotr_*nc &> /dev/null`; then
            map_ocn_to_lnd=`ls ${mapping_root}/map_${ocn_grid_name}_to_${destination_grid}_monotr_*.nc | tail -n1`
        elif `ls ${mapping_root}/map_${ocn_grid_name}_to_${destination_grid}_mono_*.nc &> /dev/null`; then
            map_ocn_to_lnd=`ls ${mapping_root}/map_${ocn_grid_name}_to_${destination_grid}_mono_*.nc | tail -n1`
        elif `ls ${mapping_root}/map_${ocn_grid_name}_to_${destination_grid}_aave_*.nc &> /dev/null`; then
            map_ocn_to_lnd=`ls ${mapping_root}/map_${ocn_grid_name}_to_${destination_grid}_aave_*.nc | tail -n1`
        elif `ls ${mapping_root}/map_${ocn_grid_name}_to_${destination_grid}_nco_*.nc &> /dev/null`; then
            map_ocn_to_lnd=`ls ${mapping_root}/map_${ocn_grid_name}_to_${destination_grid}_nco_*.nc | tail -n1`
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
