#!/bin/bash
set -e

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd $SCRIPT_DIR
cd ..

APP_NAME="AniLiberty"

IOS_APP_DIR=./Build/Build/Products/Release-iphoneos
MACOS_APP_DIR=./Build/Build/Products/Release-maccatalyst

IOS_APP=$IOS_APP_DIR/$APP_NAME.app
MACOS_APP=${MACOS_APP_DIR}/${APP_NAME}.app

IOS_DSYM=$IOS_APP_DIR/$APP_NAME.app.dSYM

VERSION=$(xcodebuild -showBuildSettings | grep MARKETING_VERSION | tr -d 'MARKETING_VERSION =')
echo $VERSION


makeIPA () {
    if [ -d $IOS_APP_DIR ]; then
        rm -rf $IOS_APP_DIR
    fi

    xcodebuild \
        -scheme $APP_NAME \
        -destination "generic/platform=iOS" \
        -configuration Release \
        -derivedDataPath ./Build \
        ARCHS="arm64" \
        IPHONEOS_DEPLOYMENT_TARGET=$TARGET

    if [ ! -d $IOS_APP ]; then
        echo "iOS: $APP_NAME.app is not found"
        exit 1
    fi

    if [ ! -d $IOS_DSYM ]; then
        echo "iOS: dSYM is not found"
        exit 1
    fi

    if [ -d Payload ]; then
        rm -rf Payload
    fi

    mkdir Payload
    mv $IOS_APP ./Payload/$APP_NAME.app
    mv $IOS_DSYM ./$APP_NAME.app.dSYM
    zip -r ${APP_NAME}_iOS.ipa ./Payload/$APP_NAME.app
    zip -r ${APP_NAME}.dSYM.zip ./$APP_NAME.app.dSYM

    if [ -d Payload ]; then
        rm -rf Payload
    fi
}

makeMacOSApp () {
    if [ -d $MACOS_APP_DIR ]; then
        rm -rf $MACOS_APP_DIR
    fi

    if [ -d $APP_NAME\ Catalyst.app ]; then
        rm -rf $APP_NAME\ Catalyst.app
    fi

    xcodebuild \
        -scheme $APP_NAME \
        -destination "generic/platform=macOS" \
        -configuration Release \
        -derivedDataPath ./Build
    
    if [ ! -d $MACOS_APP ]; then
        echo "macOS: $APP_NAME.app is not found"
        exit 1
    fi

    mv $MACOS_APP $APP_NAME\ Catalyst.app
    create-dmg  ${APP_NAME}_macOS.dmg $APP_NAME\ Catalyst.app

    if [ -d $APP_NAME\ Catalyst.app ]; then
        rm -rf $APP_NAME\ Catalyst.app
    fi
}

TARGET=13.0
makeIPA
makeMacOSApp