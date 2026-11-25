package com.cyl.classifymenu.example.menu

import android.content.ContentValues
import android.content.Context
import android.database.sqlite.SQLiteDatabase
import android.graphics.Color
import android.graphics.Typeface
import android.util.TypedValue
import android.view.Gravity
import android.view.LayoutInflater
import android.view.View
import android.widget.Button
import android.widget.ImageButton
import android.widget.LinearLayout
import android.widget.TextView
import androidx.fragment.app.FragmentActivity
import android.graphics.drawable.Drawable
import androidx.core.content.ContextCompat
import com.cyl.classifymenu.CYLAppTintColor
import com.cyl.classifymenu.CYLControlState
import com.cyl.classifymenu.CYLEdgeInsets
import com.cyl.classifymenu.CYLFont
import com.cyl.classifymenu.CYLMenuDataSource
import com.cyl.classifymenu.CYLMenuFoldControl
import com.cyl.classifymenu.CYLMenuFoldControlContent
import com.cyl.classifymenu.CYLMenuFoldControlPosition
import com.cyl.classifymenu.CYLMenuSelectionMode
import com.cyl.classifymenu.CYLMenuStyle
import com.cyl.classifymenu.CYLSize
import com.cyl.classifymenu.CYLTagListView
import com.cyl.classifymenu.CYLTagLongPressActions
import com.cyl.classifymenu.CYLClassifyMenuViewController
import com.cyl.classifymenu.CYLFilterBaseController
import com.cyl.classifymenu.CYLFilterControllerDelegate
import com.cyl.classifymenu.CYLIndexPath
import com.cyl.classifymenu.CYLMenuDelegate
import com.cyl.classifymenu.CYLMultipleFilterController
import com.cyl.classifymenu.example.R
import com.cyl.classifymenu.example.classify.ClassifyDemoDataSource
import com.cyl.classifymenu.example.classify.ClassifyPlacesDatabase
import com.cyl.classifymenu.example.classify.ClassifyResultsView
import com.cyl.classifymenu.example.classify.ClassifySQLQuery

/**
 * The `selections` table of `CYLExampleDatabase`: the conditions each demo last confirmed, restored when it opens
 * again. The shared example database is read-only, so this table lives in a small database of the app's own
 * (`cyl_selections.sqlite`, same schema: scenario, section, item).
 */
class CYLExampleSelections private constructor(context: Context) {
    private val database: SQLiteDatabase = SQLiteDatabase.openOrCreateDatabase(context.getDatabasePath("cyl_selections.sqlite").also { it.parentFile?.mkdirs() }, null).also {
        it.execSQL("CREATE TABLE IF NOT EXISTS selections (scenario TEXT NOT NULL, section INTEGER NOT NULL, item INTEGER NOT NULL)")
    }

    companion object {
        @Volatile private var shared: CYLExampleSelections? = null

        fun shared(context: Context) = shared ?: synchronized(this) { shared ?: CYLExampleSelections(context.applicationContext).also { shared = it } }
    }

    /**
     * `-savedSelectionForScenario:`: the saved index paths, or null when nothing was saved.
     */
    fun savedSelection(scenario: String): List<CYLIndexPath>? = database.rawQuery("SELECT section, item FROM selections WHERE scenario = ? ORDER BY section, item", arrayOf(scenario)).use { cursor ->
        val paths = ArrayList<CYLIndexPath>()
        while (cursor.moveToNext()) paths.add(CYLIndexPath(cursor.getInt(1), cursor.getInt(0)))
        paths.ifEmpty { null }
    }

    /**
     * `-saveSelection:forScenario:`: replaces the scenario's rows, in one transaction.
     */
    fun saveSelection(indexPaths: List<CYLIndexPath>, scenario: String): Boolean {
        database.beginTransaction()
        return try {
            database.delete("selections", "scenario = ?", arrayOf(scenario))
            for (path in indexPaths) database.insert("selections", null, ContentValues().apply { put("scenario", scenario); put("section", path.section); put("item", path.item) })
            database.setTransactionSuccessful()
            true
        } catch (error: Exception) {
            false
        } finally {
            database.endTransaction()
        }
    }

