#!/bin/bash
#SBATCH -N 1
#SBATCH --time=04:00:00
#SBATCH --job-name=gen_topo
#SBATCH --qos=regular
#SBATCH -C knl


# Reference:
# https://acme-climate.atlassian.net/wiki/spaces/ED/pages/2719776825/V2+Topography+GLL+PG2+grids
source config.sh

script_root=${PWD}
source $script_root/.env_mach_specific.sh

# homme_executable info
homme_root=${e3sm_root}/components/homme
homme_build=/global/cscratch1/sd/crjones/homme
homme_exe=${homme_build}/src/tool/homme_tool

# First pass of cube_to_target
topo_unsmoothed=${output_root}/${dyn_grid_name}pg4_topo.nc
cd ${output_root}
if [ ! -e ${topo_unsmoothed} ]; then
    echo "Run cube_to_target (first pass)"
    ${e3sm_root}/components/eam/tools/topo_tool/cube_to_target/cube_to_target \
        --target-grid ${output_root}/${dyn_grid_name}pg4_scrip.nc \
        --input-topography ${inputdata_root}/atm/cam/hrtopo/USGS-topo-cube3000.nc \
        --output-topography ${topo_unsmoothed}
fi

# Run homme_tool
topo_smoothed=${output_root}/${dyn_grid_name}pg2_smoothed_phis1.nc
cd ${output_root}
cat > homme_tool_input.nl <<EOF
&ctl_nl
ne = 0
mesh_file = '${output_root}/${dyn_grid_name}.g'
smooth_phis_numcycle = 12
smooth_phis_nudt = 4e-16
hypervis_scaling = 2
hypervis_order = 2
se_ftype = 2
/
&vert_nl
/
&analysis_nl
tool = 'topo_pgn_to_smoothed'
infilenames = '${topo_unsmoothed}', '`dirname ${topo_smoothed}`/`basename ${topo_smoothed} 1.nc`'
/
EOF

if [ ! -e ${topo_smoothed} ]; then
    echo "Running homme_tool"
    srun -n 4 ${homme_exe} < homme_tool_input.nl
fi

# Second pass of cube_to_target
topo_consistent=${output_root}/USGS-gtopo30_${atm_grid_name}_12xdel2.nc
if [ ! -e ${topo_consistent} ]; then
    echo "Run cube_to_target again..."
    ${e3sm_root}/components/eam/tools/topo_tool/cube_to_target/cube_to_target \
        --target-grid ${output_root}/${dyn_grid_name}pg2_scrip.nc \
        --input-topography ${inputdata_root}/atm/cam/hrtopo/USGS-topo-cube3000.nc \
        --smoothed-topography ${topo_smoothed} \
        --output-topography ${topo_consistent}
    ncks -A ${topo_smoothed} ${topo_consistent}
fi
