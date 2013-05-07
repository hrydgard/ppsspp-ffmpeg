#!/bin/sh

BB_OS=`cat ${QNX_TARGET}/etc/qversion 2>/dev/null`
if [ -z "$BB_OS" ]; then
    echo "Could not find your Blackberry NDK. Please source bbndk-env.sh"
    exit 1
fi
echo "Building for Blackberry ${BB_OS}"

./configure --target-os=qnx \
    --prefix=./blackberry/armv7 \
    --enable-cross-compile \
    --arch=arm \
    --cc=arm-unknown-nto-qnx8.0.0eabi-gcc \
    --cross-prefix=arm-unknown-nto-qnx8.0.0eabi- \
    --nm=arm-unknown-nto-qnx8.0.0eabi-nm \
    --sysroot=$QNX_TARGET \
    --extra-cflags="-O3 -fpic -DBLACKBERRY -DQNX -DHAVE_SYS_UIO_H=1 -Dipv6mr_interface=ipv6mr_ifindex -fasm -Wno-psabi -fno-short-enums -fno-strict-aliasing -finline-limit=300 -DCMP_HAVE_VFP -mfloat-abi=softfp -mfpu=neon -march=armv7" \
    --disable-shared \
    --enable-static \
    --extra-ldflags="-Wl,-rpath-link=$QNX_TARGET/armle-v7/usr/lib -L$QNX_TARGET/armle-v7/usr/lib" \
    --enable-zlib \
  	--disable-armv5te \
  	--disable-armv6  \
  	--disable-armv6t2 \
    --disable-ffplay \
    --disable-ffprobe \
    --disable-ffserver \
	--enable-neon

make -j 4 install

