package com.cyl.classifymenu.example.menu

import android.app.AlertDialog
import android.content.Context
import android.graphics.Color
import android.graphics.drawable.Drawable
import android.graphics.drawable.GradientDrawable
import android.os.Build
import android.view.View
import android.widget.Button
import android.widget.EditText
import android.widget.LinearLayout
import android.widget.ScrollView
import android.widget.Toast
import com.cyl.classifymenu.CYLEdgeInsets
import com.cyl.classifymenu.CYLIndexPath
import com.cyl.classifymenu.CYLMenuStyle
import com.cyl.classifymenu.CYLTag
import com.cyl.classifymenu.CYLTagBackgroundStyle
import com.cyl.classifymenu.CYLTagColorTheme
import com.cyl.classifymenu.CYLTagColors
import com.cyl.classifymenu.CYLTagDeleteIndicatorPlacement
import com.cyl.classifymenu.CYLTagListView
import com.cyl.classifymenu.CYLTagRowAlignment
import com.cyl.classifymenu.CYLTagTitleMaxLines
import kotlin.random.Random

/**
 * The sample screens' shared sizes and colors (dp unless noted).
 */
private object CYLTagSampleMetrics {
    const val SCREEN_PADDING = 16
    const val ROW_SPACING = 12
    const val SPACING = 10f
    const val CORNER_RADIUS_PIXELS_PER_DP = 3f
    const val AVATAR_SIZE = 48
    const val PAGE_BACKGROUND_GRAY = 250
    const val FIRST_THEME_COLOR_INDEX = 1
    const val CUSTOM_BACKGROUND_RADIUS = 8f
    const val CUSTOM_BACKGROUND_SIZE = 24
    const val DELETABLE_CHANCE = 2
    val firstSampleCornerRadii = listOf(0f, 20f, 60f)
    val firstSampleBorderWidths = listOf(1f, 2f, 3f)
}

/**
 * `CYLTagCloudSampleViewController`: kaedea/android-tagview's MainActivity on `CYLTagListView`: the sample's tags (a
 * click shows its id and position, a cross deletes it) and "add tag" (the typed text or "ADD A TAG", deletable half the
 * time, one of the five colors).
 */
class CYLTagCloudSampleScreen(private val context: Context) : CYLMenuScreen {
    override val title: CharSequence = CYLExampleLocalizedString(context, "标签视图示例")
    val tagListView = CYLTagListView(context)
    val textField = EditText(context).apply { hint = CYLExampleLocalizedString(context, "输入标签文字") }
    override val view: View

    companion object {
        val continents = listOf("AFRICA", "EUROPE", "ASIA", "NORTH AMERICA", "SOUTH AMERICA", "ANTARCTICA", "AUSTRALIA")
        val colors = listOf("#00BFFF", "#E91E63", "#F44336", "#9C27B0", "#673AB7")

        private fun color(index: Int) = Color.parseColor(colors[index])

        /**
         * The tags of MainActivity's onCreate, in order; each one's identifier is its position.
         */
        fun mainTags(context: Context): List<CYLTag> {
            val text = { key: String -> CYLExampleLocalizedString(context, key) }
            val tags = ArrayList<CYLTag>()
            continents.forEach { tags.add(CYLTag(it)) }
            for (index in CYLTagSampleMetrics.FIRST_THEME_COLOR_INDEX until colors.size) {
                tags.add(CYLTag(text("彩色文字")).apply { textColor = color(index) })
            }
            colors.forEach { tags.add(CYLTag(text("彩色背景"), it)) }
            val borderColors = listOf(null, color(1), color(3))
            CYLTagSampleMetrics.firstSampleBorderWidths.forEachIndexed { index, width ->
                tags.add(CYLTag(text("边框")).apply { borderWidth = width; borderColor = borderColors[index] })
            }
            CYLTagSampleMetrics.firstSampleCornerRadii.forEach { radius ->
                tags.add(CYLTag(text("圆角")).apply { cornerRadius = radius / CYLTagSampleMetrics.CORNER_RADIUS_PIXELS_PER_DP })
            }
            tags.add(CYLTag(text("可删除")).apply { isDeletable = true })
            tags.add(CYLTag(text("自定义背景")).apply { textColor = color(0); backgroundImage = customBackground(context) })
            tags.add(CYLTag(text("详情标签"), "#DDDDDD").apply {
                textColor = Color.WHITE
                highlightedBackgroundColor = Color.parseColor("#555555")
                cornerRadius = 20f / CYLTagSampleMetrics.CORNER_RADIUS_PIXELS_PER_DP
                textSize = 14f
                borderWidth = 1f
                borderColor = Color.WHITE
                isDeletable = true
            })
            tags.forEachIndexed { index, tag -> tag.identifier = index }
            return tags
        }

        /**
         * bg_tag: a white rounded rectangle, stretched.
         */
        private fun customBackground(context: Context): Drawable {
            val d = context.resources.displayMetrics.density
            return GradientDrawable().apply {
                setColor(Color.WHITE)
                cornerRadius = CYLTagSampleMetrics.CUSTOM_BACKGROUND_RADIUS * d
                setSize((CYLTagSampleMetrics.CUSTOM_BACKGROUND_SIZE * d).toInt(), (CYLTagSampleMetrics.CUSTOM_BACKGROUND_SIZE * d).toInt())
            }
        }
    }

