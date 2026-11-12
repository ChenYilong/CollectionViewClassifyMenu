package com.cyl.classifymenu

import android.content.res.Resources
import android.graphics.Color
import android.graphics.drawable.Drawable
import kotlin.math.max
import kotlin.math.min

/** `CYLTagImagePlacement`: the icon before or after the title. */
enum class CYLTagImagePlacement { CYLTagImagePlacementLeading, CYLTagImagePlacementTrailing }

/** `CYLTagContentAlignment`: the icon and title centered in the tag, or at its leading edge. */
enum class CYLTagContentAlignment { CYLTagContentAlignmentCenter, CYLTagContentAlignmentLeading }

/** `CYLTagRowAlignment`: where a row of tags sits in the list's width. */
enum class CYLTagRowAlignment { CYLTagRowAlignmentLeading, CYLTagRowAlignmentCenter, CYLTagRowAlignmentTrailing }

/** `CYLTagDeleteIndicatorPlacement`: the delete indicator after or before the title. */
enum class CYLTagDeleteIndicatorPlacement { CYLTagDeleteIndicatorPlacementTrailing, CYLTagDeleteIndicatorPlacementLeading }

/**
 * `CYLMenuStyle`: the look of a tag list: the tags in each state (`CYLTagAppearance`), the delete indicator, the touch
 * ripple, titles, rows, icons, layout spacing, section headers, fold controls and the More button. Lengths are dp,
 * font sizes sp. `copy()` is NSCopying.
 */
class CYLMenuStyle {

    var normalAppearance: CYLTagAppearance = CYLTagAppearance()
        private set
    var selectedAppearance: CYLTagAppearance = CYLTagAppearance()
        private set
    var disabledAppearance: CYLTagAppearance = CYLTagAppearance()
        private set

    var highlightedBackgroundColor: Int? = null

    // Delete indicator
    var deleteIndicatorTitle: String = "×"
        set(value) { field = value.ifEmpty { "×" } }
    var deleteIndicatorColor: Int? = null
    var deleteIndicatorFont: CYLFont? = null
    var deleteIndicatorLineWidth: Float = 0f
    var deleteIndicatorWidth: Float = 0f
    var deleteIndicatorPadding: Float = 0f
    var deleteIndicatorPlacement: CYLTagDeleteIndicatorPlacement = CYLTagDeleteIndicatorPlacement.CYLTagDeleteIndicatorPlacementTrailing

    // Touch ripple
    var rippleColor: Int? = null
    var rippleAlpha: Float = 0.2f
    /** Seconds, as `NSTimeInterval`. */
    var rippleDuration: Double = 1.0

    // Titles
    var maximumTitleLength: Int = 0
    var reversesTitleCharacters: Boolean = false

    // Rows and section headers
    var rowAlignment: CYLTagRowAlignment = CYLTagRowAlignment.CYLTagRowAlignmentLeading
    var headerIndicatorColor: Int? = null
    var headerIndicatorSize: CYLSize = CYLSize(3f, 16f)
    var imageCornerRadius: Float = 0f

    // Title and icon
    var imageTitleSpacing: Float = 4f
    var imageSize: CYLSize = CYLSize(14f, 14f)
    var imageInsets: CYLEdgeInsets = CYLEdgeInsets.ZERO
    var titlePositionAdjustment: CYLOffset = CYLOffset.ZERO
    var imagePositionAdjustment: CYLOffset = CYLOffset.ZERO
    var imagePlacement: CYLTagImagePlacement = CYLTagImagePlacement.CYLTagImagePlacementLeading
    var layoutCentered: Boolean = true
    var contentAlignment: CYLTagContentAlignment = CYLTagContentAlignment.CYLTagContentAlignmentCenter
    var animationSize: CYLSize = CYLSize.ZERO
    var animationSpeed: Float = 1f
    var adjustsFontForContentSizeCategory: Boolean = true
    var itemHeight: Float = 30f
    var numberOfItemsPerRow: Int = 0

    // Layout
    var interitemSpacing: Float = 10f
    var lineSpacing: Float = 10f
    var sectionInsets: CYLEdgeInsets = CYLEdgeInsets(10f, 16f, 10f, 16f)
    var backgroundColor: Int = Color.WHITE

