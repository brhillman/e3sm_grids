#!/bin/bash
atm_resolution=120
atm_grid_name=ne${atm_resolution}pg2
dyn_grid_name=ne${atm_resolution}
ocn_grid_name=ICOS10
ocn_grid_file="${inputdata_root}/ocn/mpas-o/ICOS10/ocean.ICOS10.scrip.211015.nc"
#ocn_scrip_file="${inputdata_root}/ocn/mpas-o/oRRS18to6v3/oRRS18to6v3.171116.nc"
lnd_grid_name=${atm_grid_name}
