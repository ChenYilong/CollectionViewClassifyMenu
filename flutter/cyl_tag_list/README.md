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
- `CylTagListController` holds the playback controls of `docs/example-demo-rules.md` (Play all, speed, loop) and
  `state()`, which reads what the native list holds.
- Status: iOS and Android pass the integration test and play the animated icons (see docs/cross-platform.md).

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
