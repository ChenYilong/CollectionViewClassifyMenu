package com.cyl.classifymenu

import android.animation.ValueAnimator
import android.annotation.SuppressLint
import android.content.Context
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.Path
import android.graphics.PathMeasure
import android.util.AttributeSet
import android.util.TypedValue
import android.view.GestureDetector
import android.view.Gravity
import android.view.MotionEvent
import android.view.View
import android.view.ViewGroup
import android.view.animation.LinearInterpolator
import android.widget.TextView
import kotlin.math.ceil
import kotlin.math.floor
import kotlin.math.hypot
import kotlin.math.max
import kotlin.math.min
import kotlin.math.roundToInt

/**
 * `CYLImageTagDirection`: where a tag sits around its group's dot (TagViewGroup's DIRECTION).
 */
enum class CYLImageTagDirection {
    CYLImageTagDirectionLeftCenter,
    CYLImageTagDirectionLeftTop,
    CYLImageTagDirectionLeftTopStraight,
    CYLImageTagDirectionLeftBottom,
    CYLImageTagDirectionLeftBottomStraight,
    CYLImageTagDirectionRightCenter,
    CYLImageTagDirectionRightTop,
    CYLImageTagDirectionRightTopStraight,
    CYLImageTagDirectionRightBottom,
    CYLImageTagDirectionRightBottomStraight,
    CYLImageTagDirectionCenter,
}

/**
 * `CYLImageTagDirectionNext`: the next direction, the last one (and Center) wrapping to LeftCenter.
 */
fun CYLImageTagDirectionNext(direction: CYLImageTagDirection): CYLImageTagDirection {
    if (direction >= CYLImageTagDirection.CYLImageTagDirectionRightBottomStraight) return CYLImageTagDirection.CYLImageTagDirectionLeftCenter
    return CYLImageTagDirection.values()[direction.ordinal + 1]
}

private fun CYLImageTagDirection.isLeft(): Boolean = this <= CYLImageTagDirection.CYLImageTagDirectionLeftBottomStraight

/**
 * The default radius of a group's dot, dp.
 */
const val CYLImageTagGroupDefaultCircleRadius = 8f
/**
 * The default radius of the dot's center, dp.
 */
const val CYLImageTagGroupDefaultCircleInnerRadius = 4f
/**
 * The default vertical distance of a tag from the dot, dp.
 */
const val CYLImageTagGroupDefaultVerticalDistance = 28f
/**
 * The default distance of a slanted ("straight") tag, dp.
 */
const val CYLImageTagGroupDefaultTiltDistance = 20f
/**
 * The default width of the lines, dp.
 */
const val CYLImageTagGroupDefaultLineWidth = 1f
/**
 * At most this many tags in a group.
 */
const val CYLImageTagGroupMaximumTagCount = 6
/**
 * The default radius of the ripple, dp.
 */
const val CYLImageTagGroupDefaultRippleMaxRadius = 20f
/**
 * Animation key of `circleRadius`.
 */
const val CYLImageTagGroupKeyCircleRadius = "circleRadius"
/**
 * Animation key of `circleInnerRadius`.
 */
const val CYLImageTagGroupKeyCircleInnerRadius = "circleInnerRadius"
/**
 * Animation key of `linesProgress`.
 */
const val CYLImageTagGroupKeyLinesProgress = "linesProgress"
/**
 * Animation key of `tagAlpha`.
 */
const val CYLImageTagGroupKeyTagAlpha = "tagAlpha"

/**
 * `CYLImageTagItem`: a view shown as a tag of a group.
 */
interface CYLImageTagItem {
    /**
     * Where the view sits around the dot.
     */
    var tagDirection: CYLImageTagDirection
}

/**
 * `CYLImageTag`: a tag of a picture: its title, direction, link and user info.
 */
class CYLImageTag(var title: String, var direction: CYLImageTagDirection) {
    /**
     * A link the tag opens, if any.
     */
    var link: String? = null
    /**
     * Anything the app attaches.
     */
    var userInfo: Any? = null

    /**
     * `-copy`.
     */
    fun copy(): CYLImageTag = CYLImageTag(title, direction).also {
        it.link = link
        it.userInfo = userInfo
    }

    companion object {
        /**
         * `+tagWithTitle:direction:`.
         */
        @JvmStatic
        fun tagWithTitle(title: String?, direction: CYLImageTagDirection) = CYLImageTag(title ?: "", direction)
    }
}

/**
 * `CYLImageTagGroup`: the tags around one dot, at a position given in fractions of the picture (0…1).
 */
class CYLImageTagGroup(var tags: List<CYLImageTag>, var percentPosition: CYLPoint) {
    /**
     * `-copy`: the tags are copied too.
     */
    fun copy(): CYLImageTagGroup = CYLImageTagGroup(tags.map { it.copy() }, percentPosition)

