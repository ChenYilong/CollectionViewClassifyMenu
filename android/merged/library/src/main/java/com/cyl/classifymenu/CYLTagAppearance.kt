package com.cyl.classifymenu

import android.graphics.drawable.Drawable
import com.cyl.animateditem.CYLAnimatedItemCornerRadiusCapsule
import kotlin.math.max

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

    /** The background in use: [backgroundColor] when set, else white, or the secondary system background in night mode (iOS: the dynamic default). */
    fun resolvedBackgroundColor(context: android.content.Context): Int =
        _backgroundColor ?: if (CYLSystemColors.isNight(context)) CYLSystemColors.SECONDARY_BACKGROUND_DARK else android.graphics.Color.WHITE

    /**
     * The background the app (or a style) set for this state, null while it was never set: the built-in default (white, or
     * the secondary system background in night mode) does not count. Under Liquid Glass only this color tints the glass.
     */
    val explicitBackgroundColor: Int? get() = _backgroundColor

    /** The title color in use: [textColor] when set, else dark gray, or the list's primary tint in night mode. */
    fun resolvedTextColor(context: android.content.Context): Int =
        _textColor ?: if (CYLSystemColors.isNight(context)) CYLSystemColors.primary(context) else CYLColor.white(0.25f)

    /** null_resettable: the 14 sp system font by default. */
    var font: CYLFont
        get() = _font ?: CYLFont.systemFont(14f)
        set(value) { _font = value }

    var iconColor: Int? = null

    var cornerRadius: Float = CYLAnimatedItemCornerRadiusCapsule
        set(value) { field = sanitized(value) }

    private var _borderColor: Int? = null
    private var _borderWidth: Float = 0f
    private var borderColorWasSet = false
    private var borderWidthWasSet = false

    /** The border color in use: the built-in default of the style until one is set (setter, configuration key, preset). */
    var borderColor: Int?
        get() = _borderColor
        set(value) {
            _borderColor = value
            borderColorWasSet = true
        }

    /** The border width in use (dp): the built-in default of the style until one is set. Negative or non-finite becomes 0. */
    var borderWidth: Float
        get() = _borderWidth
        set(value) {
            _borderWidth = sanitized(value)
            borderWidthWasSet = true
        }

    /**
     * Whether the app (a setter, a configuration key or a preset) set the border color or width of this state. The built-in
     * default border ([setDefaultBorder]) does not count. Under drawn Liquid Glass only an explicit border is handed to the
     * glass; otherwise the glass draws its own rim.
     */
    val hasExplicitBorder: Boolean get() = borderColorWasSet || borderWidthWasSet

    /** The built-in default border of a state: readable through [borderColor] and [borderWidth] but NOT explicit. */
    internal fun setDefaultBorder(color: Int?, width: Float) {
        _borderColor = color
        _borderWidth = sanitized(width)
        borderColorWasSet = false
        borderWidthWasSet = false
    }

    /** Takes the border of `other` with its explicit flags (the default stays a default). */
    internal fun copyBorderFrom(other: CYLTagAppearance) {
        _borderColor = other._borderColor
        _borderWidth = other._borderWidth
        borderColorWasSet = other.borderColorWasSet
        borderWidthWasSet = other.borderWidthWasSet
    }

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
        cornerRadius = CYLAnimatedItemCornerRadiusCapsule
        setDefaultBorder(null, 0f)
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
        it.copyBorderFrom(this)
        it.contentInsets = contentInsets
        it.backgroundImage = backgroundImage
    }

    private fun sanitized(value: Float): Float = if (value.isFinite() && value > 0) value else 0f
}
