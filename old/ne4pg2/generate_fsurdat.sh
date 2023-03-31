#!/bin/bash

source config.sh

script_root=${PWD}

# Get list of input files
if [ "${lnd_grid_name}" == "${atm_grid_name}" ]; then
    lnd_grid_file=${output_root}/${lnd_grid_name}_scrip.nc
fi
cd ${e3sm_root}/components/elm/tools/shared/mkmapdata
echo ./mkmapdata.sh \
    --gridfile ${lnd_grid_file} \
    --inputdata-path ${inputdata_root} \
    --res ${lnd_grid_name} \
    --gridtype global \
    --output-filetype 64bit_offset \
    --debug -v --list
if [ $? -ne 0 ]; then
    echo "mkmapdata.sh failed"
    exit 1
fi

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
source activate nco
echo nice ./mkmapdata.sh \
    --gridfile ${lnd_grid_file} \
    --inputdata-path ${inputdata_root} \
    --res ${lnd_grid_name} \
    --gridtype global \
    --output-filetype 64bit_offset \
    -v
if [ $? -ne 0 ]; then
    echo "mkmapdata.sh failed"
    exit 1
fi

# Edit namelist
datestr=220112 #`date +'%Y%m%d'`
cd ${e3sm_root}/components/elm/tools/clm4_5/mksurfdata_map
#cat namelist | sed "s/mksrf_fdynuse.*/mksrf_fdynuse = LUT_LUH2_HIST_LUH1f_list_parsed.txt/" #> namelist
#exit 0
#cat namelist | sed "s/fdyndat .*/fdyndat = 'landuse.timeseries_ne4pg2_historical_simyr1850-2015_c${datestr}'/" > namelist

# Build mksurfdata_map
cd ${e3sm_root}/components/elm/tools/clm4_5/mksurfdata_map/src || exit 1
${e3sm_root}/cime/tools/configure --macros-format=Makefile || exit 1
source .env_mach_specific.sh || exit 1
INC_NETCDF=${NETCDFROOT}/include \
    LIB_NETCDF=${NETCDFROOT}/lib USER_FC=gfortran \
    USER_FFLAGS="-g -O0 -fno-range-check -ffixed-line-length-none -ffree-line-length-none" \
    USER_LDFLAGS="`nf-config --flibs`" make

# Make fsurdat
cd ${e3sm_root}/components/elm/tools/clm4_5/mksurfdata_map
# Edit namelist
# Run code
nice ./mksurfdata.pl -res usrspec -usr_gname ${lnd_grid_name} -usr_gdate ${datestr} -dinlc ${inputdata_root} -years 1850-2015
