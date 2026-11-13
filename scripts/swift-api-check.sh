#!/bin/sh
# Usage: scripts/swift-api-check.sh [--baseline]
#
# Checks that the Swift migration of the core (docs/Swift-Migration.md) keeps the Swift API that callers see:
# builds the CollectionViewClassifyMenu pod (Example-Swift workspace, clean derived data), dumps its API with
# swift-api-digester and compares it with scripts/swift-api-baseline.json (the API of the Objective-C core).
# CocoaPods' module map puts every header in a submodule, which swift-api-digester does not read, so the dump uses a
# copy of the framework whose module map has no submodules.
#   --baseline   writes the dump as the new baseline instead of comparing.
# Prints the API breakages (removed or renamed declarations, changed types) and exits 1 when there are any.
set -eu
cd "$(dirname "$0")/.."
ROOT="$PWD"
MODE="${1:-check}"
WORK=$(mktemp -d "${TMPDIR:-/tmp}/cyl-swift-api.XXXXXX")
trap 'rm -rf "$WORK"' EXIT
LOG="$ROOT/build/swift-api-check.log"
mkdir -p build

(cd Example-Swift && xcodebuild build -workspace CYLTagEditorExample.xcworkspace -scheme CollectionViewClassifyMenu \
  -sdk iphonesimulator -configuration Debug -derivedDataPath "$WORK/dd" CODE_SIGNING_ALLOWED=NO) > "$LOG" 2>&1 || {
  echo "error: the pod did not build; see $LOG" >&2
  grep -E "error:" "$LOG" | sort -u | head -n 40 >&2
  exit 2
}
FRAMEWORK="$WORK/dd/Build/Products/Debug-iphonesimulator/CollectionViewClassifyMenu/CollectionViewClassifyMenu.framework"
mkdir -p "$WORK/flat"
cp -R "$FRAMEWORK" "$WORK/flat/"
MAP="$WORK/flat/CollectionViewClassifyMenu.framework/Modules/module.modulemap"
grep -v 'module \* { export \* }' "$MAP" > "$WORK/module.modulemap"
cp "$WORK/module.modulemap" "$MAP"

SDK=$(xcrun --sdk iphonesimulator --show-sdk-path)
set -- -module CollectionViewClassifyMenu -target arm64-apple-ios15.0-simulator -sdk "$SDK" -F "$WORK/flat" \
  -module-cache-path "$WORK/mc"
if [ "$MODE" = "--baseline" ]; then
  xcrun swift-api-digester -dump-sdk "$@" -avoid-tool-args -o scripts/swift-api-baseline.json
  echo "Baseline written: scripts/swift-api-baseline.json"
  exit 0
fi
xcrun swift-api-digester -diagnose-sdk "$@" -baseline-path scripts/swift-api-baseline.json \
  -o "$ROOT/build/swift-api-breakage.txt" 2>&1 | tail -n 5 || true
cat build/swift-api-breakage.txt
if grep -qE '^[^/].*(has been removed|has been renamed|has return type change|has parameter .* type change|has declared type change|is now|has generic signature change)' build/swift-api-breakage.txt; then
  echo "Swift API changed: see build/swift-api-breakage.txt" >&2
  exit 1
fi
echo "Swift API unchanged."