    fun count(): Int = database.rawQuery("SELECT COUNT(*) FROM selections", null).use { if (it.moveToFirst()) it.getInt(0) else 0 }
}

/**
 * `CYLQueryScenario`.
 */
enum class CYLQueryScenario { REVIEWS_DATABASE, REVIEWS_MEMORY, REVIEWS_NETWORK, MENU_LINKAGE, SEARCH_DISCOVER }

/**
 * `CYLQueryScenariosViewController` (the iOS example's plus page): the query scenarios (the review filter in its
 * three modes, the menu linkage, search history and discover) and the database's tables with their row counts, as one
 * `CYLTagListView` (docs/instructions/examples.md "Sectioned lists in demos use the tag list"): a section per group, the
 * group's title as the header, a tag with only the title and the icon, the More / Less control on a section that needs
 * more than `defaultVisibleRows` rows. A tap opens the scenario like the old row did; the old group footer (the
 * explanation) is the tags' subtitle, shown in the callout of a long press.
 */
class CYLQueryScenariosScreen(private val context: Context, private val navigator: CYLMenuNavigator) : CYLMenuScreen, CYLMenuScreenLifecycle, CYLMenuDataSource, CYLMenuDelegate {
    override val title: CharSequence = CYLExampleLocalizedString(context, "查询筛选")
    private var tableCounts: List<Pair<String, Int>> = emptyList()

    /** The one tag list of the screen. */
    val tagList = CYLTagListView(context, CYLMenuFoldControl.foldControlWithPosition(CYLMenuFoldControlPosition.HEADER_TRAILING, CYLMenuFoldControlContent.CYLMenuFoldControlContentIcon))
    override val view: View = tagList

    companion object {
        const val DATABASE_SECTION = 3
        const val DEFAULT_VISIBLE_ROWS = 2
        private const val SECTION_COUNT = DATABASE_SECTION + 1
        private const val CELL_SEPARATOR = " · "
        private const val SCREEN_BACKGROUND_RED = 242
        private const val SCREEN_BACKGROUND_GREEN = 242
        private const val SCREEN_BACKGROUND_BLUE = 247
        private const val TAG_BACKGROUND = 0xFFFFFFFF.toInt()
        private const val TAG_TEXT_SIZE_SP = 15f
        private const val TAG_ITEM_HEIGHT_DP = 44f
        private const val TAG_ICON_SIZE_DP = 20f
        private const val TAG_ICON_TITLE_SPACING_DP = 8f
        private const val TAG_MARGIN_DP = 12f
        private const val TAG_CORNER_RADIUS_DP = 10f
        private const val TAG_SPACING_DP = 10f
        private const val SECTION_INSET_TOP_DP = 4f
        private const val SECTION_INSET_SIDE_DP = 16f
        private const val SECTION_INSET_BOTTOM_DP = 16f
        private const val HEADER_HEIGHT_DP = 44f
        private const val HEADER_TEXT_SIZE_SP = 20f
        private const val TAG_TITLE_MAX_LINES = 3
        private val HEADERS = listOf("场景：查询参数设置（多选）", "场景：菜单选择（移植原 Demo）", "场景：搜索历史与发现", "数据库（SQLite）")
        private val FOOTERS = listOf(
            "淘宝评价默认显示全部；条件太多时，由用户多选输入筛选条件，标签列表就是为此而做。每次选择后按全部条件（AND）刷新列表。",
            "原 Demo 只实现了筛选界面，没有筛选数据；现在每次选择都会生成 SQL、查询数据库并显示结果，选择也保存在数据库中。",
            "最近搜索折叠为两行，箭头是最后一个标签；发现每行两个，超出部分显示省略号，右上角的更多按钮随机刷新。数据来自本地 JSON。",
            "每次启动时由 App 内的数据重新生成，selections 表保留各演示最后确认的条件。")
        private val SCENARIO_ICONS = mapOf(CYLQueryScenario.REVIEWS_DATABASE to R.drawable.ic_query_database, CYLQueryScenario.REVIEWS_MEMORY to R.drawable.ic_query_memory,
            CYLQueryScenario.REVIEWS_NETWORK to R.drawable.ic_query_network, CYLQueryScenario.MENU_LINKAGE to R.drawable.ic_query_grid, CYLQueryScenario.SEARCH_DISCOVER to R.drawable.ic_search_magnifier)
        private val TABLE_ICONS = mapOf("reviews" to R.drawable.ic_style_message, "places" to R.drawable.ic_style_mappin, "selections" to R.drawable.ic_style_star)
    }

