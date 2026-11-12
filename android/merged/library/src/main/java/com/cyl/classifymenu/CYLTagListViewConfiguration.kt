package com.cyl.classifymenu

import android.content.Context
import android.graphics.BitmapFactory
import android.graphics.Typeface
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.net.Uri
import android.os.Build
import android.util.Xml
import org.json.JSONArray
import org.json.JSONObject
import org.xmlpull.v1.XmlPullParser
import java.io.File
import java.io.InputStream
import java.net.URLEncoder

// Keys of a tag list configuration (`CYLTagListView+CYLConfiguration.h`); the values are the iOS strings, so one file
// configures both platforms.

/**
 * Tag list key: an array of section dictionaries.
 */
const val CYLTagListViewSections = "sections"
/**
 * Tag list key: a style dictionary applied to the list's style.
 */
const val CYLTagListViewStyle = "style"
/**
 * Tag list key: "none", "single" or "multiple".
 */
const val CYLTagListViewSelectionMode = "selectionMode"
/**
 * Tag list key: "none", "headerButton", "footerChevron" or "truncate".
 */
const val CYLTagListViewFoldStyle = "foldStyle"
/**
 * Tag list key: a Boolean.
 */
const val CYLTagListViewAllowsEmptySelection = "allowsEmptySelection"
/**
 * Tag list key: a Boolean.
 */
const val CYLTagListViewShowsSectionHeaders = "showsSectionHeaders"
/**
 * Tag list key: a Boolean.
 */
const val CYLTagListViewScrollEnabled = "scrollEnabled"
/**
 * Tag list key: a number.
 */
const val CYLTagListViewDefaultVisibleRows = "defaultVisibleRows"
/**
 * Tag list key: index paths as "section-item" strings or [section, item] arrays.
 */
const val CYLTagListViewSelectedItems = "selectedItems"
/**
 * Tag list key: a fold control dictionary, or a position name.
 */
const val CYLTagListViewFoldControl = "foldControl"
/**
 * Tag list key: the list's title.
 */
const val CYLTagListViewTitle = "title"
/**
 * Tag list key: "topLeading" or "topCenter".
 */
const val CYLTagListViewTitlePosition = "titlePosition"
/**
 * Tag list key: an image name or path.
 */
const val CYLTagListViewTitleImage = "titleImage"
/**
 * Tag list key: a style dictionary applied to `defaultTitleStyle()`.
 */
const val CYLTagListViewTitleStyle = "titleStyle"
/**
 * Tag list key: an array of tag dictionaries or titles (android-tagview's tags).
 */
const val CYLTagListViewTags = "tags"

/**
 * Fold control key: the position name.
 */
const val CYLMenuFoldControlKeyPosition = "position"
/**
 * Fold control key: "iconAndTitle", "title" or "icon".
 */
const val CYLMenuFoldControlKeyContent = "content"
/**
 * Fold control key: the expand title.
 */
const val CYLMenuFoldControlKeyTitle = "title"
/**
 * Fold control key: the collapse title.
 */
const val CYLMenuFoldControlKeyCollapseTitle = "collapseTitle"
/**
 * Fold control key: an image name or path.
 */
const val CYLMenuFoldControlKeyImage = "image"
/**
 * Fold control key: a color.
 */
const val CYLMenuFoldControlKeyColor = "color"
/**
 * Fold control key: a font.
 */
const val CYLMenuFoldControlKeyFont = "font"
/**
 * Fold control key: a Boolean.
 */
const val CYLMenuFoldControlKeyRotatesImage = "rotatesImageWhenExpanded"

/**
 * Section key: the section's title.
 */
const val CYLTagSectionTitle = "title"
/**
 * Section key: the section's image.
 */
const val CYLTagSectionImage = "image"
/**
 * Section key: the section's items.
 */
const val CYLTagSectionItems = "items"
/**
 * Section key: a style dictionary for the section.
 */
const val CYLTagSectionStyle = "style"

/**
 * Item key: the title.
 */
const val CYLTagItemTitle = "title"
/**
 * Item key: an image name or path.
 */
const val CYLTagItemImage = "image"
/**
 * Item key: the image when selected.
 */
const val CYLTagItemSelectedImage = "selectedImage"
/**
 * Item key: an animation file (Lottie, PAG, Rive, GIF).
 */
const val CYLTagItemAnimation = "animation"
/**
 * Item key: options appended to the animation URL's fragment.
 */
const val CYLTagItemAnimationOptions = "animationOptions"
/**
 * Item key: the progress shown while the animation rests.
 */
const val CYLTagItemAnimationRestingProgress = "animationRestingProgress"
/**
 * Item key: a Boolean.
 */
const val CYLTagItemEnabled = "enabled"
/**
 * Item key: a Boolean.
 */
const val CYLTagItemExclusive = "exclusive"
/**
 * Item key: "tag" or "create".
 */
const val CYLTagItemType = "type"
/**
 * Item key: a Boolean.
 */
const val CYLTagItemDeletable = "deletable"
/**
 * Item key: a number identifying a tag.
 */
const val CYLTagItemIdentifier = "id"
/**
 * Item key: a style dictionary for the item.
 */
const val CYLTagItemStyle = "style"

/**
 * Style key: the normal appearance dictionary.
 */
const val CYLMenuStyleNormal = "normal"
/**
 * Style key: the selected appearance dictionary.
 */
const val CYLMenuStyleSelected = "selected"
/**
 * Style key: the disabled appearance dictionary.
 */
const val CYLMenuStyleDisabled = "disabled"
/**
 * Style key: a number.
 */
