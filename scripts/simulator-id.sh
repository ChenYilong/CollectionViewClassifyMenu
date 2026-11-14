#!/bin/sh
# Usage: scripts/simulator-id.sh [simulator name or UDID]
#
# [EN] Prints the UDID of an available iPhone simulator: the named one, else the first iPhone of the newest iOS runtime.
#      A UDID is printed as given, without asking simctl (which can hang while other jobs use the simulator service).
# [CN] 输出可用 iPhone 模拟器的 UDID：指定名称的模拟器，否则为最新 iOS 运行时中的第一个 iPhone。
#      传入 UDID 时直接输出，不调用 simctl（其他任务占用模拟器服务时 simctl 可能卡住）。
set -eu
case "${1:-}" in
  ????????-????-????-????-????????????) echo "$1"; exit 0 ;;
esac
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
