package com.cyl.classifymenu

import android.content.Context
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.drawable.Drawable
import android.os.Bundle
import android.util.AttributeSet
import android.view.Gravity
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import android.widget.LinearLayout
import android.widget.ScrollView
import androidx.core.view.ViewCompat
import androidx.fragment.app.Fragment
import kotlin.math.ceil
import kotlin.math.max
import kotlin.math.min
import kotlin.math.roundToInt

/**
 * `CYLIndexPathButton`: a tag that knows the item it shows (`section`, `row`): a `CYLTagButton`, as on iOS, drawn from
 * its `style` (for example `CYLMenuStyle.classifyMenuTag()`, `CYLMenuStyle.filterTag()` or
 * `CYLMenuStyle.sectionTitle()`), with `title`, `image` and `animationURL`. The icon, the title, the animated icon, its
 * placeholder and its fallbacks are `CYLTagButton`'s (and `CYLAnimatedItemView`'s). TalkBack reads it as one button
 * labeled with the title as shown, with its selected state.
 */
open class CYLIndexPathButton @JvmOverloads constructor(context: Context, attrs: AttributeSet? = null) : CYLTagButton(context, attrs) {

    /**
     * The section of the item the button shows.
     */
    var section: Int = 0

    /**
     * The row (item) of the item the button shows.
     */
    var row: Int = 0

    /**
     * The space between the image and the title, dp: `style.imageTitleSpacing`.
     */
    var cyl_imageTitleSpacing: Float
        get() = style!!.imageTitleSpacing
        set(value) = changeStyle { it.imageTitleSpacing = value }

    /**
     * The space before the content (the icon, or the title alone), dp: the leading content inset of every state of
     * `style`, as `CYLMenuStyle.sectionTitle(leadingInset = …)` sets it.
     */
    var cyl_titleLeadingInset: Float
        get() = style!!.normalAppearance.contentInsets.left
        set(value) = changeStyle { copy ->
            for (state in listOf(CYLControlState.NORMAL, CYLControlState.SELECTED, CYLControlState.DISABLED)) {
                val appearance = copy.appearanceForState(state)
                appearance.contentInsets = appearance.contentInsets.copy(left = value)
            }
        }

    /**
     * The horizontal gravity of the icon and title: `Gravity.CENTER_HORIZONTAL` (or `Gravity.CENTER`) centers them
     * (`style.contentAlignment` center), any other value puts them at the leading edge. The content is always centered
     * vertically.
     */
    var gravity: Int
        get() {
            val centered = style!!.contentAlignment == CYLTagContentAlignment.CYLTagContentAlignmentCenter
            return if (centered) Gravity.CENTER else Gravity.CENTER_VERTICAL or Gravity.START
        }
        set(value) = changeStyle {
            val centered = (value and Gravity.HORIZONTAL_GRAVITY_MASK) == Gravity.CENTER_HORIZONTAL
            it.contentAlignment = if (centered) CYLTagContentAlignment.CYLTagContentAlignmentCenter else CYLTagContentAlignment.CYLTagContentAlignmentLeading
        }

    /**
     * `currentImage`: the static icon of the current state, `selectedImage` while selected (when set), else `image`.
     */
    val currentImage: Drawable?
        get() = if (isSelected && selectedImage != null) selectedImage else image

    /**
     * Changes a copy of `style` and sets it, so the tag lays itself out again.
     */
    private fun changeStyle(change: (CYLMenuStyle) -> Unit) {
        val copy = style!!.copy()
        change(copy)
        style = copy
    }
}

/**
 * `CYLRightImageButton`: the "more" button of a menu section: a `CYLTagButton`, as on iOS, showing `expandTitle` or,
 * while selected (the section is expanded), `collapseTitle`, with the arrow after the title (7 dp apart); it never
 * shows a pressed state. TalkBack reads it as one button labeled with the current title.
 */
open class CYLRightImageButton @JvmOverloads constructor(context: Context, attrs: AttributeSet? = null) : CYLTagButton(context, attrs) {

    /**
     * False until the button is set up: `CYLTagButton` may call the state hooks while it is being built.
     */
    private var setUp = false

