package com.cyl.classifymenu.example.menu

import android.content.Context
import android.graphics.Color
import android.graphics.Typeface
import android.graphics.drawable.GradientDrawable
import android.net.Uri
import android.util.TypedValue
import android.view.Gravity
import android.view.View
import android.widget.LinearLayout
import android.widget.ScrollView
import android.widget.TextView
import androidx.core.content.ContextCompat
import com.cyl.classifymenu.CYLControlState
import com.cyl.classifymenu.CYLEdgeInsets
import com.cyl.classifymenu.CYLFont
import com.cyl.classifymenu.CYLIndexPath
import com.cyl.classifymenu.CYLMenuAnimationURLWithOptions
import com.cyl.classifymenu.CYLMenuSelectionMode
import com.cyl.classifymenu.CYLMenuStyle
import com.cyl.classifymenu.CYLOffset
import com.cyl.classifymenu.CYLSize
import com.cyl.classifymenu.CYLTagListView
import com.cyl.classifymenu.example.R

/**
 * `CYLTagStyleDemoContent`.
 */
enum class CYLTagStyleDemoContent { ICON_AND_TITLE, ICON_ONLY, TITLE_ONLY }

/**
 * `CYLTagStyleDemoViewController`: a preview of tags (several selected, one disabled) over a list of actions; each tap
 * of an action changes one property of the style (the next value of a cycle) and shows the current value.
 */
class CYLTagStyleScreen(private val context: Context, private val navigator: CYLMenuNavigator) : CYLMenuScreen {
    override val title: CharSequence = CYLExampleLocalizedString(context, "标签样式")
    val tagListView = CYLTagListView(context)
    var style: CYLMenuStyle = demoStyle()
        private set
    var content = CYLTagStyleDemoContent.ICON_AND_TITLE
        private set
    var animationLibrary: String? = null
        private set
    var usesSelectedImage = true
        private set
    private val steps = HashMap<String, Int>()
    private val list = LinearLayout(context).apply { orientation = LinearLayout.VERTICAL }
    private val d = context.resources.displayMetrics.density
    override val view: View

    companion object {
        private val palette = listOf(Color.rgb(255, 149, 0), Color.rgb(175, 82, 222), Color.rgb(48, 176, 199), Color.rgb(255, 45, 85), Color.rgb(88, 86, 214), Color.rgb(52, 199, 89))
        private val systemBlue = Color.rgb(0, 122, 255)

        fun demoStyle() = CYLMenuStyle().apply {
            setIconColor(systemBlue, CYLControlState.NORMAL)
            setIconColor(Color.WHITE, CYLControlState.SELECTED)
            selectedAppearance.backgroundColor = systemBlue
            selectedAppearance.borderColor = systemBlue
            imageSize = CYLSize(16f, 16f)
            imageTitleSpacing = 4f
            itemHeight = 34f
            sectionInsets = CYLEdgeInsets(12f, 16f, 12f, 16f)
        }

        private val actionTitles = mapOf(
            "iconColor.normal" to "设置 iconColor（normal）", "iconColor.selected" to "设置 iconColor（selected）",
            "titleColor.normal" to "设置文字颜色 titleTextAttributes（normal）", "titleColor.selected" to "设置文字颜色 titleTextAttributes（selected）",
            "font" to "设置字体 NSFontAttributeName", "imageTitleSpacing" to "设置 icon 与文字间距 imageTitleSpacing",
            "imageSize" to "设置 icon 大小 imageSize", "imageInsets" to "设置 imageInsets",
            "titlePositionAdjustment" to "设置 titlePositionAdjustment", "imagePositionAdjustment" to "设置 imagePositionAdjustment",
            "content.iconAndTitle" to "显示 icon + title", "content.iconOnly" to "只显示 icon", "content.titleOnly" to "只显示 title",
            "layoutCentered" to "切换 layoutCentered（只有 icon 或 title 时居中）", "selectedImage" to "切换选中图片 selectedImage",
            "backgroundColor.normal" to "设置背景色 backgroundColor（normal）", "backgroundColor.selected" to "设置背景色 backgroundColor（selected）",
            "borderColor" to "设置边框颜色 borderColor", "borderWidth" to "设置边框宽度 borderWidth",
            "cornerRadius" to "设置圆角 cornerRadius（0 为胶囊）", "margin" to "设置内边距 margin",
            "animation.lottie" to "Lottie 动效图标", "animation.pag" to "PAG 动效图标", "animation.rive" to "Rive 动效图标",
            "animation.gif" to "GIF 动效图标", "animation.off" to "关闭动效（静态图标）", "animationSpeed" to "设置动效速度 animationSpeed",
            "configuration" to "配置文件 / 字典（map）初始化", "tagCloud" to "标签云：android-tagview 的初始化方式",
            "sample.tagCloud" to "android-tagview 示例（Swift 版）", "sample.imageTag" to "TagViewGroup 示例：图片标签",
            "sample.tagContainer" to "AndroidTagView 示例：标签容器", "reset" to "重置 reset",
        )

        private fun offsetString(offset: CYLOffset) = "{${fmt(offset.horizontal)}, ${fmt(offset.vertical)}}"
        private fun fmt(value: Float) = if (value == Math.floor(value.toDouble()).toFloat()) value.toInt().toString() else value.toString()
    }

