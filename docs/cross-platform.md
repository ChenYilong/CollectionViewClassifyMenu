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

- **Status:** TODO.
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
