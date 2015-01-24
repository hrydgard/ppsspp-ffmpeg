ppsspp-ffmpeg
=============

A private copy of FFMPEG used in PPSSPP.

Building
========

If on Mac, iOS, Blackberry, Symbian or Linux, just run the corresponding build script
If you are on an ARM Linux device, modify the ARCH used in the Linux script first.


If on Windows and building for Windows, use these instructions:

https://ffmpeg.org/platform.html#Microsoft-Visual-C_002b_002b

Instead of ./configure, just run ./windows_x86-build.sh.


Building for Android on Windows
===============================

  * Install a proper msys environment (don't use the one from msys-git)
  
  * Install: mingw32-base, mingw32-gcc, msys-base, msys-core, msys-coreutils, mingw-developer-tools

	* Install yasm as yasm.exe in mingw/msys/1.0/bin. http://yasm.tortall.net/Download.html

	* CD to the directory and run ./android-build.sh  (first adjust the paths within).


Building for Windows
====================

    mv /mingw/msys/1.0/bin/link.exe /mingw/msys/1.0/bin/mingw_link.exe

  * Start "VS2013 x86 Native Tools Command Prompt"
  * Start msys from within the prompt you get
  * ./windows_x86_build.sh

  * Same three steps for x64 (x64 Native Tools etc)


Building for Mac
================

    brew install yasm
    rm -rf macosx/x86_64
    ./mac_x86-64.sh


Errors
======

If you get `*** missing separator. Stop`, it's a line ending problem.  You can fix
this by running the following commands (WARNING: this will delete all your changes.)

    git config core.autocrlf false
    git rm --cached -r .
    git reset --hard

This won't affect anything other than this repo, though.  See also
[ffmpeg ticket #1209] (https://ffmpeg.org/trac/ffmpeg/ticket/1209).
