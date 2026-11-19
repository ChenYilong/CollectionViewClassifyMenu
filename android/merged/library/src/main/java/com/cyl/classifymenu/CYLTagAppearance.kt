package com.cyl.classifymenu

import android.graphics.drawable.Drawable
import kotlin.math.max

/** `CYLTagCornerRadiusSquare`: a corner radius that draws square corners (0 means "the list's value"). */
const val CYLTagCornerRadiusSquare: Float = 0.001f

/**
 * `CYLTagAppearance`: the box and text of a tag in one state (normal, selected, disabled). Negative or non-finite
 * lengths become 0, as on iOS.
 */
class CYLTagAppearance : Cloneable {

    private var _backgroundColor: Int? = null
    private var _textColor: Int? = null
    private var _font: CYLFont? = null

    /** null_resettable: white by default. */
    var backgroundColor: Int
        get() = _backgroundColor ?: android.graphics.Color.WHITE
        set(value) { _backgroundColor = value }

    /** null_resettable: dark gray (white 0.25) by default. */
    var textColor: Int
        get() = _textColor ?: CYLColor.white(0.25f)
        set(value) { _textColor = value }

    /** null_resettable: the 14 sp system font by default. */
    var font: CYLFont
        get() = _font ?: CYLFont.systemFont(14f)
        set(value) { _font = value }

    var iconColor: Int? = null

    var cornerRadius: Float = 3f
        set(value) { field = sanitized(value) }

    var borderColor: Int? = null

    var borderWidth: Float = 0f
        set(value) { field = sanitized(value) }

    /** The larger of the left and right content insets; setting it sets both. */
    var margin: Float
        get() = max(contentInsets.left, contentInsets.right)
        set(value) {
            val m = sanitized(value)
            contentInsets = contentInsets.copy(left = m, right = m)
        }

    var contentInsets: CYLEdgeInsets = CYLEdgeInsets(5f, 10f, 5f, 10f)
        set(value) { field = CYLEdgeInsets(sanitized(value.top), sanitized(value.left), sanitized(value.bottom), sanitized(value.right)) }

    var backgroundImage: Drawable? = null

    /** Resets the colors and font to null (the defaults) and the lengths to their defaults. */
    fun reset() {
        _backgroundColor = null
        _textColor = null
        _font = null
        iconColor = null
        cornerRadius = 3f
        borderColor = null
        borderWidth = 0f
        contentInsets = CYLEdgeInsets(5f, 10f, 5f, 10f)
        backgroundImage = null
    }

    /** Resets the background color to its default (null_resettable). */
    fun resetBackgroundColor() { _backgroundColor = null }

    /** Resets the text color to its default (null_resettable). */
    fun resetTextColor() { _textColor = null }

    /** Resets the font to its default (null_resettable). */
    fun resetFont() { _font = null }

    /** NSCopying. */
    public override fun clone(): CYLTagAppearance = CYLTagAppearance().also {
        it._backgroundColor = _backgroundColor
        it._textColor = _textColor
        it._font = _font
        it.iconColor = iconColor
        it.cornerRadius = cornerRadius
        it.borderColor = borderColor
        it.borderWidth = borderWidth
        it.contentInsets = contentInsets
        it.backgroundImage = backgroundImage
    }

    private fun sanitized(value: Float): Float = if (value.isFinite() && value > 0) value else 0f
}
