package com.cyl.classifymenu

import android.animation.Animator
import android.animation.AnimatorListenerAdapter
import android.content.Context
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.os.Bundle
import android.util.AttributeSet
import android.util.TypedValue
import android.view.Gravity
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.ScrollView
import android.widget.TextView
import androidx.fragment.app.Fragment
import java.io.File
import kotlin.math.ceil
import kotlin.math.max
import kotlin.math.min
import kotlin.math.roundToInt

/**
 * Key of the filter settings in `filterParamsDictionary`.
 */
const val kMultipleFilterSetting = "kMultipleFilterSetting"

/**
 * Key of the "modified" flag in `filterParamsDictionary`.
 */
const val kMultipleFilterSettingModified = "kMultipleFilterSettingModified"

/**
 * `CYLFilterParamsTool`: the state of the multiple filter: the titles per section (`dataSources`) and a selected flag
 * per item (`filterParamsArray`, the first item of each section selected by default).
 */
class CYLFilterParamsTool {
    /**
     * The titles, one list per section.
     */
    var dataSources: List<List<String>> = emptyList()

    private var _filterParamsArray: MutableList<MutableList<Boolean>>? = null

    /**
     * One selected flag per item; made from `dataSources` (first item selected) on first use.
     */
    var filterParamsArray: MutableList<MutableList<Boolean>>
        get() = _filterParamsArray ?: dataSources.map { section -> MutableList(section.size) { it == 0 } }.toMutableList().also { _filterParamsArray = it }
        set(value) { _filterParamsArray = value }

    private var _filterParamsDictionary: MutableMap<String, Any?>? = null

    /**
     * The settings and the modified flag.
     */
    var filterParamsDictionary: MutableMap<String, Any?>
        get() = _filterParamsDictionary ?: mutableMapOf<String, Any?>(kMultipleFilterSettingModified to false, kMultipleFilterSetting to filterParamsArray)
            .also { _filterParamsDictionary = it }
        set(value) { _filterParamsDictionary = value }

    private var _filterParamsContentDictionary: MutableMap<String, Any?>? = null

    /**
     * Free-form content of the filter ("skilled" by default, as on iOS).
     */
    var filterParamsContentDictionary: MutableMap<String, Any?>
        get() = _filterParamsContentDictionary ?: mutableMapOf<String, Any?>("skilled" to mutableListOf<Any?>()).also { _filterParamsContentDictionary = it }
        set(value) { _filterParamsContentDictionary = value }

    private var _filename: String? = null

    /**
     * Where the settings are saved: `kMultipleFilterSetting` in the app's files folder (the documents folder on iOS),
     * once `filesDir` is known; set it to choose another file.
     */
    var filename: String
        get() = _filename ?: (filesDir?.let { File(it, kMultipleFilterSetting).path } ?: kMultipleFilterSetting)
        set(value) { _filename = value }

    /**
     * The folder `filename` defaults to (an app sets `context.filesDir`).
     */
    var filesDir: File? = null
}

/**
 * `-stretchableImageWithLeftCapWidth:topCapHeight:` with caps at half the image (`+[UIImage stretchableImageNamed:]`
 * of the iOS cell): the corners are drawn at their size and only the middle column and row stretch.
 */
internal class CYLStretchableDrawable(private val bitmap: android.graphics.Bitmap) : android.graphics.drawable.Drawable() {
    private val paint = android.graphics.Paint(android.graphics.Paint.FILTER_BITMAP_FLAG)

    override fun draw(canvas: Canvas) {
        val b = bounds
        if (b.isEmpty) return
        val w = bitmap.width
        val h = bitmap.height
        val capX = w / 2
        val capY = h / 2
        val scale = bitmap.density.takeIf { it > 0 }?.let { android.content.res.Resources.getSystem().displayMetrics.densityDpi.toFloat() / it } ?: 1f
        val dx = minOf((capX * scale).toInt(), b.width() / 2)
        val dy = minOf((capY * scale).toInt(), b.height() / 2)
        val xs = intArrayOf(0, capX, capX + 1, w)
        val ys = intArrayOf(0, capY, capY + 1, h)
        val dxs = intArrayOf(b.left, b.left + dx, b.right - dx, b.right)
        val dys = intArrayOf(b.top, b.top + dy, b.bottom - dy, b.bottom)
        for (row in 0..2) for (col in 0..2) {
            canvas.drawBitmap(bitmap, android.graphics.Rect(xs[col], ys[row], xs[col + 1], ys[row + 1]),
                android.graphics.Rect(dxs[col], dys[row], dxs[col + 1], dys[row + 1]), paint)
        }
    }

