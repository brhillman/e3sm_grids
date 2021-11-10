#!/bin/bash

# project details
project=m3525

# RRM grid details to specify
dyn_grid_name=enax32v1
atm_grid_name=${dyn_grid_name}pg2
ocn_grid_name=oRRS18to6v3
lnd_grid_name=r0125

# directory structures to specify
tempest_root=${HOME}/git_repos/tempestremap
squadgen_root=${HOME}/git_repos/SQuadgen
output_root=${CSCRATCH}/e3sm/grids/${atm_grid_name}
inputdata_root=/global/cfs/cdirs/e3sm/inputdata
e3sm_root=${HOME}/git_repos/E3SM
hiccup_root=${HOME}/git_repos/HICCUP

# homme_tool

# input scrip grid files needed for mapping (step 3)
ocn_grid_file=${inputdata_root}/ocn/mpas-o/oRRS18to6v3/ocean.oRRS18to6v3.scrip.181106.nc
lnd_grid_file=${inputdata_root}/lnd/clm2/mappingdata/grids/MOSART_global_8th.scrip.20180211c.nc
ocn_scrip_file=${ocn_grid_file}
lnd_scrip_file=${lnd_grid_file}

# create directories if necessary
mkdir -p $output_root

# Machine and compiler will be used in some of the scripts to get proper environment
machine="cori-knl"
fortran_compiler="ifort"
compiler="intel"

# Need an environment with at least nco and ncl; can create this with conda like:
# > conda create --name ncl -c conda-forge nco ncl
# module load python
# conda activate hiccup_env
# use e3sm_unified unless that fails :)
source /global/common/software/e3sm/anaconda_envs/load_latest_e3sm_unified_cori-knl.sh
