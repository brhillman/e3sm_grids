#!/bin/bash
set -e
source config.sh

# Get list of input files
if [ "${lnd_grid_name}" == "${atm_grid_name}" ]; then
    #lnd_grid_file=${output_root}/${lnd_grid_name}_scrip.nc
    lnd_grid_file=${mapping_root}/grids/${lnd_grid_name}_scrip.nc
fi
cd ${e3sm_root}/components/elm/tools/mkmapdata
./mkmapdata.sh \
    --gridfile ${lnd_grid_file} \
    --inputdata-path ${inputdata_root} \
    --res ${lnd_grid_name} \
    --gridtype global \
    --output-filetype 64bit_offset \
    --debug -v --list || exit 1

# Make sure we have input files
e3sm_inputdata_repository="https://web.lcrc.anl.gov/public/e3sm"
cesm_inputdata_repository="https://svn-ccsm-inputdata.cgd.ucar.edu/trunk"
inputdata_list=elm.input_data_list
cat $inputdata_list | while read line; do
    localpath=`echo ${line} | sed 's:.* = \(.*\):\1:'`
    url1=${e3sm_inputdata_repository}/`echo ${line} | sed 's:.*\(inputdata/lnd/.*\):\1:'`
    url2=${cesm_inputdata_repository}/`echo ${line} | sed 's:.*\(inputdata/lnd/.*\):\1:'`
    if [ ! -f ${localpath} ]; then
        echo "${url1} -> ${localpath}"
        mkdir -p `dirname ${localpath}`
        cd `dirname ${localpath}`
        # Try to download using first URL, if that fails then use the second
        wget ${url1} || wget ${url2}
    else
        echo "${localpath} exists, skipping."
    fi
done

# Make maps
mkdir -p ${output_root}
cd ${output_root}
mkmapdata=${e3sm_root}/components/elm/tools/mkmapdata/mkmapdata.sh
#mpiexec="srun -A m1199 -t 02:00:00 -q regular -N 1 -C knl -n 1"
mpiexec="srun -A m1199 -t 02:00:00 -q interactive -N 1 -C cpu -n 1"
echo ${mkmapdata} \
    --gridfile ${lnd_grid_file} \
    --inputdata-path ${inputdata_root} \
    --res ${lnd_grid_name} \
    --gridtype global \
    --output-filetype 64bit_offset \
    --mpiexec "${mpiexec}" \
    -v || exit 1

# Build mksurfdata_map
cd ${e3sm_root}/components/elm/tools/mksurfdata_map/src || exit 1
${e3sm_root}/cime/CIME/scripts/configure --macros-format=Makefile --machine=${machine} --compiler=${compiler} || exit 1
source .env_mach_specific.sh || exit 1
#INC_NETCDF=${NETCDFROOT}/include \
#    LIB_NETCDF=${NETCDFROOT}/lib USER_FC=${fortran_compiler} \
#    USER_FFLAGS="-g -O0 -fno-range-check -ffixed-line-length-none -ffree-line-length-none" \
#    USER_LDFLAGS="`nf-config --flibs`" make
INC_NETCDF="`nf-config --includedir`" \
    LIB_NETCDF="`nc-config --libdir`" USER_FC="`nc-config --fc`" \
    USER_LDFLAGS="`nf-config --flibs`" make

# Make fsurdat
datestr=210706 #`date +'%Y%m%d'`
mksurfdata=${e3sm_root}/components/elm/tools/mksurfdata_map/mksurfdata.pl
cd ${output_root}
# Get list of files we need
nice ${mksurfdata} -res usrspec -usr_gname ${lnd_grid_name} -usr_gdate ${datestr} -dinlc ${inputdata_root} -year 1950
