#!/bin/bash
export NDK_ROOT=/Users/tianpeng/tools/android-ndk-r14b # 修改自己本地的ndk路径

build() {
API=24
ARCH=$1
PLATFORM=$2
SYSROOT=$NDK_ROOT/platforms/android-$API/arch-$ARCH/
CROSS_PREFIX=$NDK_ROOT/toolchains/$PLATFORM-4.9/prebuilt/darwin-x86_64/bin/$PLATFORM-
PREFIX=$(pwd)/android/$ARCH #自己指定一个输出目录
rm -rf $(pwd)/android/$ARCH

if [ "$ARCH" == "arm" ];
then
    HOST=arm-linux
elif [ "$ARCH" == "arm64" ];
then
    HOST=aarch64-linux
fi

./configure \
--prefix=$PREFIX \
--host=$HOST \
--enable-pic \
--disable-asm \
--enable-static \
--cross-prefix=$CROSS_PREFIX \
--sysroot=$SYSROOT
}

# build armv7a
build arm arm-linux-androideabi
make clean
make -j4
make install

# build armv8a
build arm64 aarch64-linux-android
make clean
make -j4
make install
