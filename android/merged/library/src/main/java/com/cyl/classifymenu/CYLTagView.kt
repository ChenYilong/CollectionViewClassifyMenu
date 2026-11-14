package com.cyl.classifymenu

import android.content.Context
import android.graphics.Color
import android.graphics.drawable.GradientDrawable
import android.util.AttributeSet
import android.util.TypedValue
import android.view.Gravity
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import android.widget.FrameLayout
import android.widget.ScrollView
import android.widget.TextView
import androidx.core.view.ViewCompat
import kotlin.math.ceil
import kotlin.math.max
import kotlin.math.min
import kotlin.math.roundToInt

// The TagCollectionView part of the pod (`TagCollectionView/TagCollectionView`): CYLTagView, its models and cells.

/**
 * `kTagCollectionViewCellsHorizonMargin`: the space between tags, dp.
 */
const val kTagCollectionViewCellsHorizonMargin = 12f
/**
 * `kTagCollectionViewToLeftMargin`, dp.
 */
const val kTagCollectionViewToLeftMargin = 16f
/**
 * `kTagCollectionViewToTopMargin`, dp.
 */
const val kTagCollectionViewToTopMargin = 12f
/**
 * `kTagCollectionViewToRightMargin`, dp.
 */
const val kTagCollectionViewToRightMargin = 16f
/**
 * `kTagCollectionViewToBottomtMargin` (the iOS spelling), dp.
 */
const val kTagCollectionViewToBottomtMargin = 10f

/**
 * `CYLTagModel`: a tag's title and its size: the title's width at 17 sp plus 50, and the height of that font (at
 * least 35), dp.
 */
class CYLTagModel {
    /**
     * The title; setting it measures the tag again.
     */
    var title: String = ""
        set(value) {
            field = value
            updateSizeForTraitCollection(null)
        }

    var width: Float = 0f
        private set

    var height: Float = 0f
        private set

    /**
     * `-updateSizeForTraitCollection:`: measures the tag at `fontScale` (null: the system's text size).
     */
    fun updateSizeForTraitCollection(fontScale: Float?) {
        val font = titleFontForTraitCollection(fontScale)
        width = ceil(CYLTagButton.textWidth(title, font)) + 50f
        height = CYLTagHeightForFont(font, 35f)
    }

    companion object {
        /**
         * `+modelWithTitle:`.
         */
        @JvmStatic
        fun modelWithTitle(title: String?): CYLTagModel = CYLTagModel().also { it.title = title ?: "" }

        /**
         * `+titleFontForTraitCollection:`: 17 sp, scaled with the text size.
         */
        @JvmStatic
        fun titleFontForTraitCollection(fontScale: Float?): CYLFont = CYLScaledSystemFont(17f, fontScale ?: android.content.res.Resources.getSystem().configuration.fontScale)
    }
}

/**
 * `CYLTagGroup`: a section of a `CYLTagView`: its name, its tags, whether it is opened, and how many tags fit on its
 * first row (dp).
 */
class CYLTagGroup {
    var groupName: String? = null

    /**
     * The width of the view, dp (0 until laid out: then the screen's width).
     */
    var width: Float = 0f

    /**
     * The header's height, dp (38).
     */
    var height: Float = 38f

    /**
     * Whether every tag shows (`isOpened`).
     */
    var opened: Boolean = false

    /**
     * `isOpened`.
     */
    val isOpened: Boolean get() = opened

    var section: Int = 0

    /**
     * The tags; setting them computes the rows again.
     */
    var itemArr: List<CYLTagModel> = emptyList()
        set(value) {
            field = value
            cellsCountArrayPerRowInSections = null
            firstRowCount = firstRowCellCountForContentWidth(defaultContentWidth())
        }

    var firstRowCount: Int = 0

    private var _cellsCountArrayPerRowInSections: List<Int>? = null

    /**
     * The number of tags of each row at the view's width.
     */
    var cellsCountArrayPerRowInSections: List<Int>?
        get() = _cellsCountArrayPerRowInSections ?: rows(defaultContentWidth()).also { _cellsCountArrayPerRowInSections = it }
        set(value) { _cellsCountArrayPerRowInSections = value }

