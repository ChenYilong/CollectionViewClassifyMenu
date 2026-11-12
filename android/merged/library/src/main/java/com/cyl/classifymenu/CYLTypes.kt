package com.cyl.classifymenu

import android.graphics.Color
import android.graphics.Typeface

/**
 * The Android forms of the UIKit value types the iOS API uses. Lengths are dp and font sizes sp, as points on iOS.
 */
data class CYLEdgeInsets(val top: Float = 0f, val left: Float = 0f, val bottom: Float = 0f, val right: Float = 0f) {
    companion object {
        /** `UIEdgeInsetsZero`. */
        @JvmField
        val ZERO = CYLEdgeInsets()
    }
}

/**
 * `CGSize` in dp.
 */
data class CYLSize(val width: Float = 0f, val height: Float = 0f) {
    companion object {
        /** `CGSizeZero`. */
        @JvmField
        val ZERO = CYLSize()
    }
}

/**
 * `UIOffset` in dp.
 */
data class CYLOffset(val horizontal: Float = 0f, val vertical: Float = 0f) {
    companion object {
        /** `UIOffsetZero`. */
        @JvmField
        val ZERO = CYLOffset()
    }
}

/**
 * `CGPoint` / `CGRect` in dp (view coordinates).
 */
data class CYLPoint(val x: Float = 0f, val y: Float = 0f)

/**
 * `CGRect` in dp.
 */
data class CYLRect(val x: Float = 0f, val y: Float = 0f, val width: Float = 0f, val height: Float = 0f) {
    val maxX: Float get() = x + width
    val maxY: Float get() = y + height

    fun intersects(other: CYLRect): Boolean = x < other.maxX && other.x < maxX && y < other.maxY && other.y < maxY
}

/**
 * `NSIndexPath` of a list: an item in a section.
 */
data class CYLIndexPath(val item: Int, val section: Int) : Comparable<CYLIndexPath> {
    override fun compareTo(other: CYLIndexPath): Int = compareValuesBy(this, other, CYLIndexPath::section, CYLIndexPath::item)

    companion object {
        @JvmStatic
        fun indexPathForItem(item: Int, inSection: Int) = CYLIndexPath(item, inSection)
    }
}

/**
 * `UIFont`: a size in sp and a typeface.
 */
data class CYLFont(val size: Float, val typeface: Typeface = Typeface.DEFAULT) {
    val isBold: Boolean get() = typeface.isBold

    /** The same font in bold (Bold Text). */
    fun bold(): CYLFont = if (isBold) this else copy(typeface = Typeface.create(typeface, Typeface.BOLD))

    fun withSize(size: Float): CYLFont = copy(size = size)

    companion object {
        /** `+[UIFont systemFontOfSize:]`. */
        @JvmStatic
        fun systemFont(size: Float) = CYLFont(size, Typeface.DEFAULT)

        /** `+[UIFont boldSystemFontOfSize:]`. */
        @JvmStatic
        fun boldSystemFont(size: Float) = CYLFont(size, Typeface.DEFAULT_BOLD)
    }
}

/**
 * `UIControlState`: bit flags, `NORMAL` being none of them.
 */
object CYLControlState {
    const val NORMAL = 0
    const val HIGHLIGHTED = 1
    const val DISABLED = 1 shl 1
    const val SELECTED = 1 shl 2
}

/**
 * Colors as ARGB ints, the Android form of `UIColor`.
 */
object CYLColor {
    /** `+[UIColor colorWithWhite:alpha:]`. */
    @JvmStatic
    fun white(white: Float, alpha: Float = 1f): Int {
        val w = (white.coerceIn(0f, 1f) * 255 + 0.5f).toInt()
        return Color.argb((alpha.coerceIn(0f, 1f) * 255 + 0.5f).toInt(), w, w, w)
    }

    /** `+[UIColor colorWithRed:green:blue:alpha:]` with components 0...1. */
    @JvmStatic
    fun rgb(red: Float, green: Float, blue: Float, alpha: Float = 1f): Int = Color.argb(
        (alpha.coerceIn(0f, 1f) * 255 + 0.5f).toInt(), (red.coerceIn(0f, 1f) * 255 + 0.5f).toInt(),
        (green.coerceIn(0f, 1f) * 255 + 0.5f).toInt(), (blue.coerceIn(0f, 1f) * 255 + 0.5f).toInt(),
    )

    /** `-[UIColor colorWithAlphaComponent:]`. */
    @JvmStatic
    fun withAlpha(color: Int, alpha: Float): Int = (color and 0x00FFFFFF) or ((alpha.coerceIn(0f, 1f) * 255 + 0.5f).toInt() shl 24)

    /** A "RRGGBB" or "#RRGGBB" hex string with `alpha`, or null when it does not parse. */
    @JvmStatic
    fun fromHex(hex: String?, alpha: Float = 1f): Int? {
        val digits = hex?.trim()?.removePrefix("#") ?: return null
        val rgb = digits.toLongOrNull(16) ?: return null
        return withAlpha((rgb and 0xFFFFFF).toInt() or (0xFF shl 24), alpha)
    }

    /** `CYLAppTintColor` (42, 185, 160). */
    @JvmField
    val APP_TINT: Int = Color.rgb(42, 185, 160)

    /** `+[UIColor clearColor]`. */
    const val CLEAR: Int = Color.TRANSPARENT
}
