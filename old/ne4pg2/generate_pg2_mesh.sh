#!/bin/bash
# See:
# https://acme-climate.atlassian.net/wiki/spaces/ED/pages/1043235115/Special+Considerations+for+FV+Physics+Grids
source config.sh
${tempest_root}/bin/GenerateVolumetricMesh \
    --in ${output_root}/${dyn_grid_name}.g \
    --out ${output_root}/${atm_grid_name}.g \
    --np 2 --uniform
