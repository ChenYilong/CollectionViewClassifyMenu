package com.cyl.classifymenu.example.menu

import android.content.Context
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.LinearGradient
import android.graphics.Paint
import android.graphics.Shader
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.net.Uri
import android.util.TypedValue
import android.view.View
import android.widget.LinearLayout
import android.widget.ScrollView
import android.widget.TextView
import com.cyl.classifymenu.CYLEdgeInsets
import com.cyl.classifymenu.CYLIndexPath
import com.cyl.classifymenu.CYLMenuDelegate
import com.cyl.classifymenu.CYLMenuFoldControl
import com.cyl.classifymenu.CYLMenuFoldControlContent
import com.cyl.classifymenu.CYLMenuFoldControlPosition
import com.cyl.classifymenu.CYLMenuSelectionMode
import com.cyl.classifymenu.CYLMenuStyleHighlightedBackgroundColor
import com.cyl.classifymenu.CYLMenuStyleImageSize
import com.cyl.classifymenu.CYLMenuStyleImageTitleSpacing
import com.cyl.classifymenu.CYLMenuStyleInteritemSpacing
import com.cyl.classifymenu.CYLMenuStyleItemHeight
import com.cyl.classifymenu.CYLMenuStyleLayoutCentered
import com.cyl.classifymenu.CYLMenuStyleLineSpacing
import com.cyl.classifymenu.CYLMenuStyleNormal
import com.cyl.classifymenu.CYLMenuStyleSelected
import com.cyl.classifymenu.CYLMenuStyleTagContentInsets
import com.cyl.classifymenu.CYLSize
import com.cyl.classifymenu.CYLTag
import com.cyl.classifymenu.CYLTagAppearanceBackgroundColor
import com.cyl.classifymenu.CYLTagAppearanceBorderColor
import com.cyl.classifymenu.CYLTagAppearanceBorderWidth
import com.cyl.classifymenu.CYLTagAppearanceCornerRadius
import com.cyl.classifymenu.CYLTagAppearanceIconColor
import com.cyl.classifymenu.CYLTagAppearanceTextColor
import com.cyl.classifymenu.CYLTagButton
import com.cyl.classifymenu.CYLTagItemAnimation
import com.cyl.classifymenu.CYLTagItemDeletable
import com.cyl.classifymenu.CYLTagItemIdentifier
import com.cyl.classifymenu.CYLTagItemImage
import com.cyl.classifymenu.CYLTagItemSelectedImage
import com.cyl.classifymenu.CYLTagItemStyle
import com.cyl.classifymenu.CYLTagItemTitle
import com.cyl.classifymenu.CYLTagListView
import com.cyl.classifymenu.CYLTagListViewFoldControl
import com.cyl.classifymenu.CYLTagListViewScrollEnabled
import com.cyl.classifymenu.CYLTagListViewSections
import com.cyl.classifymenu.CYLTagListViewSelectedItems
import com.cyl.classifymenu.CYLTagListViewSelectionMode
import com.cyl.classifymenu.CYLTagListViewStyle
import com.cyl.classifymenu.CYLTagListViewTags
import com.cyl.classifymenu.CYLTagSectionItems
import com.cyl.classifymenu.CYLTagSectionTitle
import com.cyl.classifymenu.tagListViewWithConfiguration
import com.cyl.classifymenu.tagListViewWithConfigurationFile

/**
 * A footnote caption of these screens (16 dp insets).
 */
private fun caption(context: Context, text: String) = TextView(context).apply {
    val d = context.resources.displayMetrics.density
    this.text = text
    setTextSize(TypedValue.COMPLEX_UNIT_SP, 13f)
    setTextColor(Color.argb(153, 60, 60, 67))
    setPadding((16 * d).toInt(), (8 * d).toInt(), (16 * d).toInt(), 0)
}

private fun column(context: Context, views: List<View>): View = ScrollView(context).apply {
    setBackgroundColor(Color.rgb(242, 242, 247))
    addView(LinearLayout(context).apply {
        orientation = LinearLayout.VERTICAL
        setPadding(0, (12 * context.resources.displayMetrics.density).toInt(), 0, 0)
        views.forEach { addView(it, LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT)) }
    })
}

/**
 * `CYLTagCloudDemoViewController`: android-tagview's way of making a tag cloud, twice: in code (`addTagsWithTitles`,
 * `addTag`, `addTags`, click and delete handlers) and from a dictionary (`CYLTagListViewTags`).
 */
class CYLTagCloudScreen(private val context: Context) : CYLMenuScreen {
    override val title: CharSequence = CYLExampleLocalizedString(context, "标签云（android-tagview）")
    val codeTagListView = CYLTagListView(context)
    val mapTagListView: CYLTagListView = CYLTagListView.tagListViewWithConfiguration(context, mapConfiguration())
    val eventLabel = caption(context, CYLExampleLocalizedString(context, "点击标签，或点 × 删除"))
    override val view: View

