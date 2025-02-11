#!/bin/sh

set -e

# This script is for internal CI use only
#
# performs a standard out-of-tree build and transform environment vars to cmake options
# set RTLSDR=ON/OFF/AUTO (default: ON)
# set SOAPYSDR=ON/OFF/AUTO (default: AUTO)
# set OPENSSL=ON/OFF/AUTO (default: AUTO)
# set CMAKE_TOOLCHAIN_FILE=file (default: unset)
# set RUN_RTL_433_TESTS=1 (default: unset)

RTLSDR="${RTLSDR:-ON}"
SOAPYSDR="${SOAPYSDR:-AUTO}"
OPENSSL="${OPENSSL:-AUTO}"
set -- -DENABLE_RTLSDR=$RTLSDR -DENABLE_SOAPYSDR=$SOAPYSDR -DENABLE_OPENSSL=$OPENSSL

mkdir -p build
if [ -n "$CMAKE_TOOLCHAIN_FILE" ] ; then
    cmake $@ -DCMAKE_TOOLCHAIN_FILE=../$CMAKE_TOOLCHAIN_FILE -GNinja -B build
else
    cmake $@ -GNinja -B build
fi
cmake --build build

if [ -n "$RUN_RTL_433_TESTS" ] ; then

    cd ..
    set -x
    git clone --depth 1 https://github.com/merbanan/rtl_433_tests.git
    cd rtl_433_tests
    export PATH=../build/src:$PATH
    test -f ../build/src/rtl_433

    # virtualenv --system-site-packages .venv
    # source .venv/bin/activate
    # pip install deepdiff
    make test

fi
