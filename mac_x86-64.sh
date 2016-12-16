#!/bin/sh

rm config.h
echo "Building for MacOSX"

set -e

ARCH="x86_64"

. shared_options.sh

./configure \
    --prefix=./macosx/${ARCH} \
    --extra-cflags="-D__STDC_CONSTANT_MACROS -O3 -mmacosx-version-min=10.7" \
    ${CONFIGURE_OPTS} \
    --arch=${ARCH} \
    --cc=clang

make clean
make -j8 install
