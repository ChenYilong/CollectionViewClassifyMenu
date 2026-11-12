package com.cyl.classifymenu

import android.content.res.ColorStateList
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Outline
import android.graphics.Paint
import android.graphics.PorterDuff
import android.graphics.PorterDuffXfermode
import android.graphics.drawable.ColorDrawable
import android.graphics.drawable.Drawable
import android.graphics.drawable.GradientDrawable
import android.graphics.drawable.StateListDrawable
import android.view.View
import android.view.ViewOutlineProvider
import android.widget.TextView
import kotlin.math.ceil
import kotlin.math.max
import kotlin.math.roundToInt

// `UIView (CYLGeneral)`: frame helpers in dp. On Android they move the view's laid-out frame (`layout(l, t, r, b)`), as
// the iOS methods set `frame`; the next layout pass of the parent places the view again.

private val View.density: Float get() = resources.displayMetrics.density
private fun View.px(dp: Float): Int = (dp * density).roundToInt()

/**
 * `-cyl_setWidth:`, dp.
 */
fun View.cyl_setWidth(width: Float) = layout(left, top, left + px(width), bottom)

/**
 * `-cyl_setHeight:`, dp.
 */
fun View.cyl_setHeight(height: Float) = layout(left, top, right, top + px(height))

/**
 * `-cyl_setX:`, dp.
 */
fun View.cyl_setX(x: Float) {
    val w = width
    layout(px(x), top, px(x) + w, bottom)
}

/**
 * `-cyl_setY:`, dp.
 */
fun View.cyl_setY(y: Float) {
    val h = height
    layout(left, px(y), right, px(y) + h)
}

/**
 * `-cyl_setSize:`, dp.
 */
fun View.cyl_setSize(size: CYLSize) = layout(left, top, left + px(size.width), top + px(size.height))

/**
 * `-cyl_height`, dp.
 */
fun View.cyl_height(): Float = height / density

/**
 * `-cyl_width`, dp.
 */
fun View.cyl_width(): Float = width / density

/**
 * `-cyl_x`, dp.
 */
fun View.cyl_x(): Float = left / density

/**
 * `-cyl_y`, dp.
 */
fun View.cyl_y(): Float = top / density

/**
 * `-cyl_maxY`, dp.
 */
fun View.cyl_maxY(): Float = bottom / density

/**
 * `-cyl_maxX`, dp.
 */
fun View.cyl_maxX(): Float = right / density

/**
 * `-cyl_horizontalCenterWithWidth:`: centers the view in `width` dp.
 */
fun View.cyl_horizontalCenterWithWidth(width: Float) = cyl_setX(ceil((width - cyl_width()) / 2))

/**
 * `-cyl_verticalCenterWithHeight:`: centers the view in `height` dp.
 */
fun View.cyl_verticalCenterWithHeight(height: Float) = cyl_setY(ceil((height - cyl_height()) / 2))

/**
 * `-cyl_verticalCenterInSuperView`.
 */
fun View.cyl_verticalCenterInSuperView() {
    (parent as? View)?.let { cyl_verticalCenterWithHeight(it.cyl_height()) }
}

/**
 * `-cyl_horizontalCenterInSuperView`.
 */
fun View.cyl_horizontalCenterInSuperView() {
    (parent as? View)?.let { cyl_horizontalCenterWithWidth(it.cyl_width()) }
}

private fun View.cyl_boxBackground(): GradientDrawable {
    (background as? GradientDrawable)?.let { return it }
    val box = GradientDrawable()
    (background as? ColorDrawable)?.let { box.setColor(it.color) }
    background = box
    return box
}

/**
 * `-cyl_setBorderWidth:color:`: a border of `width` dp in `color`.
 */
fun View.cyl_setBorderWidth(width: Float, color: Int) {
    cyl_boxBackground().setStroke(max(0, px(width)), color)
}

/**
 * `-cyl_setCornerRadius:`: rounds the view (and clips it) with `radius` dp.
 */
fun View.cyl_setCornerRadius(radius: Float) {
    cyl_boxBackground().cornerRadius = radius * density
    val r = radius * density
    outlineProvider = object : ViewOutlineProvider() {
        override fun getOutline(view: View, outline: Outline) = outline.setRoundRect(0, 0, view.width, view.height, r)
    }
    clipToOutline = radius > 0
}

