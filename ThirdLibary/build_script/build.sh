#!/bin/sh

#bash用法：
#   在用一sh进程中执行脚本script.sh:
#   source script.sh
#   . script.sh
#   注意这种用法，script.sh开头一行不能包含 #!/bin/sh

#   新建一个sh进程执行脚本script.sh:
#   sh script.sh
#   ./script.sh
#   注意这种用法，script.sh开头一行必须包含 #!/bin/sh

#作者：康林

#参数:
#    $1:编译目标
#    $2:源码的位置 

#运行本脚本前,先运行 build_unix_envsetup.sh 进行环境变量设置,需要先设置下面变量:
#   RABBITIM_BUILD_TARGERT   编译目标（android、windows_msvc、windows_mingw、unix）
#   RABBITIM_BUILD_PREFIX=`pwd`/../${RABBITIM_BUILD_TARGERT}  #修改这里为安装前缀
#   RABBITIM_BUILD_SOURCE_CODE    #源码目录
#   RABBITIM_BUILD_CROSS_PREFIX     #交叉编译前缀
#   RABBITIM_BUILD_CROSS_SYSROOT  #交叉编译平台的 sysroot

set -e
HELP_STRING="Usage $0 PLATFORM (android|windows_msvc|windows_mingw|unix) [SOURCE_CODE_ROOT_DIRECTORY]"

case $1 in
    android|windows_msvc|windows_mingw|unix)
    RABBITIM_BUILD_TARGERT=$1
    ;;
    *)
    echo "${HELP_STRING}"
    return 1
    ;;
esac

#if [ -z "${RABBITIM_BUILD_PREFIX}" ]; then
#    echo ". `pwd`/build_envsetup_${RABBITIM_BUILD_TARGERT}.sh"
#    . `pwd`/build_envsetup_${RABBITIM_BUILD_TARGERT}.sh
#fi

if [ -n "$2" ]; then
    echo "Source dir:$2"
    if [ "${RABBITIM_BUILD_TARGERT}" != "windows_msvc" ]; then
        ./build_speexdsp.sh ${RABBITIM_BUILD_TARGERT}  $2/speexdsp && \
        ./build_speex.sh ${RABBITIM_BUILD_TARGERT} $2/speex && \
        ./build_x264.sh ${RABBITIM_BUILD_TARGERT} $2/x264
    fi
    ./build_openssl.sh ${RABBITIM_BUILD_TARGERT} $2/openssl && \
    ./build_libcurl.sh ${RABBITIM_BUILD_TARGERT} $2/curl && \
    ./build_libvpx.sh ${RABBITIM_BUILD_TARGERT} $2/libvpx && \
    ./build_libyuv.sh ${RABBITIM_BUILD_TARGERT} $2/libyuv && \
    ./build_opencv.sh ${RABBITIM_BUILD_TARGERT} $2/opencv && \
    ./build_ffmpeg.sh ${RABBITIM_BUILD_TARGERT} $2/ffmpeg && \
    ./build_icu.sh ${RABBITIM_BUILD_TARGERT} $2/icu && \
    ./build_qt.sh ${RABBITIM_BUILD_TARGERT} $2/qt5 && \
    ./build_qxmpp.sh ${RABBITIM_BUILD_TARGERT} $2/qxmpp
else
    if [ "${RABBITIM_BUILD_TARGERT}" != "windows_msvc" ]; then
        ./build_speexdsp.sh ${RABBITIM_BUILD_TARGERT} && \
        ./build_speex.sh ${RABBITIM_BUILD_TARGERT} && \
        ./build_x264.sh ${RABBITIM_BUILD_TARGERT}
    fi
    ./build_openssl.sh ${RABBITIM_BUILD_TARGERT} && \
    ./build_libcurl.sh ${RABBITIM_BUILD_TARGERT} && \
    ./build_libvpx.sh ${RABBITIM_BUILD_TARGERT} && \
    ./build_libyuv.sh ${RABBITIM_BUILD_TARGERT} && \
    ./build_opencv.sh ${RABBITIM_BUILD_TARGERT} && \
    ./build_ffmpeg.sh ${RABBITIM_BUILD_TARGERT} && \
    ./build_icu.sh ${RABBITIM_BUILD_TARGERT} && \
    ./build_qt.sh ${RABBITIM_BUILD_TARGERT} && \
    ./build_qxmpp.sh ${RABBITIM_BUILD_TARGERT}
fi
