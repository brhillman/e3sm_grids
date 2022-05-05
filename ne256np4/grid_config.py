#!/usr/bin/env python3
atm_grid_name = 'ne256np4'
dyn_grid_name = 'ne256'
ocn_grid_name = 'oRRS18to6v3'
lnd_grid_name = atm_grid_name
se_ne = 256
#tempest_root=${HOME}/codes/e3sm_grids/tempestremap
output_root=f'/global/cscratch1/sd/bhillma/e3sm/grids/{atm_grid_name}' #/sems-data-store/ACME/bhillma/grids/${atm_grid_name}
inputdata_root='/global/cfs/cdirs/e3sm/inputdata' #/sems-data-store/ACME/inputdata
e3sm_root='/global/homes/b/bhillma/codes/e3sm/branches/master' #${HOME}/codes/e3sm/branches/fix-mkmapdata

# Machine and compiler will be used in some of the scripts to get proper environment
machine="cori-knl"
fortran_compiler="ifort"

# Need an environment with at least nco and ncl; can create this with conda like:
# > conda create --name ncl -c conda-forge nco ncl
#module load python
#source activate ncl
