# Android (Kotlin): the merged library

The library is `library` (package `com.cyl.classifymenu`); see `docs/android.md` and `docs/android-api.md` at the repository root.

## Real glass in a list: `backdropSource`

Liquid Glass tags and boards in a list sample the window root by default, which contains the list, so they draw only a tint
and a rim. Give the list a view BEHIND it that is NOT its ancestor (a sibling plate) and the glass blurs and refracts it
(Android 12+ blur, Android 13+ refraction; below that the frosted tint + rim stays). One property covers every tag, the fold
control and the section boards, also after a reload:

```kotlin
val root = FrameLayout(context)
val plate = View(context).apply { background = GradientDrawable(GradientDrawable.Orientation.TL_BR, intArrayOf(Color.rgb(255, 154, 158), Color.rgb(250, 208, 196))) }
val list = CYLTagListView(context)
root.addView(plate, FrameLayout.LayoutParams(MATCH_PARENT, MATCH_PARENT)) // behind the list, a sibling of it
root.addView(list, FrameLayout.LayoutParams(MATCH_PARENT, WRAP_CONTENT))
list.backdropSource = plate // never an ancestor of the list (root would draw tint + rim only); null restores the default
```

## Section card, header divider and tint (the default look changed)

A tag list now shows each section's tags on a rounded card by default (`sectionStyle` `insetGrouped`). If you never set
`backgroundColor`, the list background becomes the grouped background (#F2F2F7; black in dark mode). The header divider is
**off** by default. The header band (`headerBackgroundColor`) is off by default too.

Properties of `CYLMenuStyle`, or keys of the configuration's `style`:

- Remove the card: `style.sectionStyle = CYLSectionStyle.CYLSectionStylePlain` (configuration `"sectionStyle": "plain"`).
- Show the header divider: `headerSeparatorStyle` `line`, optionally with `headerSeparatorColor`, `headerSeparatorThickness`
  (default 0.5) and `headerSeparatorInsets` (default 0: it spans the same left and right edges as the card and the band).
- Optional header band: `headerBackgroundColor`, with `headerCornerRadius` and `headerContentInsets`.
- The card: `sectionBackgroundColor`, `sectionCornerRadius` (default 10), `sectionContentInsets` (default 12), `sectionBoardInset` (the content column's inset inside the board on both sides; unset: the
  leading / trailing parts of `sectionContentInsets`, 12; a set value, 0 included, overrides them), and
  `sectionBackgroundStyle` `flat` (default) or `liquidGlass` (falls back to flat where the platform cannot draw glass).
- `tintColor`: the one color of the built-in header title, icon and More / Less control. Left out, it is black or white,
  whichever is legible on the background behind them.
- Every new color adapts to light and dark mode by itself; a color you set wins in both modes.

### Migration: the default look changed

This is a breaking visual change: a list that sets nothing now shows the rounded card and the grouped background. To get the
old look, set `sectionStyle` to `plain`. Screenshots and tests that depend on pixel positions need updating.

```kotlin
val style = CYLMenuStyle()
style.sectionStyle = CYLSectionStyle.CYLSectionStylePlain                        // remove the card (the old look)
style.headerSeparatorStyle = CYLHeaderSeparatorStyle.CYLHeaderSeparatorStyleLine // show the divider (off by default)
style.headerBackgroundColor = 0xFFEFEFF4.toInt()                                 // optional band
style.sectionBackgroundStyle = CYLTagBackgroundStyle.CYLTagBackgroundStyleLiquidGlass
style.tintColor = 0xFF007AFF.toInt()
```

Colors are ARGB `Int` values; lengths are dp; insets are `CYLEdgeInsets(top, left, bottom, right)`.

```json
{
  "style": {
    "sectionStyle": "plain",
    "headerSeparatorStyle": "line",
    "headerSeparatorColor": "#C6C6C8",
    "headerSeparatorThickness": 0.5,
    "headerSeparatorInsets": [0, 0, 0, 0],
    "headerBackgroundColor": "#EFEFF4",
    "sectionBackgroundStyle": "liquidGlass",
    "tintColor": "#007AFF"
  }
}
```