    override fun setAlpha(alpha: Int) { paint.alpha = alpha }
    override fun setColorFilter(colorFilter: android.graphics.ColorFilter?) { paint.colorFilter = colorFilter }
    @Deprecated("Deprecated in Java")
    override fun getOpacity(): Int = android.graphics.PixelFormat.TRANSLUCENT

    companion object {
        fun named(name: String): android.graphics.drawable.Drawable? =
            (CYLMenuImage(name) as? android.graphics.drawable.BitmapDrawable)?.bitmap?.let { CYLStretchableDrawable(it) }
    }
}

/**
 * `CYLFilterCollectionCell`: an item of the multiple filter: a button with the slide backgrounds (green title, white
 * when selected), not touchable itself (the cell is).
 */
class CYLFilterCollectionCell @JvmOverloads constructor(context: Context, attrs: AttributeSet? = null) : FrameLayout(context, attrs) {
    val titleButton: CYLIndexPathButton = CYLIndexPathButton(context).apply {
        isClickable = false
        isFocusable = false
        importantForAccessibility = IMPORTANT_FOR_ACCESSIBILITY_NO
        val font = CYLTagTitleFont
        setTextSize(TypedValue.COMPLEX_UNIT_SP, font.size)
        gravity = Gravity.CENTER
        background = android.graphics.drawable.StateListDrawable().apply {
            CYLStretchableDrawable.named("btn_slide_selected")?.let { addState(intArrayOf(android.R.attr.state_selected), it) }
            CYLStretchableDrawable.named("btn_slide_normal")?.let { addState(intArrayOf(), it) }
        }
        setTextColor(android.content.res.ColorStateList(arrayOf(intArrayOf(android.R.attr.state_selected), intArrayOf()),
            intArrayOf(Color.WHITE, Color.rgb(96, 147, 130))))
    }

    init {
        addView(titleButton, LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT))
        importantForAccessibility = IMPORTANT_FOR_ACCESSIBILITY_YES
        isFocusable = true
    }
}

/**
 * `CYLMultipleFilterHeaderView`: a section header of the multiple filter: an image at the leading edge and the title
 * (50 dp in, half-transparent black) above a green line.
 */
class CYLMultipleFilterHeaderView @JvmOverloads constructor(context: Context, attrs: AttributeSet? = null) : ViewGroup(context, attrs) {
    private val density: Float get() = resources.displayMetrics.density
    val imageView: ImageView = ImageView(context).apply { scaleType = ImageView.ScaleType.CENTER }
    val titleLabel: TextView = TextView(context).apply {
        setTextColor(Color.argb(128, 0, 0, 0))
        gravity = Gravity.CENTER_VERTICAL
        maxLines = 1
        ellipsize = android.text.TextUtils.TruncateAt.END
        androidx.core.view.ViewCompat.setAccessibilityHeading(this, true)
    }
    private val linePaint = Paint().apply { color = Color.rgb(146, 175, 164) }

    init {
        setWillNotDraw(false)
        addView(imageView)
        addView(titleLabel)
    }

    override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
        val width = MeasureSpec.getSize(widthMeasureSpec)
        val height = (38 * density).roundToInt()
        setMeasuredDimension(width, height)
        imageView.measure(MeasureSpec.makeMeasureSpec(height, MeasureSpec.EXACTLY), MeasureSpec.makeMeasureSpec(height, MeasureSpec.EXACTLY))
        titleLabel.measure(MeasureSpec.makeMeasureSpec(max(0, width - (50 * density).roundToInt()), MeasureSpec.EXACTLY), MeasureSpec.makeMeasureSpec(height, MeasureSpec.EXACTLY))
    }

    override fun onLayout(changed: Boolean, l: Int, t: Int, r: Int, b: Int) {
        val x = (6 * density).roundToInt()
        imageView.layout(x, 0, x + imageView.measuredWidth, b - t)
        titleLabel.layout((50 * density).roundToInt(), 0, r - l, b - t)
    }

    override fun onDraw(canvas: Canvas) {
        canvas.drawRect(50 * density, height - max(1f, 0.5f * density), width.toFloat(), height.toFloat(), linePaint)
    }
}

