---
name: cyl-task-start
description: What to do before, during and after every task in CollectionViewClassifyMenu - check the session names (Mac sessions mainly iOS, Win sessions the other platforms; route platform work to the matching active session, else work alone), check the other sessions for the same branch, mark the task as TODO with the current branch at the top of the session, write it into docs/ with acceptance scoring criteria (full marks and pass), score until it passes, print the missing points as TODO at the end, and restart a hung or unopenable shared emulator after telling the other sessions.
---

# Task start, scoring and shared emulators

The rules are in `AGENTS.md` ("Task log in docs/", "Task start: TODO, branch, acceptance score", "Shared emulators
and simulators"). This is the checklist.

## Before the task

- **Read `docs/instructions/behavioral.md` in full first**, every line (AGENTS.md "[behavioral]"): think before coding, simplicity first,
  surgical changes, goal-driven execution.
0. **Check the session names: Mac for iOS, Win for the other platforms** (AGENTS.md "Session roles by name").
   - List the active sessions and read their names. A name starting with `Mac` (case insensitive) marks the session
     that mainly develops and tests iOS; a name starting with `Win` (case insensitive) marks the one that mainly
     develops the other platforms (Android, HarmonyOS, the mini program).
   - Both a Mac and a Win session active: prefer handing each platform's part of the task to the matching session
     (send the request with its context and acceptance criteria), keep your own platform's part, and do not repeat the
     other session's part.
   - No session follows this naming, or only one side is active: skip this step and finish the task independently.
1. **Check other sessions first.** List the other agent sessions and read their current tasks.
   - Is any session editing the same repository and branch? If not, continue.
   - If one is: is its task the same as this one? Same task: do not repeat it; coordinate with that session or take
     a part it is not doing. Different task: continue, and avoid editing the same files at the same time.
2. **Mark the task at the top of the session.** The first lines of the first reply:
   `TODO (branch <current branch>): <task in one line>`. Get the branch with `git branch --show-current`.
3. **Write the task into docs/.** In the most suitable document in `docs/` (the general list is the
   "待办 / TODO" section of `docs/issue-progress.md`; create a document only when none fits), add a `TODO` entry:
   - the user's prompt, quoted verbatim, and the context (branch, files, what is known);
   - **acceptance scoring criteria**: each criterion with its points, what earns **full marks (100)**, and the
     **passing score** (60 unless the task says otherwise).
   Commit the entry with the first commit of the task.

## During the task

4. **Score against the criteria.** Below the passing score, do not stop, interrupt or hand the task back: keep
   working and score again, until it passes. Aim for full marks.

## At the end

5. **Update the entry written at the start**: mark it done, the final score, why it is not full marks (each missing
   criterion and its points), the result and its evidence (commits, test counts, screenshots).
6. **Print the missing points as TODO** in the final lines of the last reply of the session, one line each:
   `TODO (-<points>): <criterion> - <what is still needed>`. Nothing missing: say the score is 100.

## Shared emulators and simulators

- Emulators and simulators (for example the Android emulator `emulator-5556`, the HarmonyOS emulator, iOS
  simulators) are shared with other sessions.
- **Hung until restarted** (the package manager hangs, `adb` / `hdc` commands time out, the screen freezes): first tell
  the other sessions that may use it (which emulator, that it is being restarted), then restart it, and tell them
  when it is back.
- **Will not open or boot: restart first.** Restart is the preferred fix. Do not ask whether to restart; run it from
  the command line directly:
  - Android: `adb -s <serial> reboot`; if `adb` cannot reach it, kill the emulator process and relaunch it with
    `emulator -avd <name> -no-snapshot-load`.
  - HarmonyOS: stop and start the emulator from its command line tool, then `hdc list targets`.
  - iOS: `xcrun simctl shutdown <udid> && xcrun simctl boot <udid>`.
