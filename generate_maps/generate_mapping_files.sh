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

# Generate mapping files between all grids
datestring=`date +'%y%m%d'`

if [ "${method}" == "aave" ] || [ "${method}" == "bilin" ] || [ "${method}" == "nco" ]; then
    atm_grid_file=${output_root}/grids/${atm_grid_name}_scrip.nc #${atm_scrip_file}
else
    atm_grid_file=${output_root}/grids/${dyn_grid_name}.g
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
