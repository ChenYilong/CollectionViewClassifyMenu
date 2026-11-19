package com.cyl.classifymenu

import android.graphics.Canvas
import android.graphics.ColorFilter
import android.graphics.Paint
import android.graphics.Path
import android.graphics.PixelFormat
import android.graphics.drawable.Drawable

/**
 * The two editing icons of a renamable tag in `CYLTagListView`'s editing mode (iOS draws SF Symbols "square.and.pencil"
 * and "xmark"): drawn strokes that fill their bounds, so the glyph is as large as the icon's slot. `color` is the
 * delete indicator's color.
 */
internal class CYLEditingIconDrawable(private val kind: Kind) : Drawable() {
    enum class Kind { Rename, Delete }

    var color: Int
        get() = paint.color
        set(value) {
            paint.color = value
            invalidateSelf()
        }

    private val paint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        style = Paint.Style.STROKE
        strokeCap = Paint.Cap.ROUND
        strokeJoin = Paint.Join.ROUND
    }
    private val path = Path()

    override fun draw(canvas: Canvas) {
        val b = bounds
        val side = minOf(b.width(), b.height()).toFloat()
        if (side <= 0f) return
        val x = b.exactCenterX() - side / 2
        val y = b.exactCenterY() - side / 2
        paint.strokeWidth = maxOf(1f, side * 0.1f)
        val inset = paint.strokeWidth / 2
        path.reset()
        when (kind) {
            Kind.Delete -> {
                path.moveTo(x + inset, y + inset)
                path.lineTo(x + side - inset, y + side - inset)
                path.moveTo(x + side - inset, y + inset)
                path.lineTo(x + inset, y + side - inset)
            }
            Kind.Rename -> {
                // A square open at the top right, and a pencil from its middle to that corner.
                val s = side - 2 * inset
                val left = x + inset
                val top = y + inset
                path.moveTo(left + s * 0.55f, top + s * 0.1f)
                path.lineTo(left, top + s * 0.1f)
                path.lineTo(left, top + s)
                path.lineTo(left + s * 0.9f, top + s)
                path.lineTo(left + s * 0.9f, top + s * 0.45f)
                path.moveTo(left + s * 0.35f, top + s * 0.65f)
                path.lineTo(left + s * 0.4f, top + s * 0.45f)
                path.lineTo(left + s * 0.85f, top)
                path.lineTo(left + s, top + s * 0.15f)
                path.lineTo(left + s * 0.55f, top + s * 0.6f)
                path.close()
            }
        }
        canvas.drawPath(path, paint)
    }

    override fun setAlpha(alpha: Int) {
        paint.alpha = alpha
        invalidateSelf()
    }

    override fun setColorFilter(colorFilter: ColorFilter?) {
        paint.colorFilter = colorFilter
        invalidateSelf()
    }

    @Deprecated("Deprecated in Android", ReplaceWith("PixelFormat.TRANSLUCENT", "android.graphics.PixelFormat"))
    override fun getOpacity(): Int = PixelFormat.TRANSLUCENT
}
