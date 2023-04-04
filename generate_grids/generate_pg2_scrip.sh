#!/bin/bash
# See:
# https://acme-climate.atlassian.net/wiki/spaces/ED/pages/1043235115/Special+Considerations+for+FV+Physics+Grids

if [ $# -eq 2 ]; then
    source $1
    atm_resolution=$2
else
    echo "usage: `basename $0` <machine config> <resolution>"
    exit 1
fi
atm_grid_name="ne${atm_resolution}"

# Convert input mesh to SCRIP format
datestring=`date +%Y%m%d`
in_mesh=${output_root}/${atm_grid_name}/grids/ne${atm_resolution}pg2.g
out_mesh=${output_root}/${atm_grid_name}/grids/ne${atm_resolution}pg2_scrip.nc
if [ -e ${out_mesh} ]; then
    echo "${out_mesh} exists; skipping."
    exit 0
else
    ConvertMeshToSCRIP --in ${in_mesh} --out ${out_mesh}
fi

# Make sure grid_imask has type int and convert to cdf5 format
ncap2 -5 -O -s "grid_imask = int(grid_imask)" ${out_mesh} ${out_mesh}
