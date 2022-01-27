Instructions for compiling NAMD 2.14 for Cirrus
===============================================

These instructions are for compiling NAMD 2.14 (with and without SMP) on Cirrus (SGI ICE XA, Broadwell) full system
using the GCC 8 compilers and Intel MPI 19.


Setup initial environment
-------------------------

```bash
PRFX=/path/to/work
NAMD_LABEL=namd
NAMD_LABEL_CAPS=`echo ${NAMD_LABEL} | tr [a-z] [A-Z]`
NAMD_VERSION=2.14
NAMD_ROOT=${PRFX}/${NAMD_LABEL}
NAMD_NAME=${NAMD_LABEL}-${NAMD_VERSION}
NAMD_ARCHIVE=${NAMD_LABEL_CAPS}_${NAMD_VERSION}_Source
```

Remember to change the setting for `PRFX` to a path appropriate for your Cirrus project.


Download and unpack NAMD
------------------------

Next, download the NAMD 2.14 source from: http://www.ks.uiuc.edu/Development/Download/download.cgi?PackageName=NAMD
and transfer to the Cirrus system at the path indicated by `$NAMD_ROOT/arc`.

Unpack the source.

```bash
cd ${NAMD_ROOT} 
cp ${NAMD_ROOT}/arc/${NAMD_ARCHIVE}.tar.gz ${NAMD_ROOT}/
tar -xzf ${NAMD_ARCHIVE}.tar.gz
rm ${NAMD_ARCHIVE}.tar.gz
mv ${NAMD_ARCHIVE} ${NAMD_NAME}
```


Load the GCC, MPI and FFTW modules
----------------------------------

```bash
GNU_VERSION=8.2.0
IMPI_VERSION=19.0.0.117
FFTW_VERSION=3.3.9

GNU_VERSION_MAJOR=`echo ${GNU_VERSION} | cut -d'.' -f1`
IMPI_VERSION_MAJOR=`echo ${IMPI_VERSION} | cut -d'.' -f1`

module load gcc/${GNU_VERSION}
module load intel-mpi-${IMPI_VERSION_MAJOR}/${IMPI_VERSION}
module load fftw/${FFTW_VERSION}-impi${IMPI_VERSION_MAJOR}-gcc${GNU_VERSION_MAJOR}
```


Download, build and install TCL
-------------------------------

```bash
TCL_LABEL=tcl
TCL_VERSION=8.5.9
TCL_ROOT=${NAMD_ROOT}/${TCL_LABEL}
TCL_NAME=${TCL_LABEL}-${TCL_VERSION}
TCL_ARCHIVE=${TCL_LABEL}${TCL_VERSION}-src

mkdir -p ${TCL_ROOT}
cd ${TCL_ROOT}

wget http://www.ks.uiuc.edu/Research/${NAMD_LABEL}/libraries/${TCL_ARCHIVE}.tar.gz
tar -xzf ${TCL_ARCHIVE}.tar.gz
rm ${TCL_ARCHIVE}.tar.gz
mv ${TCL_LABEL}${TCL_VERSION} ${TCL_NAME}

cd ${TCL_NAME}/unix
export FC=gfortran CC=gcc CXX=g++

./configure --enable-threads --prefix=${TCL_ROOT}/${TCL_VERSION}
make
make test
make install
```


Build and install Charm++ (with and without SMP)
------------------------------------------------

```bash
cd ${NAMD_ROOT}/${NAMD_NAME}

NAMD_CHARM_NAME=charm-6.10.2
tar -xf ${NAMD_CHARM_NAME}.tar

TCL_BASEDIR=${TCL_ROOT}/${TCL_VERSION}

cd ${NAMD_CHARM_NAME}
export CRAY_MPICH_GNU_BASEDIR=${CRAY_MPICH_BASEDIR}/gnu/${PE_MPICH_GENCOMPILERS_GNU}

./build charm++ mpi-linux-amd64 gcc smp --incdir=${I_MPI_ROOT}/intel64/include --libdir=${I_MPI_ROOT}/intel64/lib --libdir=${I_MPI_ROOT}/intel64/lib/release --libdir=${I_MPI_ROOT}/intel64/libfabric/lib --with-production
./build charm++ mpi-linux-amd64 gcc --incdir=${I_MPI_ROOT}/intel64/include --libdir=${I_MPI_ROOT}/intel64/lib --libdir=${I_MPI_ROOT}/intel64/lib/release --libdir=${I_MPI_ROOT}/intel64/libfabric/lib --with-production
```


Build and install NAMD (SMP version)
------------------------------------

```bash
cd ${NAMD_ROOT}/${NAMD_NAME}
./config Linux-x86_64-g++ --tcl-prefix ${TCL_BASEDIR} --with-fftw3 --fftw-prefix /lustre/sw/fftw/3.3.9-impi19-gcc8 --charm-arch mpi-linux-amd64-smp-gcc
cd ${NAMD_ROOT}/${NAMD_NAME}/Linux-x86_64-g++
gmake

mkdir -p ${NAMD_ROOT}/${NAMD_VERSION}
cd ${NAMD_ROOT}/${NAMD_VERSION}
cp -r ${NAMD_ROOT}/${NAMD_NAME}/Linux-x86_64-g++ bin
cd bin
rm .rootdir
ln -s ${NAMD_ROOT}/${NAMD_NAME} .rootdir

rm -rf ${NAMD_ROOT}/${NAMD_NAME}/Linux-x86_64-g++
```

The `namd2` executable exists in the `${NAMD_ROOT}/${NAMD_VERSION}/bin` directory.


Build and install NAMD (non-SMP version)
----------------------------------------

```bash
cd ${NAMD_ROOT}/${NAMD_NAME}
./config Linux-x86_64-g++ --tcl-prefix ${TCL_BASEDIR} --with-fftw3 --fftw-prefix /lustre/sw/fftw/3.3.9-impi19-gcc8 --charm-arch mpi-linux-amd64-gcc
cd ${NAMD_ROOT}/${NAMD_NAME}/Linux-x86_64-g++
gmake

mkdir -p ${NAMD_ROOT}/${NAMD_VERSION}-nosmp
cd ${NAMD_ROOT}/${NAMD_VERSION}-nosmp
cp -r ${NAMD_ROOT}/${NAMD_NAME}/Linux-x86_64-g++ bin
cd bin
rm .rootdir
ln -s ${NAMD_ROOT}/${NAMD_NAME} .rootdir

rm -rf ${NAMD_ROOT}/${NAMD_NAME}/Linux-x86_64-g++
```

This `namd2` executable exists in the `${NAMD_ROOT}/${NAMD_VERSION}-nosmp/bin` directory.