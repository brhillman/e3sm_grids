#!/bin/bash
# See:
# https://acme-climate.atlassian.net/wiki/spaces/ED/pages/1043235115/Special+Considerations+for+FV+Physics+Grids
source config.sh
GenerateVolumetricMesh \
    --in ${output_root}/${atm_grid_name}.g \
    --out ${output_root}/${atm_grid_name}pg2.g \
    --np 2 --uniform
