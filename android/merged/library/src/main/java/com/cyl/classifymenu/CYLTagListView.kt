package com.cyl.classifymenu

import android.annotation.SuppressLint
import android.content.Context
import android.graphics.drawable.Drawable
import android.graphics.drawable.GradientDrawable
import android.net.Uri
import android.util.AttributeSet
import android.view.GestureDetector
import android.view.MotionEvent
import android.view.View
import android.view.ViewGroup
import com.cyl.animateditem.CYLAnimatedItemBackgroundStyle
import com.cyl.animateditem.CYLAnimatedItemView
import android.view.accessibility.AccessibilityEvent
import android.widget.ImageButton
import android.widget.ImageView
import android.widget.ScrollView
import android.widget.TextView
import androidx.core.view.ViewCompat
import kotlin.math.ceil
import kotlin.math.floor
import kotlin.math.hypot
import kotlin.math.max
import kotlin.math.min
import kotlin.math.roundToInt

/** `CYLMenuSelectionMode`. */
enum class CYLMenuSelectionMode { CYLMenuSelectionModeNone, CYLMenuSelectionModeSingle, CYLMenuSelectionModeMultiple }

/** `CYLMenuTitlePosition`: where the list's title sits. */
enum class CYLMenuTitlePosition { CYLMenuTitlePositionTopLeading, CYLMenuTitlePositionTopCenter }

/** `CYLMenuFoldStyle`: the older form of `CYLMenuFoldControl`, and truncation (AndroidTagView's max lines). */
enum class CYLMenuFoldStyle { CYLMenuFoldStyleNone, CYLMenuFoldStyleHeaderButton, CYLMenuFoldStyleFooterChevron, CYLMenuFoldStyleTruncate }

private const val MORE_BUTTON_SIZE = 44f
private const val FOOTER_HEIGHT = 28f
private const val HEADER_ICON_SIZE = 16f

/** The gap between a header's indicator bar / icon / clear button and what follows, dp. */
private const val HEADER_GAP = 8f

/** The overhang of a header's fold control beyond the header's edge in the plain style (its glyph padding), dp. */
private const val HEADER_FOLD_OVERHANG = 6f

/** The gap between a header's fold control and the next control or the title, dp. */
private const val HEADER_FOLD_GAP = 8f

/** The most of the header's width a title-and-icon fold control takes (the section title truncates in the rest). */
private const val HEADER_FOLD_TITLE_AND_ICON_MAX_FRACTION = 0.4f

/** The gap after a header's More button, dp. */
private const val HEADER_MORE_GAP = 4f

/** The title's top and bottom padding in a header: a header is at least a title line plus this, dp. */
private const val HEADER_TITLE_VERTICAL_PADDING = 12f
private const val TITLE_VERTICAL_INSET = 10f

/**
 * `CYLTagListView`: a list of tags in sections (a `CYLMenuDataSource`) or of `CYLTag`s (`addTag…`, android-tagview's
 * TagView and AndroidTagView's TagContainerLayout): flowing rows, section headers with an icon, an accessory view and a
 * More button, folding (a fold control in the header, the footer or inline, or truncation), single / multiple /
 * exclusive selection, deletion, long press and reordering, a title, and the content height for its container.
 * Lengths are dp.
 */