    fun actionIdentifiers() = listOf(
        listOf("iconColor.normal", "iconColor.selected", "titleColor.normal", "titleColor.selected", "font",
            "imageTitleSpacing", "imageSize", "imageInsets", "titlePositionAdjustment", "imagePositionAdjustment",
            "content.iconAndTitle", "content.iconOnly", "content.titleOnly", "layoutCentered", "selectedImage"),
        listOf("backgroundColor.normal", "backgroundColor.selected", "borderColor", "borderWidth", "cornerRadius", "margin"),
        listOf("animation.lottie", "animation.pag", "animation.rive", "animation.gif", "animation.off", "animationSpeed", "configuration", "tagCloud"),
        listOf("sample.tagCloud", "sample.imageTag", "sample.tagContainer"),
        listOf("reset"),
    )

    fun titleForSection(section: Int) = CYLExampleLocalizedString(context, listOf(
        "标题与图标（参照 CYLFlatDesignTabBarItem）", "背景、边框与圆角（参照 CYLBadgeView）",
        "动效图标（CYLTabBarController 动效引擎）", "Android 标签库示例（Swift 复刻）", "其它")[section])

    fun titleForAction(identifier: String) = CYLExampleLocalizedString(context, actionTitles[identifier] ?: identifier)

    /**
     * Every action is available (the screens they open are ported).
     */
    private fun isAvailable(@Suppress("UNUSED_PARAMETER") identifier: String) = true

    /**
     * The Android tag libraries' samples are Swift copies on iOS; here they are the original libraries, each a tab of
     * the app (TagView: android-tagview, Container: AndroidTagView, ViewGroup: TagViewGroup). The tab is selected.
     */
    private fun selectAppTab(pageIdentifier: String) {
        val controller = (context as? com.cyl.classifymenu.example.MainActivity)?.tabBarController ?: return
        val index = listOf("kaede", "lujun", "licrafter").indexOf(pageIdentifier)
        if (index < 0) return
        // Back to the Menu home first: it shows the app's tab bar again (hidden while a screen is pushed).
        while (navigator.pop()) Unit
        controller.selectedIndex = index
    }

    fun color(step: Int) = palette[step % palette.size]

    private fun lightColor(step: Int) = Color.argb(38, Color.red(color(step)), Color.green(color(step)), Color.blue(color(step)))

    private fun nextStep(identifier: String): Int = (steps[identifier] ?: 0).also { steps[identifier] = it + 1 }

    private val appearances get() = listOf(style.normalAppearance, style.selectedAppearance, style.disabledAppearance)

