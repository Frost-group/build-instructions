# ORCA installation instructions

Dependencies:
 - OpenMPI 3.1.4
 - GNU compiler (required by OpenMPI)

Performance across nodes may not be optimal. 

## Build OpenMPI, version 3.1.4 in particular

```
INSTALL_DIR=/work/gid/gid/uid/openmpi

module restore -s PrgEnv-gnu
wget https://download.open-mpi.org/release/open-mpi/v3.1/openmpi-3.1.4.tar.gz
tar xf openmpi-3.1.4.tar.gz
cd openmpi-3.1.4
mkdir build
cd build
../configure CC=gcc CXX=g++ F77=gfortran FC=gfortran \
        --enable-mpi1-compatibility --enable-mpi-fortran \
        --with-ofi=/opt/cray/libfabric/1.11.0.4.71 \
        --prefix=$INSTALL_DIR
make
make install

export PATH=$PATH:$INSTALL_DIR
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$INSTALL_DIR/lib
```

## Install ORCA 
1. Download `orca_5_0_2_linux_x86-64_shared_openmpi411.tar.xz` from the ORCA website.
2. Untar the file, in WORK:
   ```
   tar xf orca_5_0_2_linux_x86-64_shared_openmpi411.tar.xz
   ```
3. Your PBS script will need to set the path to the ORCA and OpenMPI binaries and libraries:
   ```
# for liborca_tools_5_0_2.so.5
# and self-built openmpi
export LD_LIBRARY_PATH=/work/gid/gid/uid/orca_5_0_3_linux_x86-64_shared_openmpi411:/work/gid/gid/uid/openmpi/lib

export PATH="${PATH}":/work/gid/gid/uid/openmpi/bin

# avoid any unintentional OpenMP threading by
# setting OMP_NUM_THREADS, and launch the code.
export OMP_NUM_THREADS=1

/work/gid/gid/uid/orca_5_0_3_linux_x86-64_shared_openmpi411/orca input.orca > input.orca.stdout
```

Further generic instructions for Orc can be found here:
https://sites.google.com/site/orcainputlibrary/setting-up-orca
