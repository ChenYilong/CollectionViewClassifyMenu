# Sessions and shared devices

Tag: `sessions`. The full rules of this tag. [AGENTS.md](../../AGENTS.md) keeps the short form under the heading
`[sessions] Sessions and shared devices`; read this file when a task touches the tag. Moved from AGENTS.md word for word on 2026-11-22, when
AGENTS.md was limited to 200 lines; section names are unchanged, so a reference such as AGENTS.md "Session roles by name: Mac for iOS, Win for the other platforms" now
means the section of that name here.


## Session roles by name: Mac for iOS, Win for the other platforms

Checklist: `.agents/skills/cyl-task-start/SKILL.md` ("Before the task", step 0).

- **Check the session names before a task.** List the active agent sessions working on this repository (for example
  with the agent tool that lists sessions) and read their names.
- **Mac sessions mainly do iOS.** A session whose name starts with `Mac` (case insensitive: `Mac`, `mac`, `MAC`…)
  mainly develops and tests the iOS side: the Swift core, the iOS examples, and the iOS runs of the Flutter and React
  Native examples, on macOS with Xcode and the iOS simulator.
- **Win sessions mainly do the other platforms.** A session whose name starts with `Win` (case insensitive) mainly
  develops the other platforms: Android, HarmonyOS, the WeChat mini program, and the Android runs of the Flutter and
  React Native examples.
- **Both active: route by platform.** When a matching Mac session and a matching Win session are both active, prefer
  handing each platform's part of a task to the session that owns that platform: send it the request with the context
  and the acceptance criteria, keep your own platform's part, and do not repeat the other session's part. A
  cross-platform task is split by platform, each session doing its side and reporting back.
- **Otherwise: skip the rule.** When no active session follows this naming, or only one side is active, skip this
  rule and finish the whole task independently.
- This rule decides who does a platform's work; the other rules (checking the other sessions for the same branch,
  folder ownership, the task log) still apply.


## Shared emulators and simulators

- Emulators and simulators are shared with other sessions (for example the Android emulator `emulator-5556`).
- **An emulator that stays hung until it is restarted** (package manager hangs, `adb` or `hdc` commands time out,
  the screen stops updating): tell the other sessions first (one message to each session that may use it: which
  emulator and that it is being restarted), then restart it, and tell them again when it is back.
- **An emulator that will not open or boot: restart it first.** Restarting is the preferred fix. Do not ask whether
  to restart; run the restart from the command line directly (Android: `adb -s <serial> reboot`, or kill and relaunch
  the emulator with `-no-snapshot-load` if `adb` cannot reach it; HarmonyOS: restart the emulator from its command
  line tool; iOS: `xcrun simctl shutdown <udid> && xcrun simctl boot <udid>`).


## Running scripts

- **Run scripts with bash, not the interactive shell.** Shell scripts and multi-line command sequences run in bash:
  `bash path/to/script.sh`, or `bash <<'EOF' … EOF` (or `bash -c '…'`) for an inline sequence; new scripts start with
  `#!/usr/bin/env bash` (a POSIX `#!/bin/sh` script is run with `sh` or `bash`, never sourced into zsh). The
  interactive shell on macOS is zsh, which behaves differently: it does not split an unquoted `$var` into words
  (`box="10 20 30 40"; set -- $box` gives one argument, so a measurement over `$box` silently reads one value), a
  variable holding a command with its arguments (`hdc="hdc -t 127.0.0.1:5563"; $hdc shell …`) fails with "no such
  file or directory", and a glob that matches nothing aborts the whole command. The error this rule prevents: "zsh
  doesn't split $box into words either. Running the same measurement as a bash script." Keep a command with
  arguments in a wrapper script or a bash array (`hdc=(hdc -t 127.0.0.1:5563); "${hdc[@]}" shell …`), never in a
  string variable.


## Simulators and emulators: stop them when the work is done

Read this section before you run an iOS simulator (or any emulator). Added 2026-11-25 on the owner's order.

- **The rule in the owner's words:** after running a simulator and finishing the test or the screenshots, immediately kill the
  app and the simulator process; start them again when they are needed. Do not leave the app running after the task is
  done, and do not leave the simulator process running.
- **When:** as soon as the last screenshot is taken or the last test run has finished, before you write the report, and
  also when a task is abandoned or fails. A long wait between two runs (a build, a review) is a reason to stop them too:
  start them again for the next run (`xcrun simctl boot <udid>`, then install and launch).
- **How, on iOS (only the devices your own task started):**
  1. Terminate the app: `xcrun simctl terminate <udid> <bundle id>`.
  2. Shut the simulator down: `xcrun simctl shutdown <udid>`, then check with `xcrun simctl list devices | grep Booted`.
  3. Stop what your own run left behind: the `xcodebuild` / `xctest` / `testmanagerd` processes of your worktree, by their
     process IDs (`pgrep -fl xcodebuild`, then `kill <pid>` for yours). Never `pkill -f` a pattern that other sessions' runs
     also match, never `xcrun simctl shutdown all`, and never close the Simulator app window of another session: the Mac is
     shared (one `pkill -f "unit-tests.sh example"` once aborted another session's test run).
  4. Emulators of other platforms follow the same idea with their own tools: `adb -s <serial> emu kill`, the HarmonyOS
     emulator by its own stop command.
- **Which devices are yours:** the ones you booted or that your scripts boot for the task (record the UDID). A device that
  was already booted by someone else is left alone; say so in the report instead.
- **Report:** one line in the task report: "stopped: <udids> (app terminated, simulator shut down)".

