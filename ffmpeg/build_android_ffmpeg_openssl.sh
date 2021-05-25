#!/bin/bash
export NDK_ROOT=/Users/jeffmony/tools/android-ndk-r14b # 修改自己本地的ndk路径

build_arm() {
API=24
ARCH=$1
PLATFORM=$2
OPENSSL=$(pwd)/openssl/$ARCH
SYSROOT=$NDK_ROOT/platforms/android-$API/arch-$ARCH/
CROSS_PREFIX=$NDK_ROOT/toolchains/$PLATFORM-4.9/prebuilt/darwin-x86_64/bin/$PLATFORM-
PREFIX=$(pwd)/android/openssl/$ARCH #自己指定一个输出目录
rm -rf $(pwd)/android/openssl/$ARCH

echo "开始编译ffmpeg $ARCH so"
./configure \
--prefix=$PREFIX \
--disable-doc \
--enable-shared \
--disable-static \
--disable-x86asm \
--disable-asm \
--disable-symver \
--disable-devices \
--disable-avdevice \
--enable-gpl \
--disable-ffmpeg \
--disable-ffplay \
--disable-ffprobe \
--enable-small \
--enable-openssl \
--enable-nonfree \
--enable-cross-compile \
--cross-prefix=$CROSS_PREFIX \
--target-os=android \
--arch=$ARCH \
--sysroot=$SYSROOT \
--extra-cflags="-I$OPENSSL/include -fPIE -pie" \
--extra-ldflags="-L$OPENSSL/lib"
}

build_arm arm arm-linux-androideabi
make clean
make -j4
make install
echo "完成ffmpeg $ARCH 编译..."

build_arm arm64 aarch64-linux-android
make clean
make -j4
make install
echo "完成ffmpeg $ARCH 编译..."

build_x86() {
API=24
ARCH=$1
PLATFORM=$2
OPENSSL=$(pwd)/openssl/$ARCH
SYSROOT=$NDK_ROOT/platforms/android-$API/arch-$ARCH/
CROSS_PREFIX=$NDK_ROOT/toolchains/$ARCH-4.9/prebuilt/darwin-x86_64/bin/$PLATFORM-
PREFIX=$(pwd)/android/openssl/$ARCH #自己指定一个输出目录
rm -rf $(pwd)/android/openssl/$ARCH

echo "开始编译ffmpeg $ARCH so"
./configure \
--prefix=$PREFIX \
--disable-doc \
--enable-shared \
--disable-static \
--disable-x86asm \
--disable-asm \
--disable-symver \
--disable-devices \
--disable-avdevice \
--enable-gpl \
--disable-ffmpeg \
--disable-ffplay \
--disable-ffprobe \
--enable-small \
--enable-openssl \
--enable-nonfree \
--enable-cross-compile \
--cross-prefix=$CROSS_PREFIX \
--target-os=android \
--arch=$ARCH \
--sysroot=$SYSROOT \
--extra-cflags="-I$OPENSSL/include -fPIE -pie" \
--extra-ldflags="-L$OPENSSL/lib"
}

build_x86 x86 i686-linux-android
make clean
make -j4
make install
echo "完成ffmpeg $ARCH 编译..."

build_x86 x86_64 x86_64-linux-android
make clean
make -j4
make install