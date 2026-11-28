# harmonyos: library (part 2 of 4)

## harmony/classifymenu/src/main/ets/components/CYLTagListState.ets

The model and controller of a `CYLTagListView`, as iOS `CYLTagListView.swift` without its UIKit views: the data
source and delegate, the style, selection, folding, measurement and row layout, the title, the android-tagview tag
methods and reordering. It needs no UI to be used or tested; `CYLTagListView` renders it and calls back into it.
Lengths are vp.

- `export enum CYLMenuSelectionMode` (L47)
  How taps select items.

- `none = 0,` (L49)
  Items behave like buttons: taps are reported, nothing stays selected.

- `single = 1,` (L51)
  At most one selected item per section.

- `multiple = 2` (L53)
  Any number of selected items; exclusive items clear the others.

- `export enum CYLMenuTitlePosition` (L57)
  Where the list's title is: above every section, at the leading edge or centered.

- `export enum CYLMenuFoldStyle` (L63)
  The older way of choosing a fold control; `foldControl` gives the position and content separately.

- `none = 0,` (L65)
  Every row is always visible.

- `headerButton = 1,` (L67)
  A "更多/收起" button at the trailing edge of the section header.

- `footerChevron = 2,` (L69)
  A chevron below the section.

- `truncate = 3` (L71)
  Shows only `defaultVisibleRows` rows with no control; the host may still call `setExpanded`.

- `const LINE_HEIGHT_RATIO: number = 1.2;` (L77)
  The line height of the system font per point of size (as `CYLTagMetrics`).

- `const FOOTNOTE_SIZE: number = 13;` (L80)
  `UIFont.TextStyle.footnote` and `.headline` point sizes at the default content size.

- `const HEADER_VERTICAL_PADDING: number = 12;` (L88)
  The vertical padding of a section header around its title lines, vp.

- `const HEADER_BOARD_TITLE_PADDING: number = CYLSectionStyleMetrics.headerBoardTitlePadding;` (L90)
  The padding around the title lines of a header sized to its text (under `insetGrouped`, no divider), vp.

- `const HEADER_BOARD_SPACING: number = CYLSectionStyleMetrics.headerBoardSpacing;` (L92)
  The space between that header's bottom and the board's top, vp.

- `export const HEADER_ITEM_SPACING: number = 8;` (L97)
  The space between every two adjacent views of a header row, vp. The room math (`headerTitleRoom`) and `CYLTagListView`'s
  header Row both use this one constant.

- `export const CALLOUT_GAP: number = 4;` (L99)
  The gap between a long-press callout's arrow tip and the tag, vp (iOS `gap`).

- `export const CALLOUT_ESTIMATED_HEIGHT: number = 40;` (L101)
  The height of a one-line callout bubble with its arrow, vp: a 13 vp line, 8 vp padding twice, an 8 vp arrow.

- `const HEADER_TITLE_MIN_WIDTH_FLOOR: number = 1;` (L103)
  The least width a header's title has regardless of the other views (`HEADER_TITLE_MIN_WIDTH`: one em, at least this), vp.

- `const HEADER_MORE_BUTTON_SIDE: number = 24;` (L105)
  The side of a header's More button, vp.

- `const LONG_PRESS_DURATION: number = 0.5;` (L110)
  Seconds.

- `const SEPARATOR: string = CYLColor.argb(73, 60, 60, 67);` (L112)
  `UIColor.separator`, `.secondaryLabel`, `.tertiaryLabel`, `.label` in their light appearance.

- `export type CYLTextMeasurer = (text: string, font: CYLFont) => number;` (L118)
  Measures a line of text in vp.

- `const CAP_HEIGHT_RATIO: number = 0.7;` (L135)
  The cap height of HarmonyOS Sans, as a share of the font size.

- `export class CYLTagButtonMetrics` (L137)

- `static contentInset(style: CYLMenuStyle): number` (L143)
  The space between the border and the content, left and right, that the style's shape asks for: `CYLAnimatedItemLiquidGlassContentInset` for a
  Liquid Glass style where the glass is really drawn (the same condition as the capsule), else 0. The effective inset is the larger of this and
  the appearance's content inset.

- `static textMeasurer: CYLTextMeasurer = measureWithArkUI;` (L148)
  Replaced in tests that run without a UI context.

- `static widthWithImage(title: string | undefined, image: CYLImage | undefined, style: CYLMenuStyle,` (L155)
  `width(forTitle:image:style:)`.

- `static width(title: string | undefined, iconSize: CYLSize, showsDeleteIndicator: boolean, style: CYLMenuStyle,` (L161)
  The width a tag needs in every state, before any limit on the available width.

- `static iconSize(image: CYLImage | undefined, animated: boolean, style: CYLMenuStyle): CYLSize` (L207)
  The icon slot of an image, or of an animated icon when `animated`.

- `static height(style: CYLMenuStyle, fontScale: number = 1): number` (L231)
  `style.itemHeight`, or more when a line of the title font plus the content insets needs it; with the icon above or
  below the title, also the icon slot and the spacing.

- `static heightForTitle(title: string | undefined, iconSize: CYLSize, style: CYLMenuStyle, fontScale: number = 1): number` (L248)
  `height(forTitle:iconSize:style:traitCollection:)`: the height a tag needs for this title and an icon of `iconSize`
  in every state: the taller of the two side by side, or both and the spacing when stacked; at least `itemHeight`.

- `static wrappedTextHeight: (text: string, font: CYLFont, width: number, maxLines?: number) => number =` (L271)
  The height of `text` in `font` wrapped to `width` vp. With the window's text metrics, ArkUI measures it; without
  (host tests), the lines are the single-line width (`textMeasurer`) over `width`, rounded up.

- `static heightForTitleWidth(title: string | undefined, iconSize: CYLSize, width: number, showsDeleteIndicator: boolean,` (L288)
  `height(forTitle:iconSize:width:showsDeleteIndicator:style:traitCollection:)`: the height of a tag `width` wide; with
  `CYLMenuStyle.titleWraps` the title wrapped to the room it has beside the icon and the delete indicator, otherwise
  `heightForTitle`.

- `static capHeight(font: CYLFont): number` (L317)
  The cap height of `font` (HarmonyOS Sans: 0.7 of the size).

- `static editingIconSide(state: number, style: CYLMenuStyle, fontScale: number = 1): number` (L322)
  The side of one editing icon (the edit icon or the cross): the title's cap height x 1.25 (iOS 3af1b7cd).

- `static editingIndicatorsWidth(state: number, style: CYLMenuStyle, fontScale: number = 1): number` (L327)
  The width of the two editing icons with the space between and around them.

- `export class CYLTagFoldMetrics` (L350)
  The looks and sizes of the fold controls (`CYLTagFoldButton`).

- `static cappedFontScale(fontScale: number): number` (L352)
  The system font scale a fold / More control is sized and drawn at: at most `CYLFoldControlMaxFontScale`.

- `static style(control: CYLMenuFoldControl, color?: ResourceColor): CYLMenuStyle` (L357)
  A borderless tag: no background, the title then the icon, in `color`.

- `static inlineStyle(control: CYLMenuFoldControl, itemStyle: CYLMenuStyle): CYLMenuStyle` (L381)
  The inline control: the tags' normal look in every state, the icon after the title.

- `static size(control: CYLMenuFoldControl, expanded: boolean, fontScale: number = 1): CYLSize` (L430)
  The size the control needs in that state (at least a 44 vp wide touch target).

