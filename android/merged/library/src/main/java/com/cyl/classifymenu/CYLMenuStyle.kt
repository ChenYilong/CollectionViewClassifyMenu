package com.cyl.classifymenu

import com.cyl.animateditem.CYLAnimatedItemCornerRadiusCapsule
import android.content.res.Resources
import android.graphics.Color
import android.graphics.drawable.Drawable
import kotlin.math.max
import kotlin.math.min

/**
 * `CYLTagImagePlacement`: the icon before or after the title, or above (`Top`, raw value 2) or below (`Bottom`, 3) it,
 * both centered.
 */
enum class CYLTagImagePlacement {
    CYLTagImagePlacementLeading, CYLTagImagePlacementTrailing, CYLTagImagePlacementTop, CYLTagImagePlacementBottom;

    /** True for `Top` and `Bottom`: the icon and the title are stacked. */
    val isVertical: Boolean get() = this == CYLTagImagePlacementTop || this == CYLTagImagePlacementBottom
}

/** `CYLTagContentAlignment`: the icon and title centered in the tag, or at its leading edge. */
enum class CYLTagContentAlignment { CYLTagContentAlignmentCenter, CYLTagContentAlignmentLeading }

/** `CYLTagBackgroundStyle`: a tag's flat color, or a Liquid Glass background where the device draws one (`CYLLiquidGlass.isActive()`). */
enum class CYLTagBackgroundStyle { CYLTagBackgroundStyleFlat, CYLTagBackgroundStyleLiquidGlass }

/** `CYLTagRowAlignment`: where a row of tags sits in the list's width. */
enum class CYLTagRowAlignment { CYLTagRowAlignmentLeading, CYLTagRowAlignmentCenter, CYLTagRowAlignmentTrailing }

/**
 * `CYLSectionStyle`: how a section's tags sit in the list: `insetGrouped` (the default) inside a rounded card (UITableView's
 * inset grouped look), the header above it; `plain` on the list's background (the opt-out: the look before the default
 * changed).
 */
enum class CYLSectionStyle { CYLSectionStylePlain, CYLSectionStyleInsetGrouped }

/** `CYLHeaderSeparatorStyle`: the line at the bottom of a section header: `none` (the default) or a `line`. */
enum class CYLHeaderSeparatorStyle { CYLHeaderSeparatorStyleNone, CYLHeaderSeparatorStyleLine }

/** The named lengths of the section style, dp. */
object CYLSectionStyleMetrics {
    /** The corner radius of a section card. */
    const val CARD_CORNER_RADIUS: Float = 10f
    /** The padding between a section card and its tags. */
    const val CARD_PADDING: Float = 12f
    /** The padding between a header band and its title, leading and trailing. */
    const val HEADER_BAND_PADDING: Float = 12f
    /** The thickness of the header divider: one hairline. */
    const val SEPARATOR_THICKNESS: Float = 0.5f
}

/**
 * The colors of the section style, each following the color mode (as `CYLSystemColors`): a style whose color is null
 * resolves to them; an app can also set one itself, for example [HEADER_BAND] on `headerBackgroundColor`.
 */
object CYLSectionStyleColors {
    /** The section card in light mode: white. */
    const val CARD: Int = Color.WHITE
    /** The section card in dark mode: #1C1C1E (the secondary system background). */
    const val CARD_DARK: Int = CYLSystemColors.SECONDARY_BACKGROUND_DARK
    /** The header band in light mode: #EFEFF4 (the TagCollectionView header). */
    const val HEADER_BAND: Int = 0xFFEFEFF4.toInt()
    /** The header band in dark mode: #2C2C2E. */
    const val HEADER_BAND_DARK: Int = 0xFF2C2C2E.toInt()
    /** The list background under `insetGrouped` in light mode: #F2F2F7. */
    const val GROUPED_BACKGROUND: Int = 0xFFF2F2F7.toInt()
    /** The list background under `insetGrouped` in dark mode: black. */
    const val GROUPED_BACKGROUND_DARK: Int = Color.BLACK
    /** The header divider in light mode: the system separator (#3C3C43 at 29 %). */
    const val SEPARATOR: Int = 0x4A3C3C43
    /** The header divider in dark mode: the system separator (#545458 at 60 %). */
    const val SEPARATOR_DARK: Int = 0x99545458.toInt()

