#!/bin/bash
export NDK_ROOT=/Users/tianpeng/tools/android-ndk-r14b # 修改自己本地的ndk路径

build() {
API=24
ARCH=$1
PLATFORM=$2
X264=$(pwd)/x264/$ARCH
SYSROOT=$NDK_ROOT/platforms/android-$API/arch-$ARCH/
CROSS_PREFIX=$NDK_ROOT/toolchains/$PLATFORM-4.9/prebuilt/darwin-x86_64/bin/$PLATFORM-
PREFIX=$(pwd)/android/x264/$ARCH #自己指定一个输出目录
rm -rf $(pwd)/android/x264/$ARCH

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
--enable-libx264 \
--enable-cross-compile \
--cross-prefix=$CROSS_PREFIX \
--target-os=android \
--arch=$ARCH \
--sysroot=$SYSROOT \
--extra-cflags="-I$X264/include -fPIE -pie" \
--extra-ldflags="-L$X264/lib"
}

# build armv7a
build arm arm-linux-androideabi
make clean
make -j4
make install

echo "完成ffmpeg $ARCH 编译..."


# build armv8a
build arm64 aarch64-linux-android
make clean
make -j4
make install

echo "完成ffmpeg $ARCH 编译..."