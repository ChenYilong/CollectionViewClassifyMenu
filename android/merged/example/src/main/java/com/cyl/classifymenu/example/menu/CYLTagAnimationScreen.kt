package com.cyl.classifymenu.example.menu

import android.content.Context
import android.graphics.Color
import android.util.TypedValue
import android.view.View
import android.widget.Button
import android.widget.LinearLayout
import android.widget.TextView
import com.cyl.classifymenu.CYLAppTintColor
import com.cyl.classifymenu.CYLIndexPath
import com.cyl.classifymenu.CYLMenuDelegate
import com.cyl.classifymenu.CYLMenuStyle
import com.cyl.classifymenu.CYLMenuStyleImageSize
import com.cyl.classifymenu.CYLMenuStyleImageTitleSpacing
import com.cyl.classifymenu.CYLMenuStyleItemHeight
import com.cyl.classifymenu.CYLMenuStyleLayoutCentered
import com.cyl.classifymenu.CYLMenuStyleNormal
import com.cyl.classifymenu.CYLMenuStyleSectionInsets
import com.cyl.classifymenu.CYLMenuStyleSelected
import com.cyl.classifymenu.CYLTagAppearanceBackgroundColor
import com.cyl.classifymenu.CYLTagAppearanceBorderColor
import com.cyl.classifymenu.CYLTagAppearanceBorderWidth
import com.cyl.classifymenu.CYLTagAppearanceCornerRadius
import com.cyl.classifymenu.CYLTagAppearanceMargin
import com.cyl.classifymenu.CYLTagAppearanceTextColor
import com.cyl.classifymenu.CYLTagButton
import com.cyl.classifymenu.CYLTagItemAnimation
import com.cyl.classifymenu.CYLTagItemAnimationOptions
import com.cyl.classifymenu.CYLTagItemAnimationRestingProgress
import com.cyl.classifymenu.CYLTagItemImage
import com.cyl.classifymenu.CYLTagItemSelectedImage
import com.cyl.classifymenu.CYLTagItemTitle
import com.cyl.classifymenu.CYLTagListView
import com.cyl.classifymenu.CYLTagListViewAllowsEmptySelection
import com.cyl.classifymenu.CYLTagListViewSections
import com.cyl.classifymenu.CYLTagListViewSelectedItems
import com.cyl.classifymenu.CYLTagListViewSelectionMode
import com.cyl.classifymenu.CYLTagListViewStyle
import com.cyl.classifymenu.CYLTagSectionItems
import com.cyl.classifymenu.CYLTagSectionStyle
import com.cyl.classifymenu.CYLTagSectionTitle
import com.cyl.classifymenu.tagListViewWithConfiguration

/**
 * `CYLTagAnimationDemoViewController`: one tag list made from a configuration dictionary, a section per animation
 * library of CYLTagListView's engine (CYLTabBarController's): Lottie (plain, with image assets and placeholders, green),
 * PAG, Rive (several state machines, icons.riv on dark tags), GIF and static images; the first tag of every section is
 * selected. "Play all" plays the selected tags; the speed button cycles 1x, 2x, 0.5x.
 */
class CYLTagAnimationScreen(private val context: Context) : CYLMenuScreen, CYLMenuDelegate {
    override val title: CharSequence = CYLExampleLocalizedString(context, "动效图标")
    val tagListView: CYLTagListView = CYLTagListView.tagListViewWithConfiguration(context, configuration(context))
    val statusLabel = TextView(context)
    private val speedButton = Button(context)
    private val d = context.resources.displayMetrics.density
    override val view: View

