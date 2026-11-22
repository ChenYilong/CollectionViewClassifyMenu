# HarmonyOS

Tag: `harmonyos`. The full rules of this tag. [AGENTS.md](../../AGENTS.md) keeps the short form under the heading
`[harmonyos] HarmonyOS`; read this file when a task touches the tag. Moved from AGENTS.md word for word on 2026-11-22, when
AGENTS.md was limited to 200 lines; section names are unchanged, so a reference such as AGENTS.md "HarmonyOS: the HAP will not install on an x86_64 emulator (arm64-only Rive and PAG)" now
means the section of that name here.


## HarmonyOS: the HAP will not install on an x86_64 emulator (arm64-only Rive and PAG)

- **Symptom:** `hdc install` of `harmony/entry/build/default/outputs/default/entry-default-unsigned.hap` fails with
  `code:9568347 install parse native so failed ... the Abi type supported by the device does not match`.
- **Cause:** the default HAP's native libraries are `arm64-v8a` only: `libohos_rive.so` (`@ohos/rive` 1.0.4, the
  latest; no x86_64 build is published), `libpag.so` (`@tencent/libpag` 4.4.31) and `libc++_shared.so`. The Windows
  HarmonyOS emulators are x86_64. Check: `hdc -t <target> shell param get const.product.cpu.abilist` (`x86_64` or
  `arm64-v8a`) and `unzip -l <hap> | grep '\.so$'`.
- **The fix lives in CYLTabBarController's `CYLAnimatedItemView`** (`CrossPlatform/harmonyos-cyltabbar/cylanimateditem`,
  vendored here as `harmony/cylanimateditem`, since `62715829`; its README, "x86_64 emulator"), so every example and
  library that depends on the component can be fully tested on the x86_64 emulator:
  - `CYLAnimatedItemEngines` reads `deviceInfo.abiList`; PAG and Rive need `arm64-v8a`. Without it `canPlay` is false:
    the component never calls `animationBuilder` for those items, they show their still image (or the placeholder), and
    debug builds log the reason once. `isSupportedOnDevice(type)`, `unsupportedReason(url)`, `setDeviceAbis` (tests),
    `setRequiredNativeAbis` / the fourth argument of `register`.
  - Static imports of `@ohos/rive` / `@tencent/libpag` are fine: the library loads when a view is built. Code that builds
    PAG or Rive views outside `animationBuilder` checks `CYLAnimatedItemEngines.isSupportedOnDevice(type)` first.
  - `harmony/cylanimateditem/tools/cyl_hap_x86_64.py install <hap> --target <device>` strips the libraries the device
    cannot load and installs any HAP (`--strip auto|yes|no`, `CYL_HAP_STRIP_LIBS=1|0`).
- **In this repository (adopted 2026-11-22):** `harmony/entry/build-profile.json5` has the `emulator` build option
  (`nativeLib.filter.excludes` `**/arm64-v8a/*.so`: excluding only the Rive and PAG libraries leaves `libc++_shared.so`
  and the install still fails), the `emulator` target and the `emulatorTest` build mode (for `ohosTest`);
  `harmony/build-profile.json5` lists them. `harmony/scripts/build.sh` builds both HAPs; install
  `entry/build/default/outputs/emulator/entry-emulator-unsigned.hap` on x86_64. `harmony/scripts/ui-test.sh` reads the
  device's ABIs and picks `emulator` / `emulatorTest` by itself. Phones, arm64 emulators and releases keep `default`.
  Never add the ABI filter to the default target and never drop `@ohos/rive` / `@tencent/libpag`.
- **What x86_64 covers:** Lottie, SVGA and GIF playback; still images and placeholders; PAG and Rive items on their still
  images (no crash, no blank item); layout, dark mode, accessibility, localization, gestures and the UI tests
  (`ui-test.sh`, 14 / 14 on 2026-11-22). **Still needs an arm64 target** (the Apple Silicon Mac's DevEco Studio
  emulator, verified 2026-11-18 on `127.0.0.1:5559`, or a device; from Windows, ask the Mac session): PAG and Rive
  playback, their end callbacks and Rive's dispose workarounds. Say in every report and screenshot caption which part ran
  on x86_64 and which still needs arm64.