    init {
        tagList.style = tagStyle(monospaced = false)
        tagList.selectionMode = CYLMenuSelectionMode.CYLMenuSelectionModeNone
        tagList.defaultVisibleRows = DEFAULT_VISIBLE_ROWS
        tagList.longPressAction = CYLTagLongPressActions.callout
        tagList.menuDelegate = this
        tagList.menuDataSource = this
        reload()
    }

    private fun tagStyle(monospaced: Boolean) = CYLMenuStyle().apply {
        backgroundColor = Color.rgb(SCREEN_BACKGROUND_RED, SCREEN_BACKGROUND_GREEN, SCREEN_BACKGROUND_BLUE)
        titleMaxLines = TAG_TITLE_MAX_LINES
        itemHeight = TAG_ITEM_HEIGHT_DP
        imageSize = CYLSize(TAG_ICON_SIZE_DP, TAG_ICON_SIZE_DP)
        imageTitleSpacing = TAG_ICON_TITLE_SPACING_DP
        interitemSpacing = TAG_SPACING_DP
        lineSpacing = TAG_SPACING_DP
        sectionInsets = CYLEdgeInsets(SECTION_INSET_TOP_DP, SECTION_INSET_SIDE_DP, SECTION_INSET_BOTTOM_DP, SECTION_INSET_SIDE_DP)
        headerHeight = HEADER_HEIGHT_DP
        headerFont = CYLFont(HEADER_TEXT_SIZE_SP, Typeface.DEFAULT_BOLD)
        headerTextColor = Color.BLACK
        headerHorizontalInset = SECTION_INSET_SIDE_DP
        for (state in listOf(CYLControlState.NORMAL, CYLControlState.SELECTED, CYLControlState.DISABLED)) {
            appearanceForState(state).apply {
                backgroundColor = TAG_BACKGROUND
                cornerRadius = TAG_CORNER_RADIUS_DP
                margin = TAG_MARGIN_DP
                textColor = Color.BLACK
                font = CYLFont(TAG_TEXT_SIZE_SP, if (monospaced) Typeface.MONOSPACE else Typeface.DEFAULT)
            }
        }
    }

    fun scenarios(section: Int) = when (section) {
        0 -> listOf(CYLQueryScenario.REVIEWS_DATABASE, CYLQueryScenario.REVIEWS_MEMORY, CYLQueryScenario.REVIEWS_NETWORK)
        1 -> listOf(CYLQueryScenario.MENU_LINKAGE)
        2 -> listOf(CYLQueryScenario.SEARCH_DISCOVER)
        else -> emptyList()
    }

    fun title(scenario: CYLQueryScenario) = CYLExampleLocalizedString(context, when (scenario) {
        CYLQueryScenario.REVIEWS_DATABASE -> "评价筛选 · 数据库（SQLite）"
        CYLQueryScenario.REVIEWS_MEMORY -> "评价筛选 · 内存"
        CYLQueryScenario.REVIEWS_NETWORK -> "评价筛选 · 网络"
        CYLQueryScenario.MENU_LINKAGE -> "分类菜单 + 多选筛选 · 数据库联动"
        CYLQueryScenario.SEARCH_DISCOVER -> "最近搜索 + 发现"
    })

