package com.cyl.classifymenu

import android.graphics.Color
import kotlin.random.Random

/** `CYLTagColorTheme`: AndroidTagView's `tag_theme`. */
enum class CYLTagColorTheme(val value: Int) {
    CYLTagColorThemeNone(-1),
    CYLTagColorThemeRandom(0),
    CYLTagColorThemePureCyan(1),
    CYLTagColorThemePureTeal(2),
}

/** `CYLTagColorsBackgroundAlpha`: 0x33 / 255. */
const val CYLTagColorsBackgroundAlpha: Float = 0x33 / 255f

/** `CYLTagColorsBorderAlpha`: 0x88 / 255. */
const val CYLTagColorsBorderAlpha: Float = 0x88 / 255f

/**
 * `CYLTagColors`: the four colors of a tag (background, border, text, selected background), AndroidTagView's
 * ColorFactory: a theme, a random palette color, or your own.
 */
class CYLTagColors(
    var backgroundColor: Int? = null,
    var borderColor: Int? = null,
    var textColor: Int? = null,
    var selectedBackgroundColor: Int? = null,
) : Cloneable {

    /** `-styleByApplyingToStyle:`: a copy of `style` (the default style when null) with these colors. */
    fun styleByApplyingToStyle(style: CYLMenuStyle?): CYLMenuStyle {
        val result = (style ?: CYLMenuStyle.defaultStyle()).copy()
        val normal = result.normalAppearance
        backgroundColor?.let { normal.backgroundColor = it }
        textColor?.let {
            normal.textColor = it
            result.selectedAppearance.textColor = it
        }
        borderColor?.let {
            normal.borderColor = it
            result.selectedAppearance.borderColor = it
            if (normal.borderWidth <= 0) normal.borderWidth = 1f
        }
        selectedBackgroundColor?.let { result.selectedAppearance.backgroundColor = it }
        return result
    }

    /** NSCopying. */
    public override fun clone(): CYLTagColors = CYLTagColors(backgroundColor, borderColor, textColor, selectedBackgroundColor)

    override fun equals(other: Any?): Boolean = other is CYLTagColors && other.backgroundColor == backgroundColor &&
        other.borderColor == borderColor && other.textColor == textColor && other.selectedBackgroundColor == selectedBackgroundColor

    override fun hashCode(): Int = listOf(backgroundColor, borderColor, textColor, selectedBackgroundColor).hashCode()

    companion object {
        private val palette = listOf("F44336", "03A9F4", "FFC107", "FF9800", "FFEB3B", "CDDC39", "2196F3", "3F51B5", "8BC34A",
            "9E9E9E", "673AB7", "009688", "00BCD4")

        /** `+colorsWithBackgroundColor:borderColor:textColor:selectedBackgroundColor:`. */
        @JvmStatic
        fun colorsWithBackgroundColor(backgroundColor: Int?, borderColor: Int?, textColor: Int?, selectedBackgroundColor: Int?) =
            CYLTagColors(backgroundColor, borderColor, textColor, selectedBackgroundColor)

        /** `paletteHexByName`: ColorFactory's colors by name. */
        @JvmStatic
        val paletteHexByName: Map<String, String> = mapOf(
            "RED" to "F44336", "LIGHTBLUE" to "03A9F4", "AMBER" to "FFC107", "ORANGE" to "FF9800", "YELLOW" to "FFEB3B",
            "LIME" to "CDDC39", "BLUE" to "2196F3", "INDIGO" to "3F51B5", "LIGHTGREEN" to "8BC34A", "GREY" to "9E9E9E",
            "DEEPPURPLE" to "673AB7", "TEAL" to "009688", "CYAN" to "00BCD4",
        )

        /** `gray666666`. */
        @JvmStatic
        val gray666666: Int = Color.rgb(0x66, 0x66, 0x66)

        /** `gray727272`. */
        @JvmStatic
        val gray727272: Int = Color.rgb(0x72, 0x72, 0x72)

        /** `+colorsWithPaletteHex:textColor:selectedBackgroundColor:`: `hex` at 0x33 (background) and 0x88 (border). */
        @JvmStatic
        fun colorsWithPaletteHex(hex: String, textColor: Int, selectedBackgroundColor: Int) = CYLTagColors(
            CYLColor.fromHex(hex, CYLTagColorsBackgroundAlpha), CYLColor.fromHex(hex, CYLTagColorsBorderAlpha), textColor, selectedBackgroundColor,
        )

        /** `+colorsForTheme:seed:`: the theme's colors (random: the palette color `seed`), null for None. */
        @JvmStatic
        fun colorsForTheme(theme: CYLTagColorTheme, seed: Int): CYLTagColors? = when (theme) {
            CYLTagColorTheme.CYLTagColorThemeRandom -> colorsWithPaletteHex(palette[Math.floorMod(seed, palette.size)], gray666666, gray727272)
            CYLTagColorTheme.CYLTagColorThemePureCyan -> colorsWithPaletteHex("00BCD4", gray727272, gray666666)
            CYLTagColorTheme.CYLTagColorThemePureTeal -> colorsWithPaletteHex("009688", gray727272, gray666666)
            CYLTagColorTheme.CYLTagColorThemeNone -> null
        }

        /** `+randomColors`. */
        @JvmStatic
        fun randomColors(): CYLTagColors = colorsForTheme(CYLTagColorTheme.CYLTagColorThemeRandom, Random.nextInt(palette.size))!!
    }
}
