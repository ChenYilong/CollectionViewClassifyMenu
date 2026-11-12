package com.cyl.classifymenu

import kotlin.math.ceil
import kotlin.math.max

/**
 * CYLParameterConfiguration.h: the tint, the font sizes and the tag height rule shared by the core's views.
 */

/** The macro `CYLAppTintColor`. */
@JvmField
val CYLAppTintColor: Int = CYLColor.APP_TINT

/** `CYLMaximumFontScale`: text grows with the system font size up to this factor. */
const val CYLMaximumFontScale: Float = 2.0f

/** `CYLTagTitleFontSize`, sp. */
const val CYLTagTitleFontSize: Float = 16f

/**
 * `CYLScaledSystemFont`: the system font of `pointSize` scaled by `fontScale` (the system font scale, 1 by default),
 * at most `CYLMaximumFontScale` times.
 */
fun CYLScaledSystemFont(pointSize: Float, fontScale: Float = 1f): CYLFont =
    CYLFont.systemFont(pointSize * fontScale.coerceIn(0f, CYLMaximumFontScale))

/** `CYLTagHeightForFont`: at least `minimumHeight`, else the font's line height plus 10. */
fun CYLTagHeightForFont(font: CYLFont, minimumHeight: Float): Float = max(minimumHeight, ceil(font.size * 1.2f) + 10)

/** `CYLTagTitleFontForTraitCollection`: the scaled title font. */
fun CYLTagTitleFontForTraitCollection(fontScale: Float = 1f): CYLFont = CYLScaledSystemFont(CYLTagTitleFontSize, fontScale)

/** The macro `CYLTagTitleFont`. */
val CYLTagTitleFont: CYLFont
    get() = CYLTagTitleFontForTraitCollection()
