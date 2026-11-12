package com.cyl.classifymenu.example.tagcollection

import android.os.Bundle
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.LinearLayout
import android.widget.TextView
import androidx.fragment.app.Fragment
import com.cyl.classifymenu.CYLIndexPath
import com.cyl.classifymenu.CYLMenuDataSource
import com.cyl.classifymenu.CYLMenuDelegate
import com.cyl.classifymenu.CYLTagView
import com.cyl.classifymenu.example.R
import com.cyl.classifymenu.example.classify.classifyNavigationBar

/**
 * `CYLTagDemoViewController` of the TagCollectionView demo (`TagCollectionView/TagCollectionView`) on Android: a
 * `CYLTagView` with two sections of the demo's sample tags; each section shows its first row until its More button
 * opens it; a tap logs the tag's title (and shows it in the bar).
 */
class TagCollectionDemoFragment : Fragment(), CYLMenuDataSource, CYLMenuDelegate {

    // Sample data of the iOS demo, kept as data.
    val sections: List<List<String>> = listOf(
        listOf("约炮", "吃饭", "睡觉", "哈", "对对对", "睡觉asdfsfasfds", "asdfdsfdsf睡觉", "睡sdfdsf觉"),
        listOf("吃饭", "睡觉", "对对对", "睡觉asdfsfasfds", "asdfdsfdsf睡觉", "睡sdfdsf觉", "约炮", "打豆豆", "练武功"),
    )
    val sectionTitles = listOf("dddd打游戏了", "打游戏了")

    var tagView: CYLTagView? = null
        private set
    private var title: TextView? = null

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View {
        val context = inflater.context
        val title = TextView(context).apply { setText(R.string.tagcollection_title) }
        this.title = title
        val tagView = CYLTagView.tagView(context)
        this.tagView = tagView
        tagView.menuDataSource = this
        tagView.menuDelegate = this
        tagView.reloadMenuData()
        return LinearLayout(context).apply {
            orientation = LinearLayout.VERTICAL
            setBackgroundColor(android.graphics.Color.WHITE)
            val d = context.resources.displayMetrics.density
            addView(classifyNavigationBar(context, null, title, null), LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, (48 * d).toInt()))
            addView(tagView, LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, 0, 1f))
        }
    }

    override fun numberOfSectionsInMenu() = sections.size
    override fun menuNumberOfItemsInSection(section: Int) = sections[section].size
    override fun menuTitleForSection(section: Int) = sectionTitles[section]
    override fun menuTitleForItemAtIndexPath(indexPath: CYLIndexPath) = sections[indexPath.section][indexPath.item] + " 扩展文字😀✨"

    override fun menuDidSelectItemAtIndexPath(menu: Any, indexPath: CYLIndexPath) {
        val text = menuTitleForItemAtIndexPath(indexPath)
        Log.i("CYLTagDemo", text)
        title?.text = text
    }
}
