package com.cyl.classifymenu

import android.content.res.Resources
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.net.Uri
import java.util.IdentityHashMap
import kotlin.math.max

/** `CYLTagUseListValue`: a tag length that uses the list's style (-1). */
const val CYLTagUseListValue: Float = -1f

private fun cylTagIsSet(value: Float): Boolean = value.isFinite() && value >= 0

/**
 * `CYLTag`: one tag of a `CYLTagDataSource`: its title, identifier, icons, badge, state, and the look it changes over
 * the list's style (android-tagview's `Tag`). Lengths of `CYLTagUseListValue` (-1) use the list's value.
 */
class CYLTag(
    var identifier: Int,
    title: String,
    var backgroundColor: Int?,
) {
    /** The title; null becomes "". */
    var title: String = title
        set(value) { field = value }

    var image: Drawable? = null
    var selectedImage: Drawable? = null
    var animationURL: Uri? = null
    var isEnabled: Boolean = true
    var isDeletable: Boolean = false
    var badgeText: String? = null
    var badgeColor: Int? = null
    var badgeAccessibilityLabel: String? = null
    var userInfo: Any? = null

    // Look over the list's style
    var style: CYLMenuStyle? = null
        set(value) { field = value?.copy() }
    var textColor: Int? = null
    var font: CYLFont? = null
    var textSize: Float = CYLTagUseListValue
    var highlightedBackgroundColor: Int? = null
    var selectedBackgroundColor: Int? = null
    var backgroundImage: Drawable? = null
    var cornerRadius: Float = CYLTagUseListValue
    var borderWidth: Float = CYLTagUseListValue
    var borderColor: Int? = null
    var deleteIndicatorTitle: String? = null
    var deleteIndicatorColor: Int? = null
    var deleteIndicatorSize: Float = CYLTagUseListValue

    /** `-initWithTitle:`. */
    constructor(title: String) : this(0, title, null as Int?)

    /** `-initWithTitle:backgroundColor:`. */
    constructor(title: String, backgroundColor: Int?) : this(0, title, backgroundColor)

    /** `-initWithTitle:backgroundColorHex:`. */
    constructor(title: String, backgroundColorHex: String?) : this(0, title, backgroundColorHex?.let { CYLMenuColorFromString(it) })

    /** `-initWithIdentifier:title:`. */
    constructor(identifier: Int, title: String) : this(identifier, title, null as Int?)

    /** `-initWithIdentifier:title:backgroundColorHex:`. */
    constructor(identifier: Int, title: String, backgroundColorHex: String?) :
        this(identifier, title, backgroundColorHex?.let { CYLMenuColorFromString(it) })

    /** The four colors of the tag; setting it sets them. */
    var colors: CYLTagColors
        get() = CYLTagColors(backgroundColor, borderColor, textColor, selectedBackgroundColor)
        set(value) {
            backgroundColor = value.backgroundColor
            borderColor = value.borderColor
            textColor = value.textColor
            selectedBackgroundColor = value.selectedBackgroundColor
        }

    /** Resets `colors` (null_resettable): all four colors to the list's. */
    fun resetColors() {
        colors = CYLTagColors()
    }

    /** Whether the tag changes anything of the list's style. */
    val hasCustomStyle: Boolean
        get() = style != null || textColor != null || font != null || cylTagIsSet(textSize) || backgroundColor != null ||
            highlightedBackgroundColor != null || selectedBackgroundColor != null || backgroundImage != null ||
            cylTagIsSet(cornerRadius) || cylTagIsSet(borderWidth) || borderColor != null || deleteIndicatorTitle != null ||
            deleteIndicatorColor != null || cylTagIsSet(deleteIndicatorSize)

    /** `-styleWithBaseStyle:`: the tag's style over `baseStyle` (its own `style` when set). */
    fun styleWithBaseStyle(baseStyle: CYLMenuStyle?): CYLMenuStyle {
        val result = (style ?: baseStyle ?: CYLMenuStyle.defaultStyle()).copy()
        val normal = result.normalAppearance
        val all = listOf(normal, result.selectedAppearance, result.disabledAppearance)
        textColor?.let { normal.textColor = it }
        backgroundColor?.let { normal.backgroundColor = it }
        backgroundImage?.let { normal.backgroundImage = it }
        borderColor?.let {
            normal.borderColor = it
            if (!cylTagIsSet(borderWidth) && normal.borderWidth <= 0) normal.borderWidth = 1f
        }
        val tagFont = font ?: if (cylTagIsSet(textSize) && textSize > 0) CYLFont.systemFont(textSize) else null
        for (appearance in all) {
            tagFont?.let { appearance.font = it }
            if (cylTagIsSet(cornerRadius)) appearance.cornerRadius = cornerRadius
            if (cylTagIsSet(borderWidth)) appearance.borderWidth = borderWidth
        }
        highlightedBackgroundColor?.let { result.highlightedBackgroundColor = it }
        selectedBackgroundColor?.let { result.selectedAppearance.backgroundColor = it }
        deleteIndicatorTitle?.let { result.deleteIndicatorTitle = it }
        deleteIndicatorColor?.let { result.deleteIndicatorColor = it }
        if (cylTagIsSet(deleteIndicatorSize) && deleteIndicatorSize > 0) result.deleteIndicatorFont = CYLFont.systemFont(deleteIndicatorSize)
        return result
    }

    /** NSCopying. */
    fun copy(): CYLTag = CYLTag(identifier, title, backgroundColor).also {
        it.image = image
        it.selectedImage = selectedImage
        it.animationURL = animationURL
        it.isEnabled = isEnabled
        it.isDeletable = isDeletable
        it.userInfo = userInfo
        it.style = style
        it.textColor = textColor
        it.font = font
        it.textSize = textSize
        it.highlightedBackgroundColor = highlightedBackgroundColor
        it.selectedBackgroundColor = selectedBackgroundColor
        it.badgeText = badgeText
        it.badgeColor = badgeColor
        it.badgeAccessibilityLabel = badgeAccessibilityLabel
        it.backgroundImage = backgroundImage
        it.cornerRadius = cornerRadius
        it.borderWidth = borderWidth
        it.borderColor = borderColor
        it.deleteIndicatorTitle = deleteIndicatorTitle
        it.deleteIndicatorColor = deleteIndicatorColor
        it.deleteIndicatorSize = deleteIndicatorSize
    }

    override fun toString(): String = "<CYLTag: identifier = $identifier; title = $title>"

    companion object {
        /** `+tagWithTitle:`. */
        @JvmStatic
        fun tagWithTitle(title: String) = CYLTag(title)

        /**
         * `+badgeImageWithText:color:diameter:`: a filled circle (`color`, else system blue) of `diameter` dp with `text`
         * in white bold; its `contentDescription`-like label is the text (see `CYLBadgeDrawable.accessibilityLabel`).
         */
        @JvmStatic
        fun badgeImageWithText(text: String, color: Int?, diameter: Float): Drawable {
            val density = Resources.getSystem().displayMetrics.density
            val side = max(1, (max(1f, diameter) * density).toInt())
            val bitmap = Bitmap.createBitmap(side, side, Bitmap.Config.ARGB_8888)
            val canvas = Canvas(bitmap)
            val paint = Paint(Paint.ANTI_ALIAS_FLAG)
            paint.color = color ?: Color.rgb(0, 122, 255)
            canvas.drawOval(0f, 0f, side.toFloat(), side.toFloat(), paint)
            paint.color = Color.WHITE
            paint.isFakeBoldText = true
            paint.textSize = side * 0.6f
            paint.textAlign = Paint.Align.CENTER
            val metrics = paint.fontMetrics
            canvas.drawText(text, side / 2f, side / 2f - (metrics.ascent + metrics.descent) / 2, paint)
            return CYLBadgeDrawable(Resources.getSystem(), bitmap, text)
        }
    }
}