    // Section headers
    var headerHeight: Float = 36f
    var headerFont: CYLFont = CYLFont.systemFont(14f)
    var headerTextColor: Int = Color.GRAY
    var headerHorizontalInset: Float = 16f

    // Fold controls
    var foldControlColor: Int = Color.GRAY
    var expandTitle: String = CYLMenuLocalizedString("CYLMenuExpand", "Expand a section")
    var foldChevronImage: Drawable? = null
    var collapseTitle: String = CYLMenuLocalizedString("CYLMenuCollapse", "Collapse a section")

    // The More button
    var moreButtonImage: Drawable? = null
    var moreButtonColor: Int = CYLColor.white(0.24f, 0.6f)

    init {
        val hairline = 1f / max(1f, Resources.getSystem().displayMetrics.density)
        normalAppearance.borderColor = CYLColor.white(0.82f)
        normalAppearance.borderWidth = hairline
        selectedAppearance.backgroundColor = CYLAppTintColor
        selectedAppearance.textColor = Color.WHITE
        selectedAppearance.borderColor = CYLAppTintColor
        selectedAppearance.borderWidth = hairline
        disabledAppearance.textColor = CYLColor.white(0.7f)
        disabledAppearance.borderColor = CYLColor.white(0.88f)
        disabledAppearance.borderWidth = hairline
    }

    /** The content insets of every state; reads the normal state's. */
    var tagContentInsets: CYLEdgeInsets
        get() = normalAppearance.contentInsets
        set(value) {
            for (appearance in appearances()) appearance.contentInsets = value
        }

    private fun appearances() = listOf(normalAppearance, selectedAppearance, disabledAppearance)

    /** `-appearanceForState:`: disabled wins over selected, which wins over normal. */
    fun appearanceForState(state: Int): CYLTagAppearance = when {
        state and CYLControlState.DISABLED != 0 -> disabledAppearance
        state and CYLControlState.SELECTED != 0 -> selectedAppearance
        else -> normalAppearance
    }

    /**
     * `-displayedTitleForTitle:`: at most `maximumTitleLength` characters (whole grapheme clusters) then "...", and
     * reversed character by character when `reversesTitleCharacters`.
     */
    fun displayedTitleForTitle(title: String?): String {
        var text = title.orEmpty()
        val clusters = graphemes(text)
        if (maximumTitleLength > 0 && clusters.size > maximumTitleLength) {
            text = clusters.take(maximumTitleLength).joinToString("") + "..."
        }
        if (reversesTitleCharacters && text.length > 1) {
            text = graphemes(text).asReversed().joinToString("")
        }
        return text
    }

    /** User-perceived characters (grapheme clusters: an emoji with its modifiers is one), as composed sequences on iOS. */
    private fun graphemes(text: String): List<String> = GRAPHEME.findAll(text).map { it.value }.toList()

    /** `-setTitleTextAttributes:forState:`: the font and text color of `state` (null resets them). */
    fun setTitleTextAttributes(font: CYLFont?, textColor: Int?, forState: Int) {
        val appearance = appearanceForState(forState)
        if (font != null) appearance.font = font else appearance.resetFont()
        if (textColor != null) appearance.textColor = textColor else appearance.resetTextColor()
    }

    /** `-titleTextAttributesForState:`: the font and text color of `state`. */
    fun titleTextAttributesForState(state: Int): Pair<CYLFont, Int> {
        val appearance = appearanceForState(state)
        return appearance.font to appearance.textColor
    }

    /** `-setIconColor:forState:`. */
    fun setIconColor(iconColor: Int?, forState: Int) {
        appearanceForState(forState).iconColor = iconColor
    }

    /** `-iconColorForState:`: the icon color, else the text color. */
    fun iconColorForState(state: Int): Int {
        val appearance = appearanceForState(state)
        return appearance.iconColor ?: appearance.textColor
    }

