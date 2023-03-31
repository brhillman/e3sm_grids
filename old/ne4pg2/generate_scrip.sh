#!/bin/bash
source config.sh
${tempest_root}/bin/ConvertExodusToSCRIP --in ${output_root}/${atm_grid_name}.g --out ${output_root}/${atm_grid_name}_scrip.nc