    companion object {
        fun sectionIdentifiers() = listOf("lottie", "lottie-images", "lottie-green", "pag", "rive", "rive-icons", "gif", "images")

        private fun animation(path: String) = "CYLMenuExample.bundle/Animations/$path"

        private fun item(context: Context, title: String, animation: String? = null, image: String? = null): MutableMap<String, Any?> =
            mutableMapOf<String, Any?>(CYLTagItemTitle to CYLExampleLocalizedString(context, title)).apply {
                animation?.let { put(CYLTagItemAnimation, it) }
                image?.let { put(CYLTagItemImage, it) }
            }

        private fun rive(context: Context, title: String, name: String, options: Map<String, String>) =
            item(context, title, animation("Rive/$name.riv")).apply { put(CYLTagItemAnimationOptions, options) }

        fun configuration(context: Context): Map<String, Any?> {
            fun section(title: String, items: List<Map<String, Any?>>, style: Map<String, Any?>? = null) =
                mutableMapOf<String, Any?>(CYLTagSectionTitle to title, CYLTagSectionItems to items).apply { style?.let { put(CYLTagSectionStyle, it) } }
            val sections = listOf(
                section("Lottie · pod 'CYLTabBarController/Lottie'", listOf(
                    item(context, "首页", animation("Lottie/tab_home_animate.json")), item(context, "消息", animation("Lottie/tab_message_animate.json")),
                    item(context, "搜索", animation("Lottie/tab_search_animate.json")), item(context, "我的", animation("Lottie/tab_me_animate.json")))),
                section(CYLExampleLocalizedString(context, "Lottie（带图片资源与占位图）"), listOf(
                    item(context, "首页", animation("Lottie/gray_tabbar_home_animation.json"), "gray_tabbar_home_animation_lottie_placeholder"),
                    item(context, "消息", animation("Lottie/gray_tabbar_message_animation.json"), "gray_tabbar_message_animation_lottie_placeholder"),
                    item(context, "我的", animation("Lottie/gray_tabbar_me_animation.json"), "gray_tabbar_me_animation_lottie_placeholder"))),
                section(CYLExampleLocalizedString(context, "Lottie（绿色主题）"), listOf(
                    item(context, "首页", animation("Lottie/green_lottie_tab_home.json")), item(context, "资讯", animation("Lottie/green_lottie_tab_news.json")),
                    item(context, "发现", animation("Lottie/green_lottie_tab_discover.json")), item(context, "我的", animation("Lottie/green_lottie_tab_mine.json")))),
                section("PAG · pod 'CYLTabBarController/PAG'", listOf(
                    item(context, "首页", "pag-ios/tab_home.pag"), item(context, "健康", "pag-ios/tab_health.pag"),
                    item(context, "动态", "pag-ios/tab_moments.pag"), item(context, "我的", "pag-ios/tab_me.pag"),
                    item(context, "动效一", "pag-ios/0.pag"),
                    item(context, "动效二", "pag-ios/1.pag").apply { put(CYLTagItemAnimationRestingProgress, 1) })),
                section("Rive · pod 'CYLTabBarController/Rive'", listOf(
                    rive(context, "首页", "house", mapOf("stateMachine" to "State Machine 1")),
                    rive(context, "完成", "check", mapOf("stateMachine" to "State Machine 1", "triggerInput" to "Check")),
                    rive(context, "菜单", "menu_button", mapOf("stateMachine" to "State Machine", "input" to "isOpen", "duration" to "0")),
                    rive(context, "按钮", "button", mapOf("animation" to "active")),
                    rive(context, "形状", "shapes", mapOf("legacy" to "1")),
                    rive(context, "卡车", "truck", mapOf("legacy" to "1")))),
                section(CYLExampleLocalizedString(context, "Rive · icons.riv（深色标签）"), listOf(
                    rive(context, "聊天", "icons", mapOf("artboard" to "CHAT", "stateMachine" to "CHAT_Interactivity", "input" to "active")),
                    rive(context, "搜索", "icons", mapOf("artboard" to "SEARCH", "stateMachine" to "SEARCH_Interactivity", "input" to "active")),
                    rive(context, "计时", "icons", mapOf("artboard" to "TIMER", "stateMachine" to "TIMER_Interactivity", "input" to "active")),
                    rive(context, "提醒", "icons", mapOf("artboard" to "BELL", "stateMachine" to "BELL_Interactivity", "input" to "active")),
                    rive(context, "我的", "icons", mapOf("artboard" to "USER", "stateMachine" to "USER_Interactivity", "input" to "active"))),
                    mapOf(CYLMenuStyleNormal to mapOf(CYLTagAppearanceBackgroundColor to "#17203A", CYLTagAppearanceTextColor to "#FFFFFF", CYLTagAppearanceBorderColor to "#17203A"),
                        CYLMenuStyleSelected to mapOf(CYLTagAppearanceBackgroundColor to "#3A4E8C", CYLTagAppearanceTextColor to "#FFFFFF", CYLTagAppearanceBorderColor to "#6792FF"))),
                section("GIF · pod 'CYLTabBarController/GIF'", listOf(
                    item(context, "火焰", animation("GIF/tab_fire.gif")), item(context, "火箭", animation("GIF/tab_rocket.gif")),
                    item(context, "星星", animation("GIF/tab_star.gif")), item(context, "示例", animation("GIF/cyl_tab_sample_animated.gif")))),
                section(CYLExampleLocalizedString(context, "静态图片（CYLTabBarController Example）"), listOf(
                    "首页" to "home", "同城" to "fishpond", "发布" to "post", "消息" to "message", "我的" to "account").map { (title, name) ->
                    item(context, title, image = "${name}_normal").apply { put(CYLTagItemSelectedImage, "${name}_highlight") }
                }),
            )
            val appearance = mapOf(CYLTagAppearanceCornerRadius to 0, CYLTagAppearanceMargin to 12, CYLTagAppearanceBorderColor to "#D1D1D6", CYLTagAppearanceBorderWidth to 1)
            val style = mapOf(
                CYLMenuStyleImageSize to "{28, 28}", CYLMenuStyleImageTitleSpacing to 6, CYLMenuStyleItemHeight to 44, CYLMenuStyleLayoutCentered to true,
                CYLMenuStyleSectionInsets to listOf(6, 16, 14, 16),
                CYLMenuStyleNormal to appearance,
                CYLMenuStyleSelected to appearance + mapOf(CYLTagAppearanceBackgroundColor to "#FFF1E6", CYLTagAppearanceTextColor to "#FF6A00", CYLTagAppearanceBorderColor to "#FF6A00"),
            )
            return mapOf(
                CYLTagListViewSelectionMode to "single",
                CYLTagListViewAllowsEmptySelection to false,
                CYLTagListViewSelectedItems to sections.indices.map { "$it-0" },
                CYLTagListViewStyle to style,
                CYLTagListViewSections to sections,
            )
        }
    }

