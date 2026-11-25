# Liquid Glass tag list: how each platform does it, and how it moves from the tab bar to `CYLAnimatedItemView`

This table explains, per platform, how CYLTabBarController's Liquid Glass tab bar is implemented and how that same scheme is carried
into the tag list through `CYLAnimatedItemView` (the view a tag is built on; its `itemBackgroundStyle = liquidGlass` is what the tag
list sets). One row per platform. **A row is appended when a platform's Liquid Glass tag list is finished.** If a platform's tag list
does NOT use the tab bar's scheme, the reason is written in the row and the advisor's assessment of that reason is in
"Deviations and the advisor's assessment" below. Contract of the tag list's own glass options (`backgroundStyle`,
`sectionBackgroundStyle`, the unset-background rule): [tag-liquid-glass.md](tag-liquid-glass.md) and
[tag-section-style.md](tag-section-style.md).

| Platform | How the Liquid Glass tab bar is implemented | How the scheme moves to `CYLAnimatedItemView` (the tag list) |
| --- | --- | --- |
| iOS | The system. On iOS 26 the tab bar is the system `UITabBar`: the glass material, the blur and the lensing of what is behind it are drawn by the system, which always knows what is behind the view. Below iOS 26 the bar is a flat bar. | The tag is not a `UITabBar`, so the item draws the SAME system material itself: `CYLAnimatedItemView.itemBackgroundStyle = .liquidGlass` puts a glass effect view (`UIGlassEffect` in a `UIVisualEffectView`, tinted with the tag's EXPLICIT background color, default frosted tint when unset) behind the tag content; the system samples whatever is behind it (a gradient page shows through, no source is passed). Below iOS 26 the tag is flat. Nothing to expose: no backdrop parameter exists or is needed. The tag list sets `itemBackgroundStyle` from `CYLMenuStyle.backgroundStyle`, and draws the section board the same way from `sectionBackgroundStyle`. |
| HarmonyOS | A blur imitation drawn with ArkUI: `CYLLiquidGlassTabBar` (`cyltabbar/CYLLiquidGlass.ets`) uses the shared constants of `cylanimateditem`'s `CYLLiquidGlass` (blur radius, saturation, light/dark brightness) and ArkUI's `backgroundEffect` / `backgroundBlurStyle`, which sample what is rendered behind the component (the pages) with no source to pass; `CYLLiquidGlass.isActive()` is true on every supported API. | The same constants and the same ArkUI call, through the item: `CYLAnimatedItemBackgroundModifier` (`cylanimateditem/CYLAnimatedItemBackground.ets`) applies `backgroundEffect({radius, saturation, brightness})`, the tint as `backgroundColor`, the corner radius and `clip`, when `itemBackgroundStyle = liquidGlass`; the tag list sets it from `CYLMenuStyle.backgroundStyle` (tags) and `sectionBackgroundStyle` (the board). ArkUI samples what is behind the component, so no backdrop parameter is needed. |
| Mini program | CSS: the tab bar's lens is `backdrop-filter: blur(16px) saturate(180%)` over a translucent tint with a faint top highlight; the browser samples what is painted behind the element in the same stacking context. Where the WebView does not support `backdrop-filter` only the tint stays, as in the tab bar. | The same helper through the item: `cylAnimatedItemBackground` (`cyl-animated-item/cyl_animated_item_model.js`) emits the tint, `backdrop-filter:blur(16px) saturate(180%)` and the highlight when `itemBackgroundStyle = 'liquidGlass'`; `cyl-tag-list` uses it for the tags and for the board (`sectionBackgroundStyle`). Nothing is passed; the list's own background must not be opaque (the example sets a clear list background), or the blur samples that. |
| Android | The tab bar draws its glass ITSELF in its own `draw`: `CYLLiquidGlassTabBarStyle` calls `CYLGlassBackdrop.draw(canvas, pages, ...)` with `pages = tabBarController.pagesContainer`, a SIBLING of the bar (the pages extend under the floating bar): the sibling's views are recorded into a `RenderNode` and a `RenderEffect` blur (API 31+) and a `RuntimeShader` refraction (API 33+) are applied inside the capsule, plus a surface tint, a highlight and an outside shadow. A source that is not an ancestor is what makes the sampling legal. | `CYLAnimatedItemView.itemGlassBackdropSource: View?` (public, default null = the window root) is passed to the item's glass layer (`CYLLiquidGlassView.backdropSource`), so a tag can sample a view that is behind it and is not its ancestor; the stack (`CYLAnimatedItemStackView.itemGlassBackdropSource`) forwards it to the items it hosts. The tag list adds `CYLTagListView.backdropSource: View?` and forwards it to every tag, the tail fold cell and every section board. With no source (null) or an ancestor, the glass draws the frosted tint and a hairline rim only (never invisible); below API 31 the item is flat. See "Deviations" for the one difference with the tab bar. |

Platforms not yet in the table (no finished Liquid Glass tag list): React Native, Flutter (see "Deviations").

## Deviations and the advisor's assessment

Where a tag list does not simply reuse the tab bar's way of getting the sample, this section says why, and the advisor's assessment of
the reason is recorded here (a platform's row is not final until its assessment is in).

1. **iOS: the tab bar is a system tab bar, the tag is a custom view with the same material.** Reason: tags cannot be `UITabBar` items,
   and the system exposes the glass material to custom views only through `UIGlassEffect`. Same system sampling, different container.
2. **Android: the tab bar knows its source, the tag list gets it from the app.** Reason: the tab bar sits beside a known sibling
   (`pagesContainer`); a tag list lives INSIDE the page, so every view that contains it (the window root, the pages) is an ancestor and
   sampling an ancestor is illegal (`isInside()`: it would redraw views that are recording right now). The only legal sources are views
   behind the list that are not ancestors: only the app knows which one (a sibling plate drawn behind the list), so the library takes
   it as one parameter and does not guess.
3. **React Native, Flutter (not done):** a Flutter / React Native screen is drawn by that framework; the native tag list is a
   platform view, so the native glass cannot see what the framework draws behind it. This is a different problem from the tab bar's,
   not a reuse of its scheme.

_Advisor assessment: pending (to be written below when the advisor has reviewed items 1 to 3)._
