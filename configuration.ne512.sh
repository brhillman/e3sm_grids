#!/bin/bash

grid_name=ne512
output_root=${HOME}/e3sm/grids/${grid_name}

inputdata_root=/projects/ccsm/inputdata
mapdata_root=/projects/ccsm/mapping

atm_grid_name=ne512
atm_resolution=512
atm_mesh_file=${output_root}/descriptor_files/${atm_grid_name}.g
atm_scrip_file=${mapdata_root}/grids/ne512np4_scrip_c20190125.nc
atm_latlon_file=${mapdata_root}/grids/ne512np4_latlon_c20190125.nc

#ocn_grid_name=oRRS15to5
#ocn_scrip_file="/project/projectdirs/acme/inputdata/ocn/mpas-o/oRRS15to5/ocean.RRS.15-5km_scrip_151209.nc"
ocn_grid_name=oRRS18to6v3
ocn_scrip_file="${inputdata_root}/ocn/mpas-o/oRRS18to6v3/oRRS18to6v3.171116.nc"
#ocn_grid_name=oRRS30to10
#ocn_scrip_file="/project/projectdirs/acme/inputdata/ocn/mpas-o/oRRS30to10/ocean.RRS.30-10km_scrip_150722.nc"