/**
 * `CYLFilterControllerDelegate`: the filter panel closed after Apply or Reset.
 */
interface CYLFilterControllerDelegate {
    /**
     * `-filterControllerDidComplete:`.
     */
    fun filterControllerDidComplete(controller: CYLFilterBaseController) {}
}

/**
 * `CYLFilterBaseController`: a panel that slides in from the leading edge over a dimmed screen, on a blurred capture
 * of the screen, with Reset and Apply buttons at the bottom; tapping the dimmed part closes it. On Android it is a
 * `Fragment` added over a container with `showInView`.
 */
open class CYLFilterBaseController : Fragment() {
    /**
     * The panel's scrolling content (the collection view on iOS).
     */
    var collectionView: ViewGroup? = null
        protected set

    /**
     * The dimmed area beside the panel.
     */
    var contentView: View? = null
        protected set

    var restoreButton: Button? = null
        protected set

    var okButton: Button? = null
        protected set

    /**
     * Free-form data of a subclass.
     */
    var dataSource: List<Any?> = emptyList()

    /**
     * Free-form settings of a subclass.
     */
    var settingArray: MutableList<Any?> = mutableListOf()

    var delegate: CYLFilterControllerDelegate? = null

    private var blurImageView: ImageView? = null
    private var panel: ViewGroup? = null
    private var host: ViewGroup? = null
    private var root: FrameLayout? = null
    private var blurred: Bitmap? = null

    /**
     * Builds the panel's content inside `collectionView` (a subclass fills it).
     */
    protected open fun buildContent(container: ViewGroup) {}

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View = makeView(inflater.context)

