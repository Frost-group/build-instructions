module reset
module load PrgEnv-gnu
module load boost
module load cray-python



mkdir build
cd build


# GMP
wget https://gmplib.org/download/gmp/gmp-6.2.1.tar.xz 
tar -xvf gmp-6.2.1.tar.xz

pushd ./
cd gmp-6.2.1
CC=cc CXX=CC FC=ftn LDFLAGS=-dynamic ./configure --prefix=${HOME}/opt/gmp-6.2.1/ --enable-cxx
make -j
make install
popd

export CPPFLAGS="-I${HOME}/opt/gmp-6.2.1/include"
export LDFLAGS="-L${HOME}/opt/gmp-6.2.1/lib -dynamic"

# LIBINT
wget https://github.com/evaleev/libint/archive/v2.6.0.tar.gz
tar xzf v2.6.0.tar.gz

pushd ./
cd libint-2.6.0
./autogen.sh
mkdir build
cd build
CC=cc CXX=CC FC=ftn ../configure --prefix=${HOME}/opt/libint-2.6.0/ \
	--enable-1body=1 --enable-eri=0 --enable-eri3=0 --enable-eri2=0 --enable-contracted-ints \
	--with-max-am=7 --with-opt-am=2 \
	--with-cxxgen=g++ --with-cxxgen-optflags=-O1 --with-cxx=g++ --with-cxx-optflags=-O1
make -j
make install
popd

# LIBXC
read p

CC=cc CXX=CC FC=ftn ./configure --prefix=${HOME}/opt/libxc
