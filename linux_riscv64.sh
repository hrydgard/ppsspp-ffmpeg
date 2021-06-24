#!/bin/sh

rm config.h
echo "Building for Linux"

set -e

ARCH="riscv64"

#   --enable-cross-compile \
#   --cc=mipsel-linux-gcc \
#   --cxx=mipsel-linux-g++ \

GENERAL="
	--target-os=linux \
	--disable-shared \
	--enable-static"

MODULES="\
   --disable-avdevice \
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
   --enable-decoder=h263 \
   --enable-decoder=h263p \
   --enable-decoder=mpeg2video"

AUDIO_DECODERS="\
    --enable-decoder=aac \
    --enable-decoder=atrac3 \
    --enable-decoder=atrac3p \
    --enable-decoder=mp3 \
    --enable-decoder=pcm_s16le \
    --enable-decoder=pcm_s8"
  
DEMUXERS="\
    --enable-demuxer=h264 \
    --enable-demuxer=h263 \
    --enable-demuxer=mpegps \
    --enable-demuxer=mpegvideo \
    --enable-demuxer=avi \
    --enable-demuxer=mp3 \
    --enable-demuxer=aac \
    --enable-demuxer=oma \
    --enable-demuxer=pcm_s16le \
    --enable-demuxer=pcm_s8 \
    --enable-demuxer=wav"

VIDEO_ENCODERS="\
	  --enable-encoder=huffyuv
	  --enable-encoder=ffv1
	  --enable-encoder=mjpeg"

AUDIO_ENCODERS="\
	  --enable-encoder=pcm_s16le"

MUXERS="\
  	--enable-muxer=avi"

PARSERS="\
    --enable-parser=h264 \
    --enable-parser=mpeg4video \
    --enable-parser=mpegvideo \
    --enable-parser=aac \
    --enable-parser=mpegaudio"


./configure \
    --prefix=./linux/${ARCH} \
    ${GENERAL} \
    --extra-cflags="-D__STDC_CONSTANT_MACROS -O3" \
    --enable-zlib \
	--disable-yasm \
    --disable-everything \
    ${MODULES} \
    ${VIDEO_DECODERS} \
    ${AUDIO_DECODERS} \
    ${VIDEO_ENCODERS} \
    ${AUDIO_ENCODERS} \
    ${DEMUXERS} \
    ${MUXERS} \
    ${PARSERS} \
		--arch="riscv64" \

make clean
make install