    fun card(context: android.content.Context): Int = if (CYLSystemColors.isNight(context)) CARD_DARK else CARD
    fun headerBand(context: android.content.Context): Int = if (CYLSystemColors.isNight(context)) HEADER_BAND_DARK else HEADER_BAND
    fun groupedBackground(context: android.content.Context): Int = if (CYLSystemColors.isNight(context)) GROUPED_BACKGROUND_DARK else GROUPED_BACKGROUND
    fun separator(context: android.content.Context): Int = if (CYLSystemColors.isNight(context)) SEPARATOR_DARK else SEPARATOR
}

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

    /**
     * `editingIndicatorSpacing`: the space between the two editing icons of a renamable tag in `CYLTagListView`'s
     * editing mode (the edit icon and the delete icon, `CYLTagButton.editingIndicatorsView`), dp. 10 by default; a
     * negative value is 0.
     */
    var editingIndicatorSpacing: Float = 10f

    /**
     * `editingIndicatorInsets`: the margins around the two editing icons as a whole: left from the title, right to the
     * tag's padding, top and bottom within the tag, dp. Left 4 and right 0 by default (the tag's own padding follows
     * the cross); negative values are 0.
     */
    var editingIndicatorInsets: CYLEdgeInsets = CYLEdgeInsets(0f, 4f, 0f, 0f)

    /** `clearButtonImage`: the image of a section header's clear button; null: the core's trash icon ("cyl_trash"). */
    var clearButtonImage: android.graphics.drawable.Drawable? = null

    /** `clearButtonColor`: the color of the clear button; null: `headerTextColor`. */
    var clearButtonColor: Int? = null
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

    /**
     * The tag background: flat (the default) is the solid color of each state's appearance; Liquid Glass draws a glass background
     * behind the content, tinted with the state's `backgroundColor` and clipped to the corner radius. Where the device draws no
     * Liquid Glass the style is ignored (`resolvedBackgroundStyle`).
     */
    var backgroundStyle: CYLTagBackgroundStyle = CYLTagBackgroundStyle.CYLTagBackgroundStyleFlat

    /**
     * The background style a tag really draws: `backgroundStyle`, or flat when `CYLLiquidGlass.isActive()`
     * (`CYLAnimatedItemView.isLiquidGlassActive()`, the rule of CYLTabBarController: Android 12 and later) is false.
     */
    val resolvedBackgroundStyle: CYLTagBackgroundStyle
        get() = if (backgroundStyle == CYLTagBackgroundStyle.CYLTagBackgroundStyleLiquidGlass && com.cyl.animateditem.CYLAnimatedItemView.isLiquidGlassActive())
            CYLTagBackgroundStyle.CYLTagBackgroundStyleLiquidGlass else CYLTagBackgroundStyle.CYLTagBackgroundStyleFlat

    /**
     * The smallest size of a tag, dp: a tag narrower or shorter than it grows to it, its content staying where `contentAlignment`
     * puts it. `CYLSize.ZERO` (the default) keeps the tag as large as its content and `itemHeight` make it.
     */
    var minimumTagSize: CYLSize = CYLSize.ZERO
    var animationSize: CYLSize = CYLSize.ZERO
    var animationSpeed: Float = 1f
    var adjustsFontForContentSizeCategory: Boolean = true

    /**
     * The largest system font scale this style's texts follow when `adjustsFontForContentSizeCategory`: the text grows with the
     * system font size up to this factor. Default [CYLMaximumFontScale]; the fold controls lower it to
     * [CYL_FOLD_CONTROL_MAX_FONT_SCALE] so they stay small at accessibility font sizes.
     */
    var maximumFontScale: Float = CYLMaximumFontScale
    var itemHeight: Float = 30f

    /**
     * The most lines a title may take: a title too wide for its tag wraps onto more lines, up to this number, and the tag
     * grows taller; beyond it the title is truncated. Default [CYLTagTitleMaxLines.SINGLE] (1, one line, truncated).
     * [CYLTagTitleMaxLines.UNLIMITED] shows every line. The app chooses the number; a value below 1 is 1.
     */
    var titleMaxLines: Int = CYLTagTitleMaxLines.SINGLE
        set(value) { field = max(CYLTagTitleMaxLines.SINGLE, value) }
    var numberOfItemsPerRow: Int = 0

    // Layout
    var interitemSpacing: Float = 10f
    var lineSpacing: Float = 10f
    var sectionInsets: CYLEdgeInsets = CYLEdgeInsets(10f, 16f, 10f, 16f)
    private var backgroundColorValue: Int = Color.WHITE
    private var backgroundColorWasSet: Boolean = false

    /**
     * The list's background color. Never set, the list paints the SYSTEM background (white in light mode, black in dark mode),
     * or the grouped background under `insetGrouped` ([resolvedBackgroundColor], resolved per mode); this getter then returns
     * white, the light value, because it has no context. A set color, even a transparent one, wins in both modes.
     */
    var backgroundColor: Int
        get() = backgroundColorValue
        set(value) {
            backgroundColorValue = value
            backgroundColorWasSet = true
        }

    /** The list background the app set, null while it was never set (the default follows light / dark mode). */
    internal val explicitBackgroundColor: Int? get() = if (backgroundColorWasSet) backgroundColorValue else null

    // The section card, the header band and the header divider (the contract is docs/tag-section-style.md)
    /**
     * `insetGrouped` (the default): the section's tags inside a rounded card; `plain` opts out (the tags on the list's
     * background). The library's own looks that must stay flat ([tagCloudStyle], [wordPicker], ...) set `plain`.
     */
    var sectionStyle: CYLSectionStyle = CYLSectionStyle.CYLSectionStyleInsetGrouped
    /** The card's color; null resolves to the system card color ([resolvedSectionBackgroundColor]). */
    var sectionBackgroundColor: Int? = null
    /**
     * The card's background: flat (the default) is the solid [sectionBackgroundColor]; Liquid Glass draws the library's glass
     * behind the tags with the card's corners, tinted with [sectionBackgroundColor] when it is set. Where the device draws no
     * glass the card stays flat ([resolvedSectionBackgroundStyle]). Independent of the tags' `backgroundStyle`.
     */
    var sectionBackgroundStyle: CYLTagBackgroundStyle = CYLTagBackgroundStyle.CYLTagBackgroundStyleFlat

    /** The card background really drawn: [sectionBackgroundStyle], or flat when `CYLLiquidGlass.isActive()` is false. */
    val resolvedSectionBackgroundStyle: CYLTagBackgroundStyle
        get() = if (sectionBackgroundStyle == CYLTagBackgroundStyle.CYLTagBackgroundStyleLiquidGlass && com.cyl.animateditem.CYLAnimatedItemView.isLiquidGlassActive())
            CYLTagBackgroundStyle.CYLTagBackgroundStyleLiquidGlass else CYLTagBackgroundStyle.CYLTagBackgroundStyleFlat
    var sectionCornerRadius: Float = CYLSectionStyleMetrics.CARD_CORNER_RADIUS
        set(value) { field = max(0f, value) }
    /** The padding inside the card around the tags (`insetGrouped`), dp. */
    var sectionContentInsets: CYLEdgeInsets = CYLEdgeInsets(CYLSectionStyleMetrics.CARD_PADDING, CYLSectionStyleMetrics.CARD_PADDING,
        CYLSectionStyleMetrics.CARD_PADDING, CYLSectionStyleMetrics.CARD_PADDING)
    /** The header band's color; null: no band (today's look). [CYLSectionStyleColors.HEADER_BAND] is the usual one. */
    var headerBackgroundColor: Int? = null
    var headerCornerRadius: Float = 0f
        set(value) { field = max(0f, value) }
    /** A plain header's title and fold control inset from the band's edges (left and right), dp. */
    var headerContentInsets: CYLEdgeInsets = CYLEdgeInsets(0f, CYLSectionStyleMetrics.HEADER_BAND_PADDING, 0f, CYLSectionStyleMetrics.HEADER_BAND_PADDING)
    var headerSeparatorStyle: CYLHeaderSeparatorStyle = CYLHeaderSeparatorStyle.CYLHeaderSeparatorStyleNone
    /** The divider's color; null resolves to the system separator color ([resolvedHeaderSeparatorColor]). */
    var headerSeparatorColor: Int? = null
    var headerSeparatorThickness: Float = CYLSectionStyleMetrics.SEPARATOR_THICKNESS
        set(value) { field = max(0f, value) }
    /**
     * The divider's leading (left) and trailing (right) inset from the column's edges, dp; null (the default) is 0 and 0: the
     * divider has the same left and right edges as the card and the header band, never the title's x.
     */
    var headerSeparatorInsets: CYLEdgeInsets? = null

    /** True when the section style draws the cards. */
    val isInsetGrouped: Boolean get() = sectionStyle == CYLSectionStyle.CYLSectionStyleInsetGrouped

    /**
     * The list background in use: [backgroundColor] when the app set it (even transparent); else the grouped background under
     * `insetGrouped`, else the system background (white in light mode, black in dark mode).
     */
    fun resolvedBackgroundColor(context: android.content.Context): Int = when {
        backgroundColorWasSet -> backgroundColorValue
        isInsetGrouped -> CYLSectionStyleColors.groupedBackground(context)
        else -> CYLSystemColors.systemBackground(context)
    }

    /** The card's color in use. */
    fun resolvedSectionBackgroundColor(context: android.content.Context): Int = sectionBackgroundColor ?: CYLSectionStyleColors.card(context)

    /** The divider's color in use. */
    fun resolvedHeaderSeparatorColor(context: android.content.Context): Int = headerSeparatorColor ?: CYLSectionStyleColors.separator(context)

    // Section headers
    var headerHeight: Float = 36f

    /**
     * The most lines a section header's title may take: a title too wide for the room beside the fold control wraps onto more
     * lines, up to this number, and the header grows taller than [headerHeight]. Default [CYLHeaderTitleMaxLines.SINGLE] (1, one
     * line, truncated: the header is exactly [headerHeight] high). [CYLHeaderTitleMaxLines.UNLIMITED] shows every line. A value
     * below 1 is 1.
     */
    var headerMaxLines: Int = CYLHeaderTitleMaxLines.SINGLE
        set(value) { field = max(CYLHeaderTitleMaxLines.SINGLE, value) }
    var headerFont: CYLFont = CYLFont.systemFont(14f)
    /** null (the default): [tintColor], else its default by the background luminance ([resolvedHeaderTextColor]). */
    var headerTextColor: Int? = null
    var headerHorizontalInset: Float = 16f

    // Fold controls
    /** null (the default): the tint (see [headerTextColor]); a control's own color wins. */
    var foldControlColor: Int? = null
    var expandTitle: String = CYLMenuLocalizedString("CYLMenuExpand", "Expand a section")
    var foldChevronImage: Drawable? = null
    var collapseTitle: String = CYLMenuLocalizedString("CYLMenuCollapse", "Collapse a section")

    // The More button
    var moreButtonImage: Drawable? = null
    /** null (the default): the tint (see [headerTextColor]). */
    var moreButtonColor: Int? = null

    /**
     * The one color of every built-in view that is not a tag (header title, section icon, fold / More / clear controls); null
     * (the default): black or white by the luminance of the background it is drawn on ([resolvedTintColor]). A color set on
     * the title, the fold control, the More button or the clear button itself wins over it for that view.
     */
    var tintColor: Int? = null

    /**
     * The default tint on `background`: black on a light one, white on a dark one ([CYLTintLuminanceThreshold]); the system
     * mode ([CYLSystemColors.primary]) when the background is not an opaque color (a transparent list shows the page).
     */
    private fun tintOn(context: android.content.Context, background: Int): Int {
        val luminance = CYLMenuColorLuminance(background) ?: return CYLSystemColors.primary(context)
        return if (luminance > CYLTintLuminanceThreshold) Color.BLACK else Color.WHITE
    }

    /**
     * The tint as drawn: [tintColor], else the default against what is behind the view: the band color when `onBand` (a
     * header with a band) and a band is set, else the list's own background ([resolvedBackgroundColor]: the app's color, the
     * grouped background under `insetGrouped`, the system background the list paints by default).
     */
    @JvmOverloads
    fun resolvedTintColor(context: android.content.Context, onBand: Boolean = false): Int {
        tintColor?.let { return it }
        val band = headerBackgroundColor
        return tintOn(context, if (onBand && band != null) band else resolvedBackgroundColor(context))
    }

    /** The header title color in use: [headerTextColor], else the tint. */
    @JvmOverloads
    fun resolvedHeaderTextColor(context: android.content.Context, onBand: Boolean = false): Int = headerTextColor ?: resolvedTintColor(context, onBand)

    /** The fold controls' color in use: [foldControlColor], else the tint (a control's own color still wins). */
    @JvmOverloads
    fun resolvedFoldControlColor(context: android.content.Context, onBand: Boolean = false): Int = foldControlColor ?: resolvedTintColor(context, onBand)

    /** The More button's color in use: [moreButtonColor], else the tint. */
    @JvmOverloads
    fun resolvedMoreButtonColor(context: android.content.Context, onBand: Boolean = false): Int = moreButtonColor ?: resolvedTintColor(context, onBand)

    /** The clear button's color in use: [clearButtonColor], else the header title's. */
    @JvmOverloads
    fun resolvedClearButtonColor(context: android.content.Context, onBand: Boolean = false): Int = clearButtonColor ?: resolvedHeaderTextColor(context, onBand)

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
        result = result.withSize(result.size * min(max(scale, 0f), maximumFontScale))
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
        copy.maximumFontScale = maximumFontScale
        copy.itemHeight = itemHeight
        copy.titleMaxLines = titleMaxLines
        copy.interitemSpacing = interitemSpacing
        copy.lineSpacing = lineSpacing
        copy.sectionInsets = sectionInsets
        copy.backgroundColorValue = backgroundColorValue
        copy.backgroundColorWasSet = backgroundColorWasSet
        copy.sectionStyle = sectionStyle
        copy.sectionBackgroundColor = sectionBackgroundColor
        copy.sectionBackgroundStyle = sectionBackgroundStyle
        copy.sectionCornerRadius = sectionCornerRadius
        copy.sectionContentInsets = sectionContentInsets
        copy.headerBackgroundColor = headerBackgroundColor
        copy.headerCornerRadius = headerCornerRadius
        copy.headerContentInsets = headerContentInsets
        copy.headerSeparatorStyle = headerSeparatorStyle
        copy.headerSeparatorColor = headerSeparatorColor
        copy.headerSeparatorThickness = headerSeparatorThickness
        copy.headerSeparatorInsets = headerSeparatorInsets
        copy.headerHeight = headerHeight
        copy.headerMaxLines = headerMaxLines
        copy.headerFont = headerFont
        copy.tintColor = tintColor
        copy.headerTextColor = headerTextColor
        copy.headerHorizontalInset = headerHorizontalInset
        copy.foldControlColor = foldControlColor
        copy.foldChevronImage = foldChevronImage
        copy.expandTitle = expandTitle
        copy.collapseTitle = collapseTitle
        copy.numberOfItemsPerRow = numberOfItemsPerRow
        copy.contentAlignment = contentAlignment
        copy.backgroundStyle = backgroundStyle
        copy.minimumTagSize = minimumTagSize
        copy.moreButtonImage = moreButtonImage
        copy.moreButtonColor = moreButtonColor
        copy.highlightedBackgroundColor = highlightedBackgroundColor
        copy.deleteIndicatorTitle = deleteIndicatorTitle
        copy.deleteIndicatorColor = deleteIndicatorColor
        copy.deleteIndicatorFont = deleteIndicatorFont
        copy.deleteIndicatorLineWidth = deleteIndicatorLineWidth
        copy.deleteIndicatorWidth = deleteIndicatorWidth
        copy.deleteIndicatorPadding = deleteIndicatorPadding
        copy.editingIndicatorSpacing = editingIndicatorSpacing
        copy.editingIndicatorInsets = editingIndicatorInsets
        copy.clearButtonImage = clearButtonImage
        copy.clearButtonColor = clearButtonColor
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

        /**
         * The base of every library look that is a complete look of its own (a tag cloud, a word picker, a grid, a tag of the
         * classify menu): the default style with the section card opted out, so the look is the flat one it always was.
         */
        private fun plainBaseStyle(): CYLMenuStyle = defaultStyle().also { it.sectionStyle = CYLSectionStyle.CYLSectionStylePlain }

        /** `+tagCloudStyle`: android-tagview's look: blue square tags, white text, 5 dp spacing. */
        @JvmStatic
        fun tagCloudStyle(): CYLMenuStyle {
            val style = plainBaseStyle()
            val blue = Color.rgb(0, 0xBF, 0xFF)
            for (appearance in style.appearances()) {
                appearance.backgroundColor = blue
                appearance.textColor = Color.WHITE
                appearance.borderWidth = 0f
                appearance.borderColor = Color.WHITE
                appearance.cornerRadius = CYLAnimatedItemCornerRadiusCapsule
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

        /**
         * `+wordPicker` (选词填入, as WeChat's "涂抹选择填入词"): one character per cell, 9 equal cells per row, light gray
         * cells with small corners that turn mint green when selected, the character centered. Use it with
         * `CYLTagListView.setTagsWithCharactersOfText`, `selectionMode` multiple and `allowsSmearSelection`; the picked
         * text is `selectedText`.
         */
        @JvmStatic
        fun wordPicker(): CYLMenuStyle {
            val style = plainBaseStyle()
            style.numberOfItemsPerRow = 9
            val font = CYLFont(18f, android.graphics.Typeface.create("sans-serif-medium", android.graphics.Typeface.NORMAL))
            for (appearance in style.appearances()) {
                appearance.font = font
                appearance.cornerRadius = 3f
                appearance.borderWidth = 0f
                appearance.borderColor = null
                appearance.margin = 0f
                appearance.textColor = Color.rgb(0x1C, 0x1C, 0x1E)
                appearance.backgroundColor = Color.rgb(0xF2, 0xF2, 0xF7)
            }
            // Mint green (iOS 0.70 / 0.92 / 0.81).
            style.selectedAppearance.backgroundColor = Color.rgb(0xB3, 0xEB, 0xCF)
            style.disabledAppearance.textColor = Color.argb(0x4C, 0x3C, 0x3C, 0x43)
            style.contentAlignment = CYLTagContentAlignment.CYLTagContentAlignmentCenter
            style.layoutCentered = true
            style.itemHeight = 40f
            style.interitemSpacing = 6f
            style.lineSpacing = 10f
            style.sectionInsets = CYLEdgeInsets(12f, 24f, 12f, 24f)
            style.backgroundColor = CYLColor.CLEAR
            return style
        }

        /** `+tagContainerStyle`: AndroidTagView's look: translucent red capsules, gray text, 23 characters at most. */
        @JvmStatic
        fun tagContainerStyle(): CYLMenuStyle {
            val style = plainBaseStyle()
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

        /**
         * `+classifyMenuTag:`: a tag of `CYLClassifyMenuViewController`, in one of the looks its tag buttons have had
         * (`CYLCollectionCellButtonStyle`; `chengNi`, the default, is a light green capsule that takes the app's tint
         * while selected or pressed). The tags' title font (`CYLTagTitleFontSize`, scaled like every tag), the icon 5 dp
         * before the title, a 4 dp margin at both ends.
         */
        @JvmStatic
        @JvmOverloads
        fun classifyMenuTag(look: CYLCollectionCellButtonStyle = CYLCollectionCellButtonStyle.chengNi): CYLMenuStyle {
            val style = compactTagStyle()
            val green = Color.rgb(18, 133, 117)
            when (look) {
                CYLCollectionCellButtonStyle.general -> for (appearance in style.appearances()) {
                    appearance.cornerRadius = 5f
                    appearance.backgroundColor = Color.WHITE
                    appearance.borderWidth = 1f
                    appearance.borderColor = Color.BLACK
                }
                CYLCollectionCellButtonStyle.home -> {
                    for (appearance in style.appearances()) {
                        appearance.textColor = green
                        appearance.borderColor = green
                    }
                    style.selectedAppearance.textColor = CYLColor.withAlpha(green, 0.7f)
                    style.highlightedBackgroundColor = green
                }
                CYLCollectionCellButtonStyle.red -> {
                    val red = Color.rgb(160, 15, 85)
                    for (appearance in style.appearances()) {
                        appearance.textColor = red
                        appearance.borderColor = red
                    }
                    style.highlightedBackgroundColor = green
                }
                CYLCollectionCellButtonStyle.chengNi -> {
                    val mint = Color.rgb(230, 255, 244)
                    for (appearance in style.appearances()) {
                        appearance.cornerRadius = 13f
                        appearance.backgroundColor = mint
                        appearance.textColor = CYLAppTintColor
                    }
                    style.selectedAppearance.backgroundColor = CYLAppTintColor
                    style.selectedAppearance.backgroundImage = CYLMenuImage("tag_btn_background_highlighted")
                    style.selectedAppearance.textColor = Color.WHITE
                    style.highlightedBackgroundColor = CYLAppTintColor
                }
            }
            return style
        }

        /**
         * `+filterTag`: a tag of the multiple-choice filter (`CYLMultipleFilterController`): the filter's stretchable
         * slide images as the normal and selected backgrounds, green titles that turn white when selected.
         */
        @JvmStatic
        fun filterTag(): CYLMenuStyle {
            val style = compactTagStyle()
            for (appearance in style.appearances()) {
                appearance.backgroundColor = CYLColor.CLEAR
                appearance.cornerRadius = 0f
            }
            style.normalAppearance.backgroundImage = CYLStretchableDrawable.named("btn_slide_normal")
            style.normalAppearance.textColor = Color.rgb(96, 147, 130)
            style.selectedAppearance.backgroundImage = CYLStretchableDrawable.named("btn_slide_selected")
            style.selectedAppearance.textColor = Color.WHITE
            return style
        }

        /**
         * `+sectionTitleWithFontSize:textColor:leadingInset:`: a section title of a header: no background and no border,
         * the content at the leading edge after `leadingInset` (dp), an icon 4 dp before the title, in `fontSize` (sp).
         */
        @JvmStatic
        @JvmOverloads
        fun sectionTitle(fontSize: Float = 15f, textColor: Int = Color.BLACK, leadingInset: Float = 0f): CYLMenuStyle {
            val style = plainBaseStyle()
            for (appearance in style.appearances()) {
                appearance.backgroundColor = CYLColor.CLEAR
                appearance.borderWidth = 0f
                appearance.borderColor = null
                appearance.cornerRadius = 0f
                appearance.textColor = textColor
                appearance.font = CYLFont.systemFont(fontSize)
                appearance.contentInsets = CYLEdgeInsets(0f, leadingInset, 0f, 0f)
            }
            style.contentAlignment = CYLTagContentAlignment.CYLTagContentAlignmentLeading
            style.imageSize = CYLSize(16f, 16f)
            style.imageTitleSpacing = 4f
            style.itemHeight = 0f
            style.backgroundColor = CYLColor.CLEAR
            return style
        }

        /**
         * The tags of the classify menu and the multiple filter: the tags' title font, small end margins, no border.
         */
        private fun compactTagStyle(): CYLMenuStyle {
            val style = plainBaseStyle()
            val font = CYLFont.systemFont(CYLTagTitleFontSize)
            for (appearance in style.appearances()) {
                appearance.font = font
                appearance.borderWidth = 0f
                appearance.contentInsets = CYLEdgeInsets(0f, 4f, 0f, 4f)
            }
            style.imageTitleSpacing = 5f
            style.imageSize = CYLSize(16f, 16f)
            style.itemHeight = 30f
            style.backgroundColor = CYLColor.CLEAR
            return style
        }

        /** `+gridStyleWithNumberOfItemsPerRow:`: borderless items in `numberOfItemsPerRow` columns, icon after title. */
        @JvmStatic
        fun gridStyleWithNumberOfItemsPerRow(numberOfItemsPerRow: Int): CYLMenuStyle {
            val style = plainBaseStyle()
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

/** The line limits of a section header's title ([CYLMenuStyle.headerMaxLines]): named values, never a literal at a call site. */
object CYLHeaderTitleMaxLines {
    /** One line, the default: a title too wide for its header is truncated and the header keeps its fixed height. */
    const val SINGLE: Int = 1

    /** No limit: a title wraps onto as many lines as it needs and the header grows with it. */
    const val UNLIMITED: Int = Int.MAX_VALUE
}

/** The line limits of a tag's title ([CYLMenuStyle.titleMaxLines]): named values, never a literal at a call site. */
object CYLTagTitleMaxLines {
    /** One line, the default: a title too wide for its tag is truncated. */
    const val SINGLE: Int = 1

    /** No limit: a title wraps onto as many lines as it needs (the MAX of the line counts). */
    const val UNLIMITED: Int = Int.MAX_VALUE
}