    companion object {
        /**
         * `+groupWithTags:percentPosition:`.
         */
        @JvmStatic
        fun groupWithTags(tags: List<CYLImageTag>?, percentPosition: CYLPoint) = CYLImageTagGroup(tags ?: emptyList(), percentPosition)

        /**
         * `+defaultDirectionsForTagCount:`: right first (top, center, bottom), then left, at most six.
         */
        @JvmStatic
        fun defaultDirectionsForTagCount(count: Int): List<CYLImageTagDirection> = when (count) {
            0 -> emptyList()
            1 -> listOf(CYLImageTagDirection.CYLImageTagDirectionRightCenter)
            2 -> listOf(CYLImageTagDirection.CYLImageTagDirectionRightTop, CYLImageTagDirection.CYLImageTagDirectionRightBottom)
            else -> listOf(CYLImageTagDirection.CYLImageTagDirectionRightTop, CYLImageTagDirection.CYLImageTagDirectionRightCenter,
                CYLImageTagDirection.CYLImageTagDirectionRightBottom, CYLImageTagDirection.CYLImageTagDirectionLeftTop,
                CYLImageTagDirection.CYLImageTagDirectionLeftCenter, CYLImageTagDirection.CYLImageTagDirectionLeftBottom)
                .take(min(count, CYLImageTagGroupMaximumTagCount))
        }
    }
}

/**
 * `CYLImageTagLabel`: the default tag view: white 13 sp text with a shadow, inside `contentInsets`.
 */
class CYLImageTagLabel @JvmOverloads constructor(context: Context, attrs: AttributeSet? = null) : TextView(context, attrs), CYLImageTagItem {
    override var tagDirection: CYLImageTagDirection = CYLImageTagDirection.CYLImageTagDirectionRightCenter

    /**
     * The space around the text, dp (4, 12, 4, 12 by default).
     */
    var contentInsets: CYLEdgeInsets = CYLEdgeInsets(4f, 12f, 4f, 12f)
        set(value) {
            field = value
            applyInsets()
        }

    init {
        setTextColor(Color.WHITE)
        setTextSize(TypedValue.COMPLEX_UNIT_SP, 13f)
        setShadowLayer(3.5f * resources.displayMetrics.density, 0f, 0f, Color.BLACK)
        gravity = Gravity.CENTER_VERTICAL
        importantForAccessibility = IMPORTANT_FOR_ACCESSIBILITY_YES
        CYLAccessibilityNode.apply(this, true, null, null, emptyList())
        applyInsets()
    }

    private fun applyInsets() {
        val d = resources.displayMetrics.density
        setPadding((contentInsets.left * d).roundToInt(), (contentInsets.top * d).roundToInt(), (contentInsets.right * d).roundToInt(), (contentInsets.bottom * d).roundToInt())
    }
}

/**
 * `CYLImageTagRippleView`: a circle growing and fading from the dot, repeated every second (not with Reduce Motion).
 */
class CYLImageTagRippleView @JvmOverloads constructor(context: Context, attrs: AttributeSet? = null) : View(context, attrs), CYLImageTagItem {
    override var tagDirection: CYLImageTagDirection = CYLImageTagDirection.CYLImageTagDirectionCenter

    /**
     * The radius the ripple grows to, dp.
     */
    var maximumRadius: Float = CYLImageTagGroupDefaultRippleMaxRadius
        set(value) {
            field = value
            requestLayout()
        }

    /**
     * The opacity the ripple starts with (100 / 255 by default).
     */
    var startAlpha: Float = 100f / 255f

    /**
     * The ripple's color (white by default).
     */
    var color: Int = Color.WHITE
        set(value) {
            field = value
            invalidate()
        }

    private val paint = Paint(Paint.ANTI_ALIAS_FLAG)
    private var fraction = 0f
    private var animator: ValueAnimator? = null

    init {
        isClickable = false
        importantForAccessibility = IMPORTANT_FOR_ACCESSIBILITY_NO
    }

    override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
        val side = (2 * maximumRadius * resources.displayMetrics.density).roundToInt()
        setMeasuredDimension(side, side)
    }

    override fun onAttachedToWindow() {
        super.onAttachedToWindow()
        startAnimating()
    }

    override fun onDetachedFromWindow() {
        stopAnimating()
        super.onDetachedFromWindow()
    }

    /**
     * `-startAnimating`.
     */
    fun startAnimating() {
        if (CYLAccessibility.isReduceMotionEnabled(context)) return
        animator?.cancel()
        animator = ValueAnimator.ofFloat(0f, 1f).apply {
            duration = 1000
            repeatCount = ValueAnimator.INFINITE
            interpolator = LinearInterpolator()
            addUpdateListener {
                fraction = it.animatedValue as Float
                invalidate()
            }
            start()
        }
    }

    /**
     * `-stopAnimating`.
     */
    fun stopAnimating() {
        animator?.cancel()
        animator = null
        fraction = 0f
        invalidate()
    }

    /**
     * Whether the ripple is animating.
     */
    val isAnimating: Boolean get() = animator?.isRunning == true

    override fun onDraw(canvas: Canvas) {
        if (animator == null) return
        paint.color = color
        paint.alpha = (startAlpha * (1 - fraction) * 255).roundToInt().coerceIn(0, 255)
        canvas.drawCircle(width / 2f, height / 2f, min(width, height) / 2f * fraction, paint)
    }
}

