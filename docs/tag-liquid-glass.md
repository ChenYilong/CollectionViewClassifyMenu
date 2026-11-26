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
| Tint | Under Liquid Glass only an EXPLICIT state `backgroundColor` tints the glass (the selected tag's tint, alpha 1; a color set by a preset or the app; the pressed color). An UNSET one is ignored: the built-in white is not handed to the glass, so the component's frosted default shows (light 225, 222, 220 at alpha 0.5; dark white at 0.14) and the backdrop shows through. A cleared (alpha 0) color means the same. Flat tags are unchanged (the effective color: explicit, else the built-in). HarmonyOS: `CYLTagAppearance.explicitBackgroundColor` / `isBackgroundColorSet` (undefined / false while unset; the default is never stored), `CYLTagButton.glassTintColor` hands `CYLTagButton.GLASS_DEFAULT_TINT` (a transparent color, which `CYLAnimatedItemBackgroundModifier` reads as "no color") instead; the configuration parser leaves a state without a `backgroundColor` key unset. Android: `CYLTagAppearance.explicitBackgroundColor` (null while never set; the built-in white / secondary system background does not count) is what `CYLTagButton` hands to `itemBackgroundColor` where glass is really drawn; the fold control and the outlined create cell copy a background only when it is set. Flat tags (and glass where none is drawn) are unchanged: the effective color. No new setter. |
| Effective style | One function, `resolvedBackgroundStyle`: `liquidGlass` only when the platform's gate below is open; otherwise `flat` and every other parameter is unchanged. |
| Radius | The glass is clipped to the resolved corner radius (PR #35: `min(radius, height / 2)`). |

## Owner's decisions 2026-11-24 (latest wins; they replace the "separate base library" design)

Prompts, verbatim, with English:

1. 「我想将液态玻璃样式与扁平样式的逻辑直接封装进CYLAnimatedItemView中去，这样一来taglist里的tag仅需调用CYLAnimatedItemView里的接口即可完成本次collectionMenu新增样式的需求。sonnet负责实现。并且液态玻璃的实现新的仓库，也可以直接放进CYLAnimatedItemView中。无须新增库。taglist中的圆角逻辑也应调用CYLAnimatedItemView完成，如有自定义需求，也应修改CYLAnimatedItemView core核心代码 在本仓库调用接口实现」 — put the Liquid Glass and flat logic inside `CYLAnimatedItemView`; the tag only calls its interface; no new library; the corner-radius logic goes through it too (a custom need changes the core `CYLAnimatedItemView`, this repository only calls the interface).
2. 「CYLAnimatedItemView不应依赖于cyltabbar，cyltabbar应依赖于CYLAnimatedItemView，如果用到cyltabbar代码，应移动代码放在CYLAnimatedItemView中，暴露接口让cyltabbar代码调用。」 — `CYLAnimatedItemView` must not depend on the tab bar; the tab bar depends on it; code the animated item needs moves into it and is exposed to the tab bar.
3. 「找到本仓库旧的代码…圆角为0时，设置为胶囊样式。复制胶囊样式代码到cylanimateditem，作为液态样式的默认圆角设置。用户无须修改圆角属性即可展示胶囊样式。若用户想修改圆角，仅需修改圆角属性即可自定义圆角。该逻辑修改的是cylanimateditem。不是本仓库」 — the old rule (radius 0 = capsule) moves into `cylanimateditem` as the default corner radius of the Liquid Glass style: no radius property needed for a capsule, set the property to customize. The change is in `cylanimateditem`, not in this repository.
4. 「静态编写代码，等符合测试条件时一次性测试。一次性交付合适session进行测试任务。无须等待ci结果，无须等待其他session处理。代码编写优先，测试 CI放最后统一处理。请advisor制定测试条件满足的标准，并请sonnet执行代码编写与测试任务。」 — write code statically; test once when the conditions hold; hand the tests to the right sessions in one delivery; wait for neither CI nor other sessions; code first, tests last.

5. 「验收标准为所有example仅需在初始化cylanimateditem增加液态样式参数，即可切换样式，无须其他操作。」 — acceptance: every example switches its style by adding the Liquid Glass style parameter where it creates the `cylanimateditem` (the tag list: `backgroundStyle`), with no other step (no color, radius, border, library or setup call). The view's defaults give a capsule glass with that one parameter: iOS `item.itemBackgroundStyle = .liquidGlass`, Android `itemBackgroundStyle = CYLAnimatedItemBackgroundStyle.LiquidGlass`, HarmonyOS `itemBackgroundStyle: CYLAnimatedItemBackgroundStyle.liquidGlass`, mini program `item-background-style="liquidGlass"`; tag list `style.backgroundStyle = .liquidGlass` / config `"backgroundStyle": "liquidGlass"`. Checked in the test batch on every platform: flip that one line in each example, nothing else.

6. 「advisor 评估验收是否通过、通过后sonnet开始修改example将example中所有tag改为液态样式。格外注意选中后的背景颜色是否符合预期。预期是example为taglist初始化时传入一个液态样式参数就可以完成example的液态tag改造。并通知相关使用了本仓库的集成方也在example中修改初始化参数完成液态tag改造。本要求适用于所有平台。iOS Android 鸿蒙小程序 rn flutter」 — the advisor assesses whether acceptance passes; once it does, Sonnet changes the examples so every tag in every example is a Liquid Glass tag. Pay special attention to the background color after selection. Expected: an example needs only one Liquid Glass style parameter when it creates the tag list. Tell the integrators that use this repository to change their examples' initialization parameter the same way. Applies to all platforms: iOS, Android, HarmonyOS, mini program, React Native, Flutter.
   - Advisor's assessment (2026-11-24): acceptance NOT passed as a whole: iOS green (menu 37, tag 6, example 124, swift 23, CYLAnimatedItemBackgroundTests 8); Android, HarmonyOS, React Native, Flutter and the mini program in DevTools still unverified. The selected-color check found that an opaque tint hid the glass or darkened the selected tag: fixed in the view with one translucent tint rule (alpha x 0.75, owner's choice "stronger"), on every platform.

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
config keys `"backgroundStyle"` and `"minimumTagSize"`; the state's explicit `backgroundColor` tints the glass (Android: unset = `explicitBackgroundColor` null = frosted default).

## Status (2026-11-24): code on every platform, nothing tested on devices yet

| Platform | Tag calls | Verified |
|:--|:--|:--|
| iOS | `CYLTagButton` sets `itemBackgroundStyle/Color/CornerRadius/Border…` | compile-only before the batch; earlier suites passed on the previous API (menu 37, tag 6, example 121, swift 23) |
| Android | `CYLTagButton` (a `CYLAnimatedItemView`) sets the same properties; 0 is now square (closes the PR #35 gap) | static |
| HarmonyOS | `.attributeModifier(CYLAnimatedItemBackgroundModifier(...))` from the re-vendored `cylanimateditem` | static |
| Mini program | `model.js` calls `cylAnimatedItemBackground(...)` of the vendored `cyl-animated-item` | node tests 173 / 173. Under glass only an EXPLICIT state background reaches the glass (the appearance has `backgroundExplicit`: true for a valid, non-transparent color set by the app or a preset and for the selected default tint, false for the default fill, which never counts as explicit); an unset normal / disabled background hands an empty color so the frosted default shows (225, 222, 220 at 0.5 light, white 0.14 dark); explicit colors keep alpha x 0.75, the selected tint alpha 1; flat and inactive glass are unchanged (`test/tag-glass-background.test.js`, written statically, not yet run) |

Corner radius rule (owner's decision 2026-11-24, relayed by the CYLSearchViewController session and confirmed by the owner in this session; breaking on purpose,
the pins of integrators move together later): 「统一，圆角逻辑。0就是方。胶囊用1000，但需要使用宏定义定义1000。用户应通过宏定义传入而非传入魔法数字。其他值没有特殊含义。删除CYLTagCornerRadiusSquare。」 — one rule: the
radius is plain points limited to half the height, 0 is square, a capsule is the one named constant whose value is 1000 and users pass the constant, never the number;
no other value has a special meaning; `CYLTagCornerRadiusSquare` is deleted. The owner's answer in this session: apply it everywhere; the unset radius of `CYLAnimatedItemView` is a capsule for the Liquid Glass style only (flat stays square: owner's correction later the same day).
A ClassifyMenu tag does not use "unset": its appearance's default radius IS the capsule constant (`CYLTagCornerRadiusCapsule`), so default flat and Liquid Glass
tags are capsules and are handed to the view as a plain number; the presets that set a radius keep it.

| Platform | Capsule constant (value 1000), defined once in `CYLAnimatedItemView`'s module | 0 |
|:--|:--|:--|
| iOS | `cylAnimatedItemCornerRadiusCapsule` (`CYLAnimatedItemView.swift`) | square |
| Android | `CYLAnimatedItemCornerRadiusCapsule` (`com.cyl.animateditem`) | square (was a capsule: breaking) |
| HarmonyOS | `CYLAnimatedItemCornerRadiusCapsule` (exported by `cylanimateditem`) | square |
| Mini program | `cylAnimatedItemCornerRadiusCapsule` (`cyl_animated_item_model.js`) | square |

ClassifyMenu has no capsule constant of its own any more (`CYLTagCornerRadiusCapsule` was removed the same day): the tag default and the presets use the
animated item's constant.

Everything else is additive: `backgroundStyle` flat by default, `minimumTagSize` zero. When an integrator moves its ClassifyMenu pin it moves its
CYLTabBarController pin to the same generation (`43ad5f6a` or later): the tag uses `CYLAnimatedItemView.itemBackground…`.

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

## Dark glass contrast (title and icon)

In dark mode the default frosted glass is white at 0.14 over the backdrop (about #242424 over black), so a dark explicit title or
icon color can all but vanish. Since 2026-11-26 the rule lives in ONE place, the shared `CYLAnimatedItemContrast` of the
CYLTabBarController `CYLAnimatedItem` module (iOS `CYLAnimatedItemContrast.swift`; Android `CYLAnimatedItemContrast.kt`, HarmonyOS
`CYLAnimatedItemContrast.ets`, mini program `cyl_animated_item_contrast.js`, CYLTabBarController `e014028f`). ClassifyMenu's own iOS
`CYLIconContrast` (which also judged the glass over a bright blue backdrop) is removed.

Rule (the shared rule of every CYLAnimatedItem platform; constants `titleMinimumContrast` 4.5, `iconMinimumContrast` 3, `frostedWhiteAlpha` 0.14,
`defaultTintShare` 0.75, `lightnessStep` 0.005):

1. ONE reference luminance, the glass over black: no glass tint or tint alpha 0, the WCAG luminance of grey 0.14; else the luminance
   of the tint's sRGB components times `tint.alpha * (tintAlpha ?? 0.75)` (a selected tag tints at alpha 1).
2. Contrast = (max + 0.05) / (min + 0.05) of the two luminances. At least the minimum (title text 4.5, icon or animation tint 3):
   the color is unchanged.
3. Else the lightness (HSL) rises in steps of 0.005, hue, saturation and alpha kept, up to white, until the contrast reaches the minimum.
4. A dynamic color (its light and dark values differ) is unchanged. Pure and deterministic. Light glass is not adapted.

Applied only when glass is really drawn AND the mode is dark AND the color is EXPLICIT (set by the app). On an iOS tag (CYLTabBarController `f1673f32`; the Android, HarmonyOS and mini program ClassifyMenu rows below still use their local icon-only lift until they move to the shared rule): the style's
explicit `textColor` of the state (title, 4.5) and its explicit `iconColor` (icon and animation tint, 3; an icon that only follows the text color
is not lifted by itself). The built-in colors are never touched; light mode, flat tags, colors that already pass and dynamic colors never change.

iOS wiring: `CYLAnimatedItemView` lifts its own explicit colors (the item's or the stack's `itemAppearance` icon color, the
`titleTextAttributes` title color, a fixed `animationTint`). A tag hands its EXPLICIT title colors (normal, selected, disabled) to the item as
its `itemAppearance` `titleTextAttributes` colors (`CYLTagButton.handExplicitTitleColorsToItem`), so every state's title goes through the item's one
title pipeline, including the dark glass adaptation; an unset state keeps the effective label color the tag sets. The icon color is still handed as the
subclass level (`applyIconTintColor`), which the item treats as built-in, so the tag calls `CYLAnimatedItemContrast.adjustedIcon` itself; the animation
follows the lifted icon color (`animationTint = "title"`).

| Platform | Status |
|:--|:--|
| iOS | `CYLAnimatedItemContrast` (CYLTabBarController module), applied in `CYLAnimatedItemView` and `CYLTagButton`; compiled, not yet run |
| Android | `CYLIconContrast.kt`; `CYLTagButton.updateAppearance` lifts the icon color filter (night mode = `CYLSystemColors.isNight`, glass = `resolvedBackgroundStyle`, explicit = `CYLMenuStyle.explicitIconColorForState`); `CYLIconContrastTest`, written statically, not yet run. |
| HarmonyOS | `CYLIconContrast` (`core/CYLIconContrast.ets`, exported from `Index.ets`); `CYLMenuStyle.explicitIconColor(state)` tells an explicit icon color from the built-in; `CYLTagButton.updateAppearance` lifts the tint when `resolvedBackgroundStyle()` is glass and `CYLTagButton.isDarkMode()` (AppStorage `cyl_colorMode`, as `cylanimateditem`; `darkModeOverride` for tests). Static '#RRGGBB' / '#AARRGGBB' strings only: resources and `Color` constants are dynamic, so unchanged. Tests: `entry/src/test/IconContrast.test.ets`, written statically, not yet compiled or run. A mode switch while a tag is shown re-resolves at the tag's next `updateAppearance` (no watcher on the mode yet) |
| Mini program | `model.js`: `liftedIconColor`, `glassReferenceLuminance`, `contrastRatio`, `hslFromRgb`, `rgbFromHsl`, `relativeLuminance`; `drawnIconColor(style, state)` feeds the symbol icon of `iconContent`. Explicit = the appearance's `iconColor` (null by default, so nothing to track). Dark = `style.sectionPalette.dark` (the section style's detection); glass drawn = `backgroundStyle === 'liquidGlass'` and `cylAnimatedItemLiquidGlassIsActive()` (`isGlassDrawn`, the predicate of the glass background). Colors are static strings, so there is no dynamic case; the Mini Program has no separate animation tint. `test/tag-icon-lift.test.js`, written statically, not yet run |
| Flutter | through the native Android / iOS cores: the platform view passes the configuration map to the core, so `style.normal.iconColor` (also `selected`, `disabled`) gets the lift there. No new parameter and no Dart key: the configuration is an untyped map and `iconColor` already exists inside a state dictionary of `style` |
| React Native | the same: the bridge forwards the configuration JSON to the native cores (generic pass-through). `style.normal.iconColor` is now typed as `CylTagStateStyle.iconColor` in `CylTagListConfiguration.ts`; it only types the key the core already reads, there is no new bridge code |

## Known limitation: Android glass tags in a list are tinted only (2026-11-24)

A Liquid Glass tag in a list has the root view as its backdrop source, which contains the tag itself: sampling it re-enters the tag's own recording (a crash found by the
Windows Android run on 4bc1ec1). CYLTabBarController `a5a2f1b1` makes `CYLLiquidGlassView` skip sampling when the view is inside its own source: it draws the tint only
(no blur or refraction), and `CYLGlassBackdrop` guards the capture. iOS draws real glass. True glass for a list needs a backdrop source outside the list: `CYLTagListView.backdropSource` (docs/tag-section-style.md "Android backdropSource"); without it Android tags look like the default frosted tint (225, 222, 220 at 0.5 alpha, white 0.14 in dark mode).

