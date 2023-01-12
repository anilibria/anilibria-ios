#!/bin/bash -e
set -e

LIB_FOLDERS=(expat libpng libass fontconfig harfbuzz fribidi freetype gmp nettle nettle gnutls gnutls opus)
LIBS=(libexpat libpng16 libass libfontconfig libharfbuzz libfribidi libfreetype libgmp libnettle libhogweed libgnutls libgnutlsxx libopus)
LIBHEADERS=('' libpng16 ass fontconfig harfbuzz fribidi freetype2 '' nettle 'NONE' gnutls 'NONE' opus)

SOURCES=$ROOT/ffmpeg-kit/prebuilt
TMP=$ROOT/tmp
COMBINED=$TMP/libcombined

mkdir -p $TMP

for i in "${!LIBS[@]}"; do
  LIB=${LIBS[i]}
  LIB_FOLDER=${LIB_FOLDERS[i]}
  LIB_HEADERS=${LIBHEADERS[i]}

  IPHONE_LIB=$SOURCES/apple-ios-arm64/$LIB_FOLDER/lib
  SIMULATOR_LIB=$COMBINED/apple-ios-x86_64-arm64-simulator/$LIB_FOLDER/lib
  CATALYST_LIB=$COMBINED/apple-ios-x86_64-arm64-mac-catalyst/$LIB_FOLDER/lib

  mkdir -p $SIMULATOR_LIB
  mkdir -p $CATALYST_LIB

  lipo -create $SOURCES/apple-ios-arm64-simulator/$LIB_FOLDER/lib/$LIB.a $SOURCES/apple-ios-x86_64/$LIB_FOLDER/lib/$LIB.a -output $SIMULATOR_LIB/$LIB.a
  lipo -create $SOURCES/apple-ios-arm64-mac-catalyst/$LIB_FOLDER/lib/$LIB.a $SOURCES/apple-ios-x86_64-mac-catalyst/$LIB_FOLDER/lib/$LIB.a -output $CATALYST_LIB/$LIB.a

if [[ ${LIB_HEADERS} == 'NONE' ]]; then
  xcodebuild -create-xcframework \
    -library $IPHONE_LIB/$LIB.a \
    -library $SIMULATOR_LIB/$LIB.a \
    -library $CATALYST_LIB/$LIB.a \
    -output $XCFRAMEWORKS_OUTPUT/$LIB.xcframework
else
  IPHONE_HEADERS=$SOURCES/apple-ios-arm64/$LIB_FOLDER/include/$LIB_HEADERS
  SIMULATOR_HEADERS=$SOURCES/apple-ios-x86_64/$LIB_FOLDER/include/$LIB_HEADERS
  CATALYST_HEADERS=$SOURCES/apple-ios-x86_64-mac-catalyst/$LIB_FOLDER/include/$LIB_HEADERS

  xcodebuild -create-xcframework \
    -library $IPHONE_LIB/$LIB.a \
    -headers $IPHONE_HEADERS \
    -library $SIMULATOR_LIB/$LIB.a \
    -headers $SIMULATOR_HEADERS \
    -library $CATALYST_LIB/$LIB.a \
    -headers $CATALYST_HEADERS \
    -output $XCFRAMEWORKS_OUTPUT/$LIB.xcframework
fi
  
done

rm -r $TMP