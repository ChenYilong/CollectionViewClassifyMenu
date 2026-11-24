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

## Owner's decisions 2026-11-24 (latest wins; they replace the "separate base library" design)

Prompts, verbatim, with English:

1. 「我想将液态玻璃样式与扁平样式的逻辑直接封装进CYLAnimatedItemView中去，这样一来taglist里的tag仅需调用CYLAnimatedItemView里的接口即可完成本次collectionMenu新增样式的需求。sonnet负责实现。并且液态玻璃的实现新的仓库，也可以直接放进CYLAnimatedItemView中。无须新增库。taglist中的圆角逻辑也应调用CYLAnimatedItemView完成，如有自定义需求，也应修改CYLAnimatedItemView core核心代码 在本仓库调用接口实现」 — put the Liquid Glass and flat logic inside `CYLAnimatedItemView`; the tag only calls its interface; no new library; the corner-radius logic goes through it too (a custom need changes the core `CYLAnimatedItemView`, this repository only calls the interface).
2. 「CYLAnimatedItemView不应依赖于cyltabbar，cyltabbar应依赖于CYLAnimatedItemView，如果用到cyltabbar代码，应移动代码放在CYLAnimatedItemView中，暴露接口让cyltabbar代码调用。」 — `CYLAnimatedItemView` must not depend on the tab bar; the tab bar depends on it; code the animated item needs moves into it and is exposed to the tab bar.
3. 「找到本仓库旧的代码…圆角为0时，设置为胶囊样式。复制胶囊样式代码到cylanimateditem，作为液态样式的默认圆角设置。用户无须修改圆角属性即可展示胶囊样式。若用户想修改圆角，仅需修改圆角属性即可自定义圆角。该逻辑修改的是cylanimateditem。不是本仓库」 — the old rule (radius 0 = capsule) moves into `cylanimateditem` as the default corner radius of the Liquid Glass style: no radius property needed for a capsule, set the property to customize. The change is in `cylanimateditem`, not in this repository.
4. 「静态编写代码，等符合测试条件时一次性测试。一次性交付合适session进行测试任务。无须等待ci结果，无须等待其他session处理。代码编写优先，测试 CI放最后统一处理。请advisor制定测试条件满足的标准，并请sonnet执行代码编写与测试任务。」 — write code statically; test once when the conditions hold; hand the tests to the right sessions in one delivery; wait for neither CI nor other sessions; code first, tests last.

5. 「验收标准为所有example仅需在初始化cylanimateditem增加液态样式参数，即可切换样式，无须其他操作。」 — acceptance: every example switches its style by adding the Liquid Glass style parameter where it creates the `cylanimateditem` (the tag list: `backgroundStyle`), with no other step (no color, radius, border, library or setup call). The view's defaults give a capsule glass with that one parameter: iOS `item.itemBackgroundStyle = .liquidGlass`, Android `itemBackgroundStyle = CYLAnimatedItemBackgroundStyle.LiquidGlass`, HarmonyOS `itemBackgroundStyle: CYLAnimatedItemBackgroundStyle.liquidGlass`, mini program `item-background-style="liquidGlass"`; tag list `style.backgroundStyle = .liquidGlass` / config `"backgroundStyle": "liquidGlass"`. Checked in the test batch on every platform: flip that one line in each example, nothing else.

