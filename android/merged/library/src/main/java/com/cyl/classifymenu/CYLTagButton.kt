package com.cyl.classifymenu

import android.content.Context
import android.content.res.Resources
import android.graphics.Canvas
import android.graphics.Paint
import android.graphics.Path
import android.graphics.RectF
import android.graphics.drawable.Drawable
import android.graphics.drawable.GradientDrawable
import android.net.Uri
import android.provider.Settings
import android.text.TextUtils
import android.util.AttributeSet
import android.util.TypedValue
import android.view.Gravity
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.TextView
import kotlin.math.ceil
import kotlin.math.floor
import kotlin.math.max
import kotlin.math.min
import kotlin.math.roundToInt

/**
 * `CYLTagButton`: one tag: an icon (or an animated icon from CYLTabBarController's animation engine, found at run
 * time), a title, an optional delete indicator (a title or a drawn cross), drawn in the style's appearance for its state
 * (normal, selected, disabled, pressed). Lengths are dp; `widthForTitle…` / `heightForStyle` measure a tag before it
 * exists.
 */
open class CYLTagButton @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null,
) : ViewGroup(context, attrs) {

    val imageView: ImageView = ImageView(context).apply { scaleType = ImageView.ScaleType.FIT_CENTER }
    val titleLabel: TextView = TextView(context).apply {
        maxLines = 1
        ellipsize = TextUtils.TruncateAt.END
        includeFontPadding = false
        gravity = Gravity.CENTER_VERTICAL
    }
    val deleteIndicatorLabel: TextView = TextView(context).apply {
        gravity = Gravity.CENTER
        includeFontPadding = false
        visibility = GONE
        importantForAccessibility = IMPORTANT_FOR_ACCESSIBILITY_NO
    }
    private val backgroundImageView = ImageView(context).apply {
        scaleType = ImageView.ScaleType.FIT_XY
        visibility = GONE
    }
    private val box = GradientDrawable()
    private val crossPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        style = Paint.Style.STROKE
        strokeCap = Paint.Cap.ROUND
    }
    private val crossPath = Path()
    private var drawsCross = false

    /** The animated icon's view (CYLTabBarController's engine), or null. */
    var animationView: View? = null
        private set

    /** The engine's player of `animationView`, or null. */
    var animationPlayer: Any? = null
        private set
    private var animationViewSize = CYLSize.ZERO

    /** The delete indicator's touch area in this view, dp (`CGRectZero` when hidden). */
    var deleteIndicatorHitFrame: CYLRect = CYLRect()
        private set

    init {
        addView(backgroundImageView)
        addView(imageView)
        addView(titleLabel)
        addView(deleteIndicatorLabel)
        background = box
        clipToOutline = true
        setWillNotDraw(false)
        isClickable = true
        isFocusable = true
    }

    private val density: Float get() = resources.displayMetrics.density
    private fun px(dp: Float): Int = (dp * density).roundToInt()

    /** The style (a copy); null resets it to the default style (null_resettable). */
    var style: CYLMenuStyle? = CYLMenuStyle.defaultStyle()
        get() = field ?: CYLMenuStyle.defaultStyle()
        set(value) {
            field = (value ?: CYLMenuStyle.defaultStyle()).copy()
            // Only the speed otherwise: an animation that is playing goes on.
            if (animationView != null && animationViewSize != animationSize()) reloadAnimationView() else applyAnimationSpeed()
            updateAppearance()
        }

    private val currentStyle: CYLMenuStyle get() = style!!

    var title: String? = null
        set(value) {
            field = value
            updateAppearance()
        }

    var image: Drawable? = null
        set(value) {
            field = value
            updateAppearance()
        }

    var selectedImage: Drawable? = null
        set(value) {
            field = value
            updateAppearance()
        }

    /** An animation file for the engine (Lottie, PAG, Rive, GIF); ignored when the engine is not linked. */
    var animationURL: Uri? = null
        set(value) {
            if (field == value && (animationView != null || value == null)) return
            field = value
            reloadAnimationView()
        }

    /** Where an unselected animation rests, 0…1 (0: the first frame). */
    var animationRestingProgress: Float = 0f
        set(value) {
            if (field == value) return
            field = value
            updateAnimationState()
        }

    var showsDeleteIndicator: Boolean = false
        set(value) {
            if (field == value) return
            field = value
            updateAppearance()
        }

    override fun setSelected(selected: Boolean) {
        val changed = selected != isSelected
        super.setSelected(selected)
        if (changed) updateAnimationState()
        updateAppearance()
    }

    override fun setEnabled(enabled: Boolean) {
        super.setEnabled(enabled)
        updateAppearance()
    }

    override fun setPressed(pressed: Boolean) {
        super.setPressed(pressed)
        updateAppearance()
    }

    /** `isHighlighted`: pressed. */
    val isHighlighted: Boolean get() = isPressed

    /**
     * `animationSpeed`: the playback speed of the animated icon, applied at once, also to an animation that is playing.
     * null (the default) uses `style.animationSpeed`. Players without a speed ignore it.
     */
    var animationSpeed: Float? = null
        set(value) {
            field = value
            applyAnimationSpeed()
        }

    /**
     * `animationLoops`: true repeats the animated icon after `playAnimation()` until it is false, the selection changes
     * or the file changes; false (the default) plays once. Turning it off lets the pass in progress finish. The engine's
     * players have no loop mode, so the tag starts the animation again when the player's `progress` reaches the end;
     * a player that does not report its progress plays once.
     */
    var animationLoops: Boolean = false
        set(value) {
            if (field == value) return
            field = value
            if (value && isPlaying) startLoopCheck() else if (!value) stopLoopCheck()
        }

    /** True from `playAnimation()` until the state is set again (selection, a new file). */
    private var isPlaying = false
    private val loopCheck = object : Runnable {
        override fun run() {
            val player = animationPlayer
            if (!animationLoops || !isPlaying || player == null || !isAttachedToWindow) return
            val progress = CYLTagAnimationEngine.getFloat(player, "getProgress") ?: return
            if (progress >= LOOP_END_PROGRESS) CYLTagAnimationEngine.call(player, "play")
            postDelayed(this, LOOP_CHECK_INTERVAL_MS)
        }
    }

    private fun startLoopCheck() {
        removeCallbacks(loopCheck)
        postDelayed(loopCheck, LOOP_CHECK_INTERVAL_MS)
    }

    private fun stopLoopCheck() {
        removeCallbacks(loopCheck)
    }

    private fun applyAnimationSpeed() {
        val speed = animationSpeed ?: currentStyle.animationSpeed
        CYLTagAnimationEngine.setFloat(animationPlayer, "setAnimationSpeed", if (speed > 0) speed else 1f)
    }

    override fun onDetachedFromWindow() {
        stopLoopCheck()
        super.onDetachedFromWindow()
    }

    /**
     * Plays the animated icon from its start (not with Remove animations / Reduce Motion); with `animationLoops`, it
     * repeats.
     */
    fun playAnimation() {
        if (CYLAccessibility.isReduceMotionEnabled(context)) {
            updateAnimationState()
            return
        }
        applyAnimationSpeed()
        CYLTagAnimationEngine.call(animationPlayer, "play")
        isPlaying = animationPlayer != null
        if (animationLoops && isPlaying) startLoopCheck()
    }

    private fun animationSize(): CYLSize {
        val size = currentStyle.animationSize
        return if (size == CYLSize.ZERO) currentStyle.imageSize else size
    }

    private fun reloadAnimationView() {
        animationView?.let { removeView(it) }
        animationView = null
        animationPlayer = null
        val url = animationURL
        // A file URL whose file is gone shows the static image; an asset (file:///android_asset/…) is not on the
        // file system, so it is never "missing" here (the engine opens it from the assets).
        val missingFile = url != null && url.scheme == "file" && url.path?.let { !it.startsWith("/android_asset/") && !java.io.File(it).exists() } == true
        if (url != null && !missingFile) {
            val size = animationSize()
            val view = CYLTagAnimationEngine.animationView(context, url.toString(), size)
            if (view != null) {
                CYLTagAnimationEngine.prepareLottieImages(context, view)
                view.isClickable = false
                view.isFocusable = false
                addView(view)
                animationView = view
                animationViewSize = size
                animationPlayer = CYLTagAnimationEngine.player(view)
            }
        }
        updateAnimationState()
        updateAppearance()
    }

    private fun updateAnimationState() {
        isPlaying = false
        stopLoopCheck()
        val player = animationPlayer ?: return
        applyAnimationSpeed()
        if (isSelected) {
            CYLTagAnimationEngine.call(player, "showLastFrame")
        } else {
            CYLTagAnimationEngine.call(player, "stop")
            val resting = min(1f, max(0f, animationRestingProgress))
            if (resting > 0) CYLTagAnimationEngine.setFloat(player, "setProgress", resting)
        }
    }

    private fun currentState(): Int = when {
        !isEnabled -> CYLControlState.DISABLED
        isSelected -> CYLControlState.SELECTED
        else -> CYLControlState.NORMAL
    }

    private fun updateAppearance() {
        val style = currentStyle
        val state = currentState()
        val appearance = style.appearanceForState(state)
        val icon = if (state == CYLControlState.SELECTED && selectedImage != null) selectedImage else image
        imageView.setImageDrawable(if (animationView != null) null else icon)
        imageView.visibility = if (animationView != null) GONE else VISIBLE
        animationView?.alpha = if (state == CYLControlState.DISABLED) 0.4f else 1f
        imageView.imageTintList = null
        imageView.setColorFilter(style.iconColorForState(state))
        if (icon is CYLBadgeDrawable || icon is CYLOriginalImageDrawable) imageView.clearColorFilter()
        titleLabel.text = style.displayedTitleForTitle(title)
        val font = style.titleFontForState(state)
        titleLabel.setTextSize(TypedValue.COMPLEX_UNIT_DIP, font.size)
        titleLabel.typeface = font.typeface
        titleLabel.setTextColor(appearance.textColor)
        var backgroundColor = appearance.backgroundColor
        val highlighted = isHighlighted && state != CYLControlState.DISABLED && style.highlightedBackgroundColor != null
        if (highlighted) backgroundColor = style.highlightedBackgroundColor!!
        box.setColor(backgroundColor)
        backgroundImageView.setImageDrawable(appearance.backgroundImage)
        backgroundImageView.visibility = if (appearance.backgroundImage == null || highlighted) GONE else VISIBLE
        drawsCross = showsDeleteIndicator && style.deleteIndicatorLineWidth > 0
        deleteIndicatorLabel.visibility = if (showsDeleteIndicator && !drawsCross) VISIBLE else GONE
        deleteIndicatorLabel.text = if (showsDeleteIndicator && !drawsCross) style.deleteIndicatorTitle else null
        crossPaint.strokeWidth = style.deleteIndicatorLineWidth * density
        crossPaint.color = style.deleteIndicatorColor ?: appearance.textColor
        val deleteFont = style.deleteIndicatorFontForState(state)
        deleteIndicatorLabel.setTextSize(TypedValue.COMPLEX_UNIT_DIP, deleteFont.size)
        deleteIndicatorLabel.typeface = deleteFont.typeface
        deleteIndicatorLabel.setTextColor(style.deleteIndicatorColor ?: appearance.textColor)
        var borderColor = appearance.borderColor
        var borderWidth = if (borderColor != null) appearance.borderWidth else 0f
        if (CYLAccessibility.isIncreaseContrastEnabled(context)) {
            borderColor = if (state == CYLControlState.SELECTED) appearance.borderColor ?: appearance.textColor else appearance.textColor
            borderWidth = max(1f, appearance.borderWidth)
        }
        box.setStroke(if (borderWidth > 0) max(1, (borderWidth * density).roundToInt()) else 0, borderColor ?: 0)
        requestLayout()
        invalidate()
    }

    override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
        val iconSize = if (animationView != null) animationSize() else iconSizeForImage(imageView.drawable, false, currentStyle)
        val width = px(widthForTitle(title, iconSize, showsDeleteIndicator, currentStyle))
        val height = px(heightForStyle(currentStyle))
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
        val insets = appearance.contentInsets
        backgroundImageView.layout(0, 0, r - l, b - t)
        var deleteWidth = 0f
        if (showsDeleteIndicator) {
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
            crossPath.reset()
        }
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
        var titleWidth = min(available, ceil(titleSize.width))
        val titleHeight = min(height, ceil(titleSize.height))
        var imageX = 0f
        var titleX = 0f
        val leading = style.contentAlignment == CYLTagContentAlignment.CYLTagContentAlignmentLeading
        if (showsImage && showsTitle) {
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
            titleWidth = min(titleWidth, max(0f, width - 2 * margin))
        } else if (showsImage) {
            imageX = if (style.layoutCentered) floor((width - iconSize.width) / 2) else margin
        } else if (showsTitle) {
            titleX = if (style.layoutCentered) floor((width - titleWidth) / 2) else margin + style.imageSize.width + style.imageTitleSpacing
            titleWidth = min(titleWidth, max(0f, width - margin - titleX))
        }
        if (showsTitle) {
            place(titleLabel, CYLRect(titleX + style.titlePositionAdjustment.horizontal,
                centeredY(titleHeight, contentTop, contentHeight, height) + style.titlePositionAdjustment.vertical, titleWidth, titleHeight))
        } else {
            place(titleLabel, CYLRect())
        }
        if (showsImage) {
            val insetsOfImage = style.imageInsets
            val frame = CYLRect(imageX + style.imagePositionAdjustment.horizontal,
                centeredY(iconSize.height, contentTop, contentHeight, height) + style.imagePositionAdjustment.vertical,
                max(0f, iconSize.width - insetsOfImage.left - insetsOfImage.right), max(0f, iconSize.height - insetsOfImage.top - insetsOfImage.bottom))
            if (animated) {
                place(animationView!!, frame)
                place(imageView, CYLRect())
            } else {
                place(imageView, frame)
            }
        } else {
            place(imageView, CYLRect())
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
        val corner = appearance.cornerRadius
        val radius = if (corner > 0) (if (corner <= CYLTagCornerRadiusSquare) 0f else min(corner, height / 2)) else height / 2
        box.cornerRadius = radius * density
    }

    override fun onDraw(canvas: Canvas) {
        super.onDraw(canvas)
        if (drawsCross) canvas.drawPath(crossPath, crossPaint)
    }

    /**
     * Measures `view` at the size of `frame`, then lays it out there: a container (the engine's Rive view wraps a
     * RiveAnimationView at MATCH_PARENT) lays its children out by their measured sizes, which stay 0 × 0 without it.
     */
    private fun place(view: View, frame: CYLRect) {
        val width = maxOf(0, px(frame.maxX) - px(frame.x))
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

        /** The width of `text` in `font`, dp (`-sizeWithAttributes:`). */
        internal fun textWidth(text: String, font: CYLFont): Float = paintFor(font).measureText(text) / systemDensity

        /** The line height of `font`, dp (`UIFont.lineHeight`). */
        internal fun fontLineHeight(font: CYLFont): Float = lineHeight(paintFor(font))

        private const val LOOP_CHECK_INTERVAL_MS = 50L
        /** The progress from which a looping animation counts as finished and starts again. */
        private const val LOOP_END_PROGRESS = 0.995f

        /** `+isAnimationEngineAvailable`: CYLTabBarController's animation engine is linked. */
        @JvmStatic
        fun isAnimationEngineAvailable(): Boolean = CYLTagAnimationEngine.isAvailable

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

        private fun deleteIndicatorWidthForState(state: Int, style: CYLMenuStyle): Float {
            if (style.deleteIndicatorWidth > 0) return style.deleteIndicatorWidth
            val font = style.deleteIndicatorFontForState(state)
            if (style.deleteIndicatorLineWidth > 0) return ceil(fontLineHeight(font) * 0.75f) + 2 * style.deleteIndicatorPadding
            return ceil(textWidth(style.deleteIndicatorTitle, font))
        }

        /** `+widthForTitle:iconSize:showsDeleteIndicator:style:traitCollection:`: the widest of the three states, dp. */
        @JvmStatic
        fun widthForTitle(title: String?, iconSize: CYLSize, showsDeleteIndicator: Boolean, style: CYLMenuStyle): Float {
            val text = style.displayedTitleForTitle(title)
            var width = 0f
            for (state in states) {
                val appearance = style.appearanceForState(state)
                val titleWidth = if (text.isNotEmpty()) ceil(textWidth(text, style.titleFontForState(state))) else 0f
                var content = titleWidth + iconSize.width
                if (titleWidth > 0 && iconSize.width > 0) {
                    content += style.imageTitleSpacing
                } else if (titleWidth > 0 && !style.layoutCentered && style.contentAlignment == CYLTagContentAlignment.CYLTagContentAlignmentCenter) {
                    content += style.imageSize.width + style.imageTitleSpacing
                }
                if (showsDeleteIndicator) content += style.imageTitleSpacing + deleteIndicatorWidthForState(state, style)
                width = max(width, ceil(content + appearance.contentInsets.left + appearance.contentInsets.right))
            }
            return width
        }

        /** `+heightForStyle:traitCollection:`: the item height, or the tallest state's text plus insets, dp. */
        @JvmStatic
        fun heightForStyle(style: CYLMenuStyle): Float {
            var height = style.itemHeight
            for (state in states) {
                val insets = style.appearanceForState(state).contentInsets
                height = max(height, ceil(fontLineHeight(style.titleFontForState(state))) + insets.top + insets.bottom)
            }
            return height
        }
    }
}

