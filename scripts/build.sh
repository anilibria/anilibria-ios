#!/bin/bash

VERSION="1.0.0"
APP_NAME="Anilibria"

IOS_APP_DIR=./Build/Build/Products/Release-iphoneos
MACOS_APP_DIR=./Build/Build/Products/Release-maccatalyst

IOS_APP=$IOS_APP_DIR/$APP_NAME.app
MACOS_APP=${MACOS_APP_DIR}/${APP_NAME}.app

DMG_CREATOR=/Applications/DMG\ Canvas.app/Contents/Resources/dmgcanvas

while test $# -gt 0; do
    case "$1" in
        -v)
            shift
            VERSION=$1
            shift
            ;;
        *)
            echo "$1 is not a recognized flag!"
            exit 0
        ;;
    esac
done

makeIPA () {
    if [ -d $IOS_APP_DIR ]; then
        rm -rf $IOS_APP_DIR
    fi

    xcodebuild \
        -workspace $APP_NAME.xcworkspace \
        -scheme $APP_NAME \
        -destination "generic/platform=iOS" \
        -configuration Release \
        -derivedDataPath ./Build \
        ARCHS="arm64" \
        IPHONEOS_DEPLOYMENT_TARGET=$TARGET

    if [ ! -d $IOS_APP ]; then
        echo "iOS: Anilibria.app is not found"
        exit 1
    fi

    if [ -d Payload ]; then
        rm -rf Payload
    fi

    mkdir Payload
    mv $IOS_APP ./Payload/$APP_NAME.app
    zip -r ${APP_NAME}_${VERSION}_iOS_${TARGET}.ipa ./Payload/$APP_NAME.app

    if [ -d Payload ]; then
        rm -rf Payload
    fi
}

makeMacOSApp () {
    if [ -d $MACOS_APP_DIR ]; then
        rm -rf $MACOS_APP_DIR
    fi

    xcodebuild \
        -workspace $APP_NAME.xcworkspace \
        -scheme $APP_NAME \
        -destination "generic/platform=macOS" \
        -configuration Release \
        -derivedDataPath ./Build
    
    if [ ! -d $MACOS_APP ]; then
        echo "macOS: Anilibria.app is not found"
        exit 1
    fi

    mv $MACOS_APP "./${APP_NAME} Catalyst.app"
}

cd ..

TARGET=13.0
makeIPA

TARGET=11.2
makeIPA

makeMacOSApp
