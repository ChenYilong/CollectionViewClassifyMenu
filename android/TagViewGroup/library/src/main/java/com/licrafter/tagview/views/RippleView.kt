package com.licrafter.tagview.views

import android.animation.Animator
import android.animation.AnimatorSet
import android.animation.ValueAnimator
import android.content.Context
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.provider.Settings
import android.util.AttributeSet
import android.view.View
import com.licrafter.tagview.DIRECTION
import com.licrafter.tagview.R
import com.licrafter.tagview.utils.DipConvertUtils

/**
 * The ripple that pulses around a TagViewGroup's dot: a filled circle that grows to the maximum radius while it
 * fades, repeated while the view is attached. The group centers it on the dot whatever its direction. Animations
 * stop when the system's animator scale is 0 (Remove animations).
 */
class RippleView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null,
    defStyleAttr: Int = 0,
) : View(context, attrs, defStyleAttr), ITagView {

    private val paint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        style = Paint.Style.FILL
        color = Color.WHITE
    }
    private var direction = DIRECTION.RIGHT_CENTER
    private var rippleRadius = 0
    private var rippleAlpha: Int
    private var startAlpha: Int
    private var rippleMaxRadius: Int
    private var animator: Animator? = null

    init {
        val array = context.obtainStyledAttributes(attrs, R.styleable.RippleView, defStyleAttr, 0)
        startAlpha = array.getInteger(R.styleable.RippleView_ripple_alpha, DEFULT_RIPPLE_ALPHA)
        rippleMaxRadius = array.getDimensionPixelSize(
            R.styleable.RippleView_ripple_maxRadius,
            DipConvertUtils.dip2px(context, DEFAULT_RIPPLE_MAX_RADIUS.toFloat()),
        )
        array.recycle()
        rippleAlpha = startAlpha
        importantForAccessibility = IMPORTANT_FOR_ACCESSIBILITY_NO
    }

    override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
        val side = rippleMaxRadius * 2
        setMeasuredDimension(side, side)
    }

    override fun onDraw(canvas: Canvas) {
        if (rippleRadius <= 0 || rippleAlpha <= 0) return
        paint.alpha = rippleAlpha
        canvas.drawCircle(width / 2f, height / 2f, rippleRadius.toFloat(), paint)
    }

    override fun onAttachedToWindow() {
        super.onAttachedToWindow()
        startRipple()
    }

    override fun onDetachedFromWindow() {
        animator?.cancel()
        animator = null
        super.onDetachedFromWindow()
    }

    fun setRippleRadius(radius: Int) {
        rippleRadius = radius
        invalidate()
    }

    fun setRippleAlpha(alpha: Int) {
        rippleAlpha = alpha
        invalidate()
    }

    fun getRippleAlpha(): Int = rippleAlpha

    fun setRippleMaxRadius(radius: Int) {
        rippleMaxRadius = radius
        requestLayout()
    }

    fun getRippleMaxRadius(): Int = rippleMaxRadius

    override fun getDirection(): DIRECTION = direction

    override fun setDirection(direction: DIRECTION) {
        this.direction = direction
    }

    private fun startRipple() {
        animator?.cancel()
        val scale = Settings.Global.getFloat(context.contentResolver, Settings.Global.ANIMATOR_DURATION_SCALE, 1f)
        if (scale == 0f) return
        val radiusAnimator = ValueAnimator.ofInt(0, rippleMaxRadius).apply {
            repeatCount = ValueAnimator.INFINITE
            addUpdateListener { setRippleRadius(it.animatedValue as Int) }
        }
        val alphaAnimator = ValueAnimator.ofInt(startAlpha, 0).apply {
            repeatCount = ValueAnimator.INFINITE
            addUpdateListener { setRippleAlpha(it.animatedValue as Int) }
        }
        animator = AnimatorSet().apply {
            duration = 1000
            playTogether(radiusAnimator, alphaAnimator)
            start()
        }
    }

    companion object {
        const val DEFAULT_RIPPLE_MAX_RADIUS: Int = 20
        const val DEFULT_RIPPLE_ALPHA: Int = 100
    }
}
