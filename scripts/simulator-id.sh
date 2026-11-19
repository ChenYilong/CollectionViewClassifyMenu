#!/bin/sh
# Usage: scripts/simulator-id.sh [simulator name or UDID]
#
# [EN] Prints the UDID of an available iPhone simulator: the named one, else a regular iPhone ("iPhone <number>...") of
#      the newest iOS runtime, else its first iPhone. Form factors such as "iPhone Duo" lay tab bars out at the top.
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
import re
runtimes = sorted((r for r in devices if "iOS" in r), key=version, reverse=True)
tests = [lambda d: name in (d["name"], d["udid"])] if name else [
    lambda d: re.match(r"iPhone \d", d["name"]) is not None, lambda d: d["name"].startswith("iPhone")]
for test in tests:
    for runtime in runtimes:
        for device in devices[runtime]:
            if test(device):
                print(device["udid"]); sys.exit(0)
sys.exit(1)' "${1:-}" || { echo "No iPhone simulator${1:+ named $1}" >&2; xcrun simctl list devices available >&2; exit 1; }
