#!/bin/bash
CPU=armv8-a
API=24
ARCH=arm64
X264=$(pwd)/x264/$CPU
PLATFORM=aarch64-linux-android
SYSROOT=$NDK_ROOT/platforms/android-$API/arch-$ARCH/
CROSS_PREFIX=$NDK_ROOT/toolchains/$PLATFORM-4.9/prebuilt/linux-x86_64/bin/$PLATFORM-
PREFIX=$(pwd)/android/$CPU #自己指定一个输出目录
rm -rf $(pwd)/android/$CPU

echo "开始编译ffmpeg $CPU so"
./configure \
--prefix=$PREFIX \
--disable-encoders \
--disable-decoders \
--disable-avdevice \
--disable-static \
--disable-doc \
--disable-ffplay \
--disable-network \
--disable-doc \
--disable-symver \
--enable-neon \
--enable-shared \
--enable-libx264 \
--enable-gpl \
--enable-pic \
--enable-jni \
--enable-pthreads \
--enable-mediacodec \
--enable-encoder=aac \
--enable-encoder=gif \
--enable-encoder=libopenjpeg \
--enable-encoder=libmp3lame \
--enable-encoder=libwavpack \
--enable-encoder=mpeg4 \
--enable-encoder=libx264 \
--enable-encoder=pcm_s16le \
--enable-encoder=png \
--enable-encoder=srt \
--enable-encoder=subrip \
--enable-encoder=yuv4 \
--enable-encoder=text \
--enable-decoder=aac \
--enable-decoder=aac_latm \
--enable-decoder=libopenjpeg \
--enable-decoder=mp3 \
--enable-decoder=mpeg4_mediacodec \
--enable-decoder=pcm_s16le \
--enable-decoder=flac \
--enable-decoder=flv \
--enable-decoder=gif \
--enable-decoder=png \
--enable-decoder=srt \
--enable-decoder=xsub \
--enable-decoder=yuv4 \
--enable-decoder=vp8_mediacodec \
--enable-decoder=hevc_mediacodec \
--enable-ffmpeg \
--enable-bsf=aac_adtstoasc \
--enable-bsf=h264_mp4toannexb \
--enable-bsf=hevc_mp4toannexb \
--enable-bsf=mpeg4_unpack_bframes \
--enable-cross-compile \
--cross-prefix=$CROSS_PREFIX \
--target-os=android \
--arch=$ARCH \
--sysroot=$SYSROOT \
--extra-cflags="-I$X264/include -fPIE -pie" \
--extra-ldflags="-L$X264/lib"

make clean
make -j4
make install

echo "完成编译..."
