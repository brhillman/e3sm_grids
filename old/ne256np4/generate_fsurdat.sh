#!/bin/bash
set -e

source config.sh

# Get list of input files
if [ "${lnd_grid_name}" == "${atm_grid_name}" ]; then
    #lnd_grid_file=${output_root}/${lnd_grid_name}_scrip.nc
    lnd_grid_file=${atm_scrip_file}
fi

mkdir -p ${output_root}/fsurdat
cd ${output_root}/fsurdat
${e3sm_root}/components/elm/tools/mkmapdata/mkmapdata.sh \
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

datestr=`date +'%y%m%d'`

# Make maps
cd ${output_root}/fsurdat
mpirun="" #srun -C knl --account e3sm --time 00:30:00 -K -c 1 -N 10 --ntasks 10"
CDATE="${datestr}" ${e3sm_root}/components/elm/tools/mkmapdata/mkmapdata.sh \
    --gridfile ${lnd_grid_file} \
    --inputdata-path ${inputdata_root} \
    --res ${lnd_grid_name} \
    --gridtype global \
    --output-filetype 64bit_offset \
    -v || exit 1

# Adjust the HYDRO1K map
#algorithm="nco"
#ncks --frac_b_nrm ${output_root}/fsurdat/map_hydro1k_to_ne1024np4_${algorithm}_${datestr}.nc

# Build mksurfdata_map
cd ${e3sm_root}/components/elm/tools/mksurfdata_map/src || exit 1
eval $(${e3sm_root}/cime/CIME/Tools/get_case_env)
#${e3sm_root}/cime/CIME/scripts/configure --macros-format Makefile --mpilib mpi-serial
${e3sm_root}/cime/CIME/scripts/configure --macros-format=Makefile --machine=${machine} || exit 1
#INC_NETCDF=${NETCDFROOT}/include \
#    LIB_NETCDF=${NETCDFROOT}/lib USER_FC=${fortran_compiler} \
#    USER_FFLAGS="-g -O0 -fno-range-check -ffixed-line-length-none -ffree-line-length-none" \
#    USER_LDFLAGS="`nf-config --flibs`" make
INC_NETCDF="`nf-config --includedir`" \
    LIB_NETCDF="`nc-config --libdir`" USER_FC="`nc-config --fc`" \
    USER_LDFLAGS="`nf-config --flibs`" USER_FFLAGS="-fno-range-check -ffree-line-length-none" make

# Make fsurdat
cd ${output_root}/fsurdat
nice ${e3sm_root}/components/elm/tools/mksurfdata_map/mksurfdata.pl \
    -res usrspec \
    -usr_gname ${lnd_grid_name} -usr_gdate ${datestr} \
    -year 2010 -dinlc ${inputdata_root} \
    -usr_mapdir ${output_root}/fsurdat

