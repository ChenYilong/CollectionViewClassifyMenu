---
name: cyl-examples
description: Build example (demo) screens in the CYL projects. A demo that needs a sectioned list uses CollectionViewClassifyMenu's tag list (titles and icons, tail chevron fold control, tap = cell tap, long press = subtitle callout, titleMaxLines) and re-tests contact-list reordering.
---

# Example (demo) screens

Full rules: `docs/instructions/examples.md` (tag `examples`), "Sectioned lists in demos use the tag list". The long-press
contract: `docs/tag-long-press-action.md`.

## When to use

A demo screen needs a table-view-like list with section groups (a table view with sections, a list with section headers,
an inset-grouped list, ArkUI `List` with groups). Build it with the tag list, not with the platform's grouped list.

## How

1. One tag list, one section per group. The section title is the header. A tag shows the **main title and the icon only**.
2. Every example tag list: the tail fold control, icon only (`CYLMenuFoldControl(position: .tail, content: .icon)`; config `"foldControl": {"position": "tail", "content": "icon"}`). The last tag is the chevron button; no More / Less text. Only the fold-styles demo screen shows the other variants.
3. A tap on a tag does what the replaced cell's tap did (open the screen, select the row). Do not leave the tag selected.
4. The secondary line (detail, subtitle) is shown on a **long press** in a small floating callout with an arrow:
   - data: `menuSubtitleForItem` on the data source, `CYLTag.subtitle`, or the item key `subtitle` in a configuration;
   - behavior: `longPressAction = CYLTagLongPressActions.callout`, or `"longPressAction": "callout"` in a configuration;
   - several behaviors: `CYLTagLongPressActions.first([reorder, callout])`; custom: `CYLTagLongPressActions.handler(...)`.
   Never draw a popup in the example.
5. A title that does not fit one line wraps with the style's `titleMaxLines` (default 1). Show every line with the named
   constant `CYLTagTitleMaxLinesUnlimited`; never write a literal such as 0 or 999. The app chooses the number
   (the placeholder example uses 3).
6. The tag list lacks something the example needs: add the API to CollectionViewClassifyMenu first (core first, all
   platforms, documented in `docs/tag-long-press-action.md` or its neighbor), then use it.
7. After the change, **re-test the contact-list long-press reordering** (it is the built-in `reorder` long-press action):
   HarmonyOS `harmony/scripts/unit-test.sh` and `ui-test.sh`, and look at the screen on the emulator.

## A repository that only holds the example

It vendors CollectionViewClassifyMenu's HarmonyOS modules at a pinned commit (record the commit in `VENDORED.md`) and
re-pins `cylanimateditem` to the commit those modules need; never edit the vendored copy by hand.
