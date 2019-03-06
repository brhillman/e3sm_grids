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

# Setup environment; nco and ncl needed for scripts called from mkmapdata
source .env_mach_specific.sh
module load nco
module load ncl
ESMFBIN_PATH=/project/projectdirs/acme/software/esmf/cori-knl/bin/binO/Unicos.intel.64.mpi.default

# Run the script FROM SCRATCH SPACE!!!!
mkdir -p ${output_root}/landsurf_maps && cd ${output_root}/landsurf_maps
e3sm_root=${HOME}/codes/e3sm/branches/update-mkmapdata
mkmapdata=${e3sm_root}/components/clm/tools/shared/mkmapdata/mkmapdata.sh
mpiexec="srun --account=acme --partition=regular --constraint=knl --time=02:00:00 --ntasks=128 --nodes=128"
${mkmapdata} \
    --gridfile ${atm_scrip_file} --res ${atm_grid_name} \
    --inputdata-path ${inputdata_root} \
    --mpiexec "${mpiexec}" \
    --esmf-path ${ESMFBIN_PATH} \
    --output-filetype 64bit_offset \
    ${debug} --verbose --batch