const val CYLMenuStyleImageTitleSpacing = "imageTitleSpacing"
/**
 * Style key: a number.
 */
const val CYLMenuStyleItemHeight = "itemHeight"
/**
 * Style key: a number, 0 for flowing rows.
 */
const val CYLMenuStyleNumberOfItemsPerRow = "itemsPerRow"
/**
 * Style key: a number.
 */
const val CYLMenuStyleInteritemSpacing = "interitemSpacing"
/**
 * Style key: a number.
 */
const val CYLMenuStyleLineSpacing = "lineSpacing"
/**
 * Style key: a number.
 */
const val CYLMenuStyleHeaderHeight = "headerHeight"
/**
 * Style key: a number.
 */
const val CYLMenuStyleAnimationSpeed = "animationSpeed"
/**
 * Style key: a size.
 */
const val CYLMenuStyleImageSize = "imageSize"
/**
 * Style key: a size.
 */
const val CYLMenuStyleAnimationSize = "animationSize"
/**
 * Style key: insets.
 */
const val CYLMenuStyleImageInsets = "imageInsets"
/**
 * Style key: insets.
 */
const val CYLMenuStyleSectionInsets = "sectionInsets"
/**
 * Style key: an offset.
 */
const val CYLMenuStyleTitlePositionAdjustment = "titlePositionAdjustment"
/**
 * Style key: an offset.
 */
const val CYLMenuStyleImagePositionAdjustment = "imagePositionAdjustment"
/**
 * Style key: a Boolean.
 */
const val CYLMenuStyleLayoutCentered = "layoutCentered"
/**
 * Style key: "leading" or "trailing".
 */
const val CYLMenuStyleImagePlacement = "imagePlacement"
/**
 * Style key: "center" or "leading".
 */
const val CYLMenuStyleContentAlignment = "contentAlignment"
/**
 * Style key: a Boolean.
 */
const val CYLMenuStyleAdjustsFontForContentSizeCategory = "adjustsFontForContentSizeCategory"
/**
 * Style key: a color.
 */
const val CYLMenuStyleBackgroundColor = "backgroundColor"
/**
 * Style key: a color.
 */
const val CYLMenuStyleHeaderTextColor = "headerTextColor"
/**
 * Style key: a color.
 */
const val CYLMenuStyleFoldControlColor = "foldControlColor"
/**
 * Style key: a font.
 */
const val CYLMenuStyleHeaderFont = "headerFont"
/**
 * Style key: a color.
 */
const val CYLMenuStyleHighlightedBackgroundColor = "highlightedBackgroundColor"
/**
 * Style key: insets.
 */
const val CYLMenuStyleTagContentInsets = "tagContentInsets"
/**
 * Style key: a string.
 */
const val CYLMenuStyleDeleteIndicatorTitle = "deleteIndicatorTitle"
/**
 * Style key: a color.
 */
const val CYLMenuStyleDeleteIndicatorColor = "deleteIndicatorColor"
/**
 * Style key: a font.
 */
const val CYLMenuStyleDeleteIndicatorFont = "deleteIndicatorFont"

/**
 * Appearance key: a color.
 */
const val CYLTagAppearanceBackgroundColor = "backgroundColor"
/**
 * Appearance key: a color.
 */
const val CYLTagAppearanceTextColor = "textColor"
/**
 * Appearance key: a font.
 */
const val CYLTagAppearanceFont = "font"
/**
 * Appearance key: a color.
 */
const val CYLTagAppearanceIconColor = "iconColor"
/**
 * Appearance key: a number.
 */
const val CYLTagAppearanceCornerRadius = "cornerRadius"
/**
 * Appearance key: a color.
 */
const val CYLTagAppearanceBorderColor = "borderColor"
/**
 * Appearance key: a number.
 */
const val CYLTagAppearanceBorderWidth = "borderWidth"
/**
 * Appearance key: a number.
 */
const val CYLTagAppearanceMargin = "margin"
/**
 * Appearance key: insets.
 */
const val CYLTagAppearanceContentInsets = "contentInsets"
/**
 * Appearance key: an image name or path.
 */
const val CYLTagAppearanceBackgroundImage = "backgroundImage"

/**
 * The error domain of configuration files (`NSErrorDomain`).
 */
const val CYLMenuConfigurationErrorDomain = "CYLMenuConfigurationErrorDomain"

/**
 * `CYLMenuConfigurationError`: why a configuration file could not be read.
 */
enum class CYLMenuConfigurationError(val code: Int) {
    CYLMenuConfigurationErrorFileNotFound(1),
    CYLMenuConfigurationErrorInvalidContents(2),
    CYLMenuConfigurationErrorUnsupportedFormat(3),
}

/**
 * The exception thrown where iOS returns an `NSError` of `CYLMenuConfigurationErrorDomain`.
 */
class CYLMenuConfigurationException(val error: CYLMenuConfigurationError, message: String, cause: Throwable? = null) :
    Exception(message, cause) {
    /**
     * Always `CYLMenuConfigurationErrorDomain`.
     */
    val domain: String get() = CYLMenuConfigurationErrorDomain
}

private const val BASE_URL_KEY = "__CYLConfigurationBaseURL"

// MARK: Values

private fun number(value: Any?): Double? = when (value) {
    is Boolean -> if (value) 1.0 else 0.0
    is Number -> value.toDouble()
    is String -> when (value.trim().lowercase()) {
        "true", "yes", "on" -> 1.0
        "false", "no", "off" -> 0.0
        else -> value.trim().toDoubleOrNull()
    }
    else -> null
}

