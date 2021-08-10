#!/bin/bash
export NDK_ROOT=/Users/jeffli/tools/android-ndk-r14b # 修改自己本地的ndk路径

build() {
API=24
CPU=$1
PLATFORM=$2
DISABLE_ASM=
make clean
PREFIX=$(pwd)/android/$CPU #自己指定一个输出目录
rm -rf $(pwd)/android/$CPU

COMPILE_PLATFORM=

if [ "$CPU" == "arm" ];
then
    COMPILE_PLATFORM=$PLATFORM
elif [ "$CPU" == "arm64" ];
then
    COMPILE_PLATFORM=$PLATFORM
elif [ "$CPU" == "x86" ];
then
    COMPILE_PLATFORM=i686-linux-android
elif [ "$CPU" == "x86_64" ];
then
    COMPILE_PLATFORM=x86_64-linux-android
fi

SYSROOT=$NDK_ROOT/platforms/android-$API/arch-$CPU/
CROSS_PREFIX=$NDK_ROOT/toolchains/$PLATFORM-4.9/prebuilt/darwin-x86_64/bin/$COMPILE_PLATFORM-


if [ "$CPU" == "arm" ];
then
    HOST=arm-linux
elif [ "$CPU" == "arm64" ];
then
    HOST=aarch64-linux
elif [ "$CPU" == "x86" ];
then 
    HOST=i686-linux
    DISABLE_ASM=--disable-asm
elif [ "$CPU" == "x86_64" ];
then
    HOST=x86_64-linux
    DISABLE_ASM=--disable-asm
fi


./configure \
--prefix=$PREFIX \
--host=$HOST \
--enable-static \
--enable-pic \
--enable-strip \
--disable-cli \
--disable-opencl \
--disable-interlaced \
--disable-avs \
--disable-swscale \
--disable-lavf \
--disable-ffms \
--disable-gpac \
$DISABLE_ASM \
--cross-prefix=$CROSS_PREFIX \
--sysroot=$SYSROOT

make
make install
}

# build armv7a
build arm arm-linux-androideabi

# build armv8a
build arm64 aarch64-linux-android

# build x86
build x86 x86

# build x86_64
build x86_64 x86_64