    /**
     * The title while not selected (the section is folded); "Expand", localized, by default.
     */
    var expandTitle: String = CYLMenuLocalizedString("CYLMenuExpand", "Expand a menu section")
        set(value) {
            field = value
            updateTitle()
        }

    /**
     * The title while selected (the section is expanded); "Collapse", localized, by default.
     */
    var collapseTitle: String = CYLMenuLocalizedString("CYLMenuCollapse", "Collapse a menu section")
        set(value) {
            field = value
            updateTitle()
        }

    init {
        style = CYLMenuStyle.sectionTitle(fontSize = 12f).apply {
            contentAlignment = CYLTagContentAlignment.CYLTagContentAlignmentCenter
            imagePlacement = CYLTagImagePlacement.CYLTagImagePlacementTrailing
            imageTitleSpacing = 7f
        }
        // The arrows keep their own colors, as the bundle images do on iOS.
        image = CYLMenuImage("home_btn_more_normal")?.cyl_imageWithRenderingModeAlwaysOriginal()
        selectedImage = CYLMenuImage("home_btn_more_selected")?.cyl_imageWithRenderingModeAlwaysOriginal()
        setUp = true
        updateTitle()
    }

    override fun setSelected(selected: Boolean) {
        super.setSelected(selected)
        updateTitle()
    }

    /**
     * Never pressed: the button toggles between its normal and selected looks only.
     */
    override fun setPressed(pressed: Boolean) {
        super.setPressed(false)
    }

    private fun updateTitle() {
        if (!setUp) return
        val text = if (isSelected) collapseTitle else expandTitle
        if (title?.toString() != text) title = text
    }
}

/**
 * `CYLCollectionViewCell`: the classify menu's cell: a `CYLIndexPathButton` filling it, in
 * `CYLMenuStyle.classifyMenuTag(CYLCollectionCellButtonStyle.chengNi)`.
 */
class CYLCollectionViewCell @JvmOverloads constructor(context: Context, attrs: AttributeSet? = null) : FrameLayout(context, attrs) {
    val button: CYLIndexPathButton = CYLIndexPathButton(context).apply { cylApply(CYLCollectionCellButtonStyle.chengNi) }
    var section: Int = 0
    var row: Int = 0
    var shouldShow: Boolean = true

    init {
        addView(button, LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT))
    }
}

/**
 * `CYLFilterHeaderViewDelegate`: the More button of a section header was tapped.
 */
interface CYLFilterHeaderViewDelegate {
    /**
     * `-filterHeaderViewDidTapMoreButton:`: `sender` is the header's More button.
     */
    fun filterHeaderViewDidTapMoreButton(sender: Any)
}

/**
 * `CYLFilterHeaderViewHeigt`: the header's height, dp (the iOS spelling).
 */
const val CYLFilterHeaderViewHeigt = 38f

/**
 * `CYLFilterHeaderView`: a section header of the classify menu: the title (with the section's image), the More
 * button at the trailing edge (hidden unless the section folds) and a separator at the bottom.
 */
class CYLFilterHeaderView @JvmOverloads constructor(context: Context, attrs: AttributeSet? = null) : ViewGroup(context, attrs) {
    private val density: Float get() = resources.displayMetrics.density

    /**
     * The section's title (and image): a `CYLTagButton` in `CYLMenuStyle.sectionTitle(leadingInset = 16f)`, read by
     * TalkBack as a heading, not a control.
     */
    val titleButton: CYLIndexPathButton = CYLIndexPathButton(context).apply {
        style = CYLMenuStyle.sectionTitle(leadingInset = 16f)
        isClickable = false
        ViewCompat.setAccessibilityHeading(this, true)
    }

    /**
     * Expands or folds the section (a `CYLTagButton`); hidden by default.
     */
    val moreButton: CYLRightImageButton = CYLRightImageButton(context).apply {
        visibility = GONE
    }

    var delegate: CYLFilterHeaderViewDelegate? = null

    private val separatorPaint = Paint().apply { color = Color.rgb(188, 188, 188) }

    init {
        setBackgroundColor(Color.WHITE)
        setWillNotDraw(false)
        addView(titleButton)
        addView(moreButton)
        moreButton.setOnClickListener { moreButtonTapped(it) }
    }