    private fun defaultContentWidth(): Float {
        val metrics = android.content.res.Resources.getSystem().displayMetrics
        val width = if (width > 0) width else metrics.widthPixels / metrics.density
        return max(0f, width - kTagCollectionViewToLeftMargin - kTagCollectionViewToRightMargin)
    }

    private fun rows(available: Float): List<Int> {
        val counts = ArrayList<Int>()
        var used = 0f
        var count = 0
        for (model in itemArr) {
            val width = min(max(0f, model.width), available)
            if (count > 0 && used + kTagCollectionViewCellsHorizonMargin + width > available) {
                counts.add(count)
                count = 0
                used = 0f
            }
            used += (if (count > 0) kTagCollectionViewCellsHorizonMargin else 0f) + width
            count++
        }
        if (count > 0) counts.add(count)
        return counts
    }

    /**
     * `-firstRowCellCountForContentWidth:`: how many tags fit on the first row of `contentWidth` dp.
     */
    fun firstRowCellCountForContentWidth(contentWidth: Float): Int {
        var count = 0
        var used = 0f
        for (model in itemArr) {
            val width = min(max(0f, model.width), max(0f, contentWidth))
            val next = used + (if (count > 0) kTagCollectionViewCellsHorizonMargin else 0f) + width
            if (count > 0 && next > contentWidth) break
            used = next
            count++
        }
        return count
    }
}

/**
 * `CYLTagCell`: a tag: white text on a blue pill (the XIB's label).
 */
class CYLTagCell @JvmOverloads constructor(context: Context, attrs: AttributeSet? = null) : FrameLayout(context, attrs) {
    private val titleLabel = TextView(context).apply {
        gravity = Gravity.CENTER
        setTextColor(Color.WHITE)
        maxLines = 1
        ellipsize = android.text.TextUtils.TruncateAt.END
        importantForAccessibility = IMPORTANT_FOR_ACCESSIBILITY_NO
    }
    private val pill = GradientDrawable().apply { setColor(Color.rgb(0, 122, 255)) }

    init {
        titleLabel.background = pill
        addView(titleLabel, LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT))
        importantForAccessibility = IMPORTANT_FOR_ACCESSIBILITY_YES
        isFocusable = true
        isClickable = true
        CYLAccessibilityNode.apply(this, true, null, null, emptyList())
    }

    /**
     * The tag shown.
     */
    var model: CYLTagModel? = null
        set(value) {
            field = value
            titleLabel.text = value?.title
            contentDescription = value?.title
            val font = CYLTagModel.titleFontForTraitCollection(resources.configuration.fontScale)
            titleLabel.setTextSize(TypedValue.COMPLEX_UNIT_DIP, font.size)
            titleLabel.typeface = font.typeface
        }

    override fun onSizeChanged(w: Int, h: Int, oldw: Int, oldh: Int) {
        super.onSizeChanged(w, h, oldw, oldh)
        pill.cornerRadius = h / 2f
    }
}

/**
 * `CYLTagHeaderCellDelegate`: the header's button was tapped.
 */
interface CYLTagHeaderCellDelegate {
    /**
     * `-headerViewDidTapNameView:index:`.
     */
    fun headerViewDidTapNameView(headerCell: CYLTagHeaderCell, index: Int)
}

/**
 * `CYLTagHeaderCell`: a section header: the group's name and a More / Less button that opens or closes the group.
 */
class CYLTagHeaderCell @JvmOverloads constructor(context: Context, attrs: AttributeSet? = null) : ViewGroup(context, attrs) {
    private val density: Float get() = resources.displayMetrics.density
    private val nameLabel = TextView(context).apply {
        setTextColor(Color.BLACK)
        setTextSize(TypedValue.COMPLEX_UNIT_SP, 17f)
        gravity = Gravity.CENTER_VERTICAL
        maxLines = 1
        ViewCompat.setAccessibilityHeading(this, true)
    }
    private val button = Button(context).apply {
        isAllCaps = false
        background = null
        setTextColor(Color.BLACK)
        stateListAnimator = null
        minWidth = 0
        minimumWidth = 0
        setOnClickListener { btnClick() }
    }

