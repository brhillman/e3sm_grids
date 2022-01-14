#!/bin/bash
dyn_grid_name=ne4
atm_grid_name=ne4pg2

tempest_root=${HOME}/codes/e3sm_grids/tempestremap
output_root=/sems-data-store/ACME/bhillma/grids/${atm_grid_name}
inputdata_root=/sems-data-store/ACME/inputdata
mapping_root=/sems-data-store/ACME/mapping
e3sm_root=${HOME}/codes/e3sm/branches/fix-mkmapdata #master

# Land grid and files
lnd_grid_name=${atm_grid_name}
#lnd_grid_file=${atm_grid_file}
#lnd_grid_name=r05
#lnd_grid_file=${inputdata_root}/lnd/clm2/mappingdata/grids/SCRIPgrid_0.5x0.5_nomask_c110308.nc
#lnd_grid_name=r0125
#lnd_grid_file=${inputdata_root}/lnd/clm2/mappingdata/grids/MOSART_global_8th.scrip.20180211c.nc #${atm_grid_file}
#lnd_grid_file=${inputdata_root}/lnd/clm2/mappingdata/grids/MOSART_global_8th.scrip.20180211c.nc #${atm_grid_file}

# Ocean grid and files
ocn_grid_name=oARRM60to10
ocn_grid_file=${inputdata_root}/ocn/mpas-o/oARRM60to10/ocean.ARRM60to10.scrip.200413.nc
