# Tag background style: Liquid Glass / 标签背景样式：液态玻璃

Task log and design of the tag background style (`flat`, `liquidGlass`) and of `CYLMenuStyle.minimumTagSize`.
Branch `feat/tag-liquid-glass`, based on PR #35 (`feat/corner-radius-numeric`: glass is clipped to the numeric corner
radius, `min(radius, height / 2)`).

## Task log

- **TODO, 0 / 100** (2026-11-24, branch `feat/tag-liquid-glass`, Mac-CollectionViewClassifyMenu; the advisor designs the
  interface, Sonnet implements): **a Liquid Glass background style for tags.**
  - User prompt, verbatim: 「advisor帮助设计新增接口：为tag 背景设置增加样式，目前实现封装为扁平样式，新增液态玻璃样式背景样式接口。遵循液态玻璃样式在cyltabbar的实现，cyltabbar上注意玻璃样式在iOS平台仅适用于iOS26及以上系统。其他平台也有不同系统限制。不适用液态玻璃是，忽略样式参数，保持目前的扁平样式。sonnet负责实现。无须要考虑兼容性，修改接口后通知使用了本仓库的其他session适配我们的新接口。」
  - English: the advisor helps design a new interface: add a style to the tag background setting. Today the tag is
    implemented as a flat style; add a Liquid Glass background style interface. Follow CYLTabBarController's Liquid Glass
    implementation, and note that on iOS it applies to iOS 26 and later only; other platforms have their own system
    limits. Where Liquid Glass does not apply, ignore the style parameter and keep today's flat style. Sonnet implements.
    No compatibility concerns: after changing the interface, tell the other sessions that use this repository to adapt to
    the new interface.
  - Second item, same branch (owner's answer 2026-11-24; asked by `chenyilong-e4` for CYLSearchViewController, last point of its QMUI port score): `CYLMenuStyle.minimumTagSize`, a minimum
    tag size (CYLSearch's recent-search tags are at least 69 x 29 pt, as QMUI's search demo): a tag narrower or shorter
    than it grows to it, its content stays centred per `tagContentAlignment`; `.zero` (the default) keeps today's layout.
  - **Rubric. 100** = every platform follows CYLTabBarController's rule for Liquid Glass (a real glass background where
    CYLTabBarController draws one, otherwise the documented flat fallback), the config key is read everywhere, unit
    tests, labeled screenshots (flat against glass), docs, parity maps and public API baselines updated, and the other
    sessions notified with the hash and the API names. **60** = iOS draws glass on iOS 26 and later and falls back to
    flat elsewhere, with tests; the config key is parsed on every platform; `minimumTagSize` on iOS.

## Interface

| | |
|:--|:--|
| Type | `CYLTagBackgroundStyle`: `flat` (default), `liquidGlass`. |
| Where | A property of `CYLMenuStyle` (next to `tagContentAlignment`), copied with the style. |
| Config key | `"backgroundStyle": "flat" \| "liquidGlass"`; an unknown value is `flat`. |
| Tint | Each state's existing `backgroundColor` is the glass tint; no new appearance field. |
| Effective style | One function, `resolvedBackgroundStyle`: `liquidGlass` only when the platform's gate below is open; otherwise `flat` and every other parameter is unchanged. |
| Radius | The glass is clipped to the resolved corner radius (PR #35: `min(radius, height / 2)`). |

## Shared base library (owner's decision 2026-11-24, replaces "stay flat on Android, HarmonyOS and the mini program")

User prompt, verbatim: 「advisor你可以参考cyl animateditemview的做法，将液态玻璃实现封装为一个基础库，供本仓库引入，并实现全平台支持液态玻璃。」 English: the advisor may follow what
`CYLAnimatedItemView` does: package the Liquid Glass implementation as a base library that this repository imports, and
support Liquid Glass on every platform. (Earlier the same day: 「advisor需要重新设计，让cyltabbar里不同平台液态玻璃的实现，为所有平台都支持液态玻璃」, redesign so that the tab bar's Liquid Glass on each platform serves all platforms.)

Like `CYLAnimatedItem` (iOS pod `CYLAnimatedItem`, Android `:cylanimateditem`, HarmonyOS `cylanimateditem`, mini program
`cyl-animated-item`), the glass becomes one component per platform in CYLTabBarController's repository (PR #824's
branch): `CYLLiquidGlass` (iOS pod and Swift package target), `:cylliquidglass` (Android), `cylliquidglass`
(HarmonyOS), `cyl-liquid-glass` (mini program). The component never depends on the tab bar; the tab bar depends on it
(its glass code moves into the component, its behavior unchanged) and ClassifyMenu imports it. ClassifyMenu keeps no
copy of any glass code or gate (today's copy of the iOS gate in `CYLMenuStyle` is removed once the pod exists).

| Platform | Component | Gate (CYLTabBarController's rule, moved with the code) | Tag where the gate is closed |
|:--|:--|:--|:--|
| iOS | pod `CYLLiquidGlass`: `CYLLiquidGlass.isActive()` gate, `CYLLiquidGlassView` (`UIGlassEffect`; `glassTintColor`, `cornerRadius`, `isGlassDrawn`) | iOS 27 and later; iOS 26 unless `UIDesignRequiresCompatibility` | flat |
| Android | `:cylliquidglass`: the tab bar's `CYLLiquidGlass.kt` (AGSL shaders, backdrop, highlight) behind one public drawing entry | Android 13+ full glass, Android 12 blur only | flat below Android 12 |
| HarmonyOS | `cylliquidglass`: the tab bar's material (system material, blur imitation) as one exported modifier | system material from API 24, blur imitation below, as the tab bar | flat where the tab bar draws none |
| Mini program | `cyl-liquid-glass`: shared parts of the tab bar's glass (`cyl-glass-lens` stays the glass piece) | as the tab bar's glass | flat where the lens is not drawn |
| Flutter, React Native | nothing to move: they pass the key to the native cores | (native) | (native) |

Order: iOS, Android, HarmonyOS (Windows session `winsCYLSearchViewController`), mini program, then one re-pin of every
platform to the single CYLTabBarController commit, then notify the other sessions.

## TODO (iOS done, 35 / 100)

| Item | Points | Reason |
|:--|:--:|:--|
| iOS: tag interface, glass view, fallback, config key, `minimumTagSize`, tests (`684346a`, four suites pass; screenshot `test-tag-background-flat-liquid-glass`) | 25 | DONE with a copied gate |
| iOS: the gate and glass view live in pod `CYLLiquidGlass` (CYLTabBarController `ab6dd90b`), the tab bar and ClassifyMenu use it, the copy is deleted (suites menu, tag, example, swift pass against it) | 10 | DONE |
| Android: `:cylliquidglass` extracted from the tab bar, tags draw glass, tests, emulator screenshots, frame time with 50 tags | 20 | Not started |
| HarmonyOS: `cylliquidglass` extracted, tags use it, build, tests, emulator screenshot | 15 | Not started (Windows session) |
| Mini program: `cyl-liquid-glass` extracted, tags use it, node tests | 10 | Not started |
| Labeled screenshots flat against glass, docs, README, `cyl-api-map`, parity maps in both repositories | 10 | Not started |
| Re-pin every platform, notify the other sessions | 10 | After the components exist |