    init {
        // activity_main.xml: lineMargin 5dp, tagMargin 3dp, textPadding 10dp x 3dp.
        tagListView.style = CYLMenuStyle.tagCloudStyle().apply { backgroundStyle = CYLTagBackgroundStyle.CYLTagBackgroundStyleLiquidGlass }
        tagListView.lineSpacing = 5f
        tagListView.interitemSpacing = 3f
        tagListView.tagContentInsets = CYLEdgeInsets(3f, 10f, 3f, 10f)
        tagListView.isScrollEnabled = false
        tagListView.addTags(mainTags(context))
        tagListView.tagClickHandler = { index, tag -> toast(CYLExampleLocalizedString(context, "点击标签 id = %ld，位置 = %ld", tag.identifier, index)) }
        tagListView.tagDeleteHandler = { index, tag -> toast(CYLExampleLocalizedString(context, "删除标签 id = %ld，位置 = %ld", tag.identifier, index)) }
        val add = Button(context).apply {
            text = CYLExampleLocalizedString(context, "添加标签")
            setOnClickListener { addTag() }
        }
        view = sampleColumn(context, listOf(tagListView, textField, add))
    }

    /**
     * tv_add: the typed text or "ADD A TAG", deletable half the time, one of the five colors.
     */
    fun addTag() {
        val text = textField.text.toString()
        val tag = CYLTag(text.ifEmpty { CYLExampleLocalizedString(context, "添加标签") })
        tag.isDeletable = Random.nextInt(CYLTagSampleMetrics.DELETABLE_CHANCE) == 0
        tag.backgroundColor = color(Random.nextInt(colors.size))
        tag.identifier = tagListView.tags.size
        tagListView.addTag(tag)
    }

    private fun toast(text: String) = Toast.makeText(context, text, Toast.LENGTH_SHORT).show()
}

/**
 * `CYLTagContainerSampleViewController`: whilu/AndroidTagView's sample on `CYLTagListView`: six tag containers, each with
 * the attributes of the sample's XML, and "add tag". The network photos of the first container's avatars and the style
 * values the library does not have (tall avatar, elevation, cross image) are left out.
 */
class CYLTagContainerSampleScreen(private val context: Context) : CYLMenuScreen {
    override val title: CharSequence = CYLExampleLocalizedString(context, "标签容器示例")
    var containers: List<CYLTagListView> = emptyList()
        private set
    val textField = EditText(context).apply { hint = CYLExampleLocalizedString(context, "新标签") }
    override val view: View

