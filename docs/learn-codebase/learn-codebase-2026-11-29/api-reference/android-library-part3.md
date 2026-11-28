# android: library (part 3 of 4)

## android/merged/library/src/main/java/com/cyl/classifymenu/CYLTagButton.kt

- `open class CYLTagButton @JvmOverloads constructor(` (L49)
  `CYLTagButton`: one tag, built on CYLTabBarController's shared animated icon + title component `CYLAnimatedItemView`
  (module `:cylanimateditem`, Maven `io.github.chenyilong:cyltabbarcontroller-animateditem`; guide:
  https://github.com/ChenYilong/CYLTabBarController/blob/feat/cross-platform-components/docs/Animated-Item.md): an icon
  (or an animated icon) before, after, above or below a title, an optional delete indicator (the base class's
  `accessoryView`, a title or a drawn cross) and an optional badge, drawn in the style's appearance for its state
  (normal, selected, disabled, pressed). The icon, the title, `animationURL`, the speed, the loops, the playback and the
  display priority are the base class's: the animation when it can play (its library is in the app: Lottie, libpag,
  rive-android, SVGAPlayer; GIF needs none); otherwise the static `image` / `selectedImage`; the component's placeholder
  only when there is no static image. A tag with a title and no icon never shows a placeholder. The core adds no
  animation library. Lengths are dp; `widthForTitle…` / `heightForStyle` / `heightForTitle` measure a tag before it
  exists. Use it on its own with `CYLTagButton(context, title, image)` or `CYLTagButton(context, title, image, animationURL)`.

- `val imageView: ImageView get() = iconView` (L55)
  The icon: the base class's `iconView`.

- `val titleLabel: TextView get() = titleView` (L58)
  The title: the base class's `titleView`.

- `val deleteIndicatorLabel: TextView = TextView(context).apply` (L64)
  The delete indicator (a title, or empty under a drawn cross), shown while `showsDeleteIndicator`: the base
  class's `accessoryView`, so a tap on it calls `gestureListener.onAccessoryTapped`.

- `val badgeLabel: TextView = TextView(context).apply` (L70)
  `badgeLabel`: draws the badge (hidden while `badgeValue` is null), at the top trailing corner of the icon.