    companion object {
        val continents = listOf("Asia", "Africa", "North America", "South America", "Antarctica", "Europe", "Australia")

        fun detailedTag() = CYLTag(7, "Tag Text", "#DDDDDD").apply {
            textColor = Color.WHITE
            highlightedBackgroundColor = Color.rgb(84, 84, 84)
            cornerRadius = 20f
            textSize = 14f
            borderWidth = 1f
            borderColor = Color.WHITE
            isDeletable = true
        }

        fun styledTags(context: Context): List<CYLTag> {
            val blue = CYLTag(CYLExampleLocalizedString(context, "可删除"), "#00BFFF").apply {
                textColor = Color.WHITE
                borderWidth = 0f
                isDeletable = true
                highlightedBackgroundColor = Color.rgb(0, 128, 179)
            }
            val large = CYLTag(CYLExampleLocalizedString(context, "大字号"), Color.rgb(255, 149, 0)).apply {
                textColor = Color.WHITE
                textSize = 22f
                borderWidth = 0f
            }
            val image = CYLTag(CYLExampleLocalizedString(context, "背景图")).apply {
                backgroundImage = backgroundImage(context)
                textColor = Color.WHITE
                borderWidth = 0f
            }
            val custom = CYLTag(CYLExampleLocalizedString(context, "自定义删除"), Color.rgb(255, 45, 85)).apply {
                textColor = Color.WHITE
                borderWidth = 0f
                isDeletable = true
                deleteIndicatorTitle = "⊗"
                deleteIndicatorColor = Color.argb(204, 255, 255, 255)
                deleteIndicatorSize = 18f
            }
            return listOf(blue, large, image, custom)
        }

        /**
         * A purple-to-teal gradient, 64 × 32 (as the iOS demo draws it).
         */
        fun backgroundImage(context: Context): Drawable {
            val d = context.resources.displayMetrics.density
            val bitmap = Bitmap.createBitmap((64 * d).toInt(), (32 * d).toInt(), Bitmap.Config.ARGB_8888)
            Canvas(bitmap).drawRect(0f, 0f, bitmap.width.toFloat(), bitmap.height.toFloat(), Paint().apply {
                shader = LinearGradient(0f, 0f, bitmap.width.toFloat(), 0f, Color.rgb(175, 82, 222), Color.rgb(48, 176, 199), Shader.TileMode.CLAMP)
            })
            return BitmapDrawable(context.resources, bitmap)
        }

        fun mapConfiguration(): Map<String, Any?> {
            val blue = mapOf(CYLMenuStyleNormal to mapOf(CYLTagAppearanceBackgroundColor to "#00BFFF", CYLTagAppearanceTextColor to "#FFFFFF",
                CYLTagAppearanceBorderWidth to 0, CYLTagAppearanceCornerRadius to 0), CYLMenuStyleHighlightedBackgroundColor to "#88363636")
            return mapOf(
                CYLTagListViewStyle to mapOf(CYLMenuStyleLineSpacing to 5, CYLMenuStyleInteritemSpacing to 3, CYLMenuStyleTagContentInsets to "{3, 10, 3, 10}"),
                CYLTagListViewScrollEnabled to false,
                CYLTagListViewTags to listOf("Asia", "Europe",
                    mapOf(CYLTagItemTitle to "Africa", CYLTagItemIdentifier to 3, CYLTagItemDeletable to true, CYLTagItemStyle to blue),
                    mapOf(CYLTagItemTitle to "Australia", CYLTagItemImage to "system:globe")),
            )
        }
    }

    init {
        codeTagListView.lineSpacing = 5f
        codeTagListView.interitemSpacing = 3f
        codeTagListView.tagContentInsets = CYLEdgeInsets(3f, 10f, 3f, 10f)
        codeTagListView.isScrollEnabled = false
        codeTagListView.addTagsWithTitles(continents)
        codeTagListView.addTag(detailedTag())
        codeTagListView.addTags(styledTags(context))
        codeTagListView.tagClickHandler = { index, tag -> showEvent(CYLExampleLocalizedString(context, "点击第 %ld 个「%@」", index, tag.title)) }
        codeTagListView.tagDeleteHandler = { index, tag -> showEvent(CYLExampleLocalizedString(context, "删除第 %ld 个「%@」", index, tag.title)) }
        mapTagListView.tagDeleteHandler = { index, tag -> showEvent(CYLExampleLocalizedString(context, "删除第 %ld 个「%@」", index, tag.title)) }
        view = column(context, listOf(
            caption(context, CYLExampleLocalizedString(context, "代码初始化：addTags(withTitles:)、addTag(_:)")), codeTagListView,
            caption(context, CYLExampleLocalizedString(context, "字典初始化：CYLTagListViewTags")), mapTagListView, eventLabel))
    }

