#!/bin/sh
# End-to-end check of the example on an Android emulator or device, driven through uiautomator (elements found by
# their text or accessibility label, never by coordinates):
#   scripts/e2e-android.sh [serial] [apk]
# Tags tab: 2x speed, Loop on, a tag tap reaches JavaScript. Classify tab: every place, 川菜, the filter sheet with
# 广州, 确定, and the conditions restored after a force-stop (1 place, the same as iOS and Flutter).
# Screenshots go to build/e2e-android/.
set -eu
SERIAL="${1:-emulator-5560}"
APK="${2:-example/android/app/build/outputs/apk/release/app-release.apk}"
PACKAGE=cyltaglist.example
OUT="build/e2e-android"
mkdir -p "$OUT"
adb_() { adb -s "$SERIAL" "$@"; }

dump() {
  adb_ shell uiautomator dump /sdcard/cyl-e2e.xml >/dev/null
  adb_ shell cat /sdcard/cyl-e2e.xml
}

# The center of the first node whose text or content-desc matches the extended regular expression $1.
center() {
  bounds=$(dump | tr '>' '\n' | grep -E "(text|content-desc)=\"$1\"" | head -1 | sed -E 's/.*bounds="\[([0-9]+),([0-9]+)\]\[([0-9]+),([0-9]+)\]".*/\1 \2 \3 \4/')
  [ -n "$bounds" ] || { echo "FAIL: no element matches /$1/" >&2; exit 1; }
  echo "$bounds" | awk '{ printf "%d %d", ($1 + $3) / 2, ($2 + $4) / 2 }'
}

tap() {
  # shellcheck disable=SC2046
  adb_ shell input tap $(center "$1")
  sleep "${2:-2}"
}

expect_text() {
  if dump | grep -qE "text=\"$1\""; then
    echo "ok: $2"
  else
    echo "FAIL: $2 (no text /$1/)" >&2
    exit 1
  fi
}

shot() { adb_ exec-out screencap -p > "$OUT/$1.png"; }

launch() {
  adb_ shell am start -n "$PACKAGE/.MainActivity" >/dev/null
  sleep 8
}

[ ! -f "$APK" ] || adb_ install -r "$APK" >/dev/null
adb_ shell pm clear "$PACKAGE" >/dev/null
launch

tap '2x' 1
expect_text 'Speed 2\.00x' 'the 2x step sets the speed'
tap 'Home( .*)?' 2
expect_text 'Selected: Home' 'a tag tap reaches JavaScript'
shot tags

tap 'Classify' 3
expect_text 'All · All · All · 83' 'every place at first'
tap '川菜[^"]*' 2
expect_text '川菜[^"]* · All · All · 3' '川菜 selects its places'
tap 'Filter' 3
tap '广州' 1
shot filter-sheet
tap 'OK' 3
expect_text '川菜[^"]* · 广州 · All · 1' 'the filter ANDs 广州 with the tag'
shot classify-filter

adb_ shell am force-stop "$PACKAGE"
launch
tap 'Classify' 3
expect_text '川菜[^"]* · 广州 · All · 1' 'the conditions are restored from the database'
tap 'Reset' 3
expect_text 'All · All · All · 83' 'reset brings every place back'
echo "PASS ($OUT)"