private fun bool(value: Any?): Boolean? = number(value)?.let { it != 0.0 }

private fun numbers(value: Any?, count: Int): List<Double>? {
    val parts: List<Any?> = when (value) {
        is List<*> -> value
        is String -> value.replace(Regex("[{}\\[\\]]"), "").split(",")
        else -> return null
    }
    if (parts.size != count) return null
    return parts.map { number(it) ?: return null }
}

private fun map(value: Any?): Map<String, Any?>? {
    @Suppress("UNCHECKED_CAST")
    return value as? Map<String, Any?>
}

private fun insets(value: Any?): CYLEdgeInsets? {
    if (value is CYLEdgeInsets) return value
    map(value)?.let {
        return CYLEdgeInsets((number(it["top"]) ?: 0.0).toFloat(), (number(it["left"]) ?: 0.0).toFloat(),
            (number(it["bottom"]) ?: 0.0).toFloat(), (number(it["right"]) ?: 0.0).toFloat())
    }
    val n = numbers(value, 4) ?: return null
    return CYLEdgeInsets(n[0].toFloat(), n[1].toFloat(), n[2].toFloat(), n[3].toFloat())
}

private fun size(value: Any?): CYLSize? {
    if (value is CYLSize) return value
    map(value)?.let { return CYLSize((number(it["width"]) ?: 0.0).toFloat(), (number(it["height"]) ?: 0.0).toFloat()) }
    if (value !is List<*>) number(value)?.let { return CYLSize(it.toFloat(), it.toFloat()) }
    val n = numbers(value, 2) ?: return null
    return CYLSize(n[0].toFloat(), n[1].toFloat())
}

private fun offset(value: Any?): CYLOffset? {
    if (value is CYLOffset) return value
    map(value)?.let { return CYLOffset((number(it["horizontal"]) ?: 0.0).toFloat(), (number(it["vertical"]) ?: 0.0).toFloat()) }
    val n = numbers(value, 2) ?: return null
    return CYLOffset(n[0].toFloat(), n[1].toFloat())
}

private fun color(value: Any?): Int? = when (value) {
    is Int -> value
    is String -> CYLMenuColorFromString(value)
    else -> null
}

private val WEIGHTS = mapOf("ultralight" to 100, "thin" to 200, "light" to 300, "regular" to 400, "medium" to 500,
    "semibold" to 600, "bold" to 700, "heavy" to 800, "black" to 900)

private fun font(value: Any?): CYLFont? {
    if (value is CYLFont) return value
    if (value !is Map<*, *>) return number(value)?.let { CYLFont.systemFont(it.toFloat()) }
    val m = map(value)!!
    val pointSize = number(m["size"])?.takeIf { it != 0.0 }?.toFloat() ?: 14f
    val italic = bool(m["italic"]) == true
    val weight = (m["weight"] as? String)?.lowercase()?.let { WEIGHTS[it] } ?: 400
    val family = (m["name"] as? String)?.let { Typeface.create(it, Typeface.NORMAL) } ?: Typeface.DEFAULT
    val typeface = if (Build.VERSION.SDK_INT >= 28) Typeface.create(family, weight, italic) else Typeface.create(family,
        when {
            weight >= 600 && italic -> Typeface.BOLD_ITALIC
            weight >= 600 -> Typeface.BOLD
            italic -> Typeface.ITALIC
            else -> Typeface.NORMAL
        })
    return CYLFont(pointSize, typeface)
}

private fun <T : Enum<T>> enumValue(value: Any?, names: Map<String, T>, values: Array<T>, fallback: T): T {
    if (value is Number) return values.getOrNull(value.toInt()) ?: fallback
    if (value is String) {
        names[value.lowercase()]?.let { return it }
        number(value)?.let { return values.getOrNull(it.toInt()) ?: fallback }
    }
    return fallback
}

/**
 * `CYLMenuAnimationURLWithOptions`: `fileURL` with `options` as its fragment ("name=value&…", names sorted, percent
 * encoded), which the animation engine reads (Rive's artboard and state machine, for example).
 */
fun CYLMenuAnimationURLWithOptions(fileURL: Uri?, options: Map<String, Any?>?): Uri? {
    fileURL ?: return null
    if (options.isNullOrEmpty()) return fileURL
    fun encode(text: String) = URLEncoder.encode(text, "UTF-8").replace("+", "%20")
    val items = options.keys.filter { it.isNotEmpty() }.sorted().mapNotNull { name ->
        val value = when (val raw = options[name]) {
            is String -> raw
            is Boolean -> if (raw) "1" else "0"
            is Double -> if (raw == Math.floor(raw)) raw.toLong().toString() else raw.toString()
            is Number -> raw.toString()
            else -> null
        }
        if (value.isNullOrEmpty()) null else "${encode(name)}=${encode(value)}"
    }
    return fileURL.buildUpon().encodedFragment(if (items.isEmpty()) null else items.joinToString("&")).build()
}

private fun fileURL(context: Context?, value: Any?, baseURL: Uri?): Uri? {
    if (value is Uri) return value
    val string = value as? String ?: return null
    if (string.isEmpty()) return null
    val hash = string.indexOf('#')
    if (hash > 0 && (Uri.parse(string).scheme?.length ?: 0) <= 1) {
        val file = fileURL(context, string.substring(0, hash), baseURL) ?: return null
        return file.buildUpon().encodedFragment(string.substring(hash + 1)).build()
    }
    val parsed = Uri.parse(string)
    if ((parsed.scheme?.length ?: 0) > 1) return parsed
    if (string.startsWith("/")) return Uri.fromFile(File(string))
    if (baseURL != null) {
        val candidate = baseURL.buildUpon().appendEncodedPath(string).build()
        if (exists(context, candidate)) return candidate
    }
    val asset = Uri.parse("file:///android_asset/$string")
    return if (context == null || exists(context, asset)) asset else null
}