    /**
     * The screen of a scenario; null while it is not ported yet (search discover comes with the next part).
     */
    fun screen(scenario: CYLQueryScenario): CYLMenuScreen? = when (scenario) {
        CYLQueryScenario.REVIEWS_DATABASE -> CYLReviewListScreen(context, 0, CYLReviewFilteringMode.DATABASE)
        CYLQueryScenario.REVIEWS_MEMORY -> CYLReviewListScreen(context, 0, CYLReviewFilteringMode.MEMORY)
        CYLQueryScenario.REVIEWS_NETWORK -> CYLReviewListScreen(context, 0, CYLReviewFilteringMode.NETWORK)
        CYLQueryScenario.MENU_LINKAGE -> CYLMenuLinkageScreen(context)
        CYLQueryScenario.SEARCH_DISCOVER -> CYLSearchDiscoverScreen(context, navigator)
    }

    fun open(scenario: CYLQueryScenario) = screen(scenario)?.also { navigator.push(it) }

    /**
     * `-viewWillAppear:` reloads the list (the selections count changes after the linkage demo).
     */
    override fun screenDidAppear(navigator: CYLMenuNavigator) = reload()

    private fun reload() {
        val database = ClassifyPlacesDatabase(context)
        val counts = listOf("reviews", "places").map { it to database.countOfTable(it) }
        database.close()
        tableCounts = counts + ("selections" to CYLExampleSelections.shared(context).count())
        tagList.reloadMenuData()
    }

    // MARK: CYLMenuDataSource

    private fun icon(resource: Int?): Drawable? = resource?.let { ContextCompat.getDrawable(context, it)?.mutate()?.also { drawable -> drawable.setTint(CYLAppTintColor) } }

    override fun numberOfSectionsInMenu() = SECTION_COUNT

    override fun menuNumberOfItemsInSection(section: Int) = if (section == DATABASE_SECTION) tableCounts.size else scenarios(section).size

    override fun menuTitleForSection(section: Int) = CYLExampleLocalizedString(context, HEADERS[section])

    override fun menuTitleForItemAtIndexPath(indexPath: CYLIndexPath) = if (indexPath.section == DATABASE_SECTION) {
        tableCounts[indexPath.item].let { (table, count) -> table + CELL_SEPARATOR + CYLExampleLocalizedString(context, "%ld 行", count) }
    } else title(scenarios(indexPath.section)[indexPath.item])

    override fun menuSubtitleForItemAtIndexPath(indexPath: CYLIndexPath): String? = CYLExampleLocalizedString(context, FOOTERS[indexPath.section])

    override fun menuImageForItemAtIndexPath(indexPath: CYLIndexPath) = icon(if (indexPath.section == DATABASE_SECTION) TABLE_ICONS[tableCounts[indexPath.item].first] else SCENARIO_ICONS[scenarios(indexPath.section)[indexPath.item]])

    /** The database tables were monospaced rows. */
    override fun menuStyleForSection(section: Int): CYLMenuStyle? = if (section == DATABASE_SECTION) tagStyle(monospaced = true) else null

    // MARK: CYLMenuDelegate

    override fun menuDidSelectItemAtIndexPath(menu: Any, indexPath: CYLIndexPath) {
        if (indexPath.section != DATABASE_SECTION) open(scenarios(indexPath.section)[indexPath.item])
    }
}

/**
 * `CYLMenuLinkageViewController`: the original demo's classify menu (single choice) and multiple-choice filter
 * (regions and dishes, from the top-left button) on one screen; every choice builds the SQL, queries the shared
 * database and shows the places below. Both selections are saved (`selections`) and restored next time.
 */
