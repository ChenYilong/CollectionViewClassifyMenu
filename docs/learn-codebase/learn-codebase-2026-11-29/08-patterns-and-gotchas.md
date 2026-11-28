# Cross-platform patterns and gotchas

1. iOS is the reference for names and behavior; check parity files (docs/android-ios-api.md, harmony/parity-map.json)
   when public API changes. For the section card style the HarmonyOS component is named as the reference
   (mini program tag-section-style test comment).
2. Explicit vs built-in values matter everywhere. Setting a color, even to its default, changes glass and contrast
   behavior.
3. Dark Liquid Glass lifts only explicit colors for contrast (title 4.5, icon 3, per the mini program test comments).
4. Default look is a card (insetGrouped); tag cloud / container / grid / word picker / classify / filter presets are
   plain. Old frame expectations need the plain style.
5. Widths and fold decisions use the tag column, never the view width. A card narrows the tags, so they wrap earlier.
6. Style identity: return the same style object while unchanged.
7. Stored and queried titles are the Chinese source titles; translate only for display. Long sample titles carry
   suffixes (" 扩展文字😀✨", " 🏙️ 扩展文字") that display helpers translate separately.
8. Cache layout is shared: section titles plus "<section>#items" with U+001F. A renamed tag keeps its identifier.
9. A tag's id is identifier, else title.
10. Animated icons come from engines registered or found at run time; the core adds no engine dependency.
11. Generated files are never edited by hand (strings exports, parity tables, places database, lottie data).
12. Vendored folders are changed upstream and copied again.
13. Windows: Git Bash needs MSYS_NO_PATHCONV=1 for hdc shell paths; Python is py -3 with PYTHONUTF8=1.
