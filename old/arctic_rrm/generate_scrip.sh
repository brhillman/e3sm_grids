#!/bin/bash
source config.sh
${tempest_root}/bin/ConvertExodusToSCRIP --in ${output_root}/${grid_name}pg2.g --out ${output_root}/${grid_name}pg2_scrip.nc
