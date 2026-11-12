package com.cyl.classifymenu

import android.content.res.Resources
import android.graphics.Canvas
import android.graphics.ColorFilter
import android.graphics.Paint
import android.graphics.Path
import android.graphics.PixelFormat
import android.graphics.PorterDuff
import android.graphics.PorterDuffColorFilter
import android.graphics.drawable.Drawable

/**
 * The core's default icons, drawn in code (SF Symbols on iOS): the fold chevron ("chevron.down") and the plus of the
 * "+ New tag" item ("plus"). They draw in black and take the tint (`setColorFilter` / `setTint`) of the view.
 */
class CYLMenuIconDrawable(private val kind: Kind) : Drawable() {

    enum class Kind { CHEVRON_DOWN, PLUS }

    private val paint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        style = Paint.Style.STROKE
        strokeCap = Paint.Cap.ROUND
        strokeJoin = Paint.Join.ROUND
        color = android.graphics.Color.BLACK
    }
    private val path = Path()
    private val sizePx = (16 * Resources.getSystem().displayMetrics.density).toInt()

    override fun draw(canvas: Canvas) {
        val b = bounds
        val w = b.width().toFloat()
        val h = b.height().toFloat()
        paint.strokeWidth = maxOf(1f, minOf(w, h) * 0.11f)
        path.reset()
        when (kind) {
            Kind.CHEVRON_DOWN -> {
                path.moveTo(b.left + w * 0.2f, b.top + h * 0.38f)
                path.lineTo(b.left + w * 0.5f, b.top + h * 0.66f)
                path.lineTo(b.left + w * 0.8f, b.top + h * 0.38f)
            }
            Kind.PLUS -> {
                path.moveTo(b.left + w * 0.5f, b.top + h * 0.18f)
                path.lineTo(b.left + w * 0.5f, b.top + h * 0.82f)
                path.moveTo(b.left + w * 0.18f, b.top + h * 0.5f)
                path.lineTo(b.left + w * 0.82f, b.top + h * 0.5f)
            }
        }
        canvas.drawPath(path, paint)
    }

    override fun getIntrinsicWidth(): Int = sizePx

    override fun getIntrinsicHeight(): Int = sizePx

    override fun setAlpha(alpha: Int) {
        paint.alpha = alpha
    }

    override fun setColorFilter(colorFilter: ColorFilter?) {
        paint.colorFilter = colorFilter
    }

    override fun setTint(tintColor: Int) {
        paint.colorFilter = PorterDuffColorFilter(tintColor, PorterDuff.Mode.SRC_IN)
    }

    @Deprecated("Deprecated in Java")
    override fun getOpacity(): Int = PixelFormat.TRANSLUCENT
}