private fun exists(context: Context?, uri: Uri): Boolean {
    if (uri.scheme != "file") return true
    val path = uri.path ?: return false
    if (path.startsWith("/android_asset/")) {
        return try {
            context?.assets?.open(path.removePrefix("/android_asset/"))?.close()
            context != null
        } catch (e: Exception) {
            false
        }
    }
    return File(path).exists()
}

private fun open(context: Context?, uri: Uri): InputStream? {
    val path = uri.path ?: return null
    return try {
        when {
            uri.scheme == "file" && path.startsWith("/android_asset/") -> context?.assets?.open(path.removePrefix("/android_asset/"))
            uri.scheme == "file" -> File(path).inputStream()
            else -> context?.contentResolver?.openInputStream(uri)
        }
    } catch (e: Exception) {
        null
    }
}

private val SYSTEM_IMAGES = mapOf("chevron.down" to CYLMenuIconDrawable.Kind.CHEVRON_DOWN, "plus" to CYLMenuIconDrawable.Kind.PLUS,
    "ellipsis" to CYLMenuIconDrawable.Kind.ELLIPSIS)

private fun image(context: Context?, value: Any?, baseURL: Uri?): Drawable? {
    if (value is Drawable) return value
    val string = value as? String ?: return null
    if (string.isEmpty()) return null
    if (string.startsWith("system:")) return SYSTEM_IMAGES[string.removePrefix("system:")]?.let { CYLMenuIconDrawable(it) }
    if (context != null) {
        val name = string.substringBeforeLast('.').replace('-', '_').lowercase()
        val id = context.resources.getIdentifier(name, "drawable", context.packageName)
        if (id != 0) return androidx.core.content.ContextCompat.getDrawable(context, id)
    }
    CYLMenuImage(string)?.let { return it }
    val uri = fileURL(context, string, baseURL) ?: return null
    val stream = open(context, uri) ?: return null
    return stream.use { BitmapFactory.decodeStream(it) }?.let { bitmap ->
        if (context != null) BitmapDrawable(context.resources, bitmap) else BitmapDrawable(android.content.res.Resources.getSystem(), bitmap)
    }
}

// MARK: Data source built from a configuration

private class CYLTagListConfigurationSource(
    var sections: List<Map<String, Any?>>,
    val baseURL: Uri?,
    val owner: CYLTagListView,
) : CYLMenuDataSource {
    private val sectionStyles = HashMap<Int, Pair<CYLMenuStyle, CYLMenuStyle>>()
    private val itemStyles = HashMap<CYLIndexPath, Pair<CYLMenuStyle, CYLMenuStyle>>()
    private val context: Context get() = owner.context

    private fun items(section: Int): List<Any?> = sections.getOrNull(section)?.get(CYLTagSectionItems) as? List<*> ?: emptyList()

    private fun item(indexPath: CYLIndexPath): Map<String, Any?> {
        val item = items(indexPath.section).getOrNull(indexPath.item)
        return map(item) ?: mapOf(CYLTagItemTitle to (item?.toString() ?: ""))
    }

    override fun numberOfSectionsInMenu(): Int = sections.size
    override fun menuNumberOfItemsInSection(section: Int): Int = items(section).size
    override fun menuTitleForSection(section: Int): String = sections.getOrNull(section)?.get(CYLTagSectionTitle)?.toString() ?: ""
    override fun menuTitleForItemAtIndexPath(indexPath: CYLIndexPath): String = item(indexPath)[CYLTagItemTitle]?.toString() ?: ""
    override fun menuImageForItemAtIndexPath(indexPath: CYLIndexPath): Drawable? = image(context, item(indexPath)[CYLTagItemImage], baseURL)
    override fun menuSelectedImageForItemAtIndexPath(indexPath: CYLIndexPath): Drawable? = image(context, item(indexPath)[CYLTagItemSelectedImage], baseURL)

    override fun menuAnimationURLForItemAtIndexPath(indexPath: CYLIndexPath): Uri? {
        val item = item(indexPath)
        return CYLMenuAnimationURLWithOptions(fileURL(context, item[CYLTagItemAnimation], baseURL), map(item[CYLTagItemAnimationOptions]))
    }

    override fun menuImageForSection(section: Int): Drawable? = image(context, sections.getOrNull(section)?.get(CYLTagSectionImage), baseURL)
    override fun menuAnimationRestingProgressForItemAtIndexPath(indexPath: CYLIndexPath): Float? = number(item(indexPath)[CYLTagItemAnimationRestingProgress])?.toFloat()

    override fun menuStyleForSection(section: Int): CYLMenuStyle? {
        val value = sections.getOrNull(section)?.get(CYLTagSectionStyle)
        if (value is CYLMenuStyle) return value
        val configuration = map(value) ?: return null
        val base = owner.style!!
        sectionStyles[section]?.let { if (it.first === base) return it.second }
        val style = base.copy()
        style.applyConfiguration(configuration)
        sectionStyles[section] = base to style
        return style
    }

    override fun menuItemIsEnabledAtIndexPath(indexPath: CYLIndexPath): Boolean = bool(item(indexPath)[CYLTagItemEnabled]) ?: true
    override fun menuItemIsExclusiveAtIndexPath(indexPath: CYLIndexPath): Boolean = bool(item(indexPath)[CYLTagItemExclusive]) == true
    override fun menuItemIsDeletableAtIndexPath(indexPath: CYLIndexPath): Boolean = bool(item(indexPath)[CYLTagItemDeletable]) == true

    override fun menuRemoveItemAtIndexPath(indexPath: CYLIndexPath) {
        if (indexPath.section !in sections.indices) return
        val items = items(indexPath.section).toMutableList()
        if (indexPath.item !in items.indices) return
        items.removeAt(indexPath.item)
        sections = sections.toMutableList().also { it[indexPath.section] = it[indexPath.section] + (CYLTagSectionItems to items) }
        itemStyles.clear()
    }

    override fun menuStyleForItemAtIndexPath(indexPath: CYLIndexPath): CYLMenuStyle? {
        val value = item(indexPath)[CYLTagItemStyle]
        if (value is CYLMenuStyle) return value
        val configuration = map(value) ?: return null
        val base = menuStyleForSection(indexPath.section) ?: owner.style!!
        itemStyles[indexPath]?.let { if (it.first === base) return it.second }
        val style = base.copy()
        style.applyConfiguration(configuration)
        itemStyles[indexPath] = base to style
        return style
    }

    override fun menuItemTypeAtIndexPath(indexPath: CYLIndexPath): CYLMenuItemType = enumValue(item(indexPath)[CYLTagItemType],
        mapOf("tag" to CYLMenuItemType.CYLMenuItemTypeTag, "create" to CYLMenuItemType.CYLMenuItemTypeCreate, "new" to CYLMenuItemType.CYLMenuItemTypeCreate),
        CYLMenuItemType.values(), CYLMenuItemType.CYLMenuItemTypeTag)
}

