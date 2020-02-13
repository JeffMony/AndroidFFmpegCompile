# AndroidFFmpegCompile

1.git clone https://git.ffmpeg.org/ffmpeg.git

2.cd ffmpeg

3.git checkout -b local_n4.0.3 n4.0.3

4.修改 configure 文件
将configure中的几行配置修改一下
```
SLIBNAME_WITH_MAJOR='$(SLIBNAME).$(LIBMAJOR)
```
修改为
```
SLIBNAME_WITH_MAJOR='$(SLIBNAME)-$(LIBMAJOR)$(SLIBSUF)'
```
***
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
这是为了编译出的so是Android平台标准的so;

5.设置NDK_ROOT
我本地下载的是android-ndk-r14b
我使用ubuntu 系统编译的;

6.执行 ./build_android.sh all 可以编译所有平台的so<br>
  执行 ./build_android.sh armv7 可以编译armeabi-v7a so<br>
  执行 ./build_android.sh armv7 可以编译arm64-v8a so<br>
