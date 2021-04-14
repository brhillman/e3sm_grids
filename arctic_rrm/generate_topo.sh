#!/bin/bash
source config.sh
machine=mappy
compiler=gnu

# Build homme tool
script_root=${PWD}
homme_root=${e3sm_root}/components/homme
homme_build=${script_root}/homme_build
homme_exe=${homme_build}/src/tool/homme_tool
if [ ! -e ${homme_exe} ]; then
    mkdir -p ${homme_build} && cd ${homme_build}
    ${e3sm_root}/cime/tools/configure --machine ${machine} --compiler ${compiler}
    source .env_mach_specific.sh
    cmake -C ${homme_root}/cmake/machineFiles/${machine}.cmake PREQX_PLEV=24 ${homme_root}
    make -j4 homme_tool
    if [ $? -ne 0 ]; then
        echo "homme_tool build failed."
        exit 1
    fi
fi

# Generate intermediate high resolution physgrid mesh
cd ${output_root}
if [ ! -e ${output_root}/${atm_grid_name}pg4.g ]; then
    GenerateVolumetricMesh \
        --in ${output_root}/${atm_grid_name}.g \
        --out ${output_root}/${atm_grid_name}pg4.g --np 4 --uniform
fi
if [ ! -e ${output_root}/${atm_grid_name}pg4_scrip.nc ]; then
    ConvertExodusToSCRIP \
        --in ${output_root}/${atm_grid_name}pg4.g \
        --out ${output_root}/${atm_grid_name}pg4_scrip.nc
fi

# Build cube_to_target
cd ${e3sm_root}/components/eam/tools/topo_tool/cube_to_target
${e3sm_root}/cime/tools/configure && source .env_mach_specific.sh
export FFLAGS="-ffree-line-length-none"
make || exit 1

# First pass of cube_to_target
topo_unsmoothed=${output_root}/${atm_grid_name}pg4_topo.nc
cd ${output_root}
if [ ! -e ${topo_unsmoothed} ]; then
    ${e3sm_root}/components/eam/tools/topo_tool/cube_to_target/cube_to_target \
        --target-grid ${output_root}/${atm_grid_name}pg4_scrip.nc \
        --input-topography ${inputdata_root}/atm/cam/hrtopo/USGS-topo-cube3000.nc \
        --output-topography ${topo_unsmoothed}
fi


# Run homme_tool
topo_smoothed=${output_root}/${atm_grid_name}pg2_smoothed_phis1.nc
cd ${output_root}
cat > homme_tool_input.nl <<EOF
&ctl_nl
ne = 0
mesh_file = '${output_root}/${atm_grid_name}.g'
smooth_phis_numcycle = 12
smooth_phis_nudt = 4e-16
hypervis_scaling = 0
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
    mpirun -np 8 ${homme_exe} < homme_tool_input.nl
fi

# Second pass of cube_to_target
echo "Run cube_to_target again..."
topo_consistent=${output_root}/USGS-gtopo30_${atm_grid_name}_12xdel2.nc
if [ ! -e ${topo_consistent} ]; then
    ${e3sm_root}/components/eam/tools/topo_tool/cube_to_target/cube_to_target \
        --target-grid ${output_root}/${atm_grid_name}pg2_scrip.nc \
        --input-topography ${inputdata_root}/atm/cam/hrtopo/USGS-topo-cube3000.nc \
        --smoothed-topography ${topo_smoothed} \
        --output-topography ${topo_consistent}
    ncks -A ${topo_smoothed} ${topo_consistent}
fi