/**
 * `-cyl_addSubLayerWithFrame:color:`: a colored rectangle drawn over the view (its overlay), at `frame` dp; change
 * its bounds later to move it, as iOS changes the layer's frame.
 */
fun View.cyl_addSubLayerWithFrame(frame: CYLRect, color: Int): Drawable {
    val layer = ColorDrawable(color)
    layer.setBounds(px(frame.x), px(frame.y), px(frame.maxX), px(frame.maxY))
    overlay.add(layer)
    return layer
}

/**
 * `-cyl_setTarget:action:`: runs `action` when the view is tapped.
 */
fun View.cyl_setTarget(action: () -> Unit) {
    setOnClickListener { action() }
}

/**
 * `-cyl_capture`: the view drawn into a bitmap 270 dp wide.
 */
fun View.cyl_capture(): Bitmap = cyl_captureWithWidth(270f)

/**
 * `-cyl_captureWithWidth:`: the view drawn into a bitmap `width` dp wide and as high as the view.
 */
fun View.cyl_captureWithWidth(width: Float): Bitmap {
    val bitmap = Bitmap.createBitmap(max(1, px(width)), max(1, height), Bitmap.Config.ARGB_8888)
    draw(Canvas(bitmap))
    return bitmap
}

// `UIImage (CYLBlur)`.

/**
 * `-cyl_blurredImageWithRadius:iterations:tintColor:`: `iterations` box blurs of `radius` px (made odd, as vImage),
 * then the tint at 25 % added on top; an empty bitmap is returned as is.
 */
fun Bitmap.cyl_blurredImageWithRadius(radius: Float, iterations: Int, tintColor: Int?): Bitmap {
    if (width * height <= 0) return this
    var box = max(1, radius.toInt())
    if (box % 2 == 0) box++
    val half = box / 2
    val w = width
    val h = height
    var source = IntArray(w * h).also { getPixels(it, 0, w, 0, 0, w, h) }
    var target = IntArray(w * h)
    repeat(iterations) {
        boxPass(source, target, w, h, half, horizontal = true)
        boxPass(target, source, w, h, half, horizontal = false)
    }
    val result = Bitmap.createBitmap(w, h, Bitmap.Config.ARGB_8888)
    result.setPixels(source, 0, w, 0, 0, w, h)
    if (tintColor != null && Color.alpha(tintColor) > 0) {
        val paint = Paint().apply {
            color = tintColor
            alpha = (255 * 0.25f).roundToInt()
            xfermode = PorterDuffXfermode(PorterDuff.Mode.ADD)
        }
        Canvas(result).drawRect(0f, 0f, w.toFloat(), h.toFloat(), paint)
    }
    source = IntArray(0)
    target = IntArray(0)
    return result
}

private fun boxPass(input: IntArray, output: IntArray, w: Int, h: Int, half: Int, horizontal: Boolean) {
    val lines = if (horizontal) h else w
    val length = if (horizontal) w else h
    val size = 2 * half + 1
    for (line in 0 until lines) {
        fun index(i: Int): Int {
            val c = i.coerceIn(0, length - 1)
            return if (horizontal) line * w + c else c * w + line
        }
        var a = 0; var r = 0; var g = 0; var b = 0
        for (i in -half..half) {
            val p = input[index(i)]
            a += p ushr 24; r += (p shr 16) and 0xFF; g += (p shr 8) and 0xFF; b += p and 0xFF
        }
        for (i in 0 until length) {
            output[index(i)] = ((a / size) shl 24) or ((r / size) shl 16) or ((g / size) shl 8) or (b / size)
            val out = input[index(i - half)]
            val inn = input[index(i + half + 1)]
            a += (inn ushr 24) - (out ushr 24)
            r += ((inn shr 16) and 0xFF) - ((out shr 16) and 0xFF)
            g += ((inn shr 8) and 0xFF) - ((out shr 8) and 0xFF)
            b += (inn and 0xFF) - (out and 0xFF)
        }
    }
}

// `NSArray (CYLLog)` and `NSDictionary (CYLLog)`: readable (and, on iOS, Unicode) descriptions for logs.

/**
 * `-cyl_descriptionWithLocale:`: "count (" then one tab-indented item per line, then ")".
 */
fun List<*>.cyl_descriptionWithLocale(locale: Any?): String = buildString {
    append("$size (\n")
    for (item in this@cyl_descriptionWithLocale) append("\t").append(item).append(",\n")
    append(")")
}

