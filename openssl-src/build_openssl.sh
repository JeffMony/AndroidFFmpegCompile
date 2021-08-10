#!/bin/bash

# PLATFORM -----> MAC   LINUX
COMPILE_PLATFORM="MAC"

build() {
API=24
CPU=$1
PLATFORM=$2
make clean
rm -rf $(pwd)/android/$CPU
if [ "$COMPILE_PLATFORM" == "MAC" ]
then
    export NDK_ROOT=/Users/jeffli/tools/android-ndk-r14b # 修改自己本地的ndk路径
    export ANDROID_NDK_HOME=$NDK_ROOT
    PATH=$ANDROID_NDK_HOME/toolchains/$PLATFORM-4.9/prebuilt/darwin-x86_64/bin:$PATH
else
    export NDK_ROOT=/home/jeffmony/developer/android-ndk-r14b/android-ndk-r14b # 修改自己本地的ndk路径
    export ANDROID_NDK_HOME=$NDK_ROOT
    PATH=$ANDROID_NDK_HOME/toolchains/$PLATFORM-4.9/prebuilt/linux-x86_64/bin:$PATH
fi

./Configure android-$CPU -D__ANDROID_API__=24 no-shared no-ssl2 no-ssl3 no-comp no-hw no-engine --prefix=$(pwd)/android/$CPU --openssldir=$(pwd)/android/$CPU

make
make install
}

# build armv7
build arm arm-linux-androideabi

# build armv8
build arm64 aarch64-linux-android

# build x86
build x86 x86

# build x86_64
build x86_64 x86_64
