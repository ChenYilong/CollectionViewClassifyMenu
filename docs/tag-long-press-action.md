# Long-press action and the subtitle callout (CYLTagListView)

One contract for every platform. The list owns the long-press gesture; a **long-press action** owns what it does.
The events (`menuDidLongPressItem`, `tagLongPressHandler`) stay notifications: the built-in actions report them, and they
never change the behavior. Designed by the advisor on 2026-11-25; HarmonyOS is implemented, the other platforms follow.

## Interfaces

| Part | HarmonyOS (done) | Contract |
| --- | --- | --- |
| Action | `CYLTagLongPressAction` | `canBegin(host, indexPath)`, `begin(host, indexPath) -> follows`, optional `end(host, destination, moved)` and `cancel(host)` |
| Host (the list as an action sees it) | `CYLTagLongPressHost` | `subtitleForItem`, `showCallout(text, indexPath)`, `dismissCallout`, `canReorderItem`, `beginReordering`, `endReordering(destination, moved)`, `cancelReordering`, `reportLongPress` |
| Built-in actions | `CYLTagLongPressActions.reorder / report / callout / none`, `handler(closure)`, `first([...])` | `reorder` picks the item up (the data-source move stays in the core); `report` only reports; `callout` shows the subtitle and reports; `none` does nothing; `first` gives the press to the first action whose `canBegin` passes |
| Property | `CYLTagListState.longPressAction` | The default is `first([reorder, report])`: byte for byte the behavior before this API existed |
| Data | `CYLMenuDataSource.menuSubtitleForItem`, `CYLTag.subtitle`, item key `subtitle` | The subtitle is also the item's accessibility hint when the data source gives none |
| Configuration | list key `longPressAction` | `"reorder"`, `"callout"`, `"report"`, `"none"`, or an array (the first that can begin wins). A list without `"none"` and without `"report"` gets `report` appended, so a tag without a subtitle is still reported |

## The callout (same on every platform)

- A small bubble with an arrow pointing at the tag, above it (below when there is no room), text up to 3 lines, font 13.
- Dismissed by a tap, a scroll, a reload, another long press, or when the list goes away.
- **The release that ends a long press must not tap or select the item.** (On HarmonyOS the release fired a tap after the
  long press, which selected the tag and dismissed the callout: fixed by ignoring the next tap of the item after a
  recognized long press and clearing that on the next touch down.)

## Status

| Platform | State |
| --- | --- |
| HarmonyOS | Done in `harmony/classifymenu` (`bindPopup` with an arrow on the item). Host tests 90/90, ui-test 14/14, seen on the HarmonyOS 6.0.1 x86_64 emulator: `assets/harmonyos-6.0.1-api21-mate70pro-emulator-x86_64-tag-long-press-callout-20261125.jpeg` (raw screenshot, not a labeled sheet; the demo is the "configuration" page, `menu/map-configuration.json`). |
| Android | TODO: `PopupWindow` with a bubble drawable |
| Mini program | TODO: a positioned view with a CSS triangle, property `long-press-action`, event `taglongpress` {section, item, title, subtitle} |
| iOS | TODO: a custom `CYLTagCalloutView` overlay (not an adaptive popover); the Mac session verifies |
