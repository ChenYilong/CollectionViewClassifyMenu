package com.cyl.classifymenu

import android.animation.ValueAnimator
import android.content.Context
import android.graphics.Canvas
import android.graphics.Paint
import android.graphics.drawable.Drawable
import android.net.Uri
import android.util.AttributeSet
import android.view.MotionEvent
import android.view.View
import android.view.ViewGroup
import android.view.animation.DecelerateInterpolator
import kotlin.math.hypot
import kotlin.math.max
import kotlin.math.roundToInt

/**
 * `CYLTagListCell`: the cell of a tag in a `CYLTagListView`: a `CYLTagButton` filling it, a delete control over the
 * button's delete indicator, the touch ripple of the style (AndroidTagView), and the tag's accessibility: its title,
 * the badge as its value, selected / not enabled, and the delete action.
 */
open class CYLTagListCell @JvmOverloads constructor(context: Context, attrs: AttributeSet? = null) : ViewGroup(context, attrs) {

    val button: CYLTagButton = CYLTagButton(context).apply {
        isClickable = false
        isFocusable = false
        importantForAccessibility = IMPORTANT_FOR_ACCESSIBILITY_NO_HIDE_DESCENDANTS
    }
    private val deleteControl = View(context).apply {
        visibility = GONE
        cyl_accessibilityIdentifier = CYLTagListDeleteAccessibilityIdentifier
        importantForAccessibility = IMPORTANT_FOR_ACCESSIBILITY_NO
        setOnClickListener { delete() }
    }
    private val ripplePaint = Paint(Paint.ANTI_ALIAS_FLAG)
    private var rippleX = 0f
    private var rippleY = 0f
    private var rippleRadius = 0f
    private var rippleAnimator: ValueAnimator? = null

    /** The style last applied to `button` (held weakly on iOS: compared by identity only). */
    var appliedStyle: CYLMenuStyle? = null

    var deletable: Boolean = false
        set(value) {
            field = value
            button.showsDeleteIndicator = value
            deleteControl.visibility = if (value) VISIBLE else GONE
            updateAccessibility()
            requestLayout()
        }

    var deleteHandler: (() -> Unit)? = null

    var additionalAccessibilityActions: List<CYLAccessibilityAction>? = null
        set(value) {
            field = value?.toList()
            updateAccessibility()
        }

    private var accessibilityHintText: String? = null
    private var selectedForAccessibility: Boolean = false

    init {
        addView(button)
        addView(deleteControl)
        importantForAccessibility = IMPORTANT_FOR_ACCESSIBILITY_YES
        isFocusable = true
        setWillNotDraw(false)
        updateAccessibility()
    }

    /** `accessibilityHint` of the cell. */
    var accessibilityHint: String?
        get() = accessibilityHintText
        set(value) {
            accessibilityHintText = value
            updateAccessibility()
        }

    override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
        button.measure(widthMeasureSpec, heightMeasureSpec)
        setMeasuredDimension(resolveSize(button.measuredWidth, widthMeasureSpec), resolveSize(button.measuredHeight, heightMeasureSpec))
        button.measure(MeasureSpec.makeMeasureSpec(measuredWidth, MeasureSpec.EXACTLY), MeasureSpec.makeMeasureSpec(measuredHeight, MeasureSpec.EXACTLY))
        deleteControl.measure(MeasureSpec.makeMeasureSpec(0, MeasureSpec.UNSPECIFIED), MeasureSpec.makeMeasureSpec(0, MeasureSpec.UNSPECIFIED))
    }

    override fun onLayout(changed: Boolean, l: Int, t: Int, r: Int, b: Int) {
        button.layout(0, 0, r - l, b - t)
        val density = resources.displayMetrics.density
        val hit = if (deletable) button.deleteIndicatorHitFrame else CYLRect()
        deleteControl.layout((hit.x * density).roundToInt(), (hit.y * density).roundToInt(), (hit.maxX * density).roundToInt(), (hit.maxY * density).roundToInt())
    }

    override fun onTouchEvent(event: MotionEvent): Boolean {
        if (event.actionMasked == MotionEvent.ACTION_DOWN) showRippleAtPoint(CYLPoint(event.x / resources.displayMetrics.density, event.y / resources.displayMetrics.density))
        return super.onTouchEvent(event)
    }

    override fun setPressed(pressed: Boolean) {
        super.setPressed(pressed)
        button.isPressed = pressed
    }

    /** `-showRippleAtPoint:`: the style's ripple from `point` (dp), unless there is no ripple color or Reduce Motion. */
    fun showRippleAtPoint(point: CYLPoint) {
        val style = button.style ?: return
        val color = style.rippleColor ?: return
        if (CYLAccessibility.isReduceMotionEnabled(context)) return
        val density = resources.displayMetrics.density
        rippleX = point.x * density
        rippleY = point.y * density
        val dx = max(rippleX, width - rippleX)
        val dy = max(rippleY, height - rippleY)
        val radius = hypot(dx, dy)
        rippleAnimator?.cancel()
        val startAlpha = (style.rippleAlpha.coerceIn(0f, 1f) * 255).roundToInt()
        rippleAnimator = ValueAnimator.ofFloat(0.05f, 1f).apply {
            duration = ((if (style.rippleDuration > 0) style.rippleDuration else 1.0) * 1000).toLong()
            interpolator = DecelerateInterpolator()
            addUpdateListener {
                val fraction = it.animatedValue as Float
                rippleRadius = radius * fraction
                ripplePaint.color = color
                ripplePaint.alpha = (startAlpha * (1 - it.animatedFraction)).roundToInt()
                invalidate()
            }
            start()
        }
    }

    override fun dispatchDraw(canvas: Canvas) {
        super.dispatchDraw(canvas)
        if (rippleAnimator?.isRunning == true && rippleRadius > 0) {
            canvas.save()
            canvas.clipRect(0, 0, width, height)
            canvas.drawCircle(rippleX, rippleY, rippleRadius, ripplePaint)
            canvas.restore()
        }
    }

    private fun delete() {
        deleteHandler?.invoke()
    }

    private fun updateAccessibility() {
        val actions = ArrayList<CYLAccessibilityAction>()
        if (deletable) actions.add(CYLAccessibilityAction(CYLMenuLocalizedString("CYLMenuDeleteTag", "Deletes a tag")) { delete(); true })
        additionalAccessibilityActions?.let { actions.addAll(it) }
        CYLAccessibilityNode.apply(this, true, selectedForAccessibility, accessibilityHintText, actions)
    }

    /** `-prepareForReuse`. */
    open fun prepareForReuse() {
        deleteHandler = null
        additionalAccessibilityActions = null
        deletable = false
    }

    /** `-configureWithTitle:image:selectedImage:animationURL:style:selected:enabled:`. */
    fun configureWithTitle(title: String, image: Drawable?, selectedImage: Drawable?, animationURL: Uri?, style: CYLMenuStyle, selected: Boolean, enabled: Boolean) {
        if (appliedStyle !== style) {
            button.style = style
            appliedStyle = style
        }
        button.animationURL = animationURL
        button.title = title
        button.image = image
        button.selectedImage = selectedImage
        button.isEnabled = enabled
        button.isSelected = selected
        val value = (image as? CYLBadgeDrawable)?.accessibilityLabel
        contentDescription = if (value.isNullOrEmpty()) title else "$title, $value"
        cyl_accessibilityIdentifier = CYLTagListItemAccessibilityIdentifier
        accessibilityHintText = null
        selectedForAccessibility = selected
        isEnabled = enabled
        updateAccessibility()
    }
}