/**
 * A badge image with the label VoiceOver/TalkBack reads (`UIImage.accessibilityLabel` on iOS).
 */
class CYLBadgeDrawable(resources: Resources, bitmap: Bitmap, var accessibilityLabel: String?) : BitmapDrawable(resources, bitmap)

/**
 * `CYLTagDataSource`: a one-section `CYLMenuDataSource` of `CYLTag`s, with a section title and the list's base style;
 * each tag's style is computed once and cached until it or the base style changes (`invalidateStyles()`).
 */
class CYLTagDataSource @JvmOverloads constructor(tags: List<CYLTag>? = null) : CYLMenuDataSource {

    private var mutableTags: MutableList<CYLTag> = ArrayList(tags.orEmpty())
    private val styles = IdentityHashMap<CYLTag, CYLMenuStyle>()
    private var _baseStyle: CYLMenuStyle? = null

    /** The tags, a copy; setting it replaces them and clears the cached styles. */
    var tags: List<CYLTag>
        get() = ArrayList(mutableTags)
        set(value) {
            mutableTags = ArrayList(value)
            invalidateStyles()
        }

    var sectionTitle: String? = null

    /** The list's style the tags change; the default style when null (null_resettable). */
    var baseStyle: CYLMenuStyle?
        get() = _baseStyle ?: CYLMenuStyle.defaultStyle()
        set(value) {
            _baseStyle = value?.copy()
            invalidateStyles()
        }

