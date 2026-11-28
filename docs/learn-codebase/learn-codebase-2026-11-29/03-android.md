# Android (android/)

Per-declaration detail: api-reference/android-library-part1.md to android-library-part4.md. Library main sources were read without import and [CN] lines.

## Library (android/merged/library, com.cyl.classifymenu, published com.cyl:classifymenu:0.1.0 into build/repo)
- Mirrors the iOS names. respondsToSelector becomes flags on CYLMenuDataSource: supportsMovingItems(),
  supportsRenamingItems(), decidesDeletableItems().
- Lengths are dp, colors ARGB ints. Night mode is resolved from the Context (CYLSystemColors, CYLSectionStyleColors).
- CYLTagListView is a ViewGroup: title CYLTagButton + ScrollView + content view. Android only: backdropSource must be set
  (a view that is not an ancestor) for glass.
- Cells expose TalkBack custom actions. CYLClassifyMenu and CYLFilterBaseController are Fragments (showInView).
- CYLTagListStore: SQLite with in-memory fallback, SharedPreferences, or JSON file; same "#items" + U+001F layout.
- Reorder: canMoveItemAt checks the create item and section editability; the private moveItem checks only canReorder().
- Configuration: CYLTagListViewConfiguration parses JSON / plist into CYLTagListConfigurationSource.
- Build also has publishAnimatedItemToBuildRepository for the React Native and Flutter hosts. AGP 8.7.3, Kotlin 2.0.21,
  Robolectric 4.14.1 (sdk 23 in robolectric.properties).
- settings.gradle.kts of the merged project sparse-clones CYLTabBarController at cyl.tabbar.commit and uses includeBuild;
  a localPath fallback exists. android/scripts/gradle.sh runs Gradle in a mirror directory (macOS paths).
  sync_merged_sources.py keeps merged and standalone sources in step; *_public_api.py and api_map_from_kotlin.py build
  the iOS/Android parity tables.

## Ports
co.lujun.androidtagview (TagContainerLayout drawing TagView on canvas), com.licrafter.tagview (TagViewGroup: dot and
lines; an API-compatible reimplementation, no code copied from the GPL-3.0 original), me.kaede.tagview (RelativeLayout
based). Upstream issue fixes are annotated "#N" in the code.

## Merged example (mirrors iOS)
MainActivity builds a CYLTabBarController from cyl_merged_tabbar.json with a page registry. Packages: classify/
(ClassifyDemoDataSource, ClassifyMainFragment, ClassifyPlacesDatabase with bound parameters, results view,
FilterDemoFragment), menu/ (query scenarios, reviews with memory/network/database queries, search screens, tag
animation / cloud / style / word picker screens), kaede/, licrafter/, lujun/, tagcollection/, tageditor/ (CYLTagStore
moveTag clamps the target). The build reuses the iOS example bundles and images as assets and fetches PAG files.
Important: ClassifyDemoDataSource.menuTitleForItemAtIndexPath returns the LOCALIZED title; sourceTitle(indexPath)
returns the database title. Query with sourceTitle.
