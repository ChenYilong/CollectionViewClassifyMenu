# Windows-only scenarios

Tag: `windows`. Rules and tool notes for sessions on Windows (sessions whose name starts with `Win` mainly do Android,
HarmonyOS, the WeChat mini program and the Android runs of Flutter and React Native; see
[sessions.md](sessions.md#session-roles-by-name-mac-for-ios-win-for-the-other-platforms)). Facts checked on this machine
(Windows 11, Git Bash, DevEco Studio 6.0.1) on 2026-11-22.


## Shell and paths

- Scripts run in Git Bash (`bash script.sh`), as on macOS (sessions.md, "Running scripts").
- Git Bash rewrites arguments that look like POSIX paths: an `hdc shell` path such as `/data/local/tmp` needs
  `MSYS_NO_PATHCONV=1` in front of the command.
- `hdc file recv` / `hdc install` misread some absolute Windows paths: `cd` into the folder and pass a relative name.
- Python: `py -3`, with `PYTHONUTF8=1` so scripts that read UTF-8 files do not fail with a GBK decode error.


## HarmonyOS on Windows

- DevEco Studio: `C:/Program Files/Huawei/DevEco Studio` (`harmony/scripts/*.sh` find it by themselves); `hdc` is in
  `sdk/default/openharmony/toolchains`.
- The local HarmonyOS emulators are x86_64. Install the `emulator` target's HAP; Rive and PAG show still images there,
  and their playback needs arm64 (plan 1, x86_64 libraries in CYLTabBarController's `CYLAnimatedItemView`, or plan 2,
  the macOS session): [harmonyos.md](harmonyos.md#harmonyos-the-hap-will-not-install-on-an-x86_64-emulator-arm64-only-rive-and-pag).
- The emulators are shared with other sessions: [sessions.md](sessions.md#shared-emulators-and-simulators).


## Android on Windows

- Gradle and JDK 17 come from the Gradle cache (`~/.gradle/wrapper/dists/gradle-9.4.1-bin/...`,
  `~/.gradle/jdks/eclipse_adoptium-17-...`); set `JAVA_HOME` to that JDK. `android/merged/settings.gradle.kts`
  sparse-clones CYLTabBarController's pinned commit into `android/merged/.cyltabbar/<sha>`.


## What Windows cannot do

- No iOS build, no Xcode, no `pod install`: iOS goes to the macOS session or to GitHub CI
  ([macos.md](macos.md#xcode-and-cocoapods), [testing.md](testing.md#cicd-and-example-screenshots)).
- No arm64 HarmonyOS emulator: Rive and PAG playback goes to the macOS session (plan 2).
