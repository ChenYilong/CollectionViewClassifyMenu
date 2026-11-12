package com.cyl.classifymenu.example.classify

import android.content.Context
import android.graphics.Color
import android.os.Bundle
import android.util.TypedValue
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import android.widget.ImageButton
import android.widget.LinearLayout
import android.widget.ScrollView
import android.widget.TextView
import androidx.core.view.ViewCompat
import androidx.fragment.app.Fragment
import com.cyl.classifymenu.CYLFilterBaseController
import com.cyl.classifymenu.CYLFilterControllerDelegate
import com.cyl.classifymenu.CYLIndexPath
import com.cyl.classifymenu.CYLMenuDataSource
import com.cyl.classifymenu.CYLMenuDelegate
import com.cyl.classifymenu.CYLMultipleFilterController
import com.cyl.classifymenu.example.R
import org.json.JSONArray

/**
 * `CYLMainViewController`, its multiple-choice part (the Filter tab): the button at the leading edge of the bar opens
 * `CYLMultipleFilterController`, which slides in from the left over most of the screen (regions and dishes, "全部"
 * exclusive, Reset / Apply); its icon shows whether a filter is set; "Reset filters" clears it; the selection is kept
 * between launches; and, as the iOS example's menu linkage, the regions and dishes query the local SQLite `places`
 * table, with the results on the page.
 */
class FilterDemoFragment : Fragment(), CYLMenuDelegate, CYLFilterControllerDelegate {

    companion object {
        /**
         * The key of the stored filter selection ([[section, item], …]).
         */
        const val FILTER_SELECTION_KEY = "CYLDemoFilterSelection"
    }

    var filterSource: CYLMenuDataSource? = null
    var database: ClassifyPlacesDatabase? = null
        private set
    var selectedRegions: List<String> = emptyList()
        private set
    var selectedDishes: List<String> = emptyList()
        private set
    var lastQuery: ClassifySQLQuery = ClassifyPlacesDatabase.query(null, emptyList(), emptyList())
        private set
    var results: List<Map<String, Any>> = emptyList()
        private set
    var resultsView: ClassifyResultsView? = null
        private set
    private var filterButton: ImageButton? = null
    private var storedFilterController: CYLMultipleFilterController? = null

    private val preferences get() = requireContext().getSharedPreferences("classify_demo", Context.MODE_PRIVATE)

    /**
     * The multiple-choice filter, made once, with the stored selection restored.
     */
    val filterController: CYLMultipleFilterController
        get() = storedFilterController ?: CYLMultipleFilterController().also { controller ->
            controller.delegate = this
            controller.menuDataSource = filterSource
            controller.menuDelegate = this
            controller.reloadMenuData()
            storedFilterController = controller
            preferences.getString(FILTER_SELECTION_KEY, null)?.let { stored ->
                val paths = validatedSelection(stored)
                if (paths != null) controller.setSelectedIndexPaths(paths)
                else android.util.Log.w("ClassifyDemo", "Cannot restore demo filter settings: invalid selection.")
            }
        }

    /**
     * `-validatedSelection:`: the stored pairs as index paths, or null when one is out of range or an exclusive item
     * shares its section with another selected item.
     */
    fun validatedSelection(stored: String): List<CYLIndexPath>? {
        val source = filterSource ?: return null
        val array = try { JSONArray(stored) } catch (e: Exception) { return null }
        val paths = ArrayList<CYLIndexPath>()
        val exclusiveSections = HashSet<Int>()
        val otherSections = HashSet<Int>()
        for (index in 0 until array.length()) {
            val pair = array.optJSONArray(index) ?: return null
            if (pair.length() != 2) return null
            val section = pair.optInt(0, -1)
            val item = pair.optInt(1, -1)
            if (section < 0 || item < 0 || section >= source.numberOfSectionsInMenu() || item >= source.menuNumberOfItemsInSection(section)) return null
            val path = CYLIndexPath(item, section)
            val exclusive = source.menuItemIsExclusiveAtIndexPath(path)
            if ((exclusive && (section in exclusiveSections || section in otherSections)) || (!exclusive && section in exclusiveSections)) return null
            (if (exclusive) exclusiveSections else otherSections).add(section)
            paths.add(path)
        }
        return paths
    }

