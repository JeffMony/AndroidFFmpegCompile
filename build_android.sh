#!/bin/bash
ADDI_CFLAGS="-marm"
API=24
PLATFORM=arm-linux-androideabi
CPU=armv7-a
NDK=/Users/tianpeng/tools/android-ndk-r14b # 修改自己本地的ndk路径
SYSROOT=$NDK/platforms/android-$API/arch-arm/
ISYSROOT=$NDK/sysroot
ASM=$ISYSROOT/usr/include/$PLATFORM
TOOLCHAIN=$NDK/toolchains/$PLATFORM-4.9/prebuilt/darwin-x86_64
OUTPUT=/Users/tianpeng/sources/libs #自己指定一个输出目录
function build_one
{
./configure \
--prefix=$OUTPUT \
--enable-shared \
--disable-static \
--disable-doc \
--disable-ffmpeg \
--disable-ffplay \
--disable-ffprobe \
--disable-avdevice \
--disable-doc \
--disable-symver \
--cross-prefix=$TOOLCHAIN/bin/arm-linux-androideabi- \
--target-os=android \
--arch=arm \
--enable-cross-compile \
--sysroot=$SYSROOT \
--extra-cflags="-I$ASM -isysroot $ISYSROOT -Os -fpic -marm" \
--extra-ldflags="-marm" \
$ADDITIONAL_CONFIGURE_FLAG
  make clean
  make 
  make install
}
echo "开始编译ffmpeg..."
build_one
echo "完成编译..."
