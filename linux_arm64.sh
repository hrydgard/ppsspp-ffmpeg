#!/bin/bash

set -e

GENERAL="\
   --enable-cross-compile \
   --extra-libs="-lgcc" \
   --arch=aarch64 \
   --cc=aarch64-linux-gnu-gcc \
   --cross-prefix=aarch64-linux-gnu- \
   --nm=aarch64-linux-gnu-gcc-nm"

#~ GENERAL="\
   #~ --enable-cross-compile \
   #~ --extra-libs="-lgcc" \
   #~ --arch=arm \
   #~ --cc=arm-linux-gnueabi-gcc \
   #~ --cross-prefix=arm-linux-gnueabi- \
   #~ --nm=arm-linux-gnueabi-nm"

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


function build_ARM64
{
./configure --target-os=linux \
    --prefix=./linux/aarch64 \
    ${GENERAL} \
    --extra-cflags=" -O3 -fasm -Wno-psabi -fno-short-enums -fno-strict-aliasing -finline-limit=300 " \
    --disable-shared \
    --enable-static \
    --enable-zlib \
    --enable-pic \
    --disable-everything \
    ${MODULES} \
    ${VIDEO_DECODERS} \
    ${AUDIO_DECODERS} \
    ${VIDEO_ENCODERS} \
    ${AUDIO_ENCODERS} \
    ${DEMUXERS} \
    ${MUXERS} \
    ${PARSERS}
make clean
make install
}

build_ARM64

echo Linux ARM builds finished
