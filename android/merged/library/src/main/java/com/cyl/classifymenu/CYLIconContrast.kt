package com.cyl.classifymenu

import android.graphics.Color

/**
 * The dark-glass icon lift (iOS: `CYLIconContrast`, docs/tag-liquid-glass.md "Dark glass icon lift"): an EXPLICIT icon color
 * that is too dark for the dark glass is lifted, keeping hue and saturation, until it has [minimumContrastRatio] against the
 * glass. Pure and deterministic. The tag calls it only where glass is really drawn, in night mode, for an icon color the app
 * set; Android has no per-mode (dynamic) colors, so every icon color is static here.
 */
object CYLIconContrast {

    /** The least WCAG contrast ratio (3:1, the floor for graphics and large text) an icon keeps against the glass. */
    const val minimumContrastRatio: Float = 3f

    /** The white share of the default frosted glass in dark mode (white at 0.14); over black it is about #242424. */
    const val frostedGlassWhiteAlpha: Float = 0.14f

    /** The share of an explicit glass tint's alpha that tints the glass when no tint alpha is given. */
    const val defaultGlassTintShare: Float = 0.75f

    /** How much the lightness rises per step while the icon is lifted (0...1). */
    const val lightnessStep: Float = 0.005f

    private const val TRANSPARENT_ALPHA = 0
    private const val CHANNEL_MAX = 255f
    private const val CHANNEL_MAX_INT = 255
    private const val LUMINANCE_OFFSET = 0.05
    private const val HUE_SECTORS = 6f
    private const val SECTOR_PAIR = 2f
    private const val MAX_LIGHTNESS = 1f

    /** The WCAG contrast ratio of two relative luminances, 1 to 21. */
    fun contrastRatio(first: Double, second: Double): Double =
        (maxOf(first, second) + LUMINANCE_OFFSET) / (minOf(first, second) + LUMINANCE_OFFSET)

    /**
     * The reference luminance the icon is judged against, with the glass over a black backdrop: the default frosted glass
     * (`glassTint` null or fully transparent) is white at [frostedGlassWhiteAlpha]; an explicit tint is its color times its alpha
     * times `tintAlpha` ([defaultGlassTintShare] when null).
     */
    fun glassReferenceLuminance(glassTint: Int?, tintAlpha: Float?): Double {
        if (glassTint == null || Color.alpha(glassTint) == TRANSPARENT_ALPHA) {
            val white = frostedGlassWhiteAlpha.toDouble()
            return CYLMenuRelativeLuminance(white, white, white)
        }
        val share = Color.alpha(glassTint) / CHANNEL_MAX * (tintAlpha ?: defaultGlassTintShare)
        return CYLMenuRelativeLuminance(
            Color.red(glassTint) / CHANNEL_MAX * share.toDouble(),
            Color.green(glassTint) / CHANNEL_MAX * share.toDouble(),
            Color.blue(glassTint) / CHANNEL_MAX * share.toDouble(),
        )
    }

    /**
     * The icon color to draw in night mode on glass: `iconColor` itself when the rule does not apply (it already passes), else the
     * lifted color with the same alpha. The caller calls it only when glass is drawn and the mode is night.
     */
    fun liftedIconColor(iconColor: Int, glassTint: Int?, tintAlpha: Float?): Int {
        val red = Color.red(iconColor) / CHANNEL_MAX
        val green = Color.green(iconColor) / CHANNEL_MAX
        val blue = Color.blue(iconColor) / CHANNEL_MAX
        val reference = glassReferenceLuminance(glassTint, tintAlpha)
        fun ratio(hsl: FloatArray): Double {
            val rgb = rgbFromHSL(hsl[0], hsl[1], hsl[2])
            return contrastRatio(CYLMenuRelativeLuminance(rgb[0].toDouble(), rgb[1].toDouble(), rgb[2].toDouble()), reference)
        }
        val hsl = hslFromRGB(red, green, blue)
        if (ratio(hsl) >= minimumContrastRatio) return iconColor
        while (hsl[2] < MAX_LIGHTNESS && ratio(hsl) < minimumContrastRatio) {
            hsl[2] = minOf(MAX_LIGHTNESS, hsl[2] + lightnessStep)
        }
        val rgb = rgbFromHSL(hsl[0], hsl[1], hsl[2])
        return Color.argb(
            Color.alpha(iconColor),
            Math.round(rgb[0] * CHANNEL_MAX).coerceIn(0, CHANNEL_MAX_INT),
            Math.round(rgb[1] * CHANNEL_MAX).coerceIn(0, CHANNEL_MAX_INT),
            Math.round(rgb[2] * CHANNEL_MAX).coerceIn(0, CHANNEL_MAX_INT),
        )
    }

    /** HSL of an sRGB color (components 0...1) as [hue, saturation, lightness], all 0...1. */
    fun hslFromRGB(red: Float, green: Float, blue: Float): FloatArray {
        val high = maxOf(red, green, blue)
        val low = minOf(red, green, blue)
        val lightness = (high + low) / 2
        val delta = high - low
        if (delta <= 0f) return floatArrayOf(0f, 0f, lightness)
        val saturation = delta / (1 - Math.abs(2 * lightness - 1))
        var hue = when (high) {
            red -> (green - blue) / delta
            green -> (blue - red) / delta + SECTOR_PAIR
            else -> (red - green) / delta + 2 * SECTOR_PAIR
        }
        if (hue < 0) hue += HUE_SECTORS
        return floatArrayOf(hue / HUE_SECTORS, saturation, lightness)
    }

    /** The sRGB components [red, green, blue] (0...1) of an HSL triple (all 0...1). */
    fun rgbFromHSL(hue: Float, saturation: Float, lightness: Float): FloatArray {
        val chroma = (1 - Math.abs(2 * lightness - 1)) * saturation
        val sector = hue * HUE_SECTORS
        val second = chroma * (1 - Math.abs(sector % SECTOR_PAIR - 1))
        val base = lightness - chroma / 2
        val parts = when (sector.toInt() % HUE_SECTORS.toInt()) {
            0 -> floatArrayOf(chroma, second, 0f)
            1 -> floatArrayOf(second, chroma, 0f)
            2 -> floatArrayOf(0f, chroma, second)
            3 -> floatArrayOf(0f, second, chroma)
            4 -> floatArrayOf(second, 0f, chroma)
            else -> floatArrayOf(chroma, 0f, second)
        }
        return floatArrayOf(parts[0] + base, parts[1] + base, parts[2] + base)
    }
}