    companion object {
        val welcomeTitle = "Welcome to use Android ${Build.VERSION.RELEASE} CollectionViewClassifyMenu"
        // NOLOCALIZE-BEGIN: deliberately multilingual sample tags, as iOS
        val list1 = listOf("Java", "C++", "Python", "Swift", "你好，这是一个TAG。你好，这是一个TAG。你好，这是一个TAG。你好，这是一个TAG。",
            "PHP", "JavaScript", "Html", welcomeTitle)
        val list2 = listOf("China", "USA", "Austria", "Japan", "Sudan", "Spain", "UK", "Germany", "Niger", "Poland", "Norway",
            "Uruguay", "Brazil")
        val list3 = listOf("Persian", "波斯语", "فارسی", "Hello", "你好", "سلام")
        // NOLOCALIZE-END
        val list4 = listOf("Adele", "Whitney Houston")
        val list5 = listOf("Custom Red Color", "Custom Blue Color")
        val list6 = listOf("Starred", "A long tag that wraps onto a second line instead of leaving the container", "End")

        private const val CONTAINER_PADDING = 10f
        private const val CONTAINER_BORDER_WIDTH = 0.5f
        private const val CONTAINER_CORNER_RADIUS = 10f
        private const val CONTAINER_BACKGROUND_ALPHA = 0x11
        private const val CONTAINER_BORDER_ALPHA = 0x22
        private const val SQUARE_BORDER_WIDTH = 4f
        private const val GREEN_BORDER_ALPHA = 0x33
        private const val BLUE_BORDER_ALPHA = 0x33
        private const val TAG_GRAY = 0x66
        private const val TAG_CORNER_RADIUS = 1f
        private const val THIRD_MAX_TITLE_LENGTH = 18
        private const val SIXTH_MAX_TITLE_LENGTH = 100
        private const val THIRD_TAG_INSETS_VERTICAL = 10f
        private const val THIRD_TAG_INSETS_HORIZONTAL = 15f
        private const val RIPPLE_ALPHA = 47 / 255f
        private const val RIPPLE_SECONDS = 2.0
        private const val SELECTED_RED = 0xFF
        private const val FULL_CHANNEL = 0xFF
        private const val AVATAR_YELLOW_GREEN = 0xCC
        private const val SELECTED_GREEN = 0x76
        private const val SELECTED_BLUE = 0x69
        private const val SELECTED_ALPHA = 0x33
        private const val CUSTOM_BORDER_COLOR = Color.BLACK
        private val customColors = listOf("#ff0000", "#0000ff")

        /**
         * {backgroundColor, tagBorderColor, tagTextColor, tagSelectedBackgroundColor} of list5.
         */
        fun colors5() = customColors.map {
            CYLTagColors(Color.parseColor(it), CUSTOM_BORDER_COLOR, Color.WHITE, Color.parseColor("#999999"))
        }
    }

