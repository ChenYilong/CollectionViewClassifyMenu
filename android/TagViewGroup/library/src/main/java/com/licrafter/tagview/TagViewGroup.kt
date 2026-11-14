package com.licrafter.tagview

import android.animation.Animator
import android.content.Context
import android.database.DataSetObserver
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.Path
import android.graphics.Point
import android.graphics.RectF
import android.util.AttributeSet
import android.util.Property
import android.view.GestureDetector
import android.view.MotionEvent
import android.view.View
import android.view.ViewGroup
import com.licrafter.tagview.utils.DipConvertUtils
import com.licrafter.tagview.utils.TagGroupUtils
import com.licrafter.tagview.views.ITagView
import com.licrafter.tagview.views.RippleView
import kotlin.math.hypot
import kotlin.math.max
import kotlin.math.min

/**
 * A group of tags attached to a point of a picture: a dot (outer and inner circle), lines from the dot to each tag,
 * and up to DEFAULT_MAX_TAG tags around it in the ten DIRECTION positions. The dot sits at `setPercent(x, y)` of the
 * view's size and moves inward when its tags would leave the view. Tags come from a TagAdapter. Taps on the dot or a
 * tag, long presses and drags of the dot are reported through the listeners.
 *
 * An API-compatible Kotlin reimplementation of shellljx/TagViewGroup (no code copied: the original is GPL-3.0).
 */