    fun addTag(tag: CYLTag) {
        mutableTags.add(tag)
    }

    fun addTags(tags: List<CYLTag>) {
        mutableTags.addAll(tags)
    }

    fun insertTag(tag: CYLTag, atIndex: Int) {
        mutableTags.add(atIndex.coerceIn(0, mutableTags.size), tag)
    }

    fun removeTagAtIndex(index: Int) {
        if (index in mutableTags.indices) {
            styles.remove(mutableTags[index])
            mutableTags.removeAt(index)
        }
    }

    fun removeAllTags() {
        mutableTags.clear()
        invalidateStyles()
    }

    fun moveTagAtIndex(fromIndex: Int, toIndex: Int) {
        if (fromIndex !in mutableTags.indices || toIndex !in mutableTags.indices || fromIndex == toIndex) return
        val tag = mutableTags.removeAt(fromIndex)
        mutableTags.add(toIndex, tag)
    }

    fun invalidateStyles() {
        styles.clear()
    }

    private fun tagAt(indexPath: CYLIndexPath): CYLTag? =
        if (indexPath.section == 0 && indexPath.item in mutableTags.indices) mutableTags[indexPath.item] else null

    override fun numberOfSectionsInMenu(): Int = 1

    override fun menuNumberOfItemsInSection(section: Int): Int = if (section == 0) mutableTags.size else 0

    override fun menuTitleForSection(section: Int): String = sectionTitle.orEmpty()

    override fun menuTitleForItemAtIndexPath(indexPath: CYLIndexPath): String = tagAt(indexPath)?.title.orEmpty()

    override fun menuImageForItemAtIndexPath(indexPath: CYLIndexPath): Drawable? {
        val tag = tagAt(indexPath) ?: return null
        val badge = tag.badgeText
        if (tag.image == null && !badge.isNullOrEmpty()) {
            val size = baseStyle!!.imageSize
            val side = max(size.width, size.height)
            val image = CYLTag.badgeImageWithText(badge, tag.badgeColor ?: tag.textColor, if (side > 0) side else 16f)
            tag.badgeAccessibilityLabel?.takeIf { it.isNotEmpty() }?.let { (image as CYLBadgeDrawable).accessibilityLabel = it }
            tag.image = image
        }
        return tag.image
    }

    override fun menuSelectedImageForItemAtIndexPath(indexPath: CYLIndexPath): Drawable? = tagAt(indexPath)?.selectedImage

    override fun menuAnimationURLForItemAtIndexPath(indexPath: CYLIndexPath): Uri? = tagAt(indexPath)?.animationURL

    override fun menuItemIsEnabledAtIndexPath(indexPath: CYLIndexPath): Boolean = tagAt(indexPath)?.isEnabled ?: true

    override fun menuItemIsDeletableAtIndexPath(indexPath: CYLIndexPath): Boolean = tagAt(indexPath)?.isDeletable ?: false

    override fun menuRemoveItemAtIndexPath(indexPath: CYLIndexPath) {
        if (tagAt(indexPath) != null) removeTagAtIndex(indexPath.item)
    }

    override fun menuMoveItemAtIndexPath(sourceIndexPath: CYLIndexPath, toIndexPath: CYLIndexPath) {
        if (sourceIndexPath.section == 0 && toIndexPath.section == 0) moveTagAtIndex(sourceIndexPath.item, toIndexPath.item)
    }

    override fun supportsMovingItems(): Boolean = true

    override fun menuStyleForItemAtIndexPath(indexPath: CYLIndexPath): CYLMenuStyle? {
        val tag = tagAt(indexPath) ?: return null
        if (!tag.hasCustomStyle) return null
        return styles.getOrPut(tag) { tag.styleWithBaseStyle(baseStyle) }
    }
}