    fun showEvent(text: String) {
        eventLabel.text = text
    }
}

/**
 * `CYLTagConfigurationDemoViewController`: one tag list from the configuration file
 * (`CYLMenuExample.bundle/Configurations/animated-tags.json`) and one from a dictionary (several, animated icons).
 */
class CYLTagConfigurationScreen(private val context: Context) : CYLMenuScreen, CYLMenuDelegate {
    override val title: CharSequence = CYLExampleLocalizedString(context, "配置初始化")
    var fileTagListView: CYLTagListView? = null
        private set
    var configurationError: Exception? = null
        private set
    val mapTagListView: CYLTagListView = CYLTagListView.tagListViewWithConfiguration(context, mapConfiguration(context))
    val eventLabel = caption(context, CYLExampleLocalizedString(context, if (CYLTagButton.isAnimationEngineAvailable()) "动效引擎：CYLTabBarItemAnimationFactory 已链接" else "动效引擎未链接：显示静态图标"))
    override val view: View

    companion object {
        const val CONFIGURATION_FILE = "CYLMenuExample.bundle/Configurations/animated-tags.json"

        private fun animation(name: String) = Uri.parse("file:///android_asset/CYLMenuExample.bundle/Animations/$name")

        fun mapConfiguration(context: Context): Map<String, Any?> {
            val indigo = Color.rgb(88, 86, 214)
            val normal = mapOf(CYLTagAppearanceIconColor to indigo, CYLTagAppearanceBorderColor to indigo, CYLTagAppearanceBorderWidth to 1, CYLTagAppearanceCornerRadius to 8)
            val selected = mapOf(CYLTagAppearanceBackgroundColor to indigo, CYLTagAppearanceBorderColor to indigo, CYLTagAppearanceIconColor to Color.WHITE, CYLTagAppearanceCornerRadius to 8)
            val style = mapOf(CYLMenuStyleImageSize to CYLSize(20f, 20f), CYLMenuStyleImageTitleSpacing to 4, CYLMenuStyleItemHeight to 36,
                CYLMenuStyleLayoutCentered to true, CYLMenuStyleNormal to normal, CYLMenuStyleSelected to selected)
            val items = listOf(
                mapOf(CYLTagItemTitle to "Lottie", CYLTagItemAnimation to animation("Lottie/tab_me_animate.json")),
                mapOf(CYLTagItemTitle to "GIF", CYLTagItemAnimation to animation("GIF/cyl_tab_sample_animated.gif")),
                mapOf(CYLTagItemTitle to "Rive", CYLTagItemAnimation to animation("Rive/menu_button.riv")),
                mapOf(CYLTagItemImage to "system:heart", CYLTagItemSelectedImage to "system:heart.fill"),
                "Text only",
            )
            return mapOf(
                CYLTagListViewSelectionMode to CYLMenuSelectionMode.CYLMenuSelectionModeMultiple,
                CYLTagListViewFoldControl to CYLMenuFoldControl.foldControlWithPosition(CYLMenuFoldControlPosition.CYLMenuFoldControlPositionNone, CYLMenuFoldControlContent.CYLMenuFoldControlContentIcon),
                CYLTagListViewScrollEnabled to false,
                CYLTagListViewSelectedItems to listOf(CYLIndexPath(1, 0)),
                CYLTagListViewStyle to style,
                CYLTagListViewSections to listOf(mapOf(CYLTagSectionTitle to CYLExampleLocalizedString(context, "字典（map）初始化"), CYLTagSectionItems to items)),
            )
        }
    }

    init {
        val views = ArrayList<View>()
        views.add(caption(context, CYLExampleLocalizedString(context, "配置文件初始化：%@", CONFIGURATION_FILE)))
        try {
            val list = CYLTagListView.tagListViewWithConfigurationFile(context, CONFIGURATION_FILE)
            list.menuDelegate = this
            fileTagListView = list
            views.add(list)
        } catch (error: Exception) {
            configurationError = error
            views.add(caption(context, error.localizedMessage ?: "?"))
        }
        mapTagListView.menuDelegate = this
        views.add(caption(context, CYLExampleLocalizedString(context, "字典（map）初始化：-initWithConfiguration:")))
        views.add(mapTagListView)
        views.add(eventLabel)
        view = column(context, views)
    }

    override fun menuDidSelectItemAtIndexPath(menu: Any, indexPath: CYLIndexPath) {
        val list = menu as? CYLTagListView ?: return
        eventLabel.text = CYLExampleLocalizedString(context, "点击「%@」", list.menuDataSource?.menuTitleForItemAtIndexPath(indexPath).orEmpty())
    }
}