Where it lives now: CYLTabBarController `43ad5f6a` (`feat/harmony-animated-item-engines`, PR #824). `CYLAnimatedItemView` has
`itemBackgroundStyle`, `itemBackgroundColor`, `itemCornerRadius` (unset = capsule for Liquid Glass, square for flat),
`itemBorderWidth`, `itemBorderColor`, `isLiquidGlassActive()`; HarmonyOS also `CYLAnimatedItemBackgroundModifier` for hosts that are not
a view. The tag keeps `CYLTagAppearance.isCornerRadiusSet` (iOS, Android, HarmonyOS, mini program `cornerRadiusSet`): a glass tag whose radius was never
set hands "unset" down; a set radius, 0 (square) included, is used as it is (PR #35 rule).

## Rubric

**100** = tags reach glass, flat, radius and border only through `CYLAnimatedItemView` on every platform, no copy of glass,
blur or capsule code in this repository (grep clean), tests, labeled screenshots, docs, parity maps, other sessions notified.
**60** = iOS done and tested, the config keys parsed everywhere.

## Interface (unchanged names)

`CYLTagBackgroundStyle` `flat` (default) / `liquidGlass`; `CYLMenuStyle.backgroundStyle`, `resolvedBackgroundStyle`, `minimumTagSize`;
config keys `"backgroundStyle"` and `"minimumTagSize"`; the state's `backgroundColor` tints the glass.

## Status (2026-11-24): code on every platform, nothing tested on devices yet

| Platform | Tag calls | Verified |
|:--|:--|:--|
| iOS | `CYLTagButton` sets `itemBackgroundStyle/Color/CornerRadius/Border…` | compile-only before the batch; earlier suites passed on the previous API (menu 37, tag 6, example 121, swift 23) |
| Android | `CYLTagButton` (a `CYLAnimatedItemView`) sets the same properties; 0 is now square (closes the PR #35 gap) | static |
| HarmonyOS | `.attributeModifier(CYLAnimatedItemBackgroundModifier(...))` from the re-vendored `cylanimateditem` | static |
| Mini program | `model.js` calls `cylAnimatedItemBackground(...)` of the vendored `cyl-animated-item` | node tests 173 / 173 |

Compatibility for existing integrators (owner's feedback 2026-11-24, CYLSearchViewController session): every new API is additive and defaults
keep the look (`backgroundStyle` flat, `minimumTagSize` zero). The public constant `CYLTagCornerRadiusSquare` is kept on iOS and HarmonyOS (PR #35 had
removed it); Android keeps its old radius rule (0 is a capsule). No pin or integrator code moves by itself. When an integrator moves its ClassifyMenu pin
it must move its CYLTabBarController pin to the same generation (`43ad5f6a` or later), because the tag now uses `CYLAnimatedItemView.itemBackground…`; that pair is
the only requirement. Open for the owner (PR #35, base of this PR): on iOS, HarmonyOS and the mini program a radius of 0 changed from capsule to square.

Known follow-up: the vendored `cyl-dealloc-block-executor` stays at its current copy until the DeallocBlockExecutor session's
PR #26 merge SHA.

## TODO: the one test batch (what to run, on which machine)

Test conditions (advisor): no copies of glass code in this repository; static checks pass; one CYLTabBarController hash everywhere
(`43ad5f6a`); one push of PR #36; **acceptance: each example flips to Liquid Glass with the one style parameter (prompt 5).**

| Platform / machine | What to test |
|:--|:--|
| Mac, iOS | reboot simulator CB9BDA60, then the four suites (menu, tag, example, swift), `pod lib lint`, the SwiftPM consumer build, Flutter and React Native iOS example builds. |
| Windows, Android | CYLTabBarController: `./gradlew :cylanimateditem:testDebugUnitTest :cyltabbar:testDebugUnitTest :app:assembleDebug`; tab bar glass unchanged on API 33+. ClassifyMenu: `:library:testDebugUnitTest` (new capsule/square/custom radius test), `:example:assembleDebug`, glass tags on API 31 and 34, flat tags look unchanged (radius 3). |
| Windows, HarmonyOS | hvigor build of `cylanimateditem`, `classifymenu`, `entry`; unverified guesses: `.attributeModifier` with `AttributeModifier<CommonAttribute>` on the tag Stack, `.borderRadius(1000)` clamping to a capsule, `.clip(bool)`; then `harmony_parity.py --check` and the api maps. |
| Windows, mini program | WeChat DevTools: a glass tag renders (capsule by default); example pages unchanged. |

## Score

Code written on every platform: iOS 35, Android 20, HarmonyOS 15, mini program 10 = 80 once tested; screenshots and parity maps 10 and
notifications 10 remain. Verified today: mini program node tests; everything else after the batch.
