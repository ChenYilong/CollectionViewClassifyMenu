#!/bin/sh
# Usage: scripts/example-screenshots.sh [simulator name]
#
# [EN] Screenshots of the Example apps (the README scenarios) on an iOS simulator, on a Mac with Xcode and CocoaPods: builds
#      Example/CYLMenuExample, installs it, launches it once per screen with -CYLExampleScreen <screen> (read by
#      CYLExampleAppDelegate) and saves build/screenshots/<screen>.png; then the same for the pure Swift Example
#      (Example-Swift/CYLTagEditorExample), saved as build/screenshots/swift-<screen>.png. SCREENS and SWIFT_SCREENS
#      override the lists (comma separated; an empty SWIFT_SCREENS skips the Swift Example).
# [CN] 在 iOS 模拟器上为 Example（README 中的场景）截图，需要装有 Xcode 与 CocoaPods 的 Mac：编译并安装 Example/CYLMenuExample，
#      每个页面以 -CYLExampleScreen <页面> 启动一次（由 CYLExampleAppDelegate 读取），保存为 build/screenshots/<页面>.png。
#      随后对纯 Swift 的 Example（Example-Swift/CYLTagEditorExample）同样截图，保存为 build/screenshots/swift-<页面>.png。
#      SCREENS 与 SWIFT_SCREENS 可替换页面列表（以逗号分隔；SWIFT_SCREENS 为空时跳过 Swift Example）。
set -eu
cd "$(dirname "$0")/.."
SCREENS="${SCREENS:-product,reviews,reviews-multi,reviews-expanded,reviews-network,search-home,search,search-gossip,search-jobs,style,style-custom,style-icon-only,style-title-uncentered,style-lottie,style-pag,style-rive,style-gif,config,animations,animations-speed,animations-rive,plus,plus-reviews-db,plus-menu,plus-menu-filtered,plus-discover,plus-discover-expanded,plus-discover-refreshed,product@en,style@en,animations@en,reviews-expanded@en,search-jobs@en,search@zh-Hant,plus@en,plus-menu-filtered@en,plus-discover@en,plus-discover-expanded@en,plus-discover@zh-Hant}"
SWIFT_SCREENS="${SWIFT_SCREENS-remark,editor,editor-bottom,editor-search,editor-created,editor-new,styles,styles-expanded,styles-config,editor@en,editor-search@en,styles@en,styles-config@en}"
DERIVED=build/screenshots-build
OUT=build/screenshots
mkdir -p "$DERIVED" "$OUT"
DEVICE_ID=$(scripts/simulator-id.sh "${1:-}")
echo "Simulator: $DEVICE_ID"
xcodebuild -version

xcrun simctl boot "$DEVICE_ID" 2>/dev/null || true
xcrun simctl bootstatus "$DEVICE_ID" -b
# [EN] A clean status bar, as in App Store screenshots. [CN] 干净的状态栏，与 App Store 截图一致。
xcrun simctl status_bar "$DEVICE_ID" override --time 9:41 --batteryState charged --batteryLevel 100 --wifiBars 3 || true

