# This file is for user convenience only and is not used by the model
# Changes to this file will be ignored and overwritten
# Changes to the environment should be made in env_mach_specific.xml
# Run ./case.setup --reset to regenerate this file
source /opt/modules/default/init/sh
module rm craype craype-mic-knl craype-haswell PrgEnv-intel PrgEnv-cray PrgEnv-gnu intel cce gcc cray-parallel-netcdf cray-hdf5-parallel pmi cray-mpich2 cray-mpich cray-netcdf cray-hdf5 cray-netcdf-hdf5parallel cray-libsci papi cmake cray-petsc esmf zlib craype-hugepages2M darshan
module load craype PrgEnv-intel cray-mpich
module rm craype-haswell
module load craype-mic-knl
module swap cray-mpich cray-mpich/7.7.10
module load PrgEnv-intel/6.0.5
module rm intel
module load intel/19.0.3.199
module swap craype craype/2.6.2
module rm pmi
module load pmi/5.0.14
module rm craype-haswell
module load craype-mic-knl
module rm cray-netcdf-hdf5parallel
module load cray-netcdf-hdf5parallel/4.6.3.2 cray-hdf5-parallel/1.10.5.2 cray-parallel-netcdf/1.11.1.1
module rm git
module load git
module rm cmake
module load cmake/3.21.3 perl5-extras
export MPICH_ENV_DISPLAY=1
export MPICH_VERSION_DISPLAY=1
export OMP_STACKSIZE=128M
export OMP_PROC_BIND=spread
export OMP_PLACES=threads
export HDF5_USE_FILE_LOCKING=FALSE
export CRAYPE_LINK_TYPE=static
export MPICH_GNI_DYNAMIC_CONN=disabled
export MPICH_MEMORY_REPORT=1
export COMPILER=intel
export MPILIB=mpt
export DEBUG=FALSE
export OS=CNL
