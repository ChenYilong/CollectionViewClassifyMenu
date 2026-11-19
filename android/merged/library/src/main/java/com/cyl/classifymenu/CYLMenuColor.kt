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
