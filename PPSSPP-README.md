ppsspp-ffmpeg
=============

A private copy of FFMPEG used in PPSSPP.

Building
--------

If on Mac, iOS, Blackberry, Symbian or Linux, just run the corresponding build script.

If you are on an ARM Linux device, modify the ARCH used in the Linux script first.

If on Windows and building for Windows, use [these instructions](https://ffmpeg.org/platform.html#Microsoft-Visual-C_002b_002b).

Instead of ./configure, just run ./windows_x86-build.sh.

Building for Android on Windows
-------------------------------

* install msys, or update it (pacman -Suy)

* pacman --sync yasm diffutils

* edit NDK paths in android-arm64-v8a.sh (or whichever one you want to build)

* ./android-arm64-v8a.sh
* ... the others

Building for Windows
--------------------

old:
    mv /mingw/msys/1.0/bin/link.exe /mingw/msys/1.0/bin/mingw_link.exe

new:
    mv /usr/bin/link.exe /usr/bin/ming_link.exe   # to avoid clash with VS link.exe. not sure if still needed
    pacman --sync dos2unix nasm make

* Start "x86 Native Tools Command Prompt for VS 2022"
* Start msys from within the prompt you get
  > msys2_shell.cmd -full-path
* ./windows_x86_build.sh
* Same three steps for x64 (x64 Native Tools etc)

Building for Mac
----------------

    brew install yasm
    rm -rf macosx/x86_64 macosx/universal
    ./mac_build.sh

Errors
------

If you get `*** missing separator. Stop`, it's a line ending problem.  You can fix
this by running the following commands (WARNING: this will delete all your changes.)

    git config core.autocrlf false
    git rm --cached -r .
    git reset --hard

This won't affect anything other than this repo, though.  See also
[ffmpeg ticket #1209](https://ffmpeg.org/trac/ffmpeg/ticket/1209).