- **Rive and PAG tests that only run on arm64 (owner's rule, 2026-11-22): two plans, in this order.**
  1. **Plan 1, in CYLTabBarController's `CYLAnimatedItemView`:** bring in x86_64 builds of the Rive and PAG native
     libraries from GitHub (their source repositories or forks that publish x86_64 builds) so the Rive and PAG tests run on
     the x86_64 emulator. The guard is the running system's architecture (`deviceInfo.abiList` /
     `const.product.cpu.abilist` is x86_64): only then are the x86_64 libraries used.
     - Order of work: first, the x86_64 build compiles and does not crash or affect any other feature (Lottie, SVGA,
       GIF, still images, layout, accessibility, the UI tests); only then make Rive and PAG play correctly.
     - Until plan 1 is verified, wrap it in a debug build guard as well (debug builds only; it only takes effect on the
       emulator). Release builds and arm64 devices keep the published arm64 libraries and today's behavior.
     - **Removing the debug guard needs the owner's approval first**, after plan 1 is verified. Never remove it on your
       own.
     - The work is done in CYLTabBarController (`cylanimateditem`), never in this repository's example; this repository
       then pins the commit and runs its tests on x86_64.
  2. **Plan 2, if plan 1 fails:** forward the Rive and PAG test task to the session on macOS (Apple Silicon, arm64) with a
     cross-session message (the commit, the pages, the checks and the screenshots wanted), and record in the task log
     that plan 1 failed and why.
- Details and commands: `.agents/skills/cyl-harmonyos/SKILL.md`, "Emulator ABI: arm64-only Rive and PAG".


## HarmonyOS: accessibility, localization and accessibility-first UI tests

- All code of this project supports visual accessibility and screen readers (blind users), the HarmonyOS code
  included (`harmony/classifymenu`, the library; `harmony/entry`, the example): every control and every piece of
  text is an accessibility element with a meaningful, localized label (`accessibilityText`), a description when it
  helps (`accessibilityDescription`), and its selected state (`CYLAccessibilitySelectedModifier`, API 13 and later;
  the library targets API 12). A tappable row or button made of several views is one element
  (`accessibilityGroup(true)`); an icon beside its label is decorative (`accessibilityLevel('no')`); a text field is
  labeled like its placeholder. Text sizes are `fp`, so they follow the system font size.
- All code supports internationalization and localization, with localization files: the HarmonyOS example's strings
  come from the iOS example bundle (`harmony/scripts/export-example-strings.py`, looked up with
  `CYLExampleLocalizedString`), the core's from the iOS core bundle (`CYLMenuLocalizedString`), and the strings the
  system shows (app name, ability label) and the tab titles copied from CYLTabBarController's HarmonyOS example are
  native resources (`resources/base|en_US|zh_CN|zh_TW/element/string.json`). Compare keys, never translated text,
  in code.
- If something is found that does not support accessibility or localization, add the support first, then go on
  with the task.
- The same rule covers the cross-platform HarmonyOS shells (`flutter/cyl_tag_list_ohos`,
  `react-native/react-native-cyl-tag-list/harmony-example`, whose strings are its own native resources and whose tab
  bar is CYLTabBarController's), and visual assistance includes touch targets of at least 44 vp.
- Automated UI tests locate controls through accessibility first: by the localized accessibility label
  (`ON.text(CYLExampleLocalizedString(key))`), then its description, and only then by an id
  (`cylFindAccessible` / `cylTapAccessible` in `harmony/entry/src/ohosTest/ets/test/TestSupport.ets`). This applies to
  taps, to complex flows and to sequences of actions. An id alone is only for controls without a distinctive label
  (rows of generated data). A control a test cannot find by its label is an accessibility bug: fix the label.
- Checks: `harmony/scripts/accessibility-check.py` (every image, input and control has a label or is marked
  decorative), `harmony/scripts/check-native-strings.py` (native string files complete and equal to the iOS strings),
  `harmony/scripts/unit-test.sh`. Details: `.agents/skills/cyl-harmonyos/`, `.agents/skills/cyl-accessibility/`,
  `.agents/skills/cyl-localization/`.
