# This file is for user convenience only and is not used by the model
# Changes to this file will be ignored and overwritten
# Changes to the environment should be made in env_mach_specific.xml
# Run ./case.setup --reset to regenerate this file
source /opt/modules/default/init/sh
module rm craype craype-mic-knl craype-haswell PrgEnv-intel PrgEnv-cray PrgEnv-gnu intel cce gcc cray-parallel-netcdf cray-parallel-hdf5 pmi cray-mpich2 cray-mpich cray-netcdf cray-hdf5 cray-netcdf-hdf5parallel cray-libsci papi cmake cray-petsc esmf zlib
module load craype PrgEnv-intel cray-mpich
module rm craype-haswell
module load craype-mic-knl
module swap cray-mpich cray-mpich/7.7.0
module load PrgEnv-intel/6.0.4
module rm intel
module load intel/18.0.1.163
module swap craype craype/2.5.14
module rm pmi
module load pmi/5.0.13
module rm craype-haswell
module load craype-mic-knl
module rm cray-netcdf-hdf5parallel
module load cray-netcdf-hdf5parallel/4.4.1.1.6 cray-hdf5-parallel/1.10.1.1 cray-parallel-netcdf/1.8.1.3
module rm git
module load git
module rm cmake
module load cmake/3.11.4
export MPICH_ENV_DISPLAY=1
export MPICH_VERSION_DISPLAY=1
export OMP_STACKSIZE=128M
export OMP_PROC_BIND=spread
export OMP_PLACES=threads
export HDF5_USE_FILE_LOCKING=FALSE
export MPICH_GNI_DYNAMIC_CONN=disabled
export FORT_BUFFERED=yes
export MPICH_MEMORY_REPORT=1
export COMPILER=intel
export MPILIB=mpt
export DEBUG=FALSE
export OS=CNL
