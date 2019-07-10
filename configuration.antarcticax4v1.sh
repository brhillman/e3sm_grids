#!/bin/bash

# Specify user handle
user=eroesler

inputdata_root=/project/projectdirs/acme/inputdata
mapdata_root=/project/projectdirs/acme/mapping


# Atmos files and descriptive names that may be present
# antarcticax4v1
atm_resolution=ne0
atm_grid_name=antarcticax4v1


# Set output directory to atm grid name
output_root=/project/projectdirs/acme/${user}/grids/${atm_grid_name}


# Scrip and g file
atm_mesh_file=${output_root}/antarcticax4v1.g
atm_scrip_file=${output_root}/antarcticax4v1np4b_scrip.nc


# High resolution region names for mapping later
source_mesh_file=ne120.g
source_mesh_file_atm_resolution=120


# Make sure directories exist.  If not, make it!
if [ ! -d ${output_root} ]; then
   mkdir -p ${output_root}
fi


# Ocean files
ocn_grid_name=oRRS15to5
ocn_scrip_file="/project/projectdirs/acme/inputdata/ocn/mpas-o/oRRS15to5/ocean.RRS.15-5km_scrip_151209.nc"


# Land files
lnd_grid_name=360x720cru
lnd_scrip_file=${inputdata_root}/lnd/clm2/mappingdata/grids/SCRIPgrid_360x720_nomask_c120830.nc


# Define grid name
grid_name=${atm_grid_name}_${lnd_grid_name}_${ocn_grid_name}

