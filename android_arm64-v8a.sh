#!/bin/bash

# Run this inside git bash.

BUILD_ANDROID_PLATFORM="21"

HOST_TAG="windows-x86_64"

#TRIPLE="armv7a-linux-androideabi"
TRIPLE="aarch64-linux-android"
#TRIPLE="x86_64-linux-android"

TARGET="$TRIPLE$BUILD_ANDROID_PLATFORM"

# Change NDK to your Android NDK location if needed
if [ "$NDK" = "" ]; then
    NDK=/c/Android/sdk/ndk/27.2.12479018
fi
if [ "$NDK_USR_LIB" = "" ]; then
    NDK_USR_LIB=$NDK/toolchains/llvm/prebuilt/$HOST_TAG/sysroot/usr/lib/$TRIPLE/$BUILD_ANDROID_PLATFORM
fi
if [ "$NDK_PREBUILT" = "" ]; then
    NDK_PREBUILT=$NDK/toolchains/llvm/prebuilt/$HOST_TAG
fi

set -e

GENERAL="\
   --enable-cross-compile \
   --enable-pic \
   --extra-libs="-latomic" \
   --cc=$NDK_PREBUILT/bin/clang \
   --ld=$NDK_PREBUILT/bin/clang \
   --nm=$NDK_PREBUILT/bin/llvm-nm \
   --ar=$NDK_PREBUILT/bin/llvm-ar \
   --ranlib=$NDK_PREBUILT/bin/llvm-ranlib"

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
    --enable-decoder=mp3 \
    --enable-decoder=pcm_s16le \
    --enable-decoder=pcm_s8"

# No longer needed!
#    --enable-decoder=atrac3 \
#    --enable-decoder=atrac3p \

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

function build_arm64
{

    # no-missing-prototypes because of a compile error seemingly unique to aarch64.
./configure \
    --logfile=conflog.txt \
    --target-os=linux \
    --prefix=./android/arm64 \
    --arch=aarch64 \
    ${GENERAL} \
    --extra-cflags=" --target=$TARGET -no-canonical-prefixes -fdata-sections -ffunction-sections -fno-limit-debug-info -funwind-tables -fPIC -O2 -DCONFIG_PIC -DANDROID -DANDROID_PLATFORM=android-$BUILD_ANDROID_PLATFORM -Dipv6mr_interface=ipv6mr_ifindex -fasm -fno-short-enums -fno-strict-aliasing -Wno-missing-prototypes" \
    --disable-shared \
    --enable-static \
    --extra-ldflags="--target=$TARGET -Wl,-Bsymbolic -Wl,--rpath-link,$NDK_USR_LIB -L$NDK_USR_LIB -nostdlib -lc -lm -ldl -llog" \
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
make -j8 install
}

build_arm64


# NOTE: Ran into this relocation problem:
# https://lists.ffmpeg.org/pipermail/ffmpeg-devel/2022-July/298734.html