/**
 * `CYLImageTagGroupViewDataSource`: custom tag views instead of `tags`.
 */
interface CYLImageTagGroupViewDataSource {
    /**
     * The number of tags (at most `CYLImageTagGroupMaximumTagCount` are shown).
     */
    fun numberOfTagsInGroupView(groupView: CYLImageTagGroupView): Int

    /**
     * The view of a tag.
     */
    fun groupViewViewForTagAtIndex(groupView: CYLImageTagGroupView, index: Int): View?
}

/**
 * `CYLImageTagGroupViewDelegate`: taps, long press and drags of a group; every method is optional.
 */
interface CYLImageTagGroupViewDelegate {
    /**
     * `-groupViewDidTapCircle:`.
     */
    fun groupViewDidTapCircle(groupView: CYLImageTagGroupView) {}

    /**
     * `-groupView:didTapTagAtIndex:`.
     */
    fun groupViewDidTapTagAtIndex(groupView: CYLImageTagGroupView, index: Int) {}

    /**
     * `-groupViewDidLongPress:`.
     */
    fun groupViewDidLongPress(groupView: CYLImageTagGroupView) {}

    /**
     * `-groupView:didDragToPercentPosition:`.
     */
    fun groupViewDidDragToPercentPosition(groupView: CYLImageTagGroupView, percentPosition: CYLPoint) {}

    /**
     * Whether `groupViewDidLongPress` is implemented (respondsToSelector on iOS).
     */
    fun handlesLongPress(): Boolean = false
}

/**
 * `CYLImageTagGroupView`: a dot on a picture with up to six tags around it, joined by lines (TagViewGroup): position in
 * fractions of the view, ripple, show / hide animations, tap, long press and drag, and accessibility (the dot is an
 * element with move actions). Lengths are dp.
 */
@SuppressLint("ClickableViewAccessibility")
class CYLImageTagGroupView @JvmOverloads constructor(context: Context, attrs: AttributeSet? = null) : ViewGroup(context, attrs) {

    private val density: Float get() = resources.displayMetrics.density
    private fun px(dp: Float): Int = (dp * density).roundToInt()

    var circleRadius: Float = CYLImageTagGroupDefaultCircleRadius
        set(value) { field = max(0f, value); requestLayout(); invalidate() }
    var circleInnerRadius: Float = CYLImageTagGroupDefaultCircleInnerRadius
        set(value) { field = max(0f, value); invalidate() }
    var lineWidth: Float = CYLImageTagGroupDefaultLineWidth
        set(value) { field = max(0f, value); invalidate() }
    var verticalDistance: Float = CYLImageTagGroupDefaultVerticalDistance
        set(value) { field = max(0f, value); requestLayout() }
    var tiltDistance: Float = CYLImageTagGroupDefaultTiltDistance
        set(value) { field = max(0f, value); requestLayout() }
    var circleColor: Int = Color.argb(0x30, 0, 0, 0)
        set(value) { field = value; invalidate() }
    var circleInnerColor: Int = Color.WHITE
        set(value) { field = value; invalidate() }
    var lineColor: Int = Color.WHITE
        set(value) { field = value; invalidate() }

    /**
     * The dot's position in fractions of the view, each clamped to 0…1.
     */
    var percentPosition: CYLPoint = CYLPoint(0.5f, 0.5f)
        set(value) {
            field = CYLPoint(value.x.coerceIn(0f, 1f), value.y.coerceIn(0f, 1f))
            requestLayout()
        }

    /**
     * `-setPercentX:percentY:`.
     */
    fun setPercentX(percentX: Float, percentY: Float) {
        percentPosition = CYLPoint(percentX, percentY)
    }

    /**
     * The dot's center after layout, dp.
     */
    var centerPoint: CYLPoint = CYLPoint()
        private set

    /**
     * An offset added to the dot (the picture view moves groups apart with it), dp.
     */
    var displayOffset: CYLPoint = CYLPoint()
        set(value) {
            if (field == value) return
            field = value
            requestLayout()
        }

    private val frames = HashMap<View, CYLRect>()

    /**
     * The dot and the tags' frames together, dp.
     */
    val occupiedFrame: CYLRect
        get() {
            var minX = centerPoint.x - circleRadius
            var minY = centerPoint.y - circleRadius
            var maxX = centerPoint.x + circleRadius
            var maxY = centerPoint.y + circleRadius
            for (view in itemViews) frames[view]?.let {
                minX = min(minX, it.x); minY = min(minY, it.y); maxX = max(maxX, it.maxX); maxY = max(maxY, it.maxY)
            }
            return CYLRect(minX, minY, maxX - minX, maxY - minY)
        }