    /**
     * `-moreButtonTapped:`: tells the delegate.
     */
    fun moreButtonTapped(sender: Any?) {
        delegate?.filterHeaderViewDidTapMoreButton(moreButton)
    }

    override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
        val width = MeasureSpec.getSize(widthMeasureSpec)
        val height = if (MeasureSpec.getMode(heightMeasureSpec) == MeasureSpec.EXACTLY) MeasureSpec.getSize(heightMeasureSpec) else (CYLFilterHeaderViewHeigt * density).roundToInt()
        setMeasuredDimension(width, height)
        val w = width / density
        val moreWidth = min(72f, max(0f, w - 28))
        val moreX = max(16f, w - 12 - moreWidth)
        moreButton.measure(MeasureSpec.makeMeasureSpec((moreWidth * density).roundToInt(), MeasureSpec.EXACTLY), MeasureSpec.makeMeasureSpec(height, MeasureSpec.EXACTLY))
        titleButton.measure(MeasureSpec.makeMeasureSpec((max(0f, moreX - 24) * density).roundToInt(), MeasureSpec.EXACTLY), MeasureSpec.makeMeasureSpec(height, MeasureSpec.EXACTLY))
        // iOS: titleButton.frame = (16, 0, moreX - 24, height), image at its leading edge, title 16 after it.
    }

    override fun onLayout(changed: Boolean, l: Int, t: Int, r: Int, b: Int) {
        val w = (r - l) / density
        val moreWidth = min(72f, max(0f, w - 28))
        val moreX = max(16f, w - 12 - moreWidth)
        moreButton.layout((moreX * density).roundToInt(), 0, ((moreX + moreWidth) * density).roundToInt(), b - t)
        titleButton.layout((16 * density).roundToInt(), 0, (max(16f, moreX - 8) * density).roundToInt(), b - t)
    }

    override fun onDraw(canvas: Canvas) {
        val inset = 16 * density
        canvas.drawRect(inset, height - max(1f, 0.5f * density), width - inset, height.toFloat(), separatorPaint)
    }
}

/**
 * `CYLClassifyMenuViewController`: the original classify menu: sections of tags in left-aligned rows, folded to
 * `defaultVisibleRows` with an Expand / Collapse button per section, a header and a footer view, and the selected
 * item. On Android it is a `Fragment`; lengths are dp.
 */
open class CYLClassifyMenuViewController : Fragment() {
    var menuDataSource: CYLMenuDataSource? = null
    var menuDelegate: CYLMenuDelegate? = null

    /**
     * A view above the sections.
     */
    var menuHeaderView: View? = null
        set(value) {
            field = value
            attachHeaderAndFooter()
        }

    /**
     * A view below the sections.
     */
    var menuFooterView: View? = null
        set(value) {
            field = value
            attachHeaderAndFooter()
            updateMenuLayout()
        }

    /**
     * The selected item, shown selected.
     */
    var selectedIndexPath: CYLIndexPath? = null
        set(value) {
            field = value
            content?.refreshSelection()
        }

    /**
     * Rows a folded section shows, at least 1.
     */
    var defaultVisibleRows: Int = 1
        set(value) {
            field = max(1, value)
            content?.rebuild()
        }

    /**
     * The menu's title ("Categories", localized): `self.title` on iOS. A Fragment shares its activity's title with the
     * other pages, so the host shows it where it fits (the demo's navigation bar).
     */
    val menuTitle: String get() = CYLMenuLocalizedString("CYLMenuTitle", "Menu title")

