package com.cyl.classifymenu

import android.content.Context
import android.graphics.Color
import android.util.AttributeSet
import kotlin.math.ceil
import kotlin.math.max
import kotlin.math.min

/**
 * The largest system font scale a fold control's text follows. A fold / More control sits in a fixed-height header or row, so at
 * accessibility font sizes (up to [CYLMaximumFontScale]) it would dwarf its section: it stops growing here, while tags and
 * titles keep scaling up to [CYLMaximumFontScale].
 */
const val CYL_FOLD_CONTROL_MAX_FONT_SCALE: Float = 1.3f

/**
 * `CYLTagFoldButton`: a section's fold control as a tag button: its title and chevron, turned when expanded. Standalone
 * (`applyFoldControl`) it is a borderless control; inline (`applyInlineFoldControl`) it looks like the section's tags.
 */
class CYLTagFoldButton @JvmOverloads constructor(context: Context, attrs: AttributeSet? = null) : CYLTagButton(context, attrs) {

    var foldControl: CYLMenuFoldControl? = null
        private set

    var isExpanded: Boolean = false
        private set

    /** What TalkBack reads: the fold control's title for its state (the base class's hook). */
    private var foldAccessibilityText: CharSequence? = null

    override fun accessibilityText(): CharSequence = foldAccessibilityText ?: super.accessibilityText()

    init {
        importantForAccessibility = IMPORTANT_FOR_ACCESSIBILITY_YES
        cyl_accessibilityIdentifier = CYLTagListFoldControlAccessibilityIdentifier
        CYLAccessibilityNode.apply(this, true, null, null, emptyList())
    }

    fun applyInlineFoldControl(foldControl: CYLMenuFoldControl, itemStyle: CYLMenuStyle, expanded: Boolean, animated: Boolean) {
        apply(foldControl, inlineStyleForFoldControl(foldControl, itemStyle, context), expanded, animated)
    }

    fun applyFoldControl(foldControl: CYLMenuFoldControl, color: Int?, expanded: Boolean, animated: Boolean) {
        apply(foldControl, styleForFoldControl(foldControl, color, context), expanded, animated)
    }

    private fun apply(foldControl: CYLMenuFoldControl, style: CYLMenuStyle, expanded: Boolean, animated: Boolean) {
        this.foldControl = foldControl.copy()
        isExpanded = expanded
        this.style = style
        title = foldControl.titleWhenExpanded(expanded)
        image = if (foldControl.showsImageWhenExpanded(expanded)) foldControl.image else null
        foldAccessibilityText = foldControl.titleWhenExpanded(expanded) ?: if (expanded) foldControl.collapseTitle else foldControl.title
        updateAccessibility()
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

        private fun styleForFoldControl(control: CYLMenuFoldControl, color: Int?, context: Context? = null): CYLMenuStyle {
            val style = CYLMenuStyle.defaultStyle()
            val font = control.font ?: CYLFont.systemFont(13f)
            val tint = control.color ?: color ?: context?.let { CYLSystemColors.primary(it) } ?: Color.argb(153, 60, 60, 67)
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
            style.maximumFontScale = CYL_FOLD_CONTROL_MAX_FONT_SCALE
            style.itemHeight = HEIGHT
            return style
        }

        private fun inlineStyleForFoldControl(control: CYLMenuFoldControl, itemStyle: CYLMenuStyle, context: Context? = null): CYLMenuStyle {
            val style = itemStyle.copy()
            val normal = itemStyle.normalAppearance
            // The tint and the colors a tag leaves unset are resolved for the context (dark mode); without one (a size) they do not matter.
            val tint = control.color ?: itemStyle.foldControlColor ?: context?.let { itemStyle.resolvedTintColor(it) } ?: Color.BLACK
            for (state in listOf(CYLControlState.SELECTED, CYLControlState.DISABLED)) {
                val appearance = style.appearanceForState(state)
                // Copied only when set: an unset background stays unset (never the resolved default as an explicit color), so
                // under Liquid Glass the control gets the frosted default like the tags.
                val normalBackground = normal.explicitBackgroundColor
                if (normalBackground != null) appearance.backgroundColor = normalBackground else appearance.resetBackgroundColor()
                appearance.borderColor = normal.borderColor
                appearance.borderWidth = normal.borderWidth
                appearance.cornerRadius = normal.cornerRadius
                appearance.margin = normal.margin
                appearance.font = normal.font
                appearance.textColor = context?.let { normal.resolvedTextColor(it) } ?: normal.textColor
            }
            for (state in listOf(CYLControlState.NORMAL, CYLControlState.SELECTED, CYLControlState.DISABLED)) style.setIconColor(tint, state)
            control.font?.let { font -> listOf(style.normalAppearance, style.selectedAppearance, style.disabledAppearance).forEach { it.font = font } }
            style.imagePlacement = CYLTagImagePlacement.CYLTagImagePlacementTrailing
            style.imageSize = CYLSize(ICON_SIZE + 4, ICON_SIZE + 4)
            style.imageTitleSpacing = 3f
            style.layoutCentered = true
            style.numberOfItemsPerRow = 0
            style.maximumFontScale = min(style.maximumFontScale, CYL_FOLD_CONTROL_MAX_FONT_SCALE)
            return style
        }

        /** `+inlineSizeForFoldControl:itemStyle:expanded:traitCollection:`, dp. */
        @JvmStatic
        fun inlineSizeForFoldControl(foldControl: CYLMenuFoldControl, itemStyle: CYLMenuStyle, expanded: Boolean): CYLSize {
            val style = inlineStyleForFoldControl(foldControl, itemStyle)
            val image = if (foldControl.showsImageWhenExpanded(expanded)) foldControl.image else null
            val height = heightForStyle(style)
            val width = foldControlWidth(foldControl, expanded, image, style)
            return CYLSize(max(height, ceil(width)), height)
        }

        /** `+sizeForFoldControl:expanded:traitCollection:`, dp: at least 44 wide and 28 high. */
        @JvmStatic
        fun sizeForFoldControl(foldControl: CYLMenuFoldControl, expanded: Boolean): CYLSize {
            val style = styleForFoldControl(foldControl, null)
            val image = if (foldControl.showsImageWhenExpanded(expanded)) foldControl.image else null
            val width = foldControlWidth(foldControl, expanded, image, style)
            return CYLSize(max(44f, ceil(width)), max(HEIGHT, heightForStyle(style)))
        }

        /**
         * The width of the control's content in the given state. With the title always shown (`TitleAndIcon`) it is the wider of
         * the two titles ("More" and "Less") with the icon, so the control does not change size between folded and expanded.
         */
        private fun foldControlWidth(foldControl: CYLMenuFoldControl, expanded: Boolean, image: android.graphics.drawable.Drawable?, style: CYLMenuStyle): Float {
            if (foldControl.content != CYLMenuFoldControlContent.CYLMenuFoldControlContentTitleAndIcon) {
                return widthForTitle(foldControl.titleWhenExpanded(expanded), image, style)
            }
            return max(widthForTitle(foldControl.titleWhenExpanded(false), image, style), widthForTitle(foldControl.titleWhenExpanded(true), image, style))
        }
    }
}
