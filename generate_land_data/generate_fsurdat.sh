#!/bin/bash
set -e

if [ $# -eq 1 ]; then
    configuration=$1
    source ${configuration}
else
    echo "usage: `basename $0` <configuration file>"
    exit 1
fi

# Get list of input files
if [ "${lnd_grid_name}" == "${atm_grid_name}" ]; then
    #lnd_grid_file=${output_root}/${lnd_grid_name}_scrip.nc
    lnd_grid_file=${output_root}/grids/${lnd_grid_name}_scrip.nc
fi
mkmapdata=${e3sm_root}/components/elm/tools/mkmapdata/mkmapdata.sh
cd ${e3sm_root}/components/elm/tools/mkmapdata
echo ${mkmapdata} \
    --gridfile ${lnd_grid_file} \
    --inputdata-path ${inputdata_root} \
    --res ${lnd_grid_name} \
    --gridtype global \
    --output-filetype 64bit_offset \
    --debug -v --list || exit 1

# Make sure we have input files
e3sm_inputdata_repository="https://web.lcrc.anl.gov/public/e3sm"
cesm_inputdata_repository="https://svn-ccsm-inputdata.cgd.ucar.edu/trunk"
inputdata_list=clm.input_data_list
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
mkdir -p ${output_root}/fsurdat
cd ${output_root}/fsurdat
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
${e3sm_root}/cime/CIME/scripts/configure --compiler gnu --machine pm-cpu --mpilib=mpich --macros-format=Makefile || exit 1
source .env_mach_specific.sh || exit 1
#INC_NETCDF=${NETCDFROOT}/include \
#    LIB_NETCDF=${NETCDFROOT}/lib USER_FC=${fortran_compiler} \
#    USER_FFLAGS="-g -O0 -fno-range-check -ffixed-line-length-none -ffree-line-length-none" \
#    USER_LDFLAGS="`nf-config --flibs`" make
INC_NETCDF="`nf-config --includedir`" \
    LIB_NETCDF="`nc-config --libdir`" USER_FC="`nc-config --fc`" USER_FCTYP="gnu" \
    USER_LDFLAGS="`nf-config --flibs`" USER_FFLAGS="-g -fallow-invalid-boz -ffree-line-length-none -ffixed-line-length-none" make

# Make fsurdat
datestr=230119 #`date +'%y%m%d'`
mksurfdata=${e3sm_root}/components/elm/tools/mksurfdata_map/mksurfdata.pl
cd ${output_root}/fsurdat
# Get list of files we need
nice ${mksurfdata} \
    -res usrspec -usr_gname ${lnd_grid_name} -usr_gdate ${datestr} -usr_mapdir ${output_root}/fsurdat \
    -dinlc ${inputdata_root} -year 2010
