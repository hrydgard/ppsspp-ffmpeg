#!/bin/sh
#build ffmpeg for all archs and uses lipo to create fat libraries and deletes the originals

set -e

. shared_options.sh
PATH=$(PWD)/gas-preprocessor:$PATH

echo "Building for MacOSX"

ARCHS="arm64 x86_64"

for arch in ${ARCHS}; do
  rm -f config.h

  ffarch=${arch}
  versionmin=10.7
  cpu=generic

  if [[ ${arch} == "arm64" ]]; then
    sdk=macosx
    ffarch=aarch64
    versionmin=11.0
  elif [[ ${arch} == "x86_64" ]]; then
    sdk=macosx
    ffarch=x86_64 #because there's no guarantee that the CPU will be Intel in the future. 
  fi

  ./configure \
    --prefix=./macosx/${arch} \
    --enable-cross-compile \
    --arch=${ffarch} \
    --cc=$(xcrun -f clang) \
    --sysroot="$(xcrun --sdk ${sdk} --show-sdk-path)" \
    --extra-cflags="-arch ${arch} -D__STDC_CONSTANT_MACROS -D_DARWIN_FEATURE_CLOCK_GETTIME=0 -mmacosx-version-min=${versionmin} ${cflags}" \
    ${CONFIGURE_OPTS} \
    --extra-ldflags="-arch ${arch} -isysroot $(xcrun --sdk ${sdk} --show-sdk-path) -mmacosx-version-min=${versionmin}" \
    --target-os=darwin \
    ${extraopts} \
    --cpu=${cpu} \
    --enable-pic

  make clean
  make -j8 install
done

cd macosx
mkdir -p universal/lib

for i in x86_64/lib/*.a; do
  libname=$(basename $i)
  xcrun lipo -create $(
    for a in ${ARCHS}; do
      echo -arch ${a} ${a}/lib/${libname}
    done
  ) -output universal/lib/${libname}
done

cp -r x86_64/include universal/

rm -rf ${ARCHS}
