#!/bin/bash
set -e
if [ $# -eq 1 ]; then
    source $1
else
    echo "usage: `basename $0` <machine config>"
    exit 1
fi
eval $( ${e3sm_root}/cime/CIME/Tools/get_case_env )
