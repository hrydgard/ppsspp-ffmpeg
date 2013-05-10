#!/bin/sh

BB_OS=`cat ${QNX_TARGET}/etc/qversion 2>/dev/null`
if [ -z "$BB_OS" ]; then
    echo "Could not find your Blackberry NDK. Please source bbndk-env.sh"
    exit 1
fi
echo "Building for Blackberry ${BB_OS}"

GENERAL="\
   --enable-cross-compile \
   --arch=arm \
   --enable-neon \
   --cc=arm-unknown-nto-qnx8.0.0eabi-gcc \
   --cross-prefix=arm-unknown-nto-qnx8.0.0eabi- \
   --nm=arm-unknown-nto-qnx8.0.0eabi-nm"

MODULES="\
   --disable-filters \
   --disable-programs \
   --disable-network \
   --disable-avfilter \
   --disable-postproc \
   --disable-encoders \
   --disable-doc \
   --disable-ffplay \
   --disable-ffprobe \
   --disable-ffserver \
   --disable-ffmpeg"

VIDEO_DECODERS="\
   --enable-decoder=h264 \
   --enable-decoder=mpeg2video"

AUDIO_DECODERS="\
    --enable-decoder=aac \
    --enable-decoder=atrac1 \
    --enable-decoder=atrac3 \
    --enable-decoder=mp3 \
    --enable-decoder=pcm_s16le \
    --enable-decoder=pcm_s8"
  
DEMUXERS="\
    --enable-demuxer=h264 \
    --enable-demuxer=mpegps \
    --enable-demuxer=mpegvideo \
    --enable-demuxer=avi \
    --enable-demuxer=aac \
    --enable-demuxer=oma \
    --enable-demuxer=pcm_s16le \
    --enable-demuxer=pcm_s8 \
    --enable-demuxer=wav"

PARSERS="\
    --enable-parser=h264 \
    --enable-parser=mpeg4video \
    --enable-parser=mpegvideo \
    --enable-parser=aac \
    --enable-parser=mpegaudio" 


./configure --target-os=qnx \
    --prefix=./blackberry/armv7 \
    ${GENERAL} \
    --sysroot=$QNX_TARGET \
    --extra-cflags="-O3 -fpic -DBLACKBERRY -DQNX -fasm -Wno-psabi -fno-short-enums -fno-strict-aliasing -finline-limit=300 -DCMP_HAVE_VFP -mfloat-abi=softfp -mfpu=neon -march=armv7" \
    --disable-shared \
    --enable-static \
    --extra-ldflags="-Wl,-rpath-link=$QNX_TARGET/armle-v7/usr/lib -L$QNX_TARGET/armle-v7/usr/lib" \
    --enable-zlib \
    --disable-everything \
    ${MODULES} \
    ${VIDEO_DECODERS} \
    ${AUDIO_DECODERS} \
    ${DEMUXERS} \
    ${PARSERS}

make clean
make install

