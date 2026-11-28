# Liquid Glass tag list: how each platform does it, and how it moves from the tab bar to `CYLAnimatedItemView`

This table explains, per platform, how CYLTabBarController's Liquid Glass tab bar is implemented and how that same scheme is carried
into the tag list through `CYLAnimatedItemView` (the view a tag is built on; its `itemBackgroundStyle = liquidGlass` is what the tag
list sets). One row per platform. **A row is appended when a platform's Liquid Glass tag list is finished**: glass tags, glass board and glass tail fold control in the core, tests green, and one capture over a high-contrast plate that shows blur, not only tint If a platform's tag list
does NOT use the tab bar's scheme, the reason is written in the row and the advisor's assessment of that reason is in
"Deviations and the advisor's assessment" below. Contract of the tag list's own glass options (`backgroundStyle`,
`sectionBackgroundStyle`, the unset-background rule): [tag-liquid-glass.md](tag-liquid-glass.md) and
[tag-section-style.md](tag-section-style.md).

| Platform | How the Liquid Glass tab bar is implemented | How the scheme moves to `CYLAnimatedItemView` (the tag list) |
| --- | --- | --- |
| iOS | The system. On iOS 26 the tab bar is the system `UITabBar`: the glass material, the blur and the lensing of what is behind it are drawn by the system, which always knows what is behind the view. Below iOS 26 the bar is a flat bar (`CYLFlatDesignTabBar` uses a `UIVisualEffectView` blur). | The tag is not a `UITabBar`, so the item draws the SAME system material itself: `CYLAnimatedItemView.itemBackgroundStyle = .liquidGlass` puts a glass effect view (`CYLLiquidGlassView`, a `UIVisualEffectView` with a `UIGlassEffect`: CYLTabBarController `CYLAnimatedItem/Swift/CYLLiquidGlass.swift:60,106`, tinted with the tag's EXPLICIT background color, default frosted tint when unset) behind the tag content; the system samples whatever is behind it (a gradient page shows through, no source is passed). Below iOS 26 the tag is flat. Nothing to expose: no backdrop parameter exists or is needed. The tag list sets `itemBackgroundStyle` from `CYLMenuStyle.backgroundStyle`, and draws the section board the same way from `sectionBackgroundStyle`. |
| HarmonyOS | A blur imitation drawn with ArkUI: `CYLLiquidGlassCapsuleModifier` / `CYLLiquidGlassContainerModifier` (`cyltabbar/CYLLiquidGlass.ets`; API 12 to 21 have no system glass material, so the glass is a blur with a light or dark tint) use the shared constants of `cylanimateditem`'s `CYLLiquidGlass` (blur radius, saturation, light/dark brightness) and ArkUI's `backgroundEffect` / `backgroundBlurStyle`, which sample what is rendered behind the component (the pages) with no source to pass; `CYLLiquidGlass.isActive()` is true on every supported API. | The same constants and the same ArkUI call, through the item: `CYLAnimatedItemBackgroundModifier` (`cylanimateditem/CYLAnimatedItemBackground.ets`) applies `backgroundEffect({radius, saturation, brightness})`, the tint as `backgroundColor`, the corner radius and `clip`, when `itemBackgroundStyle = liquidGlass`; the tag list sets it from `CYLMenuStyle.backgroundStyle` (tags) and `sectionBackgroundStyle` (the board). ArkUI samples what is behind the component, so no backdrop parameter is needed. |
| Mini program | CSS: the tab bar's lens is `backdrop-filter: blur(16px) saturate(180%)` over a translucent tint with a faint top highlight; the browser samples what is painted behind the element in the same stacking context. Where the WebView does not support `backdrop-filter` only the tint stays, as in the tab bar. | The same helper through the item: `cylAnimatedItemBackground` (`cyl-animated-item/cyl_animated_item_model.js`) emits the tint, `backdrop-filter:blur(16px) saturate(180%)` and the highlight when `itemBackgroundStyle = 'liquidGlass'`; `cyl-tag-list` uses it for the tags and for the board (`sectionBackgroundStyle`). Nothing is passed; the list's own background must not be opaque (the example sets a clear list background), or the blur samples that. |
| Android | The tab bar draws its glass ITSELF in its own `draw`: `CYLLiquidGlassTabBarStyle` calls `CYLGlassBackdrop.draw(canvas, pages, ...)` with `pages = tabBarController.pagesContainer`, a SIBLING of the bar (the pages extend under the floating bar): the sibling's views are recorded into a `RenderNode` and a `RenderEffect` blur (API 31+) and a `RuntimeShader` refraction (API 33+) are applied inside the capsule, plus a surface tint, a highlight and an outside shadow. A source that is not an ancestor is what makes the sampling legal. | `CYLAnimatedItemView.itemGlassBackdropSource: View?` (public, default null = the window root) is passed to the item's glass layer (`CYLLiquidGlassView.backdropSource`), so a tag can sample a view that is behind it and is not its ancestor; the stack (`CYLAnimatedItemStackView.itemGlassBackdropSource`) forwards it to the items it hosts. The tag list adds `CYLTagListView.backdropSource: View?` and forwards it to every tag, the tail fold cell and every section board. With no source (null) or an ancestor, the glass draws the frosted tint and a hairline rim only (never invisible); below API 31 the item is flat. See "Deviations" item 2 for the one difference with the tab bar. **Status: pending** (tests green; the striped-plate capture on an API 31+ device and the scroll check below are not done). |

Verified by: iOS compile only so far (the Mac session; no capture in this table); HarmonyOS 180 host tests, 14 emulator UI tests and an emulator capture of the Flows tab (the tail fold control is NOT yet a glass tag there: open); mini program 284 tests, never seen in WeChat DevTools; Android 245 unit tests (8 new for `backdropSource`).

**The board and the tag are one glass.** The section board (`sectionBackgroundStyle = liquidGlass`) is drawn by the same
`CYLAnimatedItemView` glass as a tag capsule, so it has the same blur, the same frosted default tint and the same lit edge (the rim /
top highlight); only the corner radius and the size differ. With no `sectionBackgroundColor` the board hands NO tint (exactly as an unset
glass tag does), so the tag's default frosted tint applies to it. HarmonyOS and the mini program used to give the board a tint of its own
(`cyl_section_glass_tint`, `SECTION_COLORS.*.glassTint`); both are removed (`CYLSectionStyleColors.glassTint` is now the "no color" value;
mini: `resolvedSectionBackgroundColor` is `''` under unset glass). iOS drew an unset board with a plain `UIGlassEffect` view
(`CYLTagListCardView.plainGlassView`); that path is to be removed so the board goes through `CYLAnimatedItemView` too (Mac session).
Android already did. Tests: Android `anUnsetGlassBoardIsTheSameGlassAsAGlassTagNoTintOfItsOwn`, mini `the board shares the glass tag's
tint, blur and edge highlight`, HarmonyOS `theGlassCardTintIsTheAppColorElseTheModeAwareDefault`. Edge-glow capture over a dark, high
contrast plate: still to be taken on each platform.

Platforms not yet in the table: React Native and Flutter (see "Deviations" item 3).

## Deviations and the advisor's assessment

Where a tag list does not simply reuse the tab bar's way of getting the sample, this section says why, and the advisor's assessment of
the reason is recorded here (a platform's row is not final until its assessment is in).

1. **iOS: the tab bar is a system tab bar, the tag is a custom view with the same material.** Reason: tags cannot be `UITabBar` items,
   and the system exposes the glass material to custom views through `UIGlassEffect`. Same system sampling, different container.
2. **Android: the tab bar knows its source, the tag list gets it from the app.** Reason: the tab bar sits beside a known sibling
   (`pagesContainer`); a tag list lives INSIDE the page, so every view that contains it (the window root, the pages) is an ancestor and
   sampling an ancestor is illegal (`isInside()`: it would redraw views that are recording right now). The only legal sources are views
   behind the list that are not ancestors: only the app can name sibling content behind the list, so the library takes it as one parameter and does not guess.
   Follow-up (needs a CYLTabBarController change, the glass view takes a View, not a Drawable): the nearest ancestor's background
   `Drawable` is a legal source (drawing it redraws no recording view) and would cover "a gradient set as the page background" with no wiring.
   Scroll: a tag moves with its list, the tab bar does not. The check on an API 31+ emulator (CYLTabBarController `afc59d1c`, a plate
   behind a `ListView` with the list as its header) showed the glass at rest samples the plate but is NOT resampled after a 600 px swipe
   (the glass samples in `onDraw` only and the child display lists are cached). Fixed in `CYLTagListView` (a pre-draw listener that
   invalidates the glass layers when the list's place in the window or its scroll offsets change); the capture after the fix is still to be taken.
3. **React Native and Flutter (not done), four cases, not one:** React Native renders real native views, so the gradient behind an RN
   tag list is a native view: RN-iOS should already work through the system glass with a clear list background (to verify on the Mac),
   RN-Android needs the bridge to name that view (for example a `nativeID` or ref resolved natively to `backdropSource`). Flutter draws
   its own surface: Flutter-Android cannot record it into a `RenderNode` when the example uses a SurfaceView composition (check which
   mode it uses: a real blocker if so); Flutter-iOS likely samples the Flutter layer beneath (to verify on the Mac). Earlier messages
   saying "Flutter/RN blocked" were too broad.

### Advisor assessment (recorded)

- Item 1 (iOS): sound; cite the code (done above); the below-iOS-26 fallback must be stated as it is (flat for the tag).
- Item 2 (Android): acceptable for v1, but "only the app knows" was too strong (see the ancestor-background follow-up) and the scroll
  behaviour is unverified: the row stays **pending** until the API 31+ capture after the scroll fix is in.
- Item 3 (RN, Flutter): not sound as first written (RN renders native views); rewritten as four cases above.
- HarmonyOS: a possible fourth deviation, checked: tab bar and item both use ArkUI `backgroundEffect` with the shared tokens, so no
  deviation; but the tail fold control is not glass on HarmonyOS yet (open, the examples rule needs it).

## HarmonyOS capture (example page `CYLTagGlassDemoViewController`, 2026-11-26)

`docs/assets/harmonyos-emulator-glass-demo-light.jpeg` and `harmonyos-emulator-glass-demo-dark.jpeg` (emulator, tab bar pin `98966c43`, taken after the example set `cyl_colorMode`):
glass tags, the glass section board and the glass tail fold cell on a black / white / red / blue / green plate. Seen: the board and the tags
both have the lit edge, the tail chevron is now a glass capsule like the tags (it was an opaque capsule), and in dark mode the long header
title "滚动隐藏：模拟意外情况（issue #13）" wraps to two lines with the "More ⌄" fold control in full at the right end (the header-room model).
Not seen: the More and clear icon buttons next to the fold control (the page's data source does not enable them), and the light-mode header
text on the black band and the dark-mode tags on the white band are unreadable, because the plate is a fixed colour set in both modes (a
property of the demo plate, not of the library). No "before" capture was taken.

Dark mode needs the app's color mode: `cylanimateditem` reads AppStorage `cyl_colorMode` ('dark' / 'light'; CYLTabBarController's
`cyl_updateColorMode` sets it, light when unset). An app that uses the tag list without the tab bar module must set the key itself, or
every glass is drawn in its light variant in dark mode (grey, bright tags and board; this is what the first dark captures showed). The
ClassifyMenu example sets it in `EntryAbility` (`syncGlassColorMode`, `onConfigurationUpdate`). Whether `cylanimateditem` should fall back
to the system mode by itself is the owner's decision (tab bar repo); the recaptured dark page now has dark translucent tags and board, the
uniform rim, and the long header title wrapped with "More ⌄" in full.
