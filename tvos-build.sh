#!/bin/bash
#build ffmpeg for all archs and uses lipo to create fat libraries and deletes the originals

set -e

. shared_options.sh
PATH=$(PWD)/gas-preprocessor:$PATH

arch="arm64"

rm -f config.h

ffarch=${arch}
versionmin=6.0
cpu=generic

sdk=appletvos
ffarch=aarch64
versionmin=11.0

./configure \
    --prefix=tvos/${arch} \
    --enable-cross-compile \
    --arch=${ffarch} \
    --cc=$(xcrun -f clang) \
    --sysroot="$(xcrun --sdk ${sdk} --show-sdk-path)" \
    --extra-cflags="-arch ${arch} -D_DARWIN_FEATURE_CLOCK_GETTIME=0 -mappletvos-version-min=${versionmin} ${cflags}" \
    ${CONFIGURE_OPTS} \
    --extra-ldflags="-arch ${arch} -isysroot $(xcrun --sdk ${sdk} --show-sdk-path) -mappletvos-version-min=${versionmin}" \
    --target-os=darwin \
    ${extraopts} \
    --cpu=${cpu} \
    --enable-pic

make clean
make -j8 install