    private fun makeView(context: Context): FrameLayout {
        root?.let { return it }
        val d = context.resources.displayMetrics.density
        val root = FrameLayout(context)
        val dim = View(context).apply {
            setBackgroundColor(Color.BLACK)
            alpha = 0f
            cyl_setTarget { hide() }
            importantForAccessibility = View.IMPORTANT_FOR_ACCESSIBILITY_NO
        }
        root.addView(dim, FrameLayout.LayoutParams(FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.MATCH_PARENT))
        val panel = object : FrameLayout(context) {
            override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
                val parentWidth = MeasureSpec.getSize(widthMeasureSpec)
                super.onMeasure(MeasureSpec.makeMeasureSpec(max(0, parentWidth - (50 * d).roundToInt()), MeasureSpec.EXACTLY), heightMeasureSpec)
            }
        }
        val blur = ImageView(context).apply { scaleType = ImageView.ScaleType.CENTER_CROP; setBackgroundColor(Color.WHITE) }
        panel.addView(blur, FrameLayout.LayoutParams(FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.MATCH_PARENT))
        val scroll = ScrollView(context).apply { isVerticalScrollBarEnabled = false }
        panel.addView(scroll, FrameLayout.LayoutParams(FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.MATCH_PARENT).apply { bottomMargin = (44 * d).roundToInt() })
        val buttons = android.widget.LinearLayout(context)
        val restore = Button(context).apply {
            text = CYLMenuLocalizedString("CYLFilterReset", "Reset filter")
            isAllCaps = false
            setTextColor(Color.BLACK)
            stateListAnimator = null
            setBackgroundColor(Color.WHITE)
            setOnClickListener { restoreButtonClicked(it) }
        }
        val ok = Button(context).apply {
            text = CYLMenuLocalizedString("CYLFilterConfirm", "Apply filter")
            isAllCaps = false
            setTextColor(Color.BLACK)
            stateListAnimator = null
            setBackgroundColor(Color.WHITE)
            setOnClickListener { confirmButtonClicked(it) }
        }
        val line = Color.LTGRAY
        buttons.addView(restore, android.widget.LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.MATCH_PARENT, 1f))
        buttons.addView(ok, android.widget.LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.MATCH_PARENT, 1f))
        panel.addView(buttons, FrameLayout.LayoutParams(FrameLayout.LayoutParams.MATCH_PARENT, (44 * d).roundToInt(), Gravity.BOTTOM))
        restore.addOnLayoutChangeListener { v, _, _, _, _, _, _, _, _ -> v.overlay.clear(); v.cyl_addSubLayerWithFrame(CYLRect(0f, 0f, v.width / d, 0.5f), line) }
        ok.addOnLayoutChangeListener { v, _, _, _, _, _, _, _, _ ->
            v.overlay.clear()
            v.cyl_addSubLayerWithFrame(CYLRect(0f, 0f, v.width / d, 0.5f), line)
            v.cyl_addSubLayerWithFrame(CYLRect(0f, 0f, 0.5f, 44f), line)
        }
        root.addView(panel, FrameLayout.LayoutParams(FrameLayout.LayoutParams.WRAP_CONTENT, FrameLayout.LayoutParams.MATCH_PARENT, Gravity.START))
        this.root = root
        this.panel = panel
        this.blurImageView = blur
        this.collectionView = scroll
        this.contentView = dim
        this.restoreButton = restore
        this.okButton = ok
        blurred?.let { blur.setImageBitmap(it) }
        buildContent(scroll)
        return root
    }

    /**
     * `-showInView:`: captures and blurs `view` as the panel's background, adds the panel over it and slides it in.
     */
    open fun showInView(view: ViewGroup) {
        val root = makeView(view.context)
        val d = view.resources.displayMetrics.density
        blurred = if (view.width > 0 && view.height > 0) view.cyl_captureWithWidth(max(1f, view.width / d - 50)).cyl_blurredImageWithRadius(25f, 10, null) else null
        blurImageView?.setImageBitmap(blurred)
        (root.parent as? ViewGroup)?.removeView(root)
        view.addView(root, ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT))
        host = view
        root.post {
            val panel = panel ?: return@post
            panel.translationX = -panel.width.toFloat()
            contentView?.alpha = 0f
            animate(panel.animate().translationX(0f)) {}
            contentView?.animate()?.alpha(0.35f)?.setDuration(duration())?.start()
        }
    }

    private fun duration(): Long = if (CYLAccessibility.isReduceMotionEnabled(requireHostContext())) 0 else 300

    private fun requireHostContext(): Context = root?.context ?: host?.context ?: requireContext()

    private fun animate(animator: android.view.ViewPropertyAnimator, end: () -> Unit) {
        animator.setDuration(duration()).setListener(object : AnimatorListenerAdapter() {
            override fun onAnimationEnd(animation: Animator) {
                animator.setListener(null)
                end()
            }
        }).start()
    }

    private fun close(completion: () -> Unit) {
        val panel = panel
        val root = root
        if (panel == null || root == null || root.parent == null) {
            completion()
            return
        }
        contentView?.animate()?.alpha(0f)?.setDuration(duration())?.start()
        animate(panel.animate().translationX(-panel.width.toFloat())) {
            (root.parent as? ViewGroup)?.removeView(root)
            completion()
        }
    }

    /**
     * Closes the panel without applying (a tap on the dimmed area).
     */
    open fun hide() = close {}

    /**
     * `-itemButtonClicked:`: a subclass's item was tapped (nothing in the base class).
     */
    open fun itemButtonClicked(button: CYLIndexPathButton) {}

    /**
     * `-confirmButtonClicked:`: closes the panel, then tells the delegate.
     */
    open fun confirmButtonClicked(sender: Any?) {
        close { delegate?.filterControllerDidComplete(this) }
    }

    /**
     * `-restoreButtonClicked:`: closes like Apply (a subclass resets first).
     */
    open fun restoreButtonClicked(sender: Any?) = confirmButtonClicked(null)

    /**
     * Whether the panel is on screen.
     */
    val isShowing: Boolean get() = root?.parent != null
}

/**
 * `CYLMultipleFilterController`: the multiple-choice filter: sections of items from a `CYLMenuDataSource`, one or
 * more selected per section, an exclusive item ("All") selected alone; Apply reports the selection to the delegate,
 * Reset selects the defaults again.
 */