    // MARK: Tags

    private val itemViews = ArrayList<View>()

    /**
     * The tags (a copy); setting them rebuilds the tag views.
     */
    var tags: List<CYLImageTag> = emptyList()
        set(value) {
            field = value.toList()
            reloadData()
        }

    var dataSource: CYLImageTagGroupViewDataSource? = null

    /**
     * The tag views, in order.
     */
    val tagViews: List<View> get() = itemViews.toList()

    /**
     * Called for every default label, to style it.
     */
    var tagLabelConfiguration: ((label: CYLImageTagLabel, tag: CYLImageTag) -> Unit)? = null

    /**
     * `-reloadData`: rebuilds the tag views from the data source or from `tags`.
     */
    fun reloadData() {
        itemViews.forEach { removeView(it) }
        itemViews.clear()
        val source = dataSource
        val count = source?.numberOfTagsInGroupView(this) ?: tags.size
        for (index in 0 until min(count, CYLImageTagGroupMaximumTagCount)) {
            val view: View = if (source != null) {
                source.groupViewViewForTagAtIndex(this, index) ?: continue
            } else {
                val tag = tags[index]
                CYLImageTagLabel(context).also { label ->
                    label.text = tag.title
                    label.contentDescription = tag.title
                    label.tagDirection = tag.direction
                    tagLabelConfiguration?.invoke(label, tag)
                }
            }
            view.alpha = tagAlpha
            tagAccessibilityHint?.let { CYLAccessibilityNode.apply(view, true, null, it, emptyList()) }
            addView(view)
            itemViews.add(view)
        }
        updateAccessibility()
        requestLayout()
    }

    // MARK: Ripple

    var showsRipple: Boolean = false
        set(value) {
            field = value
            if (value && rippleView == null) {
                rippleView = CYLImageTagRippleView(context).also { addView(it, 0) }
            } else if (!value) {
                rippleView?.let { removeView(it) }
                rippleView = null
            }
            rippleView?.maximumRadius = rippleMaxRadius
            rippleView?.startAlpha = rippleAlpha
            requestLayout()
        }

    var rippleMaxRadius: Float = CYLImageTagGroupDefaultRippleMaxRadius
        set(value) {
            field = max(0f, value)
            rippleView?.maximumRadius = field
            requestLayout()
        }

    var rippleAlpha: Float = 100f / 255f
        set(value) {
            field = value.coerceIn(0f, 1f)
            rippleView?.startAlpha = field
        }

    var rippleView: CYLImageTagRippleView? = null
        private set

    // MARK: Animation

    /**
     * How much of each line is drawn, 0…1.
     */
    var linesProgress: Float = 1f
        set(value) {
            field = value.coerceIn(0f, 1f)
            invalidate()
        }

    /**
     * The tags' opacity, 0…1.
     */
    var tagAlpha: Float = 1f
        set(value) {
            field = value.coerceIn(0f, 1f)
            itemViews.forEach { it.alpha = field }
        }

    private var animators = ArrayList<ValueAnimator>()

    private fun setValue(value: Float, key: String) {
        when (key) {
            CYLImageTagGroupKeyCircleRadius -> circleRadius = value
            CYLImageTagGroupKeyCircleInnerRadius -> circleInnerRadius = value
            CYLImageTagGroupKeyLinesProgress -> linesProgress = value
            CYLImageTagGroupKeyTagAlpha -> tagAlpha = value
        }
    }

    /**
     * `-animateValueForKey:values:duration:completion:`: animates one of the `CYLImageTagGroupKey…` values through
     * `values` (eased out); with Reduce Motion, or no duration, it jumps to the last value.
     */
    fun animateValueForKey(key: String, values: List<Float>, duration: Double, completion: (() -> Unit)?) {
        if (values.isEmpty() || duration <= 0 || CYLAccessibility.isReduceMotionEnabled(context)) {
            values.lastOrNull()?.let { setValue(it, key) }
            completion?.invoke()
            return
        }
        val animator = ValueAnimator.ofFloat(0f, 1f)
        animator.duration = (duration * 1000).toLong()
        animator.interpolator = LinearInterpolator()
        animator.addUpdateListener {
            val t = it.animatedValue as Float
            val eased = 1 - (1 - t) * (1 - t)
            val position = eased * (values.size - 1)
            val index = min(floor(position).toInt(), values.size - 1)
            val next = min(index + 1, values.size - 1)
            setValue(values[index] + (values[next] - values[index]) * (position - index), key)
        }
        animator.addListener(object : android.animation.AnimatorListenerAdapter() {
            private var cancelled = false
            override fun onAnimationCancel(animation: android.animation.Animator) { cancelled = true }
            override fun onAnimationEnd(animation: android.animation.Animator) {
                animators.remove(animator)
                if (!cancelled) {
                    setValue(values.last(), key)
                    completion?.invoke()
                }
            }
        })
        animators.add(animator)
        animator.start()
    }

