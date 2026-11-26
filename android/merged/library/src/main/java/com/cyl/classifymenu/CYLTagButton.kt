package com.cyl.classifymenu

import android.content.Context
import android.content.res.Resources
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.Path
import android.graphics.drawable.Drawable
import android.graphics.drawable.GradientDrawable
import android.net.Uri
import android.provider.Settings
import android.util.AttributeSet
import android.util.TypedValue
import android.view.Gravity
import android.view.MotionEvent
import android.view.View
import android.view.accessibility.AccessibilityNodeInfo
import android.widget.ImageView
import android.widget.TextView
import com.cyl.animateditem.CYLAnimatedItemAccessoryPlacement
import com.cyl.animateditem.CYLAnimatedItemAxis
import com.cyl.animateditem.CYLAnimatedItemBackgroundStyle
import com.cyl.animateditem.CYLAnimatedItemLiquidGlassContentInset
import com.cyl.animateditem.CYLAnimatedItemStackView
import com.cyl.animateditem.CYLAnimatedItemView
import com.cyl.animateditem.CYLTabBarItemAnimationViewMaking
import kotlin.math.ceil
import kotlin.math.floor
import kotlin.math.max
import kotlin.math.min
import kotlin.math.roundToInt

/**
 * `CYLTagButton`: one tag, built on CYLTabBarController's shared animated icon + title component `CYLAnimatedItemView`
 * (module `:cylanimateditem`, Maven `io.github.chenyilong:cyltabbarcontroller-animateditem`; guide:
 * https://github.com/ChenYilong/CYLTabBarController/blob/feat/cross-platform-components/docs/Animated-Item.md): an icon
 * (or an animated icon) before, after, above or below a title, an optional delete indicator (the base class's
 * `accessoryView`, a title or a drawn cross) and an optional badge, drawn in the style's appearance for its state
 * (normal, selected, disabled, pressed). The icon, the title, `animationURL`, the speed, the loops, the playback and the
 * display priority are the base class's: the animation when it can play (its library is in the app: Lottie, libpag,
 * rive-android, SVGAPlayer; GIF needs none); otherwise the static `image` / `selectedImage`; the component's placeholder
 * only when there is no static image. A tag with a title and no icon never shows a placeholder. The core adds no
 * animation library. Lengths are dp; `widthForTitle…` / `heightForStyle` / `heightForTitle` measure a tag before it
 * exists. Use it on its own with `CYLTagButton(context, title, image)` or `CYLTagButton(context, title, image, animationURL)`.
 */
