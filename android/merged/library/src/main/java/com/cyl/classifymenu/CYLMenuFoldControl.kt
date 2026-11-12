package com.cyl.classifymenu

import android.graphics.drawable.Drawable

/** `CYLMenuFoldControlPosition`: where a section's fold control sits. */
enum class CYLMenuFoldControlPosition {
    CYLMenuFoldControlPositionNone,
    CYLMenuFoldControlPositionBottom,
    CYLMenuFoldControlPositionTopTrailing,
    CYLMenuFoldControlPositionTopLeading,
    CYLMenuFoldControlPositionInline,
}

/** `CYLMenuFoldControlContent`: what a fold control shows. */
enum class CYLMenuFoldControlContent {
    CYLMenuFoldControlContentIconAndTitle,
    CYLMenuFoldControlContentTitle,
    CYLMenuFoldControlContentIcon,
}

/**
 * `CYLMenuFoldControl`: the control that expands or collapses a folded section: its position, content, titles, image
 * (a chevron by default, turned when expanded), color and font. `copy()` is NSCopying; equal controls compare equal.
 */
class CYLMenuFoldControl {

    var position: CYLMenuFoldControlPosition = CYLMenuFoldControlPosition.CYLMenuFoldControlPositionNone
    var content: CYLMenuFoldControlContent = CYLMenuFoldControlContent.CYLMenuFoldControlContentIconAndTitle
    private var _title: String? = null
    private var _collapseTitle: String? = null
    private var _image: Drawable? = null
    private val defaultImage: Drawable by lazy { CYLMenuImage("cyl_fold_chevron") ?: CYLMenuIconDrawable(CYLMenuIconDrawable.Kind.CHEVRON_DOWN) }

    /** null_resettable: "Expand" (localized) by default. */
    var title: String?
        get() = _title ?: CYLMenuLocalizedString("CYLMenuExpand", "Expand a section")
        set(value) { _title = value }

    /** null_resettable: "Collapse" (localized) by default. */
    var collapseTitle: String?
        get() = _collapseTitle ?: CYLMenuLocalizedString("CYLMenuCollapse", "Collapse a section")
        set(value) { _collapseTitle = value }

    /** null_resettable: a chevron by default. */
    var image: Drawable?
        get() = _image ?: defaultImage
        set(value) { _image = value }

    /** Whether `image` is the default chevron. */
    val usesDefaultImage: Boolean get() = _image == null

    var color: Int? = null
    var font: CYLFont? = null
    var rotatesImageWhenExpanded: Boolean = true

    fun showsImageWhenExpanded(expanded: Boolean): Boolean = content != CYLMenuFoldControlContent.CYLMenuFoldControlContentTitle

    fun showsTitleWhenExpanded(expanded: Boolean): Boolean = when (content) {
        CYLMenuFoldControlContent.CYLMenuFoldControlContentIconAndTitle -> !expanded
        CYLMenuFoldControlContent.CYLMenuFoldControlContentTitle -> true
        CYLMenuFoldControlContent.CYLMenuFoldControlContentIcon -> false
    }

    fun titleWhenExpanded(expanded: Boolean): String? {
        if (!showsTitleWhenExpanded(expanded)) return null
        return if (expanded) collapseTitle else title
    }

    /** NSCopying. */
    fun copy(): CYLMenuFoldControl = CYLMenuFoldControl().also {
        it.position = position
        it.content = content
        it._title = _title
        it._collapseTitle = _collapseTitle
        it._image = _image
        it.color = color
        it.font = font
        it.rotatesImageWhenExpanded = rotatesImageWhenExpanded
    }

    override fun equals(other: Any?): Boolean = other is CYLMenuFoldControl && other.position == position &&
        other.content == content && other.title == title && other.collapseTitle == collapseTitle && other._image === _image &&
        other.color == color && other.font == font && other.rotatesImageWhenExpanded == rotatesImageWhenExpanded

    override fun hashCode(): Int = position.ordinal * 31 + content.ordinal

    companion object {
        /** `+foldControlWithPosition:content:`. */
        @JvmStatic
        fun foldControlWithPosition(position: CYLMenuFoldControlPosition, content: CYLMenuFoldControlContent) =
            CYLMenuFoldControl().also {
                it.position = position
                it.content = content
            }

        /** `+noFoldControl`: no control, the section shows every item. */
        @JvmStatic
        fun noFoldControl() = foldControlWithPosition(CYLMenuFoldControlPosition.CYLMenuFoldControlPositionNone, CYLMenuFoldControlContent.CYLMenuFoldControlContentIcon)
    }
}