/**
 * CYLTabBarController's animation engine, found at run time like `NSClassFromString(@"CYLTabBarItemAnimationFactory")`
 * on iOS: the core does not depend on CYLTabBarController.
 */
internal object CYLTagAnimationEngine {
    private val factory: Any? by lazy {
        try {
            Class.forName("com.cyl.tabbar.CYLTabBarItemAnimationFactory").getField("Companion").get(null)
        } catch (error: Throwable) {
            null
        }
    }

    val isAvailable: Boolean get() = factory != null

    fun animationView(context: Context, url: String, size: CYLSize): View? {
        val factory = factory ?: return null
        return try {
            val sizeClass = Class.forName("com.cyl.tabbar.CYLSize")
            val tabSize = sizeClass.getConstructor(Float::class.java, Float::class.java).newInstance(size.width, size.height)
            val method = factory.javaClass.getMethod("animationViewWithURL", Context::class.java, String::class.java, sizeClass, ImageView.ScaleType::class.java)
            method.invoke(factory, context, url, tabSize, ImageView.ScaleType.FIT_CENTER) as? View
        } catch (error: Throwable) {
            null
        }
    }

    /**
     * Gives the Lottie views in `view` an image delegate: the images of a Lottie file (its "assets" with a "p" file
     * name) load from the app's drawable of the same name, as Lottie on iOS loads them by name from the app's assets.
     * Without one, lottie-android throws when it draws an image layer ("You must set an images folder"). By reflection,
     * because the core does not depend on lottie-android.
     */
    fun prepareLottieImages(context: Context, view: View) {
        val lottieView = findView(view, "com.airbnb.lottie.LottieAnimationView") ?: return
        try {
            val delegateType = Class.forName("com.airbnb.lottie.ImageAssetDelegate")
            val delegate = java.lang.reflect.Proxy.newProxyInstance(delegateType.classLoader, arrayOf(delegateType)) { _, method, arguments ->
                if (method.name != "fetchBitmap") return@newProxyInstance null
                val asset = arguments?.firstOrNull() ?: return@newProxyInstance null
                val fileName = asset.javaClass.getMethod("getFileName").invoke(asset) as? String ?: return@newProxyInstance null
                lottieBitmap(context, fileName)
            }
            lottieView.javaClass.getMethod("setImageAssetDelegate", delegateType).invoke(lottieView, delegate)
        } catch (error: Throwable) {
            // An older lottie-android without the delegate: the engine's failure listener shows the static image.
        }
    }