/**
 * `-cyl_descriptionWithLocale:`: "{" then one tab-indented "key = value;" per line, then "}".
 */
fun Map<*, *>.cyl_descriptionWithLocale(locale: Any?): String = buildString {
    append("{\n")
    for ((key, value) in this@cyl_descriptionWithLocale) append("\t").append(key).append(" = ").append(value).append(";\n")
    append("}")
}

// `UIButton (CYLCollectionCellStyle)`: the button styles of the classify menu, on any TextView (an Android Button is one).

private val CYLHomeGreen = Color.rgb(18, 133, 117)

private fun TextView.cyl_states(normal: Int, selected: Int? = null, pressed: Int? = null): ColorStateList {
    val states = ArrayList<IntArray>()
    val colors = ArrayList<Int>()
    pressed?.let { states.add(intArrayOf(android.R.attr.state_pressed)); colors.add(it) }
    selected?.let { states.add(intArrayOf(android.R.attr.state_selected)); colors.add(it) }
    states.add(intArrayOf()); colors.add(normal)
    return ColorStateList(states.toTypedArray(), colors.toIntArray())
}

private fun TextView.cyl_applyTitleFont() {
    val font = CYLTagTitleFont
    setTextSize(android.util.TypedValue.COMPLEX_UNIT_SP, font.size)
    typeface = font.typeface
    isAllCaps = false
}

/**
 * `-cyl_generalStyle`: white, 1 dp border, 5 dp corners.
 */
fun TextView.cyl_generalStyle() {
    val box = GradientDrawable().apply {
        setColor(Color.WHITE)
        setStroke(max(1, (resources.displayMetrics.density).roundToInt()), Color.BLACK)
        cornerRadius = 5 * resources.displayMetrics.density
    }
    background = box
    clipToOutline = true
}

/**
 * `-cyl_homeStyle`: green title (lighter when selected, white when pressed on green) and a green border.
 */
fun TextView.cyl_homeStyle() {
    cyl_applyTitleFont()
    setTextColor(cyl_states(CYLHomeGreen, Color.argb((255 * 0.7f).roundToInt(), 18, 133, 117), Color.WHITE))
    val base = (background as? GradientDrawable) ?: GradientDrawable().apply { setColor(Color.WHITE) }
    base.setStroke(max(1, resources.displayMetrics.density.roundToInt()), CYLHomeGreen)
    background = StateListDrawable().apply {
        addState(intArrayOf(android.R.attr.state_pressed), GradientDrawable().apply { setColor(CYLHomeGreen); cornerRadius = base.cornerRadius })
        addState(intArrayOf(), base)
    }
}

/**
 * `-cyl_redStyle`: red title (white when pressed on green) and a red border.
 */
fun TextView.cyl_redStyle() {
    cyl_applyTitleFont()
    val red = Color.rgb(160, 15, 85)
    setTextColor(cyl_states(red, pressed = Color.WHITE))
    val base = (background as? GradientDrawable) ?: GradientDrawable().apply { setColor(Color.WHITE) }
    base.setStroke(max(1, resources.displayMetrics.density.roundToInt()), red)
    background = StateListDrawable().apply {
        addState(intArrayOf(android.R.attr.state_pressed), GradientDrawable().apply { setColor(CYLHomeGreen); cornerRadius = base.cornerRadius })
        addState(intArrayOf(), base)
    }
}

/**
 * `-cyl_chengNiStyle`: the classify menu's tag: a light green pill with the tint color, the highlighted background
 * and white title when pressed or selected.
 */
fun TextView.cyl_chengNiStyle() {
    val d = resources.displayMetrics.density
    cyl_applyTitleFont()
    val highlighted = CYLMenuImage("tag_btn_background_highlighted") ?: ColorDrawable(CYLAppTintColor)
    background = StateListDrawable().apply {
        addState(intArrayOf(android.R.attr.state_selected), highlighted)
        addState(intArrayOf(android.R.attr.state_pressed), highlighted.constantState?.newDrawable() ?: highlighted)
        addState(intArrayOf(), ColorDrawable(Color.rgb(230, 255, 244)))
    }
    setTextColor(cyl_states(CYLAppTintColor, Color.WHITE, Color.WHITE))
    outlineProvider = object : ViewOutlineProvider() {
        override fun getOutline(view: View, outline: Outline) = outline.setRoundRect(0, 0, view.width, view.height, 13 * d)
    }
    clipToOutline = true
}
