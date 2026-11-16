# Rive animated icons: engine per platform / Rive 动效图标：各平台使用的引擎

Tags with a `.riv` animation (for example `animated-tags.json`) are drawn by a different Rive runtime on each
platform. The table lists which one, its version, and its state on 2026-11-16 (branch `feat/harmony`).

带 `.riv` 动效的标签在每个平台由不同的 Rive 引擎绘制。下表列出引擎、版本与 2026-11-16 的状态（分支 `feat/harmony`）。

| Platform / 平台 | Rive engine / 引擎 | Version / 版本 | Linked by / 接入方式 | Renderer / 渲染 | State / 状态 |
|---|---|---|---|---|---|
| iOS (Swift / ObjC examples) | `RiveRuntime` (rive-ios) | `~> 6.29` | `pod 'CYLTabBarController/Rive'` (`Example/Podfile`), through `CYLTabBarItemAnimation` | Rive (Metal) | Linked; not affected by the HarmonyOS crash |
| Android (Kotlin) | `app.rive:rive-android` | `10.3.0` | `android/gradle/libs.versions.toml`, `implementation(libs.rive)` in `android/merged/example` | Rive (GPU) | Linked; not affected by the HarmonyOS crash |
| HarmonyOS (ArkTS) | `@ohos/rive` (`RiveAnimationView`) | `1.0.4` | `harmony/classifymenu/oh-package.json5`; `CYLAnimatedIcon.ets` | Emulator: `RendererType.Canvas`; device: `RendererType.Rive` (`cylRiveRendererType()`, `3417e7e`) | Crash fixed on the emulator (`e82b503`, `3417e7e`); real device untested. Switch: `CYL_RIVE_ENABLED` |
| Flutter on HarmonyOS | `@ohos/rive` via the HarmonyOS core | `1.0.4` | `flutter/cyl_tag_list_ohos/ohos/oh-package.json5` → `file:../../../harmony/classifymenu` | Same as HarmonyOS | Same fix as HarmonyOS |
| React Native on HarmonyOS | `@ohos/rive` via the HarmonyOS core | `1.0.4` | `react-native/react-native-cyl-tag-list/harmony-example/harmony/entry/oh-package.json5` → `file:` `harmony/classifymenu` | Same as HarmonyOS | Same fix as HarmonyOS |
| Flutter on iOS / Android | Not linked / 未接入 | — | The example Podfile has `CYLTabBarController/Lottie` but no `/Rive`; the Android plugin has no rive-android | — | `.riv` tags show their static image (the animation is ignored when the engine is not linked) |
| React Native on iOS / Android | Not linked / 未接入 | — | Same as Flutter: no `CYLTabBarController/Rive`, no rive-android | — | `.riv` tags show their static image |
| WeChat mini program / 微信小程序 | `@rive-app/canvas-advanced` (WebAssembly, 573 KB) wrapped as `cyl-rive-miniprogram` | `2.39.1` | CYLTabBarController `CrossPlatform/rive-miniprogram`, copied into `cyl_components` by `scripts/fetch-cyltabbar.js` | Canvas 2D | Linked (`engines.rive: true` in `utils/tag-animations.js`); not affected |

## The HarmonyOS crash / 鸿蒙崩溃

- Cause: the tag list rebuilt every tag on its first relayouts, and disposing a `RiveAnimationView` crashed inside
  `@ohos/rive` 1.0.4 (`eglDestroySurface` on a destroyed native window); the emulator's host GPU also crashed with the
  default GPU renderer. Details: `issue-progress.md`.
- Fix: stable tag keys (`e82b503`) and the Canvas renderer on the emulator (`3417e7e`), the same choice as
  CYLTableViewPlaceHolder's `CYLRivePlaceholderItemAnimator.ets`.
- 原因与修复同上；详见 `issue-progress.md`。

## Open / 待办

- TODO: run the animation screen on a real HarmonyOS device (GPU renderer).
- TODO: decide whether the Flutter and React Native iOS / Android examples should link Rive (`CYLTabBarController/Rive`, rive-android) so `.riv` tags animate there too.
