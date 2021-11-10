#!/bin/bash
source config.sh   # config file

# Step 1: Use SQuadgen to generate the atm dynamics grid
dyn_grid_file=${output_root}/${dyn_grid_name}.g
$squadgen_root/SQuadGen --refine_level 5 --resolution 32 --refine_file ~/rrm/ref_spec_ena.png --output $dyn_grid_file

# Step 2A: Generate pg2 atm_grid_name:
atm_grid_file=${output_root}/${atm_grid_name}.g
$tempest_root/bin/GenerateVolumetricMesh --in $dyn_grid_file --out $atm_grid_file --np 2 --uniform

# Generate SCRIP file
$tempest_root/bin/ConvertExodusToSCRIP --in $atm_grid_file --out ${output_root}/${atm_grid_name}_scrip.nc

# Note to self: add notebook or script to validate this step completed correctly and the grid looks good
