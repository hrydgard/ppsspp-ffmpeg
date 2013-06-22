#!/bin/sh
if [ -z "$EPOCROOT" ]; then
    echo "Could not find your Symbian NDK. Please run ~/QtSDK/Symbian/SDKs/Symbian3Qt474/setenv.sh"
    exit 1
fi

# Copies them to the Symbian LIB dir so that they can be linked directly
for i in symbian/armv6/lib/*.a
	do j=`echo $i | cut -d . -f 1 | cut -c22-`".lib"
	cp $i $EPOCROOT/epoc32/release/armv5/urel/$j
done

echo "Installed Symbian^3 ffmpeg libraries."
