# This file is for user convenience only and is not used by the model
# Changes to this file will be ignored and overwritten
# Changes to the environment should be made in env_mach_specific.xml
# Run ./case.setup --reset to regenerate this file
source /usr/share/Modules/init/sh
module purge 
module load sems-env acme-env sems-git sems-python/2.7.9 sems-cmake/3.12.2 acme-gcc/8.1.0 acme-openmpi/2.1.5 acme-netcdf/4.7.4/acme
export NETCDFROOT=/projects/sems/install/rhel7-x86_64/acme/tpl/netcdf/4.7.4/gcc/8.1.0/openmpi/2.1.5/acme
export OMP_STACKSIZE=64M
export OMP_PROC_BIND=spread
export OMP_PLACES=threads