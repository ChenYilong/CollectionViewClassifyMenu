package com.cyl.classifymenu

import android.content.Context
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.drawable.Drawable
import android.os.Bundle
import android.util.AttributeSet
import android.util.TypedValue
import android.view.Gravity
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Button
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
 * `CYLIndexPathButton`: a button that knows its item (section, row), with spacing between its image and title and
 * an inset before the title (dp).
 */
open class CYLIndexPathButton @JvmOverloads constructor(context: Context, attrs: AttributeSet? = null) : Button(context, attrs) {
    var section: Int = 0
    var row: Int = 0

    /**
     * The space between the image and the title, dp.
     */
    var cyl_imageTitleSpacing: Float = 0f
        set(value) {
            if (field == value) return
            field = value
            compoundDrawablePadding = (value * resources.displayMetrics.density).roundToInt()
        }

    /**
     * Extra space before the title, dp.
     */
    var cyl_titleLeadingInset: Float = 0f
        set(value) {
            if (field == value) return
            field = value
            setPaddingRelative((value * resources.displayMetrics.density).roundToInt(), paddingTop, paddingEnd, paddingBottom)
        }

    init {
        isAllCaps = false
        minHeight = 0
        minimumHeight = 0
        minWidth = 0
        minimumWidth = 0
        setPadding(0, 0, 0, 0)
        stateListAnimator = null
    }

    /**
     * `setImage:forState:` for the normal state: the image before the title.
     */
    fun setImage(image: Drawable?) {
        image?.setBounds(0, 0, image.intrinsicWidth, image.intrinsicHeight)
        setCompoundDrawablesRelative(image, null, null, null)
    }

    /**
     * `currentImage`.
     */
    val currentImage: Drawable? get() = compoundDrawablesRelative[0]
}

/**
 * `CYLRightImageButton`: the "Expand / Collapse" button of a section header: the title, then the arrow image after
 * it (7 dp apart); selected means expanded. It never shows a pressed state, as on iOS.
 */
class CYLRightImageButton @JvmOverloads constructor(context: Context, attrs: AttributeSet? = null) : Button(context, attrs) {
    init {
        isAllCaps = false
        background = null
        minHeight = 0
        minimumHeight = 0
        minWidth = 0
        minimumWidth = 0
        setPadding(0, 0, 0, 0)
        stateListAnimator = null
        setTextSize(TypedValue.COMPLEX_UNIT_SP, 12f)
        setTextColor(Color.BLACK)
        compoundDrawablePadding = (7 * resources.displayMetrics.density).roundToInt()
        gravity = Gravity.CENTER
        update()
    }

    override fun setSelected(selected: Boolean) {
        super.setSelected(selected)
        update()
    }

    override fun setPressed(pressed: Boolean) {
        super.setPressed(false)
    }

    private fun update() {
        text = CYLMenuLocalizedString(if (isSelected) "CYLMenuCollapse" else "CYLMenuExpand", "Expand or collapse a menu section")
        val image = CYLMenuImage(if (isSelected) "home_btn_more_selected" else "home_btn_more_normal")
        image?.setBounds(0, 0, image.intrinsicWidth, image.intrinsicHeight)
        setCompoundDrawablesRelative(null, null, image, null)
    }
}

/**
 * `CYLCollectionViewCell`: the classify menu's cell: a `CYLIndexPathButton` filling it, in `cyl_chengNiStyle`.
 */
class CYLCollectionViewCell @JvmOverloads constructor(context: Context, attrs: AttributeSet? = null) : FrameLayout(context, attrs) {
    val button: CYLIndexPathButton = CYLIndexPathButton(context).apply { cyl_chengNiStyle() }
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

    val titleButton: CYLIndexPathButton = CYLIndexPathButton(context).apply {
        background = null
        cyl_titleLeadingInset = 16f
        gravity = Gravity.CENTER_VERTICAL or Gravity.START
        setTextColor(Color.BLACK)
        ViewCompat.setAccessibilityHeading(this, true)
    }

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
    }

    override fun onLayout(changed: Boolean, l: Int, t: Int, r: Int, b: Int) {
        val w = (r - l) / density
        val moreWidth = min(72f, max(0f, w - 28))
        val moreX = max(16f, w - 12 - moreWidth)
        moreButton.layout((moreX * density).roundToInt(), 0, ((moreX + moreWidth) * density).roundToInt(), b - t)
        titleButton.layout(0, 0, (max(0f, moreX - 8) * density).roundToInt(), b - t)
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

    private var scrollView: ScrollView? = null
    private var column: LinearLayout? = null
    private var content: MenuContent? = null
    private var sections: List<Pair<String, List<Pair<String, Drawable?>>>> = emptyList()
    private val expandedSections = HashSet<Int>()

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View {
        val context = inflater.context
        activity?.title = CYLMenuLocalizedString("CYLMenuTitle", "Menu title")
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
                header.titleButton.text = title
                header.titleButton.setImage(menuDataSource?.menuImageForSection(section))
                header.titleButton.section = section
                header.moreButton.tag = section
                header.moreButton.visibility = if (folds(section)) VISIBLE else GONE
                header.moreButton.isSelected = section in expandedSections
                header.moreButton.contentDescription = "${header.moreButton.text}, $title"
                headers.add(header)
                addView(header)
                for (item in 0 until visibleCount(section)) {
                    val indexPath = CYLIndexPath(item, section)
                    val cell = CYLCollectionViewCell(context)
                    val (text, image) = items[item]
                    cell.button.text = text
                    cell.button.setImage(image)
                    cell.button.cyl_imageTitleSpacing = if (image != null) 5f else 0f
                    val f = font()
                    cell.button.setTextSize(TypedValue.COMPLEX_UNIT_DIP, f.size)
                    cell.button.typeface = f.typeface
                    cell.button.gravity = Gravity.CENTER
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
