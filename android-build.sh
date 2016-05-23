#!/bin/bash
#Change NDK to your Android NDK location
NDK=/c/AndroidNDK
PLATFORM=$NDK/platforms/android-9/arch-arm/
PREBUILT=$NDK/toolchains/arm-linux-androideabi-4.9/prebuilt/windows-x86_64
PREBUILTLLVM=$NDK/toolchains/llvm/prebuilt/windows-x86_64

set -e

GENERAL="\
   --enable-cross-compile \
   --enable-pic \
   --extra-libs="-latomic" \
   --arch=arm \
   --cc=$PREBUILTLLVM/bin/clang \
   --cross-prefix=$PREBUILT/bin/arm-linux-androideabi- \
   --ld=$PREBUILTLLVM/bin/clang \
   --nm=$PREBUILT/bin/arm-linux-androideabi-nm"

MODULES="\
   --disable-avdevice \
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
    --enable-decoder=atrac3p \
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

VIDEO_ENCODERS="\
    --enable-encoder=huffyuv \
    --enable-encoder=ffv1 \
    --enable-encoder=mjpeg"

AUDIO_ENCODERS="\
    --enable-encoder=pcm_s16le"

MUXERS="\
    --enable-muxer=avi"


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
    ${GENERAL} \
    --sysroot=$PLATFORM \
    --extra-cflags=" --target=arm-linux-androideabi -O3 -DANDROID -fpic -fasm -fno-short-enums -fno-strict-aliasing -mfloat-abi=softfp -mfpu=vfp -marm -march=armv6" \
    --disable-shared \
    --enable-static \
    --extra-ldflags=" -B$PREBUILT/bin/arm-linux-androideabi- --target=arm-linux-androideabi -Wl,--rpath-link,$PLATFORM/usr/lib -L$PLATFORM/usr/lib -L$PREBUILT/arm-linux-androideabi/lib -nostdlib -lc -lm -ldl -llog" \
    --enable-zlib \
    --disable-everything \
    ${MODULES} \
    ${VIDEO_DECODERS} \
    ${AUDIO_DECODERS} \
    ${VIDEO_ENCODERS} \
    ${AUDIO_ENCODERS} \
    ${DEMUXERS} \
    ${MUXERS} \
    ${PARSERS} \
    --disable-neon

make clean
make -j4 install
}

function build_ARMv7
{
./configure --target-os=linux \
    --prefix=./android/armv7 \
    ${GENERAL} \
    --sysroot=$PLATFORM \
    --extra-cflags=" --target=arm-linux-androideabi -O3 -DANDROID -fpic -fasm -fno-short-enums -fno-strict-aliasing -mfloat-abi=softfp -mfpu=vfp -marm -march=armv7-a" \
    --disable-shared \
    --enable-static \
    --extra-ldflags=" -B$PREBUILT/bin/arm-linux-androideabi- --target=arm-linux-androideabi -Wl,--rpath-link,$PLATFORM/usr/lib -L$PLATFORM/usr/lib -L$PREBUILT/arm-linux-androideabi/lib -nostdlib -lc -lm -ldl -llog" \
    --enable-zlib \
    --disable-everything \
    --enable-runtime-cpudetect \
    ${MODULES} \
    ${VIDEO_DECODERS} \
    ${AUDIO_DECODERS} \
    ${VIDEO_ENCODERS} \
    ${AUDIO_ENCODERS} \
    ${DEMUXERS} \
    ${MUXERS} \
    ${PARSERS}

make clean
make -j4 install
}

build_ARMv6
build_ARMv7
echo Android ARM builds finished
