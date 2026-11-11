package me.kaede.tagview

import android.graphics.Color
import android.graphics.drawable.Drawable

/**
 * Tag entity: its text, colors, size, corner radius, border, background and the delete indicator.
 */
class Tag(
    @JvmField var id: Int,
    @JvmField var text: String,
    @JvmField var layoutColor: Int,
) {
    @JvmField var tagTextColor: Int = Constants.DEFAULT_TAG_TEXT_COLOR
    @JvmField var tagTextSize: Float = Constants.DEFAULT_TAG_TEXT_SIZE
    @JvmField var layoutColorPress: Int = Constants.DEFAULT_TAG_LAYOUT_COLOR_PRESS
    @JvmField var isDeletable: Boolean = Constants.DEFAULT_TAG_IS_DELETABLE
    @JvmField var deleteIndicatorColor: Int = Constants.DEFAULT_TAG_DELETE_INDICATOR_COLOR
    @JvmField var deleteIndicatorSize: Float = Constants.DEFAULT_TAG_DELETE_INDICATOR_SIZE
    @JvmField var radius: Float = Constants.DEFAULT_TAG_RADIUS
    @JvmField var deleteIcon: String = Constants.DEFAULT_TAG_DELETE_ICON
    @JvmField var layoutBorderSize: Float = Constants.DEFAULT_TAG_LAYOUT_BORDER_SIZE
    @JvmField var layoutBorderColor: Int = Constants.DEFAULT_TAG_LAYOUT_BORDER_COLOR
    @JvmField var background: Drawable? = null

    constructor(text: String) : this(0, text, Constants.DEFAULT_TAG_LAYOUT_COLOR)

    constructor(text: String, color: Int) : this(0, text, color)

    constructor(text: String, color: String) : this(0, text, Color.parseColor(color))

    constructor(id: Int, text: String) : this(id, text, Constants.DEFAULT_TAG_LAYOUT_COLOR)

    constructor(id: Int, text: String, color: String) : this(id, text, Color.parseColor(color))
}