open class CYLTagButton @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null,
) : CYLAnimatedItemView(context, attrs) {

    /** The icon: the base class's `iconView`. */
    val imageView: ImageView get() = iconView

    /** The title: the base class's `titleView`. */
    val titleLabel: TextView get() = titleView

    /**
     * The delete indicator (a title, or empty under a drawn cross), shown while `showsDeleteIndicator`: the base
     * class's `accessoryView`, so a tap on it calls `gestureListener.onAccessoryTapped`.
     */
    val deleteIndicatorLabel: TextView = TextView(context).apply {
        gravity = Gravity.CENTER
        includeFontPadding = false
        visibility = GONE
    }
    /** `badgeLabel`: draws the badge (hidden while `badgeValue` is null), at the top trailing corner of the icon. */
    val badgeLabel: TextView = TextView(context).apply {
        gravity = Gravity.CENTER
        includeFontPadding = false
        maxLines = 1
        setTextColor(Color.WHITE)
        typeface = android.graphics.Typeface.DEFAULT_BOLD
        setTextSize(TypedValue.COMPLEX_UNIT_DIP, BADGE_FONT_SIZE)
        visibility = GONE
        importantForAccessibility = IMPORTANT_FOR_ACCESSIBILITY_NO
    }
    private val badgeBox = GradientDrawable()
    private val backgroundImageView = ImageView(context).apply {
        scaleType = ImageView.ScaleType.FIT_XY
        visibility = GONE
    }
    /**
     * The Liquid Glass layer behind the content (CYLAnimatedItemView's `itemLiquidGlassView`) while `style.resolvedBackgroundStyle`
     * is Liquid Glass and the device draws it; null while the tag is flat.
     */
    val liquidGlassView: View? get() = itemLiquidGlassView
    private val crossPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        style = Paint.Style.STROKE
        strokeCap = Paint.Cap.ROUND
    }
    private val crossPath = Path()
    private var drawsCross = false
    /** False until this class's views exist: the base class calls the hooks while it is being built. */
    private var ready = false
    private var rawTitle: CharSequence? = null
    private var followsStyleAnimationSpeed = true

    /** The delete indicator's touch area in this view, dp (`CGRectZero` when hidden). */
    var deleteIndicatorHitFrame: CYLRect = CYLRect()
        private set

    init {
        addView(backgroundImageView, 0)
        titleView.includeFontPadding = false
        titleView.gravity = Gravity.CENTER_VERTICAL
        // The disabled look comes from the style's appearance, not from the base class's alpha.
        disabledAlpha = 1f
        accessoryView = deleteIndicatorLabel
        badgeLabel.background = badgeBox
        addView(badgeLabel)
        clipToOutline = true
        setWillNotDraw(false)
        isClickable = true
        isFocusable = true
        ready = true
        // The tag plays through the engine's player itself (Play all, resting progress, speed, loops), never on selection:
        // the engine's "host drives" mode, as HarmonyOS's tag passes `drivesAnimationPlayback: false`. iOS defaults to
        // the opposite value, so it is set here and not left to the view's default.
        drivesAnimationPlayback = false
        iconSizeDp = animationSize().toAnimatedItemSize()
        applyStyleAnimationSpeed()
        afterAnimationReload()
    }

    /**
     * `init(title:image:)`: a tag for use on its own (a search bar item, a toolbar button), drawn with the default style;
     * it measures itself to fit its content (wrap_content).
     */
    constructor(context: Context, title: String?, image: Drawable?) : this(context, title, image, null)

    /**
     * `init(title:image:animationURL:)`: the same with an animated icon in the icon slot; `image` is shown while the
     * file's library is not in the app, while it downloads, or when it cannot be played.
     */
    constructor(context: Context, title: String?, image: Drawable?, animationURL: Uri?) : this(context, null as AttributeSet?) {
        this.title = title
        this.image = image
        this.animationURL = animationURL?.toString()
    }

    /**
     * `badgeValue`, as `UITabBarItem.badgeValue`: null (the default) hides the badge, "" shows a dot, any other text
     * ("3", "99+") a capsule with it, at the top trailing corner of the icon (of the title when there is no icon).
     * TalkBack reads it after the title.
     */
    var badgeValue: String? = null
        set(value) {
            if (field == value) return
            field = value
            updateAppearance()
        }

    /** `badgeColor`: the badge's background; null restores the default, system red (#FF3B30). The text is white. */
    var badgeColor: Int? = CYLTagBadgeDefaultColor
        get() = field ?: CYLTagBadgeDefaultColor
        set(value) {
            field = value ?: CYLTagBadgeDefaultColor
            updateAppearance()
        }

    private val density: Float get() = resources.displayMetrics.density
    private fun px(dp: Float): Int = (dp * density).roundToInt()

    /** The style (a copy); null resets it to the default style (null_resettable). */
    var style: CYLMenuStyle? = CYLMenuStyle.defaultStyle()
        get() = field ?: CYLMenuStyle.defaultStyle()
        set(value) {
            field = (value ?: CYLMenuStyle.defaultStyle()).copy()
            applyStyleAnimationSpeed()
            axis = if (currentStyle.imagePlacement.isVertical) CYLAnimatedItemAxis.Vertical else CYLAnimatedItemAxis.Horizontal
            val size = animationSize().toAnimatedItemSize()
            if (iconSizeDp != size) {
                // The base class makes the animation view at `iconSizeDp`: a new size reloads it.
                iconSizeDp = size
                afterAnimationReload()
            }
            updateAppearance()
        }

    private val currentStyle: CYLMenuStyle get() = style!!

    /** The title (the base class's), shown through the style (`displayedTitleForTitle`). */
    override var title: CharSequence?
        get() = rawTitle
        set(value) {
            rawTitle = value
            super.title = value
            updateAppearance()
        }

    /** The static icon (the base class's): shown until an animation shows, whenever none can play, while it downloads. */
    override var image: Drawable?
        get() = super.image
        set(value) {
            super.image = value
            updateAppearance()
        }

    /** Shown while selected (the base class's); null keeps `image`. */
    override var selectedImage: Drawable?
        get() = super.selectedImage
        set(value) {
            super.selectedImage = value
            updateAppearance()
        }

    /** The animation file (the base class's): a path, `file://`, `file:///android_asset/…` or a remote URL. */
    override var animationURL: String?
        get() = super.animationURL
        set(value) {
            val changed = value != super.animationURL
            super.animationURL = value
            if (changed) afterAnimationReload()
        }

    /** Where animation views come from (the base class's). */
    override var animationSource: CYLTabBarItemAnimationViewMaking
        get() = super.animationSource
        set(value) {
            super.animationSource = value
            afterAnimationReload()
        }

    /** Where an unselected animation rests, 0…1 (0: the first frame); the base class's. */
    override var animationRestingProgress: Float
        get() = super.animationRestingProgress
        set(value) {
            val changed = value != super.animationRestingProgress
            super.animationRestingProgress = value
            if (changed) updateAnimationState()
        }

    /**
     * `animationSpeed` (the base class's), applied at once, also to an animation that is playing. Until it is set, the
     * tag follows `style.animationSpeed`; `resetAnimationSpeed()` goes back to it.
     */
    override var animationSpeed: Float
        get() = super.animationSpeed
        set(value) {
            followsStyleAnimationSpeed = false
            super.animationSpeed = value
        }

    /** `-resetAnimationSpeed`: follows `style.animationSpeed` again after `animationSpeed` was set. */
    fun resetAnimationSpeed() {
        followsStyleAnimationSpeed = true
        applyStyleAnimationSpeed()
    }

    var showsDeleteIndicator: Boolean = false
        set(value) {
            if (field == value) return
            field = value
            updateAppearance()
        }

    /**
     * `showsRenameIndicator`: shows a rename indicator (a square and pencil) before the delete indicator, for a tag that
     * can be renamed; the two icons are then drawn by `editingIndicatorsView`. Needs `showsDeleteIndicator`. False by
     * default; `CYLTagListView` turns it on in editing mode for the items its data source can rename.
     */
    var showsRenameIndicator: Boolean = false
        set(value) {
            if (field == value) return
            field = value
            updateAppearance()
        }

    /** `renameIndicatorHitFrame`: the area a tap on the rename indicator should cover, dp; empty while it is hidden. */
    var renameIndicatorHitFrame: CYLRect = CYLRect()
        private set

    private var editingIndicatorsViewIsLoaded = false

    /**
     * `editingIndicatorsView`: the two editing icons while `showsRenameIndicator` (a pencil, then a cross), a
     * `CYLAnimatedItemStackView` in a row (`axis` Horizontal) of two icon-only `CYLAnimatedItemView`s,
     * `CYLMenuStyle.editingIndicatorSpacing` apart (`spacingDp`), tinted with the indicator color (`iconColor`). It only
     * draws; the list cell takes the taps.
     */
    val editingIndicatorsView: CYLAnimatedItemStackView by lazy {
        CYLAnimatedItemStackView(context).apply {
            contentMarginDp = 0f
            axis = com.cyl.animateditem.CYLAnimatedItemAxis.Horizontal
            stackView.gravity = Gravity.CENTER_VERTICAL
            for (kind in listOf(CYLEditingIconDrawable.Kind.Rename, CYLEditingIconDrawable.Kind.Delete)) {
                val icon = CYLAnimatedItemView(context)
                icon.image = CYLEditingIconDrawable(kind)
                icon.title = null
                icon.importantForAccessibility = IMPORTANT_FOR_ACCESSIBILITY_NO
                append(icon, null)
            }
            isClickable = false
            isFocusable = false
            importantForAccessibility = IMPORTANT_FOR_ACCESSIBILITY_NO_HIDE_DESCENDANTS
            visibility = GONE
            this@CYLTagButton.addView(this)
            editingIndicatorsViewIsLoaded = true
        }
    }

    override fun setSelected(selected: Boolean) {
        val changed = selected != isSelected
        super.setSelected(selected)
        if (changed) updateAnimationState()
        updateAppearance()
    }

    override fun setPressed(pressed: Boolean) {
        super.setPressed(pressed)
        updateAppearance()
    }

    /** The look of the state (selected, enabled), from the style's appearance (the base class's hook). */
    override fun onItemStateChanged() {
        updateAppearance()
    }

    /** `isHighlighted`: pressed. */
    val isHighlighted: Boolean get() = isPressed

    /**
     * A tag that is not clickable (a list cell's, whose cell handles the touches) leaves the touches to its parent, as
     * a plain non-clickable view does.
     */
    @android.annotation.SuppressLint("ClickableViewAccessibility")
    override fun onTouchEvent(event: MotionEvent): Boolean {
        if (!isClickable && !isLongClickable) return false
        return super.onTouchEvent(event)
    }

    private fun applyStyleAnimationSpeed() {
        if (!followsStyleAnimationSpeed) return
        val speed = currentStyle.animationSpeed
        super.animationSpeed = if (speed > 0) speed else 1f
    }

    /**
     * Plays the animated icon (the base class's `playAnimation`), not with Remove animations / Reduce Motion, where it
     * shows the state's frame; with `animationLoops`, it repeats. Without the file's library it does nothing.
     */
    override fun playAnimation() {
        if (CYLAccessibility.isReduceMotionEnabled(context)) {
            updateAnimationState()
            return
        }
        super.playAnimation()
    }

    /** The animated item's size type (CYLTabBarController's `CYLSize`). */
    private fun CYLSize.toAnimatedItemSize(): com.cyl.animateditem.CYLSize = com.cyl.animateditem.CYLSize(width, height)

    private fun animationSize(): CYLSize {
        val size = currentStyle.animationSize
        return if (size == CYLSize.ZERO) currentStyle.imageSize else size
    }

    /** After the base class built the animation view again: Lottie images, the state's frame, the look. */
    private fun afterAnimationReload() {
        if (!ready) return
        updateAnimationState()
        updateAppearance()
    }

    private fun updateAnimationState() {
        if (!ready || animationView == null) return
        if (isSelected) showAnimationLastFrame() else stopAnimation()
    }

    private fun currentState(): Int = when {
        !isEnabled -> CYLControlState.DISABLED
        isSelected -> CYLControlState.SELECTED
        else -> CYLControlState.NORMAL
    }

    /** What TalkBack reads (the base class's hook): the title as shown, or the icon's label for an icon-only tag. */
    override fun accessibilityText(): CharSequence {
        val displayed = currentStyle.displayedTitleForTitle(rawTitle?.toString())
        return displayed.ifEmpty { (super.image as? CYLBadgeDrawable)?.accessibilityLabel ?: "" }
    }

    private fun updateAppearance() {
        if (!ready) return
        val style = currentStyle
        val state = currentState()
        val appearance = style.appearanceForState(state)
        // The base class chooses the icon (the image, the selected image or its placeholder) and hides it while the
        // animation shows; only a disabled selected tag shows `image` (disabled wins over selected).
        val shown = iconView.drawable
        if (shown != null && (shown === image || shown === selectedImage)) {
            val icon = if (state == CYLControlState.SELECTED && selectedImage != null) selectedImage else image
            if (icon !== shown) iconView.setImageDrawable(icon)
        }
        animationView?.alpha = if (state == CYLControlState.DISABLED) 0.4f else 1f
        imageView.imageTintList = null
        // The icon tint (and so the animation's, which the base class draws through the same icon view) is lifted by
        // updateIconTint() once the glass state below is known.
        imageView.setColorFilter(style.iconColorForState(state))
        val icon = iconView.drawable
        if (icon is CYLBadgeDrawable || icon is CYLOriginalImageDrawable) imageView.clearColorFilter()
        titleLabel.text = style.displayedTitleForTitle(rawTitle?.toString())
        val font = style.titleFontForState(state)
        titleLabel.setTextSize(TypedValue.COMPLEX_UNIT_DIP, font.size)
        titleLabel.typeface = font.typeface
        val textColor = appearance.resolvedTextColor(context)
        titleLabel.setTextColor(textColor)
        titleLabel.maxLines = style.titleMaxLines
        var backgroundColor = appearance.resolvedBackgroundColor(context)
        val highlighted = isHighlighted && state != CYLControlState.DISABLED && style.highlightedBackgroundColor != null
        if (highlighted) backgroundColor = style.highlightedBackgroundColor!!
        // The background is CYLAnimatedItemView's: the flat color, or Liquid Glass tinted with it where the device draws it.
        itemBackgroundStyle = if (style.backgroundStyle == CYLTagBackgroundStyle.CYLTagBackgroundStyleLiquidGlass) {
            CYLAnimatedItemBackgroundStyle.LiquidGlass
        } else {
            CYLAnimatedItemBackgroundStyle.Flat
        }
        // Where glass is really drawn only an EXPLICIT color tints it: an unset one (the built-in default, which would hide the
        // backdrop) is null and the view uses its frosted default. The pressed color is always explicit. Flat keeps the effective color.
        val drawsGlass = style.resolvedBackgroundStyle == CYLTagBackgroundStyle.CYLTagBackgroundStyleLiquidGlass
        itemBackgroundColor = if (drawsGlass && !highlighted) appearance.explicitBackgroundColor else backgroundColor
        // A selected Liquid Glass tag keeps its full color (tint alpha 1, still glass); the other states tint at the view's default share.
        itemGlassTintAlpha = if (state == CYLControlState.SELECTED) 1f else null
        // Dark glass icon lift: only where glass is drawn, in night mode, for an EXPLICIT icon color; never otherwise.
        val explicitIconColor = style.explicitIconColorForState(state)
        if (drawsGlass && CYLSystemColors.isNight(context) && explicitIconColor != null) {
            val lifted = CYLIconContrast.liftedIconColor(explicitIconColor, itemBackgroundColor, itemGlassTintAlpha)
            if (lifted != explicitIconColor && iconView.drawable.let { it !is CYLBadgeDrawable && it !is CYLOriginalImageDrawable }) {
                imageView.setColorFilter(lifted)
            }
        }
        // The appearance's radius (CYLAnimatedItemCornerRadiusCapsule by default, 0 is square), set with the style and not
        // only when the tag is laid out: the view's own default (null) is square for flat.
        itemCornerRadius = appearance.cornerRadius
        backgroundImageView.setImageDrawable(appearance.backgroundImage)
        backgroundImageView.visibility = if (appearance.backgroundImage == null || highlighted) GONE else VISIBLE
        // With the rename indicator, editingIndicatorsView draws both icons instead.
        val editingIcons = showsDeleteIndicator && showsRenameIndicator
        drawsCross = showsDeleteIndicator && style.deleteIndicatorLineWidth > 0 && !editingIcons
        // Kept visible (and empty) under a drawn cross, so that a tap on it still reaches the accessory.
        deleteIndicatorLabel.visibility = if (showsDeleteIndicator) VISIBLE else GONE
        deleteIndicatorLabel.text = if (showsDeleteIndicator && !drawsCross && !editingIcons) style.deleteIndicatorTitle else null
        if (editingIcons || editingIndicatorsViewIsLoaded) {
            editingIndicatorsView.visibility = if (editingIcons) VISIBLE else GONE
            editingIndicatorsView.iconColor = style.deleteIndicatorColor ?: textColor
        }
        deleteIndicatorLabel.contentDescription = if (showsDeleteIndicator) CYLMenuLocalizedString("CYLMenuDeleteTag", "Deletes a tag") else null
        val placement = if (style.deleteIndicatorPlacement == CYLTagDeleteIndicatorPlacement.CYLTagDeleteIndicatorPlacementLeading)
            CYLAnimatedItemAccessoryPlacement.Leading else CYLAnimatedItemAccessoryPlacement.Trailing
        if (accessoryPlacement != placement) accessoryPlacement = placement
        crossPaint.strokeWidth = style.deleteIndicatorLineWidth * density
        crossPaint.color = style.deleteIndicatorColor ?: textColor
        val deleteFont = style.deleteIndicatorFontForState(state)
        deleteIndicatorLabel.setTextSize(TypedValue.COMPLEX_UNIT_DIP, deleteFont.size)
        deleteIndicatorLabel.typeface = deleteFont.typeface
        deleteIndicatorLabel.setTextColor(style.deleteIndicatorColor ?: textColor)
        // Where glass is really drawn only an EXPLICIT border (setter, configuration, preset) is handed over: the built-in default
        // border of the state is dropped (no border, width 0), so the glass's own rim shows. Flat keeps the default border.
        val dropsDefaultBorder = drawsGlass && !appearance.hasExplicitBorder
        val styleBorderColor = if (dropsDefaultBorder) null else appearance.borderColor
        val styleBorderWidth = if (dropsDefaultBorder) 0f else appearance.borderWidth
        var borderColor = styleBorderColor
        var borderWidth = if (borderColor != null) styleBorderWidth else 0f
        if (CYLAccessibility.isIncreaseContrastEnabled(context)) {
            borderColor = if (state == CYLControlState.SELECTED) styleBorderColor ?: textColor else textColor
            borderWidth = max(1f, styleBorderWidth)
        }
        // At least one pixel, as before; CYLAnimatedItemView draws the border.
        itemBorderWidth = if (borderWidth > 0) max(1f / density, borderWidth) else 0f
        itemBorderColor = borderColor
        val badge = badgeValue
        badgeLabel.visibility = if (badge == null) GONE else VISIBLE
        badgeLabel.text = if (badge.isNullOrEmpty()) null else badge
        badgeBox.setColor(badgeColor ?: CYLTagBadgeDefaultColor)
        updateAccessibility()
        requestLayout()
        invalidate()
    }

    override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
        val iconSize = if (animationView != null) animationSize() else iconSizeForImage(imageView.drawable, false, currentStyle)
        // The measured width counts the space the shape asks for between the border and the title, as the layout will use it.
        val width = px(widthForTitleWithInset(rawTitle?.toString(), iconSize, showsDeleteIndicator, showsRenameIndicator, currentStyle,
            resolvedItemContentHorizontalInset))
        // Side by side: the style's height, as in a tag list; stacked: the icon, the spacing and the title.
        val height = px(if (currentStyle.imagePlacement.isVertical) heightForTitle(rawTitle?.toString(), iconSize, currentStyle) else heightForStyle(currentStyle))
        setMeasuredDimension(resolveSize(width, widthMeasureSpec), resolveSize(height, heightMeasureSpec))
        for (index in 0 until childCount) {
            getChildAt(index).measure(MeasureSpec.makeMeasureSpec(0, MeasureSpec.UNSPECIFIED), MeasureSpec.makeMeasureSpec(0, MeasureSpec.UNSPECIFIED))
        }
    }

    override fun onLayout(changed: Boolean, l: Int, t: Int, r: Int, b: Int) {
        val style = currentStyle
        var width = (r - l) / density
        val height = (b - t) / density
        val state = currentState()
        val appearance = style.appearanceForState(state)
        // Left and right at least the shape's inset (14 on a drawn Liquid Glass tag, 0 on flat), as the measured width counted it.
        val sideInset = resolvedItemContentHorizontalInset
        val insets = appearance.contentInsets.let { it.copy(left = max(it.left, sideInset), right = max(it.right, sideInset)) }
        backgroundImageView.layout(0, 0, r - l, b - t)
        var deleteWidth = 0f
        if (showsDeleteIndicator && showsRenameIndicator) {
            deleteWidth = layOutEditingIndicators(editingIconSide(state, style), insets, width, height)
            crossPath.reset()
        } else if (showsDeleteIndicator) {
            renameIndicatorHitFrame = CYLRect()
            val indicatorWidth = deleteIndicatorWidthForState(state, style)
            deleteWidth = indicatorWidth + style.imageTitleSpacing
            val leadingIndicator = style.deleteIndicatorPlacement == CYLTagDeleteIndicatorPlacement.CYLTagDeleteIndicatorPlacementLeading
            val indicatorX = if (leadingIndicator) insets.left else max(insets.left, width - insets.right - indicatorWidth)
            val indicator = CYLRect(indicatorX, insets.top, indicatorWidth, max(0f, height - insets.top - insets.bottom))
            place(deleteIndicatorLabel, indicator)
            deleteIndicatorHitFrame = if (leadingIndicator) {
                CYLRect(0f, 0f, min(width, indicator.maxX + style.imageTitleSpacing), height)
            } else {
                val hitX = max(0f, indicatorX - style.imageTitleSpacing)
                CYLRect(hitX, 0f, width - hitX, height)
            }
            var side = max(0f, min(indicator.width, indicator.height) - 2 * style.deleteIndicatorPadding)
            if (style.deleteIndicatorLineWidth > 0 && style.deleteIndicatorWidth <= 0) side = max(0f, indicator.width - 2 * style.deleteIndicatorPadding)
            val cx = indicator.x + indicator.width / 2
            val cy = indicator.y + indicator.height / 2
            crossPath.reset()
            crossPath.moveTo((cx - side / 2) * density, (cy - side / 2) * density)
            crossPath.lineTo((cx + side / 2) * density, (cy + side / 2) * density)
            crossPath.moveTo((cx + side / 2) * density, (cy - side / 2) * density)
            crossPath.lineTo((cx - side / 2) * density, (cy + side / 2) * density)
        } else {
            place(deleteIndicatorLabel, CYLRect())
            deleteIndicatorHitFrame = CYLRect()
            renameIndicatorHitFrame = CYLRect()
            crossPath.reset()
        }
        if (!(showsDeleteIndicator && showsRenameIndicator) && editingIndicatorsViewIsLoaded) place(editingIndicatorsView, CYLRect())
        val indicatorFirst = showsDeleteIndicator && style.deleteIndicatorPlacement == CYLTagDeleteIndicatorPlacement.CYLTagDeleteIndicatorPlacementLeading
        val margin = insets.left + if (indicatorFirst) deleteWidth else 0f
        val trailing = insets.right + if (indicatorFirst) 0f else deleteWidth
        val contentTop = insets.top
        val contentHeight = max(0f, height - insets.top - insets.bottom)
        width -= trailing - margin
        val animated = animationView != null
        val showsImage = animated || imageView.drawable != null
        val showsTitle = !titleLabel.text.isNullOrEmpty()
        val iconSize = if (animated) animationSize() else iconSizeForImage(imageView.drawable, false, style)
        val spacing = if (showsImage && showsTitle) style.imageTitleSpacing else 0f
        val available = max(0f, width - 2 * margin - if (showsImage) iconSize.width + spacing else 0f)
        val titleSize = if (showsTitle) CYLSize(titleLabel.paint.measureText(titleLabel.text.toString()) / density, lineHeight(titleLabel.paint)) else CYLSize.ZERO
        var titleWidth = fitTitle(available, ceil(titleSize.width))
        var titleHeight = min(height, ceil(titleSize.height))
        // A title that may wrap (CYLMenuStyle.titleMaxLines above 1) takes as many lines as fit its width, up to the limit.
        if (showsTitle && style.titleMaxLines > CYLTagTitleMaxLines.SINGLE && !style.imagePlacement.isVertical) {
            titleHeight = min(height, ceil(wrappedTextHeight(titleLabel.text.toString(), style.titleFontForState(currentState()), titleWidth, style.titleMaxLines)))
        }
        var imageX = 0f
        var titleX = 0f
        var imageY = centeredY(iconSize.height, contentTop, contentHeight, height)
        var titleY = centeredY(titleHeight, contentTop, contentHeight, height)
        val leading = style.contentAlignment == CYLTagContentAlignment.CYLTagContentAlignmentLeading
        if (style.imagePlacement.isVertical) {
            // Stacked: each centered (or at the leading margin), the group centered between the insets.
            titleWidth = fitTitle(max(0f, width - 2 * margin), ceil(titleSize.width))
            imageX = if (leading) margin else floor((width - iconSize.width) / 2)
            titleX = if (leading) margin else floor((width - titleWidth) / 2)
            val group = (if (showsImage) iconSize.height else 0f) + spacing + (if (showsTitle) titleHeight else 0f)
            val top = centeredY(group, contentTop, contentHeight, height)
            if (style.imagePlacement == CYLTagImagePlacement.CYLTagImagePlacementBottom) {
                titleY = top
                imageY = top + if (showsTitle) titleHeight + spacing else 0f
            } else {
                imageY = top
                titleY = top + if (showsImage) iconSize.height + spacing else 0f
            }
        } else if (showsImage && showsTitle) {
            val group = iconSize.width + spacing + titleWidth
            val start = if (leading) margin else floor((width - group) / 2)
            if (style.imagePlacement == CYLTagImagePlacement.CYLTagImagePlacementTrailing) {
                titleX = start
                imageX = titleX + titleWidth + spacing
            } else {
                imageX = start
                titleX = imageX + iconSize.width + spacing
            }
        } else if (showsImage && leading) {
            imageX = margin
        } else if (showsTitle && leading) {
            titleX = margin
            titleWidth = fitTitle(max(0f, width - 2 * margin), titleWidth)
        } else if (showsImage) {
            imageX = if (style.layoutCentered) floor((width - iconSize.width) / 2) else margin
        } else if (showsTitle) {
            titleX = if (style.layoutCentered) floor((width - titleWidth) / 2) else margin + style.imageSize.width + style.imageTitleSpacing
            titleWidth = fitTitle(max(0f, width - margin - titleX), titleWidth)
        }
        if (showsTitle) {
            place(titleLabel, CYLRect(titleX + style.titlePositionAdjustment.horizontal,
                titleY + style.titlePositionAdjustment.vertical, titleWidth, titleHeight))
        } else {
            place(titleLabel, CYLRect())
        }
        if (showsImage) {
            val insetsOfImage = style.imageInsets
            val frame = CYLRect(imageX + style.imagePositionAdjustment.horizontal,
                imageY + style.imagePositionAdjustment.vertical,
                max(0f, iconSize.width - insetsOfImage.left - insetsOfImage.right), max(0f, iconSize.height - insetsOfImage.top - insetsOfImage.bottom))
            // The animation view and, under it, the static image (the base class shows it until the animation shows).
            animationView?.let { place(it, frame) }
            place(imageView, frame)
            layOutBadge(frame, width + trailing - margin, height)
        } else {
            place(imageView, CYLRect())
            val titleFrame = CYLRect(titleX + style.titlePositionAdjustment.horizontal, titleY + style.titlePositionAdjustment.vertical, titleWidth, titleHeight)
            layOutBadge(if (showsTitle) titleFrame else CYLRect(insets.left, insets.top, width - 2 * margin, contentHeight), width + trailing - margin, height)
        }
        val imageRadius = style.imageCornerRadius
        imageView.clipToOutline = imageRadius > 0
        if (imageRadius > 0) {
            imageView.scaleType = ImageView.ScaleType.CENTER_CROP
            val radius = min(imageRadius, min(style.imageSize.width, style.imageSize.height) / 2) * density
            imageView.outlineProvider = object : android.view.ViewOutlineProvider() {
                override fun getOutline(view: View, outline: android.graphics.Outline) {
                    outline.setRoundRect(0, 0, view.width, view.height, radius)
                }
            }
        }
        // CYLAnimatedItemView applies it, limited to half the height, with the background and the border: the appearance's number
        // (CYLAnimatedItemCornerRadiusCapsule by default, 0 is square).
        itemCornerRadius = appearance.cornerRadius
    }

    /** `badgeFrame`: the badge's frame in this view, dp (`CYLRect()` while it is hidden). */
    var badgeFrame: CYLRect = CYLRect()
        private set

    /**
     * The badge at the top trailing corner of `anchor` (dp): the center of its leading cap on the corner, kept inside
     * the tag (which clips its content).
     */
    private fun layOutBadge(anchor: CYLRect, boundsWidth: Float, boundsHeight: Float) {
        val badge = badgeValue
        if (badge == null) {
            badgeFrame = CYLRect()
            place(badgeLabel, badgeFrame)
            return
        }
        val isDot = badge.isEmpty()
        val font = CYLFont(BADGE_FONT_SIZE, android.graphics.Typeface.DEFAULT_BOLD)
        val badgeHeight = if (isDot) BADGE_DOT_DIAMETER else max(BADGE_MINIMUM_HEIGHT, ceil(fontLineHeight(font)) + 2)
        val badgeWidth = if (isDot) badgeHeight else max(badgeHeight, ceil(textWidth(badge, font)) + 2 * BADGE_PADDING)
        val x = max(0f, min(anchor.maxX - badgeHeight / 2, boundsWidth - badgeWidth))
        val y = max(0f, min(anchor.y - badgeHeight / 2, boundsHeight - badgeHeight))
        badgeFrame = CYLRect(x, y, badgeWidth, badgeHeight)
        badgeBox.cornerRadius = badgeHeight / 2 * density
        place(badgeLabel, badgeFrame)
        badgeLabel.bringToFront()
    }

    /** What TalkBack reads for the badge: its text, or "New" (localized) for a dot; null without a badge. */
    private fun badgeAccessibilityValue(): String? {
        val badge = badgeValue ?: return null
        return if (badge.isEmpty()) CYLMenuLocalizedString("CYLTagBadgeDot", "A badge shown as a dot") else badge
    }

    /** The title (or the content description) and then the badge, as iOS reads the label and the value. */
    override fun onInitializeAccessibilityNodeInfo(info: AccessibilityNodeInfo) {
        super.onInitializeAccessibilityNodeInfo(info)
        val value = badgeAccessibilityValue() ?: return
        val label = contentDescription?.toString()?.takeIf { it.isNotEmpty() }
            ?: currentStyle.displayedTitleForTitle(rawTitle?.toString()).takeIf { it.isNotEmpty() }
            ?: (image as? CYLBadgeDrawable)?.accessibilityLabel
        info.contentDescription = listOfNotNull(label, value).joinToString(", ")
    }

    override fun onDraw(canvas: Canvas) {
        super.onDraw(canvas)
        if (drawsCross) canvas.drawPath(crossPath, crossPaint)
    }

    /**
     * Measures `view` at the size of `frame`, then lays it out there: a container (the engine's Rive view wraps a
     * RiveAnimationView at MATCH_PARENT) lays its children out by their measured sizes, which stay 0 × 0 without it.
     */
    /**
     * The pencil and the cross of `editingIndicatorsView`, each `side` wide, at the delete indicator's place; the
     * pencil's tap area is on its side, the cross's on the other. Returns the width they take with their spacing, dp.
     */
    private fun layOutEditingIndicators(side: Float, insets: CYLEdgeInsets, width: Float, height: Float): Float {
        val style = currentStyle
        val spacing = max(0f, style.editingIndicatorSpacing)
        val m = style.editingIndicatorInsets
        val left = max(0f, m.left)
        val right = max(0f, m.right)
        val top = max(0f, m.top)
        val bottom = max(0f, m.bottom)
        val total = left + 2 * side + spacing + right
        val leading = style.deleteIndicatorPlacement == CYLTagDeleteIndicatorPlacement.CYLTagDeleteIndicatorPlacementLeading
        val x = if (leading) insets.left else max(insets.left, width - insets.right - total)
        val outer = CYLRect(x, insets.top, total, max(0f, height - insets.top - insets.bottom))
        val area = CYLRect(outer.x + left, outer.y + top, max(0f, outer.width - left - right), max(0f, outer.height - top - bottom))
        // Each icon's slot is `side` wide; the glyph fills it (iOS 3af1b7cd: the slot is the cap height x 1.25).
        val glyph = max(0f, min(side, area.height))
        val stack = editingIndicatorsView
        // The slots are `side` wide, so the stack's spacing is the editing spacing itself.
        if (stack.spacingDp != spacing) stack.spacingDp = spacing
        stack.itemViews.forEach { icon ->
            icon.iconSizeDp = com.cyl.animateditem.CYLSize(glyph, glyph)
            val params = (icon.layoutParams as? android.widget.LinearLayout.LayoutParams)
                ?: android.widget.LinearLayout.LayoutParams(0, 0)
            params.width = px(side)
            params.height = px(area.height)
            icon.layoutParams = params
        }
        place(stack, area)
        place(deleteIndicatorLabel, CYLRect())
        val middle = area.x + side + spacing / 2
        if (leading) {
            renameIndicatorHitFrame = CYLRect(0f, 0f, middle, height)
            deleteIndicatorHitFrame = CYLRect(middle, 0f, max(0f, outer.maxX + style.imageTitleSpacing - middle), height)
        } else {
            val start = max(0f, outer.x - style.imageTitleSpacing)
            renameIndicatorHitFrame = CYLRect(start, 0f, max(0f, middle - start), height)
            deleteIndicatorHitFrame = CYLRect(middle, 0f, max(0f, width - middle), height)
        }
        return total + style.imageTitleSpacing
    }

    /**
     * The title's width: `needed`, unless `limit` is short of it by more than a device pixel. The list rounds a cell's
     * edges to pixels, so a tag measured at 262.5 px can be laid out at 262 px; clamping the title to that lost its last
     * pixel and TextView ended "Book Club" with "…" (API 37, 420 dpi). Under a pixel it now spills into the inset.
     */
    private fun fitTitle(limit: Float, needed: Float): Float = if (needed - limit <= 1.01f / density) needed else min(limit, needed)

    private fun place(view: View, frame: CYLRect) {
        // Never narrower than the frame: rounding both edges could take a pixel off a title that just fits.
        val width = maxOf(0, px(frame.maxX) - px(frame.x), ceil(frame.width * density - 0.01f).toInt())
        val height = maxOf(0, px(frame.maxY) - px(frame.y))
        // Children are measured UNSPECIFIED in onMeasure; a view laid out narrower than that keeps its old text layout
        // and is clipped (PR #17). Measuring it at its frame lets the title's maxLines = 1 + ellipsize = END end it with
        // "…", and gives an animation view (Rive) its real size.
        view.measure(MeasureSpec.makeMeasureSpec(width, MeasureSpec.EXACTLY), MeasureSpec.makeMeasureSpec(height, MeasureSpec.EXACTLY))
        view.layout(px(frame.x), px(frame.y), px(frame.x) + width, px(frame.y) + height)
    }

    companion object {
        private val systemDensity: Float get() = Resources.getSystem().displayMetrics.density

        private fun centeredY(size: Float, contentTop: Float, contentHeight: Float, height: Float): Float =
            if (size <= contentHeight) contentTop + floor((contentHeight - size) / 2) else floor((height - size) / 2)

        private val states = listOf(CYLControlState.NORMAL, CYLControlState.SELECTED, CYLControlState.DISABLED)

        private fun paintFor(font: CYLFont): Paint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            textSize = font.size * systemDensity
            typeface = font.typeface
        }

        private fun lineHeight(paint: Paint): Float {
            val metrics = paint.fontMetrics
            return (metrics.descent - metrics.ascent) / systemDensity
        }

        /**
         * The height of [text] in [font] wrapped to [width] dp and cut at [maxLines] lines, dp: what a title that may wrap needs.
         */
        internal fun wrappedTextHeight(text: String, font: CYLFont, width: Float, maxLines: Int): Float {
            val line = ceil(fontLineHeight(font))
            if (text.isEmpty() || width <= 0f) return line
            val paint = android.text.TextPaint(paintFor(font))
            val layout = android.text.StaticLayout.Builder.obtain(text, 0, text.length, paint, max(1, ceil(width * systemDensity).toInt()))
                .setMaxLines(maxLines).setIncludePad(false).build()
            return max(line, min(layout.lineCount, maxLines) * line)
        }

        /**
         * The height of a tag [width] dp wide whose title may wrap ([CYLMenuStyle.titleMaxLines] above 1): the title wrapped to
         * the room it has beside the icon and the delete indicator, cut at the limit, plus the insets; at least
         * [heightForTitle]. A one-line style, or an icon above or below the title, keeps [heightForTitle].
         */
        @JvmStatic
        fun heightForTitleWidth(title: String?, iconSize: CYLSize, width: Float, showsDeleteIndicator: Boolean, style: CYLMenuStyle): Float {
            val single = heightForTitle(title, iconSize, style)
            val text = style.displayedTitleForTitle(title)
            if (style.titleMaxLines <= CYLTagTitleMaxLines.SINGLE || text.isEmpty() || style.imagePlacement.isVertical) return single
            var height = single
            for (state in states) {
                val insets = style.appearanceForState(state).contentInsets
                var room = width - insets.left - insets.right
                if (iconSize.width > 0) room -= iconSize.width + style.imageTitleSpacing
                if (showsDeleteIndicator) room -= style.imageTitleSpacing + deleteIndicatorWidthForState(state, style)
                val lines = wrappedTextHeight(text, style.titleFontForState(state), room, style.titleMaxLines)
                height = max(height, ceil(lines + insets.top + insets.bottom))
            }
            return height
        }

        /** The width of `text` in `font`, dp (`-sizeWithAttributes:`). */
        internal fun textWidth(text: String, font: CYLFont): Float = paintFor(font).measureText(text) / systemDensity

        /** The line height of `font`, dp (`UIFont.lineHeight`). */
        internal fun fontLineHeight(font: CYLFont): Float = lineHeight(paintFor(font))

        private const val BADGE_DOT_DIAMETER = 8f
        private const val BADGE_MINIMUM_HEIGHT = 16f
        private const val BADGE_PADDING = 4f
        private const val BADGE_FONT_SIZE = 11f

        /**
         * `+isAnimationEngineAvailable`: CYLTabBarController's animation engine is linked. It comes with the
         * `cyltabbarcontroller-animateditem` dependency, so it always is; each file type plays once its library is in the
         * app (Lottie, libpag, rive-android, SVGAPlayer; GIF needs none).
         */
        @JvmStatic
        fun isAnimationEngineAvailable(): Boolean = true

        private fun iconSize(image: Drawable?, style: CYLMenuStyle): CYLSize {
            if (image == null) return CYLSize.ZERO
            if (style.imageSize != CYLSize.ZERO) return style.imageSize
            return CYLSize(image.intrinsicWidth / systemDensity, image.intrinsicHeight / systemDensity)
        }

        /** `+iconSizeForImage:animated:style:`. */
        @JvmStatic
        fun iconSizeForImage(image: Drawable?, animated: Boolean, style: CYLMenuStyle): CYLSize {
            if (animated && isAnimationEngineAvailable()) {
                return if (style.animationSize == CYLSize.ZERO) style.imageSize else style.animationSize
            }
            return iconSize(image, style)
        }

        /** `+widthForTitle:image:style:traitCollection:`. */
        @JvmStatic
        fun widthForTitle(title: String?, image: Drawable?, style: CYLMenuStyle): Float = widthForTitle(title, iconSize(image, style), false, style)

        /** `+widthForTitle:iconSize:style:traitCollection:`. */
        @JvmStatic
        fun widthForTitle(title: String?, iconSize: CYLSize, style: CYLMenuStyle): Float = widthForTitle(title, iconSize, false, style)

        /** The cap height of `font`, dp (the height of "H"). */
        internal fun fontCapHeight(font: CYLFont): Float {
            val bounds = android.graphics.Rect()
            paintFor(font).getTextBounds("H", 0, 1, bounds)
            // Without glyph bounds (a test runtime), about 0.7 of the size, as HarmonyOS and the mini program use.
            if (bounds.height() <= 0) return font.size * 0.7f
            return bounds.height() / Resources.getSystem().displayMetrics.density
        }

        /** The side of one editing icon (the pencil or the cross): the title's cap height x 1.25 (iOS 3af1b7cd). */
        internal fun editingIconSide(state: Int, style: CYLMenuStyle): Float = ceil(fontCapHeight(style.titleFontForState(state)) * 1.25f)

        /** The width of the two editing icons with the space between and around them, dp. */
        private fun editingIndicatorsWidth(state: Int, style: CYLMenuStyle): Float {
            val m = style.editingIndicatorInsets
            return max(0f, m.left) + 2 * editingIconSide(state, style) + max(0f, style.editingIndicatorSpacing) + max(0f, m.right)
        }

        private fun deleteIndicatorWidthForState(state: Int, style: CYLMenuStyle): Float {
            if (style.deleteIndicatorWidth > 0) return style.deleteIndicatorWidth
            val font = style.deleteIndicatorFontForState(state)
            if (style.deleteIndicatorLineWidth > 0) return ceil(fontLineHeight(font) * 0.75f) + 2 * style.deleteIndicatorPadding
            return ceil(textWidth(style.deleteIndicatorTitle, font))
        }

        /** `+widthForTitle:iconSize:showsDeleteIndicator:style:traitCollection:`: the widest of the three states, dp. */
        @JvmStatic
        fun widthForTitle(title: String?, iconSize: CYLSize, showsDeleteIndicator: Boolean, style: CYLMenuStyle): Float =
            widthForTitle(title, iconSize, showsDeleteIndicator, false, style)

        /**
         * `+widthForTitle:iconSize:showsDeleteIndicator:showsRenameIndicator:style:traitCollection:`: with the rename
         * indicator, the two editing icons replace the delete indicator.
         */
        @JvmStatic
        fun widthForTitle(title: String?, iconSize: CYLSize, showsDeleteIndicator: Boolean, showsRenameIndicator: Boolean,
                          style: CYLMenuStyle): Float =
            widthForTitleWithInset(title, iconSize, showsDeleteIndicator, showsRenameIndicator, style, styleContentInset(style))

        /**
         * The space between the border and the content, left and right, that the style's shape asks for: [CYLAnimatedItemLiquidGlassContentInset] for a
         * Liquid Glass style where the glass is really drawn (the same condition as the capsule), else 0. The effective inset is the larger of this
         * and the appearance's content inset.
         */
        internal fun styleContentInset(style: CYLMenuStyle): Float =
            if (style.backgroundStyle == CYLTagBackgroundStyle.CYLTagBackgroundStyleLiquidGlass && CYLAnimatedItemView.isLiquidGlassActive()) {
                CYLAnimatedItemLiquidGlassContentInset
            } else {
                0f
            }

        private fun widthForTitleWithInset(title: String?, iconSize: CYLSize, showsDeleteIndicator: Boolean, showsRenameIndicator: Boolean,
                                           style: CYLMenuStyle, sideInset: Float): Float {
            val editingIcons = showsDeleteIndicator && showsRenameIndicator
            val text = style.displayedTitleForTitle(title)
            var width = style.minimumTagSize.width
            for (state in states) {
                val appearance = style.appearanceForState(state)
                val titleWidth = if (text.isNotEmpty()) ceil(textWidth(text, style.titleFontForState(state))) else 0f
                var content = titleWidth + iconSize.width
                if (style.imagePlacement.isVertical) {
                    // Stacked: the wider of the two.
                    content = max(titleWidth, iconSize.width)
                } else if (titleWidth > 0 && iconSize.width > 0) {
                    content += style.imageTitleSpacing
                } else if (titleWidth > 0 && !style.layoutCentered && style.contentAlignment == CYLTagContentAlignment.CYLTagContentAlignmentCenter) {
                    content += style.imageSize.width + style.imageTitleSpacing
                }
                if (editingIcons) content += style.imageTitleSpacing + editingIndicatorsWidth(state, style)
                else if (showsDeleteIndicator) content += style.imageTitleSpacing + deleteIndicatorWidthForState(state, style)
                width = max(width, ceil(content + max(appearance.contentInsets.left, sideInset) + max(appearance.contentInsets.right, sideInset)))
            }
            return width
        }

        /**
         * `+heightForStyle:traitCollection:`: the item height, or the tallest state's text plus insets, dp; with the icon
         * above or below the title, also the icon slot and the spacing.
         */
        @JvmStatic
        fun heightForStyle(style: CYLMenuStyle): Float {
            val iconHeight = if (style.imagePlacement.isVertical) max(style.imageSize.height, style.animationSize.height) else 0f
            val stacked = if (iconHeight > 0) iconHeight + style.imageTitleSpacing else 0f
            var height = max(style.itemHeight, style.minimumTagSize.height)
            for (state in states) {
                val insets = style.appearanceForState(state).contentInsets
                height = max(height, ceil(fontLineHeight(style.titleFontForState(state))) + stacked + insets.top + insets.bottom)
            }
            return height
        }

        /**
         * `+heightForTitle:iconSize:style:traitCollection:`: the height a tag needs for this title and an icon of
         * `iconSize` (`CYLSize.ZERO` for none) in every state, dp: the taller of the two side by side, or both and the
         * spacing when stacked; at least `style.itemHeight`.
         */
        @JvmStatic
        fun heightForTitle(title: String?, iconSize: CYLSize, style: CYLMenuStyle): Float {
            val hasTitle = style.displayedTitleForTitle(title).isNotEmpty()
            var height = max(style.itemHeight, style.minimumTagSize.height)
            for (state in states) {
                val insets = style.appearanceForState(state).contentInsets
                val line = if (hasTitle) ceil(fontLineHeight(style.titleFontForState(state))) else 0f
                val content = if (style.imagePlacement.isVertical) {
                    line + iconSize.height + if (hasTitle && iconSize.height > 0) style.imageTitleSpacing else 0f
                } else {
                    max(line, iconSize.height)
                }
                height = max(height, ceil(content + insets.top + insets.bottom))
            }
            return height
        }
    }
}

/** `UIColor.systemRed`, the default `CYLTagButton.badgeColor`. */
val CYLTagBadgeDefaultColor: Int = Color.rgb(255, 59, 48)



/**
 * The system accessibility settings the core follows: Reduce Motion (Remove animations) and Increase Contrast (High
 * contrast text).
 */
object CYLAccessibility {
    /** `UIAccessibilityIsReduceMotionEnabled()`: the animator duration scale is 0. */
    @JvmStatic
    fun isReduceMotionEnabled(context: Context): Boolean =
        Settings.Global.getFloat(context.contentResolver, Settings.Global.ANIMATOR_DURATION_SCALE, 1f) == 0f

    /** `UIAccessibilityDarkerSystemColorsEnabled()`: High contrast text. */
    @JvmStatic
    fun isIncreaseContrastEnabled(context: Context): Boolean =
        Settings.Secure.getInt(context.contentResolver, "high_text_contrast_enabled", 0) == 1
}