class TagViewGroup @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null,
    defStyleAttr: Int = 0,
) : ViewGroup(context, attrs, defStyleAttr) {

    /**
     * A tag the adapter made, with its position and the frame it was laid out in.
     */
    class ItemInfo {
        var item: ITagView? = null
        var position: Int = 0
        var rectF = RectF()
    }

    private val items = ArrayList<ItemInfo>()
    private val paint = Paint(Paint.ANTI_ALIAS_FLAG)
    private val linePath = Path()
    private var adapter: TagAdapter? = null
    private var showAnimator: Animator? = null
    private var hideAnimator: Animator? = null
    private var clickListener: OnTagGroupClickListener? = null
    private var dragListener: OnTagGroupDragListener? = null
    private val gestureDetector: GestureDetector
    private var dragging = false

    private var percentX = 0.5f
    private var percentY = 0.5f
    private var centerX = 0
    private var centerY = 0

    private var circleRadius: Int
    private var circleInnerRadius: Int
    private var lineWidth: Int
    private var vDistance: Int
    private var titlDistance: Int
    private var linesRatio = 1f
    private var tagAlpha = 1f

    private val observer = object : DataSetObserver() {
        override fun onChanged() {
            rebuildTags()
        }
    }

    init {
        val array = context.obtainStyledAttributes(attrs, R.styleable.TagViewGroup, defStyleAttr, 0)
        circleRadius = array.getDimensionPixelSize(R.styleable.TagViewGroup_radius, dp(DEFAULT_RADIUS))
        circleInnerRadius = array.getDimensionPixelSize(R.styleable.TagViewGroup_inner_radius, dp(DEFAULT_INNER_RADIUS))
        lineWidth = array.getDimensionPixelSize(R.styleable.TagViewGroup_line_width, dp(DEFAULT_LINES_WIDTH))
        vDistance = array.getDimensionPixelSize(R.styleable.TagViewGroup_v_distance, dp(DEFAULT_V_DISTANCE))
        titlDistance = array.getDimensionPixelSize(R.styleable.TagViewGroup_tilt_distance, dp(DEFAULT_TILT_DISTANCE))
        array.recycle()
        setWillNotDraw(false)
        clipChildren = false
        gestureDetector = GestureDetector(context, GestureListener())
    }

    private fun dp(value: Int): Int = DipConvertUtils.dip2px(context, value.toFloat())

    override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
        val width = MeasureSpec.getSize(widthMeasureSpec)
        // A tag never needs more than the width beside the dot.
        val childWidth = max(dp(44), width - 2 * circleRadius - titlDistance)
        for (info in items) {
            (info.item as? View)?.measure(
                MeasureSpec.makeMeasureSpec(childWidth, MeasureSpec.AT_MOST),
                MeasureSpec.makeMeasureSpec(0, MeasureSpec.UNSPECIFIED),
            )
        }
        val used = TagGroupUtils.getTagViewUsed(this)
        val rightAvailable = used[2]
        val leftAvailable = used[0]
        val wantedWidth = leftAvailable + rightAvailable
        val wantedHeight = used[1] + used[3]
        setMeasuredDimension(resolveSize(wantedWidth, widthMeasureSpec), resolveSize(wantedHeight, heightMeasureSpec))
    }

    override fun onLayout(changed: Boolean, l: Int, t: Int, r: Int, b: Int) {
        val width = r - l
        val height = b - t
        val used = TagGroupUtils.getTagViewUsed(this)
        var cx = (width * percentX).toInt()
        var cy = (height * percentY).toInt()
        // Keep the tags inside the view: move the dot inward.
        if (used[2] > width - cx) cx -= used[2] - (width - cx)
        if (used[0] > cx) cx += used[0] - cx
        if (used[3] > height - cy) cy -= used[3] - (height - cy)
        if (used[1] > cy) cy += used[1] - cy
        centerX = cx
        centerY = cy
        for (info in items) {
            val child = info.item ?: continue
            val point = TagGroupUtils.getStartPoint(this, child)
            child.layout(point.x, point.y, point.x + child.getMeasuredWidth(), point.y + child.getMeasuredHeight())
            info.rectF.set(point.x.toFloat(), point.y.toFloat(), (point.x + child.getMeasuredWidth()).toFloat(), (point.y + child.getMeasuredHeight()).toFloat())
        }
    }

    override fun dispatchDraw(canvas: Canvas) {
        // Lines from the dot to the bottom edge of each tag, drawn up to linesRatio of their length.
        paint.style = Paint.Style.STROKE
        paint.strokeWidth = lineWidth.toFloat()
        paint.color = Color.WHITE
        paint.alpha = 255
        for (info in items) {
            val child = info.item ?: continue
            if (child is RippleView) continue
            drawLine(canvas, child)
        }
        // The dot: a translucent outer circle and an opaque inner one.
        paint.style = Paint.Style.FILL
        paint.color = Color.argb(100, 0, 0, 0)
        canvas.drawCircle(centerX.toFloat(), centerY.toFloat(), circleRadius.toFloat(), paint)
        paint.color = Color.WHITE
        canvas.drawCircle(centerX.toFloat(), centerY.toFloat(), circleInnerRadius.toFloat(), paint)
        for (index in 0 until childCount) {
            val child = getChildAt(index)
            child.alpha = if (child is RippleView) 1f else tagAlpha
        }
        super.dispatchDraw(canvas)
    }

    private fun drawLine(canvas: Canvas, child: ITagView) {
        val left = child.getDirection().isLeft
        val center = child.getDirection() == DIRECTION.LEFT_CENTER || child.getDirection() == DIRECTION.RIGHT_CENTER
        val bottom = child.getBottom().toFloat()
        val near = if (left) child.getRight().toFloat() else child.getLeft().toFloat()
        val far = if (left) child.getLeft().toFloat() else child.getRight().toFloat()
        val points = ArrayList<Pair<Float, Float>>()
        points.add(centerX.toFloat() to centerY.toFloat())
        if (!center) points.add(near to bottom)
        points.add(far to bottom)
        var total = 0f
        for (i in 1 until points.size) total += hypot(points[i].first - points[i - 1].first, points[i].second - points[i - 1].second)
        var remaining = total * linesRatio
        linePath.reset()
        linePath.moveTo(points[0].first, points[0].second)
        for (i in 1 until points.size) {
            val (x0, y0) = points[i - 1]
            val (x1, y1) = points[i]
            val segment = hypot(x1 - x0, y1 - y0)
            if (segment <= 0f) continue
            if (remaining >= segment) {
                linePath.lineTo(x1, y1)
                remaining -= segment
            } else {
                val f = remaining / segment
                linePath.lineTo(x0 + (x1 - x0) * f, y0 + (y1 - y0) * f)
                break
            }
        }
        canvas.drawPath(linePath, paint)
    }

    /**
     * The tags the adapter made, in order (the ripple included when the adapter made one).
     */
    fun getTagList(): List<ITagView> {
        val list = ArrayList<ITagView>()
        for (info in items) info.item?.let { list.add(it) }
        return list
    }

    fun startShowAnimator() {
        hideAnimator?.cancel()
        showAnimator?.let {
            it.setTarget(this)
            it.start()
        }
    }

    fun startHideAnimator() {
        showAnimator?.cancel()
        hideAnimator?.let {
            it.setTarget(this)
            it.start()
        }
    }

    fun setShowAnimator(animator: Animator): TagViewGroup {
        showAnimator = animator
        return this
    }

    fun setHideAnimator(animator: Animator): TagViewGroup {
        hideAnimator = animator
        return this
    }

    fun setTagAdapter(adapter: TagAdapter) {
        this.adapter?.unregisterDataSetObserver(observer)
        this.adapter = adapter
        adapter.registerDataSetObserver(observer)
        rebuildTags()
    }

    fun getTagAdapter(): TagAdapter? = adapter

    private fun rebuildTags() {
        val adapter = this.adapter ?: return
        for (info in items) {
            info.item?.let { adapter.destroyItem(this, info.position, it) }
        }
        items.clear()
        val count = min(adapter.getCount(), DEFAULT_MAX_TAG)
        for (position in 0 until count) {
            val info = ItemInfo()
            info.position = position
            info.item = adapter.instantiateItem(this, position)
            items.add(info)
        }
        requestLayout()
        invalidate()
    }

    /**
     * Places the dot at (percentX, percentY) of the view's size (0...1 each).
     */
    fun setPercent(percentX: Float, percentY: Float) {
        this.percentX = percentX.coerceIn(0f, 1f)
        this.percentY = percentY.coerceIn(0f, 1f)
        requestLayout()
    }

    override fun onTouchEvent(event: MotionEvent?): Boolean {
        if (event == null) return false
        if (event.actionMasked == MotionEvent.ACTION_DOWN && !isOnCircle(event.x, event.y) && findTag(event.x, event.y) == null) {
            return false
        }
        val handled = gestureDetector.onTouchEvent(event)
        if (event.actionMasked == MotionEvent.ACTION_UP || event.actionMasked == MotionEvent.ACTION_CANCEL) {
            dragging = false
            parent?.requestDisallowInterceptTouchEvent(false)
        }
        return handled || dragging
    }

    private fun isOnCircle(x: Float, y: Float): Boolean = hypot(x - centerX, y - centerY) <= max(circleRadius, dp(22))

    private fun findTag(x: Float, y: Float): ItemInfo? = items.firstOrNull { it.item !is RippleView && it.rectF.contains(x, y) }

    fun setOnTagGroupClickListener(listener: OnTagGroupClickListener) {
        clickListener = listener
    }

    fun setOnTagGroupDragListener(listener: OnTagGroupDragListener) {
        dragListener = listener
    }

    interface OnTagGroupClickListener {
        fun onCircleClick(container: TagViewGroup)
        fun onTagClick(container: TagViewGroup, tag: ITagView, position: Int)
        fun onLongPress(container: TagViewGroup)
    }

    interface OnTagGroupDragListener {
        fun onDrag(container: TagViewGroup, percentX: Float, percentY: Float)
    }

    private inner class GestureListener : GestureDetector.SimpleOnGestureListener() {

        override fun onDown(e: MotionEvent): Boolean = true

        override fun onSingleTapUp(e: MotionEvent): Boolean {
            val x = e.x
            val y = e.y
            if (isOnCircle(x, y)) {
                clickListener?.onCircleClick(this@TagViewGroup)
                return true
            }
            val info = findTag(x, y) ?: return false
            info.item?.let { clickListener?.onTagClick(this@TagViewGroup, it, info.position) }
            return true
        }

        override fun onScroll(e1: MotionEvent?, e2: MotionEvent, distanceX: Float, distanceY: Float): Boolean {
            val listener = dragListener ?: return false
            if (e1 == null || (!dragging && !isOnCircle(e1.x, e1.y))) return false
            dragging = true
            parent?.requestDisallowInterceptTouchEvent(true)
            if (width <= 0 || height <= 0) return true
            val currentX = (centerX - distanceX) / width
            val currentY = (centerY - distanceY) / height
            setPercent(currentX, currentY)
            listener.onDrag(this@TagViewGroup, percentX, percentY)
            return true
        }

        override fun onLongPress(e: MotionEvent) {
            val x = e.x
            val y = e.y
            if (isOnCircle(x, y) || findTag(x, y) != null) {
                clickListener?.onLongPress(this@TagViewGroup)
            }
        }
    }

    fun getCenterPoint(): Point = Point(centerX, centerY)

    fun setCircleRadius(radius: Int) {
        circleRadius = radius
        invalidate()
    }

    fun getCircleRadius(): Int = circleRadius

    fun setCircleInnerRadius(innerRadius: Int) {
        circleInnerRadius = innerRadius
        invalidate()
    }

    fun getCircleInnerRadius(): Int = circleInnerRadius

    /**
     * How much of each line is drawn, 0...1 (animated by LINES_RATIO).
     */
    fun setLinesRatio(ratio: Float) {
        linesRatio = ratio
        invalidate()
    }

    fun getLinesRatio(): Float = linesRatio

    /**
     * The tags' alpha, 0...1 (animated by TAG_ALPHA); the dot and the ripple stay opaque.
     */
    fun setTagAlpha(alpha: Float) {
        tagAlpha = alpha
        invalidate()
    }

    fun getTagAlpha(): Float = tagAlpha

    fun setLineWidth(lineWidth: Int) {
        this.lineWidth = lineWidth
        invalidate()
    }

    fun getLineWidth(): Int = lineWidth

    fun setVDistance(vDistance: Int) {
        this.vDistance = vDistance
        requestLayout()
    }

    fun getVDistance(): Int = vDistance

    fun setTitlDistance(titlDistance: Int) {
        this.titlDistance = titlDistance
        requestLayout()
    }

    fun getTitlDistance(): Int = titlDistance

    companion object {
        /** The dot's outer radius, dp. */
        const val DEFAULT_RADIUS: Int = 8
        /** The dot's inner radius, dp. */
        const val DEFAULT_INNER_RADIUS: Int = 4
        /** The vertical line to a non-straight tag, dp. */
        const val DEFAULT_V_DISTANCE: Int = 28
        /** The diagonal line to a straight tag, dp. */
        const val DEFAULT_TILT_DISTANCE: Int = 20
        /** The lines' width, dp. */
        const val DEFAULT_LINES_WIDTH: Int = 1
        /** At most this many tags per group. */
        const val DEFAULT_MAX_TAG: Int = 6

        @JvmField
        val CIRCLE_RADIUS: Property<TagViewGroup, Int> = object : Property<TagViewGroup, Int>(Int::class.java, "circleRadius") {
            override fun get(obj: TagViewGroup): Int = obj.getCircleRadius()
            override fun set(obj: TagViewGroup, value: Int) = obj.setCircleRadius(value)
        }

        @JvmField
        val CIRCLE_INNER_RADIUS: Property<TagViewGroup, Int> = object : Property<TagViewGroup, Int>(Int::class.java, "circleInnerRadius") {
            override fun get(obj: TagViewGroup): Int = obj.getCircleInnerRadius()
            override fun set(obj: TagViewGroup, value: Int) = obj.setCircleInnerRadius(value)
        }

        @JvmField
        val LINES_RATIO: Property<TagViewGroup, Float> = object : Property<TagViewGroup, Float>(Float::class.java, "linesRatio") {
            override fun get(obj: TagViewGroup): Float = obj.getLinesRatio()
            override fun set(obj: TagViewGroup, value: Float) = obj.setLinesRatio(value)
        }

        @JvmField
        val TAG_ALPHA: Property<TagViewGroup, Float> = object : Property<TagViewGroup, Float>(Float::class.java, "tagAlpha") {
            override fun get(obj: TagViewGroup): Float = obj.getTagAlpha()
            override fun set(obj: TagViewGroup, value: Float) = obj.setTagAlpha(value)
        }
    }
}
