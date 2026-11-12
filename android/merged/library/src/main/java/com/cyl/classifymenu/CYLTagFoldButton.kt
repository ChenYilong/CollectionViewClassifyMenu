package com.cyl.classifymenu

import android.content.Context
import android.graphics.Color
import android.util.AttributeSet
import kotlin.math.ceil
import kotlin.math.max

/**
 * `CYLTagFoldButton`: a section's fold control as a tag button: its title and chevron, turned when expanded. Standalone
 * (`applyFoldControl`) it is a borderless control; inline (`applyInlineFoldControl`) it looks like the section's tags.
 */
class CYLTagFoldButton @JvmOverloads constructor(context: Context, attrs: AttributeSet? = null) : CYLTagButton(context, attrs) {

    var foldControl: CYLMenuFoldControl? = null
        private set

    var isExpanded: Boolean = false
        private set

    init {
        importantForAccessibility = IMPORTANT_FOR_ACCESSIBILITY_YES
        cyl_accessibilityIdentifier = CYLTagListFoldControlAccessibilityIdentifier
        CYLAccessibilityNode.apply(this, true, null, null, emptyList())
    }

    fun applyInlineFoldControl(foldControl: CYLMenuFoldControl, itemStyle: CYLMenuStyle, expanded: Boolean, animated: Boolean) {
        apply(foldControl, inlineStyleForFoldControl(foldControl, itemStyle), expanded, animated)
    }

    fun applyFoldControl(foldControl: CYLMenuFoldControl, color: Int?, expanded: Boolean, animated: Boolean) {
        apply(foldControl, styleForFoldControl(foldControl, color), expanded, animated)
    }

    private fun apply(foldControl: CYLMenuFoldControl, style: CYLMenuStyle, expanded: Boolean, animated: Boolean) {
        this.foldControl = foldControl.copy()
        isExpanded = expanded
        this.style = style
        title = foldControl.titleWhenExpanded(expanded)
        image = if (foldControl.showsImageWhenExpanded(expanded)) foldControl.image else null
        contentDescription = foldControl.titleWhenExpanded(expanded) ?: if (expanded) foldControl.collapseTitle else foldControl.title
        val rotation = if (expanded && foldControl.rotatesImageWhenExpanded) 180f - 0.0001f else 0f
        if (animated && !CYLAccessibility.isReduceMotionEnabled(context)) {
            imageView.animate().rotation(rotation).setDuration(250).start()
        } else {
            imageView.rotation = rotation
        }
        requestLayout()
    }

    companion object {
        private const val ICON_SIZE = 12f
        private const val MARGIN = 6f
        private const val HEIGHT = 28f

        private fun styleForFoldControl(control: CYLMenuFoldControl, color: Int?): CYLMenuStyle {
            val style = CYLMenuStyle.defaultStyle()
            val font = control.font ?: CYLFont.systemFont(13f)
            val tint = control.color ?: color ?: Color.argb(153, 60, 60, 67)
            for (state in listOf(CYLControlState.NORMAL, CYLControlState.SELECTED, CYLControlState.DISABLED)) {
                val appearance = style.appearanceForState(state)
                appearance.backgroundColor = Color.TRANSPARENT
                appearance.borderWidth = 0f
                appearance.borderColor = null
                appearance.margin = MARGIN
                appearance.font = font
                appearance.textColor = tint
                style.setIconColor(tint, state)
            }
            style.imagePlacement = CYLTagImagePlacement.CYLTagImagePlacementTrailing
            style.imageSize = CYLSize(ICON_SIZE, ICON_SIZE)
            style.imageTitleSpacing = 3f
            style.layoutCentered = true
            style.adjustsFontForContentSizeCategory = control.font == null
            style.itemHeight = HEIGHT
            return style
        }

        private fun inlineStyleForFoldControl(control: CYLMenuFoldControl, itemStyle: CYLMenuStyle): CYLMenuStyle {
            val style = itemStyle.copy()
            val normal = itemStyle.normalAppearance
            val tint = control.color ?: itemStyle.foldControlColor
            for (state in listOf(CYLControlState.SELECTED, CYLControlState.DISABLED)) {
                val appearance = style.appearanceForState(state)
                appearance.backgroundColor = normal.backgroundColor
                appearance.borderColor = normal.borderColor
                appearance.borderWidth = normal.borderWidth
                appearance.cornerRadius = normal.cornerRadius
                appearance.margin = normal.margin
                appearance.font = normal.font
                appearance.textColor = normal.textColor
            }
            for (state in listOf(CYLControlState.NORMAL, CYLControlState.SELECTED, CYLControlState.DISABLED)) style.setIconColor(tint, state)
            control.font?.let { font -> listOf(style.normalAppearance, style.selectedAppearance, style.disabledAppearance).forEach { it.font = font } }
            style.imagePlacement = CYLTagImagePlacement.CYLTagImagePlacementTrailing
            style.imageSize = CYLSize(ICON_SIZE + 4, ICON_SIZE + 4)
            style.imageTitleSpacing = 3f
            style.layoutCentered = true
            style.numberOfItemsPerRow = 0
            return style
        }

        /** `+inlineSizeForFoldControl:itemStyle:expanded:traitCollection:`, dp. */
        @JvmStatic
        fun inlineSizeForFoldControl(foldControl: CYLMenuFoldControl, itemStyle: CYLMenuStyle, expanded: Boolean): CYLSize {
            val style = inlineStyleForFoldControl(foldControl, itemStyle)
            val image = if (foldControl.showsImageWhenExpanded(expanded)) foldControl.image else null
            val height = heightForStyle(style)
            val width = widthForTitle(foldControl.titleWhenExpanded(expanded), image, style)
            return CYLSize(max(height, ceil(width)), height)
        }

        /** `+sizeForFoldControl:expanded:traitCollection:`, dp: at least 44 wide and 28 high. */
        @JvmStatic
        fun sizeForFoldControl(foldControl: CYLMenuFoldControl, expanded: Boolean): CYLSize {
            val style = styleForFoldControl(foldControl, null)
            val image = if (foldControl.showsImageWhenExpanded(expanded)) foldControl.image else null
            val width = widthForTitle(foldControl.titleWhenExpanded(expanded), image, style)
            return CYLSize(max(44f, ceil(width)), max(HEIGHT, heightForStyle(style)))
        }
    }
}