## Default glass tint: one low alpha for tags and boards (iOS, 2026-11-26)

- Under glass with no explicit background color, a tag and a section board (`sectionBackgroundColor` unset) both get `CYLMenuStyle.defaultGlassTint`: 225, 222, 220 in light mode at `defaultGlassTintAlphaLight` 0.10, white in dark mode at `defaultGlassTintAlphaDark` 0.04, handed with `itemGlassTintAlpha` 1 (its own alpha is the tint). The component's own default (0.5 / 0.14) greyed the board interior (white minus black through it: light 95.5 to 67.4, dark 78.4 to 70.4 at `affb5bc8`); the lit edge stays.
- The two alphas are estimates until the placeholder session measures them; they are the lever. Explicit colors are untouched (tags: tint x 0.75, selected 1; boards: as set). The other platforms still use the component default (0.5 / 0.14) until they port these two constants.

## No default border under glass (iOS, 2026-11-26)

- `CYLTagAppearance` tracks the border like the background: `isBorderColorSet` / `isBorderWidthSet` (true after an assignment by the app, a configuration or a preset; the style's built-in border, set by `CYLMenuStyle.init` through `applyBuiltInBorder`, is not explicit; `copy()` and `reset()` keep or clear the flags). `glassBorderColor` / `glassBorderWidth` are the border handed to drawn glass; the explicit COLOR decides (as Android, HarmonyOS and the mini program): an explicit color draws the border with the explicit width, else the default width; a width alone, or nothing explicit, draws none (width 0).
- `CYLTagButton`: under drawn Liquid Glass a tag (and the tail fold cell, which copies the tag's border with its explicitness) gets no border unless one is explicit, so the shared glass rim shows, as on the board; the selected built-in app-tint border is dropped too. Flat tags, and glass requested but not drawn, keep the effective border exactly.
