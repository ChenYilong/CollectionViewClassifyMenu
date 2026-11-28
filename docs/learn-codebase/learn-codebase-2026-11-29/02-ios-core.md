# iOS core (CollectionViewClassifyMenu/Class)

Per-declaration detail: api-reference/ios-core-library-part1.md to ios-core-library-part5.md.

## Model and style (TagList/, Other/Tool/)
- CYLTag: final class with per-tag look overrides. badgeText "" draws an 8 pt dot; text draws a capsule image
  (cylIsBadgeImage widens the icon slot). CYLTagDataSource (one section) caches per-tag styles by ObjectIdentifier so an
  unchanged tag returns the same style object.
- CYLTagAppearance: colors are null_resettable with explicit* / is*Set accessors. Built-in and explicit values differ:
  only an EXPLICIT border is drawn under Liquid Glass, and only an explicit background tints glass. iconColor follows
  textColor when unset.
- CYLMenuStyle (copying; copy() lists every property): presets tagCloud, tagContainer, gridStyle, wordPicker,
  classifyMenuTag, filterTag, sectionTitle. Default sectionStyle is .insetGrouped (a card); those tag presets use .plain.
  *WasSet flags decide resolved colors. CYLTintContrast threshold 0.179. CYLSectionStyleMetrics: corner 10, padding 12,
  separator 0.5, title padding 8, board spacing 4.
- Style objects are copied on set: mutate a copy and assign it again. Per-section and per-item style providers must
  return the same object while unchanged (identity caches use ===).

## CYLTagListView (the real component)
- UICollectionView with CYLTagListLayout: left-aligned layout plus a section card decoration view (glass cards use
  CYLAnimatedItemView).
- One column model: column(atWidth) -> boardColumn -> tagColumn. All widths, rows and fold decisions use tagColumn.
  Rows come from a greedy rows(forWidths:). Header widths use CYLTagListHeaderRoom (spacing 8, fold control cap 0.4 alone
  or 0.3 shared, accessory 0.3, fold margin 6).
- Fold: foldControl.position none / footer / headerTrailing / headerLeading / tail, kept in step with the legacy
  foldStyle. tail is an inline CYLTagFoldCell that takes room from the last visible row. Editing disables folding.
- Selection rules: applySelection / handleTap. Smear selection uses a pan recognizer with a delegate.
- Editing: add-item view with keyboard inset, rename (own editor possible through renameRequestHandler), saves to the
  cache and reports edits.
- Reorder: movingItem + measuredIndexPath during the drag. canReorderItem is only canReorder; UIKit enforces
  collectionView(_:canMoveItemAt:) -> canMoveItem (excludes create item and non-editable sections).
- Long-press callout lives in the window; dismissed by observing scrolling (KVO) and by a window tap.
- loadSections / loadItems follow one of 3 load policies (cache and remote order).

## CYLTagButton
Every icon + title view is CYLTagButton, a subclass of CYLTabBarController's CYLAnimatedItemView (import chosen by
canImport: CYLAnimatedItemViews / CYLAnimatedItem / CYLTabBarController). Colors go through the item's precedence chain
(setSubclassTitleColor, setSubclassIconColor, applyTitleTintColor, applyIconTintColor, CYLAnimatedItemColorRole roles
for the delete indicator and editing icons). Editing icons are a lazy stack: square.and.pencil + xmark.
Animation and icon + title bugs are fixed upstream in the animated item, not here.

## Configuration, cache, long press
- CYLTagListView(configuration:) and (configurationFile:): JSON and plist natively; other formats through
  CYLTabBarController's parser, found at run time by NSClassFromString. CYLConfigurationValue does the parsing;
  CYLTagListConfigurationSource caches section and item styles.
- CYLTagListStore: SQLite by default (Application Support/CollectionViewClassifyMenu/tags.sqlite), UserDefaults, or a
  JSON file. Titles by section; items in a companion key "<section>#items" with the U+001F separator.
- CYLTagLongPressAction: reorder / report / callout / none / handler / first; default first([reorder, report]).

## Image tags, legacy views, strings
- CYLImageTagGroupView: up to 6 tags around a dot, 11 directions; geometry from TagViewGroup (Apache 2.0);
  CADisplayLink animations; the dot is an accessibility element with move actions. CYLImageTagView pushes overlapping
  groups apart with displayOffset.
- CYLClassifyMenuViewController, CYLMultipleFilterController (side panel with blur, exclusive-item rules, prefetching
  off because of issue #1) and TagCollectionView's CYLTagView keep Objective-C names and NSArray state because the
  Objective-C root tests read them through KVC. Do not rename those privates.
- Core strings: CYLMenuLocalizedString over CYLClassifyMenuResources.bundle (en, zh-Hans, zh-Hant). Each example has
  its own lookup; keys are Chinese source text.
- Demo-only files in the core folder (excluded from the package by name): CYLDemoDataSource,
  CYLFilterDemoViewController, CYLMainViewController, CYLAppDelegate, CYLDemoLocalization, CYLDBManager.
