#!/bin/bash

mkdir -p Output/Windows10/ARM64

cd Output/Windows10/ARM64

../../../configure \
--toolchain=msvc \
--disable-programs \
--disable-d3d11va \
--disable-dxva2 \
--arch=aarch64 \
--enable-static \
--disable-shared \
--enable-cross-compile \
--target-os=win32 \
--extra-cflags="-MD -DWINAPI_FAMILY=WINAPI_FAMILY_APP -D_WIN32_WINNT=0x0A00" \
--extra-ldflags="-APPCONTAINER WindowsApp.lib" \
--prefix=../../../Windows10/ARM64

make

make install