    var delegate: CYLTagHeaderCellDelegate? = null

    /**
     * The group shown.
     */
    var group: CYLTagGroup? = null
        set(value) {
            field = value
            button.text = CYLMenuLocalizedString(if (value?.isOpened == true) "CYLMenuCollapse" else "CYLMenuExpand", "Expand or collapse a tag group")
            nameLabel.text = value?.groupName
            button.contentDescription = "${button.text}, ${value?.groupName.orEmpty()}"
        }

    init {
        setBackgroundColor(Color.rgb(239, 239, 244))
        addView(nameLabel)
        addView(button)
    }

    /**
     * `-btnClick`: opens or closes the group and tells the delegate.
     */
    fun btnClick() {
        val group = group ?: return
        group.opened = !group.opened
        delegate?.headerViewDidTapNameView(this, group.section)
    }

    override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
        val width = MeasureSpec.getSize(widthMeasureSpec)
        val height = MeasureSpec.getSize(heightMeasureSpec)
        setMeasuredDimension(width, height)
        button.measure(MeasureSpec.makeMeasureSpec(0, MeasureSpec.UNSPECIFIED), MeasureSpec.makeMeasureSpec(height, MeasureSpec.EXACTLY))
        nameLabel.measure(MeasureSpec.makeMeasureSpec(max(0, width - button.measuredWidth - (24 * density).roundToInt()), MeasureSpec.EXACTLY), MeasureSpec.makeMeasureSpec(height, MeasureSpec.EXACTLY))
    }

    override fun onLayout(changed: Boolean, l: Int, t: Int, r: Int, b: Int) {
        val inset = (8 * density).roundToInt()
        nameLabel.layout(inset, 0, inset + nameLabel.measuredWidth, b - t)
        button.layout(r - l - inset - button.measuredWidth, 0, r - l - inset, b - t)
    }
}

/**
 * `CYLTagView`: the sections of a `CYLMenuDataSource` as blue tags in left-aligned rows, each section showing its
 * first row until its header's More button opens it. Lengths are dp.
 */
class CYLTagView @JvmOverloads constructor(context: Context, attrs: AttributeSet? = null) : FrameLayout(context, attrs), CYLTagHeaderCellDelegate {
    private val density: Float get() = resources.displayMetrics.density
    private fun px(dp: Float) = (dp * density).roundToInt()
    private val content = Content(context)

    /**
     * Whether the section headers show (`isShowHeader`).
     */
    var showHeader: Boolean = true
        set(value) {
            field = value
            content.rebuild()
        }

    /**
     * `isShowHeader`.
     */
    val isShowHeader: Boolean get() = showHeader

    /**
     * The sections, made by `reloadMenuData`.
     */
    var groups: MutableList<CYLTagGroup> = ArrayList()

    var menuDataSource: CYLMenuDataSource? = null
    var menuDelegate: CYLMenuDelegate? = null

