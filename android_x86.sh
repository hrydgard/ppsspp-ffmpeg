#!/bin/bash
#Change NDK to your Android NDK location
if [ "$NDK" = "" ]; then
    NDK=/c/AndroidNDK
fi
if [ "$NDK_PLATFORM" = "" ]; then
    NDK_PLATFORM=$NDK/platforms/android-14/arch-x86
fi
if [ "$NDK_PREBUILT" = "" ]; then
    NDK_PREBUILT=$NDK/toolchains/x86-4.9/prebuilt/windows-x86_64
    NDK_PREBUILTLLVM=$NDK/toolchains/llvm/prebuilt/windows-x86_64
fi

set -e

# The --disable asm flag is very unfrotunate here and only needed for x86.
# This is now required because text relocations are no longer allowed on Android.
GENERAL="\
   --enable-cross-compile \
   --enable-pic \
   --disable-asm \
   --extra-libs="-latomic" \
   --cc=$NDK_PREBUILTLLVM/bin/clang \
   --cross-prefix=$NDK_PREBUILT/bin/i686-linux-android- \
   --ld=$NDK_PREBUILTLLVM/bin/clang \
   --nm=$NDK_PREBUILT/bin/i686-linux-android-nm"

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
	  --enable-encoder=huffyuv
	  --enable-encoder=ffv1"

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

function build_x86
{
./configure --logfile=conflog.txt --target-os=linux \
    --prefix=./android/x86 \
    --arch=x86 \
    ${GENERAL} \
    --extra-cflags=" --target=i686-linux-android -O3 -DANDROID -Dipv6mr_interface=ipv6mr_ifindex -fasm -fno-short-enums -fno-strict-aliasing -fomit-frame-pointer -march=k8" \
    --disable-shared \
    --enable-static \
    --extra-ldflags=" -B$NDK_PREBUILT/bin/i686-linux-android- --target=i686-linux-android -Wl,--rpath-link,$NDK_PLATFORM/usr/lib -L$NDK_PLATFORM/usr/lib -L$NDK_PREBUILT/i686-linux-android/lib -nostdlib -lc -lm -ldl -llog" \
    --enable-zlib \
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
make -j4 install
}

build_x86
