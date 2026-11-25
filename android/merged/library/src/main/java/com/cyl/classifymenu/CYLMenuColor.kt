package com.cyl.classifymenu

import android.graphics.Color

/**
 * `CYLMenuColorFromString`: "#RGB", "#RRGGBB", "#RRGGBBAA" (alpha last, as on iOS), or the name of a UIColor class
 * property ("systemBlue", "systemBlueColor", "red"…); null when it is none of them.
 */
fun CYLMenuColorFromString(string: String?): Int? {
    val value = string?.trim() ?: return null
    if (value.startsWith("#")) {
        var hex = value.substring(1)
        if (hex.length == 3) hex = hex.map { "$it$it" }.joinToString("")
        if (hex.length != 6 && hex.length != 8) return null
        var rgba = hex.toLongOrNull(16) ?: return null
        if (hex.length == 6) rgba = (rgba shl 8) or 0xFF
        return Color.argb((rgba and 0xFF).toInt(), ((rgba shr 24) and 0xFF).toInt(), ((rgba shr 16) and 0xFF).toInt(), ((rgba shr 8) and 0xFF).toInt())
    }
    val name = value.removeSuffix("Color")
    return CYLUIColorNames[name]
}

/**
 * The relative luminance (WCAG 2.x, 0 black ... 1 white) of an opaque ARGB color; null when the color is not opaque
 * (transparent or translucent: what is behind it is not known).
 */
fun CYLMenuColorLuminance(color: Int): Float? {
    if (Color.alpha(color) != CYLTintChannelMax) return null
    fun linear(channel: Int): Double {
        val c = channel / CYLTintChannelMax.toDouble()
        return if (c <= CYLTintLinearCutoff) c / CYLTintLinearSlope else Math.pow((c + CYLTintOffset) / CYLTintScale, CYLTintGamma)
    }
    return (CYLTintLumaRed * linear(Color.red(color)) + CYLTintLumaGreen * linear(Color.green(color)) + CYLTintLumaBlue * linear(Color.blue(color))).toFloat()
}

/**
 * The relative luminance above which a background counts as light, so that the default tint on it is black: 0.179 is where
 * black and white have the same contrast ratio against it.
 */
const val CYLTintLuminanceThreshold: Float = 0.179f
private const val CYLTintChannelMax = 255
private const val CYLTintLinearCutoff = 0.03928
private const val CYLTintLinearSlope = 12.92
private const val CYLTintOffset = 0.055
private const val CYLTintScale = 1.055
private const val CYLTintGamma = 2.4
private const val CYLTintLumaRed = 0.2126
private const val CYLTintLumaGreen = 0.7152
private const val CYLTintLumaBlue = 0.0722

/** The UIColor class properties a configuration may name, in their light appearance. */
internal val CYLUIColorNames: Map<String, Int> = mapOf(
    "black" to Color.BLACK, "white" to Color.WHITE, "clear" to Color.TRANSPARENT, "darkGray" to CYLColor.white(1f / 3),
    "lightGray" to CYLColor.white(2f / 3), "gray" to CYLColor.white(0.5f), "red" to Color.RED, "green" to Color.GREEN,
    "blue" to Color.BLUE, "cyan" to Color.CYAN, "yellow" to Color.YELLOW, "magenta" to Color.MAGENTA,
    "orange" to CYLColor.rgb(1f, 0.5f, 0f), "purple" to CYLColor.rgb(0.5f, 0f, 0.5f), "brown" to CYLColor.rgb(0.6f, 0.4f, 0.2f),
    "systemRed" to Color.rgb(255, 59, 48), "systemOrange" to Color.rgb(255, 149, 0), "systemYellow" to Color.rgb(255, 204, 0),
    "systemGreen" to Color.rgb(52, 199, 89), "systemMint" to Color.rgb(0, 199, 190), "systemTeal" to Color.rgb(48, 176, 199),
    "systemCyan" to Color.rgb(50, 173, 230), "systemBlue" to Color.rgb(0, 122, 255), "systemIndigo" to Color.rgb(88, 86, 214),
    "systemPurple" to Color.rgb(175, 82, 222), "systemPink" to Color.rgb(255, 45, 85), "systemBrown" to Color.rgb(162, 132, 94),
    "systemGray" to Color.rgb(142, 142, 147), "systemGray2" to Color.rgb(174, 174, 178), "systemGray3" to Color.rgb(199, 199, 204),
    "systemGray4" to Color.rgb(209, 209, 214), "systemGray5" to Color.rgb(229, 229, 234), "systemGray6" to Color.rgb(242, 242, 247),
    "label" to Color.BLACK, "secondaryLabel" to Color.argb(153, 60, 60, 67), "tertiaryLabel" to Color.argb(76, 60, 60, 67),
    "quaternaryLabel" to Color.argb(46, 60, 60, 67), "systemBackground" to Color.WHITE,
    "secondarySystemBackground" to Color.rgb(242, 242, 247), "tertiarySystemBackground" to Color.WHITE,
    "separator" to Color.argb(73, 60, 60, 67), "link" to Color.rgb(0, 122, 255), "tint" to Color.rgb(0, 122, 255),
)

/**
 * The list's own tint and the tag defaults in dark mode, as iOS does with dynamic colors (`UIColor.label`,
 * `secondarySystemBackground`): resolved from the context when the host left a color unset.
 */
internal object CYLSystemColors {
    /** Whether the context is in night mode (the system's dark theme or the app's). */
    fun isNight(context: android.content.Context): Boolean =
        (context.resources.configuration.uiMode and android.content.res.Configuration.UI_MODE_NIGHT_MASK) ==
            android.content.res.Configuration.UI_MODE_NIGHT_YES

    /**
     * The one tint of the list's texts and icons: the theme's `textColorPrimary` (what `UIColor.label` is on iOS), else white in
     * night mode and black otherwise.
     */
    fun primary(context: android.content.Context): Int {
        val fallback = if (isNight(context)) Color.WHITE else Color.BLACK
        val attributes = context.obtainStyledAttributes(intArrayOf(android.R.attr.textColorPrimary))
        return try {
            attributes.getColorStateList(0)?.defaultColor ?: fallback
        } catch (error: Throwable) {
            fallback
        } finally {
            attributes.recycle()
        }
    }

    /** The secondary system background of dark mode (iOS #1C1C1E), the default tag background there. */
    const val SECONDARY_BACKGROUND_DARK: Int = -0xe3e3e2 // 0xFF1C1C1E
}
