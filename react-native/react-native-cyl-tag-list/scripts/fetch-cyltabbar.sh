#!/bin/sh
# Checks out CYLTabBarController at the commit the example uses (its React Native component react-native-cyltabbar
# lives in CrossPlatform/ and is not on npm) into .deps/, which git ignores. Run before `yarn install`.
set -e
COMMIT=c5a18088b3e905cc9d8a4c59d43196bc0cfba618  # CYL_TAB_BAR: keep equal to the pin in example/ios/Podfile
DIR="$(cd "$(dirname "$0")/.." && pwd)/.deps/CYLTabBarController"
if [ ! -d "$DIR/.git" ]; then
  git clone --filter=blob:none --no-checkout https://github.com/ChenYilong/CYLTabBarController.git "$DIR"
fi
git -C "$DIR" fetch -q origin
git -C "$DIR" checkout -q "$COMMIT"
echo "react-native-cyltabbar at $(git -C "$DIR" rev-parse --short HEAD)"