class CYLMenuLinkageScreen(private val context: Context) : CYLMenuScreen, CYLMenuScreenLifecycle {
    override val title: CharSequence = CYLExampleLocalizedString(context, "菜单选择 · 数据库联动")
    val classifySource = ClassifyDemoDataSource.classifyDataSource(context)
    val filterSource = ClassifyDemoDataSource.filterDataSource(context)
    var selectedTag: String? = null
        private set
    var selectedRegions: List<String> = emptyList()
        private set
    var selectedDishes: List<String> = emptyList()
        private set
    var lastQuery: ClassifySQLQuery = ClassifyPlacesDatabase.query(null, emptyList(), emptyList())
        private set
    var results: List<Map<String, Any>> = emptyList()
        private set
    private val database = ClassifyPlacesDatabase(context)
    private val selections = CYLExampleSelections.shared(context)
    private val resultsView = ClassifyResultsView(context)
    private val d = context.resources.displayMetrics.density
    private val filterButton = ImageButton(context).apply { background = null }
    val menu = LinkageMenu()
    override val view: View

    companion object {
        const val CLASSIFY_SCENARIO = "menu.classify"
        const val FILTER_SCENARIO = "menu.filter"
    }

    /**
     * The classify menu of the screen: `CYLClassifyMenuViewController` builds the view (its header, sections and
     * footer); taps come back here.
     */
    inner class LinkageMenu : CYLClassifyMenuViewController(), CYLMenuDelegate {
        fun relayout() = updateMenuLayout()
        override fun menuDidSelectItemAtIndexPath(menu: Any, indexPath: CYLIndexPath) = selectClassifyItem(indexPath)
    }

    val filterController: CYLMultipleFilterController by lazy {
        CYLMultipleFilterController().also { controller ->
            controller.delegate = object : CYLFilterControllerDelegate {
                override fun filterControllerDidComplete(controller: CYLFilterBaseController) = updateFilterButton()
            }
            controller.menuDataSource = filterSource
            controller.menuDelegate = object : CYLMenuDelegate {
                override fun menuDidConfirmSelectedItems(menu: Any, indexPaths: List<CYLIndexPath>) = applyFilterSelection(indexPaths, true)
            }
            controller.reloadMenuData()
        }
    }