    init {
        containers = buildContainers()
        val add = Button(context).apply {
            text = CYLExampleLocalizedString(context, "添加")
            setOnClickListener { addTag() }
        }
        val addRow = LinearLayout(context).apply {
            addView(textField, LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.WRAP_CONTENT, 1f))
            addView(add, LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.WRAP_CONTENT, 1f))
        }
        view = sampleColumn(context, listOf(containers[0], addRow) + containers.drop(1))
    }

    /**
     * A TagContainerLayout with the library's defaults: the container's #11FF0000 background, a 0.5 dp #22FF0000 border
     * with a 10 dp radius, 10 dp padding.
     */
    private fun makeContainer(configure: (CYLTagListView, CYLMenuStyle) -> Unit): CYLTagListView {
        val list = CYLTagListView(context)
        val style = CYLMenuStyle.tagContainerStyle()
        style.backgroundStyle = CYLTagBackgroundStyle.CYLTagBackgroundStyleLiquidGlass
        style.sectionInsets = CYLEdgeInsets(CONTAINER_PADDING, CONTAINER_PADDING, CONTAINER_PADDING, CONTAINER_PADDING)
        style.backgroundColor = Color.argb(CONTAINER_BACKGROUND_ALPHA, FULL_CHANNEL, 0, 0)
        style.interitemSpacing = CYLTagSampleMetrics.SPACING
        style.lineSpacing = CYLTagSampleMetrics.SPACING
        list.containerBorderWidth = CONTAINER_BORDER_WIDTH
        list.containerBorderColor = Color.argb(CONTAINER_BORDER_ALPHA, FULL_CHANNEL, 0, 0)
        list.containerCornerRadius = CONTAINER_CORNER_RADIUS
        list.isScrollEnabled = false
        // tag_clickable is false by default; the sample turns it on where it wants taps.
        list.allowsTapping = false
        list.colorTheme = CYLTagColorTheme.CYLTagColorThemePureCyan
        configure(list, style)
        list.style = style
        return list
    }

    private fun clickToast(list: CYLTagListView) {
        list.tagClickHandler = { position, tag -> toast(CYLExampleLocalizedString(context, "点击位置：%ld，文字：%@", position, tag.title)) }
    }

    private fun crossToast(list: CYLTagListView) {
        list.tagDeleteHandler = { position, _ -> toast(CYLExampleLocalizedString(context, "点了标签的叉！位置 = %ld", position)) }
    }

    private fun avatar(): Drawable {
        val d = context.resources.displayMetrics.density
        val size = (CYLTagSampleMetrics.AVATAR_SIZE * d).toInt()
        return GradientDrawable().apply { shape = GradientDrawable.OVAL; setColor(Color.rgb(FULL_CHANNEL, AVATAR_YELLOW_GREEN, 0)); setSize(size, size) }
    }

    private fun buildContainers(): List<CYLTagListView> {
        // tagcontainerLayout1: drag, clickable, cross, pure teal, the default avatar.
        val first = makeContainer { list, _ ->
            list.allowsReordering = true
            list.allowsTapping = true
            list.colorTheme = CYLTagColorTheme.CYLTagColorThemePureTeal
            list.removesItemsOnDelete = false
            list.defaultTagImage = avatar()
        }
        first.setTagsWithTitles(list1)
        first.tags.forEach { it.isDeletable = true }
        first.reloadMenuData()
        clickToast(first)
        first.tagLongPressHandler = { position, _ -> confirmDelete(position) }
        first.longPressAccessibilityActionName = CYLExampleLocalizedString(context, "删除")
        crossToast(first)

        // tagcontainerLayout2: transparent, a 4 dp #3300ff00 border, square, drag, not clickable, random colors.
        val second = makeContainer { list, style ->
            style.backgroundColor = Color.TRANSPARENT
            list.containerBorderColor = Color.argb(GREEN_BORDER_ALPHA, 0, FULL_CHANNEL, 0)
            list.containerBorderWidth = SQUARE_BORDER_WIDTH
            list.containerCornerRadius = 0f
            list.allowsReordering = true
            list.colorTheme = CYLTagColorTheme.CYLTagColorThemeRandom
        }
        second.setTagsWithTitles(list2)

        // tagcontainerLayout3: right-aligned, white tags with a #330000ff border, selectable, cross on the left.
        val third = makeContainer { list, style ->
            style.backgroundColor = Color.TRANSPARENT
            style.rowAlignment = CYLTagRowAlignment.CYLTagRowAlignmentTrailing
            style.maximumTitleLength = THIRD_MAX_TITLE_LENGTH
            style.deleteIndicatorPlacement = CYLTagDeleteIndicatorPlacement.CYLTagDeleteIndicatorPlacementLeading
            style.tagContentInsets = CYLEdgeInsets(THIRD_TAG_INSETS_VERTICAL, THIRD_TAG_INSETS_HORIZONTAL, THIRD_TAG_INSETS_VERTICAL, THIRD_TAG_INSETS_HORIZONTAL)
            for (appearance in listOf(style.normalAppearance, style.selectedAppearance)) {
                appearance.backgroundColor = Color.WHITE
                appearance.borderColor = Color.argb(BLUE_BORDER_ALPHA, 0, 0, FULL_CHANNEL)
                appearance.borderWidth = 1f
                appearance.cornerRadius = TAG_CORNER_RADIUS
                appearance.textColor = Color.rgb(TAG_GRAY, TAG_GRAY, TAG_GRAY)
            }
            style.selectedAppearance.backgroundColor = Color.argb(SELECTED_ALPHA, SELECTED_RED, SELECTED_GREEN, SELECTED_BLUE)
            list.containerBorderColor = Color.argb(GREEN_BORDER_ALPHA, TAG_GRAY, TAG_GRAY, TAG_GRAY)
            list.containerCornerRadius = 0f
            list.allowsTapping = true
            list.colorTheme = CYLTagColorTheme.CYLTagColorThemeNone
            list.removesItemsOnDelete = false
        }
        third.setTagsWithTitles(list3)
        third.tags.forEach { it.isDeletable = true }
        third.reloadMenuData()
        third.tagClickHandler = { position, tag ->
            val selected = third.selectedIndexPaths.map { it.item }
            // Deselect all when an unselected tag is tapped while others are selected; otherwise show the toast.
            if (selected.isEmpty() || position in selected) {
                toast(CYLExampleLocalizedString(context, "点击位置：%ld，文字：%@", position, tag.title))
            } else {
                third.deselectAllItems()
            }
        }
        third.tagLongPressHandler = { position, _ ->
            third.toggleSelectionOfItemAtIndexPath(CYLIndexPath(position, 0))
            toast(CYLExampleLocalizedString(context, "已选位置：%@", third.selectedIndexPaths.joinToString(", ") { it.item.toString() }))
        }
        third.longPressAccessibilityActionName = CYLExampleLocalizedString(context, "选择或取消选择")
        third.selectedTagDragHandler = { _, tag -> toast(CYLExampleLocalizedString(context, "拖动：%@", tag.title)) }

        // tagcontainerLayout4: centered, clickable, a 2 s black ripple at alpha 47, pure teal.
        val fourth = makeContainer { list, style ->
            style.rowAlignment = CYLTagRowAlignment.CYLTagRowAlignmentCenter
            style.rippleColor = Color.BLACK
            style.rippleAlpha = RIPPLE_ALPHA
            style.rippleDuration = RIPPLE_SECONDS
            list.allowsTapping = true
            list.colorTheme = CYLTagColorTheme.CYLTagColorThemePureTeal
        }
        fourth.setTagsWithTitles(list4)
        clickToast(fourth)

        // tagcontainerLayout5: a 4 dp square border, not clickable, random theme, but custom colors per tag.
        val fifth = makeContainer { list, _ ->
            list.containerBorderWidth = SQUARE_BORDER_WIDTH
            list.containerCornerRadius = 0f
            list.colorTheme = CYLTagColorTheme.CYLTagColorThemeRandom
        }
        fifth.setTagsWithTitles(list5, colors5())

        // tagcontainerLayout6: gravity end, 100 characters, wrapping titles, cyan tags, no cross on the last tag.
        val sixth = makeContainer { list, style ->
            style.rowAlignment = CYLTagRowAlignment.CYLTagRowAlignmentTrailing
            style.maximumTitleLength = SIXTH_MAX_TITLE_LENGTH
            style.titleMaxLines = CYLTagTitleMaxLines.UNLIMITED
            for (appearance in listOf(style.normalAppearance, style.selectedAppearance, style.disabledAppearance)) {
                appearance.backgroundColor = Color.parseColor("#E0F7FA")
                appearance.borderColor = Color.parseColor("#4DD0E1")
                appearance.textColor = Color.parseColor("#006064")
            }
            list.colorTheme = CYLTagColorTheme.CYLTagColorThemeNone
            list.removesItemsOnDelete = false
        }
        sixth.setTagsWithTitles(list6)
        sixth.tags.forEach { it.isDeletable = true }
        sixth.tags.last().isDeletable = false
        sixth.reloadMenuData()
        crossToast(sixth)
        return listOf(first, second, third, fourth, fifth, sixth)
    }

    fun addTag() {
        containers.first().addTagWithTitle(textField.text.toString())
    }

    /**
     * onTagLongClick: "You will delete this tag!".
     */
    private fun confirmDelete(position: Int) {
        AlertDialog.Builder(context)
            .setTitle(CYLExampleLocalizedString(context, "长按"))
            .setMessage(CYLExampleLocalizedString(context, "将删除这个标签！"))
            .setPositiveButton(CYLExampleLocalizedString(context, "删除")) { _, _ ->
                val first = containers.first()
                if (position < first.tags.size) first.removeTagAtIndex(position)
            }
            .setNegativeButton(CYLExampleLocalizedString(context, "取消"), null)
            .show()
    }

    private fun toast(text: String) = Toast.makeText(context, text, Toast.LENGTH_SHORT).show()
}

/**
 * A scrolling column of the sample's views.
 */
private fun sampleColumn(context: Context, views: List<View>): View = ScrollView(context).apply {
    val d = context.resources.displayMetrics.density
    setBackgroundColor(Color.rgb(CYLTagSampleMetrics.PAGE_BACKGROUND_GRAY, CYLTagSampleMetrics.PAGE_BACKGROUND_GRAY, CYLTagSampleMetrics.PAGE_BACKGROUND_GRAY))
    addView(LinearLayout(context).apply {
        orientation = LinearLayout.VERTICAL
        val padding = (CYLTagSampleMetrics.SCREEN_PADDING * d).toInt()
        setPadding(padding, padding, padding, padding)
        views.forEach { addView(it, LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT).apply { bottomMargin = (CYLTagSampleMetrics.ROW_SPACING * d).toInt() }) }
    })
}
