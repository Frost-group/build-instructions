#!/bin/bash
module switch PrgEnv-$(echo $PE_ENV | tr '[:upper:]' '[:lower:]') PrgEnv-gnu 

# In theory
#
# changing execs to apruns in the test suite files should mean that
# the build and test could be done in /home.  Even this is not ideal -
# the exec should be $EXEC and the $EXEC should be removed from
# xc-run_testsuite, then EXEC could be set to 'aprun -n 1' in the test
# PBS script.  However, the test suite files are actually generated by
# libtool, and so they cannot be changed - the execs are in ltmain.sh
# itself.
#
# In practice
#
# there are too many directories to fix up to let aprun work, so
# simply build and test on /work.

export CC=cc
export FC=ftn
export CRAYPE_LINK_TYPE=dynamic
# The prefix will be something like
# /work/y07/y07/cse/libxc/4.3.4_build1/GNU
# since this script should be run in something like
# /work/y07/y07/cse/libxc/4.3.4_build1/GNU/build
prefix=$(readlink -f $PWD/..)
(
    cd libxc-4.3.4
    module list &> module.log
    ./configure CC=$CC FC=$FC --prefix=$prefix --enable-shared &> configure.log &&
    make &> make.log &&
    qsub ../test.pbs
)