    init {
        menu.menuDataSource = classifySource
        menu.menuDelegate = menu
        menu.defaultVisibleRows = 2
        menu.menuHeaderView = TextView(context).apply {
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 12f)
            setTextColor(Color.argb(153, 60, 60, 67))
            setBackgroundColor(Color.WHITE)
            setPadding((16 * d).toInt(), (8 * d).toInt(), (16 * d).toInt(), (8 * d).toInt())
            text = CYLExampleLocalizedString(context, "点按分类标签（单选），左上角按钮多选地区与菜品") + "\n" + CYLExampleLocalizedString(context, "每次选择 → 生成 SQL → SQLite 查询 → 刷新下方结果")
        }
        menu.menuFooterView = resultsView
        view = menu.onCreateView(LayoutInflater.from(context), null, null)
        filterButton.contentDescription = CYLExampleLocalizedString(context, "多选筛选")
        filterButton.setOnClickListener { showFilter() }
        restoreSavedSelection()
    }

    override fun screenDidAppear(navigator: CYLMenuNavigator) {
        val reset = Button(context).apply {
            text = CYLExampleLocalizedString(context, "重置")
            isAllCaps = false
            background = null
            stateListAnimator = null
            minWidth = 0
            minimumWidth = 0
            setTextColor(Color.WHITE)
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 16f)
            setOnClickListener { resetConditions() }
        }
        (filterButton.parent as? android.view.ViewGroup)?.removeView(filterButton)
        navigator.setTrailing(LinearLayout(context).apply {
            gravity = Gravity.CENTER_VERTICAL
            addView(filterButton, LinearLayout.LayoutParams((44 * d).toInt(), (44 * d).toInt()))
            addView(reset)
        })
    }

    private fun updateFilterButton() {
        val modified = selectedRegions.isNotEmpty() || selectedDishes.isNotEmpty()
        filterButton.setImageResource(if (modified) R.drawable.classify_filter_modified else R.drawable.classify_filter_normal)
        androidx.core.view.ViewCompat.setStateDescription(filterButton, if (modified) CYLExampleLocalizedString(context, "已修改") else null)
    }

    fun showFilter() {
        filterController.refreshFilterParams()
        filterController.showInView((context as FragmentActivity).findViewById(android.R.id.content))
    }

    fun confirmFilterSelection(indexPaths: List<CYLIndexPath>) {
        filterController.setSelectedIndexPaths(indexPaths)
        applyFilterSelection(filterController.selectedIndexPaths(), true)
    }

    private fun applyFilterSelection(indexPaths: List<CYLIndexPath>, save: Boolean) {
        val regions = ArrayList<String>()
        val dishes = ArrayList<String>()
        for (indexPath in indexPaths) {
            if (filterSource.menuItemIsExclusiveAtIndexPath(indexPath)) continue
            val title = filterSource.menuTitleForItemAtIndexPath(indexPath)
            if (indexPath.section == 0) regions.add(title) else dishes.add(title)
        }
        selectedRegions = regions
        selectedDishes = dishes
        if (save) selections.saveSelection(indexPaths, FILTER_SCENARIO)
        runQuery()
    }

    fun selectClassifyItem(indexPath: CYLIndexPath) {
        val deselect = menu.selectedIndexPath == indexPath
        menu.selectedIndexPath = if (deselect) null else indexPath
        selectedTag = if (deselect) null else classifySource.menuTitleForItemAtIndexPath(indexPath)
        selections.saveSelection(menu.selectedIndexPath?.let { listOf(it) } ?: emptyList(), CLASSIFY_SCENARIO)
        runQuery()
    }

    fun resetConditions() {
        menu.selectedIndexPath = null
        selectedTag = null
        selections.saveSelection(emptyList(), CLASSIFY_SCENARIO)
        confirmFilterSelection((0 until filterSource.numberOfSectionsInMenu()).map { CYLIndexPath(0, it) })
    }

    private fun contains(indexPath: CYLIndexPath, source: ClassifyDemoDataSource) =
        indexPath.section < source.numberOfSectionsInMenu() && indexPath.item < source.menuNumberOfItemsInSection(indexPath.section)

    private fun isValidFilterSelection(indexPaths: List<CYLIndexPath>): Boolean {
        val exclusiveSections = HashSet<Int>()
        val otherSections = HashSet<Int>()
        for (indexPath in indexPaths) {
            val exclusive = filterSource.menuItemIsExclusiveAtIndexPath(indexPath)
            if (if (exclusive) indexPath.section in exclusiveSections || indexPath.section in otherSections else indexPath.section in exclusiveSections) return false
            (if (exclusive) exclusiveSections else otherSections).add(indexPath.section)
        }
        return true
    }

    private fun restoreSavedSelection() {
        selections.savedSelection(CLASSIFY_SCENARIO)?.firstOrNull()?.takeIf { contains(it, classifySource) }?.let {
            menu.selectedIndexPath = it
            selectedTag = classifySource.menuTitleForItemAtIndexPath(it)
        }
        val filter = selections.savedSelection(FILTER_SCENARIO).orEmpty().filter { contains(it, filterSource) }
        if (filter.isNotEmpty()) {
            if (isValidFilterSelection(filter)) filterController.setSelectedIndexPaths(filter)
            else { android.util.Log.w("CYLMenuExample", "Ignoring the saved filter selection: $filter"); filterController.reloadMenuData() }
        }
        applyFilterSelection(filterController.selectedIndexPaths(), false)
    }

    private fun runQuery() {
        val query = ClassifyPlacesDatabase.query(selectedTag, selectedRegions, selectedDishes)
        lastQuery = query
        results = try { database.rows(query) } catch (error: Exception) { emptyList() }
        resultsView.show(selectedTag, selectedRegions, selectedDishes, query, results, database.countOfTable("places"))
        updateFilterButton()
        menu.relayout()
    }
}
