package com.cyl.classifymenu.example

import android.content.Context
import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat
import com.cyl.classifymenu.example.classify.ClassifyMainFragment
import com.cyl.classifymenu.example.classify.FilterDemoFragment
import com.cyl.classifymenu.example.kaede.KaedeTagViewFragment
import com.cyl.classifymenu.example.licrafter.LicrafterTagEditFragment
import com.cyl.classifymenu.example.licrafter.LicrafterTagGroupFragment
import com.cyl.classifymenu.example.lujun.LujunTagContainerFragment
import com.cyl.tabbar.CYLTabBarConfiguration
import com.cyl.tabbar.CYLTabBarController
import com.cyl.tabbar.CYLTabBarPageRegistry

/**
 * The example: a CYLTabBarController built from the configuration file `cyl_merged_tabbar.json` (assets), one tab per
 * example, the pages registered by page ID, and a raised plus button (its top above the tab bar) whose page (`plus`)
 * is the TagViewGroup editor. The iOS demo app's two features have a tab each: Classify (the single-choice classify
 * menu) and Filter (the multiple-choice filter), both linked to the local SQLite data.
 */
class MainActivity : AppCompatActivity() {

    var tabBarController: CYLTabBarController? = null
        private set

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        registerPages()
        val controller = CYLTabBarController.tabBarControllerWithConfigurationFile(this, CONFIGURATION_FILE)
        tabBarController = controller
        setContentView(controller.view)
    }

    companion object {
        const val CONFIGURATION_FILE = "cyl_merged_tabbar.json"
        private var registered = false

        /** The "system:…" image names of the configuration file -> drawables. */
        private val icons = mapOf(
            "tag" to R.drawable.ic_tab_tag,
            "square.grid.2x2" to R.drawable.ic_tab_grid,
            "photo" to R.drawable.ic_tab_photo,
            "info.circle" to R.drawable.ic_tab_info,
            "list.bullet.rectangle" to R.drawable.ic_tab_classify,
            "line.3.horizontal.decrease.circle" to R.drawable.ic_tab_filter,
            "plus.circle.fill" to R.drawable.ic_plus_raised,
        )

        @Synchronized
        fun registerPages() {
            if (registered) return
            registered = true
            CYLTabBarConfiguration.imageResolver = CYLTabBarConfiguration.CYLTabBarImageResolver { context: Context, name: String ->
                val symbol = name.removePrefix("system:")
                icons[symbol]?.let { ContextCompat.getDrawable(context, it) }
            }
            val pages = CYLTabBarPageRegistry.sharedRegistry
            pages.registerPageProvider({ _, _ -> KaedeTagViewFragment() }, "kaede")
            pages.registerPageProvider({ _, _ -> LujunTagContainerFragment() }, "lujun")
            pages.registerPageProvider({ _, _ -> LicrafterTagGroupFragment() }, "licrafter")
            pages.registerPageProvider({ _, _ -> AboutFragment() }, "about")
            pages.registerPageProvider({ _, _ -> ClassifyMainFragment() }, "classify")
            pages.registerPageProvider({ _, _ -> FilterDemoFragment() }, "filter")
            pages.registerPageProvider({ _, _ -> LicrafterTagEditFragment() }, "plus")
        }
    }
}
