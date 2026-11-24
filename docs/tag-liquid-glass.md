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

## The gate on each platform: as CYLTabBarController

| Platform | CYLTabBarController's rule | Tags |
|:--|:--|:--|
| iOS | `CYLUtils.isLiquidGlassActive()`: iOS 27 and later always; iOS 26 unless the app sets `UIDesignRequiresCompatibility`. System `UIGlassEffect`. | Same gate, `UIVisualEffectView` with `UIGlassEffect` behind the content. |
| Android | `CYLLiquidGlass`: Android 13+ full glass (AGSL shaders), Android 12 blur only, older an opaque capsule. Internal to the tab bar. | Parsed; flat until the glass is drawn for tags (TODO). |
| HarmonyOS | `CYLLiquidGlassTabBarModifier`: system material from API 24, blur imitation below. | Parsed; flat until drawn for tags (TODO). |
| Mini program | Glass lens style of the custom tab bar. | Parsed; flat until drawn for tags (TODO). |
| Flutter, React Native | Pass the key through to the iOS and Android cores. | Key reaches the native side (test). |

## TODO (0 / 100)

| Item | Points | Reason |
|:--|:--:|:--|
| Interface and config key on iOS, Android, HarmonyOS, mini program, copy in the style | 20 | Not started |
| iOS glass view with fallback, tests with injected availability | 25 | Not started |
| `minimumTagSize` on iOS | 5 | Not started |
| Android, HarmonyOS, mini program: draw glass where CYLTabBarController does | 20 | Needs the tab bar's glass to be usable outside the bar (PR #824) or a separate implementation |
| Labeled screenshots flat against glass | 10 | Not started |
| Docs, README, parity maps, API baselines | 10 | Not started |
| Other sessions notified | 10 | After the interface is pushed |
