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

(cd Example-Swift && pod install > "$WORK/pod-install.log" 2>&1 && xcodebuild build -workspace CYLTagEditorExample.xcworkspace -scheme CollectionViewClassifyMenu \
  -sdk iphonesimulator -configuration Debug -derivedDataPath "$WORK/dd" CODE_SIGNING_ALLOWED=NO) > "$LOG" 2>&1 || {
  echo "error: the pod did not build; see $LOG" >&2
  grep -E "error:" "$LOG" | sort -u | head -n 40 >&2
  exit 2
}
FRAMEWORK="$WORK/dd/Build/Products/Debug-iphonesimulator/CollectionViewClassifyMenu/CollectionViewClassifyMenu.framework"
SDK=$(xcrun --sdk iphonesimulator --show-sdk-path)
FLAT='framework module CollectionViewClassifyMenu {
  umbrella header "CollectionViewClassifyMenu-umbrella.h"
  export *
}'
# The Objective-C part: a copy without the Swift module, with a module map without submodules.
mkdir -p "$WORK/objc"
cp -R "$FRAMEWORK" "$WORK/objc/"
rm -rf "$WORK/objc/CollectionViewClassifyMenu.framework/Modules/CollectionViewClassifyMenu.swiftmodule" \
  "$WORK/objc/CollectionViewClassifyMenu.framework/Headers/CollectionViewClassifyMenu-Swift.h"
printf '%s\n' "$FLAT" > "$WORK/objc/CollectionViewClassifyMenu.framework/Modules/module.modulemap"
xcrun swift-api-digester -dump-sdk -module CollectionViewClassifyMenu -target arm64-apple-ios15.0-simulator -sdk "$SDK" \
  -F "$WORK/objc" -module-cache-path "$WORK/mc-objc" -avoid-tool-args -o "$WORK/objc.json"
# The Swift part (once the core has Swift files): only the declarations written in Swift.
if [ -d "$FRAMEWORK/Modules/CollectionViewClassifyMenu.swiftmodule" ]; then
  mkdir -p "$WORK/swift"
  cp -R "$FRAMEWORK" "$WORK/swift/"
  printf '%s\n' "$FLAT" > "$WORK/swift/CollectionViewClassifyMenu.framework/Modules/module.modulemap"
  xcrun swift-api-digester -dump-sdk -swift-only -module CollectionViewClassifyMenu -target arm64-apple-ios15.0-simulator \
    -sdk "$SDK" -F "$WORK/swift" -module-cache-path "$WORK/mc-swift" -avoid-tool-args -o "$WORK/swift.json"
fi
python3 - "$WORK" <<'PY'
import json, os, sys
work = sys.argv[1]
merged = json.load(open(os.path.join(work, "objc.json")))
swift_path = os.path.join(work, "swift.json")
if os.path.exists(swift_path):
    seen = {(c.get("kind"), c.get("printedName")) for c in merged["ABIRoot"]["children"]}
    for child in json.load(open(swift_path))["ABIRoot"]["children"]:
        if child.get("kind") == "Import" and (child.get("kind"), child.get("printedName")) in seen:
            continue
        merged["ABIRoot"]["children"].append(child)
json.dump(merged, open(os.path.join(work, "current.json"), "w"), indent=2)
PY

if [ "$MODE" = "--baseline" ]; then
  cp "$WORK/current.json" scripts/swift-api-baseline.json
  echo "Baseline written: scripts/swift-api-baseline.json"
  exit 0
fi
xcrun swift-api-digester -diagnose-sdk -input-paths scripts/swift-api-baseline.json -input-paths "$WORK/current.json" \
  -o "$ROOT/build/swift-api-breakage.txt" 2>&1 | tail -n 5 || true
# Not API changes, but differences between a dump of Objective-C and of Swift: Clang's builtin type aliases
# (__Int8x8_t…), conformances a Swift dump does not list because they are inherited from UIKit / Foundation (changes
# to the project's own CYL protocols stay), the @preconcurrency that Swift adds to UIKit subclasses, and Objective-C
# names a Swift-only dump does not record (checked below against the generated -Swift.h instead).
grep -vE 'TypeAlias __|has removed conformance to (NS|UI|CA|CVar|Custom|Equatable|Hashable|Sendable|Copyable|Escapable|CL|CM)|is now with @preconcurrency|has ObjC name change from .* to $' \
  build/swift-api-breakage.txt > "$WORK/breakage.txt" || true
cp "$WORK/breakage.txt" build/swift-api-breakage.txt
# The Objective-C names: every class, protocol and selector of a migrated Swift type must be in the -Swift.h.
if [ -f "$FRAMEWORK/Headers/CollectionViewClassifyMenu-Swift.h" ]; then
  python3 - "$WORK/swift.json" "$FRAMEWORK/Headers/CollectionViewClassifyMenu-Swift.h" scripts/swift-api-baseline.json \
    >> build/swift-api-breakage.txt <<'PY'
import json, re, sys
swift_dump, header_path, baseline_path = sys.argv[1:4]
header = open(header_path).read()
swift_types = {c.get("name") for c in json.load(open(swift_dump))["ABIRoot"]["children"]
               if c.get("declKind") in ("Class", "Protocol")}
swift_exts = {c.get("name") for c in json.load(open(swift_dump))["ABIRoot"]["children"] if c.get("declKind") == "Extension"}
def selector_present(sel):
    parts = [p for p in sel.split(":") if p]
    if ":" not in sel:
        return re.search(r"\b%s\b" % re.escape(sel), header) is not None
    return all(re.search(r"\b%s:" % re.escape(p), header) for p in parts)
for node in json.load(open(baseline_path))["ABIRoot"]["children"]:
    name, kind = node.get("name"), node.get("declKind")
    if not ((kind in ("Class", "Protocol") and name in swift_types) or (kind == "Extension" and name in swift_exts)):
        continue
    if kind != "Extension" and node.get("objc_name") and not re.search(r'SWIFT_(CLASS|PROTOCOL)(_NAMED)?\("[^"]*%s' % re.escape(node["objc_name"]), header) \
            and ("@interface %s" % node["objc_name"]) not in header and ("@protocol %s" % node["objc_name"]) not in header:
        print("(%s): %s %s has ObjC name change: %s missing in -Swift.h" % (name, kind, name, node["objc_name"]))
    for child in node.get("children") or []:
        sel = child.get("objc_name")
        inherited_init = child.get("declKind") == "Constructor" and "Override" in (child.get("declAttributes") or [])
        if sel and not inherited_init and child.get("declKind") in ("Func", "Var", "Constructor") \
                and not selector_present(sel):
            print("(%s): %s %s.%s has ObjC name change: selector %s missing in -Swift.h"
                  % (name, child.get("declKind"), name, child.get("printedName"), sel))
PY
fi
cat build/swift-api-breakage.txt
if grep -qE '^[^/].*(has been removed|has been renamed|has return type change|has parameter .* type change|has declared type change|is now|has generic signature change|no longer|ObjC name change: )' build/swift-api-breakage.txt; then
  echo "Swift API changed: see build/swift-api-breakage.txt" >&2
  exit 1
fi
echo "Swift API unchanged."
