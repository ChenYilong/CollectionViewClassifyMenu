# harmony folder instructions

- This folder is the HarmonyOS NEXT port: `classifymenu` (the core, a HAR) and `entry` (the ArkTS example).
- Accessibility and localization (English rule, AGENTS.md "Accessibility and localization on HarmonyOS (and every
  platform)"):

- **All code supports accessibility and localization, on every platform, HarmonyOS included.** Every screen of the
  core and of the examples (iOS, Android, Flutter, React Native, Mini Program and HarmonyOS: `harmony/classifymenu`,
  `harmony/entry`, the Flutter and React Native HarmonyOS shells) supports visual assistance and screen readers
  (VoiceOver, TalkBack, HarmonyOS ScreenReader: labels, states, hints, grouping, decorative elements hidden, touch
  targets of at least 44 vp, text that follows the system font scale) and is internationalized and localized through
  resource files (iOS `.lproj` in one bundle per module; Android `res/values-*`; HarmonyOS
  `resources/{base,en_US,zh_CN,zh_TW}/element/string.json` per module, the core's keys prefixed `cyl_menu_` and read
  through `CYLMenuLocalizedString`, the examples' through their own lookup or `$r`). No user-facing literal stays in
  code.
- **Where support is missing, add it first**, before other work on that code.
- **Automated UI tests locate controls through accessibility and localized text first**: find elements by their
  accessibility label, description or identifier, or by their localized text read from the resources (HarmonyOS:
  `ON.text(...)` / `ON.description(...)` with `resourceManager.getStringByNameSync`), and use them to tap and to run
  multi-step flows and consecutive operations. Fall back to ids, types or coordinates only for controls without text
  (a slider's thumb), and file the missing label as a bug.
- **Checks:** `python3 scripts/harmonyos-l10n-check.py` (the same keys in every locale, no literal text in ArkTS);
  the HarmonyOS score sheet `docs/harmonyos-api.md` (`python3 scripts/harmonyos-api.py`).
