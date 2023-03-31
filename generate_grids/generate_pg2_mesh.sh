#!/bin/bash
# See:
# https://acme-climate.atlassian.net/wiki/spaces/ED/pages/1043235115/Special+Considerations+for+FV+Physics+Grids

if [ $# -eq 1 ]; then
    configuration=$1
    source ${configuration}
else
    echo "usage: `basename $0` <configuration file>"
    exit 1
fi

in_mesh=${output_root}/grids/ne${atm_resolution}.g
out_mesh=${output_root}/grids/ne${atm_resolution}pg2.g
if [ -e ${out_mesh} ]; then
    echo "${out_mesh} exists; skipping."
    exit 0
else
    GenerateVolumetricMesh \
        --in ${in_mesh} \
        --out ${out_mesh} \
        --np 2 --uniform
fi