    /**
     * The font of `font` as the views draw it: bold when `boldText` (Bold Text), and scaled by `fontScale` up to
     * `CYLMaximumFontScale` when `adjustsFontForContentSizeCategory`. `fontScale` null means the system's font scale.
     */
    private fun scaledFont(font: CYLFont, fontScale: Float?, boldText: Boolean): CYLFont {
        var result = if (boldText) font.bold() else font
        if (!adjustsFontForContentSizeCategory) return result
        val scale = fontScale ?: Resources.getSystem().configuration.fontScale
        result = result.withSize(result.size * min(max(scale, 0f), CYLMaximumFontScale))
        return result
    }

    /** `-titleFontForState:traitCollection:`; the trait collection is the font scale and Bold Text. */
    @JvmOverloads
    fun titleFontForState(state: Int, fontScale: Float? = null, boldText: Boolean = false): CYLFont =
        scaledFont(appearanceForState(state).font, fontScale, boldText)

    /** `-deleteIndicatorFontForState:traitCollection:`: `deleteIndicatorFont`, else the title font. */
    @JvmOverloads
    fun deleteIndicatorFontForState(state: Int, fontScale: Float? = null, boldText: Boolean = false): CYLFont =
        deleteIndicatorFont?.let { scaledFont(it, fontScale, boldText) } ?: titleFontForState(state, fontScale, boldText)

    /** `-headerFontForTraitCollection:`. */
    @JvmOverloads
    fun headerFontForTraitCollection(fontScale: Float? = null, boldText: Boolean = false): CYLFont = scaledFont(headerFont, fontScale, boldText)

    /** NSCopying. */
    fun copy(): CYLMenuStyle {
        val copy = CYLMenuStyle()
        copy.normalAppearance = normalAppearance.clone()
        copy.selectedAppearance = selectedAppearance.clone()
        copy.disabledAppearance = disabledAppearance.clone()
        copy.imageTitleSpacing = imageTitleSpacing
        copy.imageSize = imageSize
        copy.imageInsets = imageInsets
        copy.titlePositionAdjustment = titlePositionAdjustment
        copy.imagePositionAdjustment = imagePositionAdjustment
        copy.imagePlacement = imagePlacement
        copy.layoutCentered = layoutCentered
        copy.animationSize = animationSize
        copy.animationSpeed = animationSpeed
        copy.adjustsFontForContentSizeCategory = adjustsFontForContentSizeCategory
        copy.itemHeight = itemHeight
        copy.interitemSpacing = interitemSpacing
        copy.lineSpacing = lineSpacing
        copy.sectionInsets = sectionInsets
        copy.backgroundColor = backgroundColor
        copy.headerHeight = headerHeight
        copy.headerFont = headerFont
        copy.headerTextColor = headerTextColor
        copy.headerHorizontalInset = headerHorizontalInset
        copy.foldControlColor = foldControlColor
        copy.foldChevronImage = foldChevronImage
        copy.expandTitle = expandTitle
        copy.collapseTitle = collapseTitle
        copy.numberOfItemsPerRow = numberOfItemsPerRow
        copy.contentAlignment = contentAlignment
        copy.moreButtonImage = moreButtonImage
        copy.moreButtonColor = moreButtonColor
        copy.highlightedBackgroundColor = highlightedBackgroundColor
        copy.deleteIndicatorTitle = deleteIndicatorTitle
        copy.deleteIndicatorColor = deleteIndicatorColor
        copy.deleteIndicatorFont = deleteIndicatorFont
        copy.deleteIndicatorLineWidth = deleteIndicatorLineWidth
        copy.deleteIndicatorWidth = deleteIndicatorWidth
        copy.deleteIndicatorPadding = deleteIndicatorPadding
        copy.deleteIndicatorPlacement = deleteIndicatorPlacement
        copy.rippleColor = rippleColor
        copy.rippleAlpha = rippleAlpha
        copy.rippleDuration = rippleDuration
        copy.maximumTitleLength = maximumTitleLength
        copy.reversesTitleCharacters = reversesTitleCharacters
        copy.rowAlignment = rowAlignment
        copy.headerIndicatorColor = headerIndicatorColor
        copy.headerIndicatorSize = headerIndicatorSize
        copy.imageCornerRadius = imageCornerRadius
        return copy
    }

