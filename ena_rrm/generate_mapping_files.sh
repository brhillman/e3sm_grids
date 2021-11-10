#!/bin/bash
# ###################################################################################################
# This script generates mapping files give atm, ocn, and lnd grids (step 3 in the general reference)
# General reference: https://acme-climate.atlassian.net/wiki/spaces/ED/pages/872579110/Adding+support+for+new+grids+-+internal#3.-Generate-mapping-files
#
# Script lightly modified from e3sm_grids/arctic_rrm/generate_mapping_files.sh authored by Ben Hillman
#
# ###################################################################################################

# Set paths
source config.sh
# conda activate hiccup_env

# echo $PATH
# nco_exe=`which ncks`

# echo `which ncremap`
# echo `which ncks`

# if [ -z "${nco_exe}" ]; then
#     echo "Couldn't find nco for some reason"
#     export PATH="/global/homes/c/crjones/.conda/envs/hiccup_env/bin:$PATH"
# fi

atm_grid_file=${output_root}/${atm_grid_name}.g
atm_scrip_file=${output_root}/${atm_grid_name}_scrip.nc
# Note: ocean and lnd scrip files specified in config.sh

# Set date for output file names
date=`date +'%Y%m%d'`

# #######################################
# Generate conservative, monotone maps
#   (ocn <-> atm, lnd <-> atm)
# #######################################
alg_name=mono
function map_conserve {
    if [ ! -e ${map} ]; then
        echo "map: ${map}"
        ncremap \
            -a tempest --src_grd=${src_grid} --dst_grd=${dst_grid} -m ${map} \
            -W '--in_type fv --in_np 1 --out_type fv --out_np 1 --out_format Classic --correct_areas' \
            ${extra}
    fi
}

# ocn to atm
src_grid=${ocn_scrip_file}
dst_grid=${atm_grid_file}
extra=""
map=${output_root}/map_${ocn_grid_name}_to_${atm_grid_name}_${alg_name}.${date}.nc
# map_conserve

# atm to ocn
src_grid=${atm_grid_file}
dst_grid=${ocn_scrip_file}
extra="--a2o"
map=${output_root}/map_${atm_grid_name}_to_${ocn_grid_name}_${alg_name}.${date}.nc
# map_conserve

# lnd to atm 
src_grid=${lnd_scrip_file}
dst_grid=${atm_grid_file}
extra=""
map=${output_root}/map_${lnd_grid_name}_to_${atm_grid_name}_${alg_name}.${date}.nc
# if [ "${lnd_grid_name}" != "${atm_grid_name}" ]; then
    # map_conserve
# fi

# atm to lnd
src_grid=${atm_grid_file}
dst_grid=${lnd_scrip_file}
extra=""
map=${output_root}/map_${atm_grid_name}_to_${lnd_grid_name}_${alg_name}.${date}.nc
# if [ "${lnd_grid_name}" != "${atm_grid_name}" ]; then
    # map_conserve
# fi

# ocn to lnd (for domain files)
src_grid=${ocn_scrip_file}
dst_grid=${lnd_scrip_file}
extra=""
map=${output_root}/map_${ocn_grid_name}_to_${lnd_grid_name}_${alg_name}.${date}.nc
# map_conserve


# ##############################################
# Generate nonconservative, monotone maps.
#   (atm->lnd, atm->ocn)
# ##############################################
alg_name=bilin
function map_noconserve {
    if [ ! -e ${map} ]; then
        echo "map: ${map}"
        ncremap -a bilinear -s ${src_grid} -g ${dst_grid} -m ${map} -W '--extrap_method nearestidavg'
    fi
}
src_grid=$atm_scrip_file
dst_grid=$lnd_scrip_file
map="${output_root}/map_${atm_grid_name}_to_${lnd_grid_name}_${alg_name}.${date}.nc"
if [ "${atm_grid_name}" != "${lnd_grid_name}" ]; then
    map_noconserve
fi

src_grid=$atm_scrip_file
dst_grid=$ocn_scrip_file
map="${output_root}/map_${atm_grid_name}_to_${ocn_grid_name}_${alg_name}.${date}.nc"
map_noconserve

# ##############################################
# NCO maps for domain files
#   (ocn -> lnd; not sure what this is used for)
# ##############################################
alg_name=nco
function map_nco {
    if [ ! -e ${map} ]; then
        echo "map: ${map}"
        cmd="ncremap -a nco -s ${src_grid} -g ${dst_grid} -m ${map}"
        echo "${cmd}" && ${cmd}
    fi
}
src_grid=${ocn_scrip_file}
dst_grid=${lnd_scrip_file}
map="${output_root}/map_${ocn_grid_name}_to_${lnd_grid_name}_${alg_name}.${date}.nc"
# map_nco

# ##############################################
# Area-average maps for domain files
#   (ocn -> lnd; not sure what this is used for)
# ##############################################
alg_name=aave
function map_aave {
    if [ ! -e ${map} ]; then
        echo "map: ${map}"
        cmd="ncremap -a aave -s ${src_grid} -g ${dst_grid} -m ${map}"
        echo "${cmd}" && ${cmd}
    fi
}
src_grid=${ocn_scrip_file}
dst_grid=${lnd_scrip_file}
map="${output_root}/map_${ocn_grid_name}_to_${lnd_grid_name}_${alg_name}.${date}.nc"
map_aave
