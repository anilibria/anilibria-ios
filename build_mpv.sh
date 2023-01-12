#!/bin/bash
set -e

FFMPEG_KIT_TAG=v4.5.1
# MPV_TAG=v0.35.0

export BUILD_ROOT=$PWD
mkdir -p mpv_build
cd mpv_build

export ROOT=$PWD
export MPV_LIBS="$ROOT/mpv_libs"
export FFMPEG_KIT_BUILD_TYPE="ios"
export IOS_MIN_VERSION=13.0
export MAC_CATALYST_MIN_VERSION=14.0
export LDFLAGS
export CFLAGS
export CXXFLAGS
export XCFRAMEWORKS_OUTPUT=$BUILD_ROOT/xcframeworks
export SKIP_ffmpeg_kit=1
export PATH="$(brew --prefix bison)/bin:$PATH"

ORIGINAL_LIBRARY_PATH=$LIBRARY_PATH

ARCHES=(arm64 arm64-simulator x86_64 arm64-mac-catalyst x86_64-mac-catalyst)

echo "--"
echo "fetching resources"
echo "--"
[[ -d ffmpeg-kit ]] || git clone --depth 1 --branch $FFMPEG_KIT_TAG https://github.com/arthenica/ffmpeg-kit.git
# [[ -d mpv ]] || git clone --depth 1 --branch $MPV_TAG https://github.com/mpv-player/mpv.git
[[ -d mpv ]] || git clone https://github.com/mpv-player/mpv.git
cd ffmpeg-kit/src
# [[ -d ffmpeg ]] || git clone --depth 1 --branch n4.4.3 https://github.com/arthenica/FFmpeg
[[ -d gmp ]] || git clone --depth 1 --branch v6.2.0 https://github.com/tanersener/gmp
[[ -d gnutls ]] || git clone --depth 1 --branch 3.6.15.1 https://github.com/tanersener/gnutls && cd gnutls && git submodule update --init && cd ..
# MASKING THE -march=all OPTION WHICH BREAKS THE BUILD ON NEWER XCODE VERSIONS
perl -i -p0e "s|AM_CCASFLAGS =|#AM_CCASFLAGS=|g" ./gnutls/lib/accelerated/aarch64/Makefile.am
cd ../..
echo "--"
echo "fetching completed"
echo "--"

# build ffmpeg
echo "--"
echo "starting ffmpeg build"
echo "--"
cd ffmpeg-kit

CREATE_UNIVERSAL='create_ffmpeg_kit_universal_library.*\n'
CREATE_FRAMEWORK='create_ffmpeg_kit_framework.*\n'
CREATE_XC='create_ffmpeg_kit_xcframework\n'
SKIP=''
BITCODE_1=' -fembed-bitcode -Wc,-fembed-bitcode'
BITCODE_2=' -fembed-bitcode'
BITCODE_3='-fembed-bitcode'

perl -pi -e 's/BITCODE_FLAGS=.*/BITCODE_FLAGS=""/' ./scripts/apple/ffmpeg.sh
perl -i -p0e "s/${CREATE_UNIVERSAL}/${SKIP}/g" ./scripts/function-ios.sh
perl -i -p0e "s/${CREATE_FRAMEWORK}/${SKIP}/g" ./scripts/function-ios.sh
perl -i -p0e "s/${CREATE_XC}/${SKIP}/g" ./scripts/function-ios.sh
perl -i -p0e "s/${BITCODE_1}/${SKIP}/g" ./scripts/function-ios.sh
perl -i -p0e "s/${BITCODE_2}/${SKIP}/g" ./scripts/function-ios.sh
perl -i -p0e "s/${BITCODE_3}/${SKIP}/g" ./scripts/function-ios.sh

sh ./ios.sh --xcframework --disable-armv7 --disable-armv7s --disable-arm64e --enable-dav1d --enable-opus --enable-gnutls --enable-libass --enable-ios-zlib --enable-ios-libiconv --enable-ios-avfoundation --enable-ios-audiotoolbox --enable-ios-videotoolbox 
cd ..
echo "--"
echo "ffmpeg build completed"
echo "--"

# build mpv
echo "--"
echo "starting mpv build"
echo "--"
get_arch() {
  case ${1} in
  x86_64)
    echo "x86-64"
    ;;
  x86_64-mac-catalyst)
    echo "x86-64-mac-catalyst"
    ;;
  *)
    echo "$1"
    ;;
  esac
}

export BASEDIR=$ROOT/ffmpeg-kit
source "${BASEDIR}"/scripts/function.sh
source "${BASEDIR}"/scripts/function-ios.sh

prebuilt_path="$BASEDIR"/prebuilt

for arch in ${ARCHES[*]}
do
    export ARCH=$(get_arch $arch)

    LIBRARY_PATH=$ORIGINAL_LIBRARY_PATH
    path=$prebuilt_path/apple-ios-$arch
    dirs=$(ls -1 $path)
    for dir in ${dirs[*]}
    do
        if [ $dir != "pkgconfig" ]; then
          echo $path/$dir/lib
	        export LIBRARY_PATH=$path/$dir/lib:$LIBRARY_PATH
          export PKG_CONFIG_LIBDIR=$path/$dir/lib/pkgconfig:$PKG_CONFIG_LIBDIR
        else
          echo $path/$dir
          export PKG_CONFIG_LIBDIR=$path/$dir:$PKG_CONFIG_LIBDIR
        fi
    done
    export SDK_PATH=$(get_sdk_path)
    export CFLAGS=$(get_cflags)
    export CXXFLAGS=$(get_cxxflags)
    export LDFLAGS=$(get_ldflags)

    cd mpv
    OPTS="--prefix=$MPV_LIBS/$arch \
	        --exec-prefix=$MPV_LIBS/$arch \
          --disable-iconv  \
	        --disable-cplayer \
	        --disable-lcms2 \
	        --disable-lua \
	        --disable-rubberband \
	        --disable-zimg \
	        --disable-javascript \
	        --disable-libbluray \
          --disable-jpeg \
	        --disable-vapoursynth \
          --disable-manpage \
	        --enable-libmpv-static \
	        --enable-gl \
          --enable-lgpl"

  ./bootstrap.py
  ./waf configure $OPTS
  ./waf build -j4
  ./waf install
  cd ..
done
echo "--"
echo "mpv build completed"
echo "--"

echo "--"
echo "making xcframeworks"
echo "--"
# create xcframeworks
mkdir -p $XCFRAMEWORKS_OUTPUT
sh $BUILD_ROOT/scripts/make_mpv_xcframework.sh
sh $BUILD_ROOT/scripts/make_xcframeworks.sh

# # copy xcframeworks
FRAMEWORKS=(libavcodec.xcframework
libavdevice.xcframework
libavfilter.xcframework
libavformat.xcframework
libavutil.xcframework
libswresample.xcframework
libswscale.xcframework)

for framework in ${FRAMEWORKS[*]}; do
  cp -R $prebuilt_path/bundle-apple-xcframework-ios/$framework $XCFRAMEWORKS_OUTPUT/$framework
done

echo "--"
echo "xcframeworks were made"
echo "--"