    private fun bounceCircle(completion: () -> Unit) {
        val radius = circleRadius
        val inner = circleInnerRadius
        animateValueForKey(CYLImageTagGroupKeyCircleInnerRadius, listOf(max(0f, inner - 3), inner + 3, inner), 0.4, null)
        animateValueForKey(CYLImageTagGroupKeyCircleRadius, listOf(max(0f, radius - 3), radius + 3, radius), 0.4, completion)
    }

    /**
     * Whether the group is hidden by `hideAnimated`.
     */
    var isGroupHidden: Boolean = false
        private set

    /**
     * `groupHidden`.
     */
    val groupHidden: Boolean get() = isGroupHidden

    var showAnimation: ((groupView: CYLImageTagGroupView, completion: () -> Unit) -> Unit)? = null
    var hideAnimation: ((groupView: CYLImageTagGroupView, completion: () -> Unit) -> Unit)? = null

    /**
     * `-showAnimated:completion:`: the dot bounces, the lines draw, then the tags fade in.
     */
    fun showAnimated(animated: Boolean, completion: (() -> Unit)?) {
        isGroupHidden = false
        visibility = VISIBLE
        updateAccessibility()
        showAnimation?.let { if (animated) { it(this) { completion?.invoke() }; return } }
        if (!animated || CYLAccessibility.isReduceMotionEnabled(context)) {
            linesProgress = 1f
            tagAlpha = 1f
            completion?.invoke()
            return
        }
        linesProgress = 0f
        tagAlpha = 0f
        bounceCircle {
            animateValueForKey(CYLImageTagGroupKeyLinesProgress, listOf(0f, 1f), 0.3) {
                animateValueForKey(CYLImageTagGroupKeyTagAlpha, listOf(0f, 1f), 0.2, completion)
            }
        }
    }

    /**
     * `-hideAnimated:completion:`: the dot bounces, the tags fade and the lines retract, then the group hides.
     */
    fun hideAnimated(animated: Boolean, completion: (() -> Unit)?) {
        val finish: () -> Unit = {
            isGroupHidden = true
            visibility = GONE
            updateAccessibility()
            completion?.invoke()
        }
        hideAnimation?.let { if (animated) { it(this, finish); return } }
        if (!animated || CYLAccessibility.isReduceMotionEnabled(context)) {
            finish()
            return
        }
        bounceCircle {
            animateValueForKey(CYLImageTagGroupKeyTagAlpha, listOf(tagAlpha, 0f), 0.4, null)
            animateValueForKey(CYLImageTagGroupKeyLinesProgress, listOf(1f, 0f), 0.4, finish)
        }
    }

    // MARK: Interaction

    var delegate: CYLImageTagGroupViewDelegate? = null
        set(value) {
            field = value
            updateAccessibility()
        }

    var draggable: Boolean = false
        set(value) {
            field = value
            updateAccessibility()
        }

    /**
     * `isDraggable`.
     */
    val isDraggable: Boolean get() = draggable

    // MARK: Accessibility

    /**
     * The dot as an accessibility element ("Tag group: …"), with the long press and move actions.
     */
    val circleAccessibilityElement: View = View(context).apply {
        importantForAccessibility = IMPORTANT_FOR_ACCESSIBILITY_YES
        isFocusable = true
        setOnClickListener { delegate?.groupViewDidTapCircle(this@CYLImageTagGroupView) }
    }

    var longPressAccessibilityActionName: String? = null
        set(value) {
            field = value
            updateAccessibility()
        }

    var tagAccessibilityHint: String? = null
        set(value) {
            field = value
            itemViews.forEach { CYLAccessibilityNode.apply(it, true, null, value, emptyList()) }
        }

    /**
     * How far a move action moves the dot, in fractions of the view (0.05).
     */
    var accessibilityMoveStep: Float = 0.05f

    init {
        setWillNotDraw(false)
        clipChildren = false
        addView(circleAccessibilityElement)
        updateAccessibility()
    }

