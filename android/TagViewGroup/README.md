# TagViewGroup (Kotlin)

The public API of [shellljx/TagViewGroup](https://github.com/shellljx/TagViewGroup) (at `befcd9b`, 2019-03-09) in
Kotlin: `com.licrafter.tagview.TagViewGroup` with `TagAdapter`, `ITagView`, `DIRECTION`, `RippleView`,
`TagTextView`, `DipConvertUtils` and `TagGroupUtils`, the same classes, methods, listeners, attributes
(`radius`, `inner_radius`, `line_width`, `v_distance`, `tilt_distance`, `ripple_alpha`, `ripple_maxRadius`) and
animation properties (`CIRCLE_RADIUS`, `CIRCLE_INNER_RADIUS`, `LINES_RATIO`, `TAG_ALPHA`).

**Not a transcription.** TagViewGroup is licensed under GPL-3.0. To keep this repository's license, its code was
not copied or translated: only the names of its public API and its README were used, and the behavior was written
anew after this repository's own iOS implementation (`CYLImageTagGroupView`). The sample is a translation of this
repository's Swift port (`Example/CYLMenuExample/CYLImageTagSample.swift`): a picture with two groups (a tap shows or
hides them), the editor (create, drag, turn, delete, save) and a list of 30 pictures. The pictures are drawn in code;
the original sample's photo is not included.

Build (from this repository): `android/scripts/gradle.sh TagViewGroup assembleDebug`.
