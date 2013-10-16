#!/bin/bash
#Change NDK to your Android NDK location
NDK=/c/AndroidNDK
PLATFORM=$NDK/platforms/android-14/arch-x86/
PREBUILT=$NDK/toolchains/x86-4.6/prebuilt/windows-x86_64

GENERAL="\
   --enable-cross-compile \
   --extra-libs="-lgcc" \
   --cc=$PREBUILT/bin/i686-linux-android-gcc \
   --cross-prefix=$PREBUILT/bin/i686-linux-android- \
   --nm=$PREBUILT/bin/i686-linux-android-nm"

MODULES="\
   --disable-filters \
   --disable-programs \
   --disable-network \
   --disable-avfilter \
   --disable-postproc \
   --disable-encoders \
   --disable-protocols \
   --disable-hwaccels \
   --disable-doc"

VIDEO_DECODERS="\
   --enable-decoder=h264 \
   --enable-decoder=mpeg4 \
   --enable-decoder=mpeg2video \
   --enable-decoder=mjpeg \
   --enable-decoder=mjpegb"

AUDIO_DECODERS="\
    --enable-decoder=aac \
    --enable-decoder=aac_latm \
    --enable-decoder=atrac3 \
    --enable-decoder=mp3 \
    --enable-decoder=pcm_s16le \
    --enable-decoder=pcm_s8"
  
DEMUXERS="\
    --enable-demuxer=h264 \
    --enable-demuxer=m4v \
    --enable-demuxer=mpegvideo \
    --enable-demuxer=mpegps \
    --enable-demuxer=mp3 \
    --enable-demuxer=avi \
    --enable-demuxer=aac \
    --enable-demuxer=pmp \
    --enable-demuxer=oma \
    --enable-demuxer=pcm_s16le \
    --enable-demuxer=pcm_s8 \
    --enable-demuxer=wav"

PARSERS="\
    --enable-parser=h264 \
    --enable-parser=mpeg4video \
    --enable-parser=mpegaudio \
    --enable-parser=mpegvideo \
    --enable-parser=aac \
    --enable-parser=aac_latm"


function build_ARMv6
{
./configure --target-os=linux \
    --prefix=./android/armv6 \
    --arch=arm \
    ${GENERAL} \
    --sysroot=$PLATFORM \
    --extra-cflags=" -O3 -fpic -DANDROID -DHAVE_SYS_UIO_H=1 -Dipv6mr_interface=ipv6mr_ifindex -fasm -Wno-psabi -fno-short-enums -fno-strict-aliasing -finline-limit=300 -DCMP_HAVE_VFP -mfloat-abi=softfp -mfpu=vfp -marm -march=armv6" \
    --disable-shared \
    --enable-static \
    --extra-ldflags="-Wl,-rpath-link=$PLATFORM/usr/lib -L$PLATFORM/usr/lib -nostdlib -lc -lm -ldl -llog" \
    --enable-zlib \
    --disable-everything \
    ${MODULES} \
    ${VIDEO_DECODERS} \
    ${AUDIO_DECODERS} \
    ${DEMUXERS} \
    ${PARSERS} \
    --disable-neon

make clean
make install
}

function build_ARMv7
{
./configure --target-os=linux \
    --prefix=./android/armv7 \
    --arch=arm \
    ${GENERAL} \
    --sysroot=$PLATFORM \
    --extra-cflags=" -O3 -fpic -DANDROID -DHAVE_SYS_UIO_H=1 -Dipv6mr_interface=ipv6mr_ifindex -fasm -Wno-psabi -fno-short-enums -fno-strict-aliasing -finline-limit=300 -mfloat-abi=softfp -mfpu=vfp -marm -march=armv7-a" \
    --disable-shared \
    --enable-static \
    --extra-ldflags="-Wl,-rpath-link=$PLATFORM/usr/lib -L$PLATFORM/usr/lib -nostdlib -lc -lm -ldl -llog" \
    --enable-zlib \
    --disable-everything \
    ${MODULES} \
    ${VIDEO_DECODERS} \
    ${AUDIO_DECODERS} \
    ${DEMUXERS} \
    ${PARSERS} \
    --disable-neon \

make clean
make install
}

function build_x86
{
./configure --logfile=conflog.txt --target-os=linux \
    --prefix=./android/x86 \
    --arch=x86 \
    ${GENERAL} \
    --sysroot=$PLATFORM \
    --extra-cflags=" -O3 -DANDROID -DHAVE_SYS_UIO_H=1 -Dipv6mr_interface=ipv6mr_ifindex -fasm -Wno-psabi -fno-short-enums -fno-strict-aliasing -fomit-frame-pointer -march=k8" \
    --disable-shared \
    --enable-static \
    --extra-ldflags="-Wl,-rpath-link=$PLATFORM/usr/lib -L$PLATFORM/usr/lib -nostdlib -lc -lm -ldl -llog" \
    --enable-zlib \
    --disable-everything \
    ${MODULES} \
    ${VIDEO_DECODERS} \
    ${AUDIO_DECODERS} \
    ${DEMUXERS} \
    ${PARSERS}

make clean
make install
}

#build_ARMv6
#build_ARMv7
build_x86
