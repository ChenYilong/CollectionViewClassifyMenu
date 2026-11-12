package me.kaede.tagview

import android.graphics.Color

/**
 * Default values of the tag view; dimensions are in dp or sp, not px.
 */
internal object Constants {
    @JvmField
    var DEBUG = true

    const val DEFAULT_LINE_MARGIN = 5f
    const val DEFAULT_TAG_MARGIN = 5f
    const val DEFAULT_TAG_TEXT_PADDING_LEFT = 8f
    const val DEFAULT_TAG_TEXT_PADDING_TOP = 5f
    const val DEFAULT_TAG_TEXT_PADDING_RIGHT = 8f
    const val DEFAULT_TAG_TEXT_PADDING_BOTTOM = 5f
    const val LAYOUT_WIDTH_OFFSET = 2f

    const val DEFAULT_TAG_TEXT_SIZE = 14f
    const val DEFAULT_TAG_DELETE_INDICATOR_SIZE = 14f
    const val DEFAULT_TAG_LAYOUT_BORDER_SIZE = 0f
    const val DEFAULT_TAG_RADIUS = 100f
    val DEFAULT_TAG_LAYOUT_COLOR: Int = Color.parseColor("#00BFFF")
    val DEFAULT_TAG_LAYOUT_COLOR_PRESS: Int = Color.parseColor("#88363636")
    val DEFAULT_TAG_TEXT_COLOR: Int = Color.parseColor("#ffffff")
    val DEFAULT_TAG_DELETE_INDICATOR_COLOR: Int = Color.parseColor("#ffffff")
    val DEFAULT_TAG_LAYOUT_BORDER_COLOR: Int = Color.parseColor("#ffffff")
    const val DEFAULT_TAG_DELETE_ICON = "×"
    const val DEFAULT_TAG_IS_DELETABLE = false
}
