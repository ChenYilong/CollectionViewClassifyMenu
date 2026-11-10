#!/bin/sh
# Usage: scripts/example-screenshots.sh [simulator name]
#
# [EN] Screenshots of the Example app (the README scenarios) on an iOS simulator, on a Mac with Xcode and CocoaPods: builds
#      Example/CYLMenuExample, installs it, launches it once per screen with -CYLExampleScreen <screen> (read by
#      CYLExampleAppDelegate) and saves build/screenshots/<screen>.png. SCREENS overrides the list (comma separated).
# [CN] 在 iOS 模拟器上为 Example（README 中的场景）截图，需要装有 Xcode 与 CocoaPods 的 Mac：编译并安装 Example/CYLMenuExample，
#      每个页面以 -CYLExampleScreen <页面> 启动一次（由 CYLExampleAppDelegate 读取），保存为 build/screenshots/<页面>.png。
#      SCREENS 可替换页面列表（以逗号分隔）。
set -eu
cd "$(dirname "$0")/.."
SCREENS="${SCREENS:-list,product,reviews,reviews-good,reviews-expanded,search,search-gossip,search-jobs}"
DERIVED=build/screenshots-build
OUT=build/screenshots
mkdir -p "$DERIVED" "$OUT"
DEVICE_ID=$(scripts/simulator-id.sh "${1:-}")
echo "Simulator: $DEVICE_ID"
xcodebuild -version

(cd Example && pod install)
if ! (cd Example && xcodebuild build -workspace CYLMenuExample.xcworkspace -scheme CYLMenuExample -configuration Debug \
  -sdk iphonesimulator -destination "id=$DEVICE_ID" -derivedDataPath "../$DERIVED" \
  CODE_SIGNING_ALLOWED=NO) > "$DERIVED/build.log" 2>&1; then
  echo "Build failed. Errors:"
  grep -nE "(error|fatal error):|^ld: |Undefined symbols" "$DERIVED/build.log" | sort -u | head -n 60 || true
  tail -n 30 "$DERIVED/build.log"
  exit 1
fi
APP=$(find "$DERIVED/Build/Products" -maxdepth 4 -name 'CYLMenuExample.app' | head -n 1)
if [ -z "$APP" ] || [ ! -d "$APP" ]; then
  echo "No .app was built"; exit 1
fi
BUNDLE_ID=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$APP/Info.plist")
echo "App: $BUNDLE_ID ($APP)"

xcrun simctl boot "$DEVICE_ID" 2>/dev/null || true
xcrun simctl bootstatus "$DEVICE_ID" -b
# [EN] A clean status bar, as in App Store screenshots. [CN] 干净的状态栏，与 App Store 截图一致。
xcrun simctl status_bar "$DEVICE_ID" override --time 9:41 --batteryState charged --batteryLevel 100 --wifiBars 3 || true
xcrun simctl install "$DEVICE_ID" "$APP"

OLD_IFS=$IFS
IFS=','
for SCREEN in $SCREENS; do
  IFS=$OLD_IFS
  FILE="$OUT/$SCREEN.png"
  for ATTEMPT in 1 2; do
    xcrun simctl launch --terminate-running-process "$DEVICE_ID" "$BUNDLE_ID" -CYLExampleScreen "$SCREEN"
    sleep 5
    # [EN] Still running? A crash leaves the home screen behind: report it and launch once more.
    # [CN] 仍在运行？崩溃后会回到主屏幕：报告并重新启动一次。
    if xcrun simctl spawn "$DEVICE_ID" launchctl list | grep -q "UIKitApplication:$BUNDLE_ID"; then
      xcrun simctl io "$DEVICE_ID" screenshot "$FILE"
      echo "Saved $FILE"
      break
    fi
    echo "The app is not running after launching $SCREEN (attempt $ATTEMPT): crashed?"
    find "$HOME/Library/Logs/DiagnosticReports" -name 'CYLMenuExample*' -newer "$DERIVED/build.log" -print \
      -exec head -n 60 {} \; 2>/dev/null || true
  done
  xcrun simctl terminate "$DEVICE_ID" "$BUNDLE_ID" || true
  IFS=','
done
IFS=$OLD_IFS
ls -la "$OUT"
