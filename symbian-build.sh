#!/bin/bash
#Download Symbian Linux SDK: https://projects.developer.nokia.com/symbian_linux_qtsdk/files/testinstaller_scp1.2_v201109271138_238.x32.run.7z
if [ -z "$EPOCROOT" ]; then
    echo "Could not find your Symbian NDK. Please run ~/QtSDK/Symbian/SDKs/SymbianSR1Qt474/setenv.sh"
    exit 1
fi
echo "Building for Symbian^3"
#Download xsacha's Symbian GCC 4.8.3 for Linux
#Change COMPILERROOT to your compiler dir
COMPILERROOT=~/Downloads/tools/gcc4.8.3_x86-64

EPOCLIB=$EPOCROOT/epoc32/release/armv5
EPOCINC=$EPOCROOT/epoc32/include

set -e

GENERAL="\
   --enable-cross-compile \
   --arch=armv6zk \
   --cpu=arm1176jzf-s \
   --sysinclude=$EPOCINC \
   --cc=$COMPILERROOT/bin/arm-none-symbianelf-gcc \
   --cross-prefix=$COMPILERROOT/bin/arm-none-symbianelf- \
   --nm=$COMPILERROOT/bin/arm-none-symbianelf-nm"

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


./configure --target-os=symbian \
    --prefix=./symbian/armv6 \
    ${GENERAL} \
    --extra-cflags="-D__EPOC32__ -D__MARM_ARMV5__ -D__EABI__ -D__SUPPORT_CPP_EXCEPTIONS__ -nostdinc -I $EPOCINC -I $EPOCINC/platform -I $EPOCINC/stdapis -I $EPOCINC/stdapis/sys -I $EPOCINC/stdapis/stlportv5 -I $EPOCINC/stdapis/stlportv5/stl -O3 -Wno-psabi -fno-short-enums -fno-strict-aliasing -finline-limit=300 -DHAVE_UNISTD_H -mfloat-abi=softfp -mfpu=vfp -marm" \
    --disable-shared \
    --enable-static \
    --extra-ldflags="-Wl,-rpath-link=$EPOCLIB/lib -L$EPOCLIB/lib -L$EPOCLIB/urel -L$COMPILERROOT/arm-none-symbianelf/lib -nostdlib" \
    --disable-everything \
    ${MODULES} \
    ${VIDEO_DECODERS} \
    ${AUDIO_DECODERS} \
    ${VIDEO_ENCODERS} \
    ${AUDIO_ENCODERS} \
    ${DEMUXERS} \
    ${MUXERS} \
    ${PARSERS} \
    --disable-neon && \
make clean && \
make install && for i in symbian/armv6/lib/*.a;	do j=`echo $i | cut -d . -f 1 | cut -c22-`".lib"; mv $i symbian/armv6/lib/$j; done
