#!/bin/sh
# Fetches CYLTabBarController's HarmonyOS library (CrossPlatform/harmonyos-cyltabbar/cyltabbar) at its pinned commit
# into harmony/.deps/, where build-profile.json5 finds the module "cyltabbar" (the example's tab bar). Run it once
# before the first build and after the pin changes. The pin is the head of feat/harmonyos-component, the only branch
# with the library so far (the iOS Podfiles pin CYLTabBarController by commit the same way).
set -eu
CYL_TAB_BAR_COMMIT=19cbf801f9b7c7f2a571aacaf6eaea9ad1ff9a5e
HERE=$(cd "$(dirname "$0")/.." && pwd)
DEPS="$HERE/.deps/CYLTabBarController"
if [ ! -d "$DEPS" ]; then
  mkdir -p "$HERE/.deps"
  git clone -q --filter=blob:none --no-checkout https://github.com/ChenYilong/CYLTabBarController.git "$DEPS"
  git -C "$DEPS" sparse-checkout set --no-cone CrossPlatform/harmonyos-cyltabbar/cyltabbar
fi
git -C "$DEPS" fetch -q origin "$CYL_TAB_BAR_COMMIT" 2>/dev/null || true
git -C "$DEPS" checkout -q "$CYL_TAB_BAR_COMMIT"
echo "cyltabbar at $(git -C "$DEPS" rev-parse --short HEAD)"