// MARK: Fold control

/**
 * `CYLMenuFoldControl (CYLConfiguration) +foldControlWithConfiguration:`: a copy of a fold control, a control for a
 * position name (with the position's usual content), or one built from a dictionary; null for anything else.
 */
fun CYLMenuFoldControl.Companion.foldControlWithConfiguration(configuration: Any?, context: Context? = null): CYLMenuFoldControl? {
    if (configuration is CYLMenuFoldControl) return configuration.copy()
    val control = CYLMenuFoldControl.noFoldControl()
    if (configuration is String || configuration is Number) {
        control.applyConfiguration(mapOf(CYLMenuFoldControlKeyPosition to configuration), context)
        control.content = if (control.position == CYLMenuFoldControlPosition.CYLMenuFoldControlPositionBottom)
            CYLMenuFoldControlContent.CYLMenuFoldControlContentIcon else CYLMenuFoldControlContent.CYLMenuFoldControlContentIconAndTitle
        return control
    }
    val dictionary = map(configuration) ?: return null
    control.applyConfiguration(dictionary, context)
    return control
}

/**
 * `CYLMenuFoldControl (CYLConfiguration) -applyConfiguration:`: sets the values the dictionary holds.
 */
fun CYLMenuFoldControl.applyConfiguration(configuration: Map<String, Any?>, context: Context? = null) {
    configuration[CYLMenuFoldControlKeyPosition]?.let {
        position = enumValue(it, mapOf("none" to CYLMenuFoldControlPosition.CYLMenuFoldControlPositionNone,
            "bottom" to CYLMenuFoldControlPosition.CYLMenuFoldControlPositionBottom,
            "toptrailing" to CYLMenuFoldControlPosition.CYLMenuFoldControlPositionTopTrailing,
            "topright" to CYLMenuFoldControlPosition.CYLMenuFoldControlPositionTopTrailing,
            "topleading" to CYLMenuFoldControlPosition.CYLMenuFoldControlPositionTopLeading,
            "topleft" to CYLMenuFoldControlPosition.CYLMenuFoldControlPositionTopLeading,
            "inline" to CYLMenuFoldControlPosition.CYLMenuFoldControlPositionInline), CYLMenuFoldControlPosition.values(), position)
    }
    configuration[CYLMenuFoldControlKeyContent]?.let {
        content = enumValue(it, mapOf("iconandtitle" to CYLMenuFoldControlContent.CYLMenuFoldControlContentIconAndTitle,
            "titleandicon" to CYLMenuFoldControlContent.CYLMenuFoldControlContentIconAndTitle,
            "title" to CYLMenuFoldControlContent.CYLMenuFoldControlContentTitle,
            "icon" to CYLMenuFoldControlContent.CYLMenuFoldControlContentIcon), CYLMenuFoldControlContent.values(), content)
    }
    (configuration[CYLMenuFoldControlKeyTitle] as? String)?.let { title = it }
    (configuration[CYLMenuFoldControlKeyCollapseTitle] as? String)?.let { collapseTitle = it }
    image(context, configuration[CYLMenuFoldControlKeyImage], configuration[BASE_URL_KEY] as? Uri)?.let { image = it }
    color(configuration[CYLMenuFoldControlKeyColor])?.let { color = it }
    font(configuration[CYLMenuFoldControlKeyFont])?.let { font = it }
    bool(configuration[CYLMenuFoldControlKeyRotatesImage])?.let { rotatesImageWhenExpanded = it }
}

// MARK: Style

/**
 * `CYLTagAppearance (CYLConfiguration) -applyConfiguration:`: sets the values the dictionary holds; a key whose
 * color cannot be read clears the optional color, as on iOS.
 */
