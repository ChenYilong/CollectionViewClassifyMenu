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
) : ViewGroup(context, attrs) {

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
            val style = CYLMenuStyle.defaultStyle()
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
                CYLMenuFoldControlPosition.CYLMenuFoldControlPositionBottom -> CYLMenuFoldStyle.CYLMenuFoldStyleFooterChevron
                CYLMenuFoldControlPosition.CYLMenuFoldControlPositionTopTrailing,
                CYLMenuFoldControlPosition.CYLMenuFoldControlPositionTopLeading -> CYLMenuFoldStyle.CYLMenuFoldStyleHeaderButton
                CYLMenuFoldControlPosition.CYLMenuFoldControlPositionNone ->
                    if (_foldStyle == CYLMenuFoldStyle.CYLMenuFoldStyleTruncate) _foldStyle else CYLMenuFoldStyle.CYLMenuFoldStyleNone
                CYLMenuFoldControlPosition.CYLMenuFoldControlPositionInline -> CYLMenuFoldStyle.CYLMenuFoldStyleNone
            }
            reloadLayout()
        }

    var foldStyle: CYLMenuFoldStyle
        get() = _foldStyle
        set(value) {
            _foldStyle = value
            _foldControl = when (value) {
                CYLMenuFoldStyle.CYLMenuFoldStyleHeaderButton -> CYLMenuFoldControl.foldControlWithPosition(
                    CYLMenuFoldControlPosition.CYLMenuFoldControlPositionTopTrailing, CYLMenuFoldControlContent.CYLMenuFoldControlContentTitle)
                CYLMenuFoldStyle.CYLMenuFoldStyleFooterChevron -> CYLMenuFoldControl.foldControlWithPosition(
                    CYLMenuFoldControlPosition.CYLMenuFoldControlPositionBottom, CYLMenuFoldControlContent.CYLMenuFoldControlContentIcon)
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

    private fun applyStyleColors() {
        container.setColor(listStyle.backgroundColor)
        content.layout.rowAlignment = listStyle.rowAlignment.ordinal
        themeStyles.clear()
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

    // MARK: Data

    /** `-reloadMenuData`: reads the data source again and lays the list out. */
    fun reloadMenuData() {
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

    private fun isDeletableAt(indexPath: CYLIndexPath): Boolean =
        itemTypeAt(indexPath) != CYLMenuItemType.CYLMenuItemTypeCreate && menuDataSource?.menuItemIsDeletableAtIndexPath(indexPath) == true

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
        if (itemTypeAt(indexPath) == CYLMenuItemType.CYLMenuItemTypeCreate) return false
        return menuDataSource?.menuItemIsSelectableAtIndexPath(indexPath) ?: true
    }

    private fun styleForSection(section: Int): CYLMenuStyle = menuDataSource?.menuStyleForSection(section) ?: listStyle

    private fun showsMoreButtonIn(section: Int): Boolean = menuDataSource?.menuShowsMoreButtonInSection(section) == true

    private fun selectedImageAt(indexPath: CYLIndexPath): Drawable? = menuDataSource?.menuSelectedImageForItemAtIndexPath(indexPath)

    // MARK: Measurement

    private fun itemHeight(): Float = CYLTagButton.heightForStyle(listStyle)

    private fun foldIsInHeader(): Boolean = _foldControl.position == CYLMenuFoldControlPosition.CYLMenuFoldControlPositionTopTrailing ||
        _foldControl.position == CYLMenuFoldControlPosition.CYLMenuFoldControlPositionTopLeading

    private fun foldIsInFooter(): Boolean = _foldControl.position == CYLMenuFoldControlPosition.CYLMenuFoldControlPositionBottom

    private fun foldIsInline(): Boolean = _foldControl.position == CYLMenuFoldControlPosition.CYLMenuFoldControlPositionInline

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

    private fun headerHeight(): Float {
        val foldHeight = if (foldIsInHeader()) foldSize(false).height else 0f
        if (!showsSectionHeaders) return foldHeight
        val font = listStyle.headerFontForTraitCollection()
        return max(max(listStyle.headerHeight, ceil(CYLTagButton.fontLineHeight(font)) + 12), foldHeight)
    }

    private fun contentWidthFor(width: Float): Float = max(0f, width - listStyle.sectionInsets.left - listStyle.sectionInsets.right)

    private fun widthsFor(contentWidth: Float): List<List<Float>> = titles.mapIndexed { section, items ->
        items.mapIndexed { item, title ->
            val indexPath = CYLIndexPath(item, section)
            val itemStyle = styleForItem(indexPath)
            val iconSize = CYLTagButton.iconSizeForImage(imageAt(indexPath), animationURLAt(indexPath) != null, itemStyle)
            var width = CYLTagButton.widthForTitle(title, iconSize, isDeletableAt(indexPath), itemStyle)
            val perRow = styleForSection(section).numberOfItemsPerRow
            if (perRow > 0) width = gridItemWidth(contentWidth, perRow)
            min(width, contentWidth)
        }
    }

    private fun heightsForItems(): List<List<Float>> {
        val listHeight = itemHeight()
        return titles.mapIndexed { section, items ->
            items.indices.map { item ->
                val itemStyle = styleForItem(CYLIndexPath(item, section))
                if (itemStyle === listStyle) listHeight else max(listHeight, CYLTagButton.heightForStyle(itemStyle))
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
        itemHeights = heightsForItems()
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
        val heights = if (same) itemHeights else heightsForItems()
        val header = headerHeight()
        val insets = listStyle.sectionInsets
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
            height += header + insets.top + insets.bottom
            height += heightOfRows(rowCount, sectionRows[section], heights.getOrElse(section) { emptyList() })
            if (foldable && foldIsInFooter()) height += footerHeight()
        }
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

    private fun canReorder(): Boolean = allowsReordering && menuDataSource?.supportsMovingItems() == true

    private fun reportLongPress(indexPath: CYLIndexPath) {
        menuDelegate?.menuDidLongPressItemAtIndexPath(this, indexPath)
        val tag = tagAt(indexPath)
        if (tag != null) tagLongPressHandler?.invoke(indexPath.item, tag)
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
        if (menuDataSource === _tagDataSource) tagMoveHandler?.invoke(from, to)
        post { reloadMenuData() }
    }

    private fun accessibilityMove(indexPath: CYLIndexPath, offset: Int): Boolean {
        val target = indexPath.item + offset
        if (!canReorder() || target < 0 || target >= numberOfVisibleItemsInSection(indexPath.section)) return false
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
        if (canReorder() && isValid(indexPath)) {
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
        val folds = _foldStyle == CYLMenuFoldStyle.CYLMenuFoldStyleTruncate || _foldControl.position != CYLMenuFoldControlPosition.CYLMenuFoldControlPositionNone
        return folds && defaultVisibleRows > 0 && rowCount > defaultVisibleRows
    }

    fun canFoldSection(section: Int): Boolean {
        measureIfNeeded()
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
        val titled = _foldControl.position != CYLMenuFoldControlPosition.CYLMenuFoldControlPositionNone
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
        val deletable = isDeletableAt(indexPath) && isEnabledAt(indexPath)
        cell.deletable = deletable
        cell.deleteHandler = if (deletable) ({ deleteItemAtIndexPath(indexPath) }) else null
        cell.additionalAccessibilityActions = accessibilityActions(indexPath)
        menuDataSource?.menuAccessibilityHintForItemAtIndexPath(indexPath)?.let { cell.accessibilityHint = it }
    }

    private fun configureFoldCell(cell: CYLTagFoldCell, section: Int, animated: Boolean) {
        val expanded = isSectionExpanded(section)
        cell.configureWithFoldControl(displayedFoldControl(), styleForSection(section), expanded, animated)
        cell.contentDescription = foldAccessibilityLabel(section)
        CYLAccessibilityNode.apply(cell, true, null, if (expanded) null else CYLMenuLocalizedString("CYLMenuExpandHint", "Shows every tag"), emptyList())
    }

    private fun configureFoldButton(button: CYLTagFoldButton, section: Int, expanded: Boolean, animated: Boolean) {
        button.applyFoldControl(displayedFoldControl(), listStyle.foldControlColor, expanded, animated)
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
        private val frames = HashMap<View, CYLRect>()
        private val sectionTops = HashMap<Int, Float>()
        private var totalHeight = 0f
        private var dragCell: CYLTagListCell? = null
        private var dragIndexPath: CYLIndexPath? = null
        private var dragStart = CYLPoint()
        private var dragMoved = false

        fun cellAt(indexPath: CYLIndexPath): CYLTagListCell? = cells[indexPath]

        fun frameOf(indexPath: CYLIndexPath): CYLRect? = cells[indexPath]?.let { frames[it] }

        fun sectionTop(section: Int): Float? = sectionTops[section]

        fun foldControlIn(section: Int): View? = foldCells[section] ?: footers[section]?.foldButton ?: headers[section]?.foldButton?.takeIf { it.visibility == VISIBLE }

        fun layoutHeight(): Float = totalHeight

        fun rebuild(animated: Boolean = false) {
            removeAllViews()
            cells.clear()
            foldCells.clear()
            headers.clear()
            footers.clear()
            for (section in titles.indices) {
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
            val width = measuredContentWidth.coerceAtLeast(0f)
            val insets = listStyle.sectionInsets
            val rtl = layoutDirection == LAYOUT_DIRECTION_RTL
            var y = 0f
            for (section in titles.indices) {
                sectionTops[section] = y
                val header = headerHeight()
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
                val (itemFrames, bottom) = layout.frames(sizes, y, width, insets, listStyle.interitemSpacing, listStyle.lineSpacing, rtl)
                views.forEachIndexed { index, view -> frames[view] = itemFrames[index] }
                y = (if (sizes.isEmpty()) y + insets.top else bottom) + insets.bottom
                footers[section]?.let {
                    frames[it] = CYLRect(0f, y, width, footerHeight())
                    y += footerHeight()
                }
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
                    if (canReorder()) {
                        reordering = true
                        dragCell = cell
                        dragIndexPath = indexPath
                        dragStart = CYLPoint(e.rawX, e.rawY)
                        dragMoved = false
                        cell.bringToFront()
                        cell.animate().scaleX(1.1f).scaleY(1.1f).setDuration(120).start()
                        parent?.requestDisallowInterceptTouchEvent(true)
                        if (indexPath in selection) reportSelectedDrag(indexPath)
                    } else {
                        reportLongPress(indexPath)
                    }
                }
            })
            detector.setIsLongpressEnabled(true)
            cell.isLongClickable = true
            cell.setOnTouchListener { view, event ->
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

        private fun finishDrag(released: Boolean) {
            val cell = dragCell ?: return
            val source = dragIndexPath ?: return
            dragCell = null
            dragIndexPath = null
            reordering = false
            cell.animate().scaleX(1f).scaleY(1f).setDuration(120).start()
            val frame = frames[cell]
            val center = frame?.let { CYLPoint(it.x + it.width / 2 + cell.translationX / density, it.y + it.height / 2 + cell.translationY / density) }
            cell.translationX = 0f
            cell.translationY = 0f
            requestLayout()
            if (!released) return
            if (!dragMoved) {
                reportLongPress(source)
                return
            }
            center ?: return
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
            moveItem(source, CYLIndexPath(min(target, last), source.section))
        }
    }

    /** A section header: indicator bar, icon, title, accessory view, fold button and More button. */
    private inner class HeaderView(context: Context, private val section: Int) : ViewGroup(context) {
        val iconView = ImageView(context).apply { scaleType = ImageView.ScaleType.FIT_CENTER }
        val titleLabel = TextView(context).apply {
            maxLines = 1
            ellipsize = android.text.TextUtils.TruncateAt.END
            gravity = android.view.Gravity.CENTER_VERTICAL
            ViewCompat.setAccessibilityHeading(this, true)
        }
        val foldButton = CYLTagFoldButton(context)
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
            addView(indicatorView)
            addView(iconView)
            addView(titleLabel)
            addView(foldButton)
            addView(moreButton)
            indicatorView.visibility = if (style.headerIndicatorColor == null) GONE else VISIBLE
            style.headerIndicatorColor?.let { indicatorView.setBackgroundColor(it) }
            titleLabel.text = source?.menuTitleForSection(section)
            val font = style.headerFontForTraitCollection()
            titleLabel.setTextSize(android.util.TypedValue.COMPLEX_UNIT_DIP, font.size)
            titleLabel.typeface = font.typeface
            titleLabel.setTextColor(style.headerTextColor)
            iconView.setImageDrawable(source?.menuImageForSection(section))
            accessoryView = source?.menuAccessoryViewForSection(section)
            accessoryView?.let { (it.parent as? ViewGroup)?.removeView(it); addView(it) }
            val showsFold = foldIsInHeader() && canFoldSection(section)
            foldButton.visibility = if (showsFold) VISIBLE else GONE
            if (showsFold) {
                val expanded = isSectionExpanded(section)
                configureFoldButton(foldButton, section, expanded, false)
                foldSize = foldSize(expanded)
            }
            foldButton.setOnClickListener { toggleSection(section) }
            titleLabel.visibility = if (showsSectionHeaders) VISIBLE else GONE
            iconView.visibility = if (showsSectionHeaders && iconView.drawable != null) VISIBLE else GONE
            val showsMore = showsMoreButtonIn(section)
            moreButton.visibility = if (showsMore) VISIBLE else GONE
            if (showsMore) {
                val image = (style.moreButtonImage ?: CYLMenuImage("cyl_more") ?: CYLMenuIconDrawable(CYLMenuIconDrawable.Kind.ELLIPSIS)).mutate()
                image.setTint(style.moreButtonColor)
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
            val inset = listStyle.headerHorizontalInset
            var trailing = width - inset
            var leading = inset
            if (moreButton.visibility == VISIBLE) {
                val size = min(MORE_BUTTON_SIZE, if (height > 0) max(height, 30f) else MORE_BUTTON_SIZE)
                trailing += floor((size - 22f) / 2)
                trailing -= size
                place(moreButton, CYLRect(trailing, floor((height - size) / 2), size, size))
                trailing -= 4
            }
            if (foldButton.visibility == VISIBLE) {
                val size = CYLSize(min(foldSize.width, width / 2), min(foldSize.height, height))
                val y = floor((height - size.height) / 2)
                if (_foldControl.position == CYLMenuFoldControlPosition.CYLMenuFoldControlPositionTopLeading) {
                    place(foldButton, CYLRect(leading - 6, y, size.width, size.height))
                    leading += size.width - 6 + 4
                } else {
                    trailing -= size.width - 6
                    place(foldButton, CYLRect(trailing, y, size.width, size.height))
                    trailing -= 8
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

        private fun place(view: View, frame: CYLRect) = view.layout(px(frame.x), px(frame.y), px(frame.maxX), px(frame.maxY))
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