- `static inlineSize(control: CYLMenuFoldControl, itemStyle: CYLMenuStyle, expanded: boolean,` (L439)
  The inline control's size: the tags' height, and at least as wide as it is high.

- `export class CYLTagCreateItem` (L450)
  "+ 新建标签" (`CYLTagCreateCell`).

- `static title(name?: string): string` (L456)
  "新建标签" for an empty name, "新建标签：<name>" otherwise.

- `static outlinedStyle(style: CYLMenuStyle): CYLMenuStyle` (L464)
  The outlined look of the item: the list's background, a hairline border and secondary text.

- `export class CYLTagListItemFrame` (L489)
  Where an item (or the inline fold control) is, in the list's content (below the title).

- `isFoldCell: boolean = false;` (L497)
  The inline fold control (`CYLMenuFoldControlPosition.tail`), after the visible items.

- `export function cylCharacters(text: string): string[]` (L505)
  The characters of `text` as a reader sees them (graphemes): a code point with the marks, variation selectors, skin
  tones and zero-width-joined parts that follow it (ArkTS has no `Intl.Segmenter` on every target).

- `let cylNextGestureOwner: number = 1;` (L538)
  The next id of a tag list in `CYLMenuGestureState.shared`.

- `export class CYLTagListSectionFrame` (L541)
  A section as laid out: its header, items and footer.

- `y: number = 0;` (L544)
  The section's top, in the list's content (below the title).

- `card?: CYLRect = undefined;` (L552)
  The section card (`CYLSectionStyle.insetGrouped`), in the list's content (below the title); undefined: none.

- `headerBand?: CYLRect = undefined;` (L554)
  The header band (`CYLMenuStyle.headerBackgroundColor`); undefined: none.

- `headerSeparator?: CYLRect = undefined;` (L556)
  The header divider, at the header's bottom edge inside `headerHeight` (it adds no height); undefined: none.

- `headerInsetLeft: number = 0;` (L558)
  The distances from the list's leading and trailing edges to the header's title and fold control.

- `isRtl: boolean = false;` (L561)
  True when the list lays out right to left (`CYLTagListState.layoutDirection`).

