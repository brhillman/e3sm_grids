#!/bin/bash

set -e

source config.sh

# Make sure environment matches E3SM
eval $(${e3sm_root}/cime/scripts/Tools/get_case_env)

# Create a working directory for HOMME source code
mkdir -p ${output_root}/homme_bld && cd ${output_root}/homme_bld

# Run CMAKE
if [ ! -e src/tool/homme_tool ]; then
    cmake -C ${e3sm_root}/components/homme/cmake/machineFiles/${machine}.cmake \
            -DPREQX_PLEV=30 -DPREQX_NP=4 ${e3sm_root}/components/homme
    make -j4 homme_tool
fi

# Edit namelist
# Edit e3sm/components/homme/test/tool/namelist/template.nl and specify the grid
# resolution or RRM file
# 
# For ne512, this would be `set ne = 512`. For RRM grids, leave `ne = 0`, but will
# need to edit where the exodus grid file comes from
#
# for non-RRM grids using the older E3SM v1 dycore, add cubed_sphere_map=0 to template.nl
sed -i "s/ne = .*/ne = ${se_ne}/" $e3sm_root/components/homme/test/tool/namelists/template.nl

#
#  script to show how to run various HOMME tools
#  
#  Generate NP4 scrip and subcell files
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
mesh_file = "none"
/

&vert_nl
/

&analysis_nl
tool = 'grid_template_tool'

output_dir = "./" 
output_timeunits=1
output_frequency=1
output_varnames1='area','corners','cv_lat','cv_lon'
output_type='netcdf'
!output_type='netcdf4p'  ! needed for ne1024
io_stride = 16                                                                                                    
/

EOF

# Batch submit
#job_cmd="salloc -I -C knl --account e3sm"
$mpirun $exe < input.nl

# Load ncl for tool scripts
module load ncl

# make the 'latlon' file
ncks -O -v lat,lon,corners,area ${mesh}_tmp1.nc ${mesh}_tmp.nc
ncl $TOOLDIR/ncl/HOMME2META.ncl  name=\"$mesh\"  ne=$NE  np=$NPTS

# make the 'scrip' file
ncks -O -v lat,lon,area,cv_lat,cv_lon ${mesh}_tmp1.nc ${mesh}_tmp.nc
ncl $TOOLDIR/ncl/HOMME2SCRIP.ncl  name=\"$mesh\"  ne=$NE  np=$NPTS
rm -f {$mesh}_tmp.nc {$mesh}_tmp1.nc

# make some plots (ncl defaults to ne4np4 grid
#ncl $TOOLDIR/ncl/plotscrip.ncl
#ncl $TOOLDIR/ncl/plotlatlon.ncl
