#!/bin/bash
# See:
# https://acme-climate.atlassian.net/wiki/spaces/ED/pages/1043235115/Special+Considerations+for+FV+Physics+Grids
grid_name=arcticx4v1
output_root=/sems-data-store/ACME/bhillma/grids/${grid_name}
tempest_root=${HOME}/codes/e3sm_grids/tempestremap/build
${tempest_root}/GenerateVolumetricMesh --in ${output_root}/${grid_name}.g --out ${output_root}/${grid_name}pg2.g --np 2 --uniform