- `headerTitleLeadingX: number = 0;` (L566)
  The x (from the list's left edge) of the header title's leading edge: the left inset in ltr, the list width minus
  the right inset in rtl, where the title is aligned to its right end. Under `insetGrouped` it is the tags' leading edge.

- `headerFoldX?: number = undefined;` (L571)
  The x of the header fold control's left edge when the section's header shows one, else undefined. The control sits
  at the trailing side (`headerTrailing`) or the leading side (`headerLeading`); rtl mirrors both.

- `headerTitleWidth: number = 0;` (L576)
  The title's maximum width (`CYLTagListState.headerTitleRoom`): the width the header height is computed for and the
  width the title is drawn at.

- `headerAccessoryMaxWidth: number = 0;` (L578)
  The header accessory's maximum width (`CYLHeaderAccessoryMaxFraction` of the inner width); 0 without an accessory.

- `class CYLStyleCacheEntry` (L594)

- `export class CYLTagListState implements CYLTagLongPressHost` (L606)

- `menuDataSource?: CYLMenuDataSource;` (L608)
  The sections and items.

- `menuDelegate?: CYLMenuDelegate;` (L610)
  Receives taps, selection changes, folding and size changes.

- `allowsEmptySelection: boolean = true;` (L612)
  When false, a tap never removes the last selected item of a section.

- `allowsTapping: boolean = true;` (L614)
  False ignores taps on tags (tag_clickable); long presses still work.

- `defaultTagImage?: CYLImage;` (L616)
  The icon of every item without one of its own (setDefaultImageDrawableID).

- `removesItemsOnDelete: boolean = true;` (L618)
  False makes a tap on a delete indicator only report it; the host removes the item.

- `tagClickHandler?: (index: number, tag: CYLTag) => void;` (L620)
  Every accepted tap on one of `tags`, after the menu delegate.

- `tagDeleteHandler?: (index: number, tag: CYLTag) => void;` (L622)
  A tap on a tag's delete indicator removed it, after the menu delegate.

- `tagMoveHandler?: (from: number, to: number) => void;` (L624)
  One of `tags` moved (after `menuDidMoveItem`).

- `selectedTagDragHandler?: (index: number, tag: CYLTag) => void;` (L626)
  A selected tag started moving, after `menuDidBeginDraggingSelectedItem`.

- `fontScale: number = 1;` (L628)
  The system font scale the tags are measured at (Dynamic Type).

- `get layoutDirection(): CYLLayoutDirection` (L637)
  The layout direction: `ltr` by default. `rtl` mirrors the header (title, icon, fold / More control), the section
  insets, the card, band and divider insets and starts the rows at the trailing edge; `CYLTagListView` sets it from the
  system language unless the app gave one. Left-to-right frames are never changed by it.

- `calloutIndexPath?: CYLIndexPath;` (L707)
  The item the callout points at and its text, or undefined while no callout shows (read by the view).

- `constructor(foldControl?: CYLMenuFoldControl, title?: string, titleImage?: CYLImage,` (L726)
  `init(foldControl:)` and `init(foldControl:title:titleImage:titlePosition:)`: a tag list with its fold control
  (undefined: none), title and title icon.

- `static withFoldPosition(position: CYLMenuFoldControlPosition, content: CYLMenuFoldControlContent): CYLTagListState` (L737)
  `init(foldPosition:content:)`: a tag list with a fold control at this position showing this content.

- `cache?: CYLTagListCache = undefined;` (L749)
  `cache`: the store the list saves to, the built-in store of `cachePolicy` or one of yours; undefined: no cache.

- `remoteSource?: CYLTagListRemoteSource = undefined;` (L751)
  `remoteSource`: the server the sections are also kept on, for `loadSectionsWithKeys`; undefined: the cache only.

- `loadPolicy: CYLTagListLoadPolicy = CYLTagListLoadPolicy.cacheThenNetwork;` (L756)
  `loadPolicy`: how `loadSectionsWithKeys` combines the cache and `remoteSource`; `cacheThenNetwork` (the cache at
  once, then a refresh from the server) by default.

- `editingFinishHandler?: (titles: Map<string, string[]>) => void = undefined;` (L761)
  `editingFinishHandler`: called when editing ends (`setEditing(false)`) with the edited sections by cache key, after
  `menuDidFinishEditingWithTitles`: the place to upload them.

- `editableSectionTitles(): Map<string, string[]>` (L767)
  `editableSectionTitles()`: the titles of every editable section by cache key (`cacheKeyForSection`), without
  "+ New tag" items: what the list saves and what `menuDidFinishEditingWithTitles` reports.

- `loadSectionsWithKeys(keys: string[], completion: (sections: Map<string, string[]>, origin: CYLTagListDataOrigin) => void): void` (L796)
  `loadSections(withKeys:completion:)`: reads the sections saved under `keys` from the cache and `remoteSource`, in the
  order of `loadPolicy`, and calls `completion` with the titles by key and where they come from: once or twice
  (`cacheThenNetwork`: the cache at once, then the server). Downloaded sections are saved to the cache first. Without
  a remote source it reads the cache only; nothing saved anywhere calls nothing. (ArkTS runs callbacks on the UI
  thread's event loop, iOS's main queue.)

- `get isEditing(): boolean` (L854)
  `isEditing`: whether the list is in editing mode (`setEditing`). While editing, the items of the editable sections
  (`menuSectionAllowsEditing`, every section by default) show the delete indicator and can be dragged to reorder; a
  tap no longer selects an item but still calls `menuDidSelectItem`, so the host can open the item; folded sections
  show every item; and `addItemView` appears below the last section. False by default.

- `get showsAddItemViewWhileEditing(): boolean` (L859)
  `showsAddItemViewWhileEditing`: shows `addItemView` below the last section while editing. True by default.

- `get addItemView(): CYLTagListAddItemView` (L872)
  `addItemView`: the "add tag" control shown while editing. A submitted name is reported through
  `menuDidRequestNewItemWithName` with the index path after the last item of the first editable section.

- `get cachePolicy(): CYLTagListCachePolicy` (L888)
  `cachePolicy`: where the list saves its editable sections after an edit (a drag, a delete or an added tag in
  editing mode), so the order survives a relaunch: none (the default), a database, the app's preferences or a file.
  The host restores it when it builds its data (`cachedTitlesInSection`). Setting it makes `cache` the built-in store
  of the policy and `cacheName`.

- `get cacheName(): string` (L898)
  `cacheName`: separates the caches of different lists ("CYLTagListView" by default); set it before `cachePolicy`.

- `cachedTitlesInSection(section: number): string[] | undefined` (L908)
  `cachedTitles(inSection:)`: the titles saved for `section`, in order; undefined when nothing was saved or no cache.

- `cacheKeyForSection(section: number): string` (L913)
  `cacheKey(forSection:)`: the data source's `menuCacheKeyForSection`, else the section's index.

- `saveEditableSectionsToCache(): void` (L919)
  `saveEditableSectionsToCache()`: saves the current titles of every editable section to `cache` (after each edit).

- `get renamingIndexPath(): CYLIndexPath | undefined` (L940)
  `renamingIndexPath`: the item being renamed in editing mode (its rename indicator was tapped); undefined otherwise.

- `get renamesOnTitleTapWhileEditing(): boolean` (L948)
  `renamesOnTitleTapWhileEditing`: in editing mode, a tap on a renamable item's title (outside its two icons) renames
  it too; a tap elsewhere still selects. True by default; it needs the data source's `menuRenameItem`.

- `renameRequestHandler?: (indexPath: CYLIndexPath, title: string) => void = undefined;` (L961)
  `renameRequestHandler`: your own editor for renaming: when set, a rename indicator or title tap calls it with the
  item and its title instead of filling `addItemView`; finish with `finishRenaming` or `cancelRenaming`.

- `clearButtonHandler?: (section: number) => void = undefined;` (L964)
  `clearButtonHandler`: called with the section when its header's clear button is tapped (after the delegate).

- `editableSectionItems(): Map<string, CYLTagListCacheItem[]>` (L967)
  The items (identifier and title) of every editable section, by cache key, without "+ New tag" items.

- `isRenamable(indexPath: CYLIndexPath): boolean` (L991)
  Whether the item can be renamed now: editing, an editable section, deletable, a data source that renames.

- `beginRenaming(indexPath: CYLIndexPath): void` (L1001)
  `beginRenaming(at:)`: starts renaming (the rename indicator does this): `addItemView` shows the title, its submit
  renames the item through the data source's `menuRenameItem`; or `renameRequestHandler` gets it.

- `cancelRenaming(): void` (L1022)
  `cancelRenaming()`: ends renaming without a change.

- `submitNewItem(name: string): void` (L1032)
  `submitNewItem(named:)`: adds an item from your own editor, as `addItemView`'s submit does (trimmed).

- `finishRenaming(title: string): void` (L1045)
  `finishRenaming(to:)`: renames the item being renamed to `title` (trimmed; an empty or unchanged one only ends
  renaming): the data source renames it, the list reloads, saves its cache and calls `menuDidRenameItem`.

- `showsClearButton(section: number): boolean` (L1065)
  Whether the section's header shows the clear button (`menuShowsClearButtonForSection`).

- `clearButtonLabel(section: number): string` (L1070)
  The clear button's accessibility label: "Clear <section title>".

- `tapClearButton(section: number): void` (L1077)
  A tap on a section header's clear button.

- `loadItemsWithKeys(keys: string[],` (L1086)
  `loadItems(withKeys:completion:)`: `loadSectionsWithKeys` with identifiers: the cache's items and the remote
  source's (`fetchItemsWithKeys`, else its titles, each its own identifier); downloaded items are saved first.

- `setEditing(editing: boolean, animated: boolean = false): void` (L1166)
  `setEditing(_:animated:)`: enters or leaves editing mode; the delete indicators, reordering, the selection rules,
  folding and `addItemView` change together; then `menuDidChangeEditing` is called. The list itself does not move or
  open anything. (`animated` is accepted for parity; the view redraws the list either way.)

- `sectionAllowsEditing(section: number): boolean` (L1186)
  `sectionAllowsEditing(_:)`: the data source's `menuSectionAllowsEditing`, else true.

- `get showsAddItemView(): boolean` (L1192)
  Whether `addItemView` is shown (editing, and `showsAddItemViewWhileEditing`).

- `get addItemViewFrame(): CYLRect | undefined` (L1204)
  Where the view draws `addItemView`: right below the sections, inside the scrolling content; undefined when hidden.

- `attach(listener: () => void, scrollHandler?: (offset: number, animated: boolean) => void): void` (L1238)
  Called by the view that renders the list: `listener` runs whenever it must render again.

- `setLayoutWidth(width: number): void` (L1249)
  The view's width; a new width lays the tags out again.

- `setViewportHeight(height: number): void` (L1262)
  The height of the area the list scrolls in.

- `get playToken(): number` (L1267)
  Changes each time `playAllAnimations()` is called.

- `playTokenForItem(indexPath: CYLIndexPath): number` (L1272)
  Changes each time the item's animated icon must play from its start (a tap, `playAllAnimations()`).

- `get titleView(): CYLTagButton` (L1283)
  `titleView`: the `CYLTagButton` that draws the title (every public API of `CYLTagButton`, e.g. an animated
  icon with `animationURL`). The list sets its title, icon and style from `title`, `titleImage` and `titleStyle`;
  other changes to it are drawn at once.

- `get titleLabel(): CYLTagButtonPart` (L1288)
  `titleLabel`: the title's label (`titleView.titleLabel`), as last laid out.

- `tagButton(indexPath: CYLIndexPath): CYLTagButton | undefined` (L1297)
  `tagButton(at:)`: the tag view of a shown item (the `CYLTagButton` the list draws), or undefined when the item is
  not shown. The list configures it when the item's data, state or style changes; changes made in between are
  drawn at once.

- `cellForItemAt(indexPath: CYLIndexPath): CYLTagListCell | undefined` (L1302)
  `collectionView(_:cellForItemAt:)`: the cell of a shown item (`CYLTagListCell`), or undefined.

- `viewForSupplementaryElementOfKind(kind: string, indexPath: CYLIndexPath): CYLTagListSupplementaryView | undefined` (L1311)
  `collectionView(_:viewForSupplementaryElementOfKind:at:)`: the header (`CYLTagListElementKindSectionHeader`) or
  footer (`CYLTagListElementKindSectionFooter`) of a shown section, or undefined.

- `get viewGeneration(): number` (L1322)
  Changes when the data or the style is reloaded: the views are configured again.

- `dequeueCell(indexPath: CYLIndexPath): CYLTagListCell` (L1327)
  For the list view: the cell of an item it draws (made on first use), kept until the item goes away.

- `dequeueSupplementaryView(kind: string, section: number): CYLTagListSupplementaryView` (L1338)
  For the list view: the header or footer of a section it draws.

- `setShownViews(items: CYLIndexPath[], headers: number[], footers: number[]): void` (L1351)
  For the list view: what it draws now (the other cells and views are dropped).

- `get style(): CYLMenuStyle` (L1379)
  Appearance. Setting copies the style; set it again after changing it.

- `get selectionMode(): CYLMenuSelectionMode` (L1394)
  How taps select items; `.single` by default.

- `get showsSectionHeaders(): boolean` (L1415)
  True by default. When false, sections are laid out back to back without titles.

- `get foldControl(): CYLMenuFoldControl` (L1428)
  The fold control of a foldable section. Setting copies it and also sets `foldStyle` (footer: `.footerChevron`,
  header: `.headerButton`, none: `.none`, or `.truncate` when `foldStyle` was `.truncate`).

- `get foldStyle(): CYLMenuFoldStyle` (L1455)
  `.none` by default. Setting it also sets `foldControl`.

- `get defaultVisibleRows(): number` (L1474)
  Rows shown while a foldable section is collapsed. 0 shows every row. 1 by default.

- `get title(): string | undefined` (L1486)
  A title above every section (undefined, the default, for none).

- `get titleImage(): CYLImage | undefined` (L1496)
  The title's icon; undefined for none.

- `get titleStyle(): CYLMenuStyle` (L1515)
  The title's look; default `defaultTitleStyle()`. Setting copies the style.

- `static defaultTitleStyle(): CYLMenuStyle` (L1525)
  The default title look: the headline font in the label color, an 18 vp icon, no background or border.

- `titleHeight(): number` (L1556)
  The height of the title area, 0 without a title or an icon.

- `titleFrame(): CYLTagListItemFrame` (L1564)
  The title's frame: as wide as its content (no wider than the list), at the leading edge or centered.

- `get isScrollEnabled(): boolean` (L1585)
  False to embed the list in another scroll view and size it with `contentHeight`. True by default.

- `get contentHeight(): number` (L1595)
  The height the current content needs at the current width (also reported by `menuDidChangeContentHeight`).

- `get lineSpacing(): number` (L1602)
  The space between rows (`style.lineSpacing`).

- `get interitemSpacing(): number` (L1613)
  The space between tags in a row (`style.interitemSpacing`).

- `get tagContentInsets(): CYLEdgeInsets` (L1624)
  The space inside every tag (`style.tagContentInsets`).

- `get animationSpeed(): number | undefined` (L1673)
  The playback speed of every animated icon; undefined (the default) uses each item's `style.animationSpeed`.

- `get animationLoops(): boolean` (L1683)
  True repeats the animated icons after they start playing; false (the default) plays them once.

- `playAllAnimations(): void` (L1693)
  Plays the animated icon of every tag on screen from its start.

- `animationSpeedForItem(indexPath: CYLIndexPath): number` (L1699)
  The speed an item's animated icon plays at.

- `get containerBorderWidth(): number` (L1706)
  The list's own border width (container_border_width); 0 by default.

- `get maximumNumberOfRows(): number` (L1734)
  At most this many rows of each section (container_max_lines); 0 shows every row. Sets `.truncate`.

- `get colorTheme(): CYLTagColorTheme` (L1748)
  Colors every item without a look of its own from a theme (tag_theme); `.none` by default.

- `get tagLongPressHandler(): ((index: number, tag: CYLTag) => void) | undefined` (L1761)
  A long press on an item without moving it: `menuDidLongPressItem`, then this (onTagLongClick).

- `get longPressAccessibilityActionName(): string | undefined` (L1771)
  The name of the long-press action for assistive technologies; undefined: "长按" (`CYLMenuLongPress`).

- `get allowsReordering(): boolean` (L1781)
  A long press and a move reorders the items of a section; needs a data source with `menuMoveItem`.

- `get reorderingSensitivity(): number` (L1791)
  How quickly a press starts reordering: the press lasts 0.5 s divided by it; not positive is 1.

- `get isReordering(): boolean` (L1801)
  Whether an item is being moved (getTagViewState).

- `get longPressDuration(): number` (L1806)
  The long press duration in milliseconds.

- `reloadMenuData(): void` (L1815)
  Reads everything from the data source again; selections and expanded sections still in range are kept.

- `heightThatFitsWidth(width: number): number` (L1854)
  The height the content needs at `width` with the current data and fold state.

- `get tagDataSource(): CYLTagDataSource` (L1888)
  The list's own tags; the first tag method makes it the data source, hides headers and sets `.none`.

- `get tags(): CYLTag[]` (L1899)
  The tags of `tagDataSource`, in order (getTags()).

- `insertTag(tag: CYLTag, index: number): void` (L1922)
  Inserts a tag; selections at or after it move down. An index past the end adds it at the end.

- `removeTag(index: number): void` (L1935)
  Removes a tag; selections after it move up. Out-of-range indexes are ignored.

- `removeTags(indexes: number[]): void` (L1946)
  Removes several tags (removeConsecutiveTags).

- `replaceTags(tags: CYLTag[]): void` (L1965)
  Replaces the tags (setTags).

- `setTagsWithTitles(titles: string[], colors: CYLTagColors[] = []): void` (L1972)
  Replaces the tags with tags of these titles, and colors per tag, in order.

- `setTagsWithCharactersOfText(text: string): void` (L1987)
  `setTags(withCharactersOf:)`: one tag per character of `text`, in order: each character (a letter, a Chinese
  character, an emoji with its modifiers, a space) is one tag, as the word picker's cells (`CYLMenuStyle.wordPicker()`).
  Unlike the first `setTagsWithTitles`, it keeps `selectionMode` (a word picker selects several cells).

- `get selectedText(): string` (L1994)
  `selectedText`: the titles of the selected items joined in item order (a word picker's picked characters).

- `selectItemsFrom(start: CYLIndexPath, end: CYLIndexPath): void` (L2002)
  `selectItems(from:through:)`: selects every selectable item from `start` through `end` (either order), in item
  order across sections, as a smear over them does, without calling the delegate. Needs multiple selection.

- `allowsSmearSelection: boolean = false;` (L2017)
  `allowsSmearSelection`: a finger dragged across the items selects them ("smearing", as WeChat's 涂抹选择填入词): the
  drag starts on the item it touched down on and selects every item from it to the item under the finger, in item
  order, or deselects them when that item was already selected. A tap still toggles one item, so screen readers select
  the same items. Needs multiple selection; a drag that starts between items scrolls. The delegate gets
  `menuDidChangeSelectedItems`. False by default; `CYLMenuStyle.wordPicker()` is the matching look.

- `canSmearFrom(indexPath: CYLIndexPath): boolean` (L2056)
  Whether a smear may start on `indexPath`: smear selection on, multiple selection, not editing, a selectable tag.

- `beginSmear(indexPath: CYLIndexPath): void` (L2063)
  Starts a smear on `indexPath` (the item the finger went down on).

- `smearTo(indexPath: CYLIndexPath | undefined): void` (L2076)
  The selection the smear began with, with the items from its first item to `indexPath` changed.

- `endSmear(): void` (L2094)
  Ends the smear.

- `clearGestureState(): void` (L2113)
  Ends this list's share of `CYLMenuGestureState.shared` (its view went away in the middle of a gesture).

- `get isSmearing(): boolean` (L2118)
  Whether a smear is in progress.

- `deleteItem(indexPath: CYLIndexPath): void` (L2123)
  Deletes a deletable, enabled item as a tap on its delete indicator does.

- `get selectedIndexPaths(): CYLIndexPath[]` (L2146)
  Selected items in ascending order. Setting applies the selection rules; an item outside the menu throws.

- `get selectedTitles(): string[]` (L2167)
  The titles of the selected items, in order (getSelectedTagViewText).

- `selectItem(indexPath: CYLIndexPath): void` (L2176)
  Applies the selection rules without calling the delegate.

- `toggleSelection(indexPath: CYLIndexPath): void` (L2196)
  Selects or deselects an item; in `.none` mode it still selects (any number of items).

- `setExpanded(expanded: boolean, section: number, animated: boolean = false): void` (L2216)
  Expands or collapses a section and calls `menuDidChangeExpanded`.

- `toggleSection(section: number): void` (L2231)
  The fold control's action.

- `canFoldSection(section: number): boolean` (L2236)
  Whether the section has more rows than `defaultVisibleRows` and can fold.

- `numberOfRows(section: number): number` (L2246)
  Number of rows the section's items occupy at the current width.

- `numberOfVisibleItems(section: number): number` (L2252)
  Number of items currently shown in the section (fewer while collapsed).

- `showsInlineFoldCell(section: number): boolean` (L2287)
  Whether a section shows the inline fold control.

- `showsHeaderFoldControl(section: number): boolean` (L2292)
  Whether the section's header shows the fold control.

- `showsFooterFoldControl(section: number): boolean` (L2297)
  Whether the section's footer shows the fold control.

- `foldAccessibilityLabel(section: number): string` (L2302)
  "<section title> <expand or collapse title>", so a fold control says which section it changes.

- `get displayedFoldControl(): CYLMenuFoldControl` (L2315)
  The fold control as shown: `CYLMenuStyle.foldChevronImage` replaces the default chevron.

- `scrollToSection(section: number, animated: boolean = true): void` (L2328)
  Scrolls so that the section (its header, or its first row) is at the top, as far as the content allows.

- `scrollToItem(indexPath: CYLIndexPath, animated: boolean = true): void` (L2346)
  Scrolls so that the item is centered vertically, as far as the content allows.

- `tapItem(indexPath: CYLIndexPath): void` (L2367)
  A tap on an item (`collectionView(_:didSelectItemAt:)`): the inline fold control folds, a tag is handled.

- `tapMoreButton(section: number): void` (L2379)
  The section header's More button.

- `shouldHighlightItem(indexPath: CYLIndexPath): boolean` (L2384)
  Whether an item highlights when pressed.

- `get canReorder(): boolean` (L2436)
  Whether items can be reordered: `allowsReordering` and a data source that moves items.

- `beginLongPress(indexPath: CYLIndexPath): boolean` (L2451)
  A long press began on an item: it starts reordering (reporting a selected item's drag) when the list can
  reorder, else it is reported as a long press. Returns whether reordering started.

- `endLongPress(destination: CYLIndexPath | undefined, moved: boolean): void` (L2470)
  The press ended: moved onto `destination`, or a press that did not move; the long-press action decides what that does.

- `get longPressAction(): CYLTagLongPressAction` (L2520)
  What a long press on an item does: `CYLTagLongPressActions.first([reorder, report])` by default (reordering where the list
  can reorder, else the long press is reported). Set another built-in action, a combination or your own.

- `static calloutPlacesBelow(targetTop: number, targetBottom: number, height: number, safeTop: number,` (L2548)
  Whether a callout of `height` goes below the target (iOS `placesBelow`). Above first; below when it does not fit above
  (`safeTop`) or when it would cover the header (`headerTop`..`headerBottom`, the section header above a first-row tag)
  and it fits below (`bottomLimit`); above when neither side is free of the header and below does not fit. Pure; all
  values are in one coordinate space (the list's content).

- `calloutPlacesBelowItem(indexPath: CYLIndexPath, height: number = CALLOUT_ESTIMATED_HEIGHT): boolean` (L2567)
  Whether the callout of the item goes below it: the bubble above would cover the item's section header and fits below.
  The popup's own flip still handles a lack of room at the window's edges.

- `targetIndexPathForMove(original: CYLIndexPath, proposed: CYLIndexPath): CYLIndexPath` (L2631)
  Where a moved item may go: within its section, among the shown items (not onto the inline fold control).

- `moveItem(source: CYLIndexPath, destination: CYLIndexPath): void` (L2643)
  `collectionView(_:moveItemAt:to:)`: the data source moves the item; the selection moves with it.

- `indexPathAtPoint(x: number, y: number): CYLIndexPath | undefined` (L2676)
  The item at a point of the list's content (below the title), or undefined.

- `reportsLongPress(indexPath: CYLIndexPath): boolean` (L2705)
  Whether a long press is reported for an item (the delegate or `tagLongPressHandler` handles it).

- `numberOfDisplayedItems(section: number): number` (L2717)
  `collectionView(_:numberOfItemsInSection:)`: the visible items and the inline fold control.

- `titleForItem(indexPath: CYLIndexPath): string` (L2722)
  The title an item shows ("新建标签：<name>" for a create item).

- `styleForItem(indexPath: CYLIndexPath): CYLMenuStyle` (L2787)
  The item's own look, or its section's (themed by `colorTheme`; outlined for a create item).

- `styleForSection(section: number): CYLMenuStyle` (L2805)
  The section's own look, or the list's style.

- `moreButtonAccessibilityLabel(section: number): string` (L2814)
  The More button's label: the data source's, else "<section title> 更多".

- `tagAt(indexPath: CYLIndexPath): CYLTag | undefined` (L2841)
  One of `tags` when the list shows them.

- `headerInnerWidth(width: number = this.layoutWidth): number` (L2897)
  The header's inner width at the list width `width` (default the list width): the width between the header edges
  (the tag column: the width minus the leading and trailing header edges).

- `headerFoldSize(expanded: boolean, width: number = this.layoutWidth, section: number = -1): CYLSize` (L2908)
  The fold control's size in a header. Its width is the same collapsed and expanded (so the title room never changes
  when toggling): the wider of the two natural widths, at most `CYLHeaderFoldAloneMaxFraction` of the header's inner
  width, or `CYLHeaderFoldSharedMaxFraction` when `section` also shows a More button, a clear button or an accessory.
  The title keeps the rest and is the one that shrinks. `section` -1 (the default) means the fold control alone.

- `showsHeaderAccessory(section: number): boolean` (L2926)
  Whether `section`'s header shows an accessory view (`menuAccessoryViewForSection`).

- `headerAccessoryMaxWidth(section: number, width: number = this.layoutWidth): number` (L2935)
  The most width a header accessory takes: `CYLHeaderAccessoryMaxFraction` of the inner width, 0 when `section` has no
  accessory. An accessory has no measured width on HarmonyOS (it is a builder), so this cap is what the room math
  reserves for it and what the render constrains it to.

- `headerHeight(section: number = -1, width: number = this.layoutWidth, foldable?: boolean): number` (L2950)
  The header's height: `headerHeight`, a line of the title plus its padding, or the fold control, whichever is most.
  With `headerMaxLines` above 1 and a `section`, a title that wraps at the width left of the header's other views makes
  it taller (the wrapped lines, up to the limit, plus the padding). `section` -1 (the default) is the one-line height.
  A fold control in the header counts only where it is shown: `foldable` says whether the section can fold at `width`
  (default: `canFoldSection(section)`, and true for no section), so an unfoldable section reserves nothing for it.

- `headerTitleRoom(section: number, width: number = this.layoutWidth, foldShown?: boolean): number` (L2999)
  The title's maximum width in `section`'s header at the list width `width`: the inner width less the fixed views of
  the row (indicator bar, section icon, clear button, More button, accessory, fold control) and `HEADER_ITEM_SPACING`
  for each of them, at least one em of the header font (and 1). With no other view it is the inner width. The title
  wraps to `headerMaxLines` at exactly this width. The one function the header height and the render both use (the
  frame's `headerTitleWidth`). `foldShown` says whether the fold control is in the header (default: the section's
  header shows it).

- `contentColumn(section: number): CYLRect` (L3066)
  The section's column at the current layout width (`sectionInsets` taken off the list width).

- `tagColumn(section: number): CYLRect` (L3074)
  The tag column: `contentColumn(section)`, narrowed by the card's padding under `insetGrouped` (never by `sectionBoardInset`). Every
  tag width, row count, fold decision, height and frame takes its width and x from here.

- `invalidateMeasurements(): void` (L3210)
  Drops the cached item sizes, so the next layout measures again (the view calls it once it has a UI context,
  replacing sizes estimated before).

- `layoutSections(): CYLTagListSectionFrame[]` (L3252)
  The sections as laid out at the current width (`CYLCollectionViewLeftAlignedLayout`): a header, rows of the
  visible items (and the inline fold control) aligned by `style.rowAlignment`, each row as tall as its tallest item
  with its items centered in it, and a footer. Positions are below the title.

- `get configurationDataSource(): CYLMenuDataSource | undefined` (L3403)
  The data source built from `CYLTagListKey.sections`, or undefined.

- `static withConfiguration(configuration: CYLConfiguration): CYLTagListState` (L3408)
  `init(configuration:)`: a tag list from one dictionary holding everything (`CYLTagListKey`).

- `static withConfigurationFile(filePath: string, context?: Context): CYLTagListState` (L3415)
  `init(configurationFile:)`: reads a configuration file and creates a tag list from it.

- `static configurationContentsOfFile(filePath: string, context?: Context): CYLConfiguration` (L3423)
  Reads a JSON configuration file: an absolute path (a sandbox file), or the name of a rawfile of the app (with
  `context`). Throws `CYLMenuConfigurationError`.

- `applyConfiguration(configuration: CYLConfiguration): void` (L3463)
  Applies a configuration to an existing list; keys that are missing keep their values.

- `export class CYLTagListConfigurationSource implements CYLMenuDataSource` (L3584)
  The data source of `CYLTagListKey.sections`.

## harmony/classifymenu/src/main/ets/components/CYLTagListSupplementaryView.ets

A section header or footer of the tag list (iOS `CYLTagListHeaderView` / `CYLTagListFooterView`), as the object
the list draws it from: `CYLTagListState.viewForSupplementaryElementOfKind(kind, indexPath)` returns it. The list
configures it from its data source and style when that data changes (a reload, a fold, a style); changes made to it
in between are drawn: call `setNeedsDisplay()` after changing it.

- `export const CYLTagListElementKindSectionHeader: string = 'UICollectionElementKindSectionHeader';` (L11)
  `UICollectionView.elementKindSectionHeader`.

- `export const CYLTagListElementKindSectionFooter: string = 'UICollectionElementKindSectionFooter';` (L13)
  `UICollectionView.elementKindSectionFooter`.

- `export class CYLTagListSupplementaryView` (L15)

- `readonly titleLabel: CYLTagButtonPart = new CYLTagButtonPart();` (L19)
  The section title (`isHidden` when section titles are hidden). Header only.

- `readonly iconView: CYLTagButtonPart = new CYLTagButtonPart();` (L21)
  The section icon (`menuImageForSection`). Header only.

- `indicatorColor?: string;` (L23)
  The bar before the title; undefined: none.

- `showsFoldButton: boolean = false;` (L28)
  The fold control (in a header, or the footer's only content).

- `showsMoreButton: boolean = false;` (L31)
  The More button.

- `configuredInputs: string = '';` (L37)
  The inputs it was last configured from (the list reconfigures it only when they change).

- `setDisplayHandler(handler: (() => void) | undefined): void` (L46)
  Called by the list that draws it.

- `setNeedsDisplay(): void` (L51)
  Draws the changes made to it.

- `get icon(): CYLImage | undefined` (L56)
  The icon's image.

## harmony/classifymenu/src/main/ets/components/CYLTagListView.ets

- `const HEADER_TITLE_LINES_CEILING: number = 1000;` (L31)
  The most lines a header title is given to ArkUI (`CYLHeaderTitleMaxLines.unlimited` is too large for a Text).

- `class CYLTagRenderItem` (L34)
  What a tag (or a fold control, or the title) shows, resolved from the list's state for one render.

- `itemBackgroundStyle: CYLAnimatedItemBackgroundStyle = CYLAnimatedItemBackgroundStyle.flat;` (L54)
  The inline fold cell: the background style a tag of its list draws (glass or flat).

- `appearanceCornerRadius: number = 0;` (L56)
  The inline fold cell: the appearance's radius as it is (the capsule constant by default), as `CYLTagButton`.

- `glassTint?: ResourceColor = undefined;` (L58)
  The inline fold cell: the explicit glass tint (the normal appearance's explicit background), undefined for the frosted default.

- `adaptedOnGlass(color: ResourceColor, kind: string): ResourceColor` (L65)
  The dark-glass rule for a colour this item draws (`CYLTagButton.adaptedOnGlassOf`, the tag's own rule):
  the colour itself unless this item draws glass (`itemBackgroundStyle`: only the inline fold cell does) in dark mode, then lifted
  to 4.5:1 (text) or 3:1 (icon). Read when the item draws, so a light / dark switch re-resolves it.

- `resolvedTextColor(): ResourceColor` (L70)
  The title colour to draw.

- `resolvedIconColor(): ResourceColor` (L75)
  The icon colour to draw (the fold control's own colour stays explicit, and is lifted like any explicit icon colour).

- `cell?: CYLTagListCell;` (L100)
  A tag: the cell it is drawn from (`CYLTagListState.cellForItemAt`).

- `class CYLSectionDecoration` (L104)
  A section card, header band or header divider, resolved for one render: a filled, optionally rounded rectangle.

- `background: CYLAnimatedItemBackgroundStyle = CYLAnimatedItemBackgroundStyle.flat;` (L113)
  The drawn background: flat, or the core's Liquid Glass tinted with `color`.

- `class CYLSectionRender` (L117)
  A section header or footer, resolved for one render.

- `rtl: boolean = false;` (L130)
  Right to left: the header row is mirrored (its views in reverse order, the title aligned to its right end).

- `maxLines: number = 1;` (L132)
  The most lines of the title.

- `iconColor: ResourceColor = CYLColor.BLACK;` (L144)
  The section icon's tint (`CYLMenuStyle.resolvedTintColor`).

- `showsClear: boolean = false;` (L147)
  The clear button (`menuShowsClearButtonForSection`): a square as tall as a line of the title.

- `titleMaxWidth: number = 0;` (L154)
  The title's width (`CYLTagListSectionFrame.headerTitleWidth`): the width the header height was computed for.

- `accessoryMaxWidth: number = 0;` (L156)
  The accessory's maximum width (`CYLTagListSectionFrame.headerAccessoryMaxWidth`).

- `function legacyConfiguration(raw: CYLConfiguration): CYLConfiguration` (L174)
  Copies a parsed JSON value into a configuration, reading the cross-platform JSON's older keys.

- `export struct CYLTagListView` (L226)
  A tag list: sections of tags in left-aligned rows, with single or multiple selection, folding, a title, deletion,
  long presses and reordering, as iOS `CYLTagListView`. Its state and API are a `CYLTagListState` (`tagList`, made
  by the view when not given); `configuration` is the JSON of the Flutter and React Native components and of iOS
  `init(configuration:)`, applied over that state whenever it changes.

- `controller?: CYLTagListController;` (L234)
  Plays the animated icons again (`playAll()`).

- `layoutDirection?: CYLLayoutDirection;` (L236)
  The layout direction; undefined (the default) follows the system language.

- `tagList?: CYLTagListState;` (L238)
  The list's state and API; made by the view when not given.

- `content(r: CYLTagRenderItem)` (L866)
  The content of a tag: the delete indicator, the icon and the title, in their placements.

- `foldButton(r: CYLTagRenderItem)` (L897)
  A fold control in a header or footer.

- `foldCellButton(r: CYLTagRenderItem)` (L916)
  The inline fold control, the last item of a section.

- `addItemControl()` (L1053)
  `CYLTagListAddItemView` while editing: a text field and an Add button below the last section.

## harmony/classifymenu/src/main/ets/core/CYLAccessibilitySelected.ets

- `export class CYLAccessibilitySelectedModifier<T extends CommonMethod<T>> implements AttributeModifier<T>` (L7)
  Sets the accessibility selected state where the system has it (API 13 and later); the library targets API 12,
  where the attribute does not exist and the state is left out.

## harmony/classifymenu/src/main/ets/core/CYLMenuColor.ets

`CYLMenuColorFromString`: "#RGB", "#RRGGBB", "#RRGGBBAA" (alpha last, as on iOS), or the name of a UIColor class
property ("systemBlue", "systemBlueColor", "red"...), as '#AARRGGBB'; undefined when it is none of them.

- `const UI_COLOR_NAMES: Map<string, string> = new Map<string, string>([` (L8)
  The UIColor class properties a configuration may name, in their light appearance.

- `const ARGB_DIGITS: number = 8;` (L52)
  The channel bytes of a '#AARRGGBB' or '#RRGGBB' color.

- `const SRGB_LINEAR_CUTOFF: number = 0.03928;` (L56)
  Linearization of an sRGB channel (WCAG 2.x).

- `export function CYLMenuColorLuminance(color: ResourceColor | undefined): number | undefined` (L77)
  The WCAG relative luminance (0 black ... 1 white) of an opaque color given as '#AARRGGBB', '#RRGGBB' or a number
  (0xRRGGBB, or 0xAARRGGBB above 0xFFFFFF). Undefined when the color cannot be read as an opaque color: no color, a
  transparent or translucent one, or a resource. A resource (`$r(...)`, such as the library's palette) is not resolved: a
  system resource has no value that a host test or the style can read, only the drawing sees it; the callers use the
  system mode for it (the library's palette flips with the mode as the system tint does).

## harmony/classifymenu/src/main/ets/core/CYLMenuDataSource.ets

The data source and delegate of a menu, as iOS `CYLMenuDataSource.swift`. ArkTS interfaces have no default
methods: the four required data source methods are methods, every optional one is an optional function property, and
`CYLMenuDefaults` gives the iOS default of each (the value when a data source does not implement it).

- `export enum CYLMenuItemType` (L12)
  What an item of a tag list is: a tag (the default), or "+ 新建标签", which asks for a name.

- `export interface CYLMenuDataSource` (L18)
  The sections and items of a menu, owned by the host.

- `menuSubtitleForItem?: (indexPath: CYLIndexPath) => string | undefined;` (L28)
  The item's subtitle, shown in a callout with an arrow on a long press when the list's `longPressAction` includes
  `CYLTagLongPressActions.callout` (a longer description of a short title). undefined or empty: none.

- `menuImageForItem?: (indexPath: CYLIndexPath) => CYLImage | undefined;` (L31)
  An image shown before the title (a resource or a path).

- `menuSelectedImageForItem?: (indexPath: CYLIndexPath) => CYLImage | undefined;` (L33)
  The image of a selected item.

- `menuAnimationURLForItem?: (indexPath: CYLIndexPath) => string | undefined;` (L35)
  A Lottie animation played as the item's icon: `asset:<rawfile path>` or the JSON text.

- `menuAnimationRestingProgressForItem?: (indexPath: CYLIndexPath) => number | undefined;` (L37)
  The progress (0...1) the animation rests at while not selected.

- `menuStyleForSection?: (section: number) => CYLMenuStyle | undefined;` (L39)
  The style of a section (the list's style when undefined).

- `menuStyleForItem?: (indexPath: CYLIndexPath) => CYLMenuStyle | undefined;` (L41)
  The style of one item (its section's style when undefined).

- `menuImageForSection?: (section: number) => CYLImage | undefined;` (L43)
  The icon of a section header.

- `menuAccessoryViewForSection?: (section: number) => WrappedBuilder<[number]> | undefined;` (L48)
  A view at the trailing end of a section header, left of a trailing fold control, at most
  `CYLHeaderAccessoryMaxFraction` (30%) of the header's inner width (a builder that takes the section; ArkTS passes builders as WrappedBuilder).

- `menuItemIsExclusive?: (indexPath: CYLIndexPath) => boolean;` (L51)
  An item that clears the other selected items of its section (the "全部" of a filter).

- `menuMoveItem?: (from: CYLIndexPath, to: CYLIndexPath) => void;` (L60)
  Implemented when the list may reorder items (iOS: `respondsToSelector:`).

- `menuSectionAllowsEditing?: (section: number) => boolean;` (L65)
  `menuSectionAllowsEditing(_:)`: whether a section takes part in `CYLTagListState`'s editing mode (delete indicators,
  reordering); true when not implemented.

- `menuCacheKeyForSection?: (section: number) => string;` (L70)
  `menuCacheKey(forSection:)`: the key the list saves a section's titles under in its cache (`cachePolicy`), stable
  when sections come and go (e.g. "mine"); the section's index when not implemented.

- `menuIdentifierForItem?: (indexPath: CYLIndexPath) => string;` (L75)
  `menuIdentifierForItem(at:)`: the item's stable identifier (a database id), kept by the list's cache and sync so a
  reorder or a rename never loses what the item stands for; its title when not implemented.

- `menuRenameItem?: (indexPath: CYLIndexPath, title: string) => void;` (L81)
  `menuRenameItem(at:to:)`: rename the item in your data. Implementing it shows the rename indicator (an edit icon
  before the delete indicator) in editing mode; its submit calls this, then the list reloads, saves its cache and
  calls `menuDidRenameItem`.

- `menuShowsClearButtonForSection?: (section: number) => boolean;` (L87)
  `menuShowsClearButton(forSection:)`: shows a clear button (the trash icon, `CYLMenuStyle.clearButtonImage`) at the
  trailing end of the section's header; a tap calls `menuDidTapClearButtonInSection` and `clearButtonHandler`. False
  when not implemented.

- `export interface CYLMenuDelegate` (L94)
  Selection, new items, folding, height, the More button, deletion, long press, reordering and dragging of a menu.
  Every method is optional; `menu` is the list that calls it.

- `menuDidChangeReordering?: (menu: Object, reordering: boolean) => void;` (L105)
  `menuDidChangeReordering(_:reordering:)`: a drag (reordering) started (true) or ended (false: a drop or a cancelled
  touch), once per change, as the mini program's `reorderingchange`; a container turns its own scrolling off while it
  is true.

- `menuDidChangeSmearing?: (menu: Object, smearing: boolean) => void;` (L110)
  `menuDidChangeSmearing(_:smearing:)`: a word picker smear (`allowsSmearSelection`) started (true) or ended (false),
  once per change, as the mini program's `smearingchange`.

- `menuDidChangeEditing?: (menu: Object, editing: boolean) => void;` (L120)
  `menu(_:didChangeEditing:)`: the list entered (true) or left (false) editing mode (`setEditing`).

- `menuDidFinishEditingWithTitles?: (menu: Object, titles: Map<string, string[]>) => void;` (L125)
  `menu(_:didFinishEditingWithTitles:)`: the list's editing ended; the edited sections' titles by cache key
  (`cacheKeyForSection`), in their new order, already saved to its cache: upload them to your server here.

- `menuDidFinishEditingWithItems?: (menu: Object, items: Map<string, CYLTagListCacheItem[]>) => void;` (L127)
  `menu(_:didFinishEditingWithItems:)`: the same edited sections as items (stable identifier and title).

- `menuDidRenameItem?: (menu: Object, indexPath: CYLIndexPath, title: string) => void;` (L129)
  `menu(_:didRenameItemAt:to:)`: the list renamed an item in editing mode, already saved to its cache.

- `menuDidTapClearButtonInSection?: (menu: Object, section: number) => void;` (L131)
  `menu(_:didTapClearButtonInSection:)`: a section header's clear button was tapped: clear the section's data.

- `export class CYLMenuDefaults` (L135)
  The iOS defaults of the optional data source methods, for a data source that does not implement them.

- `static supportsMovingItems(source: CYLMenuDataSource): boolean` (L161)
  Whether the list may reorder items: the data source moves them.

- `static shouldSelect(delegate: CYLMenuDelegate | undefined, menu: Object, indexPath: CYLIndexPath): boolean` (L166)
  Whether `menuShouldSelectItem` allows the selection (true when the delegate does not implement it).

## harmony/classifymenu/src/main/ets/core/CYLMenuFoldControl.ets

The fold control of a `CYLTagListView` ("更多 ⌄"), as iOS `CYLMenuFoldControl.swift`: where it is (below the
section, in the section header, or as the last tag) and what it shows (icon and title, title only, icon only, or
title and icon always). Expanded, a control with an icon keeps only the icon, turned 180°; a title-only control shows
its collapse title; a title-and-icon-always control shows its collapse title and the turned icon.

- `export const CYLFoldControlMaxFontScale: number = 1.3;` (L14)
  The most the system font scale grows a fold / More control (its text and its size). At accessibility font sizes the
  control would otherwise dwarf the header; tags and titles keep scaling normally.

- `export const CYLHeaderFoldAloneMaxFraction: number = 0.4;` (L20)
  The widest a fold control in a section header gets when it is the only extra view of the header row, as a fraction of
  the header's inner width (the width between the header edges); the title gives way.

- `export const CYLHeaderFoldSharedMaxFraction: number = 0.3;` (L26)
  The widest a fold control in a section header gets when a More button, a clear button or an accessory is also shown,
  as a fraction of the header's inner width.

- `export const CYLHeaderAccessoryMaxFraction: number = 0.3;` (L29)
  The widest a header accessory view gets, as a fraction of the header's inner width.

- `export const CYLHeaderFoldMaxWidthFraction: number = CYLHeaderFoldAloneMaxFraction;` (L32)
  The widest a fold control in a section header gets alone: `CYLHeaderFoldAloneMaxFraction` (the older name).

- `export enum CYLMenuFoldControlPosition` (L35)
  Where the fold control of a foldable section is.

- `none = 0,` (L37)
  No fold control: every row is shown.

- `footer = 1,` (L39)
  Centered below the section's tags.

- `headerTrailing = 2,` (L41)
  At the trailing edge of the section header.

- `headerLeading = 3,` (L43)
  At the leading edge of the section header.

- `tail = 4` (L45)
  The last item of the tags.

- `export enum CYLMenuFoldControlContent` (L49)
  What the fold control shows while the section is collapsed.

- `iconAndTitle = 0,` (L51)
  "更多 ⌄"; expanded, only the icon, turned.

- `title = 1,` (L53)
  "更多"; expanded, the collapse title ("收起").

- `icon = 2,` (L55)
  "⌄"; expanded, the same icon, turned.

- `titleAndIcon = 3` (L61)
  "更多 ⌄" collapsed and "收起 ⌃" expanded ("More ⌄" / "Less ⌃"): the title and the icon in both states, the icon
  turned 180° when expanded. In a configuration: "titleAndIconAlways" ("titleAndIcon" is an older alias of
  `iconAndTitle`).

- `export class CYLMenuFoldControl` (L64)

- `color?: string;` (L68)
  Title and icon color; undefined uses `CYLMenuStyle.foldControlColor`.

- `font?: CYLFont;` (L70)
  Undefined: the footnote size (13 fp).

- `rotatesImageWhenExpanded: boolean = true;` (L72)
  The icon turns 180° when expanded.

- `get title(): string` (L84)
  Shown while collapsed; default the localized "更多" (`CYLMenuExpand`).

- `get collapseTitle(): string` (L93)
  Shown while expanded by a control that keeps its title; default the localized "收起" (`CYLMenuCollapse`).

- `get image(): CYLImage` (L102)
  The icon, pointing down while collapsed; default the core's chevron (`cyl_fold_chevron`).

- `get usesDefaultImage(): boolean` (L111)
  True while `image` is the default chevron.

- `titleWhenExpanded(expanded: boolean): string | undefined` (L132)
  The title shown in that state, or undefined.

- `copy(): CYLMenuFoldControl` (L140)
  NSCopying (the image and colors are shared).

## harmony/classifymenu/src/main/ets/core/CYLMenuGestureState.ets

- `export class CYLMenuGestureState` (L16)
  `CYLMenuGestureState.shared`: whether any tag list has a drag (reordering) or a word picker smear in progress, so a
  container can hold its own scrolling meanwhile without knowing the host's delegate (an ArkTS builder gives no event
  bubbling). Every `CYLTagListState` reports here as its gestures start and end, besides calling its delegate's
  `menuDidChangeReordering` / `menuDidChangeSmearing`.
  A container (e.g. a search page's content `Scroll`) listens while it is shown:
    aboutToAppear():    CYLMenuGestureState.shared.addListener(this.onGesture)
    aboutToDisappear(): CYLMenuGestureState.shared.removeListener(this.onGesture)
    Scroll(...).enableScrollInteraction(!this.gestureActive)
  Each tag list's share is kept apart (a list removed in the middle of a drag clears its own share), so the state is
  active while at least one list has a gesture.

- `static readonly shared: CYLMenuGestureState = new CYLMenuGestureState();` (L18)
  The one state every tag list reports to.

- `get isActive(): boolean` (L24)
  Whether any tag list has a drag or a smear in progress.

- `addListener(listener: (active: boolean) => void): void` (L29)
  Calls `listener(active)` whenever `isActive` changes (not on every report).

- `setActive(owner: number, active: boolean): void` (L40)
  A tag list (`owner`, its id) reports whether it has a gesture in progress.

## harmony/classifymenu/src/main/ets/core/CYLMenuKeys.ets

- `export const kDataSourceSectionKey: string = 'Items';` (L5)
  The keys of a classify-menu data source's dictionaries, as iOS `CYLMenuKeys.swift` (data.json: `Items`,
  `Item_Title`, `Picture`).

- `export class CYLMenuKeys` (L10)
  The same keys as static members, as iOS `CYLMenuKeys`.

