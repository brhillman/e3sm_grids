#!/bin/bash

# Parse command line arguments
if [ $# -ge 1 ]; then
    configuration_file=$1
    source ${configuration_file}
    shift
else
    echo "usage: `basename $0` <configuration_file>"
    exit 1
fi


# Parse optional arguments
method="tempest"
for arg in "$@"; do
    case $arg in
        --method=*)
            method="${arg#*=}"
            shift
            ;;
        *)
            echo "Error parsing ${arg}. See usage."
            exit 1
            ;;
    esac
done



# Load a common conda environment for E3SM pre and post processing tools
source /global/project/projectdirs/acme/software/anaconda_envs/load_latest_e3sm_unified.sh


# Build and add tempest to path
tempest_path=~bhillma/codes/e3sm/e3sm_grids/tempestremap/bin
PATH=${tempest_path}:${PATH}
            
            
# Add Charlie Zender's latest NCO tool builds on Cori to path
zender_path=~zender/bin_cori
PATH=${zender_path}:${PATH}
            
    
# Need to override hard-coded paths in NCO scripts
export NCO_PATH_OVERRIDE='No'


# Generate mapping files between all grids
datestring=`date +'%y%m%d'`


# Set E3SM paths
e3sm_root="${HOME}/codes/e3sm/branches/master"


## Get machine-specific modules
#if [ ]; then 
#    ${e3sm_root}/cime/tools/configure  && source .env_mach_specific.sh
#else
    source .env_mach_specific.sh
#fi


# Locate 1x1d scrip grid. 
srfFileName=1x1d
srfFileName_loc=/project/projectdirs/acme/mapping/grids/1x1d.nc


# Locate atm scrip file
echo "Atm scrip file is ${atm_scrip_file}"


# Locate land file for vegetation 
landFileName=/project/projectdirs/acme/inputdata/atm/cam/chem/trop_mozart/dvel/regrid_vegetation.nc


# Locate soil climate file
soilwFileName=/project/projectdirs/acme/inputdata/atm/cam/chem/trop_mozart/dvel/clim_soilw.nc


# Make mapping file from 1x1d to RRM grid
# srf2atmFmapname=/project/projectdirs/acme/bhillma/grids/ne30np4/atmsrffile/map_1x1_to_ne30np4_aave.nc
if [ ! -d ${output_root}/atmsrffile ]; then
    mkdir -p ${output_root}/atmsrffile
fi

if [ "${method}" == "esmf" ]; then
    atm_grid_file=${atm_scrip_file}
else
    atm_grid_file=${atm_mesh_file}
fi
echo "Make mapping file from 1x1d to RRM grid using ${method}"
mapping_root=${output_root}/mapping_files
if [ ! -d ${mapping_root} ]; then 
    mkdir -p ${mapping_root} && cd ${mapping_root}
else
    cd ${mapping_root}
fi


# Maps between 1x1d and atmosphere 
ncremap -P mwf \
    -s ${srfFileName_loc} -g ${atm_grid_file} \
    --nm_src=${srfFileName} --nm_dst=${atm_grid_name} \
    --dt_sng=${datestring}


#srf2atmFmapname=${output_root}/atmsrffile/map_1x1_to_ne30np4_aave.nc


# Change directories to the mkatmsrffile tool
cd ${e3sm_root}/components/cam/tools/mkatmsrffile

# Create namelist for atmsrf, nml_atmsrf
# &input
# srfFileName =  '1x1d.nc'
# atmFileName = 'northamericax4v1np4b_scrip.nc'
# landFileName = 'regrid_vegetation.nc' 
# soilwFileName = 'clim_soilw.nc'
# srf2atmFmapname = 'map_1x1d_to_northamericax4v1_aave.190626.nc'
# outputFileName = 'atmsrf_northamericax4v1np4_190606.nc'
# /




