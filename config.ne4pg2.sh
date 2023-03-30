#!/bin/bash

grid_name=ne4
output_root=/global/cfs/cdirs/e3sm/bhillma/grids/${grid_name}
e3sm_root=${HOME}/codes/e3sm/branches/master

#inputdata_root=/projects/ccsm/inputdata
#mapdata_root=/projects/ccsm/mapping
inputdata_root=/global/cfs/cdirs/e3sm/inputdata
mapdata_root=/global/cfs/cdirs/e3sm/mapping

atm_grid_name=ne4np4
atm_resolution=4
atm_mesh_file=${output_root}/descriptor_files/ne${atm_resolution}.g
atm_scrip_file=${mapdata_root}/grids/ne4np4-pentagons_c100308.nc
atm_latlon_file=${mapdata_root}/grids/ne4np4_latlon_c100308.nc

#ocn_grid_name=oRRS15to5
#ocn_scrip_file="/project/projectdirs/acme/inputdata/ocn/mpas-o/oRRS15to5/ocean.RRS.15-5km_scrip_151209.nc"
#ocn_grid_name=oRRS18to6v3
#ocn_scrip_file="${inputdata_root}/ocn/mpas-o/oRRS18to6v3/oRRS18to6v3.171116.nc"
ocn_grid_name=oRRS30to10
ocn_scrip_file="${inputdata_root}/ocn/mpas-o/oRRS30to10/ocean.RRS.30-10km_scrip_150722.nc"
