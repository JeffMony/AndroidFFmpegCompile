# !/bin/bash

export NDK_ROOT=/home/jeffmony/tools/android-ndk-r14b # 修改自己本地的ndk路径

configure()
{
    CPU=$1
    API=24
    PREFIX=$(pwd)/android/$CPU
    HOST=""
    CROSS_PREFIX=""
    SYSROOT=""
    if [ "$CPU" == "armv7-a" ]
    then
        HOST=arm-linux
        SYSROOT=$NDK_ROOT/platforms/android-$API/arch-arm/
        CROSS_PREFIX=$NDK_ROOT/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64/bin/arm-linux-androideabi-
    else
        HOST=aarch64-linux
        SYSROOT=$NDK_ROOT/platforms/android-$API/arch-arm64/
        CROSS_PREFIX=$NDK_ROOT/toolchains/aarch64-linux-android-4.9/prebuilt/linux-x86_64/bin/aarch64-linux-android-
    fi
    ./configure \
    --prefix=$PREFIX \
    --host=$HOST \
    --enable-pic \
    --disable-asm \
    --enable-static \
    --enable-neon \
    --extra-cflags="-fPIE -pie" \
    --extra-ldflags="-fPIE -pie" \
    --cross-prefix=$CROSS_PREFIX \
    --sysroot=$SYSROOT
}

build()
{
    make clean
    cpu=$1
    echo "build $cpu"

    configure $cpu
    make -j4
    make install
}

build arm64
build armv7-a