#!/bin/bash
source config.sh

# Homme tool 
script_root=${PWD}
homme_root=${e3sm_root}/components/homme
homme_build=/global/cscratch1/sd/crjones/homme
homme_exe=${homme_build}/src/tool/homme_tool

# to do: create scripts to build homme_tool and cube_to_target
# create .env_mach_specific.sh if it doesn't already exist (needed for building homme_tool and/or cube_to_target
if [ ! -e ${script_root}/.env_mach_specific.sh ]; then
    ${e3sm_root}/cime/tools/configure --machine ${machine} --compiler ${compiler}
fi

# Generate intermediate high resolution physgrid mesh
cd ${output_root}
if [ ! -e ${output_root}/${dyn_grid_name}pg4.g ]; then
    GenerateVolumetricMesh \
        --in ${output_root}/${dyn_grid_name}.g \
        --out ${output_root}/${dyn_grid_name}pg4.g --np 4 --uniform
fi
if [ ! -e ${output_root}/${dyn_grid_name}pg4_scrip.nc ]; then
    ConvertExodusToSCRIP \
        --in ${output_root}/${dyn_grid_name}pg4.g \
        --out ${output_root}/${dyn_grid_name}pg4_scrip.nc
fi

# NOTE: cube_to_target and homme_tool need to be run on cori-knl compute nodes
do_generate_topo_files=FALSE
topo_unsmoothed=${output_root}/${dyn_grid_name}pg4_topo.nc
topo_smoothed=${output_root}/${dyn_grid_name}pg2_smoothed_phis1.nc
topo_consistent=${output_root}/USGS-gtopo30_${dyn_grid_name}_12xdel2.nc

if [ ! -e ${topo_unsmoothed} ]; then
    echo "Need to do first pass of cube_to_target"
    do_generate_topo_files=TRUE
fi
if [ ! -e ${topo_smoothed} ]; then
    echo "Need to run homme_tool"
    do_generate_topo_files=TRUE
fi
if [ ! -e ${topo_consistent} ]; then
    echo "Need to do second pass of cube_to_target"
    do_generate_topo_files=TRUE
fi

if [ "$do_generate_topo_files" == "TRUE" ]; then
    echo "submitting slurm_gen_topo.sh job"
    cd $script_root
    sbatch slurm_gen_topo.sh
fi
