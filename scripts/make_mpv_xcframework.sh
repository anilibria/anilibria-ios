#!/bin/bash -e
set -e

build_modulemap() {
  local FILE_PATH="$1"

  cat >"${FILE_PATH}" <<EOF
module libmpv {
    header "stream_cb.h"
    header "render.h"
    header "render_gl.h"
    header "client.h"
    export *
}
EOF
}

SOURCES=$MPV_LIBS
TMP=$ROOT/tmp
COMBINED=$TMP/libcombined
MODULEMAP=$TMP/module.modulemap

mkdir -p $TMP
build_modulemap $MODULEMAP

IPHONE_LIB=$SOURCES/arm64/lib
IPHONE_HEADERS=$SOURCES/arm64/include/mpv/
SIMULATOR_LIB=$COMBINED/x86_64-arm64-simulator/lib
SIMULATOR_HEADERS=$SOURCES/x86_64/include/mpv/
CATALYST_LIB=$COMBINED/x86_64-arm64-mac-catalyst/lib
CATALYST_HEADERS=$SOURCES/x86_64-mac-catalyst/include/mpv/

cp $MODULEMAP $IPHONE_HEADERS
cp $MODULEMAP $SIMULATOR_HEADERS
cp $MODULEMAP $CATALYST_HEADERS

mkdir -p $SIMULATOR_LIB
mkdir -p $CATALYST_LIB

lipo -create $SOURCES/arm64-simulator/lib/libmpv.a $SOURCES/x86_64/lib/libmpv.a -output $SIMULATOR_LIB/libmpv.a
lipo -create $SOURCES/arm64-mac-catalyst/lib/libmpv.a $SOURCES/x86_64-mac-catalyst/lib/libmpv.a -output $CATALYST_LIB/libmpv.a

xcodebuild -create-xcframework \
    -library $IPHONE_LIB/libmpv.a \
    -headers $IPHONE_HEADERS \
    -library $SIMULATOR_LIB/libmpv.a \
    -headers $SIMULATOR_HEADERS \
    -library $CATALYST_LIB/libmpv.a \
    -headers $CATALYST_HEADERS \
    -output $XCFRAMEWORKS_OUTPUT/MPV.xcframework

rm -r $TMP
rm $IPHONE_HEADERS/module.modulemap
rm $SIMULATOR_HEADERS/module.modulemap
rm $CATALYST_HEADERS/module.modulemap