#!/bin/sh
# Usage: scripts/simulator-id.sh [simulator name]
#
# [EN] Prints the UDID of an available iPhone simulator: the named one, else the first iPhone of the newest iOS runtime.
# [CN] 输出可用 iPhone 模拟器的 UDID：指定名称的模拟器，否则为最新 iOS 运行时中的第一个 iPhone。
set -eu
xcrun simctl list devices available -j | python3 -c '
import json, sys
name = sys.argv[1]
devices = json.load(sys.stdin)["devices"]
def version(runtime):
    return [int(part) for part in runtime.rsplit("iOS-", 1)[-1].split("-") if part.isdigit()]
for runtime in sorted((r for r in devices if "iOS" in r), key=version, reverse=True):
    for device in devices[runtime]:
        if (name and name in (device["name"], device["udid"])) or (not name and device["name"].startswith("iPhone")):
            print(device["udid"]); sys.exit(0)
sys.exit(1)' "${1:-}" || { echo "No iPhone simulator${1:+ named $1}" >&2; xcrun simctl list devices available >&2; exit 1; }
