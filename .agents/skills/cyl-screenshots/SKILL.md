---
name: cyl-screenshots
description: Take, label and stitch screenshots for CollectionViewClassifyMenu (one column, two when taller than a phone screen; header and footer with the test environment and purpose). Use whenever a screenshot goes into docs/ or README.md.
---

# Screenshots: take, label, stitch

Rules: AGENTS.md, "CI/CD and Example screenshots" (where screenshots go, labels, quality, key moments, cropping) and
the updates of 2026-11-18 ("stitching layout, update", "header and footer"). This skill is the checklist.

## Layout

- One column first: panels top to bottom, in step or time order.
- Two columns and several rows (filled left to right, then top to bottom) when the one-column image, header and
  footer included, would be longer than one screen of an ordinary phone: taller than 19.5:9, i.e. height > 2.17 x
  width (an iPhone 17 Pro screen is 1206 x 2622 px). Never more than two columns. (Update of 2026-11-18, replacing
  "two columns by default".)
- Panels: the same size (one crop rectangle for all), original pixels (no scaling, no recompression), whole elements
  (never cut through a row of controls or a tag).

## Header, captions, footer

Each has its own band; no text is drawn on a screenshot, and no band overlaps or covers a panel. White background,
a thin gray rule under the header and above the footer. English only.

| Band | Style | Content |
| --- | --- | --- |
| Header | red `#FF3B30`, bold | `Purpose:` what the test checks, the expected result, the commit of the change under test. `Platform:` simulator / emulator platform and device, simulator OS version `\| Host:` host OS version `\| IDE:` IDE version |
| Panel caption | red, bold, above the panel | step number, state or action, time offset, screen or launch argument, measurement |
| Footer | dark gray, regular | `Result:` the measured outcome. `Versions:` this repository's branch and commit, dependency commits, engine versions. `Taken:` local date, time and time zone `\| Stitched by` the script |

Fields per platform:

| Platform | Device and OS | Tools |
| --- | --- | --- |
| iOS | Simulator device, iOS version | Xcode version, macOS version |
| Android | emulator (AVD), API level | Android Studio or Gradle, JDK, host OS |
| HarmonyOS | emulator name, HarmonyOS version, CPU ABI | DevEco Studio version, host OS |
| Mini Program | WeChat DevTools simulator, base library version | WeChat DevTools version, host OS |
| Flutter / React Native | the platform fields above | Flutter or React Native version |

Get the values, never guess them: `sw_vers -productVersion`, `xcodebuild -version`, `xcrun simctl list devices`,
`Podfile.lock` (engine versions), `git rev-parse --short HEAD`, `date '+%Y-%m-%d %H:%M %Z'`.

## Tool

```sh
swift scripts/stitch-screenshots.swift --out docs/assets/<name>.png [--columns auto|1|2] [--crop x,y,w,h] \
  --header "Purpose: ..." --header "Platform: ... | Host: ... | IDE: ..." \
  --footer "Result: ..." --footer "Versions: ..." --footer "Taken: ... | Stitched by scripts/stitch-screenshots.swift" \
  "1. <caption>::<image>" "2. <caption>::<image>" ...
```

## Example

- `docs/assets/ios-rive-rest.png`: the first version. Kept: a red bold header with the platform, simulator, Xcode,
  dependency commit, branch, date and purpose; a red bold caption above each panel in its own band. Missing: the
  host OS, a footer, two columns; a panel cut through the Shapes row.
- `docs/assets/ios-rive-rest-one-column.png`: two cropped panels, short enough for one column.
- `docs/assets/ios-rive-rest-then-play-grid.png`: four full screens; one column would be taller than a phone screen,
  so two columns (2 x 2), with header, captions and footer.

## Checklist before committing a screenshot

1. One column, or two when one column would be taller than a phone screen; panels in order, same size, whole elements.
2. Header: purpose, platform and device, simulator OS version, host OS version, IDE version.
3. Captions above every panel; footer: result, versions, time taken with time zone.
4. Nothing overlaps a panel; all text in English; original pixels.
5. Saved in `docs/assets/` (English, lowercase, hyphens), shown in the related document with a table row or caption.
