#!/bin/bash

# PLATFORM -----> MAC   LINUX
COMPILE_PLATFORM="MAC"

build_arm() {
API=24
ARCH=$1
PLATFORM=$2
OPENSSL=$(pwd)/openssl_lib/$ARCH
if [ "$COMPILE_PLATFORM" == "MAC" ]
then
    export NDK_ROOT=/Users/jeffli/tools/android-ndk-r14b # 修改自己本地的ndk路径
    SYSROOT=$NDK_ROOT/platforms/android-$API/arch-$ARCH/
    CROSS_PREFIX=$NDK_ROOT/toolchains/$PLATFORM-4.9/prebuilt/darwin-x86_64/bin/$PLATFORM-
else
    export NDK_ROOT=/home/jeffmony/developer/android-ndk-r14b/android-ndk-r14b # 修改自己本地的ndk路径
    SYSROOT=$NDK_ROOT/platforms/android-$API/arch-$ARCH/
    CROSS_PREFIX=$NDK_ROOT/toolchains/$PLATFORM-4.9/prebuilt/linux-x86_64/bin/$PLATFORM-
fi
PREFIX=$(pwd)/android/ffmpeg_lite_lib/$ARCH #自己指定一个输出目录
rm -rf $(pwd)/android/ffmpeg_lite_lib/$ARCH

echo "开始编译ffmpeg $ARCH so"
./configure \
--prefix=$PREFIX \
--disable-gpl \
--disable-doc \
--disable-static \
--disable-x86asm \
--disable-asm \
--disable-symver \
--disable-devices \
--disable-avdevice \
--disable-postproc \
--disable-avfilter \
--disable-avresample \
--disable-ffmpeg \
--disable-ffplay \
--disable-ffprobe \
--disable-programs \
--disable-encoders \
--disable-decoders \
--enable-decoder=h264 \
--enable-decoder=hevc \
--enable-decoder=aac \
--enable-decoder=mp3 \
--disable-muxers \
--enable-muxer=mp4 \
--disable-demuxers \
--enable-demuxer=hls \
--enable-demuxer=mov \
--enable-demuxer=mpegts \
--disable-parsers \
--enable-parser=aac \
--enable-parser=aac_latm \
--enable-parser=ac3 \
--enable-parser=h264 \
--enable-parser=hevc \
--disable-protocols \
--enable-protocol=http \
--enable-protocol=https \
--enable-protocol=crypto \
--enable-protocol=file \
--enable-protocol=hls \
--enable-protocol=tls \
--enable-protocol=tcp \
--enable-shared \
--enable-gpl \
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
OPENSSL=$(pwd)/openssl_lib/$ARCH
if [ "$COMPILE_PLATFORM" == "MAC" ]
then
    export NDK_ROOT=/Users/jeffli/tools/android-ndk-r14b # 修改自己本地的ndk路径
    SYSROOT=$NDK_ROOT/platforms/android-$API/arch-$ARCH/
    CROSS_PREFIX=$NDK_ROOT/toolchains/$ARCH-4.9/prebuilt/darwin-x86_64/bin/$PLATFORM-
else
    export NDK_ROOT=/home/jeffmony/developer/android-ndk-r14b/android-ndk-r14b # 修改自己本地的ndk路径
    SYSROOT=$NDK_ROOT/platforms/android-$API/arch-$ARCH/
    CROSS_PREFIX=$NDK_ROOT/toolchains/$ARCH-4.9/prebuilt/linux-x86_64/bin/$PLATFORM-
fi
PREFIX=$(pwd)/android/ffmpeg_lite_lib/$ARCH #自己指定一个输出目录
rm -rf $(pwd)/android/ffmpeg_lite_lib/$ARCH

echo "开始编译ffmpeg $ARCH so"
./configure \
--prefix=$PREFIX \
--disable-gpl \
--disable-doc \
--disable-static \
--disable-x86asm \
--disable-asm \
--disable-symver \
--disable-devices \
--disable-avdevice \
--disable-postproc \
--disable-avfilter \
--disable-avresample \
--disable-ffmpeg \
--disable-ffplay \
--disable-ffprobe \
--disable-programs \
--disable-encoders \
--disable-decoders \
--enable-decoder=h264 \
--enable-decoder=hevc \
--enable-decoder=aac \
--enable-decoder=mp3 \
--disable-muxers \
--enable-muxer=mp4 \
--disable-demuxers \
--enable-demuxer=hls \
--enable-demuxer=mov \
--enable-demuxer=mpegts \
--disable-parsers \
--enable-parser=aac \
--enable-parser=aac_latm \
--enable-parser=ac3 \
--enable-parser=h264 \
--enable-parser=hevc \
--disable-protocols \
--enable-protocol=http \
--enable-protocol=https \
--enable-protocol=crypto \
--enable-protocol=file \
--enable-protocol=hls \
--enable-protocol=tls \
--enable-protocol=tcp \
--enable-shared \
--enable-gpl \
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