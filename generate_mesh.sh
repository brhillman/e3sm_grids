#!/bin/bash

if [ $# -eq 1 ]; then
    configuration=$1
    source ${configuration}
else
    echo "usage: `basename $0` <configuration file>"
    exit 1
fi

# Generate exodus mesh file
atm_mesh_file=${output_root}/grids/ne${atm_resolution}.g
mkdir -p `dirname ${atm_mesh_file}`
if [ -e ${atm_mesh_file} ]; then
    echo "${atm_mesh_file} exists; skipping."
    exit 0
else
    GenerateCSMesh --alt --res ${atm_resolution} --file ${atm_mesh_file}
fi