# [EN] Usage: capture <project dir> <workspace> <scheme> <app name> <screens> <file prefix>
#      Builds and installs one app, then launches it once per screen and saves $OUT/<prefix><screen>.png.
# [CN] 用法：capture <工程目录> <workspace> <scheme> <App 名称> <页面列表> <文件名前缀>
#      编译并安装一个 App，然后每个页面启动一次，保存为 $OUT/<前缀><页面>.png。
capture() {
  DIR=$1 WORKSPACE=$2 SCHEME=$3 APP_NAME=$4 LIST=$5 PREFIX=$6
  BUILD_LOG="$DERIVED/build-$APP_NAME.log"
  (cd "$DIR" && pod install)
  if ! (cd "$DIR" && xcodebuild build -workspace "$WORKSPACE" -scheme "$SCHEME" -configuration Debug \
    -sdk iphonesimulator -destination "id=$DEVICE_ID" -derivedDataPath "$ROOT/$DERIVED" \
    CODE_SIGNING_ALLOWED=NO) > "$BUILD_LOG" 2>&1; then
    echo "Build of $APP_NAME failed. Errors:"
    grep -nE "(error|fatal error):|^ld: |Undefined symbols" "$BUILD_LOG" | sort -u | head -n 60 || true
    tail -n 30 "$BUILD_LOG"
    return 1
  fi
  # [EN] The first app's log keeps its old name, which the workflow uploads. [CN] 第一个 App 的日志保留原名称（workflow 会上传）。
  [ -f "$DERIVED/build.log" ] || cp "$BUILD_LOG" "$DERIVED/build.log"
  APP=$(find "$DERIVED/Build/Products" -maxdepth 4 -name "$APP_NAME.app" | head -n 1)
  if [ -z "$APP" ] || [ ! -d "$APP" ]; then
    echo "No $APP_NAME.app was built"; return 1
  fi
  BUNDLE_ID=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$APP/Info.plist")
  echo "App: $BUNDLE_ID ($APP)"
  xcrun simctl install "$DEVICE_ID" "$APP"
  # [EN] SpringBoard can refuse a launch right after boot ("denied by service delegate"): give it time, and retry below.
  # [CN] 刚启动的模拟器中 SpringBoard 可能拒绝打开 App（“denied by service delegate”）：先等待，下面也会重试。
  sleep 10

  OLD_IFS=$IFS
  IFS=','
  for SCREEN in $LIST; do
    IFS=$OLD_IFS
    # [EN] Screens without "@<language>" are taken in Simplified Chinese, the language of the scenarios;
    #      the simulator's own language is usually English.
    # [CN] 未写 "@<语言>" 的页面使用简体中文截图（场景的语言）；模拟器自身通常为英文。
    case "$SCREEN" in
      *@*) ;;
      *) SCREEN="$SCREEN@zh-Hans" ;;
    esac
    FILE="$OUT/$PREFIX$SCREEN.png"
    for ATTEMPT in 1 2 3; do
      LOG="$OUT/$PREFIX$SCREEN.log"
      # [EN] The app writes a layout report ([CYLExampleLayout]) to Documents/CYLExampleLayout.txt 3 s after
      #      launch; it is copied next to the screenshot. (`simctl launch --stdout` made SpringBoard refuse launches.)
      # [CN] App 在启动 3 秒后把布局报告写入 Documents/CYLExampleLayout.txt，随后复制到截图旁。
      #      （使用 `simctl launch --stdout` 时 SpringBoard 会拒绝启动。）
      if ! xcrun simctl launch --terminate-running-process "$DEVICE_ID" "$BUNDLE_ID" -CYLExampleScreen "$SCREEN"; then
        echo "Launching $SCREEN failed (attempt $ATTEMPT); retrying"
        sleep 10
        continue
      fi
      sleep 8
      # [EN] Still running? A crash leaves the home screen behind: report it and launch once more.
      # [CN] 仍在运行？崩溃后会回到主屏幕：报告并重新启动一次。
      if xcrun simctl spawn "$DEVICE_ID" launchctl list | grep -q "UIKitApplication:$BUNDLE_ID"; then
        xcrun simctl io "$DEVICE_ID" screenshot "$FILE"
        echo "Saved $FILE"
        DATA=$(xcrun simctl get_app_container "$DEVICE_ID" "$BUNDLE_ID" data 2>/dev/null || true)
        if [ -n "$DATA" ] && [ -f "$DATA/Documents/CYLExampleLayout.txt" ]; then
          cp "$DATA/Documents/CYLExampleLayout.txt" "$LOG"
          cat "$LOG"
        else
          echo "No layout report for $SCREEN: the main thread may be blocked"
        fi
        break
      fi
      echo "The app is not running after launching $SCREEN (attempt $ATTEMPT): crashed?"
      find "$HOME/Library/Logs/DiagnosticReports" -name "$APP_NAME*" -newer "$BUILD_LOG" -print \
        -exec head -n 60 {} \; 2>/dev/null || true
    done
    xcrun simctl terminate "$DEVICE_ID" "$BUNDLE_ID" || true
    IFS=','
  done
  IFS=$OLD_IFS
}

ROOT=$PWD
STATUS=0
capture Example CYLMenuExample.xcworkspace CYLMenuExample CYLMenuExample "$SCREENS" "" || STATUS=1
if [ -n "$SWIFT_SCREENS" ]; then
  capture Example-Swift CYLTagEditorExample.xcworkspace CYLTagEditorExample CYLTagEditorExample "$SWIFT_SCREENS" swift- || STATUS=1
fi
ls -la "$OUT"
exit "$STATUS"
