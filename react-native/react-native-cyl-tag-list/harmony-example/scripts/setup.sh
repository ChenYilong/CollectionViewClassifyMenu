#!/bin/sh
# Prepares the React Native for OpenHarmony example: fetches CYLTabBarController's HarmonyOS library (the tab bar) at
# its pinned commit, copies in what is shared with the iOS/Android example (the library, the Tags and Classify pages,
# the Lottie files, the shared database), runs RNOH's codegen and bundles the JS. Then build harmony/ with hvigor.
# Usage (from harmony-example/): npm install --legacy-peer-deps && sh scripts/setup.sh. Metro needs Node 20+.
set -eu
HERE=$(cd "$(dirname "$0")/.." && pwd)
LIB="$HERE/.."
REPO="$LIB/../.."
cd "$HERE"

# CYLTabBarController's HarmonyOS library at the newest commit that has what the example needs: the plus button read
# from the configuration (CYLTabBarController PR #796, branch feat/harmonyos-plus-button-configuration, into
# feat/harmonyos-component; CrossPlatform/harmonyos-cyltabbar is on no other branch yet).
CYL_TAB_BAR_COMMIT=08073a46084e1694ad9344050e2d5c06c3e6ce10
if [ ! -d .deps/CYLTabBarController ]; then
  mkdir -p .deps
  git clone -q --filter=blob:none --no-checkout https://github.com/ChenYilong/CYLTabBarController.git .deps/CYLTabBarController
  git -C .deps/CYLTabBarController sparse-checkout set --no-cone CrossPlatform/harmonyos-cyltabbar/cyltabbar
fi
git -C .deps/CYLTabBarController fetch -q origin "$CYL_TAB_BAR_COMMIT" 2>/dev/null || true
git -C .deps/CYLTabBarController checkout -q "$CYL_TAB_BAR_COMMIT"

# The library, as an npm package would install it (its spec drives codegen).
rm -rf node_modules/react-native-cyl-tag-list
mkdir -p node_modules/react-native-cyl-tag-list specs src
cp -R "$LIB/src" node_modules/react-native-cyl-tag-list/
rm -rf node_modules/react-native-cyl-tag-list/src/__tests__
printf '{"name":"react-native-cyl-tag-list","version":"0.1.0","main":"src/index.tsx","react-native":"src/index.tsx"}\n' \
  > node_modules/react-native-cyl-tag-list/package.json
cp "$LIB/src/CylTagListViewNativeComponent.ts" specs/

# The pages of the iOS/Android example, unchanged.
for f in TagListPage.tsx Slider.tsx i18n.ts ClassifyPage.tsx PlacesDatabase.ts launchOptions.ts; do
  cp "$LIB/example/src/$f" src/
done

# The Lottie files the tags play (rawfiles, as in harmony/entry) and the shared database of the Classify page.
mkdir -p harmony/entry/src/main/resources/rawfile
cp "$REPO"/harmony/entry/src/main/resources/rawfile/tab_*.json harmony/entry/src/main/resources/rawfile/
cp "$REPO/Example-Shared/Database/cyl_places.sqlite" harmony/entry/src/main/resources/rawfile/

npx react-native codegen-harmony --no-safety-check \
  --cpp-output-path ./harmony/entry/src/main/cpp/generated --ets-output-path ./harmony/entry/src/main/ets/generated
npx react-native bundle-harmony --dev false

# RNOH 0.86.1 calls a WebSocket API of API 26 behind a run-time check; this cast lets it compile on API 21 SDKs.
if [ -d harmony/oh_modules ]; then
  find harmony/oh_modules/.ohpm -path '*turboModules/WebSocketTurboModule.ts' -exec sed -i '' \
    "s/      ws.on('openInfo', (err: BusinessError, value: webSocket.WebSocketOpenInfo) => {/      (ws as ESObject).on('openInfo', (err: BusinessError, value: ESObject) => {/" {} \;
fi