    private fun lottieBitmap(context: Context, fileName: String): android.graphics.Bitmap? {
        val name = fileName.substringAfterLast('/').substringBeforeLast('.').replace('-', '_').lowercase()
        val id = context.resources.getIdentifier(name, "drawable", context.packageName)
        if (id == 0) return null
        return android.graphics.BitmapFactory.decodeResource(context.resources, id)
    }

    private fun findView(view: View, className: String): View? {
        var type: Class<*>? = view.javaClass
        while (type != null) {
            if (type.name == className) return view
            type = type.superclass
        }
        if (view is android.view.ViewGroup) for (index in 0 until view.childCount) findView(view.getChildAt(index), className)?.let { return it }
        return null
    }

    fun player(view: View): Any? {
        val factory = factory ?: return null
        return try {
            factory.javaClass.getMethod("playerForView", View::class.java).invoke(factory, view)
        } catch (error: Throwable) {
            null
        }
    }

    fun call(target: Any?, name: String) {
        target ?: return
        try {
            target.javaClass.getMethod(name).invoke(target)
        } catch (error: Throwable) {
            // The player has no such method.
        }
    }

    /** A Float getter of the player (`getProgress`), or null when it has none. */
    fun getFloat(target: Any?, name: String): Float? {
        target ?: return null
        return try {
            (target.javaClass.getMethod(name).invoke(target) as? Number)?.toFloat()
        } catch (error: Throwable) {
            null
        }
    }

    fun setFloat(target: Any?, name: String, value: Float) {
        target ?: return
        try {
            target.javaClass.getMethod(name, Float::class.java).invoke(target, value)
        } catch (error: Throwable) {
            // Optional on the player.
        }
    }
}

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
