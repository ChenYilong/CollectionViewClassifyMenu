package com.cyl.classifymenu.example.classify

import android.content.Context
import android.graphics.drawable.Drawable
import com.cyl.classifymenu.CYLIndexPath
import com.cyl.classifymenu.CYLMenuDataSource
import com.cyl.classifymenu.CYLMenuResources
import com.cyl.classifymenu.kDataSourceCellPictureKey
import com.cyl.classifymenu.kDataSourceCellTextKey
import com.cyl.classifymenu.kDataSourceSectionKey
import org.json.JSONArray

/**
 * `CYLDBManager`: the demo data (`classify_data.json`, the iOS demo's data.json) and every item title in it.
 */
object ClassifyDemoDatabase {
    private var cache: List<Map<String, Any?>>? = null

    /**
     * `+dataSource`: the sections of the data file ("Type", "Items" of { "Item_Title", "Picture"? }).
     */
    fun dataSource(context: Context): List<Map<String, Any?>> = cache ?: run {
        val raw = context.assets.open("classify_data.json").use { it.readBytes().toString(Charsets.UTF_8) }
        // The iOS data.json has trailing commas before "}" and "]" (NSJSONSerialization accepts them, org.json does
        // not); drop them before parsing.
        val array = JSONArray(raw.replace(Regex(",\\s*([}\\]])"), "$1"))
        (0 until array.length()).map { index ->
            val section = array.getJSONObject(index)
            val items = section.getJSONArray(kDataSourceSectionKey)
            mapOf(
                ClassifyDemoDataSource.SECTION_TITLE_KEY to section.optString(ClassifyDemoDataSource.SECTION_TITLE_KEY),
                kDataSourceSectionKey to (0 until items.length()).map { i ->
                    val item = items.getJSONObject(i)
                    buildMap<String, Any?> {
                        put(kDataSourceCellTextKey, item.optString(kDataSourceCellTextKey))
                        if (item.has(kDataSourceCellPictureKey)) put(kDataSourceCellPictureKey, item.optString(kDataSourceCellPictureKey))
                    }
                },
            )
        }.also { cache = it }
    }

    /**
     * `+allTags`: every item title, in order.
     */
    fun allTags(context: Context): List<String> = dataSource(context).flatMap { section ->
        @Suppress("UNCHECKED_CAST")
        (section[kDataSourceSectionKey] as List<Map<String, Any?>>).map { it[kDataSourceCellTextKey] as String }
    }
}

/**
 * `CYLDemoDataSource`: the classify menu's sections (from the data file) or the filter's (regions and foods, each
 * starting with an exclusive "全部").
 */
class ClassifyDemoDataSource private constructor(
    val sections: List<Map<String, Any?>>,
    val hasExclusiveFirstItem: Boolean,
) : CYLMenuDataSource {

    companion object {
        const val SECTION_TITLE_KEY = "Type"

        /**
         * `+classifyDataSource`.
         */
        fun classifyDataSource(context: Context) = ClassifyDemoDataSource(ClassifyDemoDatabase.dataSource(context), false)

        /**
         * `+filterDataSource`: "地区过滤" and "菜品过滤", each led by the exclusive "全部" (sample data).
         */
        fun filterDataSource(context: Context): ClassifyDemoDataSource {
            val all = mapOf<String, Any?>(kDataSourceCellTextKey to "全部")
            val foods = listOf(all) + ClassifyDemoDatabase.allTags(context).map { mapOf<String, Any?>(kDataSourceCellTextKey to it) }
            val regions = listOf(all) + regions().map { mapOf<String, Any?>(kDataSourceCellTextKey to it) }
            return ClassifyDemoDataSource(listOf(
                mapOf(SECTION_TITLE_KEY to "地区过滤", kDataSourceSectionKey to regions),
                mapOf(SECTION_TITLE_KEY to "菜品过滤", kDataSourceSectionKey to foods),
            ), true)
        }

        /**
         * `+regions`.
         */
        fun regions() = listOf("北京 🏙️ 扩展文字", "上海", "广州", "深圳")

        /**
         * `+shortTitleForTitle:`: the title without the demo's long suffix.
         */
        fun shortTitle(title: String): String {
            for (suffix in listOf(" 扩展文字😀✨", " 🏙️ 扩展文字")) if (title.endsWith(suffix)) return title.dropLast(suffix.length)
            return title
        }
    }

    @Suppress("UNCHECKED_CAST")
    private fun items(section: Int): List<Map<String, Any?>> = sections[section][kDataSourceSectionKey] as? List<Map<String, Any?>> ?: emptyList()

    override fun numberOfSectionsInMenu() = sections.size
    override fun menuNumberOfItemsInSection(section: Int) = items(section).size
    override fun menuTitleForSection(section: Int) = sections[section][SECTION_TITLE_KEY] as? String ?: ""
    override fun menuTitleForItemAtIndexPath(indexPath: CYLIndexPath) = items(indexPath.section)[indexPath.item][kDataSourceCellTextKey] as? String ?: ""

    override fun menuImageForItemAtIndexPath(indexPath: CYLIndexPath): Drawable? =
        if (items(indexPath.section)[indexPath.item].containsKey(kDataSourceCellPictureKey)) CYLMenuResources.imageNamed("home_btn_shrink") else null

    override fun menuImageForSection(section: Int): Drawable? = if (hasExclusiveFirstItem) null else CYLMenuResources.imageNamed("home_btn_cosmetic")

    override fun menuItemIsExclusiveAtIndexPath(indexPath: CYLIndexPath) = hasExclusiveFirstItem && indexPath.item == 0
}