    init {
        addView(ScrollView(context).apply {
            isVerticalScrollBarEnabled = false
            addView(content)
        }, LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT))
    }

    companion object {
        /**
         * `+tagView` (`makeTagView()` in Swift).
         */
        @JvmStatic
        fun tagView(context: Context): CYLTagView = CYLTagView(context)
    }

    /**
     * `-reloadMenuData`: reads the data source again.
     */
    fun reloadMenuData() {
        val source = menuDataSource
        val scale = resources.configuration.fontScale
        groups = (0 until (source?.numberOfSectionsInMenu() ?: 0)).map { section ->
            CYLTagGroup().also { group ->
                group.section = section
                group.groupName = source!!.menuTitleForSection(section)
                group.width = width / density
                group.itemArr = (0 until source.menuNumberOfItemsInSection(section)).map { item ->
                    CYLTagModel.modelWithTitle(source.menuTitleForItemAtIndexPath(CYLIndexPath(item, section))).also { it.updateSizeForTraitCollection(scale) }
                }
            }
        }.toMutableList()
        content.rebuild()
    }

    override fun headerViewDidTapNameView(headerCell: CYLTagHeaderCell, index: Int) = content.rebuild()

    override fun onSizeChanged(w: Int, h: Int, oldw: Int, oldh: Int) {
        super.onSizeChanged(w, h, oldw, oldh)
        if (w != oldw) {
            groups.forEach { it.width = w / density }
            post { content.rebuild() }
        }
    }

    /**
     * The number of tags a section shows now (for tests).
     */
    fun numberOfVisibleItemsInSection(section: Int): Int = content.visibleCount(section)

    private inner class Content(context: Context) : ViewGroup(context) {
        private val layout = CYLCollectionViewLeftAlignedLayout()
        private val frames = LinkedHashMap<View, CYLRect>()
        private val insets = CYLEdgeInsets(kTagCollectionViewToTopMargin, kTagCollectionViewToLeftMargin, kTagCollectionViewToBottomtMargin, kTagCollectionViewToRightMargin)
        private var totalHeight = 0f

        fun visibleCount(section: Int): Int {
            val group = groups.getOrNull(section) ?: return 0
            val contentWidth = max(0f, this@CYLTagView.width / density - kTagCollectionViewToLeftMargin - kTagCollectionViewToRightMargin)
            return if (group.isOpened) group.itemArr.size else group.firstRowCellCountForContentWidth(contentWidth)
        }

        fun rebuild() {
            removeAllViews()
            for (group in groups) {
                if (showHeader) addView(CYLTagHeaderCell(context).also { it.delegate = this@CYLTagView; it.group = group; it.tag = group })
                for (item in 0 until visibleCount(group.section)) {
                    val indexPath = CYLIndexPath(item, group.section)
                    addView(CYLTagCell(context).also { cell ->
                        cell.model = group.itemArr[item]
                        cell.tag = indexPath
                        cell.setOnClickListener { menuDelegate?.menuDidSelectItemAtIndexPath(this@CYLTagView, indexPath) }
                    })
                }
            }
            requestLayout()
        }

        override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
            val widthPx = MeasureSpec.getSize(widthMeasureSpec)
            val width = widthPx / density
            frames.clear()
            var y = 35f
            val children = (0 until childCount).map { getChildAt(it) }
            for (group in groups) {
                children.firstOrNull { it is CYLTagHeaderCell && it.tag === group }?.let {
                    frames[it] = CYLRect(kTagCollectionViewToLeftMargin, y, max(0f, width - kTagCollectionViewToLeftMargin - kTagCollectionViewToRightMargin), group.height)
                    y += group.height
                }
                val cells = children.filter { (it.tag as? CYLIndexPath)?.section == group.section }
                val contentWidth = max(0f, width - kTagCollectionViewToLeftMargin - kTagCollectionViewToRightMargin)
                val sizes = cells.map { val model = (it as CYLTagCell).model!!; CYLSize(min(max(0f, model.width), contentWidth), model.height) }
                val (itemFrames, bottom) = layout.frames(sizes, y, width, insets, kTagCollectionViewCellsHorizonMargin, 10f)
                cells.forEachIndexed { index, cell -> frames[cell] = itemFrames[index] }
                y = (if (sizes.isEmpty()) y + insets.top else bottom) + insets.bottom
            }
            totalHeight = y
            for ((view, frame) in frames) view.measure(MeasureSpec.makeMeasureSpec(px(frame.width), MeasureSpec.EXACTLY), MeasureSpec.makeMeasureSpec(px(frame.height), MeasureSpec.EXACTLY))
            setMeasuredDimension(widthPx, px(totalHeight))
        }

        override fun onLayout(changed: Boolean, l: Int, t: Int, r: Int, b: Int) {
            for ((view, frame) in frames) view.layout(px(frame.x), px(frame.y), px(frame.maxX), px(frame.maxY))
        }
    }
}