open class CYLMultipleFilterController : CYLFilterBaseController() {
    var menuDataSource: CYLMenuDataSource? = null
    var menuDelegate: CYLMenuDelegate? = null

    private val filterParamsTool = CYLFilterParamsTool()
    private var content: FilterContent? = null

    override fun buildContent(container: ViewGroup) {
        val content = FilterContent(container.context)
        container.addView(content, ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT))
        this.content = content
        if (filterParamsTool.dataSources.isEmpty()) reloadMenuData() else content.rebuild()
    }

    /**
     * `-refreshFilterParams`: shows the current selection again.
     */
    fun refreshFilterParams() {
        content?.rebuild()
    }

    /**
     * `-reloadMenuData`: reads the data source again; each section selects its first exclusive item.
     */
    fun reloadMenuData() {
        val source = menuDataSource
        val sections = ArrayList<List<String>>()
        val selected = ArrayList<MutableList<Boolean>>()
        for (section in 0 until (source?.numberOfSectionsInMenu() ?: 0)) {
            val items = ArrayList<String>()
            val states = ArrayList<Boolean>()
            var selectedExclusive = false
            for (item in 0 until source!!.menuNumberOfItemsInSection(section)) {
                val indexPath = CYLIndexPath(item, section)
                items.add(source.menuTitleForItemAtIndexPath(indexPath))
                val exclusive = source.menuItemIsExclusiveAtIndexPath(indexPath)
                states.add(exclusive && !selectedExclusive)
                selectedExclusive = selectedExclusive || exclusive
            }
            sections.add(items)
            selected.add(states)
        }
        filterParamsTool.dataSources = sections
        filterParamsTool.filterParamsArray = selected
        content?.rebuild()
    }

    /**
     * `-selectedIndexPaths`.
     */
    fun selectedIndexPaths(): List<CYLIndexPath> = filterParamsTool.filterParamsArray.flatMapIndexed { section, states ->
        states.mapIndexedNotNull { item, value -> if (value) CYLIndexPath(item, section) else null }
    }

    /**
     * `-setSelectedIndexPaths:`: throws for an invalid item, or an exclusive item selected with another in its section.
     */
    fun setSelectedIndexPaths(indexPaths: List<CYLIndexPath>) {
        if (filterParamsTool.dataSources.isEmpty()) reloadMenuData()
        val exclusiveSections = HashSet<Int>()
        val otherSections = HashSet<Int>()
        for (path in indexPaths) {
            require(path.section in filterParamsTool.dataSources.indices && path.item in filterParamsTool.dataSources[path.section].indices) { "Invalid menu selection: $path" }
            val exclusive = menuDataSource?.menuItemIsExclusiveAtIndexPath(path) == true
            require(!((exclusive && (path.section in exclusiveSections || path.section in otherSections)) || (!exclusive && path.section in exclusiveSections))) {
                "Exclusive selection conflicts in section ${path.section}"
            }
            (if (exclusive) exclusiveSections else otherSections).add(path.section)
        }
        filterParamsTool.filterParamsArray.forEach { section -> section.indices.forEach { section[it] = false } }
        indexPaths.forEach { filterParamsTool.filterParamsArray[it.section][it.item] = true }
        content?.rebuild()
    }

    override fun confirmButtonClicked(sender: Any?) {
        menuDelegate?.menuDidConfirmSelectedItems(this, selectedIndexPaths())
        super.confirmButtonClicked(sender)
    }

    override fun restoreButtonClicked(sender: Any?) {
        reloadMenuData()
        confirmButtonClicked(sender)
    }

    /**
     * Selects or deselects an item as a tap does (the collection view's `didSelectItemAtIndexPath:`).
     */
    fun selectItemAtIndexPath(indexPath: CYLIndexPath) {
        val setting = filterParamsTool.filterParamsArray.getOrNull(indexPath.section) ?: return
        if (indexPath.item !in setting.indices) return
        val source = menuDataSource
        val exclusive = source?.menuItemIsExclusiveAtIndexPath(indexPath) == true
        if (exclusive) {
            setting.indices.forEach { setting[it] = it == indexPath.item }
        } else {
            setting[indexPath.item] = !setting[indexPath.item]
            setting.indices.forEach { if (source?.menuItemIsExclusiveAtIndexPath(CYLIndexPath(it, indexPath.section)) == true) setting[it] = false }
            if (!setting.contains(true) && source != null) {
                setting.indices.firstOrNull { source.menuItemIsExclusiveAtIndexPath(CYLIndexPath(it, indexPath.section)) }?.let { setting[it] = true }
            }
        }
        content?.rebuild()
        menuDelegate?.menuDidSelectItemAtIndexPath(this, indexPath)
    }

    private inner class FilterContent(context: Context) : ViewGroup(context) {
        private val density: Float get() = resources.displayMetrics.density
        private fun px(dp: Float) = (dp * density).roundToInt()
        private val layout = CYLCollectionViewLeftAlignedLayout()
        private val insets = CYLEdgeInsets(12f, 50f, 15f, 5f)
        private val frames = LinkedHashMap<View, CYLRect>()
        private val headers = ArrayList<CYLMultipleFilterHeaderView>()
        private val cells = ArrayList<Pair<CYLIndexPath, CYLFilterCollectionCell>>()

        fun rebuild() {
            removeAllViews()
            headers.clear()
            cells.clear()
            val font = CYLTagTitleFontForTraitCollection(resources.configuration.fontScale)
            filterParamsTool.dataSources.forEachIndexed { section, items ->
                val header = CYLMultipleFilterHeaderView(context)
                header.titleLabel.text = menuDataSource?.menuTitleForSection(section)
                headers.add(header)
                addView(header)
                items.forEachIndexed { item, text ->
                    val indexPath = CYLIndexPath(item, section)
                    val cell = CYLFilterCollectionCell(context)
                    cell.titleButton.text = text
                    cell.titleButton.setTextSize(TypedValue.COMPLEX_UNIT_DIP, font.size)
                    cell.titleButton.isSelected = filterParamsTool.filterParamsArray.getOrNull(section)?.getOrNull(item) == true
                    cell.titleButton.section = section
                    cell.titleButton.row = item
                    cell.contentDescription = text
                    CYLAccessibilityNode.apply(cell, true, cell.titleButton.isSelected, null, emptyList())
                    cell.setOnClickListener {
                        itemButtonClicked(cell.titleButton)
                        selectItemAtIndexPath(indexPath)
                    }
                    cells.add(indexPath to cell)
                    addView(cell)
                }
            }
            requestLayout()
        }

        override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
            val widthPx = MeasureSpec.getSize(widthMeasureSpec)
            val width = widthPx / density
            val font = CYLTagTitleFontForTraitCollection(resources.configuration.fontScale)
            val limit = max(0f, width - insets.left - insets.right)
            frames.clear()
            var y = 50f
            filterParamsTool.dataSources.forEachIndexed { section, items ->
                headers.getOrNull(section)?.let { frames[it] = CYLRect(0f, y, width, 38f) }
                y += 38f
                val sectionCells = cells.filter { it.first.section == section }
                val sizes = sectionCells.map { (indexPath, _) ->
                    CYLSize(min(ceil(CYLTagButton.textWidth(items[indexPath.item], font)) + 16, limit), CYLTagHeightForFont(font, 30f))
                }
                val (itemFrames, bottom) = layout.frames(sizes, y, width, insets, 12f, 10f)
                sectionCells.forEachIndexed { index, (_, cell) -> frames[cell] = itemFrames[index] }
                y = (if (sizes.isEmpty()) y + insets.top else bottom) + insets.bottom
            }
            for ((view, frame) in frames) view.measure(MeasureSpec.makeMeasureSpec(px(frame.width), MeasureSpec.EXACTLY), MeasureSpec.makeMeasureSpec(px(frame.height), MeasureSpec.EXACTLY))
            setMeasuredDimension(widthPx, px(y))
        }

        override fun onLayout(changed: Boolean, l: Int, t: Int, r: Int, b: Int) {
            for ((view, frame) in frames) view.layout(px(frame.x), px(frame.y), px(frame.maxX), px(frame.maxY))
        }
    }
}
