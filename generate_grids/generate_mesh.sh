#!/bin/bash

if [ $# -ge 2 ]; then
    source $1
    atm_resolution=$2
else
    echo "usage: `basename $0` <machine config> <resolution>"
    exit 1
fi
atm_grid_name="ne${atm_resolution}"

# Generate exodus mesh file
atm_mesh_file=${output_root}/${atm_grid_name}/grids/ne${atm_resolution}.g
mkdir -p `dirname ${atm_mesh_file}`
if [ -e ${atm_mesh_file} ]; then
    echo "${atm_mesh_file} exists; skipping."
    exit 0
else
    GenerateCSMesh --alt --res ${atm_resolution} --file ${atm_mesh_file}
fi
