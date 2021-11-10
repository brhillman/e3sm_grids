#!/bin/bash

# create atm initial condition using HICCUP [WIP]
# this script will need to be cleaned up
source config.sh

# load conda environment with dependencies (note: may be able to get away with e3sm-unified??)
conda activate hiccup_env

# hiccup initial condition for specific date (assuming initial hindcast data was already grabbed)
# TODO: update this script with example using get_hindcast_data.ERA5.py
#       to grab ICs for a new date

vgrid=L72
init_date=2017-07-18    # yyyy-mm-dd format
vgrid_dir=${hiccup_root}/files_vert
vgrid_file=${vgrid_dir}/vert_coord_E3SM_L72.nc

cd ${hiccup_root}

python create_initial_condition_from_obs_ena.py --vgrid $vgrid --init_date $init_date \
       --vgrid_dir $vgrid_dir --vgrid_file $vgrid_file
