#!/bin/sh
# Prepares the React Native for OpenHarmony example: copies in what is shared with the iOS/Android example (the
# library, the Tags page, the Lottie files), runs RNOH's codegen and bundles the JS. Then build harmony/ with hvigor.
# Usage (from harmony-example/): npm install --legacy-peer-deps && sh scripts/setup.sh. Metro needs Node 20+.
set -eu
HERE=$(cd "$(dirname "$0")/.." && pwd)
LIB="$HERE/.."
REPO="$LIB/../.."
cd "$HERE"

# The library, as an npm package would install it (its spec drives codegen).
rm -rf node_modules/react-native-cyl-tag-list
mkdir -p node_modules/react-native-cyl-tag-list specs src
cp -R "$LIB/src" node_modules/react-native-cyl-tag-list/
rm -rf node_modules/react-native-cyl-tag-list/src/__tests__
printf '{"name":"react-native-cyl-tag-list","version":"0.1.0","main":"src/index.tsx","react-native":"src/index.tsx"}\n' \
  > node_modules/react-native-cyl-tag-list/package.json
cp "$LIB/src/CylTagListViewNativeComponent.ts" specs/

# The Tags page of the iOS/Android example, unchanged.
for f in TagListPage.tsx Slider.tsx i18n.ts; do cp "$LIB/example/src/$f" src/; done

# The Lottie files the tags play (rawfiles, as in harmony/entry).
mkdir -p harmony/entry/src/main/resources/rawfile
cp "$REPO"/harmony/entry/src/main/resources/rawfile/tab_*.json harmony/entry/src/main/resources/rawfile/

npx react-native codegen-harmony --no-safety-check \
  --cpp-output-path ./harmony/entry/src/main/cpp/generated --ets-output-path ./harmony/entry/src/main/ets/generated
npx react-native bundle-harmony --dev false

# RNOH 0.86.1 calls a WebSocket API of API 26 behind a run-time check; this cast lets it compile on API 21 SDKs.
if [ -d harmony/oh_modules ]; then
  find harmony/oh_modules/.ohpm -path '*turboModules/WebSocketTurboModule.ts' -exec sed -i '' \
    "s/      ws.on('openInfo', (err: BusinessError, value: webSocket.WebSocketOpenInfo) => {/      (ws as ESObject).on('openInfo', (err: BusinessError, value: ESObject) => {/" {} \;
fi