    init {
        tagListView.menuDelegate = this
        statusLabel.apply {
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 13f)
            setTextColor(Color.argb(153, 60, 60, 67))
            text = CYLExampleLocalizedString(context, if (CYLTagButton.isAnimationEngineAvailable()) "动效引擎：CYLTabBarItemAnimationFactory 已链接" else "动效引擎未链接：显示静态图标")
        }
        fun barButton(button: Button, text: String, action: () -> Unit) = button.apply {
            this.text = text
            isAllCaps = false
            background = null
            stateListAnimator = null
            minWidth = 0
            minimumWidth = 0
            setTextColor(CYLAppTintColor)
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 15f)
            setOnClickListener { action() }
        }
        barButton(speedButton, "1x") { changeSpeed() }
        val play = barButton(Button(context), CYLExampleLocalizedString(context, "全部播放")) { playSelectedAnimations() }
        view = LinearLayout(context).apply {
            orientation = LinearLayout.VERTICAL
            setBackgroundColor(Color.WHITE)
            addView(LinearLayout(context).apply {
                gravity = android.view.Gravity.CENTER_VERTICAL
                setPadding((16 * d).toInt(), (4 * d).toInt(), (4 * d).toInt(), 0)
                addView(statusLabel, LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.WRAP_CONTENT, 1f))
                addView(speedButton)
                addView(play)
            })
            addView(tagListView, LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, 0, 1f))
        }
    }

    fun playSelectedAnimations() {
        tagListView.selectedIndexPaths.forEach { tagListView.tagButtonAtIndexPath(it)?.playAnimation() }
    }

    fun changeSpeed() {
        val style: CYLMenuStyle = tagListView.style?.copy() ?: CYLMenuStyle()
        val speeds = listOf(1f, 2f, 0.5f)
        val next = speeds.indexOf(style.animationSpeed).let { if (it < 0) 0 else it + 1 }
        style.animationSpeed = speeds[next % speeds.size]
        tagListView.style = style
        speedButton.text = (if (style.animationSpeed % 1f == 0f) style.animationSpeed.toInt().toString() else style.animationSpeed.toString()) + "x"
        playSelectedAnimations()
    }

    fun scrollToSectionIdentifier(identifier: String) {
        val section = sectionIdentifiers().indexOf(identifier)
        if (section >= 0) tagListView.scrollToSection(section, false)
    }

    override fun menuDidSelectItemAtIndexPath(menu: Any, indexPath: CYLIndexPath) {
        val source = tagListView.menuDataSource
        val section = source?.menuTitleForSection(indexPath.section).orEmpty()
        val title = source?.menuTitleForItemAtIndexPath(indexPath).orEmpty()
        statusLabel.text = CYLExampleLocalizedString(context, "点击「%@」", "$section · $title")
    }
}