fun CYLTagAppearance.applyConfiguration(configuration: Map<String, Any?>?, context: Context? = null) {
    configuration ?: return
    if (CYLTagAppearanceBackgroundColor in configuration) color(configuration[CYLTagAppearanceBackgroundColor])?.let { backgroundColor = it }
    if (CYLTagAppearanceTextColor in configuration) color(configuration[CYLTagAppearanceTextColor])?.let { textColor = it }
    if (CYLTagAppearanceFont in configuration) font(configuration[CYLTagAppearanceFont])?.let { font = it }
    if (CYLTagAppearanceIconColor in configuration) iconColor = color(configuration[CYLTagAppearanceIconColor])
    if (CYLTagAppearanceBorderColor in configuration) borderColor = color(configuration[CYLTagAppearanceBorderColor])
    number(configuration[CYLTagAppearanceCornerRadius])?.let { cornerRadius = it.toFloat() }
    number(configuration[CYLTagAppearanceBorderWidth])?.let { borderWidth = it.toFloat() }
    number(configuration[CYLTagAppearanceMargin])?.let { margin = it.toFloat() }
    insets(configuration[CYLTagAppearanceContentInsets])?.let { contentInsets = it }
    if (CYLTagAppearanceBackgroundImage in configuration) {
        backgroundImage = image(context, configuration[CYLTagAppearanceBackgroundImage], configuration[BASE_URL_KEY] as? Uri)
    }
}

/**
 * `CYLMenuStyle (CYLConfiguration) +styleWithConfiguration:`: the default style with the dictionary applied.
 */
fun CYLMenuStyle.Companion.styleWithConfiguration(configuration: Map<String, Any?>, context: Context? = null): CYLMenuStyle =
    CYLMenuStyle.defaultStyle().also { it.applyConfiguration(configuration, context) }

/**
 * `CYLMenuStyle (CYLConfiguration) -applyConfiguration:`: sets the values the dictionary holds.
 */
fun CYLMenuStyle.applyConfiguration(configuration: Map<String, Any?>, context: Context? = null) {
    normalAppearance.applyConfiguration(map(configuration[CYLMenuStyleNormal]), context)
    selectedAppearance.applyConfiguration(map(configuration[CYLMenuStyleSelected]), context)
    disabledAppearance.applyConfiguration(map(configuration[CYLMenuStyleDisabled]), context)
    number(configuration[CYLMenuStyleImageTitleSpacing])?.let { imageTitleSpacing = it.toFloat() }
    number(configuration[CYLMenuStyleItemHeight])?.let { itemHeight = it.toFloat() }
    number(configuration[CYLMenuStyleNumberOfItemsPerRow])?.let { numberOfItemsPerRow = maxOf(0, it.toInt()) }
    number(configuration[CYLMenuStyleInteritemSpacing])?.let { interitemSpacing = it.toFloat() }
    number(configuration[CYLMenuStyleLineSpacing])?.let { lineSpacing = it.toFloat() }
    number(configuration[CYLMenuStyleHeaderHeight])?.let { headerHeight = it.toFloat() }
    number(configuration[CYLMenuStyleAnimationSpeed])?.let { animationSpeed = it.toFloat() }
    bool(configuration[CYLMenuStyleLayoutCentered])?.let { layoutCentered = it }
    configuration[CYLMenuStyleImagePlacement]?.let {
        imagePlacement = enumValue(it, mapOf("leading" to CYLTagImagePlacement.CYLTagImagePlacementLeading,
            "left" to CYLTagImagePlacement.CYLTagImagePlacementLeading, "trailing" to CYLTagImagePlacement.CYLTagImagePlacementTrailing,
            "right" to CYLTagImagePlacement.CYLTagImagePlacementTrailing), CYLTagImagePlacement.values(), imagePlacement)
    }
    configuration[CYLMenuStyleContentAlignment]?.let {
        contentAlignment = enumValue(it, mapOf("center" to CYLTagContentAlignment.CYLTagContentAlignmentCenter,
            "leading" to CYLTagContentAlignment.CYLTagContentAlignmentLeading, "left" to CYLTagContentAlignment.CYLTagContentAlignmentLeading),
            CYLTagContentAlignment.values(), contentAlignment)
    }
    bool(configuration[CYLMenuStyleAdjustsFontForContentSizeCategory])?.let { adjustsFontForContentSizeCategory = it }
    size(configuration[CYLMenuStyleImageSize])?.let { imageSize = it }
    size(configuration[CYLMenuStyleAnimationSize])?.let { animationSize = it }
    insets(configuration[CYLMenuStyleImageInsets])?.let { imageInsets = it }
    insets(configuration[CYLMenuStyleSectionInsets])?.let { sectionInsets = it }
    offset(configuration[CYLMenuStyleTitlePositionAdjustment])?.let { titlePositionAdjustment = it }
    offset(configuration[CYLMenuStyleImagePositionAdjustment])?.let { imagePositionAdjustment = it }
    color(configuration[CYLMenuStyleBackgroundColor])?.let { backgroundColor = it }
    color(configuration[CYLMenuStyleHeaderTextColor])?.let { headerTextColor = it }
    color(configuration[CYLMenuStyleFoldControlColor])?.let { foldControlColor = it }
    font(configuration[CYLMenuStyleHeaderFont])?.let { headerFont = it }
    if (CYLMenuStyleHighlightedBackgroundColor in configuration) highlightedBackgroundColor = color(configuration[CYLMenuStyleHighlightedBackgroundColor])
    insets(configuration[CYLMenuStyleTagContentInsets])?.let { tagContentInsets = it }
    (configuration[CYLMenuStyleDeleteIndicatorTitle] as? String)?.let { deleteIndicatorTitle = it }
    if (CYLMenuStyleDeleteIndicatorColor in configuration) deleteIndicatorColor = color(configuration[CYLMenuStyleDeleteIndicatorColor])
    if (CYLMenuStyleDeleteIndicatorFont in configuration) deleteIndicatorFont = font(configuration[CYLMenuStyleDeleteIndicatorFont])
}

