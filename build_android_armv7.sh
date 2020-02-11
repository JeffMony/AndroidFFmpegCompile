#!/bin/bash
CPU=armv7-a
API=24
ARCH=arm
PLATFORM=arm-linux-androideabi
SYSROOT=$NDK_ROOT/platforms/android-$API/arch-$ARCH/
CROSS_PREFIX=$NDK_ROOT/toolchains/$PLATFORM-4.9/prebuilt/darwin-x86_64/bin/$PLATFORM-
PREFIX=/Users/tianpeng/sources/libs/$CPU #自己指定一个输出目录

echo "开始编译ffmpeg $CPU so"
./configure \
--prefix=$PREFIX \
--enable-shared \
--disable-static \
--disable-doc \
--disable-ffmpeg \
--disable-ffplay \
--disable-ffprobe \
--disable-avdevice \
--disable-doc \
--disable-symver \
--cross-prefix=$CROSS_PREFIX \
--target-os=android \
--arch=$ARCH \
--enable-cross-compile \
--sysroot=$SYSROOT \
--extra-cflags="-I$NDK_ROOT/sysroot/usr/include/$PLATFORM -isysroot $NDK_ROOT/sysroot -Os -fpic -march=$CPU -mfloat-abi=softfp -mfpu=neon" \
$ADDITIONAL_CONFIGURE_FLAG

make clean
make
make install

echo "完成编译..."
