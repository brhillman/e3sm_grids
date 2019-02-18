#!/bin/bash

if [ $# -eq 1 ]; then
    configuration=$1
    source ${configuration}
else
    echo "usage: `basename $0` <configuration file>"
    exit 1
fi

# Set tempest path
tempest_dir=tempestremap

# Make sure directory exists
mkdir -p `dirname ${atm_mesh_file}`

# Generate exodus mesh file
${tempest_dir}/bin/GenerateCSMesh --alt --res ${atm_resolution} --file ${atm_mesh_file}