    private fun updateAccessibility() {
        val titles = itemViews.mapNotNull { view ->
            view.contentDescription?.toString()?.takeIf { it.isNotEmpty() } ?: (view as? TextView)?.text?.toString()?.takeIf { it.isNotEmpty() }
        }
        val joined = listFormat(titles)
        circleAccessibilityElement.contentDescription = String.format(CYLMenuLocalizedString("CYLImageTagGroup", "The dot of a tag group").replace("%@", "%s"), joined)
        val actions = ArrayList<CYLAccessibilityAction>()
        if (delegate?.handlesLongPress() == true) {
            val name = longPressAccessibilityActionName?.takeIf { it.isNotEmpty() } ?: CYLMenuLocalizedString("CYLMenuLongPress", "Does what a long press does")
            actions.add(CYLAccessibilityAction(name) { delegate?.groupViewDidLongPress(this); true })
        }
        if (draggable) {
            for ((key, dx, dy) in listOf(Triple("CYLImageTagMoveUp", 0, -1), Triple("CYLImageTagMoveDown", 0, 1),
                    Triple("CYLImageTagMoveLeft", -1, 0), Triple("CYLImageTagMoveRight", 1, 0))) {
                actions.add(CYLAccessibilityAction(CYLMenuLocalizedStringForKey(key)) { accessibilityMove(dx.toFloat(), dy.toFloat()) })
            }
        }
        circleAccessibilityElement.importantForAccessibility = if (isGroupHidden) IMPORTANT_FOR_ACCESSIBILITY_NO else IMPORTANT_FOR_ACCESSIBILITY_YES
        CYLAccessibilityNode.apply(circleAccessibilityElement, true, null, null, actions)
    }

    private fun listFormat(items: List<String>): String {
        if (items.size <= 1) return items.firstOrNull() ?: ""
        if (android.os.Build.VERSION.SDK_INT < 26) return items.joinToString(", ")
        val locale = java.util.Locale.forLanguageTag(CYLMenuResources.currentLanguage())
        return android.icu.text.ListFormatter.getInstance(locale).format(items)
    }

    private fun accessibilityMove(dx: Float, dy: Float): Boolean {
        val old = percentPosition
        percentPosition = CYLPoint(old.x + dx * accessibilityMoveStep, old.y + dy * accessibilityMoveStep)
        if (old == percentPosition) return false
        delegate?.groupViewDidDragToPercentPosition(this, percentPosition)
        post { circleAccessibilityElement.sendAccessibilityEvent(android.view.accessibility.AccessibilityEvent.TYPE_VIEW_FOCUSED) }
        return true
    }

    // MARK: Geometry (TagGroupUtils)

    private var layoutVerticalDistance = 0f
    private var layoutTiltDistance = 0f

    private fun itemSizes(): List<CYLSize> {
        val widthDp = max(44f, width / density - 2 * circleRadius - tiltDistance)
        return itemViews.map { view ->
            view.measure(MeasureSpec.makeMeasureSpec(px(widthDp), MeasureSpec.AT_MOST), MeasureSpec.makeMeasureSpec(0, MeasureSpec.UNSPECIFIED))
            CYLSize(ceil(view.measuredWidth / density), ceil(view.measuredHeight / density))
        }
    }

    private fun direction(view: View): CYLImageTagDirection = (view as? CYLImageTagItem)?.tagDirection ?: CYLImageTagDirection.CYLImageTagDirectionRightCenter

    private fun tagSpaceUsedForSizes(sizes: List<CYLSize>): CYLEdgeInsets {
        var left = circleRadius
        var top = circleRadius
        var right = circleRadius
        var bottom = circleRadius
        val tallest = sizes.maxOfOrNull { it.height } ?: 0f
        val v = max(verticalDistance, tallest)
        val t = tiltDistance + (v - verticalDistance)
        layoutVerticalDistance = v
        layoutTiltDistance = t
        itemViews.forEachIndexed { index, view ->
            val size = sizes[index]
            when (direction(view)) {
                CYLImageTagDirection.CYLImageTagDirectionRightTopStraight -> { right = max(right, t + size.width); top = max(top, size.height + t) }
                CYLImageTagDirection.CYLImageTagDirectionRightTop -> { right = max(right, size.width); top = max(top, size.height + v) }
                CYLImageTagDirection.CYLImageTagDirectionRightCenter -> { right = max(right, size.width); top = max(top, max(v, size.height)) }
                CYLImageTagDirection.CYLImageTagDirectionRightBottom -> { right = max(right, size.width); bottom = max(bottom, v) }
                CYLImageTagDirection.CYLImageTagDirectionRightBottomStraight -> { right = max(right, t + size.width); bottom = max(bottom, t) }
                CYLImageTagDirection.CYLImageTagDirectionLeftTop -> { left = max(left, size.width); top = max(top, size.height + v) }
                CYLImageTagDirection.CYLImageTagDirectionLeftTopStraight -> { left = max(left, size.width + t); top = max(top, size.height + t) }
                CYLImageTagDirection.CYLImageTagDirectionLeftCenter -> { left = max(left, size.width); top = max(top, max(v, size.height)) }
                CYLImageTagDirection.CYLImageTagDirectionLeftBottom -> { left = max(left, size.width); bottom = max(bottom, v) }
                CYLImageTagDirection.CYLImageTagDirectionLeftBottomStraight -> { left = max(left, size.width + t); bottom = max(bottom, t) }
                CYLImageTagDirection.CYLImageTagDirectionCenter -> { left = max(left, size.width / 2); bottom = max(bottom, size.height / 2) }
            }
        }
        return CYLEdgeInsets(top, left, bottom, right)
    }