    private fun dp(context: Context, value: Float) = (value * context.resources.displayMetrics.density).toInt()

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View {
        val context = inflater.context
        if (filterSource == null) filterSource = ClassifyDemoDataSource.filterDataSource(context)
        database = ClassifyPlacesDatabase(context)
        val filter = ImageButton(context).apply {
            background = null
            contentDescription = CYLDemoLocalizedString(context, R.string.classify_filter)
            setOnClickListener { leftBarButtonClicked() }
        }
        filterButton = filter
        val reset = Button(context).apply {
            text = CYLDemoLocalizedString(context, R.string.classify_reset_filters)
            isAllCaps = false
            background = null
            setTextColor(Color.WHITE)
            setOnClickListener { rightBarButtonClicked() }
            ViewCompat.setAccessibilityDelegate(this, object : androidx.core.view.AccessibilityDelegateCompat() {
                override fun onInitializeAccessibilityNodeInfo(host: View, info: androidx.core.view.accessibility.AccessibilityNodeInfoCompat) {
                    super.onInitializeAccessibilityNodeInfo(host, info)
                    info.hintText = CYLDemoLocalizedString(context, R.string.classify_reset_filters_hint)
                }
            })
        }
        val title = TextView(context).apply { setText(R.string.filter_title) }
        val hint = TextView(context).apply {
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 12f)
            setTextColor(Color.argb(153, 60, 60, 67))
            setText(R.string.filter_hint)
            setBackgroundColor(Color.WHITE)
            setPadding(dp(context, 16f), dp(context, 12f), dp(context, 16f), dp(context, 12f))
        }
        val results = ClassifyResultsView(context)
        resultsView = results
        val page = LinearLayout(context).apply {
            orientation = LinearLayout.VERTICAL
            addView(hint)
            addView(results)
        }
        val column = LinearLayout(context).apply { orientation = LinearLayout.VERTICAL }
        column.addView(classifyNavigationBar(context, filter, title, reset), LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, dp(context, 48f)))
        column.addView(ScrollView(context).apply { addView(page) }, LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, 0, 1f))
        applyFilterSelection(filterController.selectedIndexPaths())
        return column
    }

    override fun onDestroyView() {
        database?.close()
        super.onDestroyView()
    }

    /**
     * `-initLeftBarButtonItem`: the filter icon, "modified" once an item other than "全部" is selected.
     */
    fun initLeftBarButtonItem() {
        val modified = filterController.selectedIndexPaths().any { it.item != 0 }
        filterButton?.setImageResource(if (modified) R.drawable.classify_filter_modified else R.drawable.classify_filter_normal)
        filterButton?.tag = if (modified) "modified" else "normal"
    }

    /**
     * `-leftBarButtonClicked:`: the filter slides in from the left, over the whole screen.
     */
    fun leftBarButtonClicked() {
        val filter = filterController
        filter.refreshFilterParams()
        filter.showInView(requireActivity().findViewById(android.R.id.content))
    }

    /**
     * `-rightBarButtonClicked:`: resets the filter, stores it and queries again.
     */
    fun rightBarButtonClicked() {
        val filter = filterController
        filter.reloadMenuData()
        menuDidConfirmSelectedItems(filter, filter.selectedIndexPaths())
    }

    /**
     * Regions and dishes from the filter's selection (section 0 and 1, without the exclusive "全部"), then the query.
     */
    private fun applyFilterSelection(indexPaths: List<CYLIndexPath>) {
        val source = filterSource ?: return
        val regions = ArrayList<String>()
        val dishes = ArrayList<String>()
        for (indexPath in indexPaths) {
            if (source.menuItemIsExclusiveAtIndexPath(indexPath)) continue
            val title = source.menuTitleForItemAtIndexPath(indexPath)
            if (indexPath.section == 0) regions.add(title) else dishes.add(title)
        }
        selectedRegions = regions
        selectedDishes = dishes
        val database = database ?: return
        val query = ClassifyPlacesDatabase.query(null, regions, dishes)
        lastQuery = query
        results = try { database.rows(query) } catch (e: Exception) { emptyList() }
        resultsView?.show(null, regions, dishes, query, results, database.countOfTable("places"))
        initLeftBarButtonItem()
    }

    override fun filterControllerDidComplete(controller: CYLFilterBaseController) = initLeftBarButtonItem()

    override fun menuDidConfirmSelectedItems(menu: Any, indexPaths: List<CYLIndexPath>) {
        val stored = JSONArray(indexPaths.map { JSONArray(listOf(it.section, it.item)) })
        preferences.edit().putString(FILTER_SELECTION_KEY, stored.toString()).apply()
        applyFilterSelection(indexPaths)
    }
}
