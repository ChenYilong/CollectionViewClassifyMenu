# cyl_tag_list

Flutter wrapper of the native `CYLTagListView` of CollectionViewClassifyMenu: the same tag list, folding, selection and
animated icons on iOS (the Swift pod) and Android (the Kotlin port in `android/merged`).

```dart
final controller = CylTagListController();

CylTagListView(
  controller: controller,
  configuration: {
    'selectionMode': 'multiple',
    'foldControl': {'position': 'tail', 'content': 'icon'},
    'sections': [
      {'title': 'Tags', 'items': [
        {'title': 'Home', 'image': 'system:house'},
        {'title': 'Home', 'animation': 'asset:assets/tab_home_animate.json'},
      ]},
    ],
  },
  onTap: (tap) => print(tap.title),
);

controller.setSpeed(2);   // every animated icon, at once
controller.setLoops(true);
controller.playAll();     // from progress 0
```

- `configuration` is the dictionary of `CYLTagListView(configuration:)` (keys `CYLTagListKey`, `CYLTagSectionKey`,
  `CYLTagItemKey`, `CYLMenuStyleKey`…; strings work for every value). A value `asset:<key>` becomes the path of that Flutter
  asset on the device.
- `foldControl` is a position string (`none`, `footer`, `headerTrailing`, `headerLeading`, `tail`) or a map
  `{'position': ..., 'content': ..., 'title': ..., 'collapseTitle': ..., 'color': ...}`. `content` strings: `iconAndTitle`
  ("More v" folded, only the chevron turned 180 degrees expanded), `title`, `icon`, and `titleAndIconAlways` (the title and the
  chevron in both states: "More v" folded, "Less ^" expanded). The old `titleAndIcon` string stays an alias of `iconAndTitle`.
  Unset, the tail and the footer show the icon only and the header shows `iconAndTitle`. A control in a section header shows only
  on a section that can fold, with a capped font and at most 40% of the header width (the section title truncates).
- `CylTagListController` holds the playback controls of `docs/example-demo-rules.md` (Play all, speed, loop) and
  `state()`, which reads what the native list holds.
- Status: iOS and Android pass the integration test and play the animated icons (see docs/cross-platform.md).

## Section card, header divider and tint (the default look changed)

A tag list now shows each section's tags on a rounded card by default (`sectionStyle` `insetGrouped`). If you never set
`backgroundColor`, the list background becomes the grouped background (#F2F2F7; black in dark mode). The header divider is
**off** by default. The header band (`headerBackgroundColor`) is off by default too.

`configuration` is passed to the native list as it is, so the keys go in its `style` map (strings and numbers work for every value; there is no typed Dart class for them):

- Remove the card: `'style': {'sectionStyle': 'plain'}`.
- Show the header divider: `headerSeparatorStyle` `line`, optionally with `headerSeparatorColor`, `headerSeparatorThickness`
  (default 0.5) and `headerSeparatorInsets` (default 0: it spans the same left and right edges as the card and the band).
- Optional header band: `headerBackgroundColor`, with `headerCornerRadius` and `headerContentInsets`.
- The card: `sectionBackgroundColor`, `sectionCornerRadius` (default 10), `sectionContentInsets` (default 12), and
  `sectionBackgroundStyle` `flat` (default) or `liquidGlass` (falls back to flat where the platform cannot draw glass).
- `tintColor`: the one color of the built-in header title, icon and More / Less control. Left out, it is black or white,
  whichever is legible on the background behind them.
- Every new color adapts to light and dark mode by itself; a color you set wins in both modes.

### Migration: the default look changed

This is a breaking visual change: a list that sets nothing now shows the rounded card and the grouped background. To get the
old look, set `sectionStyle` to `plain`. Screenshots and tests that depend on pixel positions need updating.

```dart
CylTagListView(
  controller: controller,
  configuration: {
    'style': {
      'sectionStyle': 'plain',              // remove the card; leave 'style' out for the default card
      'headerSeparatorStyle': 'line',       // the divider is opt-in
      'headerBackgroundColor': '#EFEFF4',   // optional band
      'sectionBackgroundStyle': 'liquidGlass',
      'tintColor': '#007AFF',
    },
    'sections': [{'title': 'Reviews', 'items': [{'title': 'All'}]}],
  },
);
```

`controller.applyConfiguration({'style': {'sectionStyle': 'plain'}})` changes a shown list; keys that are missing keep their values.

## iOS

The plugin's podspec depends on the `CollectionViewClassifyMenu` pod, which is a static framework: the app links
statically (`use_frameworks! :linkage => :static`) and lists the pod, as `example/ios/Podfile` does. Animated icons need
`pod 'CYLTabBarController/Lottie'` (or PAG, Rive, GIF) in the app's Podfile (the core finds the engine at run time).

Build and test from a copy outside the exFAT volume:

```sh
cd example
flutter build ios --simulator --no-codesign --dart-define=CYL_AUTOPLAY=true   # 2x, loop and Play all after start
flutter test integration_test/tag_list_test.dart -d <simulator id>
```

## Android

The plugin depends on `com.cyl:classifymenu:0.1.0`, the Kotlin library of `android/merged`, from a local Maven folder:
publish it first with `android/scripts/gradle.sh merged :library:publishReleasePublicationToBuildRepository`, and point
`cyl.classifymenu.repo` (in `example/android/gradle.properties`) at the `library/build/repo` folder when the build runs from
another directory. Then `flutter test integration_test/tag_list_test.dart -d <emulator>`.

For the animated (Lottie) icons on Android, also build CYLTabBarController's engine with
`android/scripts/gradle.sh merged :Example-Android:cyltabbar:assembleRelease :Example-Android:tabpages:jar` and set
`cyl.tabbar.libs` in `example/android/gradle.properties` to a folder holding `cyltabbar-release.aar` and `tabpages-*.jar`.