    /**
     * `-tagSpaceUsed`: how far the tags reach from the dot on each side, dp.
     */
    fun tagSpaceUsed(): CYLEdgeInsets = tagSpaceUsedForSizes(itemSizes())

    /**
     * `-originForTagOfSize:direction:`: the top-left corner of a tag of `size` in `direction`, dp.
     */
    fun originForTagOfSize(size: CYLSize, direction: CYLImageTagDirection): CYLPoint {
        val cx = centerPoint.x
        val cy = centerPoint.y
        val v = max(verticalDistance, layoutVerticalDistance)
        val t = max(tiltDistance, layoutTiltDistance)
        return when (direction) {
            CYLImageTagDirection.CYLImageTagDirectionRightTopStraight -> CYLPoint(cx + t, cy - t - size.height)
            CYLImageTagDirection.CYLImageTagDirectionRightTop -> CYLPoint(cx, cy - v - size.height)
            CYLImageTagDirection.CYLImageTagDirectionRightCenter -> CYLPoint(cx, cy - size.height)
            CYLImageTagDirection.CYLImageTagDirectionRightBottom -> CYLPoint(cx, cy + v - size.height)
            CYLImageTagDirection.CYLImageTagDirectionRightBottomStraight -> CYLPoint(cx + t, cy + t - size.height)
            CYLImageTagDirection.CYLImageTagDirectionLeftTop -> CYLPoint(cx - size.width, cy - v - size.height)
            CYLImageTagDirection.CYLImageTagDirectionLeftTopStraight -> CYLPoint(cx - size.width - t, cy - t - size.height)
            CYLImageTagDirection.CYLImageTagDirectionLeftCenter -> CYLPoint(cx - size.width, cy - size.height)
            CYLImageTagDirection.CYLImageTagDirectionLeftBottom -> CYLPoint(cx - size.width, cy + v - size.height)
            CYLImageTagDirection.CYLImageTagDirectionLeftBottomStraight -> CYLPoint(cx - size.width - t, cy + t - size.height)
            CYLImageTagDirection.CYLImageTagDirectionCenter -> CYLPoint(cx - size.width / 2, cy - size.height / 2)
        }
    }

    // MARK: Layout and drawing

