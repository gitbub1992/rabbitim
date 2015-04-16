#bash用法：
#   在用一sh进程中执行脚本script.sh:
#   source script.sh
#   . script.sh
#   注意这种用法，script.sh开头一行不能包含 #!/bin/sh

#   新建一个sh进程执行脚本script.sh:
#   sh script.sh
#   ./script.sh
#   注意这种用法，script.sh开头一行必须包含 #!/bin/sh

#注意：修改后的本文件不要上传代码库中
#需要设置下面变量，也可以把它们设置在环境变量中：
#export ANDROID_NDK_ROOT=/home/android-ndk-r9c   #指定 android ndk 根目录
#export ANDROID_NDK=$ANDROID_NDK_ROOT            #指定 android ndk 根目录
#export ANDROID_SDK=/home/android-sdk/sdk        #指定 android sdk 根目录
#export ANDROID_SDK_ROOT=$ANDROID_SDK
#export JAVA_HOME=/home/jdk1.7.0_51              #指定 jdk 根目录

ANT=/usr/bin/ant         #ant 程序
#QT_ROOT=/usr/local/Qt-5.5.0-android         #QT 安装根目录
RABBITIM_MAKE_JOB_PARA="-j2"  #make 同时工作进程参数
JOM=make #/c/Qt/Qt5.3.1/Tools/QtCreator/bin/jom       #设置 QT make 工具 JOM

if [ -z "$ANDROID_NDK_ROOT" -o -z "$ANDROID_NDK" -o -z "$ANDROID_SDK" -o -z "$ANDROID_SDK_ROOT"	-o -z "$JAVA_HOME" ]; then
	echo "Please set ANDROID_NDK_ROOT and ANDROID_NDK and ANDROID_SDK and ANDROID_SDK_ROOT and JAVA_HOME"
	exit 1
fi

#   RABBITIM_BUILD_PREFIX=`pwd`/../${RABBITIM_BUILD_TARGERT}  #修改这里为安装前缀
#   RABBITIM_BUILD_CROSS_PREFIX     #交叉编译前缀
#   RABBITIM_BUILD_CROSS_SYSROOT  #交叉编译平台的 sysroot

if [ -n "${RabbitImRoot}" ]; then
    RABBITIM_BUILD_PREFIX=${RabbitImRoot}/ThirdLibary/android
else
    RABBITIM_BUILD_PREFIX=`pwd`/../android    #修改这里为安装前缀 
fi
if [ ! -d ${RABBITIM_BUILD_PREFIX} ]; then
    mkdir -p ${RABBITIM_BUILD_PREFIX}
fi

#设置qt安装位置
if [ -z "$QT_ROOT" ]; then
        QT_ROOT=${RABBITIM_BUILD_PREFIX}/qt
fi
QT_BIN=${QT_ROOT}/bin       #设置用于 android 平台编译的 qt bin 目录
QMAKE=${QT_BIN}/qmake       #设置用于 unix 平台编译的 QMAKE。
                            #这里设置的是自动编译时的配置，你需要修改为你本地qt编译环境的配置.

#自动判断主机类型，目前只做了linux、windows判断
TARGET_OS=`uname -s`
case $TARGET_OS in
    MINGW* | CYGWIN* | MSYS*)
        RABBITIM_BUILD_HOST="windows"
        #RABBITIM_CMAKE_MAKE_PROGRAM=$ANDROID_NDK/prebuilt/${RABBITIM_BUILD_HOST}/bin/make #这个用不着，只有在windows命令行下才有用
        ;;
    Linux* | Unix*)
        RABBITIM_BUILD_HOST="linux-`uname -m`"    #windows、linux-x86_64
        ;;
    *)
    echo "Please set RABBITIM_BUILD_HOST. see build_envsetup_android.sh"
    return 2
    ;;
esac

RABBITIM_BUILD_TOOLCHAIN_VERSION=4.8   #工具链版本号 
RABBITIM_BUILD_PLATFORMS_VERSION=18 #android api (平台)版本号 

RABBITIM_BUILD_CROSS_PREFIX=$ANDROID_NDK_ROOT/toolchains/arm-linux-androideabi-${RABBITIM_BUILD_TOOLCHAIN_VERSION}/prebuilt/${RABBITIM_BUILD_HOST}/bin/arm-linux-androideabi-
RABBITIM_BUILD_CROSS_SYSROOT=$ANDROID_NDK_ROOT/platforms/android-${RABBITIM_BUILD_PLATFORMS_VERSION}/arch-arm
if [ -z "${RABBITIM_BUILD_CROSS_HOST}" ]; then
	RABBITIM_BUILD_CROSS_HOST=arm-linux-androideabi
fi
export ANDROID_API_VERSION=android-${RABBITIM_BUILD_PLATFORMS_VERSION}
export PATH=${QT_BIN}:$PATH
export PKG_CONFIG=/usr/bin/pkg-config
export PKG_CONFIG_PATH=${RABBITIM_BUILD_PREFIX}/lib/pkgconfig