    init {
        tagListView.selectionMode = CYLMenuSelectionMode.CYLMenuSelectionModeMultiple
        tagListView.showsSectionHeaders = false
        tagListView.isScrollEnabled = false
        val root = LinearLayout(context).apply {
            orientation = LinearLayout.VERTICAL
            setBackgroundColor(Color.WHITE)
            addView(tagListView, LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT))
            addView(View(context).apply { setBackgroundColor(Color.rgb(198, 198, 200)) }, LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, 1))
            addView(ScrollView(context).apply {
                setBackgroundColor(Color.rgb(242, 242, 247))
                addView(list)
            }, LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, 0, 1f))
        }
        view = root
        reloadItems()
        applyStyle()
    }

    fun performAction(identifier: String) {
        val style = this.style
        val step = nextStep(identifier)
        when (identifier) {
            "iconColor.normal" -> style.setIconColor(color(step), CYLControlState.NORMAL)
            "iconColor.selected" -> style.setIconColor(listOf(Color.rgb(255, 204, 0), Color.BLACK, Color.WHITE)[step % 3], CYLControlState.SELECTED)
            "titleColor.normal", "titleColor.selected" -> {
                val state = if (identifier.endsWith("selected")) CYLControlState.SELECTED else CYLControlState.NORMAL
                val (font, _) = style.titleTextAttributesForState(state)
                val white = (255 * (1 - 0.15f * (step % 3))).toInt()
                style.setTitleTextAttributes(font, if (state == CYLControlState.SELECTED) Color.rgb(white, white, white) else color(step), state)
            }
            "font" -> {
                val fonts = listOf(CYLFont(16f, Typeface.DEFAULT_BOLD), CYLFont.systemFont(12f), CYLFont(15f, Typeface.create(Typeface.DEFAULT, Typeface.ITALIC)), CYLFont.systemFont(14f))
                appearances.forEach { it.font = fonts[step % fonts.size] }
            }
            "imageTitleSpacing" -> style.imageTitleSpacing = listOf(10f, 0f, 4f)[step % 3]
            "imageSize" -> listOf(20f, 10f, 14f)[step % 3].let { style.imageSize = CYLSize(it, it) }
            "imageInsets" -> (if (step % 2 == 0) 3f else 0f).let { style.imageInsets = CYLEdgeInsets(it, it, it, it) }
            "titlePositionAdjustment" -> style.titlePositionAdjustment = listOf(CYLOffset(0f, -4f), CYLOffset(4f, 0f), CYLOffset.ZERO)[step % 3]
            "imagePositionAdjustment" -> style.imagePositionAdjustment = listOf(CYLOffset(0f, -4f), CYLOffset(-4f, 0f), CYLOffset.ZERO)[step % 3]
            "content.iconAndTitle", "content.iconOnly", "content.titleOnly" -> {
                content = when (identifier) { "content.iconOnly" -> CYLTagStyleDemoContent.ICON_ONLY; "content.titleOnly" -> CYLTagStyleDemoContent.TITLE_ONLY; else -> CYLTagStyleDemoContent.ICON_AND_TITLE }
                reloadItems()
            }
            "layoutCentered" -> style.layoutCentered = !style.layoutCentered
            "selectedImage" -> { usesSelectedImage = !usesSelectedImage; reloadItems() }
            "backgroundColor.normal" -> style.normalAppearance.backgroundColor = lightColor(step)
            "backgroundColor.selected" -> { style.selectedAppearance.backgroundColor = color(step); style.selectedAppearance.borderColor = color(step) }
            "borderColor" -> style.normalAppearance.borderColor = color(step)
            "borderWidth" -> listOf(2f, 0f, 1f, 0.5f)[step % 4].let { width -> appearances.forEach { it.borderWidth = width } }
            "cornerRadius" -> listOf(0f, 8f, 3f)[step % 3].let { radius -> appearances.forEach { it.cornerRadius = radius } }
            "margin" -> listOf(18f, 4f, 10f)[step % 3].let { margin -> appearances.forEach { it.margin = margin } }
            "animation.lottie", "animation.pag", "animation.rive", "animation.gif", "animation.off" -> {
                val library = identifier.removePrefix("animation.")
                animationLibrary = if (library == "off") null else library
                reloadItems()
                tagListView.post { tagListView.selectedIndexPaths.forEach { tagListView.tagButtonAtIndexPath(it)?.playAnimation() } }
            }
            "animationSpeed" -> style.animationSpeed = listOf(0.5f, 2f, 1f)[step % 3]
            "configuration" -> { navigator.push(CYLTagConfigurationScreen(context)); return }
            "tagCloud" -> { navigator.push(CYLTagCloudScreen(context)); return }
            "sample.tagCloud" -> { selectAppTab("kaede"); return }
            "sample.imageTag" -> { selectAppTab("licrafter"); return }
            "sample.tagContainer" -> { selectAppTab("lujun"); return }
            "reset" -> {
                this.style = demoStyle()
                content = CYLTagStyleDemoContent.ICON_AND_TITLE
                animationLibrary = null
                usesSelectedImage = true
                steps.clear()
                reloadItems()
            }
            else -> return
        }
        applyStyle()
    }

    fun valueForAction(identifier: String): String {
        val style = this.style
        when (identifier) {
            "imageTitleSpacing" -> return fmt(style.imageTitleSpacing)
            "imageSize" -> return "{${fmt(style.imageSize.width)}, ${fmt(style.imageSize.height)}}"
            "imageInsets" -> return style.imageInsets.let { "{${fmt(it.top)}, ${fmt(it.left)}, ${fmt(it.bottom)}, ${fmt(it.right)}}" }
            "titlePositionAdjustment" -> return offsetString(style.titlePositionAdjustment)
            "imagePositionAdjustment" -> return offsetString(style.imagePositionAdjustment)
            "layoutCentered" -> return if (style.layoutCentered) "YES" else "NO"
            "selectedImage" -> return if (usesSelectedImage) "YES" else "NO"
            "font" -> return style.normalAppearance.font.let { "${if (it.isBold) "Bold" else if (it.typeface.isItalic) "Italic" else "Regular"} ${fmt(it.size)}" }
            "borderWidth" -> return String.format(java.util.Locale.US, "%.1f", style.normalAppearance.borderWidth)
            "cornerRadius" -> return fmt(style.normalAppearance.cornerRadius)
            "margin" -> return fmt(style.normalAppearance.margin)
            "animationSpeed" -> return String.format(java.util.Locale.US, "%.1f", style.animationSpeed)
        }
        if (identifier.startsWith("animation.")) {
            val library = identifier.removePrefix("animation.")
            return if ((library == "off" && animationLibrary == null) || library == animationLibrary) "✓" else ""
        }
        if (identifier.startsWith("content.")) {
            return if (identifier == listOf("content.iconAndTitle", "content.iconOnly", "content.titleOnly")[content.ordinal]) "✓" else ""
        }
        return ""
    }

    fun reloadItems() {
        val samples = listOf(
            Triple("首页", R.drawable.ic_style_house, R.drawable.ic_style_house_fill),
            Triple("同城", R.drawable.ic_style_mappin, R.drawable.ic_style_mappin_fill),
            Triple("消息", R.drawable.ic_style_message, R.drawable.ic_style_message_fill),
            Triple("我的", R.drawable.ic_style_person, R.drawable.ic_style_person_fill),
            Triple("一个很长很长的标签标题", R.drawable.ic_style_star, R.drawable.ic_style_star_fill),
            Triple("已禁用", R.drawable.ic_style_nosign, R.drawable.ic_style_nosign),
        )
        val items = ArrayList<CYLExampleMenuItem>()
        for ((key, image, selected) in samples) {
            val iconOnly = content == CYLTagStyleDemoContent.ICON_ONLY
            val titleOnly = content == CYLTagStyleDemoContent.TITLE_ONLY
            val item = CYLExampleMenuItem(if (iconOnly) "" else CYLExampleLocalizedString(context, key))
            item.image = if (titleOnly) null else ContextCompat.getDrawable(context, image)
            item.selectedImage = if (titleOnly || !usesSelectedImage) null else ContextCompat.getDrawable(context, selected)
            item.isEnabled = key != "已禁用"
            if (animationLibrary != null && item.isEnabled && !titleOnly) item.animationURL = animationURL(items.size)
            items.add(item)
        }
        val selection = tagListView.selectedIndexPaths
        tagListView.menuDataSource = CYLExampleMenuSource(listOf(CYLExampleMenuSection("", items)))
        tagListView.reloadMenuData()
        tagListView.selectedIndexPaths = selection.ifEmpty { listOf(CYLIndexPath(0, 0)) }
    }

    fun animationURL(index: Int): Uri? {
        val files = mapOf(
            "lottie" to listOf("CYLMenuExample.bundle/Animations/Lottie/tab_home_animate.json", "CYLMenuExample.bundle/Animations/Lottie/tab_me_animate.json"),
            "gif" to listOf("CYLMenuExample.bundle/Animations/GIF/tab_star.gif", "CYLMenuExample.bundle/Animations/GIF/cyl_tab_sample_animated.gif"),
            "pag" to listOf("pag-ios/0.pag", "pag-ios/1.pag"),
            "rive" to listOf("CYLMenuExample.bundle/Animations/Rive/house.riv", "CYLMenuExample.bundle/Animations/Rive/menu_button.riv"),
        )
        val library = animationLibrary ?: return null
        val names = files[library] ?: return null
        val url = Uri.parse("file:///android_asset/" + names[index % names.size])
        if (library != "rive") return url
        return CYLMenuAnimationURLWithOptions(url, if (index % 2 == 0) mapOf("stateMachine" to "State Machine 1")
            else mapOf("stateMachine" to "State Machine", "input" to "isOpen", "duration" to "0"))
    }

    fun applyStyle() {
        tagListView.style = style
        reloadList()
    }

    private fun reloadList() {
        val scroll = list.parent as? ScrollView
        val offset = scroll?.scrollY ?: 0
        list.removeAllViews()
        actionIdentifiers().forEachIndexed { section, identifiers ->
            list.addView(TextView(context).apply {
                text = titleForSection(section)
                setTextSize(TypedValue.COMPLEX_UNIT_SP, 13f)
                setTextColor(Color.argb(153, 60, 60, 67))
                setPadding((32 * d).toInt(), (18 * d).toInt(), (32 * d).toInt(), (6 * d).toInt())
                androidx.core.view.ViewCompat.setAccessibilityHeading(this, true)
            })
            val group = LinearLayout(context).apply {
                orientation = LinearLayout.VERTICAL
                background = GradientDrawable().apply { setColor(Color.WHITE); cornerRadius = 10 * d }
                clipToOutline = true
            }
            identifiers.forEachIndexed { row, identifier ->
                if (row > 0) group.addView(View(context).apply { setBackgroundColor(Color.rgb(224, 224, 224)) }, LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, 1).apply { leftMargin = (16 * d).toInt() })
                val available = isAvailable(identifier)
                val title = titleForAction(identifier)
                val value = valueForAction(identifier)
                group.addView(LinearLayout(context).apply {
                    gravity = Gravity.CENTER_VERTICAL
                    minimumHeight = (44 * d).toInt()
                    setPadding((16 * d).toInt(), (8 * d).toInt(), (16 * d).toInt(), (8 * d).toInt())
                    addView(TextView(context).apply {
                        text = title
                        setTextSize(TypedValue.COMPLEX_UNIT_SP, 15f)
                        setTextColor(if (available) Color.BLACK else Color.GRAY)
                    }, LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.WRAP_CONTENT, 1f))
                    addView(TextView(context).apply {
                        text = value
                        setTextSize(TypedValue.COMPLEX_UNIT_SP, 15f)
                        setTextColor(Color.argb(153, 60, 60, 67))
                        setPadding((8 * d).toInt(), 0, 0, 0)
                    })
                    isEnabled = available
                    isClickable = true
                    isFocusable = true
                    contentDescription = if (value.isEmpty()) title else "$title, $value"
                    setBackgroundResource(TypedValue().also { context.theme.resolveAttribute(android.R.attr.selectableItemBackground, it, true) }.resourceId)
                    setOnClickListener { performAction(identifier) }
                })
            }
            list.addView(group, LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT).apply { leftMargin = (16 * d).toInt(); rightMargin = (16 * d).toInt() })
        }
        list.addView(View(context), LinearLayout.LayoutParams(1, (24 * d).toInt()))
        scroll?.post { scroll.scrollTo(0, offset) }
    }
}