    override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
        setMeasuredDimension(MeasureSpec.getSize(widthMeasureSpec), MeasureSpec.getSize(heightMeasureSpec))
    }

    override fun onLayout(changed: Boolean, l: Int, t: Int, r: Int, b: Int) {
        layoutGroup()
    }

    /**
     * Lays the dot and the tags out now (`-layoutIfNeeded` on iOS); the picture view calls it to move groups apart.
     */
    fun layoutGroup() {
        val sizes = itemSizes()
        val used = tagSpaceUsedForSizes(sizes)
        val w = width / density
        val h = height / density
        var cx = w * percentPosition.x
        var cy = h * percentPosition.y
        if (used.right > w - cx) cx -= used.right - (w - cx)
        if (used.left > cx) cx += used.left - cx
        if (used.bottom > h - cy) cy -= used.bottom - (h - cy)
        if (used.top > cy) cy += used.top - cy
        centerPoint = CYLPoint(cx + displayOffset.x, cy + displayOffset.y)
        frames.clear()
        itemViews.forEachIndexed { index, view ->
            val size = sizes[index]
            val origin = originForTagOfSize(size, direction(view))
            val frame = CYLRect(origin.x, origin.y, size.width, size.height)
            frames[view] = frame
            view.measure(MeasureSpec.makeMeasureSpec(px(size.width), MeasureSpec.EXACTLY), MeasureSpec.makeMeasureSpec(px(size.height), MeasureSpec.EXACTLY))
            view.layout(px(frame.x), px(frame.y), px(frame.maxX), px(frame.maxY))
        }
        rippleView?.let {
            val side = 2 * rippleMaxRadius
            it.measure(MeasureSpec.makeMeasureSpec(px(side), MeasureSpec.EXACTLY), MeasureSpec.makeMeasureSpec(px(side), MeasureSpec.EXACTLY))
            it.layout(px(cx - side / 2), px(cy - side / 2), px(cx + side / 2), px(cy + side / 2))
        }
        val radius = max(circleRadius * 2, 22f)
        circleAccessibilityElement.layout(px(centerPoint.x - radius), px(centerPoint.y - radius), px(centerPoint.x + radius), px(centerPoint.y + radius))
        invalidate()
    }

    /**
     * The frame of a tag view after layout, dp.
     */
    fun frameOfTagView(view: View): CYLRect? = frames[view]

    private val linePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply { style = Paint.Style.STROKE }
    private val fillPaint = Paint(Paint.ANTI_ALIAS_FLAG)

    override fun dispatchDraw(canvas: Canvas) {
        linePaint.color = lineColor
        linePaint.strokeWidth = lineWidth * density
        val c = centerPoint
        for (view in itemViews) {
            val d = direction(view)
            if (d == CYLImageTagDirection.CYLImageTagDirectionCenter) continue
            val frame = frames[view] ?: continue
            val path = Path()
            path.moveTo(c.x * density, c.y * density)
            val left = d.isLeft()
            val center = d == CYLImageTagDirection.CYLImageTagDirectionLeftCenter || d == CYLImageTagDirection.CYLImageTagDirectionRightCenter
            if (!center) path.lineTo((if (left) frame.maxX else frame.x) * density, frame.maxY * density)
            path.lineTo((if (left) frame.x else frame.maxX) * density, frame.maxY * density)
            if (linesProgress >= 1f) {
                canvas.drawPath(path, linePaint)
            } else if (linesProgress > 0f) {
                val measure = PathMeasure(path, false)
                val partial = Path()
                var remaining = linesProgress * run {
                    var total = 0f
                    do { total += measure.length } while (measure.nextContour())
                    total
                }
                val again = PathMeasure(path, false)
                do {
                    val length = again.length
                    again.getSegment(0f, min(length, remaining), partial, true)
                    remaining -= length
                } while (remaining > 0 && again.nextContour())
                canvas.drawPath(partial, linePaint)
            }
        }
        fillPaint.color = circleColor
        canvas.drawCircle(c.x * density, c.y * density, circleRadius * density, fillPaint)
        fillPaint.color = circleInnerColor
        canvas.drawCircle(c.x * density, c.y * density, circleInnerRadius * density, fillPaint)
        super.dispatchDraw(canvas)
    }

    // MARK: Touches

    private var dragOffset = CYLPoint()
    private var dragging = false

    private fun isPointOnCircle(point: CYLPoint): Boolean = hypot(point.x - centerPoint.x, point.y - centerPoint.y) <= max(circleRadius * 2, 22f)

    private fun tagIndexAt(point: CYLPoint): Int = itemViews.indexOfFirst { view ->
        direction(view) != CYLImageTagDirection.CYLImageTagDirectionCenter && frames[view]?.let {
            point.x >= it.x && point.x <= it.maxX && point.y >= it.y && point.y <= it.maxY
        } == true
    }

    /**
     * `-pointInside:withEvent:`: only the dot and the tags take touches (dp).
     */
    fun pointInside(point: CYLPoint): Boolean = !isGroupHidden && (isPointOnCircle(point) || tagIndexAt(point) >= 0)

    private val gestures = GestureDetector(context, object : GestureDetector.SimpleOnGestureListener() {
        override fun onDown(e: MotionEvent): Boolean = true

        override fun onSingleTapUp(e: MotionEvent): Boolean {
            val index = tagIndexAt(CYLPoint(e.x / density, e.y / density))
            if (index >= 0) delegate?.groupViewDidTapTagAtIndex(this@CYLImageTagGroupView, index)
            else delegate?.groupViewDidTapCircle(this@CYLImageTagGroupView)
            return true
        }

        override fun onLongPress(e: MotionEvent) {
            if (!dragging) delegate?.groupViewDidLongPress(this@CYLImageTagGroupView)
        }
    })

    override fun dispatchTouchEvent(event: MotionEvent): Boolean {
        val point = CYLPoint(event.x / density, event.y / density)
        if (event.actionMasked == MotionEvent.ACTION_DOWN && !pointInside(point)) return false
        return onTouchEvent(event)
    }

    override fun onTouchEvent(event: MotionEvent): Boolean {
        val point = CYLPoint(event.x / density, event.y / density)
        when (event.actionMasked) {
            MotionEvent.ACTION_DOWN -> {
                dragOffset = CYLPoint(centerPoint.x - point.x, centerPoint.y - point.y)
                dragging = false
            }
            MotionEvent.ACTION_MOVE -> if (draggable) {
                if (!dragging && hypot(point.x + dragOffset.x - centerPoint.x, point.y + dragOffset.y - centerPoint.y) > 4) {
                    dragging = true
                    parent?.requestDisallowInterceptTouchEvent(true)
                }
                if (dragging) {
                    val w = max(1f, width / density)
                    val h = max(1f, height / density)
                    percentPosition = CYLPoint((point.x + dragOffset.x) / w, (point.y + dragOffset.y) / h)
                    layoutGroup()
                    delegate?.groupViewDidDragToPercentPosition(this, percentPosition)
                }
            }
        }
        if (dragging) {
            if (event.actionMasked == MotionEvent.ACTION_UP || event.actionMasked == MotionEvent.ACTION_CANCEL) dragging = false
            val cancel = MotionEvent.obtain(event).apply { action = MotionEvent.ACTION_CANCEL }
            gestures.onTouchEvent(cancel)
            cancel.recycle()
            return true
        }
        return gestures.onTouchEvent(event)
    }

    override fun onDetachedFromWindow() {
        animators.toList().forEach { it.cancel() }
        animators.clear()
        super.onDetachedFromWindow()
    }
}