- `val liquidGlassView: View? get() = itemLiquidGlassView` (L89)
  The Liquid Glass layer behind the content (CYLAnimatedItemView's `itemLiquidGlassView`) while `style.resolvedBackgroundStyle`
  is Liquid Glass and the device draws it; null while the tag is flat.

- `internal val drawnCrossColor: Int get() = crossPaint.color` (L95)
  The colour the delete cross is drawn with (after the glass adaptation); read by the tests.

- `var deleteIndicatorHitFrame: CYLRect = CYLRect()` (L104)
  The delete indicator's touch area in this view, dp (`CGRectZero` when hidden).

- `var badgeValue: String? = null` (L153)
  `badgeValue`, as `UITabBarItem.badgeValue`: null (the default) hides the badge, "" shows a dot, any other text
  ("3", "99+") a capsule with it, at the top trailing corner of the icon (of the title when there is no icon).
  TalkBack reads it after the title.

- `var badgeColor: Int? = CYLTagBadgeDefaultColor` (L161)
  `badgeColor`: the badge's background; null restores the default, system red (#FF3B30). The text is white.

- `var style: CYLMenuStyle? = CYLMenuStyle.defaultStyle()` (L172)
  The style (a copy); null resets it to the default style (null_resettable).

- `override var title: CharSequence?` (L190)
  The title (the base class's), shown through the style (`displayedTitleForTitle`).

- `override var image: Drawable?` (L199)
  The static icon (the base class's): shown until an animation shows, whenever none can play, while it downloads.

- `override var selectedImage: Drawable?` (L207)
  Shown while selected (the base class's); null keeps `image`.

- `override var animationURL: String?` (L215)
  The animation file (the base class's): a path, `file://`, `file:///android_asset/…` or a remote URL.

- `override var animationSource: CYLTabBarItemAnimationViewMaking` (L224)
  Where animation views come from (the base class's).

- `override var animationRestingProgress: Float` (L232)
  Where an unselected animation rests, 0…1 (0: the first frame); the base class's.

- `override var animationSpeed: Float` (L244)
  `animationSpeed` (the base class's), applied at once, also to an animation that is playing. Until it is set, the
  tag follows `style.animationSpeed`; `resetAnimationSpeed()` goes back to it.

- `fun resetAnimationSpeed()` (L252)
  `-resetAnimationSpeed`: follows `style.animationSpeed` again after `animationSpeed` was set.

- `var showsRenameIndicator: Boolean = false` (L269)
  `showsRenameIndicator`: shows a rename indicator (a square and pencil) before the delete indicator, for a tag that
  can be renamed; the two icons are then drawn by `editingIndicatorsView`. Needs `showsDeleteIndicator`. False by
  default; `CYLTagListView` turns it on in editing mode for the items its data source can rename.

- `var renameIndicatorHitFrame: CYLRect = CYLRect()` (L277)
  `renameIndicatorHitFrame`: the area a tap on the rename indicator should cover, dp; empty while it is hidden.

- `val editingIndicatorsView: CYLAnimatedItemStackView by lazy` (L288)
  `editingIndicatorsView`: the two editing icons while `showsRenameIndicator` (a pencil, then a cross), a
  `CYLAnimatedItemStackView` in a row (`axis` Horizontal) of two icon-only `CYLAnimatedItemView`s,
  `CYLMenuStyle.editingIndicatorSpacing` apart (`spacingDp`), tinted with the indicator color (`iconColor`). It only
  draws; the list cell takes the taps.

- `override fun onItemStateChanged()` (L322)
  The look of the state (selected, enabled), from the style's appearance (the base class's hook).

- `override fun onConfigurationChanged(newConfig: android.content.res.Configuration)` (L337)
  The light / dark mode may have changed: the colors the style leaves unset (the text and icon default, the glass tint) resolve
  again, no app code needed. The base class re-applies its own colors first; the tag's own come after.

- `val isHighlighted: Boolean get() = isPressed` (L343)
  `isHighlighted`: pressed.

- `override fun onTouchEvent(event: MotionEvent): Boolean` (L350)
  A tag that is not clickable (a list cell's, whose cell handles the touches) leaves the touches to its parent, as
  a plain non-clickable view does.

- `override fun playAnimation()` (L365)
  Plays the animated icon (the base class's `playAnimation`), not with Remove animations / Reduce Motion, where it
  shows the state's frame; with `animationLoops`, it repeats. Without the file's library it does nothing.

- `override fun accessibilityText(): CharSequence` (L400)
  What TalkBack reads (the base class's hook): the title as shown, or the icon's label for an icon-only tag.

- `override val usesBuiltInColors: Boolean get() = false` (L410)
  The tag hands every color through the item's channels (explicit: setSubclass*Color; unset: apply*TintColor), so the component's own
  built-in level must not fill in. Kept (not removed): while disabled, the item's icon resolution puts the COMPONENT's disabled color
  above the subclass colors when this is true, and an icon that keeps its own colors (badge, original image) hands none at all.

- `var badgeFrame: CYLRect = CYLRect()` (L679)
  `badgeFrame`: the badge's frame in this view, dp (`CYLRect()` while it is hidden).

- `override fun onInitializeAccessibilityNodeInfo(info: AccessibilityNodeInfo)` (L712)
  The title (or the content description) and then the badge, as iOS reads the label and the value.

- `internal fun wrappedTextHeight(text: String, font: CYLFont, width: Float, maxLines: Int): Float` (L813)
  The height of [text] in [font] wrapped to [width] dp and cut at [maxLines] lines, dp: what a title that may wrap needs.

- `fun heightForTitleWidth(title: String?, iconSize: CYLSize, width: Float, showsDeleteIndicator: Boolean, style: CYLMenuStyle): Float` (L828)
  The height of a tag [width] dp wide whose title may wrap ([CYLMenuStyle.titleMaxLines] above 1): the title wrapped to
  the room it has beside the icon and the delete indicator, cut at the limit, plus the insets; at least
  [heightForTitle]. A one-line style, or an icon above or below the title, keeps [heightForTitle].

- `internal fun textWidth(text: String, font: CYLFont): Float = paintFor(font).measureText(text) / systemDensity` (L845)
  The width of `text` in `font`, dp (`-sizeWithAttributes:`).

- `internal fun fontLineHeight(font: CYLFont): Float = lineHeight(paintFor(font))` (L848)
  The line height of `font`, dp (`UIFont.lineHeight`).

- `fun isAnimationEngineAvailable(): Boolean = true` (L861)
  `+isAnimationEngineAvailable`: CYLTabBarController's animation engine is linked. It comes with the
  `cyltabbarcontroller-animateditem` dependency, so it always is; each file type plays once its library is in the
  app (Lottie, libpag, rive-android, SVGAPlayer; GIF needs none).

- `fun iconSizeForImage(image: Drawable?, animated: Boolean, style: CYLMenuStyle): CYLSize` (L878)
  `+iconSizeForImage:animated:style:`.

- `fun widthForTitle(title: String?, image: Drawable?, style: CYLMenuStyle): Float = widthForTitle(title, iconSize(image, style), false, style)` (L887)
  `+widthForTitle:image:style:traitCollection:`.

- `fun widthForTitle(title: String?, iconSize: CYLSize, style: CYLMenuStyle): Float = widthForTitle(title, iconSize, false, style)` (L891)
  `+widthForTitle:iconSize:style:traitCollection:`.

- `internal fun fontCapHeight(font: CYLFont): Float` (L894)
  The cap height of `font`, dp (the height of "H").

- `internal fun editingIconSide(state: Int, style: CYLMenuStyle): Float = ceil(fontCapHeight(style.titleFontForState(state)) * 1.25f)` (L903)
  The side of one editing icon (the pencil or the cross): the title's cap height x 1.25 (iOS 3af1b7cd).

- `fun widthForTitle(title: String?, iconSize: CYLSize, showsDeleteIndicator: Boolean, style: CYLMenuStyle): Float =` (L920)
  `+widthForTitle:iconSize:showsDeleteIndicator:style:traitCollection:`: the widest of the three states, dp.

- `fun widthForTitle(title: String?, iconSize: CYLSize, showsDeleteIndicator: Boolean, showsRenameIndicator: Boolean,` (L928)
  `+widthForTitle:iconSize:showsDeleteIndicator:showsRenameIndicator:style:traitCollection:`: with the rename
  indicator, the two editing icons replace the delete indicator.

- `internal fun styleContentInset(style: CYLMenuStyle): Float =` (L937)
  The space between the border and the content, left and right, that the style's shape asks for: [CYLAnimatedItemLiquidGlassContentInset] for a
  Liquid Glass style where the glass is really drawn (the same condition as the capsule), else 0. The effective inset is the larger of this
  and the appearance's content inset.

- `fun heightForStyle(style: CYLMenuStyle): Float` (L973)
  `+heightForStyle:traitCollection:`: the item height, or the tallest state's text plus insets, dp; with the icon
  above or below the title, also the icon slot and the spacing.

- `fun heightForTitle(title: String?, iconSize: CYLSize, style: CYLMenuStyle): Float` (L990)
  `+heightForTitle:iconSize:style:traitCollection:`: the height a tag needs for this title and an icon of
  `iconSize` (`CYLSize.ZERO` for none) in every state, dp: the taller of the two side by side, or both and the
  spacing when stacked; at least `style.itemHeight`.

- `val CYLTagBadgeDefaultColor: Int = Color.rgb(255, 59, 48)` (L1009)
  `UIColor.systemRed`, the default `CYLTagButton.badgeColor`.

- `object CYLAccessibility` (L1017)
  The system accessibility settings the core follows: Reduce Motion (Remove animations) and Increase Contrast (High
  contrast text).

- `fun isReduceMotionEnabled(context: Context): Boolean =` (L1020)
  `UIAccessibilityIsReduceMotionEnabled()`: the animator duration scale is 0.

- `fun isIncreaseContrastEnabled(context: Context): Boolean =` (L1025)
  `UIAccessibilityDarkerSystemColorsEnabled()`: High contrast text.

## android/merged/library/src/main/java/com/cyl/classifymenu/CYLTagColors.kt

- `enum class CYLTagColorTheme(val value: Int)` (L7)
  `CYLTagColorTheme`: AndroidTagView's `tag_theme`.

- `const val CYLTagColorsBackgroundAlpha: Float = 0x33 / 255f` (L15)
  `CYLTagColorsBackgroundAlpha`: 0x33 / 255.

- `const val CYLTagColorsBorderAlpha: Float = 0x88 / 255f` (L18)
  `CYLTagColorsBorderAlpha`: 0x88 / 255.

- `class CYLTagColors(` (L24)
  `CYLTagColors`: the four colors of a tag (background, border, text, selected background), AndroidTagView's
  ColorFactory: a theme, a random palette color, or your own.

- `fun styleByApplyingToStyle(style: CYLMenuStyle?): CYLMenuStyle` (L32)
  `-styleByApplyingToStyle:`: a copy of `style` (the default style when null) with these colors.

- `public override fun clone(): CYLTagColors = CYLTagColors(backgroundColor, borderColor, textColor, selectedBackgroundColor)` (L50)
  NSCopying.

- `fun colorsWithBackgroundColor(backgroundColor: Int?, borderColor: Int?, textColor: Int?, selectedBackgroundColor: Int?) =` (L63)
  `+colorsWithBackgroundColor:borderColor:textColor:selectedBackgroundColor:`.

- `val paletteHexByName: Map<String, String> = mapOf(` (L68)
  `paletteHexByName`: ColorFactory's colors by name.

- `val gray666666: Int = Color.rgb(0x66, 0x66, 0x66)` (L76)
  `gray666666`.

- `val gray727272: Int = Color.rgb(0x72, 0x72, 0x72)` (L80)
  `gray727272`.

- `fun colorsWithPaletteHex(hex: String, textColor: Int, selectedBackgroundColor: Int) = CYLTagColors(` (L84)
  `+colorsWithPaletteHex:textColor:selectedBackgroundColor:`: `hex` at 0x33 (background) and 0x88 (border).

- `fun colorsForTheme(theme: CYLTagColorTheme, seed: Int): CYLTagColors? = when (theme)` (L90)
  `+colorsForTheme:seed:`: the theme's colors (random: the palette color `seed`), null for None.

- `fun randomColors(): CYLTagColors = colorsForTheme(CYLTagColorTheme.CYLTagColorThemeRandom, Random.nextInt(palette.size))!!` (L99)
  `+randomColors`.

## android/merged/library/src/main/java/com/cyl/classifymenu/CYLTagCreateCell.kt

- `class CYLTagCreateCell @JvmOverloads constructor(context: Context, attrs: AttributeSet? = null) : CYLTagListCell(context, attrs)` (L13)
  `CYLTagCreateCell`: the "+ New tag" item: an outlined tag with a plus; it shows the typed name ("+ New tag "name"").

- `fun configureWithName(name: String?, style: CYLMenuStyle, enabled: Boolean)` (L16)
  `-configureWithName:style:enabled:`.

- `fun plusImage(): Drawable = CYLMenuImage("cyl_tag_plus") ?: CYLMenuIconDrawable(CYLMenuIconDrawable.Kind.PLUS)` (L24)
  `+plusImage`.

- `fun titleForName(name: String?): String` (L28)
  `+titleForName:`: "New tag", or "New tag "name"" (localized).

- `fun styleWithStyle(style: CYLMenuStyle): CYLMenuStyle` (L35)
  `+styleWithStyle:`: `style` outlined: the list's background, a separator-colored border, secondary text.

## android/merged/library/src/main/java/com/cyl/classifymenu/CYLTagFoldButton.kt

- `const val CYL_FOLD_CONTROL_MAX_FONT_SCALE: Float = 1.3f` (L15)
  The largest system font scale a fold control's text follows. A fold / More control sits in a fixed-height header or row, so at
  accessibility font sizes (up to [CYLMaximumFontScale]) it would dwarf its section: it stops growing here, while tags and
  titles keep scaling up to [CYLMaximumFontScale].

- `class CYLTagFoldButton @JvmOverloads constructor(context: Context, attrs: AttributeSet? = null) : CYLTagButton(context, attrs)` (L21)
  `CYLTagFoldButton`: a section's fold control as a tag button: its title and chevron, turned when expanded. Standalone
  (`applyFoldControl`) it is a borderless control; inline (`applyInlineFoldControl`) it looks like the section's tags.

- `fun inlineSizeForFoldControl(foldControl: CYLMenuFoldControl, itemStyle: CYLMenuStyle, expanded: Boolean): CYLSize` (L128)
  `+inlineSizeForFoldControl:itemStyle:expanded:traitCollection:`, dp.

- `fun sizeForFoldControl(foldControl: CYLMenuFoldControl, expanded: Boolean): CYLSize` (L138)
  `+sizeForFoldControl:expanded:traitCollection:`, dp: at least 44 wide and 28 high.

## android/merged/library/src/main/java/com/cyl/classifymenu/CYLTagFoldCell.kt

- `class CYLTagFoldCell @JvmOverloads constructor(context: Context, attrs: AttributeSet? = null) : ViewGroup(context, attrs)` (L10)
  `CYLTagFoldCell`: the inline fold control of a section, as the last item of its folded rows.

- `fun configureWithFoldControl(foldControl: CYLMenuFoldControl, itemStyle: CYLMenuStyle, expanded: Boolean, animated: Boolean)` (L36)
  `-configureWithFoldControl:itemStyle:expanded:animated:`.

## android/merged/library/src/main/java/com/cyl/classifymenu/CYLTagListAccessibility.kt

- `const val CYLTagListTitleAccessibilityIdentifier: String = "CYLTagListTitle"` (L9)
  The title of a tag list (`CYLTagListTitleAccessibilityIdentifier`).

- `const val CYLTagListFoldControlAccessibilityIdentifier: String = "CYLTagListFoldControl"` (L12)
  The fold control.

- `const val CYLTagListItemAccessibilityIdentifier: String = "CYLTagListItem"` (L15)
  A tag.

- `const val CYLTagCreateItemAccessibilityIdentifier: String = "CYLTagCreateItem"` (L18)
  The "+ New tag" item.

- `const val CYLTagListMoreButtonAccessibilityIdentifier: String = "CYLTagListMoreButton"` (L21)
  The More button of a section header.

- `const val CYLTagListDeleteAccessibilityIdentifier: String = "CYLTagListDeleteButton"` (L24)
  A tag's delete control.

- `const val CYLTagListRenameAccessibilityIdentifier: String = "CYLTagListRenameButton"` (L27)
  `renameButton`: the rename indicator of a tag in editing mode (an edit icon before the delete indicator).

- `const val CYLTagListRenameTitleAccessibilityIdentifier: String = "CYLTagListRenameTitle"` (L30)
  `renameTitle`: the title of a renamable tag in editing mode (a tap renames it, `renamesOnTitleTapWhileEditing`).

- `const val CYLTagListClearButtonAccessibilityIdentifier: String = "CYLTagListClearButton"` (L33)
  `clearButton`: a section header's clear button (`menuShowsClearButtonForSection`).

- `class CYLAccessibilityAction(val name: String, val handler: () -> Boolean)` (L38)
  `UIAccessibilityCustomAction`: a named action TalkBack, Switch Access and Voice Access offer on a view.

- `var View.cyl_accessibilityIdentifier: String?` (L41)
  `accessibilityIdentifier`: stored as a view tag (`R.id.cyl_accessibility_identifier`) for tests and tools.

- `fun View.cyl_viewsWithAccessibilityIdentifier(identifier: String): List<View>` (L46)
  Finds the descendants (and this view) whose `cyl_accessibilityIdentifier` is `identifier`.

- `internal object CYLAccessibilityNode` (L60)
  The accessibility of a core view: a button (or not), its selected / enabled state, a hint, and custom actions, as
  `accessibilityTraits`, `accessibilityHint` and `accessibilityCustomActions` on iOS.

## android/merged/library/src/main/java/com/cyl/classifymenu/CYLTagListAddItemView.kt

- `open class CYLTagListAddItemView @JvmOverloads constructor(context: Context, attrs: AttributeSet? = null) : LinearLayout(context, attrs)` (L26)
  `CYLTagListAddItemView`: the "add tag" control of `CYLTagListView` in editing mode, a text field and an Add button.
  The list places it below its last section and reports a submitted name through `menuDidRequestNewItemWithName`;
  customize its field and button (hint, text sizes, colors) as needed.

- `const val textFieldIdentifier: String = "CYLTagListAddItemField"` (L31)
  `textFieldIdentifier`: the text field's identifier ("CYLTagListAddItemField", its tag here).

- `const val addButtonIdentifier: String = "CYLTagListAddItemButton"` (L34)
  `addButtonIdentifier`: the Add button's identifier ("CYLTagListAddItemButton", its tag here).

- `val textField: EditText = EditText(context).apply` (L38)
  The name field. Its hint and TalkBack label are the localized "Tag name" (`CYLMenuAddTagPlaceholder`).

- `val addButton: Button = Button(context).apply` (L53)
  The Add button (`CYLMenuAddTag`); it is enabled while the field has a name.

- `var submitHandler: ((String) -> Unit)? = null` (L63)
  Called with the trimmed name when the Add button or the keyboard's Done key is tapped; the field is cleared.

- `open val preferredHeight: Int` (L66)
  The height of the control, px: 44 dp by default, larger with a larger font scale.

- `open val name: String get() = textField.text?.toString()?.trim().orEmpty()` (L73)
  The trimmed name in the field.

- `var isRenaming: Boolean = false` (L76)
  `isRenaming`: whether the control renames a tag (`beginRenamingWithTitle`) instead of adding one.

- `open fun beginRenamingWithTitle(title: String)` (L83)
  `-beginRenamingWithTitle:`: renames a tag; the field shows `title` with the keyboard up, the button reads "Done"
  (`CYLMenuRenameDone`); the next submit reports the new name, then the control adds tags again.

- `open fun endRenaming()` (L97)
  `-endRenaming`: leaves renaming without a change; the field is cleared and adds tags again.

- `open fun submit()` (L133)
  `submit`: submits the name in the field (as the Add button does): calls `submitHandler` and clears the field.
  An empty name does nothing. TalkBack announces "Tag added: <name>" (`CYLMenuTagAdded`).

## android/merged/library/src/main/java/com/cyl/classifymenu/CYLTagListCache.kt

- `enum class CYLTagListCachePolicy` (L15)
  `CYLTagListCachePolicy`: where `CYLTagListView` keeps the titles of its edited sections (`cachePolicy`), so an order
  changed in editing mode (a drag), a deleted tag or an added one survives a relaunch.

- `interface CYLTagListCache` (L33)
  `CYLTagListCache`: a store of the ordered titles of a tag list's sections. `CYLTagListView` makes the built-in store
  of its `cachePolicy`; implement this interface and set `CYLTagListView.cache` to use another store.

- `fun cachedTitlesForSection(section: String): List<String>?` (L35)
  `cachedTitlesForSection:`: the titles saved for `section`, in order; null when nothing was saved for it.

- `fun saveTitles(titles: List<String>, forSection: String)` (L38)
  `saveTitles:forSection:`: saves `titles` (in this order) as the contents of `section`, replacing what was saved.

- `fun removeTitlesForSection(section: String)` (L41)
  `removeTitlesForSection:`: removes what was saved for `section`.

- `fun removeAllTitles()` (L44)
  `removeAllTitles`: removes every section of this cache.

- `fun cachedItemsForSection(section: String): List<CYLTagListCacheItem>? = null` (L50)
  `cachedItemsForSection:`: the items (stable identifier and title) saved for `section`, in order; null when none
  were saved. Optional on iOS: the default (a cache that keeps titles only) returns null.

- `fun supportsItems(): Boolean = false` (L53)
  Whether `saveItems` is implemented (`respondsToSelector:` on iOS); false for a cache that keeps titles only.

- `fun saveItems(items: List<CYLTagListCacheItem>, forSection: String) {}` (L59)
  `saveItems:forSection:`: saves `items` (in this order) as the contents of `section`; `cachedTitlesForSection` then
  returns their titles. Optional on iOS: the default does nothing.

- `data class CYLTagListCacheItem(val identifier: String, val title: String)` (L67)
  `CYLTagListCacheItem`: one saved item of a tag list, its stable identifier (a database id; the title when the item
  has none) and its current title. A reorder or a rename keeps the identifier, so whatever the host binds to it stays
  bound.

- `class CYLTagListStore(context: Context, val policy: CYLTagListCachePolicy, name: String) : CYLTagListCache` (L76)
  `CYLTagListStore`: the built-in caches (a database, `SharedPreferences` or a file) behind one class, as iOS.
  `name` separates the caches of different lists (the database key, the preferences key or the file name).
  Android needs a `Context` for its storage; iOS uses the app's own folders.

- `val name: String = name.ifEmpty { "CYLTagListView" }` (L78)
  Separates the caches of different lists ("CYLTagListView" when empty).

- `fun cacheWithPolicy(context: Context, policy: CYLTagListCachePolicy, name: String): CYLTagListStore? =` (L88)
  `+cacheWithPolicy:name:`: the store for `policy` and `name`; null for `CYLTagListCachePolicyNone`.

- `enum class CYLTagListLoadPolicy` (L274)
  `CYLTagListLoadPolicy`: in what order `CYLTagListView.loadSectionsWithKeys` reads the cache and the remote source.
  Unlike a search suggestion cache, a tag list may be kept on a server and edited on several devices.

- `enum class CYLTagListDataOrigin` (L286)
  `CYLTagListDataOrigin`: where the titles reported by `CYLTagListView.loadSectionsWithKeys` come from.

- `interface CYLTagListRemoteSource` (L299)
  `CYLTagListRemoteSource`: a server that keeps a tag list's sections, shared by the user's devices. The host implements
  it with its own networking; `CYLTagListView` only asks it for sections (`loadSectionsWithKeys`). Uploading is the
  host's too: `menuDidFinishEditingWithTitles` / `editingFinishHandler` give it the edited sections.

- `fun fetchSectionsWithKeys(keys: List<String>, completion: (Map<String, List<String>>?, Throwable?) -> Unit)` (L304)
  `fetchSectionsWithKeys:completion:`: downloads the sections saved under `keys`; calls `completion` once, on any
  thread, with the titles by key (a missing key: nothing on the server) or an error.

- `fun fetchItemsWithKeys(keys: List<String>, completion: (Map<String, List<CYLTagListCacheItem>>?, Throwable?) -> Unit)` (L310)
  `fetchItemsWithKeys:completion:`: downloads the sections saved under `keys` as items (stable identifier and title),
  for `CYLTagListView.loadItemsWithKeys`. Optional on iOS: the default fetches the titles, each its own identifier.

## android/merged/library/src/main/java/com/cyl/classifymenu/CYLTagListCell.kt

- `open class CYLTagListCell @JvmOverloads constructor(context: Context, attrs: AttributeSet? = null) : ViewGroup(context, attrs)` (L23)
  `CYLTagListCell`: the cell of a tag in a `CYLTagListView`: a `CYLTagButton` filling it, a delete control over the
  button's delete indicator, the touch ripple of the style (AndroidTagView), and the tag's accessibility: its title,
  the badge as its value, selected / not enabled, and the delete action.

- `var appliedStyle: CYLMenuStyle? = null` (L43)
  The style last applied to `button` (held weakly on iOS: compared by identity only).

- `var isRenamable: Boolean = false` (L73)
  `isRenamable`: shows the rename indicator (a pencil before the cross, `CYLTagButton.showsRenameIndicator`) and
  makes it tappable; also adds a TalkBack "Edit" action. Needs `deletable`. False by default.

- `var renameHandler: (() -> Unit)? = null` (L84)
  `renameHandler`: called when the rename indicator is tapped (or the TalkBack action), and on a title tap while `renamesOnTitleTap`.

- `var renamesOnTitleTap: Boolean = false` (L87)
  `renamesOnTitleTap`: a tap on the title (outside the editing icons) renames too. Needs `isRenamable`. False by default.

- `var accessibilityHint: String?` (L115)
  `accessibilityHint` of the cell.

- `fun showRippleAtPoint(point: CYLPoint)` (L162)
  `-showRippleAtPoint:`: the style's ripple from `point` (dp), unless there is no ripple color or Reduce Motion.

- `open fun prepareForReuse()` (L215)
  `-prepareForReuse`.

- `fun configureWithTitle(title: String, image: Drawable?, selectedImage: Drawable?, animationURL: Uri?, style: CYLMenuStyle, selected: Boolean, enabled: Boolean)` (L225)
  `-configureWithTitle:image:selectedImage:animationURL:style:selected:enabled:`.

## android/merged/library/src/main/java/com/cyl/classifymenu/CYLTagListView.kt

- `enum class CYLMenuSelectionMode { CYLMenuSelectionModeNone, CYLMenuSelectionModeSingle, CYLMenuSelectionModeMultiple }` (L29)
  `CYLMenuSelectionMode`.

- `enum class CYLMenuTitlePosition { CYLMenuTitlePositionTopLeading, CYLMenuTitlePositionTopCenter }` (L32)
  `CYLMenuTitlePosition`: where the list's title sits.

- `enum class CYLMenuFoldStyle { CYLMenuFoldStyleNone, CYLMenuFoldStyleHeaderButton, CYLMenuFoldStyleFooterChevron, CYLMenuFoldStyleTruncate }` (L35)
  `CYLMenuFoldStyle`: the older form of `CYLMenuFoldControl`, and truncation (AndroidTagView's max lines).

- `internal const val HEADER_BOARD_TITLE_PADDING = 8f` (L82)
  The title's top and bottom padding in a header that is sized to its text (insetGrouped, no header divider): 4 above, 4
  below, dp. See docs/tag-section-style.md "The gap between the header and the board is short when there is no divider".

- `internal const val HEADER_BOARD_SPACING = 4f` (L85)
  The distance from such a header's bottom edge to the board's top, dp (instead of the section's top inset).

- `open class CYLTagListView @JvmOverloads constructor(` (L96)
  `CYLTagListView`: a list of tags in sections (a `CYLMenuDataSource`) or of `CYLTag`s (`addTag…`, android-tagview's
  TagView and AndroidTagView's TagContainerLayout): flowing rows, section headers with an icon, an accessory view and a
  More button, folding (a fold control in the header, the footer or inline, or truncation), single / multiple /
  exclusive selection, deletion, long press and reordering, a title, and the content height for its container.
  Lengths are dp.

- `val titleView: CYLTagButton = CYLTagButton(context).apply` (L117)
  The title of the list (`titleView`), hidden when there is neither title nor title image.

- `val titleLabel: TextView get() = titleView.titleLabel` (L126)
  The label of `titleView`.

- `var backdropSource: View? = null` (L144)
  `backdropSource` (Android only): the view the Liquid Glass of this list's tags, fold controls and section boards blurs and
  refracts. null (the default) keeps the library's choice, the root of the window's views, which CONTAINS the list: the
  glass then cannot sample it and draws only its tint and rim.
  The one rule: the source must be a view BEHIND the list and NOT an ancestor of it, a sibling plate (for example the
  gradient view under the list in the same parent). The core does not check or guess: an ancestor is passed through
  unchanged and the glass then draws tint + rim, as with null. Below Android 12 (API 31) nothing is sampled and the
  frosted tint + rim fallback shows; refraction needs API 33+ (blur only on API 31 and 32).
  One parameter for the whole list: it is forwarded to every glass host the list makes, now and when it rebuilds (every
  `CYLTagButton`, the inline and header/footer fold controls, the list title and the section boards), and the setter
  applies it to the views already shown, so no `reloadMenuData` is needed. Tag buttons made outside the list are not
  affected. iOS, HarmonyOS and the mini program sample what is behind them by themselves and have no such property.
  See docs/tag-section-style.md "Android backdropSource".

- `fun tagListViewWithFoldPosition(context: Context, position: CYLMenuFoldControlPosition, content: CYLMenuFoldControlContent) =` (L256)
  `+tagListViewWithFoldPosition:content:`.

- `fun defaultTitleStyle(): CYLMenuStyle` (L261)
  `+defaultTitleStyle`: a 17 sp headline in the label color, no box.

- `var style: CYLMenuStyle? = CYLMenuStyle.defaultStyle()` (L293)
  The list's style (a copy); null resets it (null_resettable).

- `var foldControl: CYLMenuFoldControl?` (L329)
  The fold control (a copy); null resets it to no control (null_resettable).

- `var titleStyle: CYLMenuStyle? = defaultTitleStyle()` (L379)
  The title's style (a copy); null resets it to `defaultTitleStyle()` (null_resettable).

- `var defaultVisibleRows: Int = 1` (L392)
  Rows a folded section shows (1 by default).

- `var isScrollEnabled: Boolean` (L399)
  Whether the list scrolls (off inside another scrolling container: it then reports its height).

- `var contentHeight: Float = 0f` (L407)
  The height of all sections and the title for the current width, dp.

- `internal var backgroundColorInUse: Int = 0` (L411)
  The list background as drawn: the style's, or the grouped background under `insetGrouped`, in the current mode.

- `var isEditing: Boolean = false` (L453)
  `isEditing`: whether the list is in editing mode (`setEditing`). While editing, the items of the editable sections
  (`menuSectionAllowsEditing`, every section by default) show the delete indicator and can be dragged to reorder; a
  tap no longer selects an item but still calls `menuDidSelectItemAtIndexPath`, so the host can open the item;
  folded sections show every item; and `addItemView` appears below the last section. False by default.

- `var showsAddItemViewWhileEditing: Boolean = true` (L457)
  `showsAddItemViewWhileEditing`: shows `addItemView` below the last section while editing. True by default.

- `val addItemView: CYLTagListAddItemView by lazy` (L468)
  `addItemView`: the "add tag" control shown while editing, a text field and an Add button. A submitted name is
  reported through `menuDidRequestNewItemWithName` with the index path after the last item of the first editable
  section.

- `var cachePolicy: CYLTagListCachePolicy = CYLTagListCachePolicy.CYLTagListCachePolicyNone` (L478)
  `cachePolicy`: where the list saves its editable sections after an edit (a drag, a delete or an added tag in
  editing mode), so the order survives a relaunch: none (the default), a SQLite database, `SharedPreferences` or a
  file. The host restores it when it builds its data (`cachedTitlesInSection`). Setting it makes `cache` the
  built-in store of the policy and `cacheName`.

- `var cacheName: String = "CYLTagListView"` (L485)
  `cacheName`: separates the caches of different lists ("CYLTagListView" by default); set it before `cachePolicy`.

- `var cache: CYLTagListCache? = null` (L492)
  `cache`: the store the list saves to, the built-in store of `cachePolicy` or one of yours; null: no cache.

- `var remoteSource: CYLTagListRemoteSource? = null` (L495)
  `remoteSource`: the server the sections are also kept on, for `loadSectionsWithKeys`; null: the cache only.

- `var loadPolicy: CYLTagListLoadPolicy = CYLTagListLoadPolicy.CYLTagListLoadPolicyCacheThenNetwork` (L501)
  `loadPolicy`: how `loadSectionsWithKeys` combines the cache and `remoteSource`; `CacheThenNetwork` (the cache at
  once, then a refresh from the server) by default.

- `var editingFinishHandler: ((Map<String, List<String>>) -> Unit)? = null` (L507)
  `editingFinishHandler`: called when editing ends (`setEditing(false, …)`) with the edited sections by cache key,
  after `menuDidFinishEditingWithTitles`: the place to upload them.

- `fun editableSectionTitles(): Map<String, List<String>>` (L513)
  `-editableSectionTitles`: the titles of every editable section by cache key (`cacheKeyForSection`), without
  "+ New tag" items: what the list saves and what `menuDidFinishEditingWithTitles` reports.

- `fun loadSectionsWithKeys(keys: List<String>, completion: (Map<String, List<String>>, CYLTagListDataOrigin) -> Unit)` (L533)
  `-loadSectionsWithKeys:completion:`: reads the sections saved under `keys` from the cache and `remoteSource`, in
  the order of `loadPolicy`, and calls `completion` on the main thread with the titles by key and where they come
  from: once or twice (`CacheThenNetwork`: the cache at once, then the server). Downloaded sections are saved to
  the cache first. Without a remote source it reads the cache only; nothing saved anywhere calls nothing.

- `fun cachedTitlesInSection(section: Int): List<String>? = cache?.cachedTitlesForSection(cacheKeyForSection(section))` (L566)
  `-cachedTitlesInSection:`: the titles saved for `section`, in order; null when nothing was saved or no cache.

- `fun cacheKeyForSection(section: Int): String = menuDataSource?.menuCacheKeyForSection(section) ?: section.toString()` (L569)
  `-cacheKeyForSection:`: the data source's `menuCacheKeyForSection`, else the section's index.

- `fun saveEditableSectionsToCache()` (L572)
  `-saveEditableSectionsToCache`: saves the current titles of every editable section to `cache` (after each edit).

- `fun setEditing(editing: Boolean, animated: Boolean)` (L587)
  `-setEditing:animated:`: enters or leaves editing mode; the delete indicators, reordering, the selection rules,
  folding and `addItemView` change together; then `menuDidChangeEditing` is called. The list itself does not move
  or open anything.

- `fun sectionAllowsEditing(section: Int): Boolean = menuDataSource?.menuSectionAllowsEditing(section) ?: true` (L611)
  `-sectionAllowsEditing:`: the data source's `menuSectionAllowsEditing`, else true.

- `var renamingIndexPath: CYLIndexPath? = null` (L616)
  `renamingIndexPath`: the item being renamed in editing mode (its rename indicator was tapped); null otherwise.

- `var renamesOnTitleTapWhileEditing: Boolean = true` (L624)
  `renamesOnTitleTapWhileEditing`: in editing mode, a tap on a renamable item's title (outside its pencil and cross)
  renames it too; a tap elsewhere still calls `menuDidSelectItemAtIndexPath`. True by default; it needs the data
  source's `menuRenameItemAtIndexPath`.

- `var renameRequestHandler: ((CYLIndexPath, String) -> Unit)? = null` (L635)
  `renameRequestHandler`: your own editor for renaming: when set, a pencil or title tap calls it with the item and its
  title instead of filling `addItemView`; finish with `finishRenamingToTitle` or `cancelRenaming`. null (the
  default): `addItemView` is the rename field.

- `var clearButtonHandler: ((Int) -> Unit)? = null` (L641)
  `clearButtonHandler`: called with the section when its header's clear button (`menuShowsClearButtonForSection`)
  is tapped, after `menuDidTapClearButtonInSection`.

- `fun editableSectionItems(): Map<String, List<CYLTagListCacheItem>>` (L647)
  `-editableSectionItems`: the items (identifier from `menuIdentifierForItemAtIndexPath`, else the title; and title)
  of every editable section, by cache key, without "+ New tag" items.

- `fun beginRenamingItemAtIndexPath(indexPath: CYLIndexPath)` (L671)
  `-beginRenamingItemAtIndexPath:`: starts renaming (the rename indicator does this): `addItemView` shows the title
  with the keyboard up; its submit renames the item through the data source's `menuRenameItemAtIndexPath`.

- `fun cancelRenaming()` (L687)
  `-cancelRenaming`: ends renaming without a change.

- `fun submitNewItemNamed(name: String)` (L698)
  `-submitNewItemNamed:`: adds an item named `name` from your own editor, as `addItemView`'s submit does: reported
  through `menuDidRequestNewItemWithName` at the end of the first editable section, then the cache is saved.

- `fun finishRenamingToTitle(title: String)` (L709)
  `-finishRenamingToTitle:`: renames the item being renamed to `title` (trimmed; an empty or unchanged one only ends
  renaming): the data source renames it, the list reloads, saves its cache and calls `menuDidRenameItemAtIndexPath`.

- `fun loadItemsWithKeys(keys: List<String>, completion: (Map<String, List<CYLTagListCacheItem>>, CYLTagListDataOrigin) -> Unit)` (L729)
  `-loadItemsWithKeys:completion:`: `loadSectionsWithKeys` with identifiers: the cache's items
  (`cachedItemsForSection`) and the remote source's (`fetchItemsWithKeys`, by default its titles, each its own
  identifier), in the order of `loadPolicy`; downloaded items are saved to the cache first.

- `fun reloadMenuData()` (L790)
  `-reloadMenuData`: reads the data source again and lays the list out.

- `fun boardColumn(@Suppress("UNUSED_PARAMETER") section: Int): CYLRect = boardColumnAt(max(0f, measuredContentWidth))` (L1007)
  The board's column at the current layout width (see [boardColumnAt]).

- `fun contentColumn(@Suppress("UNUSED_PARAMETER") section: Int): CYLRect = columnAt(max(0f, measuredContentWidth))` (L1010)
  The section's column at the current layout width (`sectionInsets` taken off the list width).

- `fun tagColumn(@Suppress("UNUSED_PARAMETER") section: Int): CYLRect = tagColumnAt(max(0f, measuredContentWidth))` (L1016)
  The column the tags are laid in: [contentColumn], narrowed by the card's padding under `insetGrouped`. Every tag width,
  row count, fold decision, height and frame takes its width and x from here.

- `internal data class CYLTagListSectionFrame(` (L1050)
  The card, header band and header divider of a section, and the distances of its header title (dp, in the content's
  coordinates, below the title): null where the style draws none. The divider sits at the header's bottom edge inside
  `headerHeight`: it adds no height.

- `internal fun sectionFrame(section: Int): CYLTagListSectionFrame? = content.sectionFrames.getOrNull(section)` (L1063)
  The frames of section `section` as the last layout pass computed them; null before the first one.

- `fun heightThatFitsWidth(width: Float): Float` (L1160)
  `-heightThatFitsWidth:`: the height of the title and every section at `width` dp.

- `val tagDataSource: CYLTagDataSource` (L1263)
  The `CYLTagDataSource` the `addTag…` methods fill (made on first use).

- `val tags: List<CYLTag> get() = _tagDataSource?.tags ?: emptyList()` (L1270)
  The tags of `tagDataSource`.

- `fun deleteItemAtIndexPath(indexPath: CYLIndexPath)` (L1335)
  `-deleteItemAtIndexPath:`: removes it (when `removesItemsOnDelete`) and tells the delegate.

- `var maximumNumberOfRows: Int` (L1376)
  At most this many rows, the others cut (truncation); 0 for no limit.

- `fun tagButtonAtIndexPath(indexPath: CYLIndexPath): CYLTagButton? = content.cellAt(indexPath)?.button` (L1408)
  `-tagButtonAtIndexPath:`: the button of a visible tag, or null.

- `var animationSpeed: Float? = null` (L1416)
  `animationSpeed`: the playback speed of every animated icon, applied at once, also to animations that are
  playing, without reloading the list. null (the default) uses each tag's `style.animationSpeed`.

- `var animationLoops: Boolean = false` (L1426)
  `animationLoops`: true repeats the animated icons after they start playing (a tap, `playAllAnimations()`) until
  it is false; false (the default) plays them once.

- `fun playAllAnimations()` (L1433)
  `-playAllAnimations`: plays the animated icon of every tag from its start (progress 0), whatever its selection.

- `var reorderingSensitivity: Float = 1f` (L1458)
  Higher is quicker: the long press before a drag lasts 0.5 s / sensitivity.

- `val isReordering: Boolean get() = reordering` (L1465)
  `isReordering`.

- `fun canMoveItemAtIndexPath(indexPath: CYLIndexPath): Boolean = canMoveItemAt(indexPath)` (L1476)
  `collectionView(_:canMoveItemAt:)`: whether an item can be dragged, while reordering (`allowsReordering`) or
  editing (an editable section), and never the "+ New tag" item.

- `fun moveItemAtIndexPath(sourceIndexPath: CYLIndexPath, toIndexPath: CYLIndexPath) = moveItem(sourceIndexPath, toIndexPath)` (L1482)
  `collectionView(_:moveItemAt:to:)`: moves an item as a drag does (the data source moves it, the delegate is told,
  the list saves its editable sections when it has a cache).

- `var longPressAction: CYLTagLongPressAction` (L1500)
  What a long press on an item does: `CYLTagLongPressActions.first(reorder, report)` by default (reordering where the
  list can reorder, else the long press is reported). Set another built-in action, a combination or your own.

- `internal val calloutText: String? get() = (calloutPopup?.contentView as? CYLTagCalloutBubble)?.text?.toString()` (L1574)
  The text of the callout that shows now, or null (for tests).

- `override fun onVisibilityChanged(changedView: View, visibility: Int)` (L1588)
  Hidden (this view or an ancestor, as a hidden fragment's view): the callout of a list nobody sees goes away.

- `override fun onWindowVisibilityChanged(visibility: Int)` (L1594)
  The window is hidden (another activity, the app in the background): the callout goes away.

- `fun setTagsWithCharactersOfText(text: String)` (L1698)
  `-setTagsWithCharactersOfText:`: one tag per character of `text`, in order: each grapheme (a letter, a Chinese
  character, an emoji, a space) is one tag, as the word picker's cells (`CYLMenuStyle.wordPicker()`). Unlike the
  first `setTagsWithTitles`, it keeps `selectionMode` (a word picker selects several cells).

- `val selectedText: String` (L1705)
  `selectedText`: the titles of the selected items joined in item order (a word picker's picked characters).

- `fun selectItemsFromIndexPath(start: CYLIndexPath, throughIndexPath: CYLIndexPath)` (L1713)
  `-selectItemsFromIndexPath:throughIndexPath:`: selects every selectable item from `start` through `end` (either
  order), in item order across sections, as a smear over them does, without calling the delegate. Needs multiple
  selection.

- `var allowsSmearSelection: Boolean = false` (L1728)
  `allowsSmearSelection`: a finger dragged across the items selects them ("smearing", as WeChat's 涂抹选择填入词): the
  drag starts on the item it touched down on and selects every item from it to the item under the finger, in item
  order, or deselects them when that item was already selected. A tap still toggles one item, so TalkBack and Switch
  Access select the same items. Needs multiple selection; a drag that starts between items scrolls. The delegate
  gets `menuDidChangeSelectedItems`. False by default; `CYLMenuStyle.wordPicker()` is the matching look.

- `fun removeTagsAtIndexes(indexes: Collection<Int>)` (L1785)
  `-removeTagsAtIndexes:`.

- `var selectedIndexPaths: List<CYLIndexPath>` (L1815)
  The selected items, sorted; setting an invalid one throws, as on iOS.

- `fun scrollToSection(section: Int, animated: Boolean)` (L1965)
  `-scrollToSection:animated:`.

- `fun scrollToItemAtIndexPath(indexPath: CYLIndexPath, animated: Boolean)` (L1971)
  `-scrollToItemAtIndexPath:animated:`: centers a visible item.

- `fun beginDrag(indexPath: CYLIndexPath)` (L2054)
  Reordering picks the item up: the cell grows and follows the finger (the long-press action `reorder`).

- `fun cancelDrag()` (L2069)
  Puts a cell that was picked up back without moving anything.

- `fun headerViewAt(section: Int): View? = headers[section]` (L2076)
  The section's header view, or null (no title row, or the section is not built).

- `val sectionFrames = ArrayList<CYLTagListSectionFrame>()` (L2091)
  The card, header band and divider of each section, from the last `computeFrames`.

- `fun applyBackdropSource()` (L2130)
  Forwards `backdropSource` to the glass hosts already shown: the tags, the fold controls and the section boards.

- `fun invalidateGlassHosts()` (L2140)
  Invalidates the glass layer of every host shown (see `resampleGlassWhenMoved`): the tags, fold controls and boards.

- `fun indexPathAtRaw(rawX: Float, rawY: Float): CYLIndexPath?` (L2365)
  The selectable tag under the screen point (`rawX`, `rawY`), for a smear; null between tags.

- `override fun onDetachedFromWindow()` (L2380)
  A drag or smear in progress ends, reporting it, when the list leaves the window (as iOS `didMoveToWindow`).

- `val clearButton = ImageButton(context).apply` (L2442)
  The section's clear button (`menuShowsClearButtonForSection`, the core's trash icon): a square as tall as a
  line of the title at the trailing inset, its top and bottom the title text's, tapped in a 44 dp area.

- `internal fun CYLTagButton.cylApplyListAnimationSpeed(speed: Float?)` (L2638)
  The list's `animationSpeed`: a speed sets the tag's own, null lets it follow its style again.

