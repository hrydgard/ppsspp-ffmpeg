#!/bin/bash
#ffmpeg for windows x86
#windows_x86-build.sh requements.
# MinGW
# MSYS
# 1. open command-prompt of Visual Studio
# 2. run msys.bat on the command-line.
# 3. $ cd /PathTo/ppsspp/ffmpeg
# 4. $ windows_x86-build.sh
#build requements.
# use toolchain=msvc
# http://ffmpeg.org/platform.html#Windows

AUDIO_DECODERS="
    --enable-decoder=aac
#    --enable-decoder=aac_latm
    --enable-decoder=atrac1
    --enable-decoder=atrac3
    --enable-decoder=mp3
#    --enable-decoder=mp3adu
#    --enable-decoder=mp3adufloat
#    --enable-decoder=mp3float
#    --enable-decoder=mp3on4
#    --enable-decoder=mp3on4float
#    --enable-decoder=libmp3lame
#    --enable-decoder=wmav1
#    --enable-decoder=wmav2
#    --enable-decoder=wmavoice
    --enable-decoder=pcm_s16le
    --enable-decoder=pcm_s8
"

VIDEO_DECODERS="
    --enable-decoder=h264
#    --enable-decoder=h264_crystalhd
#    --enable-decoder=h264_vda
#    --enable-decoder=h264_vdpau
#    --enable-decoder=mpeg4
#    --enable-decoder=mpeg4_crystalhd
#    --enable-decoder=mpeg4_vdpau
    --enable-decoder=mpeg2video
#    --enable-decoder=mpeg2_crystalhd
#    --enable-decoder=mjpeg
#    --enable-decoder=mjpegb
"

AUDIO_ENCODERS="
    --enable-encoder=aac
#    --enable-encoder=libfdk_aac
#    --enable-encoder=libfaac
#    --enable-encoder=libmp3lame
#    --enable-encoder=wmav1
#    --enable-encoder=wmav2
    --enable-encoder=pcm_s16le
    --enable-encoder=pcm_s8
"

VIDEO_ENCODERS="
#    --enable-encoder=libx264
#    --enable-encoder=libx264rgb
    --enable-encoder=mpeg4
#    --enable-encoder=msmpeg4v2
#    --enable-encoder=msmpeg4v3
#    --enable-encoder=libxvid
    --enable-encoder=mpeg2video
#    --enable-encoder=mjpeg
"

HARDWARE_ACCELS="
    --enable-hwaccel=h264_dxva2
#    --enable-hwaccel=h264_vaapi
#    --enable-hwaccel=h264_vda
#    --enable-hwaccel=h264_vdpau
#    --enable-hwaccel=mpeg4_vaapi
#    --enable-hwaccel=mpeg4_vdpau
"

MUXERS="
    --enable-muxer=h264
    --enable-muxer=mp4
#    --enable-muxer=m4v
#    --enable-muxer=asf
#    --enable-muxer=asf_stream
    --enable-muxer=avi
#    --enable-muxer=mpjpeg
#    --enable-muxer=mjpeg
#    --enable-muxer=adts
#    --enable-muxer=latm
    --enable-muxer=mp3
    --enable-muxer=psp
    --enable-muxer=oma
    --enable-muxer=wav
    --enable-muxer=pcm_s16le
    --enable-muxer=pcm_s8

"

DEMUXERS="
    --enable-demuxer=h264
#    --enable-demuxer=m4v
    --enable-demuxer=mpegvideo
#    --enable-demuxer=mjpeg
#    --enable-demuxer=asf
    --enable-demuxer=avi
    --enable-demuxer=aac
#    --enable-demuxer=latm
    --enable-demuxer=oma
#    --enable-demuxer=xwma
    --enable-demuxer=pcm_s16le
    --enable-demuxer=pcm_s8
    --enable-demuxer=wav
"

PARSERS="
    --enable-parser=h264
    --enable-parser=mpeg4video
    --enable-parser=mpegvideo
#    --enable-parser=mjpeg
    --enable-parser=aac
#    --enable-parser=aac_latm
    --enable-parser=mpegaudio
"

PROTOCOLS=""

BSFS="
#    --enable-bsf=aac_adtstoasc
#    --enable-bsf=chomp
#    --enable-bsf=dump_extradata
#    --enable-bsf=h264_mp4toannexb
#    --enable-bsf=mjpeg2jpeg
#    --enable-bsf=mjpega_dump_header
#    --enable-bsf=mp3_header_compress
#    --enable-bsf=mp3_header_decompress
#    --enable-bsf=remove_extradata
"

INPUT_DEVICES="
    --enable-indev=dshow
#    --enable-indev=lavfi
#    --enable-indev=vfwcap
#    --enable-indev=alsa
#    --enable-indev=fbdev
#    --enable-indev=libcdio
#    --enable-indev=libdc1394
#    --enable-indev=oss
#    --enable-indev=pulse
#    --enable-indev=sndio
#    --enable-indev=v4l2
#    --enable-indev=x11grab
#    --enable-indev=openal
"

OUTPUT_DEVICES="
#    --enable-outdev=sdl
"

FILTERS=""

append() {
    var=$1
    shift
    eval "$var=\"\$$var $*\""
}

getparams() {
	eval "value=\"\$$1\""
	ret=""
    value=$(echo "$value" | sed "s/ //g")
	for var in $value ; do
	    if [ ! `echo "$var" | fgrep -o "#"` ]; then
	        ret="$ret $var"
	    fi
	done
	echo "$ret"
}

params_dump() {
	eval "value=\"\$$1\""
    echo "---- dump configure params ----"
    IFS=" "
    for var in $value ; do
        echo "$var"
    done
    echo "---- end dump ----"
}

function build_ffmpeg
{
find ./ -type d -regex "(?:*.mak|Makefile)" | xargs dos2unix

#configure params.
PARAMS="
    --toolchain=msvc
    --prefix=./x86
#    --arch=x86
#    --cpu=opteron-sse3
#    --extra-cflags=""
    --extra-ldflags="-lz"
#    --optflags=""
    --disable-programs
    --disable-avfilter
    --disable-postproc
    --enable-static
    --disable-shared
    --disable-doc
    --enable-zlib
    --disable-pthreads
    --enable-w32threads
    --disable-network
    --disable-everything
    --enable-dxva2
#    --enable-libmp3lame
#     --enable-vaapi
#    --enable-vda
#    --enable-vdpau
"
PARAMS="$(getparams PARAMS)\
$(echo -e "$(getparams AUDIO_DECODERS)")\
$(echo -e "$(getparams VIDEO_DECODERS)")\
$(echo -e "$(getparams AUDIO_ENCODERS)")\
$(echo -e "$(getparams VIDEO_ENCODERS)")\
$(echo -e "$(getparams BSFS)")\
$(echo -e "$(getparams PARSERS)")\
$(echo -e "$(getparams DEMUXERS)")\
$(echo -e "$(getparams MUXERS)")\
$(echo -e "$(getparams HARDWARE_ACCELS)")\
$(echo -e "$(getparams INPUT_DEVICES)")\
"
params_dump PARAMS

echo "---- configure ----"
./configure $PARAMS
echo "---- make clean ----"
make clean
echo "---- make install ----"
make  -j4 install 2>&1 | tee build.log
echo "---- windows_x86-build.sh finished ----"
}
build_ffmpeg

