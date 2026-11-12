# Cross-platform consistency

The examples of this project on every platform (iOS, Android, and later React Native, Flutter, HarmonyOS, Mini
Program) show the same screens with the same data and look the same as iOS, which is the reference.

## TODO (2026-11-12): one shared local database for every platform

- **Status:** TODO.
- **Context:** the Android Classify / Filter tabs query a SQLite `places` table made on the device; the iOS demo app
  filters the same places in memory, and `Example/CYLMenuExample` builds its own SQLite database at run time.
- **Requirements:**
  1. iOS uses the Android implementation's approach: the conditions build an SQL query on a local SQLite database,
     and the page shows the conditions, the SQL statement, the count and the rows.
  2. iOS and Android share **one** local database file (the same file in the repository, bundled by each app), so
     the demos show the same data.
  3. Every other platform uses the same database file too, including React Native and Flutter.
- **Prompt (verbatim):**

  > 这个android实现，同步到iOS端实现，共用share 同一个本地数据库 ，保持演示的一致性。相同要求，其他平台也使用同一个数据库。包括RN flutter。将该要求写进跨端相关文档，标注TODO continue

## TODO (2026-11-12): the tag cells look the same as iOS on every platform

- **Status:** Android left spacing DONE (this commit); residual gap and React Native / Flutter TODO.
- **Cause (core):** Android `CYLIndexPathButton` put the image as a compound drawable at the padding edge and
  centered only the text, so the image touched the cell's left edge. iOS `UIButton` centers image and title together,
  then `CYLIndexPathButton -layoutSubviews` moves the image `cyl_imageTitleSpacing / 2` left and the title the same
  right (plus `cyl_titleLeadingInset`). The Android button now computes its padding with the same algorithm (centered
  or start gravity, half spacing, title inset), and the section header's title button starts at 16 with the inset
  between icon and title, as `CYLFilterHeaderView` does on iOS.
- **Pixel comparison** (iOS 27.2 simulator, iPhone 17 Pro, @3x → pt; Android 15 emulator, 2.625x → dp; same data,
  same parameters; `tools`: a CoreGraphics scanner measuring the pill and its content edges):

  | Cell | Platform | Pill | Left padding | Right padding |
  | --- | --- | --- | --- | --- |
  | ★ 展览 扩展文字😀✨ | iOS | 16.0…199.7 (183.7) | 6.0 | 8.7 |
  | ★ 展览 扩展文字😀✨ | Android before | 16.0…193.5 | 0 (image at the edge) | 9.9 |
  | ★ 展览 扩展文字😀✨ | Android after | 16.0…193.5 (177.5) | 8.8 | 9.9 |
  | 美妙下午茶 扩展文字😀✨ | iOS | 16.0…228.7 (212.7) | 10.3 | 12.3 |
  | 美妙下午茶 扩展文字😀✨ | Android after | 16.0…222.5 (206.5) | 10.7 | 10.7 |

  Top to bottom: iOS, Android before, Android after:

  <img src="assets/tag-cell-ios-android-compare.png" width="600" alt="Tag cell: iOS, Android before, Android after">

- **Residual (TODO):** iOS cells are about 6 pt wider and the iOS gap between image and title is about 10 pt against
  4.6 dp, although both use text width + 38 and a spacing of 5. Both come from text measurement: the iOS title label
  is wider than `-sizeWithAttributes:` (Apple Color Emoji / PingFang metrics), and `UIButton` centers within that
  label; Android measures with Noto. Next: log the iOS title label's frame in a test, then decide whether the core
  should size cells from the label's intrinsic width on both platforms.
- **Context:** with the same parameters, the Android classify menu's tag cells differ from iOS: an image sits at the
  cell's left edge on Android, while iOS centers image and title together, so the left padding equals the right one
  (`assets/request-android-cell-left-spacing.png`, `assets/request-ios-cell-reference.png`,
  `assets/request-android-cell-compare.png`).
- **Requirements:**
  1. Compare the iOS and Android tag cells pixel by pixel, the left spacing above all.
  2. Look for the cause in the core (library) first, comparing the two implementations: with the same parameters
     they must look the same.
  3. Every other platform matches iOS too, including React Native and Flutter.
- **Prompts (verbatim):**

  > 该example中 tag cell 左侧间距有问题。优先从core层面找原因修复。因为右侧间距正确。continue

  > 你刚刚实现的android中 该example中 tag cell 左侧间距有问题。优先从core层面找原因修复。因为右侧间距正确。continue

  > 像素级对比iOS与Android端 tag cell实现UI差别。尤其注意左侧间距，android端异常。优先从core层面对比两者实现差别，因为初始化参数都是一样的情况下，显示也应保持一致。同样要求其他端与iOS端保持一致，包括RN flutter。写入跨端相关文档，标记todo。