// MARK: Tag

/**
 * `CYLTag (CYLConfiguration) +tagWithConfiguration:`: a tag from an item dictionary (id, title, images, animation,
 * enabled, deletable, style).
 */
fun CYLTag.Companion.tagWithConfiguration(configuration: Map<String, Any?>?, context: Context? = null): CYLTag {
    val item = configuration ?: emptyMap()
    val baseURL = item[BASE_URL_KEY] as? Uri
    val tag = CYLTag(number(item[CYLTagItemIdentifier])?.toInt() ?: 0, item[CYLTagItemTitle]?.toString() ?: "", null as Int?)
    tag.image = image(context, item[CYLTagItemImage], baseURL)
    tag.selectedImage = image(context, item[CYLTagItemSelectedImage], baseURL)
    tag.animationURL = CYLMenuAnimationURLWithOptions(fileURL(context, item[CYLTagItemAnimation], baseURL), map(item[CYLTagItemAnimationOptions]))
    tag.isEnabled = bool(item[CYLTagItemEnabled]) ?: true
    tag.isDeletable = bool(item[CYLTagItemDeletable]) == true
    when (val style = item[CYLTagItemStyle]) {
        is CYLMenuStyle -> tag.style = style
        is Map<*, *> -> tag.style = CYLMenuStyle.styleWithConfiguration(map(style)!!, context)
    }
    return tag
}

// MARK: Tag list

private val configurationSources = java.util.WeakHashMap<CYLTagListView, CYLMenuDataSource>()

/**
 * `-configurationDataSource`: the data source the last configuration with sections installed (kept alive by the list).
 */
val CYLTagListView.configurationDataSource: CYLMenuDataSource?
    get() = configurationSources[this]

/**
 * `-initWithConfiguration:` / `+tagListViewWithConfiguration:`: a list with the configuration applied.
 */
fun CYLTagListView.Companion.tagListViewWithConfiguration(context: Context, configuration: Map<String, Any?>): CYLTagListView =
    CYLTagListView(context).also { it.applyConfiguration(configuration) }

/**
 * `-applyConfiguration:`: sets the values the dictionary holds, in the iOS order: style, selection mode, fold style
 * and control, title, flags, then sections or tags, then the selection.
 */
fun CYLTagListView.applyConfiguration(configuration: Map<String, Any?>) {
    val baseURL = configuration[BASE_URL_KEY] as? Uri
    configuration[CYLTagListViewStyle]?.let { value ->
        if (value is CYLMenuStyle) style = value
        else map(value)?.let { style = style!!.copy().also { s -> s.applyConfiguration(it, context) } }
    }
    configuration[CYLTagListViewSelectionMode]?.let {
        selectionMode = enumValue(it, mapOf("none" to CYLMenuSelectionMode.CYLMenuSelectionModeNone,
            "single" to CYLMenuSelectionMode.CYLMenuSelectionModeSingle, "multiple" to CYLMenuSelectionMode.CYLMenuSelectionModeMultiple),
            CYLMenuSelectionMode.values(), selectionMode)
    }
    configuration[CYLTagListViewFoldStyle]?.let {
        foldStyle = enumValue(it, mapOf("none" to CYLMenuFoldStyle.CYLMenuFoldStyleNone, "headerbutton" to CYLMenuFoldStyle.CYLMenuFoldStyleHeaderButton,
            "footerchevron" to CYLMenuFoldStyle.CYLMenuFoldStyleFooterChevron, "truncate" to CYLMenuFoldStyle.CYLMenuFoldStyleTruncate),
            CYLMenuFoldStyle.values(), foldStyle)
    }
    configuration[CYLTagListViewFoldControl]?.let { value ->
        val withBase = map(value)?.let { if (baseURL != null) it + (BASE_URL_KEY to baseURL) else it } ?: value
        CYLMenuFoldControl.foldControlWithConfiguration(withBase, context)?.let { foldControl = it }
    }
    configuration[CYLTagListViewTitlePosition]?.let {
        titlePosition = enumValue(it, mapOf("topleading" to CYLMenuTitlePosition.CYLMenuTitlePositionTopLeading,
            "leading" to CYLMenuTitlePosition.CYLMenuTitlePositionTopLeading, "left" to CYLMenuTitlePosition.CYLMenuTitlePositionTopLeading,
            "topcenter" to CYLMenuTitlePosition.CYLMenuTitlePositionTopCenter, "center" to CYLMenuTitlePosition.CYLMenuTitlePositionTopCenter),
            CYLMenuTitlePosition.values(), titlePosition)
    }
    configuration[CYLTagListViewTitleStyle]?.let { value ->
        if (value is CYLMenuStyle) titleStyle = value
        else map(value)?.let { titleStyle = CYLTagListView.defaultTitleStyle().also { s -> s.applyConfiguration(it, context) } }
    }
    image(context, configuration[CYLTagListViewTitleImage], baseURL)?.let { titleImage = it }
    (configuration[CYLTagListViewTitle] as? String)?.let { title = it }
    bool(configuration[CYLTagListViewAllowsEmptySelection])?.let { allowsEmptySelection = it }
    bool(configuration[CYLTagListViewShowsSectionHeaders])?.let { showsSectionHeaders = it }
    bool(configuration[CYLTagListViewScrollEnabled])?.let { isScrollEnabled = it }
    number(configuration[CYLTagListViewDefaultVisibleRows])?.let { defaultVisibleRows = maxOf(0, it.toInt()) }
    (configuration[CYLTagListViewSections] as? List<*>)?.let { list ->
        val source = CYLTagListConfigurationSource(list.mapNotNull { map(it) }, baseURL, this)
        configurationSources[this] = source
        menuDataSource = source
        reloadMenuData()
    }
    (configuration[CYLTagListViewTags] as? List<*>)?.let { list ->
        val tags = list.map { item ->
            var dictionary = map(item) ?: mapOf(CYLTagItemTitle to (item?.toString() ?: ""))
            if (baseURL != null) dictionary = dictionary + (BASE_URL_KEY to baseURL)
            CYLTag.tagWithConfiguration(dictionary, context)
        }
        removeAllTags()
        addTags(tags)
    }
    (configuration[CYLTagListViewSelectedItems] as? List<*>)?.let { list ->
        selectedIndexPaths = list.mapNotNull { item ->
            if (item is CYLIndexPath) return@mapNotNull item
            val pair = if (item is String) numbers(item.replace("-", ","), 2) else numbers(item, 2)
            pair?.let { CYLIndexPath(it[1].toInt(), it[0].toInt()) }
        }
    }
}