    companion object {
        private val GRAPHEME = Regex("\\X")

        /** `+defaultStyle`. */
        @JvmStatic
        fun defaultStyle() = CYLMenuStyle()

        /** `+tagCloudStyle`: android-tagview's look: blue square tags, white text, 5 dp spacing. */
        @JvmStatic
        fun tagCloudStyle(): CYLMenuStyle {
            val style = defaultStyle()
            val blue = Color.rgb(0, 0xBF, 0xFF)
            for (appearance in style.appearances()) {
                appearance.backgroundColor = blue
                appearance.textColor = Color.WHITE
                appearance.borderWidth = 0f
                appearance.borderColor = Color.WHITE
                appearance.cornerRadius = 0f
                appearance.font = CYLFont.systemFont(14f)
            }
            style.disabledAppearance.backgroundColor = CYLColor.withAlpha(blue, 0.4f)
            style.highlightedBackgroundColor = Color.argb(0x88, 0x36, 0x36, 0x36)
            style.tagContentInsets = CYLEdgeInsets(5f, 8f, 5f, 8f)
            style.interitemSpacing = 5f
            style.lineSpacing = 5f
            style.itemHeight = 0f
            style.backgroundColor = CYLColor.CLEAR
            return style
        }

        /** `+tagContainerStyle`: AndroidTagView's look: translucent red capsules, gray text, 23 characters at most. */
        @JvmStatic
        fun tagContainerStyle(): CYLMenuStyle {
            val style = defaultStyle()
            val red = Color.rgb(0xF4, 0x43, 0x36)
            for (appearance in style.appearances()) {
                appearance.backgroundColor = CYLColor.withAlpha(red, 0x33 / 255f)
                appearance.borderColor = CYLColor.withAlpha(red, 0x88 / 255f)
                appearance.borderWidth = 0.5f
                appearance.textColor = Color.rgb(0x66, 0x66, 0x66)
                appearance.cornerRadius = 15f
                appearance.font = CYLFont.systemFont(14f)
            }
            style.selectedAppearance.backgroundColor = Color.argb(0x33, 0xFF, 0x76, 0x69)
            style.disabledAppearance.textColor = CYLColor.withAlpha(Color.rgb(0x66, 0x66, 0x66), 0.5f)
            style.tagContentInsets = CYLEdgeInsets(8f, 10f, 8f, 10f)
            style.interitemSpacing = 5f
            style.lineSpacing = 5f
            style.itemHeight = 0f
            style.maximumTitleLength = 23
            style.deleteIndicatorLineWidth = 1f
            style.deleteIndicatorPadding = 10f
            style.deleteIndicatorColor = Color.BLACK
            style.rippleColor = Color.rgb(0xEE, 0xEE, 0xEE)
            style.rippleAlpha = 128 / 255f
            style.backgroundColor = CYLColor.CLEAR
            return style
        }

        /** `+gridStyleWithNumberOfItemsPerRow:`: borderless items in `numberOfItemsPerRow` columns, icon after title. */
        @JvmStatic
        fun gridStyleWithNumberOfItemsPerRow(numberOfItemsPerRow: Int): CYLMenuStyle {
            val style = defaultStyle()
            style.numberOfItemsPerRow = max(1, numberOfItemsPerRow)
            val font = CYLFont.systemFont(17f)
            for (appearance in style.appearances()) {
                appearance.backgroundColor = CYLColor.CLEAR
                appearance.borderWidth = 0f
                appearance.borderColor = null
                appearance.margin = 0f
                appearance.font = font
            }
            style.normalAppearance.textColor = Color.BLACK
            style.selectedAppearance.textColor = Color.BLACK
            style.disabledAppearance.textColor = CYLColor.white(0.24f, 0.3f)
            style.contentAlignment = CYLTagContentAlignment.CYLTagContentAlignmentLeading
            style.imagePlacement = CYLTagImagePlacement.CYLTagImagePlacementTrailing
            style.imageSize = CYLSize(18f, 18f)
            style.imageTitleSpacing = 6f
            style.itemHeight = 32f
            style.interitemSpacing = 24f
            style.lineSpacing = 18f
            return style
        }
    }
}
