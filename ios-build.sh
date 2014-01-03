#!/bin/bash
#build ffmpeg for armv7,armv7s and uses lipo to create fat libraries and deletes the originals
PLATFORM=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/

GENERAL="\
   --enable-cross-compile \
   --arch=arm \
   --cc=$PLATFORM/usr/bin/gcc"

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

PARSERS="\
    --enable-parser=h264 \
    --enable-parser=mpeg4video \
    --enable-parser=mpegaudio \
    --enable-parser=mpegvideo \
    --enable-parser=aac \
    --enable-parser=aac_latm"

VIDEO_ENCODERS="\
	  --enable-encoder=mjpeg"

AUDIO_ENCODERS="\
	  --enable-encoder=pcm_s16le"

MUXERS="\
  	--enable-muxer=avi"


./configure \
    --prefix=ios/armv7 \
    $GENERAL \
    --sysroot="$PLATFORM/SDKs/iPhoneOS6.1.sdk" \
    --extra-cflags="-arch armv7 -mfpu=neon -miphoneos-version-min=6.0" \
    --disable-shared \
    --enable-static \
    --extra-ldflags="-arch armv7 -isysroot $PLATFORM/SDKs/iPhoneOS6.1.sdk -miphoneos-version-min=6.0" \
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
    --target-os=darwin \
    --enable-vfp \
    --enable-neon \
    --cpu=cortex-a8 \
    --enable-pic

make clean
make && make install

if [ "$?" != "0" ]; then
    exit 1;
fi

./configure \
    --prefix=ios/armv7s \
    $GENERAL \
    --sysroot="$PLATFORM/SDKs/iPhoneOS6.1.sdk" \
    --extra-cflags="-arch armv7s -mfpu=neon -miphoneos-version-min=6.0" \
    --disable-shared \
    --enable-static \
    --extra-ldflags="-arch armv7s -isysroot $PLATFORM/SDKs/iPhoneOS6.1.sdk -miphoneos-version-min=6.0" \
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
    --target-os=darwin \
    --enable-vfp \
    --enable-neon \
    --cpu=cortex-a9 \
    --enable-pic

make clean
make && make install

if [ "$?" != "0" ]; then
    exit 1;
fi

cd ios
mkdir -p universal/lib


xcrun -sdk iphoneos lipo -create -arch armv7 armv7/lib/libavformat.a -arch armv7s armv7s/lib/libavformat.a -output universal/lib/libavformat.a

xcrun -sdk iphoneos lipo -create -arch armv7 armv7/lib/libavutil.a -arch armv7s armv7s/lib/libavutil.a -output universal/lib/libavutil.a

xcrun -sdk iphoneos lipo -create -arch armv7 armv7/lib/libswresample.a -arch armv7s armv7s/lib/libswresample.a -output universal/lib/libswresample.a

xcrun -sdk iphoneos lipo -create -arch armv7 armv7/lib/libavcodec.a -arch armv7s armv7s/lib/libavcodec.a -output universal/lib/libavcodec.a

xcrun -sdk iphoneos lipo -create -arch armv7 armv7/lib/libswscale.a -arch armv7s armv7s/lib/libswscale.a -output universal/lib/libswscale.a

xcrun -sdk iphoneos lipo -create -arch armv7 armv7/lib/libavdevice.a -arch armv7s armv7s/lib/libavdevice.a -output universal/lib/libavdevice.a

cp -r armv7/include universal/

rm -rf armv7 armv7s