/**
 * `+configurationWithContentsOfFile:error:`: reads a JSON file or an XML property list (a path, a `file:` /
 * `content:` URI, or a path inside the app's assets). Relative paths in it are resolved against the file's folder.
 * Throws `CYLMenuConfigurationException` where iOS returns an error.
 */
@Throws(CYLMenuConfigurationException::class)
fun CYLTagListView.Companion.configurationWithContentsOfFile(context: Context, filePath: String): Map<String, Any?> {
    val uri = fileURL(context, filePath, null)
    val stream = uri?.let { open(context, it) }
        ?: throw CYLMenuConfigurationException(CYLMenuConfigurationError.CYLMenuConfigurationErrorFileNotFound, "No configuration file at $filePath")
    val extension = (uri.lastPathSegment ?: "").substringAfterLast('.', "").lowercase()
    val text = stream.use { it.readBytes().toString(Charsets.UTF_8) }
    val contents: Any? = try {
        when (extension) {
            "json" -> jsonValue(JSONObject(text))
            "plist" -> plistValue(text)
            "" -> if (text.trimStart().startsWith("{")) jsonValue(JSONObject(text)) else plistValue(text)
            else -> throw CYLMenuConfigurationException(CYLMenuConfigurationError.CYLMenuConfigurationErrorUnsupportedFormat,
                "Reading .$extension files needs CYLTabBarController; use JSON or a property list.")
        }
    } catch (e: CYLMenuConfigurationException) {
        throw e
    } catch (e: Exception) {
        throw CYLMenuConfigurationException(CYLMenuConfigurationError.CYLMenuConfigurationErrorInvalidContents, "$filePath could not be read", e)
    }
    val dictionary = map(contents)
        ?: throw CYLMenuConfigurationException(CYLMenuConfigurationError.CYLMenuConfigurationErrorInvalidContents, "$filePath does not hold a dictionary")
    val folder = uri.buildUpon().path(uri.path?.substringBeforeLast('/', "") ?: "").fragment(null).build()
    return dictionary + (BASE_URL_KEY to folder)
}

/**
 * `-initWithConfigurationFile:error:` / `+tagListViewWithConfigurationFile:error:`.
 */
@Throws(CYLMenuConfigurationException::class)
fun CYLTagListView.Companion.tagListViewWithConfigurationFile(context: Context, filePath: String): CYLTagListView =
    tagListViewWithConfiguration(context, configurationWithContentsOfFile(context, filePath))

private fun jsonValue(value: Any?): Any? = when (value) {
    is JSONObject -> value.keys().asSequence().associateWith { jsonValue(value.get(it)) }
    is JSONArray -> (0 until value.length()).map { jsonValue(value.get(it)) }
    JSONObject.NULL -> null
    else -> value
}

private fun plistValue(text: String): Any? {
    val parser = Xml.newPullParser()
    parser.setFeature(XmlPullParser.FEATURE_PROCESS_NAMESPACES, false)
    parser.setInput(text.reader())
    fun read(): Any? {
        val name = parser.name
        return when (name) {
            "dict" -> {
                val result = LinkedHashMap<String, Any?>()
                var key: String? = null
                while (parser.next() != XmlPullParser.END_TAG || parser.name != "dict") {
                    if (parser.eventType != XmlPullParser.START_TAG) continue
                    if (parser.name == "key") key = parser.nextText() else result[key ?: ""] = read()
                }
                result
            }
            "array" -> {
                val result = ArrayList<Any?>()
                while (parser.next() != XmlPullParser.END_TAG || parser.name != "array") {
                    if (parser.eventType == XmlPullParser.START_TAG) result.add(read())
                }
                result
            }
            "string", "date", "data" -> parser.nextText()
            "integer" -> parser.nextText().trim().toLong()
            "real" -> parser.nextText().trim().toDouble()
            "true" -> true.also { parser.next() }
            "false" -> false.also { parser.next() }
            else -> null
        }
    }
    while (parser.next() != XmlPullParser.END_DOCUMENT) {
        if (parser.eventType == XmlPullParser.START_TAG && parser.name != "plist") return read()
    }
    return null
}
