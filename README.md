欢迎访问站点：[ffmpeg 开源项目分析(一)ffmpeg/openssl/x264编译](https://www.jianshu.com/p/f292a6575d58)

做音视频开发，ffmpeg是绕不过去的开源库，我们要在Android 平台上运行ffmpeg，需要编译一个ffmpeg 动态库；
#### 1.编译环境
ffmpeg源码：https://git.ffmpeg.org/ffmpeg.git
下载下来之后切换到一个release分支，我切换的是n4.0.3分支；每个分支的情况编译都不一样，这个分支的代码尝试编译时可以的，推荐给大家吧；

编译系统：Mac OS X

ndk版本：android-ndk-r14b

#### 2.编译ffmpeg过程
针对Android 平台的，只需要关注armeabi-v7a 和  arm64-v8a 两种平台就可以；
交叉编译主要有4点：
> * 编译架构ARCH，armeabi-v7a 是  arm  ， arm64-v8a 是arm64；
> * 编译平台PLATFORM，armeabi-v7a 是 arm-linux-androideabi， arm64-v8a 是aarch64-linux-android；
> * 系统链接SYSROOT，armeabi-v7a 是`$NDK_ROOT/platforms/android-$API/arch-arm/`， arm64-v8a 是`$NDK_ROOT/platforms/android-$API/arch-arm64/`；
> * 交叉编译工具，`$NDK_ROOT/toolchains/$PLATFORM-4.9/prebuilt/darwin-x86_64/bin/$PLATFORM-`

ffmpeg 有很多configure 配置选项，通过 ./configure --help可以看到全部的ffmpeg 配置选项；
编译之前还要注意一点，如果想让生成的so是标准的so命名规范，还需要改一下configure文件中的配置；
将configure中的几行配置修改一下
```
SLIBNAME_WITH_MAJOR='$(SLIBNAME).$(LIBMAJOR)
```
修改为
```
SLIBNAME_WITH_MAJOR='$(SLIBNAME)-$(LIBMAJOR)$(SLIBSUF)'
```
 将
```
SLIB_INSTALL_NAME='$(SLIBNAME_WITH_VERSION)'
SLIB_INSTALL_LINKS='$(SLIBNAME_WITH_MAJOR) $(SLIBNAME)'
```
修改为
```
SLIB_INSTALL_NAME='$(SLIBNAME_WITH_MAJOR)'
SLIB_INSTALL_LINKS='$(SLIBNAME)'
```
```
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
--enable-cross-compile \
--cross-prefix=$CROSS_PREFIX \
--target-os=android \
--arch=$ARCH \
--sysroot=$SYSROOT
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
```

将这个脚本放在ffmpeg 项目文件下，执行这个脚本，执行完成 ffmpeg/android 目录下生成两个文件夹，分别是 arm和arm64，
里面的文件分别是两个CPU架构下生成的动态库和头文件；
> * include 下面是生成的头文件，通过这些头文件可以引用生成so中的ffmpeg 具体模块的功能；
> * lib 下面是生成的动态库，Android下直接加载这些动态库，pkgconfig 文件夹是pc上的链接文件，我们这里可以忽略；
> * share 文件夹下面是ffmpeg中的例子应用，学习这些例子对理解ffmpeg有很大的帮助；

![](https://upload-images.jianshu.io/upload_images/3768281-7ecd5eabe1f8f85e.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
#### 3.编译openssl过程
先下载openssl库，[https://www.openssl.org/source/snapshot/](https://www.openssl.org/source/snapshot/)
下载最新的：[openssl-1.1.1-stable-SNAP-20200215.tar.gz](https://www.openssl.org/source/snapshot/openssl-1.1.1-stable-SNAP-20200215.tar.gz)
openssl 库中编译配置是 ./Configure 文件
![](https://upload-images.jianshu.io/upload_images/3768281-8c5832008e459fc2.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
openssl的编译选项有点少，我们需要将openssl编译到ffmpeg中，还是选择编译静态库，方便打包；

编译脚本如下：
```
#!/bin/bash
export NDK_ROOT=/Users/tianpeng/tools/android-ndk-r14b # 修改自己本地的ndk路径

build() {
API=24
CPU=$1
PLATFORM=$2
make clean
rm -rf $(pwd)/android/$CPU
export ANDROID_NDK_HOME=$NDK_ROOT
PATH=$ANDROID_NDK_HOME/toolchains/$PLATFORM-4.9/prebuilt/darwin-x86_64/bin:$PATH
./Configure android-$CPU -D__ANDROID_API__=24 no-shared no-ssl2 no-ssl3 no-comp no-hw no-engine --prefix=$(pwd)/android/$CPU --openssldir=$(pwd)/android/$CPU

make
make install
}

# build armv7
build arm arm-linux-androideabi

# build armv8
build arm64 aarch64-linux-android
```
编译完成之后，会在android 文件夹下生成 arm、arm64两个文件夹；
![](https://upload-images.jianshu.io/upload_images/3768281-dfd77e7642df0b6d.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
> * include  下面是 openssl 的核心头文件；
> * lib 下面是编译好的 静态库；
libcrypto.a和libssl.a

#### 4.ffmpeg中引入openssl过程
上面给出了编译openssl静态库的过程，ffmpeg如果想解析https的链接，必须将openssl 编译进 ffmpeg 库中；

在编译ffmpeg的基础上加一些参数：
> * 编译配置中加上   --enable-openssl \ --enable-nonfree
> * 编译链接中加上openssl的链接：-extra-cflags 加上  openssl的头文件；--extra-ldflags 加上 openssl的静态库；

```
#!/bin/bash
export NDK_ROOT=/Users/tianpeng/tools/android-ndk-r14b # 修改自己本地的ndk路径

build() {
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
```
编译过程中发生如下的错误，找不到openssl；
![](https://upload-images.jianshu.io/upload_images/3768281-e150b00888cbeb9e.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

去ffmpeg/configure 文件中查看一下：![](https://upload-images.jianshu.io/upload_images/3768281-ae5deca748e616b0.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)报错的地方在这里，原因是新版本的openssl 需要在configure中新加一个检测语句：![](https://upload-images.jianshu.io/upload_images/3768281-875ccacd68e0aa15.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

```
check_lib openssl openssl/ssl.h OPENSSL_init_ssl -lssl -lcrypto
```
老的openssl库使用‘SSL_library_init’初始化， 新版本openssl使用‘OPENSSL_init_ssl’初始化；

下面正常编译就没有问题了；生成的ffmpeg中的so是可以解析https的；
#### 5.编译x264库
首先下载x264 库；
```
git clone https://code.videolan.org/videolan/x264.git
```
不用切换分支，直接在master分支；
因为需要编进ffmpeg中，所以还是编译静态库；
```
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
```
编译完成后，在android目录下生成不同平台的文件；![](https://upload-images.jianshu.io/upload_images/3768281-ec634ba5ff9849c3.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)生成头文件和对应的静态库；
#### 6.ffmpeg引入x264的过程
上面编译好了x264 静态库，ffmpeg需要加上特定的配置，--enable-libx264，--extra-cflags加上 x264的include头文件，--extra-ldflags加上x264的静态库；
```
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
```
编译出来的库放在android/x264/文件夹下；

所有的编译脚本放在：[https://github.com/JeffMony/AndroidFFmpegCompile](https://github.com/JeffMony/AndroidFFmpegCompile)






