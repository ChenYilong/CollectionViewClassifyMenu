---
name: cyl-simulator-cleanup
description: Read before running an iOS simulator or emulator; after the tests and screenshots, terminate the app and shut the simulator down (own devices only), and start them again only when needed.
---

# Stop the simulator when the work is done

Full rule: `docs/instructions/sessions.md`, section "Simulators and emulators: stop them when the work is done".

## Before you run a simulator

1. Read the rule above (or the short text below) before the first `xcrun simctl boot` / `xcodebuild test`.
2. Note the UDIDs your task uses (`scripts/simulator-id.sh`, or the device your script boots). Only these are yours.

## After the tests or screenshots (immediately, before the report)

```sh
xcrun simctl terminate <udid> <bundle id>
xcrun simctl shutdown <udid>
xcrun simctl list devices | grep Booted      # yours must be gone
pgrep -fl xcodebuild                          # kill <pid> only for your own worktree's runs
```

- Never `xcrun simctl shutdown all`, never `pkill -f` a pattern other sessions' runs also match, never close another
  session's Simulator window: the Mac is shared.
- Boot again only when the next run needs it (`xcrun simctl boot <udid>`, install, launch).
- Do this also when the task fails or is abandoned. Other platforms: `adb -s <serial> emu kill`, the HarmonyOS
  emulator's own stop command.
- Report one line: `stopped: <udids> (app terminated, simulator shut down)`.
