#!/bin/bash

inputdata_root=/project/projectdirs/acme/inputdata
mapdata_root=/project/projectdirs/acme/mapping

atm_resolution=512
atm_grid_name=ne${atm_resolution}np4

# Set output directory to atm grid name
output_root=/project/projectdirs/acme/bhillma/grids/${atm_grid_name}

# Additional atmos files that may be present
#atm_scrip_file=${mapdata_root}/grids/ne16np4_110512_pentagons.nc
#atm_latlon_file=${mapdata_root}/grids/ne16np4_latlon.nc
#atm_scrip_file=${mapdata_root}/grids/ne4np4-pentagons_c100308.nc
#atm_latlon_file=${mapdata_root}/grids/ne4np4_latlon_c100308.nc
#atm_source_inic_file=${inputdata_root}/atm/cam/inic/homme/cami_mam3_Linoz_0000-01-ne120np4_L72_c160318.nc
#atm_source_inic_grid_file=${mapdata_root}/grids/ne120np4_pentagons.100310.nc
#atm_source_inic_grid_name="ne120np4"
atm_source_inic_file=${inputdata_root}/atm/cam/inic/homme/cami_mam4_Linoz_0001-01-ne240np4_L72_c170910.nc
atm_source_inic_grid_file=${mapdata_root}/grids/ne240np4_091227_pentagons.nc
atm_source_inic_grid_name="ne240np4"

# Ocean files
ocn_grid_name=oRRS15to5
ocn_scrip_file="/project/projectdirs/acme/inputdata/ocn/mpas-o/oRRS15to5/ocean.RRS.15-5km_scrip_151209.nc"
#ocn_grid_name=oRRS18to6v3
#ocn_scrip_file="${inputdata_root}/ocn/mpas-o/oRRS18to6v3/oRRS18to6v3.171116.nc"
#ocn_grid_name=oRRS30to10
#ocn_scrip_file="/project/projectdirs/acme/inputdata/ocn/mpas-o/oRRS30to10/ocean.RRS.30-10km_scrip_150722.nc"
#ocn_grid_name=oQU240
#ocn_scrip_file=/project/projectdirs/acme/inputdata/ocn/mpas-o/oQU240/ocean.QU.240km.scrip.181106.nc

# Land files
#lnd_grid_name=ne120np4
#lnd_scrip_file=${mapdata_root}/grids/ne120np4_pentagons.100310.nc
#lnd_scrip_file=${mapdata_root}/grids/ne240np4_091227_pentagons.nc
#lnd_scrip_file=${mapdata_root}/grids/ne30np4_pentagons.091226.nc
lnd_grid_name=360x720cru
lnd_scrip_file=${inputdata_root}/lnd/clm2/mappingdata/grids/SCRIPgrid_360x720_nomask_c120830.nc
#lnd_grid_name=fv1.9x2.5
#lnd_scrip_file="${mapdata_root}/grids/fv1.9x2.5_090205.nc"
grid_name=${atm_grid_name}_${lnd_grid_name}_${ocn_grid_name}
atm_mesh_file=${output_root}/descriptor_files/ne${atm_resolution}.g
