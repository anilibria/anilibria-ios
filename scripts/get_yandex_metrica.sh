SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd $SCRIPT_DIR

NAME="YandexMobileMetrica.dynamic.xcframework"
VERSION="4.4.0"
DOWNLOAD_URL="https://github.com/yandexmobile/metrica-sdk-ios/releases/download/${VERSION}/${NAME}.zip"
FRAMEWORKS_FOLDER="../xcframeworks"

mkdir -p $FRAMEWORKS_FOLDER

cd $FRAMEWORKS_FOLDER

curl -LO $DOWNLOAD_URL
tar -xf $NAME".zip"
rm $NAME".zip"