    private var scrollView: ScrollView? = null
    private var column: LinearLayout? = null
    private var content: MenuContent? = null
    private var sections: List<Pair<String, List<Pair<String, Drawable?>>>> = emptyList()
    private val expandedSections = HashSet<Int>()

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View {
        val context = inflater.context
        val column = LinearLayout(context).apply { orientation = LinearLayout.VERTICAL }
        val content = MenuContent(context)
        column.addView(content, LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT))
        val scroll = ScrollView(context).apply {
            setBackgroundColor(Color.rgb(252, 252, 252))
            isVerticalScrollBarEnabled = false
            addView(column)
        }
        this.scrollView = scroll
        this.column = column
        this.content = content
        initData()
        attachHeaderAndFooter()
        content.rebuild()
        return scroll
    }

    override fun onDestroyView() {
        (menuHeaderView?.parent as? ViewGroup)?.removeView(menuHeaderView)
        (menuFooterView?.parent as? ViewGroup)?.removeView(menuFooterView)
        scrollView = null
        column = null
        content = null
        super.onDestroyView()
    }

    private fun attachHeaderAndFooter() {
        val column = column ?: return
        val content = content ?: return
        for (index in column.childCount - 1 downTo 0) if (column.getChildAt(index) !== content) column.removeViewAt(index)
        menuHeaderView?.let { (it.parent as? ViewGroup)?.removeView(it); column.addView(it, 0) }
        menuFooterView?.let { (it.parent as? ViewGroup)?.removeView(it); column.addView(it) }
    }

    private fun initData() {
        val source = menuDataSource
        sections = (0 until (source?.numberOfSectionsInMenu() ?: 0)).map { section ->
            source!!.menuTitleForSection(section) to (0 until source.menuNumberOfItemsInSection(section)).map { item ->
                val indexPath = CYLIndexPath(item, section)
                source.menuTitleForItemAtIndexPath(indexPath) to source.menuImageForItemAtIndexPath(indexPath)
            }
        }
    }

    /**
     * `-reloadMenuData`: reads the data source again; every section folds again.
     */
    fun reloadMenuData() {
        initData()
        expandedSections.clear()
        content?.rebuild()
    }

    /**
     * `-updateMenuLayout`: lays the menu out again (after the header or footer changed size).
     */
    fun updateMenuLayout() {
        content?.requestLayout()
        column?.requestLayout()
    }

    /**
     * The number of items a section shows now, and whether its More button shows (for tests and the example).
     */
    fun numberOfVisibleItemsInSection(section: Int): Int = content?.visibleCount(section) ?: 0

    /**
     * Whether a section is expanded.
     */
    fun isSectionExpanded(section: Int): Boolean = section in expandedSections

    /**
     * Expands or folds a section, as its More button does.
     */
    fun setSectionExpanded(section: Int, expanded: Boolean) {
        if (expanded) expandedSections.add(section) else expandedSections.remove(section)
        content?.rebuild()
    }

    private inner class MenuContent(context: Context) : ViewGroup(context), CYLFilterHeaderViewDelegate {
        private val density: Float get() = resources.displayMetrics.density
        private fun px(dp: Float) = (dp * density).roundToInt()
        private val layout = CYLCollectionViewLeftAlignedLayout()
        private val insets = CYLEdgeInsets(12f, 16f, 10f, 16f)
        private val spacing = 12f
        private val lineSpacing = 10f
        private val headers = ArrayList<CYLFilterHeaderView>()
        private val cells = HashMap<CYLIndexPath, CYLCollectionViewCell>()
        private val frames = HashMap<View, CYLRect>()
        private var totalHeight = 0f
        private var measuredFor = -1f
        private var rows: List<List<Int>> = emptyList()

        init {
            setBackgroundColor(Color.WHITE)
        }

        private fun font(): CYLFont = CYLTagTitleFontForTraitCollection(resources.configuration.fontScale)

        private fun cellHeight(): Float = CYLTagHeightForFont(font(), 30f)

        private fun itemWidth(title: String, image: Drawable?, width: Float): Float {
            val text = CYLTagButton.textWidth(title, font())
            val cell = ceil(text) + if (image != null) 38f else 19f
            return min(cell, max(0f, width - insets.left - insets.right))
        }

        private fun computeRows(width: Float) {
            val available = max(0f, width - insets.left - insets.right)
            rows = sections.map { (_, items) ->
                val counts = ArrayList<Int>()
                var used = 0f
                var count = 0
                for ((title, image) in items) {
                    val w = itemWidth(title, image, width)
                    if (count > 0 && used + spacing + w > available) { counts.add(count); used = 0f; count = 0 }
                    used += (if (count > 0) spacing else 0f) + w
                    count++
                }
                if (count > 0) counts.add(count)
                counts
            }
        }

        fun visibleCount(section: Int): Int {
            val total = sections.getOrNull(section)?.second?.size ?: 0
            if (section in expandedSections) return total
            return min(total, rows.getOrNull(section)?.take(defaultVisibleRows)?.sum() ?: total)
        }

        private fun folds(section: Int): Boolean = (rows.getOrNull(section)?.size ?: 0) > defaultVisibleRows

        fun rebuild() {
            removeAllViews()
            headers.clear()
            cells.clear()
            val width = this.width / density
            if (width > 0) computeRows(width)
            measuredFor = width
            sections.forEachIndexed { section, (title, items) ->
                val header = CYLFilterHeaderView(context)
                header.delegate = this
                // CYLTagButtons: their styles set the fonts, the colors and the icon spacing. The data source's images
                // keep their own colors, as on iOS.
                header.titleButton.title = title
                header.titleButton.image = menuDataSource?.menuImageForSection(section)?.cyl_imageWithRenderingModeAlwaysOriginal()
                header.titleButton.section = section
                header.moreButton.tag = section
                header.moreButton.visibility = if (folds(section)) VISIBLE else GONE
                header.moreButton.isSelected = section in expandedSections
                // TalkBack reads the button's title, then the section it folds (the iOS accessibilityHint).
                CYLAccessibilityNode.apply(header.moreButton, true, null, title, emptyList())
                headers.add(header)
                addView(header)
                for (item in 0 until visibleCount(section)) {
                    val indexPath = CYLIndexPath(item, section)
                    val cell = CYLCollectionViewCell(context)
                    val (text, image) = items[item]
                    cell.button.title = text
                    cell.button.image = image?.cyl_imageWithRenderingModeAlwaysOriginal()
                    cell.button.section = section
                    cell.button.row = item
                    cell.section = section
                    cell.row = item
                    cell.button.setOnClickListener { menuDelegate?.menuDidSelectItemAtIndexPath(this@CYLClassifyMenuViewController, indexPath) }
                    cells[indexPath] = cell
                    addView(cell)
                }
            }
            refreshSelection()
            requestLayout()
        }

        fun refreshSelection() {
            for ((indexPath, cell) in cells) {
                val selected = indexPath == selectedIndexPath
                cell.button.isSelected = selected
                CYLAccessibilityNode.apply(cell.button, true, selected, null, emptyList())
            }
        }

        override fun filterHeaderViewDidTapMoreButton(sender: Any) {
            val button = sender as? CYLRightImageButton ?: return
            val section = button.tag as? Int ?: return
            button.isSelected = !button.isSelected
            if (button.isSelected) expandedSections.add(section) else expandedSections.remove(section)
            rebuild()
        }

        override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
            val widthPx = MeasureSpec.getSize(widthMeasureSpec)
            val width = widthPx / density
            if (width != measuredFor && width > 0) {
                post { rebuild() }
                computeRows(width)
                measuredFor = width
            }
            frames.clear()
            var y = 15f
            sections.forEachIndexed { section, _ ->
                headers.getOrNull(section)?.let { frames[it] = CYLRect(0f, y, width, CYLFilterHeaderViewHeigt) }
                y += CYLFilterHeaderViewHeigt
                val visible = (0 until visibleCount(section)).mapNotNull { item -> cells[CYLIndexPath(item, section)]?.let { it to item } }
                val sizes = visible.map { (_, item) ->
                    val (title, image) = sections[section].second[item]
                    CYLSize(itemWidth(title, image, width), cellHeight())
                }
                val (itemFrames, bottom) = layout.frames(sizes, y, width, insets, spacing, lineSpacing)
                visible.forEachIndexed { index, (cell, _) -> frames[cell] = itemFrames[index] }
                y = (if (sizes.isEmpty()) y + insets.top else bottom) + insets.bottom
            }
            totalHeight = y + 12f + 10f
            for ((view, frame) in frames) {
                view.measure(MeasureSpec.makeMeasureSpec(px(frame.width), MeasureSpec.EXACTLY), MeasureSpec.makeMeasureSpec(px(frame.height), MeasureSpec.EXACTLY))
            }
            setMeasuredDimension(widthPx, px(totalHeight))
        }

        override fun onLayout(changed: Boolean, l: Int, t: Int, r: Int, b: Int) {
            for ((view, frame) in frames) view.layout(px(frame.x), px(frame.y), px(frame.maxX), px(frame.maxY))
        }
    }
}
