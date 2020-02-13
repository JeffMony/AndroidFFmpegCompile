make clean

# export NDK=/home/jeffmony/tools/android-ndk-r18b/android-ndk-r18b
# export PREBUILT=$NDK/toolchains/arm-linux-androideabi-4.8/prebuilt
# export PLATFORM=$NDK/platforms/android-21/arch-arm
# export PREFIX=/home/jeffmony/sources/git/ffmpeg/jeffmony/

./configure --target-os=linux --prefix=$PREFIX \
--enable-cross-compile \
--enable-runtime-cpudetect \
--disable-asm \
--arch=arm \
--cc=$PREBUILT/linux-x86_64/bin/arm-linux-androideabi-gcc \
--cross-prefix=$PREBUILT/linux-x86_64/bin/arm-linux-androideabi- \
--disable-stripping \
--nm=$PREBUILT/linux-x86_64/bin/arm-linux-androideabi-nm \
--sysroot=$PLATFORM \
--enable-gpl --enable-shared --disable-static --enable-small \
--disable-ffprobe --disable-ffplay --disable-ffmpeg --disable-ffserver --disable-debug \
--extra-cflags="-fPIC -DANDROID -D__thumb__ -mthumb -Wfatal-errors -Wno-deprecated -mfloat-abi=softfp -marm -march=armv7-a" 

make
make install
