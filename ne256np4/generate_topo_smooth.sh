#!/bin/bash

set -e

source config.sh

input_topography_file=${inputdata_root}/atm/cam/hrtopo/USGS-topo-cube3000.nc
output_topography_file=${output_root}/topo/USGS-gtopo30_${atm_grid_name}_16xdel2_consistentSGH_${datestring}.nc
interpolated_topography_file=${output_root}/topo/USGS-gtopo30_${atm_grid_name}_unsmoothed.nc
smoothed_topography_file=${output_root}/topo/USGS-gtopo30_${atm_grid_name}_16xdel2.nc

# Make sure environment matches E3SM
eval $(${e3sm_root}/cime/CIME/Tools/get_case_env)

# Create a working directory for HOMME source code
mkdir -p ${output_root}/homme_bld && cd ${output_root}/homme_bld

# Run CMAKE
if [ ! -e src/tool/homme_tool ]; then
    cmake -C ${e3sm_root}/components/homme/cmake/machineFiles/${machine}.cmake \
            -DPREQX_PLEV=30 -DPREQX_NP=4 ${e3sm_root}/components/homme
    make clean && make -j4 homme_tool
fi

# Edit namelist
# Edit e3sm/components/homme/test/tool/namelist/template.nl and specify the grid
# resolution or RRM file
# 
# For ne512, this would be `set ne = 512`. For RRM grids, leave `ne = 0`, but will
# need to edit where the exodus grid file comes from
#
# for non-RRM grids using the older E3SM v1 dycore, add cubed_sphere_map=0 to template.nl

#
#  Generate smoothed topo
# 
TOOLDIR=${e3sm_root}/components/homme/test/tool
exe=src/tool/homme_tool

SLURM_NNODES=80
NTASKS_PER_NODE=21
echo $SLURM_NNODES
echo $NTASKS_PER_NODE
NTASKS=$(( ${SLURM_NNODES} * ${NTASKS_PER_NODE} ))
echo $NTASKS
NE=${se_ne}
NPTS=4   # be sure to rerun CMAKE if this is changed
mesh=ne${NE}np${NPTS}

if [ -z ${SLURM_NNODES} ]; then #${?SLURM_NNODES} ] then
   mpirun="mpirun -np 4"
else
   mpirun="srun -C knl --account e3sm --time 00:30:00 -K -c 1 -N $SLURM_NNODES --ntasks $NTASKS"
fi


# create namelist:
rm -f input.nl
cat > input.nl <<EOF
&ctl_nl
ne = ${NE}
mesh_file = 'none'
smooth_phis_numcycle = 16
!smooth_phis_nudt =  28e7 * ( 30/NE)**2
smooth_phis_nudt = `echo "print(28.e7 * (30. / ${NE}) ** 2.0)" | python3` 
hypervis_scaling = 0         ! 2 for RRM grids
/

&vert_nl
/

&analysis_nl
tool = 'topo_gll_to_smoothed'
infilenames = '${interpolated_topography_file}'
output_dir = "./"
output_timeunits=1
output_frequency=1
output_varnames1='PHIS'  ! homme will output goes. rename afterwards
output_type='netcdf'
io_stride = 16
/

EOF

# Batch submit
#job_cmd="salloc -I -C knl --account e3sm"
$mpirun $exe < input.nl
ncks -O -v PHIS,lat,lon phis-smoothed1.nc ${smoothed_topography_file}