@SuppressLint("ClickableViewAccessibility")
open class CYLTagListView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null,
) : ViewGroup(context, attrs), CYLTagLongPressHost {

    private val density: Float get() = resources.displayMetrics.density
    private fun px(dp: Float): Int = (dp * density).roundToInt()
    private val container = GradientDrawable()

    private val scrollView = object : ScrollView(context) {
        override fun onInterceptTouchEvent(ev: MotionEvent): Boolean = scrollEnabledFlag && !reordering && super.onInterceptTouchEvent(ev)
        override fun onTouchEvent(ev: MotionEvent): Boolean = if (scrollEnabledFlag && !reordering) super.onTouchEvent(ev) else false
    }.apply {
        isVerticalScrollBarEnabled = true
        overScrollMode = OVER_SCROLL_NEVER
        isFillViewport = true
    }
    private val content = ContentView(context)
    private var scrollEnabledFlag = true

    /** The title of the list (`titleView`), hidden when there is neither title nor title image. */
    val titleView: CYLTagButton = CYLTagButton(context).apply {
        isClickable = false
        isFocusable = false
        visibility = GONE
        cyl_accessibilityIdentifier = CYLTagListTitleAccessibilityIdentifier
        ViewCompat.setAccessibilityHeading(this, true)
    }

    /** The label of `titleView`. */
    val titleLabel: TextView get() = titleView.titleLabel

    private var titles: List<List<String>> = emptyList()
    private var itemWidths: List<List<Float>> = emptyList()
    private var itemHeights: List<List<Float>> = emptyList()
    private var rows: List<List<Int>> = emptyList()
    private var selection = LinkedHashSet<CYLIndexPath>()
    private val expandedSections = HashSet<Int>()
    private var measuredContentWidth = -1f
    private val themeStyles = HashMap<CYLIndexPath, Pair<CYLMenuStyle, CYLMenuStyle>>()
    private var createItemStyle: CYLMenuStyle? = null
    private var createItemBaseStyle: CYLMenuStyle? = null
    private var _tagDataSource: CYLTagDataSource? = null

    init {
        background = container
        clipToOutline = false
        scrollView.addView(content)
        addView(scrollView)
        addView(titleView)
        applyStyleColors()
        // A scroll hides the callout.
        scrollView.viewTreeObserver.addOnScrollChangedListener { dismissCallout() }
    }

    override fun onDetachedFromWindow() {
        dismissCallout()
        super.onDetachedFromWindow()
    }

    // MARK: Initializers (iOS)

    /** `-initWithFoldControl:title:titleImage:titlePosition:`. */
    constructor(context: Context, foldControl: CYLMenuFoldControl?, title: String?, titleImage: Drawable?, titlePosition: CYLMenuTitlePosition) : this(context) {
        this.foldControl = foldControl
        this.titlePosition = titlePosition
        this.titleImage = titleImage
        this.title = title
    }

    /** `-initWithFoldControl:title:titlePosition:`. */
    constructor(context: Context, foldControl: CYLMenuFoldControl?, title: String?, titlePosition: CYLMenuTitlePosition) :
        this(context, foldControl, title, null, titlePosition)

    /** `-initWithFoldControl:`. */
    constructor(context: Context, foldControl: CYLMenuFoldControl?) :
        this(context, foldControl, null, null, CYLMenuTitlePosition.CYLMenuTitlePositionTopLeading)

    companion object {
        /** `+tagListViewWithFoldPosition:content:`. */
        @JvmStatic
        fun tagListViewWithFoldPosition(context: Context, position: CYLMenuFoldControlPosition, content: CYLMenuFoldControlContent) =
            CYLTagListView(context, CYLMenuFoldControl.foldControlWithPosition(position, content))

        /** `+defaultTitleStyle`: a 17 sp headline in the label color, no box. */
        @JvmStatic
        fun defaultTitleStyle(): CYLMenuStyle {
            val style = CYLMenuStyle.defaultStyle().also { it.sectionStyle = CYLSectionStyle.CYLSectionStylePlain }
            val font = CYLFont.boldSystemFont(17f)
            for (state in listOf(CYLControlState.NORMAL, CYLControlState.SELECTED, CYLControlState.DISABLED)) {
                val appearance = style.appearanceForState(state)
                appearance.backgroundColor = CYLColor.CLEAR
                appearance.borderWidth = 0f
                appearance.borderColor = null
                appearance.margin = 0f
                appearance.font = font
                appearance.textColor = android.graphics.Color.BLACK
                style.setIconColor(android.graphics.Color.BLACK, state)
            }
            style.imageSize = CYLSize(18f, 18f)
            style.imageTitleSpacing = 6f
            style.layoutCentered = true
            style.adjustsFontForContentSizeCategory = true
            style.itemHeight = 24f
            return style
        }
    }

    // MARK: Properties

    var menuDataSource: CYLMenuDataSource? = null
        set(value) {
            field = value
        }

    var menuDelegate: CYLMenuDelegate? = null

    /** The list's style (a copy); null resets it (null_resettable). */
    var style: CYLMenuStyle? = CYLMenuStyle.defaultStyle()
        get() = field ?: CYLMenuStyle.defaultStyle()
        set(value) {
            field = (value ?: CYLMenuStyle.defaultStyle()).copy()
            _tagDataSource?.baseStyle = field
            applyStyleColors()
            invalidateMeasurements()
        }
    private val listStyle: CYLMenuStyle get() = style!!

    var selectionMode: CYLMenuSelectionMode = CYLMenuSelectionMode.CYLMenuSelectionModeSingle
        set(value) {
            field = value
            if (value == CYLMenuSelectionMode.CYLMenuSelectionModeNone) {
                selection.clear()
            } else if (value == CYLMenuSelectionMode.CYLMenuSelectionModeSingle) {
                val seen = HashSet<Int>()
                for (indexPath in selectedIndexPaths) {
                    if (!seen.add(indexPath.section)) selection.remove(indexPath)
                }
            }
            refreshVisibleCells()
        }

    var allowsEmptySelection: Boolean = true

    var showsSectionHeaders: Boolean = true
        set(value) {
            field = value
            reloadLayout()
        }

    private var _foldControl: CYLMenuFoldControl = CYLMenuFoldControl.noFoldControl()
    private var _foldStyle: CYLMenuFoldStyle = CYLMenuFoldStyle.CYLMenuFoldStyleNone

    /** The fold control (a copy); null resets it to no control (null_resettable). */
    var foldControl: CYLMenuFoldControl?
        get() = _foldControl
        set(value) {
            _foldControl = (value ?: CYLMenuFoldControl.noFoldControl()).copy()
            _foldStyle = when (_foldControl.position) {
                CYLMenuFoldControlPosition.FOOTER -> CYLMenuFoldStyle.CYLMenuFoldStyleFooterChevron
                CYLMenuFoldControlPosition.HEADER_TRAILING,
                CYLMenuFoldControlPosition.HEADER_LEADING -> CYLMenuFoldStyle.CYLMenuFoldStyleHeaderButton
                CYLMenuFoldControlPosition.NONE ->
                    if (_foldStyle == CYLMenuFoldStyle.CYLMenuFoldStyleTruncate) _foldStyle else CYLMenuFoldStyle.CYLMenuFoldStyleNone
                CYLMenuFoldControlPosition.TAIL -> CYLMenuFoldStyle.CYLMenuFoldStyleNone
            }
            reloadLayout()
        }

    var foldStyle: CYLMenuFoldStyle
        get() = _foldStyle
        set(value) {
            _foldStyle = value
            _foldControl = when (value) {
                CYLMenuFoldStyle.CYLMenuFoldStyleHeaderButton -> CYLMenuFoldControl.foldControlWithPosition(
                    CYLMenuFoldControlPosition.HEADER_TRAILING, CYLMenuFoldControlContent.CYLMenuFoldControlContentTitle)
                CYLMenuFoldStyle.CYLMenuFoldStyleFooterChevron -> CYLMenuFoldControl.foldControlWithPosition(
                    CYLMenuFoldControlPosition.FOOTER, CYLMenuFoldControlContent.CYLMenuFoldControlContentIcon)
                else -> CYLMenuFoldControl.noFoldControl()
            }
            reloadLayout()
        }

    var title: String? = null
        set(value) {
            field = value
            titleView.title = value
            titleDidChange()
        }

    var titleImage: Drawable? = null
        set(value) {
            field = value
            titleView.image = value
            titleDidChange()
        }

    var titlePosition: CYLMenuTitlePosition = CYLMenuTitlePosition.CYLMenuTitlePositionTopLeading
        set(value) {
            field = value
            requestLayout()
        }

    /** The title's style (a copy); null resets it to `defaultTitleStyle()` (null_resettable). */
    var titleStyle: CYLMenuStyle? = defaultTitleStyle()
        get() = field ?: defaultTitleStyle()
        set(value) {
            field = (value ?: defaultTitleStyle()).copy()
            titleView.style = field
            titleDidChange()
        }

    init {
        titleView.style = titleStyle
    }

    /** Rows a folded section shows (1 by default). */
    var defaultVisibleRows: Int = 1
        set(value) {
            field = value
            reloadLayout()
        }

    /** Whether the list scrolls (off inside another scrolling container: it then reports its height). */
    var isScrollEnabled: Boolean
        get() = scrollEnabledFlag
        set(value) {
            scrollEnabledFlag = value
            if (!value) scrollView.scrollTo(0, 0)
        }

    /** The height of all sections and the title for the current width, dp. */
    var contentHeight: Float = 0f
        private set

    /** The list background as drawn: the style's, or the grouped background under `insetGrouped`, in the current mode. */
    internal var backgroundColorInUse: Int = 0
        private set

    private fun applyStyleColors() {
        backgroundColorInUse = listStyle.resolvedBackgroundColor(context)
        container.setColor(backgroundColorInUse)
        content.layout.rowAlignment = listStyle.rowAlignment.ordinal
        themeStyles.clear()
        content.invalidate()
    }

    private fun hasTitle(): Boolean = !title.isNullOrEmpty() || titleImage != null

    private fun titleDidChange() {
        titleView.visibility = if (hasTitle()) VISIBLE else GONE
        val label = if (!title.isNullOrEmpty()) title else (titleImage as? CYLBadgeDrawable)?.accessibilityLabel
        titleView.contentDescription = label
        titleView.importantForAccessibility = if (label.isNullOrEmpty()) IMPORTANT_FOR_ACCESSIBILITY_NO else IMPORTANT_FOR_ACCESSIBILITY_YES
        requestLayout()
        updateContentHeight()
    }

    private fun titleHeight(): Float = if (!hasTitle()) 0f else ceil(CYLTagButton.heightForStyle(titleStyle!!)) + 2 * TITLE_VERTICAL_INSET

    private fun titleFrame(width: Float, height: Float): CYLRect {
        val inset = listStyle.sectionInsets.left
        val available = max(0f, width - 2 * inset)
        val contentWidth = min(available, ceil(CYLTagButton.widthForTitle(title, titleImage, titleStyle!!)))
        val rightToLeft = layoutDirection == LAYOUT_DIRECTION_RTL
        val x = if (titlePosition == CYLMenuTitlePosition.CYLMenuTitlePositionTopCenter) floor((width - contentWidth) / 2)
        else if (rightToLeft) width - inset - contentWidth else inset
        return CYLRect(x, TITLE_VERTICAL_INSET, contentWidth, height - 2 * TITLE_VERTICAL_INSET)
    }

    // MARK: Editing

    /**
     * `isEditing`: whether the list is in editing mode (`setEditing`). While editing, the items of the editable sections
     * (`menuSectionAllowsEditing`, every section by default) show the delete indicator and can be dragged to reorder; a
     * tap no longer selects an item but still calls `menuDidSelectItemAtIndexPath`, so the host can open the item;
     * folded sections show every item; and `addItemView` appears below the last section. False by default.
     */
    var isEditing: Boolean = false
        private set

    /** `showsAddItemViewWhileEditing`: shows `addItemView` below the last section while editing. True by default. */
    var showsAddItemViewWhileEditing: Boolean = true
        set(value) {
            field = value
            if (isEditing) invalidateMeasurements()
        }

    /**
     * `addItemView`: the "add tag" control shown while editing, a text field and an Add button. A submitted name is
     * reported through `menuDidRequestNewItemWithName` with the index path after the last item of the first editable
     * section.
     */
    val addItemView: CYLTagListAddItemView by lazy {
        CYLTagListAddItemView(context).apply { submitHandler = { name -> requestNewItem(name) } }
    }

    /**
     * `cachePolicy`: where the list saves its editable sections after an edit (a drag, a delete or an added tag in
     * editing mode), so the order survives a relaunch: none (the default), a SQLite database, `SharedPreferences` or a
     * file. The host restores it when it builds its data (`cachedTitlesInSection`). Setting it makes `cache` the
     * built-in store of the policy and `cacheName`.
     */
    var cachePolicy: CYLTagListCachePolicy = CYLTagListCachePolicy.CYLTagListCachePolicyNone
        set(value) {
            field = value
            cache = CYLTagListStore.cacheWithPolicy(context, value, cacheName)
        }

    /** `cacheName`: separates the caches of different lists ("CYLTagListView" by default); set it before `cachePolicy`. */
    var cacheName: String = "CYLTagListView"
        set(value) {
            field = value
            cache = CYLTagListStore.cacheWithPolicy(context, cachePolicy, value)
        }

    /** `cache`: the store the list saves to, the built-in store of `cachePolicy` or one of yours; null: no cache. */
    var cache: CYLTagListCache? = null

    /** `remoteSource`: the server the sections are also kept on, for `loadSectionsWithKeys`; null: the cache only. */
    var remoteSource: CYLTagListRemoteSource? = null

    /**
     * `loadPolicy`: how `loadSectionsWithKeys` combines the cache and `remoteSource`; `CacheThenNetwork` (the cache at
     * once, then a refresh from the server) by default.
     */
    var loadPolicy: CYLTagListLoadPolicy = CYLTagListLoadPolicy.CYLTagListLoadPolicyCacheThenNetwork

    /**
     * `editingFinishHandler`: called when editing ends (`setEditing(false, …)`) with the edited sections by cache key,
     * after `menuDidFinishEditingWithTitles`: the place to upload them.
     */
    var editingFinishHandler: ((Map<String, List<String>>) -> Unit)? = null

    /**
     * `-editableSectionTitles`: the titles of every editable section by cache key (`cacheKeyForSection`), without
     * "+ New tag" items: what the list saves and what `menuDidFinishEditingWithTitles` reports.
     */
    fun editableSectionTitles(): Map<String, List<String>> {
        val source = menuDataSource ?: return emptyMap()
        val result = LinkedHashMap<String, List<String>>()
        for (section in 0 until source.numberOfSectionsInMenu()) {
            if (!sectionAllowsEditing(section)) continue
            result[cacheKeyForSection(section)] = (0 until source.menuNumberOfItemsInSection(section)).mapNotNull { item ->
                val indexPath = CYLIndexPath(item, section)
                if (source.menuItemTypeAtIndexPath(indexPath) == CYLMenuItemType.CYLMenuItemTypeCreate) null
                else source.menuTitleForItemAtIndexPath(indexPath)
            }
        }
        return result
    }

    /**
     * `-loadSectionsWithKeys:completion:`: reads the sections saved under `keys` from the cache and `remoteSource`, in
     * the order of `loadPolicy`, and calls `completion` on the main thread with the titles by key and where they come
     * from: once or twice (`CacheThenNetwork`: the cache at once, then the server). Downloaded sections are saved to
     * the cache first. Without a remote source it reads the cache only; nothing saved anywhere calls nothing.
     */
    fun loadSectionsWithKeys(keys: List<String>, completion: (Map<String, List<String>>, CYLTagListDataOrigin) -> Unit) {
        val cached = LinkedHashMap<String, List<String>>()
        for (key in keys) cache?.cachedTitlesForSection(key)?.let { cached[key] = it }
        val main = android.os.Handler(android.os.Looper.getMainLooper())
        fun fetch(done: (Boolean) -> Unit) {
            val remote = remoteSource ?: return done(false)
            remote.fetchSectionsWithKeys(keys) { sections, error ->
                main.post {
                    if (sections == null || error != null) {
                        done(false)
                        return@post
                    }
                    val downloaded = sections.filterKeys { it in keys }
                    for ((key, titles) in downloaded) cache?.saveTitles(titles, key)
                    completion(downloaded, CYLTagListDataOrigin.CYLTagListDataOriginNetwork)
                    done(true)
                }
            }
        }
        when (loadPolicy) {
            CYLTagListLoadPolicy.CYLTagListLoadPolicyCacheThenNetwork -> {
                if (cached.isNotEmpty()) completion(cached, CYLTagListDataOrigin.CYLTagListDataOriginCache)
                fetch { }
            }
            CYLTagListLoadPolicy.CYLTagListLoadPolicyCacheFirst ->
                if (cached.size == keys.size) completion(cached, CYLTagListDataOrigin.CYLTagListDataOriginCache)
                else fetch { ok -> if (!ok && cached.isNotEmpty()) completion(cached, CYLTagListDataOrigin.CYLTagListDataOriginCache) }
            CYLTagListLoadPolicy.CYLTagListLoadPolicyNetworkFirst ->
                fetch { ok -> if (!ok && cached.isNotEmpty()) completion(cached, CYLTagListDataOrigin.CYLTagListDataOriginCache) }
        }
    }

    /** `-cachedTitlesInSection:`: the titles saved for `section`, in order; null when nothing was saved or no cache. */
    fun cachedTitlesInSection(section: Int): List<String>? = cache?.cachedTitlesForSection(cacheKeyForSection(section))

    /** `-cacheKeyForSection:`: the data source's `menuCacheKeyForSection`, else the section's index. */
    fun cacheKeyForSection(section: Int): String = menuDataSource?.menuCacheKeyForSection(section) ?: section.toString()

    /** `-saveEditableSectionsToCache`: saves the current titles of every editable section to `cache` (after each edit). */
    fun saveEditableSectionsToCache() {
        val cache = cache ?: return
        if (cache.supportsItems()) {
            // With identifiers, so a renamed item stays the same item.
            for ((key, items) in editableSectionItems()) cache.saveItems(items, key)
            return
        }
        for ((key, titles) in editableSectionTitles()) cache.saveTitles(titles, key)
    }

    /**
     * `-setEditing:animated:`: enters or leaves editing mode; the delete indicators, reordering, the selection rules,
     * folding and `addItemView` change together; then `menuDidChangeEditing` is called. The list itself does not move
     * or open anything.
     */
    fun setEditing(editing: Boolean, animated: Boolean) {
        if (editing == isEditing) return
        isEditing = editing
        if (!editing) {
            addItemView.textField.clearFocus()
            (context.getSystemService(Context.INPUT_METHOD_SERVICE) as? android.view.inputmethod.InputMethodManager)
                ?.hideSoftInputFromWindow(addItemView.textField.windowToken, 0)
            renamingIndexPath = null
            addItemView.endRenaming()
            // The edited sections, for the host to upload (the cache already has them).
            val titles = editableSectionTitles()
            menuDelegate?.menuDidFinishEditingWithTitles(this, titles)
            menuDelegate?.menuDidFinishEditingWithItems(this, editableSectionItems())
            editingFinishHandler?.invoke(titles)
        }
        invalidateMeasurements()
        if (animated && isAttachedToWindow) {
            content.alpha = 0f
            content.animate().alpha(1f).setDuration(250).start()
        }
        menuDelegate?.menuDidChangeEditing(this, editing)
    }

    /** `-sectionAllowsEditing:`: the data source's `menuSectionAllowsEditing`, else true. */
    fun sectionAllowsEditing(section: Int): Boolean = menuDataSource?.menuSectionAllowsEditing(section) ?: true

    // MARK: Renaming (iOS 990cf115)

    /** `renamingIndexPath`: the item being renamed in editing mode (its rename indicator was tapped); null otherwise. */
    var renamingIndexPath: CYLIndexPath? = null
        private set

    /**
     * `renamesOnTitleTapWhileEditing`: in editing mode, a tap on a renamable item's title (outside its pencil and cross)
     * renames it too; a tap elsewhere still calls `menuDidSelectItemAtIndexPath`. True by default; it needs the data
     * source's `menuRenameItemAtIndexPath`.
     */
    var renamesOnTitleTapWhileEditing: Boolean = true
        set(value) {
            field = value
            refreshVisibleCells()
        }

    /**
     * `renameRequestHandler`: your own editor for renaming: when set, a pencil or title tap calls it with the item and its
     * title instead of filling `addItemView`; finish with `finishRenamingToTitle` or `cancelRenaming`. null (the
     * default): `addItemView` is the rename field.
     */
    var renameRequestHandler: ((CYLIndexPath, String) -> Unit)? = null

    /**
     * `clearButtonHandler`: called with the section when its header's clear button (`menuShowsClearButtonForSection`)
     * is tapped, after `menuDidTapClearButtonInSection`.
     */
    var clearButtonHandler: ((Int) -> Unit)? = null

    /**
     * `-editableSectionItems`: the items (identifier from `menuIdentifierForItemAtIndexPath`, else the title; and title)
     * of every editable section, by cache key, without "+ New tag" items.
     */
    fun editableSectionItems(): Map<String, List<CYLTagListCacheItem>> {
        val source = menuDataSource ?: return emptyMap()
        val result = LinkedHashMap<String, List<CYLTagListCacheItem>>()
        for (section in 0 until source.numberOfSectionsInMenu()) {
            if (!sectionAllowsEditing(section)) continue
            result[cacheKeyForSection(section)] = (0 until source.menuNumberOfItemsInSection(section)).mapNotNull { item ->
                val indexPath = CYLIndexPath(item, section)
                if (source.menuItemTypeAtIndexPath(indexPath) == CYLMenuItemType.CYLMenuItemTypeCreate) return@mapNotNull null
                val title = source.menuTitleForItemAtIndexPath(indexPath)
                CYLTagListCacheItem(source.menuIdentifierForItemAtIndexPath(indexPath) ?: title, title)
            }
        }
        return result
    }

    /** Whether the item can be renamed now: editing, an editable section, deletable, and a data source that renames. */
    private fun isRenamableAt(indexPath: CYLIndexPath): Boolean =
        isEditing && sectionAllowsEditing(indexPath.section) && itemTypeAt(indexPath) != CYLMenuItemType.CYLMenuItemTypeCreate &&
            isDeletableAt(indexPath) && menuDataSource?.supportsRenamingItems() == true

    /**
     * `-beginRenamingItemAtIndexPath:`: starts renaming (the rename indicator does this): `addItemView` shows the title
     * with the keyboard up; its submit renames the item through the data source's `menuRenameItemAtIndexPath`.
     */
    fun beginRenamingItemAtIndexPath(indexPath: CYLIndexPath) {
        if (!isValid(indexPath) || !isRenamableAt(indexPath)) return
        renamingIndexPath = indexPath
        val title = menuDataSource?.menuTitleForItemAtIndexPath(indexPath).orEmpty()
        renameRequestHandler?.let {
            // The host's editor takes it.
            it(indexPath, title)
            return
        }
        invalidateMeasurements()
        addItemView.beginRenamingWithTitle(title)
        // The field is below the last section: bring it into view.
        post { scrollView.smoothScrollTo(0, max(0, addItemView.bottom - scrollView.height)) }
    }

    /** `-cancelRenaming`: ends renaming without a change. */
    fun cancelRenaming() {
        if (renamingIndexPath == null) return
        renamingIndexPath = null
        addItemView.endRenaming()
        invalidateMeasurements()
    }

    /**
     * `-submitNewItemNamed:`: adds an item named `name` from your own editor, as `addItemView`'s submit does: reported
     * through `menuDidRequestNewItemWithName` at the end of the first editable section, then the cache is saved.
     */
    fun submitNewItemNamed(name: String) {
        val trimmed = name.trim()
        if (trimmed.isEmpty()) return
        cancelRenaming()
        requestNewItem(trimmed)
    }

    /**
     * `-finishRenamingToTitle:`: renames the item being renamed to `title` (trimmed; an empty or unchanged one only ends
     * renaming): the data source renames it, the list reloads, saves its cache and calls `menuDidRenameItemAtIndexPath`.
     */
    fun finishRenamingToTitle(title: String) {
        val indexPath = renamingIndexPath ?: return
        renamingIndexPath = null
        addItemView.endRenaming()
        val name = title.trim()
        if (!isValid(indexPath) || name.isEmpty() || name == menuDataSource?.menuTitleForItemAtIndexPath(indexPath)) {
            invalidateMeasurements()
            return
        }
        menuDataSource?.menuRenameItemAtIndexPath(indexPath, name)
        reloadMenuData()
        saveEditableSectionsToCache()
        menuDelegate?.menuDidRenameItemAtIndexPath(this, indexPath, name)
    }

    /**
     * `-loadItemsWithKeys:completion:`: `loadSectionsWithKeys` with identifiers: the cache's items
     * (`cachedItemsForSection`) and the remote source's (`fetchItemsWithKeys`, by default its titles, each its own
     * identifier), in the order of `loadPolicy`; downloaded items are saved to the cache first.
     */
    fun loadItemsWithKeys(keys: List<String>, completion: (Map<String, List<CYLTagListCacheItem>>, CYLTagListDataOrigin) -> Unit) {
        val cached = LinkedHashMap<String, List<CYLTagListCacheItem>>()
        for (key in keys) {
            val items = cache?.cachedItemsForSection(key) ?: cache?.cachedTitlesForSection(key)?.map { CYLTagListCacheItem(it, it) }
            if (items != null) cached[key] = items
        }
        val main = android.os.Handler(android.os.Looper.getMainLooper())
        fun fetch(done: (Boolean) -> Unit) {
            val remote = remoteSource ?: return done(false)
            remote.fetchItemsWithKeys(keys) { items, error ->
                main.post {
                    if (items == null || error != null) {
                        done(false)
                        return@post
                    }
                    val downloaded = items.filterKeys { it in keys }
                    for ((key, sectionItems) in downloaded) {
                        val store = cache
                        if (store != null && store.supportsItems()) store.saveItems(sectionItems, key)
                        else store?.saveTitles(sectionItems.map { it.title }, key)
                    }
                    completion(downloaded, CYLTagListDataOrigin.CYLTagListDataOriginNetwork)
                    done(true)
                }
            }
        }
        val fallBack: (Boolean) -> Unit = { ok -> if (!ok && cached.isNotEmpty()) completion(cached, CYLTagListDataOrigin.CYLTagListDataOriginCache) }
        when (loadPolicy) {
            CYLTagListLoadPolicy.CYLTagListLoadPolicyCacheThenNetwork -> {
                if (cached.isNotEmpty()) completion(cached, CYLTagListDataOrigin.CYLTagListDataOriginCache)
                fetch { }
            }
            CYLTagListLoadPolicy.CYLTagListLoadPolicyCacheFirst ->
                if (cached.size == keys.size) completion(cached, CYLTagListDataOrigin.CYLTagListDataOriginCache) else fetch(fallBack)
            CYLTagListLoadPolicy.CYLTagListLoadPolicyNetworkFirst -> fetch(fallBack)
        }
    }

    /** Whether `addItemView` is shown (editing, and `showsAddItemViewWhileEditing`). */
    private fun showsAddItemView(): Boolean =
        isEditing && (showsAddItemViewWhileEditing || (renamingIndexPath != null && renameRequestHandler == null))

    /** The height `addItemView` takes below the sections, dp (with the bottom section inset), or 0. */
    private fun addItemViewHeight(): Float =
        if (showsAddItemView()) addItemView.preferredHeight / density + listStyle.sectionInsets.bottom else 0f

    /** A name submitted in `addItemView`: reported at the end of the first editable section. */
    private fun requestNewItem(name: String) {
        if (renamingIndexPath != null) {
            finishRenamingToTitle(name)
            return
        }
        val section = titles.indices.firstOrNull { sectionAllowsEditing(it) } ?: 0
        val item = titles.getOrNull(section)?.size ?: 0
        menuDelegate?.menuDidRequestNewItemWithName(this, name, CYLIndexPath(item, section))
        saveEditableSectionsToCache()
    }

    // MARK: Data

    /** `-reloadMenuData`: reads the data source again and lays the list out. */
    fun reloadMenuData() {
        dismissCallout()
        val source = menuDataSource
        if (source != null && source === _tagDataSource) _tagDataSource?.invalidateStyles()
        val sections = source?.numberOfSectionsInMenu() ?: 0
        titles = (0 until sections).map { section ->
            (0 until source!!.menuNumberOfItemsInSection(section)).map { item ->
                val indexPath = CYLIndexPath(item, section)
                val title = source.menuTitleForItemAtIndexPath(indexPath)
                if (itemTypeAt(indexPath) == CYLMenuItemType.CYLMenuItemTypeCreate) CYLTagCreateCell.titleForName(title) else title
            }
        }
        selection.removeAll { !isValid(it) }
        expandedSections.removeAll { it >= sections }
        invalidateMeasurements()
    }

    private fun isValid(indexPath: CYLIndexPath): Boolean =
        indexPath.section in titles.indices && indexPath.item in titles[indexPath.section].indices

    private fun isEnabledAt(indexPath: CYLIndexPath): Boolean = menuDataSource?.menuItemIsEnabledAtIndexPath(indexPath) ?: true

    private fun isDeletableAt(indexPath: CYLIndexPath): Boolean {
        if (itemTypeAt(indexPath) == CYLMenuItemType.CYLMenuItemTypeCreate) return false
        val source = menuDataSource
        if (isEditing && sectionAllowsEditing(indexPath.section)) {
            // Editing: every item of an editable section, unless the data source decides.
            return source == null || !source.decidesDeletableItems() || source.menuItemIsDeletableAtIndexPath(indexPath)
        }
        return source?.menuItemIsDeletableAtIndexPath(indexPath) == true
    }

    private fun isExclusiveAt(indexPath: CYLIndexPath): Boolean = menuDataSource?.menuItemIsExclusiveAtIndexPath(indexPath) == true

    private fun imageAt(indexPath: CYLIndexPath): Drawable? {
        if (itemTypeAt(indexPath) == CYLMenuItemType.CYLMenuItemTypeCreate) return CYLTagCreateCell.plusImage()
        return menuDataSource?.menuImageForItemAtIndexPath(indexPath) ?: defaultTagImage
    }

    private fun itemTypeAt(indexPath: CYLIndexPath): CYLMenuItemType =
        menuDataSource?.menuItemTypeAtIndexPath(indexPath) ?: CYLMenuItemType.CYLMenuItemTypeTag

    private fun animationURLAt(indexPath: CYLIndexPath): Uri? = menuDataSource?.menuAnimationURLForItemAtIndexPath(indexPath)

    private fun restingProgressAt(indexPath: CYLIndexPath): Float = menuDataSource?.menuAnimationRestingProgressForItemAtIndexPath(indexPath) ?: 0f

    private fun styleForItem(indexPath: CYLIndexPath): CYLMenuStyle {
        menuDataSource?.menuStyleForItemAtIndexPath(indexPath)?.let { return it }
        val sectionStyle = styleForSection(indexPath.section)
        if (itemTypeAt(indexPath) != CYLMenuItemType.CYLMenuItemTypeCreate) return themeStyle(indexPath, sectionStyle)
        if (createItemBaseStyle !== sectionStyle || createItemStyle == null) {
            createItemStyle = CYLTagCreateCell.styleWithStyle(sectionStyle)
            createItemBaseStyle = sectionStyle
        }
        return createItemStyle!!
    }

    private fun isSelectableAt(indexPath: CYLIndexPath): Boolean {
        // Editing: a tap reports the item (`menuDidSelectItemAtIndexPath`) without changing the selection.
        if (isEditing || itemTypeAt(indexPath) == CYLMenuItemType.CYLMenuItemTypeCreate) return false
        return menuDataSource?.menuItemIsSelectableAtIndexPath(indexPath) ?: true
    }

    private fun styleForSection(section: Int): CYLMenuStyle = menuDataSource?.menuStyleForSection(section) ?: listStyle

    private fun showsMoreButtonIn(section: Int): Boolean = menuDataSource?.menuShowsMoreButtonInSection(section) == true

    private fun selectedImageAt(indexPath: CYLIndexPath): Drawable? = menuDataSource?.menuSelectedImageForItemAtIndexPath(indexPath)

    // MARK: Measurement

    private fun itemHeight(): Float = CYLTagButton.heightForStyle(listStyle)

    private fun foldIsInHeader(): Boolean = _foldControl.position == CYLMenuFoldControlPosition.HEADER_TRAILING ||
        _foldControl.position == CYLMenuFoldControlPosition.HEADER_LEADING

    private fun foldIsInFooter(): Boolean = _foldControl.position == CYLMenuFoldControlPosition.FOOTER

    private fun foldIsInline(): Boolean = _foldControl.position == CYLMenuFoldControlPosition.TAIL

    private fun showsInlineFoldCell(section: Int): Boolean = foldIsInline() && canFoldSection(section)

    private fun displayedFoldControl(): CYLMenuFoldControl {
        var control = _foldControl
        val chevron = listStyle.foldChevronImage
        if (chevron != null && control.usesDefaultImage) {
            control = control.copy()
            control.image = chevron
        }
        return control
    }

    private fun inlineFoldSize(section: Int, expanded: Boolean): CYLSize =
        CYLTagFoldButton.inlineSizeForFoldControl(displayedFoldControl(), styleForSection(section), expanded)

    private fun foldSize(expanded: Boolean): CYLSize = CYLTagFoldButton.sizeForFoldControl(_foldControl, expanded)

    private fun footerHeight(): Float = max(FOOTER_HEIGHT, foldSize(false).height)

    /**
     * The header's height: `headerHeight`, at least a line of the title and the fold control. With `headerMaxLines` above 1 the
     * title of `section` is wrapped at the room it has at the list width `width` ([headerTitleWidth]) and the header grows to
     * the wrapped lines; `section` -1 (and the default one line) keeps the fixed height.
     */
    private fun headerHeight(section: Int = -1, width: Float = measuredContentWidth): Float {
        // Only a foldable section shows the header control, so only it reserves height (an unknown section -1 keeps the control's).
        val foldable = section !in rows.indices || canFoldRowCount(rows[section].size)
        val foldHeight = if (foldIsInHeader() && foldable) foldSize(false).height else 0f
        if (!showsSectionHeaders) return foldHeight
        val font = listStyle.headerFontForTraitCollection()
        var text = ceil(CYLTagButton.fontLineHeight(font))
        if (listStyle.headerMaxLines > CYLHeaderTitleMaxLines.SINGLE && section in titles.indices) {
            val title = menuDataSource?.menuTitleForSection(section).orEmpty()
            text = CYLTagButton.wrappedTextHeight(title, font, headerTitleWidth(section, width), listStyle.headerMaxLines)
        }
        return max(max(listStyle.headerHeight, text + HEADER_TITLE_VERTICAL_PADDING), foldHeight)
    }

    /**
     * The room a header's title has at the list width `width` dp: the width between the header's edges minus the indicator bar,
     * the icon, the fold control, the More and the clear buttons. The same subtractions as `HeaderView.onLayout`, rounded the
     * safe way (a little too much taken off), so a header never reserves fewer lines than its title needs. An accessory view
     * is not measured here.
     */
    private fun headerTitleWidth(section: Int, width: Float): Float {
        val style = listStyle
        val source = menuDataSource
        val (leading, trailing) = headerEdgeInsetsAt(width)
        var room = width - leading - trailing
        if (style.headerIndicatorColor != null) room -= style.headerIndicatorSize.width + HEADER_GAP
        if (source?.menuImageForSection(section) != null) room -= HEADER_ICON_SIZE + HEADER_GAP
        if (foldIsInHeader() && section in rows.indices && canFoldRowCount(rows[section].size)) {
            room -= headerFoldWidth(max(foldSize(false).width, foldSize(true).width), width) + HEADER_FOLD_GAP - headerFoldOverhang()
        }
        if (source?.menuShowsClearButtonForSection(section) == true) {
            room -= ceil(CYLTagButton.fontLineHeight(style.headerFontForTraitCollection())) + HEADER_GAP
        }
        if (showsMoreButtonIn(section)) room -= MORE_BUTTON_SIZE - floor((MORE_BUTTON_SIZE - 22f) / 2) + HEADER_MORE_GAP
        return max(0f, room)
    }

    /**
     * The overhang of a header's fold control beyond the header's edge: [HEADER_FOLD_OVERHANG] in the plain style, none under
     * `insetGrouped`, where the control's edge is the board's edge exactly.
     */
    private fun headerFoldOverhang(): Float = if (listStyle.isInsetGrouped) 0f else HEADER_FOLD_OVERHANG

    /** The width the header gives its fold control: `natural`, but at most 40% of the header `width` for the title-and-icon content. */
    private fun headerFoldWidth(natural: Float, width: Float): Float =
        if (_foldControl.content == CYLMenuFoldControlContent.CYLMenuFoldControlContentTitleAndIcon) min(natural, width * HEADER_FOLD_TITLE_AND_ICON_MAX_FRACTION) else min(natural, width / 2)

    /**
     * The section's column at the list width `width` dp: the list width minus `sectionInsets` (x and width; y and height are
     * 0). The card, the header band and the divider span it. The one place the column comes from.
     */
    private fun columnAt(width: Float): CYLRect {
        val insets = listStyle.sectionInsets
        return CYLRect(insets.left, 0f, max(0f, width - insets.left - insets.right), 0f)
    }

    /** The card's padding around the tags: `sectionContentInsets` under `insetGrouped`, else none. */
    private fun cardInsets(): CYLEdgeInsets = if (listStyle.isInsetGrouped) listStyle.sectionContentInsets else CYLEdgeInsets.ZERO

    /** The section's column at the current layout width (`sectionInsets` taken off the list width). */
    fun contentColumn(@Suppress("UNUSED_PARAMETER") section: Int): CYLRect = columnAt(max(0f, measuredContentWidth))

    /**
     * The column the tags are laid in: [contentColumn], narrowed by the card's padding under `insetGrouped`. Every tag width,
     * row count, fold decision, height and frame takes its width and x from here.
     */
    fun tagColumn(@Suppress("UNUSED_PARAMETER") section: Int): CYLRect = tagColumnAt(max(0f, measuredContentWidth))

    private fun tagColumnAt(width: Float): CYLRect {
        val column = columnAt(width)
        val card = cardInsets()
        return CYLRect(column.x + card.left, 0f, max(0f, column.width - card.left - card.right), 0f)
    }

    private fun contentWidthFor(width: Float): Float = tagColumnAt(width).width

    /**
     * The distances from the list's leading and trailing edges to a header's title and fold control: the board's own edges
     * (`insetGrouped`: the title starts where the card starts and a control ends where it ends, not at the tags inside it), the band's edges plus `headerContentInsets` (a plain header with a band), else
     * `headerHorizontalInset`.
     */
    private fun headerEdgeInsets(): Pair<Float, Float> = headerEdgeInsetsAt(max(0f, measuredContentWidth))

    private fun headerEdgeInsetsAt(width: Float): Pair<Float, Float> {
        val style = listStyle
        val column = columnAt(width)
        val rest = max(0f, width - column.x - column.width)
        if (style.isInsetGrouped) {
            return column.x to rest
        }
        if (style.headerBackgroundColor != null) return (column.x + style.headerContentInsets.left) to (rest + style.headerContentInsets.right)
        return style.headerHorizontalInset to style.headerHorizontalInset
    }

    /**
     * The card, header band and header divider of a section, and the distances of its header title (dp, in the content's
     * coordinates, below the title): null where the style draws none. The divider sits at the header's bottom edge inside
     * `headerHeight`: it adds no height.
     */
    internal data class CYLTagListSectionFrame(
        val section: Int,
        val top: Float,
        val height: Float,
        val headerHeight: Float,
        val card: CYLRect?,
        val headerBand: CYLRect?,
        val headerSeparator: CYLRect?,
        val headerInsetLeft: Float,
        val headerInsetRight: Float,
    )

    /** The frames of section `section` as the last layout pass computed them; null before the first one. */
    internal fun sectionFrame(section: Int): CYLTagListSectionFrame? = content.sectionFrames.getOrNull(section)

    private fun widthsFor(contentWidth: Float): List<List<Float>> = titles.mapIndexed { section, items ->
        items.mapIndexed { item, title ->
            val indexPath = CYLIndexPath(item, section)
            val itemStyle = styleForItem(indexPath)
            val iconSize = CYLTagButton.iconSizeForImage(imageAt(indexPath), animationURLAt(indexPath) != null, itemStyle)
            val deletable = isDeletableAt(indexPath)
            var width = CYLTagButton.widthForTitle(title, iconSize, deletable, deletable && isRenamableAt(indexPath), itemStyle)
            val perRow = styleForSection(section).numberOfItemsPerRow
            if (perRow > 0) width = gridItemWidth(contentWidth, perRow)
            min(width, contentWidth)
        }
    }

    private fun heightsForItems(widths: List<List<Float>> = itemWidths): List<List<Float>> {
        val listHeight = itemHeight()
        return titles.mapIndexed { section, items ->
            items.indices.map { item ->
                val indexPath = CYLIndexPath(item, section)
                val itemStyle = styleForItem(indexPath)
                val width = widths.getOrNull(section)?.getOrNull(item) ?: 0f
                if (itemStyle.titleMaxLines > CYLTagTitleMaxLines.SINGLE && width > 0f) {
                    // A title that may wrap grows the tag: measured at the width it gets.
                    val iconSize = CYLTagButton.iconSizeForImage(imageAt(indexPath), animationURLAt(indexPath) != null, itemStyle)
                    val deletable = isDeletableAt(indexPath)
                    max(listHeight, CYLTagButton.heightForTitleWidth(titles[section][item], iconSize, width, deletable, itemStyle))
                } else if (itemStyle === listStyle) listHeight else max(listHeight, CYLTagButton.heightForStyle(itemStyle))
            }
        }
    }

    private fun heightOfRows(rowCount: Int, sectionRows: List<Int>, heights: List<Float>): Float {
        var total = 0f
        var item = 0
        for (row in 0 until rowCount) {
            var rowHeight = itemHeight()
            if (row < sectionRows.size) {
                val count = sectionRows[row]
                for (index in item until min(item + count, heights.size)) rowHeight = max(rowHeight, heights[index])
                item += count
            }
            total += rowHeight
        }
        return total + if (rowCount > 0) (rowCount - 1) * listStyle.lineSpacing else 0f
    }

    private fun gridItemWidth(contentWidth: Float, itemsPerRow: Int): Float {
        val spacing = listStyle.interitemSpacing
        return max(1f, floor((contentWidth - spacing * (itemsPerRow - 1)) / itemsPerRow))
    }

    private fun rowsFor(widths: List<List<Float>>, contentWidth: Float): List<List<Int>> {
        val spacing = listStyle.interitemSpacing
        return widths.map { sectionWidths ->
            val sectionRows = ArrayList<Int>()
            var used = 0f
            var count = 0
            for (width in sectionWidths) {
                if (count > 0 && used + spacing + width > contentWidth) {
                    sectionRows.add(count)
                    used = 0f
                    count = 0
                }
                used += (if (count > 0) spacing else 0f) + width
                count++
            }
            if (count > 0) sectionRows.add(count)
            sectionRows
        }
    }

    private fun currentWidth(): Float = width / density

    private fun measureIfNeeded() {
        val width = currentWidth()
        if (width == measuredContentWidth) return
        measuredContentWidth = width
        val contentWidth = contentWidthFor(width)
        itemWidths = widthsFor(contentWidth)
        itemHeights = heightsForItems(itemWidths)
        rows = rowsFor(itemWidths, contentWidth)
    }

    private fun invalidateMeasurements() {
        measuredContentWidth = -1f
        reloadLayout()
    }

    private fun reloadLayout() {
        measureIfNeeded()
        content.rebuild()
        requestLayout()
        updateContentHeight()
    }

    /** `-heightThatFitsWidth:`: the height of the title and every section at `width` dp. */
    fun heightThatFitsWidth(width: Float): Float {
        val contentWidth = contentWidthFor(width)
        val same = width == measuredContentWidth
        val widths = if (same) itemWidths else widthsFor(contentWidth)
        val sectionRows = if (same) rows else rowsFor(widths, contentWidth)
        val heights = if (same) itemHeights else heightsForItems(widths)
        val insets = listStyle.sectionInsets
        val card = cardInsets()
        var height = 0f
        for (section in sectionRows.indices) {
            var rowCount = sectionRows[section].size
            val foldable = canFoldRowCount(rowCount)
            if (foldable && section !in expandedSections) {
                rowCount = defaultVisibleRows
            } else if (foldable && foldIsInline()) {
                val withFold = widths[section] + inlineFoldSize(section, true).width
                rowCount = rowsFor(listOf(withFold), contentWidth).first().size
            }
            height += headerHeight(section, width) + insets.top + insets.bottom + card.top + card.bottom
            height += heightOfRows(rowCount, sectionRows[section], heights.getOrElse(section) { emptyList() })
            if (foldable && foldIsInFooter()) height += footerHeight()
        }
        height += addItemViewHeight()
        return ceil(height) + titleHeight()
    }

    private fun updateContentHeight() {
        val height = if (width > 0) content.layoutHeight() + titleHeight() else heightThatFitsWidth(0f)
        if (kotlin.math.abs(height - contentHeight) < 0.5f) return
        contentHeight = height
        requestLayout()
        menuDelegate?.menuDidChangeContentHeight(this, height)
    }

    override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
        val width = MeasureSpec.getSize(widthMeasureSpec)
        val wanted = px(heightThatFitsWidth(width / density))
        setMeasuredDimension(width, resolveSize(wanted, heightMeasureSpec))
        val titleHeight = px(titleHeight())
        scrollView.measure(MeasureSpec.makeMeasureSpec(width, MeasureSpec.EXACTLY), MeasureSpec.makeMeasureSpec(max(0, measuredHeight - titleHeight), MeasureSpec.EXACTLY))
        titleView.measure(MeasureSpec.makeMeasureSpec(0, MeasureSpec.UNSPECIFIED), MeasureSpec.makeMeasureSpec(0, MeasureSpec.UNSPECIFIED))
    }

    override fun onLayout(changed: Boolean, l: Int, t: Int, r: Int, b: Int) {
        val width = (r - l) / density
        val titleHeight = titleHeight()
        if (titleHeight > 0) {
            val frame = titleFrame(width, titleHeight)
            titleView.layout(px(frame.x), px(frame.y), px(frame.maxX), px(frame.maxY))
        }
        scrollView.layout(0, px(titleHeight), r - l, b - t)
        if (width != measuredContentWidth) reloadLayout()
        updateContentHeight()
        if (!scrollEnabledFlag) scrollView.scrollTo(0, 0)
    }

    override fun onConfigurationChanged(newConfig: android.content.res.Configuration?) {
        super.onConfigurationChanged(newConfig)
        // The light / dark mode may have changed: the background, card, band and divider resolve it again, no app code needed.
        applyStyleColors()
        invalidateMeasurements()
    }

    // MARK: Spacing (android-tagview's lineMargin, tagMargin and textPadding)

    private fun updateStyle(change: (CYLMenuStyle) -> Unit) {
        val copy = listStyle.copy()
        change(copy)
        style = copy
    }

    var lineSpacing: Float
        get() = listStyle.lineSpacing
        set(value) = updateStyle { it.lineSpacing = value }

    var interitemSpacing: Float
        get() = listStyle.interitemSpacing
        set(value) = updateStyle { it.interitemSpacing = value }

    var tagContentInsets: CYLEdgeInsets
        get() = listStyle.tagContentInsets
        set(value) = updateStyle { it.tagContentInsets = value }

    var tagContentInsetTop: Float
        get() = tagContentInsets.top
        set(value) { tagContentInsets = tagContentInsets.copy(top = value) }

    var tagContentInsetLeft: Float
        get() = tagContentInsets.left
        set(value) { tagContentInsets = tagContentInsets.copy(left = value) }

    var tagContentInsetBottom: Float
        get() = tagContentInsets.bottom
        set(value) { tagContentInsets = tagContentInsets.copy(bottom = value) }

    var tagContentInsetRight: Float
        get() = tagContentInsets.right
        set(value) { tagContentInsets = tagContentInsets.copy(right = value) }

    // MARK: Tags (android-tagview's TagView)

    /** The `CYLTagDataSource` the `addTag…` methods fill (made on first use). */
    val tagDataSource: CYLTagDataSource
        get() = _tagDataSource ?: CYLTagDataSource().also {
            it.baseStyle = listStyle
            _tagDataSource = it
        }

    /** The tags of `tagDataSource`. */
    val tags: List<CYLTag> get() = _tagDataSource?.tags ?: emptyList()

    private fun showTags(): CYLTagDataSource {
        val source = tagDataSource
        if (menuDataSource !== source) {
            menuDataSource = source
            showsSectionHeaders = false
            selectionMode = CYLMenuSelectionMode.CYLMenuSelectionModeNone
        }
        return source
    }

    private fun tagAt(indexPath: CYLIndexPath): CYLTag? {
        val source = _tagDataSource ?: return null
        if (menuDataSource !== source || indexPath.section != 0) return null
        return source.tags.getOrNull(indexPath.item)
    }

    fun addTag(tag: CYLTag) {
        showTags().addTag(tag)
        reloadMenuData()
    }

    fun addTags(tags: List<CYLTag>) {
        showTags().addTags(tags)
        reloadMenuData()
    }

    fun addTagsWithTitles(titles: List<String>) = addTags(titles.map { CYLTag(it) })

    fun insertTag(tag: CYLTag, atIndex: Int) {
        val source = showTags()
        val position = min(atIndex, source.tags.size)
        source.insertTag(tag, position)
        shiftSelection(0, position, 1)
        reloadMenuData()
    }

    fun removeTagAtIndex(index: Int) {
        val source = showTags()
        if (index !in source.tags.indices) return
        source.removeTagAtIndex(index)
        removeSelection(CYLIndexPath(index, 0))
        reloadMenuData()
    }

    fun removeAllTags() {
        showTags().removeAllTags()
        selection.clear()
        reloadMenuData()
    }

    var tagClickHandler: ((index: Int, tag: CYLTag) -> Unit)? = null
    var tagDeleteHandler: ((index: Int, tag: CYLTag) -> Unit)? = null

    private fun shiftSelection(section: Int, fromItem: Int, by: Int) {
        selection = selection.mapTo(LinkedHashSet()) { if (it.section == section && it.item >= fromItem) CYLIndexPath(it.item + by, section) else it }
    }

    private fun removeSelection(indexPath: CYLIndexPath) {
        selection.remove(indexPath)
        shiftSelection(indexPath.section, indexPath.item + 1, -1)
    }

    /** `-deleteItemAtIndexPath:`: removes it (when `removesItemsOnDelete`) and tells the delegate. */
    fun deleteItemAtIndexPath(indexPath: CYLIndexPath) {
        if (!isValid(indexPath) || !isDeletableAt(indexPath) || !isEnabledAt(indexPath)) return
        val source = menuDataSource
        val tag = tagAt(indexPath)
        if (removesItemsOnDelete && source != null) {
            source.menuRemoveItemAtIndexPath(indexPath)
            removeSelection(indexPath)
            reloadMenuData()
        }
        menuDelegate?.menuDidDeleteItemAtIndexPath(this, indexPath)
        if (isEditing) saveEditableSectionsToCache()
        if (tag != null) tagDeleteHandler?.invoke(indexPath.item, tag)
    }

    // MARK: Container (AndroidTagView's TagContainerLayout)

    var containerBorderWidth: Float = 0f
        set(value) {
            field = max(0f, value)
            updateContainer()
        }

    var containerBorderColor: Int? = null
        set(value) {
            field = value
            updateContainer()
        }

    var containerCornerRadius: Float = 0f
        set(value) {
            field = max(0f, value)
            updateContainer()
        }

    private fun updateContainer() {
        container.setStroke(if (containerBorderWidth > 0) max(1, px(containerBorderWidth)) else 0, containerBorderColor ?: 0)
        container.cornerRadius = containerCornerRadius * density
        clipToOutline = containerCornerRadius > 0
    }

    /** At most this many rows, the others cut (truncation); 0 for no limit. */
    var maximumNumberOfRows: Int
        get() = if (_foldStyle == CYLMenuFoldStyle.CYLMenuFoldStyleTruncate) defaultVisibleRows else 0
        set(value) {
            if (value > 0) {
                foldStyle = CYLMenuFoldStyle.CYLMenuFoldStyleTruncate
                defaultVisibleRows = value
            } else if (_foldStyle == CYLMenuFoldStyle.CYLMenuFoldStyleTruncate) {
                foldStyle = CYLMenuFoldStyle.CYLMenuFoldStyleNone
            }
        }

    var colorTheme: CYLTagColorTheme = CYLTagColorTheme.CYLTagColorThemeNone
        set(value) {
            field = value
            themeStyles.clear()
            invalidateMeasurements()
        }

    private fun themeStyle(indexPath: CYLIndexPath, baseStyle: CYLMenuStyle): CYLMenuStyle {
        if (colorTheme == CYLTagColorTheme.CYLTagColorThemeNone) return baseStyle
        themeStyles[indexPath]?.let { if (it.first === baseStyle) return it.second }
        val seed = indexPath.item + indexPath.section * 7
        val themed = CYLTagColors.colorsForTheme(colorTheme, seed)?.styleByApplyingToStyle(baseStyle) ?: baseStyle
        themeStyles[indexPath] = baseStyle to themed
        return themed
    }

    var allowsTapping: Boolean = true
    var defaultTagImage: Drawable? = null
    var removesItemsOnDelete: Boolean = true

    /** `-tagButtonAtIndexPath:`: the button of a visible tag, or null. */
    fun tagButtonAtIndexPath(indexPath: CYLIndexPath): CYLTagButton? = content.cellAt(indexPath)?.button

    // MARK: Animated icons

    /**
     * `animationSpeed`: the playback speed of every animated icon, applied at once, also to animations that are
     * playing, without reloading the list. null (the default) uses each tag's `style.animationSpeed`.
     */
    var animationSpeed: Float? = null
        set(value) {
            field = value
            content.forEachTagButton { it.cylApplyListAnimationSpeed(value) }
        }

    /**
     * `animationLoops`: true repeats the animated icons after they start playing (a tap, `playAllAnimations()`) until
     * it is false; false (the default) plays them once.
     */
    var animationLoops: Boolean = false
        set(value) {
            field = value
            content.forEachTagButton { it.animationLoops = value }
        }

    /** `-playAllAnimations`: plays the animated icon of every tag from its start (progress 0), whatever its selection. */
    fun playAllAnimations() {
        content.forEachTagButton { it.playAnimation() }
    }

    // MARK: Long press and reordering

    var tagLongPressHandler: ((index: Int, tag: CYLTag) -> Unit)? = null
        set(value) {
            field = value
            refreshVisibleCells()
        }

    var longPressAccessibilityActionName: String? = null
        set(value) {
            field = value
            refreshVisibleCells()
        }

    var allowsReordering: Boolean = false
        set(value) {
            field = value
            refreshVisibleCells()
        }

    /** Higher is quicker: the long press before a drag lasts 0.5 s / sensitivity. */
    var reorderingSensitivity: Float = 1f
        set(value) { field = if (value > 0) value else 1f }

    var reordering: Boolean = false
        private set

    /** `isReordering`. */
    val isReordering: Boolean get() = reordering

    var tagMoveHandler: ((fromIndex: Int, toIndex: Int) -> Unit)? = null
    var selectedTagDragHandler: ((index: Int, tag: CYLTag) -> Unit)? = null

    private fun canReorder(): Boolean = (allowsReordering || isEditing) && menuDataSource?.supportsMovingItems() == true

    /**
     * `collectionView(_:canMoveItemAt:)`: whether an item can be dragged, while reordering (`allowsReordering`) or
     * editing (an editable section), and never the "+ New tag" item.
     */
    fun canMoveItemAtIndexPath(indexPath: CYLIndexPath): Boolean = canMoveItemAt(indexPath)

    /**
     * `collectionView(_:moveItemAt:to:)`: moves an item as a drag does (the data source moves it, the delegate is told,
     * the list saves its editable sections when it has a cache).
     */
    fun moveItemAtIndexPath(sourceIndexPath: CYLIndexPath, toIndexPath: CYLIndexPath) = moveItem(sourceIndexPath, toIndexPath)

    private fun canMoveItemAt(indexPath: CYLIndexPath): Boolean =
        canReorder() && isValid(indexPath) && (allowsReordering || sectionAllowsEditing(indexPath.section)) &&
            itemTypeAt(indexPath) != CYLMenuItemType.CYLMenuItemTypeCreate

    override fun reportLongPress(indexPath: CYLIndexPath) {
        menuDelegate?.menuDidLongPressItemAtIndexPath(this, indexPath)
        val tag = tagAt(indexPath)
        if (tag != null) tagLongPressHandler?.invoke(indexPath.item, tag)
    }

    private var longPressActionValue: CYLTagLongPressAction = CYLTagLongPressActions.makeDefault()

    /**
     * What a long press on an item does: `CYLTagLongPressActions.first(reorder, report)` by default (reordering where the
     * list can reorder, else the long press is reported). Set another built-in action, a combination or your own.
     */
    var longPressAction: CYLTagLongPressAction
        get() = longPressActionValue
        set(value) {
            content.cancelDrag()
            dismissCallout()
            longPressActionValue = value
        }

    /** The item the current long press began on. */
    private var pressedIndexPath: CYLIndexPath? = null

    /** A long press began on an item: the action takes it when it can; true when it follows the finger. */
    private fun beginLongPress(indexPath: CYLIndexPath): Boolean {
        if (!isValid(indexPath)) return false
        pressedIndexPath = indexPath
        val action = longPressActionValue
        if (!action.canBegin(this, indexPath)) {
            pressedIndexPath = null
            return false
        }
        val follows = action.begin(this, indexPath)
        if (!follows) pressedIndexPath = null
        return follows
    }

    private var calloutPopup: android.widget.PopupWindow? = null

    // MARK: CYLTagLongPressHost

    override fun subtitleForItem(indexPath: CYLIndexPath): String? = menuDataSource?.menuSubtitleForItemAtIndexPath(indexPath)

    override fun showCallout(text: String, indexPath: CYLIndexPath) {
        dismissCallout()
        val cell = content.cellAt(indexPath) ?: return
        val bubble = CYLTagCalloutBubble(context, text)
        val display = android.graphics.Rect().also { getWindowVisibleDisplayFrame(it) }
        bubble.measure(MeasureSpec.makeMeasureSpec(display.width(), MeasureSpec.AT_MOST), MeasureSpec.makeMeasureSpec(display.height(), MeasureSpec.AT_MOST))
        val location = IntArray(2)
        cell.getLocationOnScreen(location)
        val cellCenterX = location[0] + cell.width / 2
        val margin = px(8f)
        val x = max(display.left + margin, min(display.right - margin - bubble.measuredWidth, cellCenterX - bubble.measuredWidth / 2))
        // Above the tag; below it when there is no room.
        val above = location[1] - bubble.measuredHeight >= display.top
        bubble.arrowUp = !above
        bubble.arrowCenter = (cellCenterX - x).toFloat()
        val y = if (above) location[1] - bubble.measuredHeight + px(6f) else location[1] + cell.height - px(6f)
        val popup = android.widget.PopupWindow(bubble, android.view.ViewGroup.LayoutParams.WRAP_CONTENT, android.view.ViewGroup.LayoutParams.WRAP_CONTENT, false)
        // Not outside-touchable: the popup would dismiss itself when the finger that began the long press lifts. The list dismisses
        // the callout on the next touch down, a tap, a scroll, a reload or another long press.
        popup.isOutsideTouchable = false
        popup.setBackgroundDrawable(null)
        popup.setOnDismissListener { if (calloutPopup === popup) calloutPopup = null }
        calloutPopup = popup
        popup.showAtLocation(this, android.view.Gravity.NO_GRAVITY, x, y)
        bubble.contentDescription = text
        bubble.announceForAccessibility(text)
    }

    /** The text of the callout that shows now, or null (for tests). */
    internal val calloutText: String? get() = (calloutPopup?.contentView as? CYLTagCalloutBubble)?.text?.toString()

    override fun dispatchTouchEvent(event: MotionEvent): Boolean {
        if (event.actionMasked == MotionEvent.ACTION_DOWN) dismissCallout()
        return super.dispatchTouchEvent(event)
    }

    override fun dismissCallout() {
        val popup = calloutPopup ?: return
        calloutPopup = null
        popup.dismiss()
    }

    override fun canReorderItem(indexPath: CYLIndexPath): Boolean = canMoveItemAt(indexPath)

    override fun beginReordering(indexPath: CYLIndexPath) = content.beginDrag(indexPath)

    override fun endReordering(destination: CYLIndexPath?, moved: Boolean) {
        val source = pressedIndexPath
        pressedIndexPath = null
        if (source == null) return
        if (!moved || destination == null) reportLongPress(source) else moveItem(source, destination)
    }

    override fun cancelReordering() {
        pressedIndexPath = null
    }

    private fun reportSelectedDrag(indexPath: CYLIndexPath) {
        menuDelegate?.menuDidBeginDraggingSelectedItemAtIndexPath(this, indexPath)
        val tag = tagAt(indexPath)
        if (tag != null) selectedTagDragHandler?.invoke(indexPath.item, tag)
    }

    private fun moveItem(source: CYLIndexPath, destination: CYLIndexPath) {
        if (source == destination || !canReorder()) return
        menuDataSource?.menuMoveItemAtIndexPath(source, destination)
        val from = source.item
        val to = destination.item
        selection = selection.mapTo(LinkedHashSet()) { indexPath ->
            var item = indexPath.item
            if (indexPath.section == source.section) {
                item = when {
                    item == from -> to
                    from < to && item > from && item <= to -> item - 1
                    from > to && item >= to && item < from -> item + 1
                    else -> item
                }
            }
            CYLIndexPath(item, indexPath.section)
        }
        menuDelegate?.menuDidMoveItemAtIndexPath(this, source, destination)
        // The new order survives a relaunch when the list has a cache.
        saveEditableSectionsToCache()
        if (menuDataSource === _tagDataSource) tagMoveHandler?.invoke(from, to)
        post { reloadMenuData() }
    }

    private fun accessibilityMove(indexPath: CYLIndexPath, offset: Int): Boolean {
        val target = indexPath.item + offset
        if (!canMoveItemAt(indexPath) || target < 0 || target >= numberOfVisibleItemsInSection(indexPath.section)) return false
        val destination = CYLIndexPath(target, indexPath.section)
        if (indexPath in selection) reportSelectedDrag(indexPath)
        moveItem(indexPath, destination)
        val announcement = String.format(CYLMenuLocalizedString("CYLMenuTagMoved", "Announced after a move").replace("%ld", "%d"), target + 1)
        post {
            content.cellAt(destination)?.sendAccessibilityEvent(AccessibilityEvent.TYPE_VIEW_FOCUSED)
            announceForAccessibility(announcement)
        }
        return true
    }

    private fun accessibilityActions(indexPath: CYLIndexPath): List<CYLAccessibilityAction> {
        val actions = ArrayList<CYLAccessibilityAction>()
        if (canMoveItemAt(indexPath)) {
            val count = numberOfVisibleItemsInSection(indexPath.section)
            if (indexPath.item > 0) actions.add(CYLAccessibilityAction(CYLMenuLocalizedString("CYLMenuMoveTagEarlier", "Moves a tag one place earlier")) { accessibilityMove(indexPath, -1) })
            if (indexPath.item + 1 < count) actions.add(CYLAccessibilityAction(CYLMenuLocalizedString("CYLMenuMoveTagLater", "Moves a tag one place later")) { accessibilityMove(indexPath, 1) })
        }
        val reportsLongPress = menuDelegate?.handlesLongPress() == true || (tagLongPressHandler != null && tagAt(indexPath) != null)
        if (reportsLongPress) {
            val name = longPressAccessibilityActionName?.takeIf { it.isNotEmpty() } ?: CYLMenuLocalizedString("CYLMenuLongPress", "Does what a long press does")
            actions.add(CYLAccessibilityAction(name) { reportLongPress(indexPath); true })
        }
        return actions
    }

    // MARK: More tag methods (AndroidTagView)

    fun replaceTags(tags: List<CYLTag>) {
        showTags().tags = tags
        selection.clear()
        reloadMenuData()
    }

    fun setTagsWithTitles(titles: List<String>) = setTagsWithTitles(titles, emptyList())

    fun setTagsWithTitles(titles: List<String>, colors: List<CYLTagColors>) {
        replaceTags(titles.mapIndexed { index, title -> CYLTag(title).also { tag -> colors.getOrNull(index)?.let { tag.colors = it } } })
    }

    /**
     * `-setTagsWithCharactersOfText:`: one tag per character of `text`, in order: each grapheme (a letter, a Chinese
     * character, an emoji, a space) is one tag, as the word picker's cells (`CYLMenuStyle.wordPicker()`). Unlike the
     * first `setTagsWithTitles`, it keeps `selectionMode` (a word picker selects several cells).
     */
    fun setTagsWithCharactersOfText(text: String) {
        val mode = selectionMode
        setTagsWithTitles(Regex("\\X").findAll(text).map { it.value }.toList())
        selectionMode = mode
    }

    /** `selectedText`: the titles of the selected items joined in item order (a word picker's picked characters). */
    val selectedText: String
        get() = selectedTitles.joinToString("")

    /**
     * `-selectItemsFromIndexPath:throughIndexPath:`: selects every selectable item from `start` through `end` (either
     * order), in item order across sections, as a smear over them does, without calling the delegate. Needs multiple
     * selection.
     */
    fun selectItemsFromIndexPath(start: CYLIndexPath, throughIndexPath: CYLIndexPath) {
        if (selectionMode != CYLMenuSelectionMode.CYLMenuSelectionModeMultiple || !isValid(start) || !isValid(throughIndexPath)) return
        val result = smearedSelection(selection, start, throughIndexPath, true)
        selection.clear()
        selection.addAll(result)
        refreshVisibleCells()
    }

    /**
     * `allowsSmearSelection`: a finger dragged across the items selects them ("smearing", as WeChat's 涂抹选择填入词): the
     * drag starts on the item it touched down on and selects every item from it to the item under the finger, in item
     * order, or deselects them when that item was already selected. A tap still toggles one item, so TalkBack and Switch
     * Access select the same items. Needs multiple selection; a drag that starts between items scrolls. The delegate
     * gets `menuDidChangeSelectedItems`. False by default; `CYLMenuStyle.wordPicker()` is the matching look.
     */
    var allowsSmearSelection: Boolean = false

    /** The current smear: the selection it began with, its first item and whether it selects. */
    private class Smear(val base: Set<CYLIndexPath>, val anchor: CYLIndexPath, val selects: Boolean)

    private var smear: Smear? = null

    /** Every item in order across sections (the order a smear follows). */
    private fun itemIndexPathsInOrder(): List<CYLIndexPath> {
        val source = menuDataSource ?: return emptyList()
        return (0 until source.numberOfSectionsInMenu()).flatMap { section ->
            (0 until source.menuNumberOfItemsInSection(section)).map { CYLIndexPath(it, section) }
        }
    }

    /** `base` with the items from `anchor` to `end` (item order) selected, or deselected when `selects` is false. */
    private fun smearedSelection(base: Set<CYLIndexPath>, anchor: CYLIndexPath, end: CYLIndexPath, selects: Boolean): LinkedHashSet<CYLIndexPath> {
        val order = itemIndexPathsInOrder()
        val result = LinkedHashSet(base)
        val a = order.indexOf(anchor)
        val b = order.indexOf(end)
        if (a < 0 || b < 0) return result
        for (indexPath in order.subList(min(a, b), max(a, b) + 1)) {
            if (!isSelectableAt(indexPath) || itemTypeAt(indexPath) == CYLMenuItemType.CYLMenuItemTypeCreate) continue
            if (selects) result.add(indexPath) else result.remove(indexPath)
        }
        return result
    }

    /** Whether a smear may start on `indexPath`: smear selection on, multiple selection, not editing, a selectable tag. */
    private fun canSmearFrom(indexPath: CYLIndexPath): Boolean =
        allowsSmearSelection && selectionMode == CYLMenuSelectionMode.CYLMenuSelectionModeMultiple && !isEditing &&
            isValid(indexPath) && isSelectableAt(indexPath) && itemTypeAt(indexPath) != CYLMenuItemType.CYLMenuItemTypeCreate

    /** Starts a smear on `indexPath` (the touched-down item). */
    private fun beginSmear(indexPath: CYLIndexPath) {
        smear = Smear(LinkedHashSet(selection), indexPath, indexPath !in selection)
        menuDelegate?.menuDidChangeSmearing(this, true)
        applySmear(indexPath)
    }

    /** The selection the smear began with, with the items from its first item to `indexPath` changed. */
    private fun applySmear(indexPath: CYLIndexPath) {
        val current = smear ?: return
        val smeared = smearedSelection(current.base, current.anchor, indexPath, current.selects)
        if (smeared == selection) return
        selection.clear()
        selection.addAll(smeared)
        refreshVisibleCells()
        menuDelegate?.menuDidChangeSelectedItems(this, selectedIndexPaths)
    }

    fun addTagWithTitle(title: String) = addTag(CYLTag(title))

    fun insertTagWithTitle(title: String, atIndex: Int) = insertTag(CYLTag(title), atIndex)

    /** `-removeTagsAtIndexes:`. */
    fun removeTagsAtIndexes(indexes: Collection<Int>) {
        val source = showTags()
        for (index in indexes.toSortedSet().reversed()) {
            if (index in source.tags.indices) {
                source.removeTagAtIndex(index)
                removeSelection(CYLIndexPath(index, 0))
            }
        }
        reloadMenuData()
    }

    fun toggleSelectionOfItemAtIndexPath(indexPath: CYLIndexPath) {
        if (indexPath in selection) {
            deselectItemAtIndexPath(indexPath)
        } else if (selectionMode == CYLMenuSelectionMode.CYLMenuSelectionModeNone) {
            if (isValid(indexPath) && isSelectableAt(indexPath)) {
                applySelection(indexPath, null)
                refreshVisibleCells()
            }
        } else {
            selectItemAtIndexPath(indexPath)
        }
    }

    val selectedTitles: List<String>
        get() = selectedIndexPaths.map { menuDataSource?.menuTitleForItemAtIndexPath(it).orEmpty() }

    // MARK: Selection

    /** The selected items, sorted; setting an invalid one throws, as on iOS. */
    var selectedIndexPaths: List<CYLIndexPath>
        get() = selection.sorted()
        set(value) {
            selection.clear()
            if (selectionMode != CYLMenuSelectionMode.CYLMenuSelectionModeNone) {
                for (indexPath in value) {
                    require(isValid(indexPath)) { "Invalid menu selection: $indexPath" }
                    if (isSelectableAt(indexPath)) applySelection(indexPath, null)
                }
            }
            refreshVisibleCells()
        }

    fun selectItemAtIndexPath(indexPath: CYLIndexPath) {
        if (selectionMode == CYLMenuSelectionMode.CYLMenuSelectionModeNone || !isValid(indexPath) || !isSelectableAt(indexPath)) return
        applySelection(indexPath, null)
        refreshVisibleCells()
    }

    fun deselectItemAtIndexPath(indexPath: CYLIndexPath) {
        selection.remove(indexPath)
        refreshVisibleCells()
    }

    fun deselectAllItems() {
        selection.clear()
        refreshVisibleCells()
    }

    private fun applySelection(indexPath: CYLIndexPath, removed: MutableList<CYLIndexPath>?) {
        val exclusive = isExclusiveAt(indexPath)
        for (other in selection.toList()) {
            if (other.section != indexPath.section || other == indexPath) continue
            if (selectionMode == CYLMenuSelectionMode.CYLMenuSelectionModeSingle || exclusive || isExclusiveAt(other)) {
                selection.remove(other)
                removed?.add(other)
            }
        }
        selection.add(indexPath)
    }

    private fun selectedCount(section: Int): Int = selection.count { it.section == section }

    private fun handleTap(indexPath: CYLIndexPath) {
        dismissCallout()
        if (!isEnabledAt(indexPath)) return
        val delegate = menuDelegate
        if (delegate != null && !delegate.menuShouldSelectItemAtIndexPath(this, indexPath)) return
        if (itemTypeAt(indexPath) == CYLMenuItemType.CYLMenuItemTypeCreate && delegate != null) {
            delegate.menuDidRequestNewItemWithName(this, menuDataSource?.menuTitleForItemAtIndexPath(indexPath).orEmpty(), indexPath)
            return
        }
        val removed = ArrayList<CYLIndexPath>()
        var selected = false
        val selectable = isSelectableAt(indexPath)
        when (if (selectable) selectionMode else CYLMenuSelectionMode.CYLMenuSelectionModeNone) {
            CYLMenuSelectionMode.CYLMenuSelectionModeNone -> selected = true
            else -> if (indexPath in selection) {
                if (allowsEmptySelection || selectedCount(indexPath.section) > 1) {
                    selection.remove(indexPath)
                    removed.add(indexPath)
                }
            } else {
                applySelection(indexPath, removed)
                selected = true
            }
        }
        refreshVisibleCells()
        if (selected) content.cellAt(indexPath)?.button?.playAnimation()
        removed.forEach { delegate?.menuDidDeselectItemAtIndexPath(this, it) }
        if (selected) delegate?.menuDidSelectItemAtIndexPath(this, indexPath)
        val changed = removed.isNotEmpty() || (selected && selectable && selectionMode != CYLMenuSelectionMode.CYLMenuSelectionModeNone)
        if (changed) delegate?.menuDidChangeSelectedItems(this, selectedIndexPaths)
        val tag = tagAt(indexPath)
        if (tag != null) tagClickHandler?.invoke(indexPath.item, tag)
    }

    // MARK: Folding

    private fun canFoldRowCount(rowCount: Int): Boolean {
        // Editing shows every item, so each one can be deleted or dragged.
        if (isEditing) return false
        val folds = _foldStyle == CYLMenuFoldStyle.CYLMenuFoldStyleTruncate || _foldControl.position != CYLMenuFoldControlPosition.NONE
        return folds && defaultVisibleRows > 0 && rowCount > defaultVisibleRows
    }

    fun canFoldSection(section: Int): Boolean {
        measureIfNeeded()
        // Without a known width every tag is laid out in a row of its own: that is no layout, so nothing can need a fold yet.
        if (currentWidth() <= 0f) return false
        return section in rows.indices && canFoldRowCount(rows[section].size)
    }

    fun numberOfRowsInSection(section: Int): Int {
        measureIfNeeded()
        return rows.getOrNull(section)?.size ?: 0
    }

    fun isSectionExpanded(section: Int): Boolean = section in expandedSections

    fun numberOfVisibleItemsInSection(section: Int): Int {
        measureIfNeeded()
        if (section !in titles.indices) return 0
        val total = titles[section].size
        if (section !in rows.indices || !canFoldSection(section) || isSectionExpanded(section)) return total
        var visible = 0
        val sectionRows = rows[section]
        var lastRowCount = 0
        for (row in 0 until min(defaultVisibleRows, sectionRows.size)) {
            lastRowCount = sectionRows[row]
            visible += lastRowCount
        }
        visible = min(visible, total)
        if (foldIsInline() && lastRowCount > 0 && section in itemWidths.indices) {
            val widths = itemWidths[section]
            val spacing = listStyle.interitemSpacing
            val contentWidth = contentWidthFor(measuredContentWidth)
            val foldWidth = inlineFoldSize(section, false).width
            var used = 0f
            for (item in visible - lastRowCount until visible) used += (if (item > visible - lastRowCount) spacing else 0f) + widths[item]
            while (lastRowCount > 1 && used + spacing + foldWidth > contentWidth) {
                used -= widths[visible - 1] + spacing
                lastRowCount--
                visible--
            }
        }
        return visible
    }

    fun setExpanded(expanded: Boolean, forSection: Int, animated: Boolean) {
        if (forSection !in titles.indices || expanded == isSectionExpanded(forSection)) return
        if (expanded) expandedSections.add(forSection) else expandedSections.remove(forSection)
        content.rebuild(animated && isAttachedToWindow && !CYLAccessibility.isReduceMotionEnabled(context))
        requestLayout()
        updateContentHeight()
        post { content.foldControlIn(forSection)?.sendAccessibilityEvent(AccessibilityEvent.TYPE_VIEW_FOCUSED) }
        menuDelegate?.menuDidChangeExpanded(this, expanded, forSection)
    }

    private fun foldAccessibilityLabel(section: Int): String {
        val titled = _foldControl.position != CYLMenuFoldControlPosition.NONE
        val action = if (isSectionExpanded(section)) (if (titled) _foldControl.collapseTitle else listStyle.collapseTitle)
        else (if (titled) _foldControl.title else listStyle.expandTitle)
        val title = menuDataSource?.menuTitleForSection(section).orEmpty()
        return if (title.isNotEmpty()) "$title ${action.orEmpty()}" else action.orEmpty()
    }

    private fun toggleSection(section: Int) = setExpanded(!isSectionExpanded(section), section, true)

    /** `-scrollToSection:animated:`. */
    fun scrollToSection(section: Int, animated: Boolean) {
        val top = content.sectionTop(section) ?: return
        scrollTo(top, animated)
    }

    /** `-scrollToItemAtIndexPath:animated:`: centers a visible item. */
    fun scrollToItemAtIndexPath(indexPath: CYLIndexPath, animated: Boolean) {
        if (!isValid(indexPath) || indexPath.item >= numberOfVisibleItemsInSection(indexPath.section)) return
        val frame = content.frameOf(indexPath) ?: return
        val visible = scrollView.height / density
        scrollTo(frame.y + frame.height / 2 - visible / 2, animated)
    }

    private fun scrollTo(dp: Float, animated: Boolean) {
        val maxOffset = max(0, content.measuredHeight - scrollView.height)
        val y = px(dp).coerceIn(0, maxOffset)
        if (animated && !CYLAccessibility.isReduceMotionEnabled(context)) scrollView.smoothScrollTo(0, y) else scrollView.scrollTo(0, y)
    }

    // MARK: Cells

    private fun refreshVisibleCells() {
        content.refresh()
    }

    private fun configureCell(cell: CYLTagListCell, indexPath: CYLIndexPath) {
        if (!isValid(indexPath)) return
        if (cell is CYLTagCreateCell) {
            cell.configureWithName(menuDataSource?.menuTitleForItemAtIndexPath(indexPath), styleForItem(indexPath), isEnabledAt(indexPath))
            return
        }
        cell.configureWithTitle(titles[indexPath.section][indexPath.item], imageAt(indexPath), selectedImageAt(indexPath),
            animationURLAt(indexPath), styleForItem(indexPath), indexPath in selection, isEnabledAt(indexPath))
        cell.button.animationRestingProgress = restingProgressAt(indexPath)
        cell.button.cylApplyListAnimationSpeed(animationSpeed)
        cell.button.animationLoops = animationLoops
        val deletable = isDeletableAt(indexPath) && isEnabledAt(indexPath)
        cell.deletable = deletable
        cell.deleteHandler = if (deletable) ({ deleteItemAtIndexPath(indexPath) }) else null
        val renamable = deletable && isRenamableAt(indexPath)
        cell.isRenamable = renamable
        cell.renamesOnTitleTap = renamable && renamesOnTitleTapWhileEditing
        cell.renameHandler = if (renamable) ({ beginRenamingItemAtIndexPath(indexPath) }) else null
        cell.additionalAccessibilityActions = accessibilityActions(indexPath)
        // A screen-reader user rarely long-presses: the subtitle is the hint when the data source gives none.
        (menuDataSource?.menuAccessibilityHintForItemAtIndexPath(indexPath) ?: subtitleForItem(indexPath))?.let { cell.accessibilityHint = it }
    }

    private fun configureFoldCell(cell: CYLTagFoldCell, section: Int, animated: Boolean) {
        val expanded = isSectionExpanded(section)
        cell.configureWithFoldControl(displayedFoldControl(), styleForSection(section), expanded, animated)
        cell.contentDescription = foldAccessibilityLabel(section)
        CYLAccessibilityNode.apply(cell, true, null, if (expanded) null else CYLMenuLocalizedString("CYLMenuExpandHint", "Shows every tag"), emptyList())
    }

    /** `onBand`: the button sits in a header with a band, so the tint is chosen against the band color. */
    private fun configureFoldButton(button: CYLTagFoldButton, section: Int, expanded: Boolean, animated: Boolean, onBand: Boolean = false) {
        button.applyFoldControl(displayedFoldControl(), listStyle.resolvedFoldControlColor(context, onBand), expanded, animated)
        button.contentDescription = foldAccessibilityLabel(section)
        CYLAccessibilityNode.apply(button, true, null, if (expanded) null else CYLMenuLocalizedString("CYLMenuExpandHint", "Shows every tag"), emptyList())
    }

    /**
     * The scrolled content: section headers, tag cells, inline fold cells and footers, laid out like the iOS collection
     * view with the left-aligned flow layout.
     */
    private inner class ContentView(context: Context) : ViewGroup(context) {
        val layout = CYLCollectionViewLeftAlignedLayout()
        private val cells = HashMap<CYLIndexPath, CYLTagListCell>()
        private val foldCells = HashMap<Int, CYLTagFoldCell>()
        private val headers = HashMap<Int, HeaderView>()
        private val footers = HashMap<Int, FooterView>()
        /** The Liquid Glass behind each section's tags while the card is glass (the library's glass drawing), by section. */
        private val glassCards = HashMap<Int, CYLAnimatedItemView>()
        private val frames = HashMap<View, CYLRect>()
        private val sectionTops = HashMap<Int, Float>()
        private var totalHeight = 0f
        private var dragCell: CYLTagListCell? = null
        private var dragIndexPath: CYLIndexPath? = null
        private var dragStart = CYLPoint()
        private var dragMoved = false
        /** The cell and the point the current long press began on, for the reordering action. */
        private var pressCell: CYLTagListCell? = null
        private var pressStart = CYLPoint()

        /** Reordering picks the item up: the cell grows and follows the finger (the long-press action `reorder`). */
        fun beginDrag(indexPath: CYLIndexPath) {
            val cell = pressCell ?: return
            reordering = true
            menuDelegate?.menuDidChangeReordering(this@CYLTagListView, true)
            dragCell = cell
            dragIndexPath = indexPath
            dragStart = pressStart
            dragMoved = false
            cell.bringToFront()
            cell.animate().scaleX(1.1f).scaleY(1.1f).setDuration(120).start()
            parent?.requestDisallowInterceptTouchEvent(true)
            if (indexPath in selection) reportSelectedDrag(indexPath)
        }

        /** Puts a cell that was picked up back without moving anything. */
        fun cancelDrag() {
            if (dragCell != null) finishDrag(false)
        }

        fun cellAt(indexPath: CYLIndexPath): CYLTagListCell? = cells[indexPath]

        fun forEachTagButton(body: (CYLTagButton) -> Unit) {
            for (cell in cells.values) body(cell.button)
        }

        fun frameOf(indexPath: CYLIndexPath): CYLRect? = cells[indexPath]?.let { frames[it] }

        fun sectionTop(section: Int): Float? = sectionTops[section]

        fun foldControlIn(section: Int): View? = foldCells[section] ?: footers[section]?.foldButton ?: headers[section]?.foldButton?.takeIf { it.visibility == VISIBLE }

        fun layoutHeight(): Float = totalHeight

        /** The card, header band and divider of each section, from the last `computeFrames`. */
        val sectionFrames = ArrayList<CYLTagListSectionFrame>()

        /**
         * The frames of one section. `column` and the header edges are leading-based (the column's x is the leading inset, the
         * divider's `left` inset the leading one); right to left (`rtl`) mirrors the card, the band and the divider inside
         * `width`, so with symmetric insets they are unchanged and with asymmetric ones they swap sides like the tags.
         * `headerInsetLeft` / `headerInsetRight` stay the leading / trailing distances of the title.
         */
        private fun sectionFrameOf(
            section: Int, top: Float, height: Float, header: Float, column: CYLRect, cardY: Float, cardBottom: Float,
            headerEdges: Pair<Float, Float>, width: Float, rtl: Boolean,
        ): CYLTagListSectionFrame {
            val style = listStyle
            fun mirrored(rect: CYLRect?): CYLRect? = if (!rtl || rect == null) rect else CYLRect(width - rect.maxX, rect.y, rect.width, rect.height)
            val card = mirrored(if (style.isInsetGrouped) CYLRect(column.x, cardY, column.width, cardBottom - cardY) else null)
            val band = mirrored(if (header > 0f && style.headerBackgroundColor != null) CYLRect(column.x, top, column.width, header) else null)
            var separator: CYLRect? = null
            if (header > 0f && style.headerSeparatorStyle == CYLHeaderSeparatorStyle.CYLHeaderSeparatorStyleLine && style.headerSeparatorThickness > 0f) {
                val separatorInsets = style.headerSeparatorInsets
                val left = column.x + (separatorInsets?.left ?: 0f)
                val right = column.x + column.width - (separatorInsets?.right ?: 0f)
                val thickness = min(style.headerSeparatorThickness, header)
                separator = mirrored(CYLRect(left, top + header - thickness, max(0f, right - left), thickness))
            }
            return CYLTagListSectionFrame(section, top, height, header, card, band, separator, headerEdges.first, headerEdges.second)
        }

        /** The glass of a card: not touchable, hidden from accessibility, tinted with `sectionBackgroundColor` when it is set. */
        private fun makeGlassCard(): CYLAnimatedItemView = CYLAnimatedItemView(context).apply {
            isClickable = false
            isFocusable = false
            importantForAccessibility = IMPORTANT_FOR_ACCESSIBILITY_NO
            itemBackgroundStyle = CYLAnimatedItemBackgroundStyle.LiquidGlass
            itemBackgroundColor = listStyle.sectionBackgroundColor
            itemCornerRadius = listStyle.sectionCornerRadius
        }

        init {
            // The cards, bands and dividers are drawn behind the headers and tags (onDraw runs before the children).
            setWillNotDraw(false)
        }

        override fun onDraw(canvas: android.graphics.Canvas) {
            val style = listStyle
            val paint = android.graphics.Paint(android.graphics.Paint.ANTI_ALIAS_FLAG)
            fun fill(rect: CYLRect?, color: Int, radius: Float) {
                if (rect == null) return
                paint.color = color
                val box = android.graphics.RectF(rect.x * density, rect.y * density, rect.maxX * density, rect.maxY * density)
                canvas.drawRoundRect(box, radius * density, radius * density, paint)
            }
            for (frame in sectionFrames) {
                fill(frame.headerBand, style.headerBackgroundColor ?: CYLColor.CLEAR, style.headerCornerRadius)
                if (glassCards.isEmpty()) fill(frame.card, style.resolvedSectionBackgroundColor(context), style.sectionCornerRadius)
                fill(frame.headerSeparator, style.resolvedHeaderSeparatorColor(context), 0f)
            }
        }

        fun rebuild(animated: Boolean = false) {
            removeAllViews()
            cells.clear()
            foldCells.clear()
            headers.clear()
            footers.clear()
            glassCards.clear()
            val glassCard = listStyle.isInsetGrouped && listStyle.resolvedSectionBackgroundStyle == CYLTagBackgroundStyle.CYLTagBackgroundStyleLiquidGlass
            for (section in titles.indices) {
                if (glassCard) glassCards[section] = makeGlassCard().also { addView(it) }
                if (headerHeight() > 0) headers[section] = HeaderView(context, section).also { addView(it) }
                val visible = numberOfVisibleItemsInSection(section)
                for (item in 0 until visible) {
                    val indexPath = CYLIndexPath(item, section)
                    val cell = if (itemTypeAt(indexPath) == CYLMenuItemType.CYLMenuItemTypeCreate) CYLTagCreateCell(context) else CYLTagListCell(context)
                    configureCell(cell, indexPath)
                    attachGestures(cell, indexPath)
                    cells[indexPath] = cell
                    addView(cell)
                }
                if (showsInlineFoldCell(section)) {
                    val cell = CYLTagFoldCell(context)
                    configureFoldCell(cell, section, animated)
                    cell.setOnClickListener { toggleSection(section) }
                    foldCells[section] = cell
                    addView(cell)
                }
                if (foldIsInFooter() && canFoldSection(section)) footers[section] = FooterView(context, section).also { addView(it) }
            }
            if (showsAddItemView()) {
                (addItemView.parent as? ViewGroup)?.removeView(addItemView)
                addView(addItemView)
            }
            computeFrames()
            if (animated) {
                alpha = 0.6f
                animate().alpha(1f).setDuration(200).start()
            }
        }

        fun refresh() {
            for ((indexPath, cell) in cells) configureCell(cell, indexPath)
            for ((section, cell) in foldCells) configureFoldCell(cell, section, false)
            computeFrames()
            requestLayout()
        }

        private fun computeFrames() {
            frames.clear()
            sectionTops.clear()
            sectionFrames.clear()
            val width = measuredContentWidth.coerceAtLeast(0f)
            val insets = listStyle.sectionInsets
            val card = cardInsets()
            val column = columnAt(width)
            val headerEdges = headerEdgeInsets()
            // The tags' insets: the section's, plus the card's padding (the same insets when the style is plain).
            val tagInsets = CYLEdgeInsets(insets.top + card.top, insets.left + card.left, insets.bottom, insets.right + card.right)
            val rtl = layoutDirection == LAYOUT_DIRECTION_RTL
            var y = 0f
            for (section in titles.indices) {
                sectionTops[section] = y
                val sectionTop = y
                val header = headerHeight(section, width)
                headers[section]?.let { frames[it] = CYLRect(0f, y, width, header) }
                y += header
                val visible = numberOfVisibleItemsInSection(section)
                val views = ArrayList<View>()
                val sizes = ArrayList<CYLSize>()
                for (item in 0 until visible) {
                    val indexPath = CYLIndexPath(item, section)
                    val cell = cells[indexPath] ?: continue
                    views.add(cell)
                    val itemWidth = itemWidths.getOrNull(section)?.getOrNull(item) ?: 0f
                    val itemHeight = itemHeights.getOrNull(section)?.getOrNull(item) ?: itemHeight()
                    sizes.add(CYLSize(max(1f, itemWidth), itemHeight))
                }
                foldCells[section]?.let {
                    views.add(it)
                    sizes.add(inlineFoldSize(section, isSectionExpanded(section)))
                }
                val cardY = y + insets.top
                val (itemFrames, bottom) = layout.frames(sizes, y, width, tagInsets, listStyle.interitemSpacing, listStyle.lineSpacing, rtl)
                views.forEachIndexed { index, view -> frames[view] = itemFrames[index] }
                val cardBottom = (if (sizes.isEmpty()) y + tagInsets.top else bottom) + card.bottom
                y = cardBottom + insets.bottom
                footers[section]?.let {
                    frames[it] = CYLRect(0f, y, width, footerHeight())
                    y += footerHeight()
                }
                val sectionFrame = sectionFrameOf(section, sectionTop, y - sectionTop, header, column, cardY, cardBottom, headerEdges, width, rtl)
                sectionFrames.add(sectionFrame)
                glassCards[section]?.let { glass -> sectionFrame.card?.let { frames[glass] = it } }
            }
            if (showsAddItemView() && addItemView.parent === this) {
                // Right below the sections, inside the content (it scrolls with the items), as iOS.
                val height = addItemView.preferredHeight / density
                frames[addItemView] = CYLRect(if (rtl) insets.right else insets.left, y, max(0f, width - insets.left - insets.right), height)
                y += height + insets.bottom
            }
            totalHeight = ceil(y)
        }

        override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
            val width = MeasureSpec.getSize(widthMeasureSpec)
            computeFrames()
            for ((view, frame) in frames) {
                view.measure(MeasureSpec.makeMeasureSpec(px(frame.width), MeasureSpec.EXACTLY), MeasureSpec.makeMeasureSpec(px(frame.height), MeasureSpec.EXACTLY))
            }
            setMeasuredDimension(width, px(totalHeight))
        }

        override fun onLayout(changed: Boolean, l: Int, t: Int, r: Int, b: Int) {
            for ((view, frame) in frames) {
                if (view === dragCell) continue
                view.layout(px(frame.x), px(frame.y), px(frame.maxX), px(frame.maxY))
            }
        }

        private fun attachGestures(cell: CYLTagListCell, indexPath: CYLIndexPath) {
            val detector = GestureDetector(context, object : GestureDetector.SimpleOnGestureListener() {
                override fun onDown(e: MotionEvent): Boolean = true

                override fun onSingleTapUp(e: MotionEvent): Boolean {
                    if (allowsTapping) handleTap(indexPath)
                    return true
                }

                override fun onLongPress(e: MotionEvent) {
                    // The long-press action decides what this does (reordering picks the item up through beginDrag).
                    pressCell = cell
                    pressStart = CYLPoint(e.rawX, e.rawY)
                    beginLongPress(indexPath)
                }
            })
            detector.setIsLongpressEnabled(true)
            cell.isLongClickable = true
            var smearDown: CYLPoint? = null
            cell.setOnTouchListener { view, event ->
                // `allowsSmearSelection`: a drag from this tag selects the tags it crosses; the list does not scroll.
                if (canSmearFrom(indexPath)) {
                    when (event.actionMasked) {
                        MotionEvent.ACTION_DOWN -> {
                            smearDown = CYLPoint(event.rawX, event.rawY)
                            parent?.requestDisallowInterceptTouchEvent(true)
                        }
                        MotionEvent.ACTION_MOVE -> {
                            val down = smearDown
                            if (smear == null && down != null && hypot(event.rawX - down.x, event.rawY - down.y) > 8 * density) {
                                beginSmear(indexPath)
                                view.isPressed = false
                                detector.onTouchEvent(MotionEvent.obtain(event).apply { action = MotionEvent.ACTION_CANCEL })
                            }
                            if (smear != null) {
                                indexPathAtRaw(event.rawX, event.rawY)?.let { applySmear(it) }
                                return@setOnTouchListener true
                            }
                        }
                        MotionEvent.ACTION_UP, MotionEvent.ACTION_CANCEL -> {
                            smearDown = null
                            if (smear != null) {
                                smear = null
                                menuDelegate?.menuDidChangeSmearing(this@CYLTagListView, false)
                                view.isPressed = false
                                return@setOnTouchListener true
                            }
                        }
                    }
                }
                if (view.isPressed != (event.actionMasked == MotionEvent.ACTION_DOWN || (event.actionMasked == MotionEvent.ACTION_MOVE && view.isPressed))) {
                    view.isPressed = event.actionMasked == MotionEvent.ACTION_DOWN && allowsTapping
                }
                if (dragCell === cell) {
                    when (event.actionMasked) {
                        MotionEvent.ACTION_MOVE -> {
                            val dx = event.rawX - dragStart.x
                            val dy = event.rawY - dragStart.y
                            if (hypot(dx, dy) > 8 * density) dragMoved = true
                            cell.translationX = dx
                            cell.translationY = dy
                        }
                        MotionEvent.ACTION_UP, MotionEvent.ACTION_CANCEL -> finishDrag(event.actionMasked == MotionEvent.ACTION_UP)
                    }
                    return@setOnTouchListener true
                }
                if (event.actionMasked == MotionEvent.ACTION_UP || event.actionMasked == MotionEvent.ACTION_CANCEL) view.isPressed = false
                detector.onTouchEvent(event)
                view.onTouchEvent(event)
                true
            }
        }

        /** The selectable tag under the screen point (`rawX`, `rawY`), for a smear; null between tags. */
        fun indexPathAtRaw(rawX: Float, rawY: Float): CYLIndexPath? {
            val origin = IntArray(2)
            getLocationOnScreen(origin)
            val x = (rawX - origin[0]) / density
            val y = (rawY - origin[1]) / density
            for ((indexPath, cell) in cells) {
                val frame = frames[cell] ?: continue
                if (x >= frame.x && x < frame.maxX && y >= frame.y && y < frame.maxY) {
                    return indexPath.takeIf { canSmearFrom(it) }
                }
            }
            return null
        }

        /** A drag or smear in progress ends, reporting it, when the list leaves the window (as iOS `didMoveToWindow`). */
        override fun onDetachedFromWindow() {
            super.onDetachedFromWindow()
            if (dragCell != null) finishDrag(false)
            if (smear != null) {
                smear = null
                menuDelegate?.menuDidChangeSmearing(this@CYLTagListView, false)
            }
        }

        private fun finishDrag(released: Boolean) {
            val cell = dragCell ?: return
            val source = dragIndexPath ?: return
            dragCell = null
            dragIndexPath = null
            reordering = false
            menuDelegate?.menuDidChangeReordering(this@CYLTagListView, false)
            cell.animate().scaleX(1f).scaleY(1f).setDuration(120).start()
            val frame = frames[cell]
            val center = frame?.let { CYLPoint(it.x + it.width / 2 + cell.translationX / density, it.y + it.height / 2 + cell.translationY / density) }
            cell.translationX = 0f
            cell.translationY = 0f
            requestLayout()
            if (!released) {
                longPressActionValue.cancel(this@CYLTagListView)
                return
            }
            // The long-press action ends the press: a press that did not move is reported, a moved one moves the item.
            if (!dragMoved || center == null) {
                longPressActionValue.end(this@CYLTagListView, null, false)
                return
            }
            val last = max(0, numberOfVisibleItemsInSection(source.section) - 1)
            var target = source.item
            var best = Float.MAX_VALUE
            for ((indexPath, other) in cells) {
                if (indexPath.section != source.section) continue
                val f = frames[other] ?: continue
                val distance = hypot(f.x + f.width / 2 - center.x, f.y + f.height / 2 - center.y)
                if (distance < best) {
                    best = distance
                    target = indexPath.item
                }
            }
            longPressActionValue.end(this@CYLTagListView, CYLIndexPath(min(target, last), source.section), true)
        }
    }

    /** A section header: indicator bar, icon, title, accessory view, fold button and More button. */
    private inner class HeaderView(context: Context, private val section: Int) : ViewGroup(context) {
        val iconView = ImageView(context).apply { scaleType = ImageView.ScaleType.FIT_CENTER }
        val titleLabel = TextView(context).apply {
            maxLines = listStyle.headerMaxLines
            ellipsize = android.text.TextUtils.TruncateAt.END
            // START: right to left aligns the title text with the right edge, its leading one.
            gravity = android.view.Gravity.START or android.view.Gravity.CENTER_VERTICAL
            ViewCompat.setAccessibilityHeading(this, true)
        }
        val foldButton = CYLTagFoldButton(context)
        /**
         * The section's clear button (`menuShowsClearButtonForSection`, the core's trash icon): a square as tall as a
         * line of the title at the trailing inset, its top and bottom the title text's, tapped in a 44 dp area.
         */
        val clearButton = ImageButton(context).apply {
            visibility = GONE
            background = null
            scaleType = ImageView.ScaleType.FIT_CENTER
            setPadding(0, 0, 0, 0)
            cyl_accessibilityIdentifier = CYLTagListClearButtonAccessibilityIdentifier
        }
        val moreButton = ImageButton(context).apply {
            background = null
            cyl_accessibilityIdentifier = CYLTagListMoreButtonAccessibilityIdentifier
        }
        val indicatorView = View(context)
        private val accessoryView: View?
        private var foldSize = CYLSize.ZERO

        init {
            val source = menuDataSource
            val style = listStyle
            val onBand = style.headerBackgroundColor != null
            addView(indicatorView)
            addView(iconView)
            addView(titleLabel)
            addView(foldButton)
            addView(clearButton)
            addView(moreButton)
            indicatorView.visibility = if (style.headerIndicatorColor == null) GONE else VISIBLE
            style.headerIndicatorColor?.let { indicatorView.setBackgroundColor(it) }
            titleLabel.text = source?.menuTitleForSection(section)
            val font = style.headerFontForTraitCollection()
            titleLabel.setTextSize(android.util.TypedValue.COMPLEX_UNIT_DIP, font.size)
            titleLabel.typeface = font.typeface
            titleLabel.setTextColor(style.resolvedHeaderTextColor(context, onBand))
            iconView.setImageDrawable(source?.menuImageForSection(section))
            iconView.imageTintList = android.content.res.ColorStateList.valueOf(style.resolvedTintColor(context, onBand))
            accessoryView = source?.menuAccessoryViewForSection(section)
            accessoryView?.let { (it.parent as? ViewGroup)?.removeView(it); addView(it) }
            val showsFold = foldIsInHeader() && canFoldSection(section)
            foldButton.visibility = if (showsFold) VISIBLE else GONE
            if (showsFold) {
                val expanded = isSectionExpanded(section)
                configureFoldButton(foldButton, section, expanded, false, onBand)
                foldSize = foldSize(expanded)
            }
            foldButton.setOnClickListener { toggleSection(section) }
            titleLabel.visibility = if (showsSectionHeaders) VISIBLE else GONE
            iconView.visibility = if (showsSectionHeaders && iconView.drawable != null) VISIBLE else GONE
            // The clear button: the core's trash icon (or the style's image), the host's action.
            val showsClear = source?.menuShowsClearButtonForSection(section) == true
            clearButton.visibility = if (showsClear) VISIBLE else GONE
            if (showsClear) {
                val image = (style.clearButtonImage ?: CYLMenuImage("cyl_trash"))?.mutate()
                image?.setTint(style.resolvedClearButtonColor(context, onBand))
                clearButton.setImageDrawable(image)
                val title = source?.menuTitleForSection(section).orEmpty()
                val clear = CYLMenuLocalizedString("CYLMenuClearSection", "The clear button of a section")
                clearButton.contentDescription = if (title.isEmpty()) clear else "$clear $title"
                androidx.appcompat.widget.TooltipCompat.setTooltipText(clearButton, clearButton.contentDescription)
                clearButton.setOnClickListener {
                    menuDelegate?.menuDidTapClearButtonInSection(this@CYLTagListView, section)
                    clearButtonHandler?.invoke(section)
                }
            }
            val showsMore = showsMoreButtonIn(section)
            moreButton.visibility = if (showsMore) VISIBLE else GONE
            if (showsMore) {
                val image = (style.moreButtonImage ?: CYLMenuImage("cyl_more") ?: CYLMenuIconDrawable(CYLMenuIconDrawable.Kind.ELLIPSIS)).mutate()
                image.setTint(style.resolvedMoreButtonColor(context, onBand))
                moreButton.setImageDrawable(image)
                var label = source?.menuAccessibilityLabelForMoreButtonInSection(section)
                if (label.isNullOrEmpty()) {
                    val title = source?.menuTitleForSection(section).orEmpty()
                    val more = CYLMenuLocalizedString("CYLMenuMoreActions", "The More button of a section")
                    label = if (title.isNotEmpty()) "$title $more" else more
                }
                moreButton.contentDescription = label
                moreButton.tooltipText = label
                moreButton.setOnClickListener { menuDelegate?.menuDidTapMoreButtonInSection(this@CYLTagListView, section) }
            }
        }

        override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
            setMeasuredDimension(MeasureSpec.getSize(widthMeasureSpec), MeasureSpec.getSize(heightMeasureSpec))
            for (index in 0 until childCount) getChildAt(index).measure(MeasureSpec.makeMeasureSpec(0, MeasureSpec.UNSPECIFIED), MeasureSpec.makeMeasureSpec(0, MeasureSpec.UNSPECIFIED))
        }

        override fun onLayout(changed: Boolean, l: Int, t: Int, r: Int, b: Int) {
            val width = (r - l) / density
            val height = (b - t) / density
            // Everything below is laid out leading-first (as left to right); `place` mirrors it in right to left.
            laidOutWidth = width
            mirrors = layoutDirection == LAYOUT_DIRECTION_RTL
            val (leadingInset, trailingInset) = headerEdgeInsets()
            var trailing = width - trailingInset
            var leading = leadingInset
            if (clearButton.visibility == VISIBLE) {
                // A square as tall as a line of the title at the trailing inset, aligned with the title text.
                val line = min(height, ceil(titleLabel.lineHeight / density))
                trailing -= line
                place(clearButton, CYLRect(trailing, floor((height - line) / 2), line, line))
                // A 44 dp touch area around it.
                val extra = max(0, ((44 - line) / 2 * density).roundToInt())
                val bounds = android.graphics.Rect(clearButton.left - extra, clearButton.top - extra, clearButton.right + extra, clearButton.bottom + extra)
                touchDelegate = android.view.TouchDelegate(bounds, clearButton)
                trailing -= 8
            }
            if (moreButton.visibility == VISIBLE) {
                val size = min(MORE_BUTTON_SIZE, if (height > 0) max(height, 30f) else MORE_BUTTON_SIZE)
                trailing += floor((size - 22f) / 2)
                trailing -= size
                place(moreButton, CYLRect(trailing, floor((height - size) / 2), size, size))
                trailing -= 4
            }
            if (foldButton.visibility == VISIBLE) {
                val size = CYLSize(headerFoldWidth(foldSize.width, width), min(foldSize.height, height))
                val y = floor((height - size.height) / 2)
                if (_foldControl.position == CYLMenuFoldControlPosition.HEADER_LEADING) {
                    val overhang = headerFoldOverhang()
                    place(foldButton, CYLRect(leading - overhang, y, size.width, size.height))
                    leading += size.width - overhang + 4
                } else {
                    trailing -= size.width - headerFoldOverhang()
                    place(foldButton, CYLRect(trailing, y, size.width, size.height))
                    trailing -= HEADER_FOLD_GAP
                }
            }
            accessoryView?.let { view ->
                val w = min(view.measuredWidth / density, width / 2)
                val h = min(max(view.measuredHeight / density, 1f), height)
                trailing -= w
                place(view, CYLRect(trailing, floor((height - h) / 2), w, h))
                trailing -= 8
            }
            var x = leading
            if (indicatorView.visibility == VISIBLE) {
                val bar = listStyle.headerIndicatorSize
                place(indicatorView, CYLRect(x, floor((height - bar.height) / 2), bar.width, bar.height))
                x += bar.width + 8
            }
            if (iconView.drawable != null && iconView.visibility == VISIBLE) {
                place(iconView, CYLRect(x, floor((height - HEADER_ICON_SIZE) / 2), HEADER_ICON_SIZE, HEADER_ICON_SIZE))
                x += HEADER_ICON_SIZE + 8
            } else {
                place(iconView, CYLRect())
            }
            place(titleLabel, CYLRect(x, 0f, max(0f, trailing - x), height))
        }

        /**
         * Measures `view` at the size of `frame`, then lays it out there, so a label's vertical centering uses the
         * header's height (as the iOS frames do), not its own natural height.
         */
        private fun place(view: View, leadingFrame: CYLRect) {
            val frame = if (mirrors) CYLRect(laidOutWidth - leadingFrame.maxX, leadingFrame.y, leadingFrame.width, leadingFrame.height) else leadingFrame
            val width = px(frame.maxX) - px(frame.x)
            val height = px(frame.maxY) - px(frame.y)
            view.measure(MeasureSpec.makeMeasureSpec(maxOf(0, width), MeasureSpec.EXACTLY), MeasureSpec.makeMeasureSpec(maxOf(0, height), MeasureSpec.EXACTLY))
            view.layout(px(frame.x), px(frame.y), px(frame.x) + maxOf(0, width), px(frame.y) + maxOf(0, height))
        }

        /** The header's width in dp at the last layout, and whether it was laid out right to left (`place` mirrors then). */
        private var laidOutWidth = 0f
        private var mirrors = false
    }

    /** A section footer with the fold control at the bottom. */
    private inner class FooterView(context: Context, private val section: Int) : ViewGroup(context) {
        val foldButton = CYLTagFoldButton(context)
        private val foldSize: CYLSize

        init {
            addView(foldButton)
            val expanded = isSectionExpanded(section)
            configureFoldButton(foldButton, section, expanded, false)
            foldSize = foldSize(expanded)
            foldButton.setOnClickListener { toggleSection(section) }
        }

        override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
            setMeasuredDimension(MeasureSpec.getSize(widthMeasureSpec), MeasureSpec.getSize(heightMeasureSpec))
            foldButton.measure(MeasureSpec.makeMeasureSpec(px(foldSize.width), MeasureSpec.EXACTLY), MeasureSpec.makeMeasureSpec(px(foldSize.height), MeasureSpec.EXACTLY))
        }

        override fun onLayout(changed: Boolean, l: Int, t: Int, r: Int, b: Int) {
            val width = (r - l) / density
            val height = (b - t) / density
            val size = CYLSize(min(foldSize.width, width), min(foldSize.height, height))
            val x = floor((width - size.width) / 2)
            val y = floor((height - size.height) / 2)
            foldButton.layout(px(x), px(y), px(x + size.width), px(y + size.height))
        }
    }
}

/** The list's `animationSpeed`: a speed sets the tag's own, null lets it follow its style again. */
internal fun CYLTagButton.cylApplyListAnimationSpeed(speed: Float?) {
    if (speed != null) animationSpeed = speed else resetAnimationSpeed()
}
