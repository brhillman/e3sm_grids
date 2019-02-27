#!/bin/bash

# Parse arguments
if [ $# -ge 1 ]; then
    configuration_file=$1
    source ${configuration_file}
    shift
else
    echo "usage: `basename $0` <configuration file> [options]"
    exit 1
fi

# Parse optional arguments
ntasks=1
debug=""
for arg in "$@"; do
    case $arg in
        --ntasks=*)
            ntasks="${arg#*=}"
            shift
            ;;
        --debug)
            debug="--debug"
            ;;
        *)
            echo "Error parsing ${arg}. See usage."
            exit 1
            ;;
    esac
done

# Setup environment
module load python
source activate e3sm-unified

# Run the script FROM SCRATCH SPACE!!!!
mkdir -p ${output_root}/landsurf_maps && cd ${output_root}/landsurf_maps
e3sm_root=${HOME}/codes/e3sm/branches/update-mkmapdata
mkmapdata=${e3sm_root}/components/clm/tools/shared/mkmapdata/mkmapdata.sh
${mkmapdata} \
    --gridfile ${atm_scrip_file} --res ${atm_grid_name} \
    --inputdata-path ${inputdata_root} \
    --mpiexec "srun" \
    --output-filetype netcdf4 ${debug} --verbose --batch
