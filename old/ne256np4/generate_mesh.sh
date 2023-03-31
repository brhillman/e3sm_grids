#!/bin/bash

source config.sh
mkdir -p ${output_root}
GenerateCSMesh --alt --res ${se_ne} --file ${output_root}/${dyn_grid_name}.g
