package com.cyl.classifymenu.example.menu

import android.content.Context
import android.graphics.Color
import android.graphics.drawable.GradientDrawable
import android.os.Bundle
import android.text.InputType
import android.util.TypedValue
import android.view.Gravity
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.view.inputmethod.EditorInfo
import android.view.inputmethod.InputMethodManager
import android.widget.Button
import android.widget.EditText
import android.widget.FrameLayout
import android.widget.LinearLayout
import android.widget.PopupMenu
import android.widget.ScrollView
import android.widget.TextView
import androidx.core.content.ContextCompat
import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentActivity
import com.cyl.classifymenu.CYLControlState
import com.cyl.classifymenu.CYLEdgeInsets
import com.cyl.classifymenu.CYLFont
import com.cyl.classifymenu.CYLIndexPath
import com.cyl.classifymenu.CYLMenuDelegate
import com.cyl.classifymenu.CYLMenuSelectionMode
import com.cyl.classifymenu.CYLMenuStyle
import com.cyl.classifymenu.CYLTagListView
import com.cyl.classifymenu.example.R
import com.cyl.tabbar.CYLConstants
import com.cyl.tabbar.CYLTabBarController
import com.cyl.tabbar.CYLTabBarControllerDelegate
import com.cyl.tabbar.CYLViewController

/**
 * `CYLSearchCategory`.
 */
enum class CYLSearchCategory { PEOPLE, FEEDS, GOSSIP, JOBS }

/**
 * A page of a tab bar that shows a view made by its owner (`CYLSearchCategoryPageViewController`).
 */
class CYLViewHostFragment : Fragment() {
    var content: View? = null

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View =
        content?.also { (it.parent as? ViewGroup)?.removeView(it) } ?: FrameLayout(inflater.context)
}

/**
 * A search field for the bar (`CYLSearchBarView`): a rounded field with a magnifier, its placeholder and text.
 */
class CYLExampleSearchField(context: Context) : FrameLayout(context) {
    private val d = context.resources.displayMetrics.density
    val textField = EditText(context).apply {
        setSingleLine()
        inputType = InputType.TYPE_CLASS_TEXT
        imeOptions = EditorInfo.IME_ACTION_SEARCH
        setTextSize(TypedValue.COMPLEX_UNIT_SP, 15f)
        background = GradientDrawable().apply { setColor(Color.WHITE); cornerRadius = 10 * d }
        setPadding((10 * d).toInt(), 0, (10 * d).toInt(), 0)
        compoundDrawablePadding = (6 * d).toInt()
        val icon = ContextCompat.getDrawable(context, R.drawable.ic_search_magnifier)!!.mutate()
        icon.setBounds(0, 0, (18 * d).toInt(), (18 * d).toInt())
        icon.setTint(Color.GRAY)
        setCompoundDrawablesRelative(icon, null, null, null)
        setOnEditorActionListener { view, action, _ ->
            if (action == EditorInfo.IME_ACTION_SEARCH) {
                (context.getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager).hideSoftInputFromWindow(view.windowToken, 0)
                view.clearFocus()
                true
            } else false
        }
    }

    init {
        addView(textField, LayoutParams(LayoutParams.MATCH_PARENT, (36 * d).toInt(), Gravity.CENTER_VERTICAL))
    }

    var placeholder: CharSequence?
        get() = textField.hint
        set(value) { textField.hint = value }

    var text: String
        get() = textField.text.toString()
        set(value) { textField.setText(value); textField.setSelection(value.length) }
}

/**
 * `CYLSearchHomeViewController`: a search button that opens the category search.
 */
class CYLSearchHomeScreen(private val context: Context, private val navigator: CYLMenuNavigator) : CYLMenuScreen {
    override val title: CharSequence = CYLExampleLocalizedString(context, "脉脉搜索")
    val searchButton: Button
    override val view: View

    init {
        val d = context.resources.displayMetrics.density
        searchButton = Button(context).apply {
            text = CYLExampleLocalizedString(context, "搜人名,职位,公司...")
            isAllCaps = false
            stateListAnimator = null
            gravity = Gravity.CENTER_VERTICAL or Gravity.START
            setTextColor(Color.argb(153, 60, 60, 67))
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 16f)
            background = GradientDrawable().apply { setColor(Color.rgb(229, 229, 234)); cornerRadius = 100 * d }
            setPadding((16 * d).toInt(), (12 * d).toInt(), (16 * d).toInt(), (12 * d).toInt())
            compoundDrawablePadding = (8 * d).toInt()
            val icon = ContextCompat.getDrawable(context, R.drawable.ic_search_magnifier)!!.mutate()
            icon.setBounds(0, 0, (18 * d).toInt(), (18 * d).toInt())
            icon.setTint(Color.argb(153, 60, 60, 67))
            setCompoundDrawablesRelative(icon, null, null, null)
            setOnClickListener { openSearch() }
        }
        val hint = TextView(context).apply {
            text = CYLExampleLocalizedString(context, "按分类浏览热门标签：找人、动态、八卦、职位")
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 13f)
            setTextColor(Color.argb(153, 60, 60, 67))
        }
        view = ScrollView(context).apply {
            setBackgroundColor(Color.rgb(242, 242, 247))
            addView(LinearLayout(context).apply {
                orientation = LinearLayout.VERTICAL
                setPadding((16 * d).toInt(), (16 * d).toInt(), (16 * d).toInt(), 0)
                addView(searchButton)
                addView(hint, LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT).apply { topMargin = (12 * d).toInt() })
            })
        }
    }

    fun openSearch(): CYLSearchCategoryScreen = CYLSearchCategoryScreen(context).also { navigator.push(it) }
}

/**
 * `CYLSearchCategoryViewController`: a search bar in the navigation bar, and a tab bar at the bottom with a page of
 * hot tags per category (people, feeds, gossip, jobs); jobs has a sidebar of job categories and an industry menu.
 * Tapping a tag puts it in the search bar.
 */
class CYLSearchCategoryScreen(private val context: Context) : CYLMenuScreen, CYLMenuDelegate, CYLTabBarControllerDelegate {
    override val title: CharSequence = ""
    val searchBar = CYLExampleSearchField(context)
    override val titleView: View get() = searchBar
    val categoryTabBarController: CYLTabBarController
    val industryButton = Button(context)
    var category = CYLSearchCategory.PEOPLE
        private set
    var industry = industries()[0]
        private set
    val jobCategories = listOf("开发", "测试", "运维/DBA", "硬件", "产品", "运营", "设计", "编辑/记者", "游戏", "市场BD")
    var jobCategoryIndex = 0
        private set
    private val tagListViews = HashMap<CYLSearchCategory, CYLTagListView>()
    private val menuSources = HashMap<CYLSearchCategory, CYLExampleMenuSource>()
    private val jobRows = ArrayList<TextView>()
    private val d = context.resources.displayMetrics.density
    override val view: View

    companion object {
        fun industries() = listOf("IT互联网", "金融", "教育培训", "医疗健康", "房地产")

        val jobKeywords: Map<String, List<String>> = mapOf(
            "开发" to listOf("后端开发", "PHP", "Java", "Python", ".NET", "C#", "C/C++", "Ruby", "Hadoop", "Node.js",
                "Perl", "搜索算法", "推荐算法", "数据挖掘", "机器学习", "信息检索", "NLP", "语音算法",
                "视频算法", "图像算法", "全栈", "Linux", "广告算法", "GO", "ASP", "Shell", "VB",
                "Delphi", "前端开发", "Web前端", "Flash"),
            "测试" to listOf("测试工程师", "自动化测试", "性能测试", "测试开发", "白盒测试", "游戏测试", "手机测试"),
            "运维/DBA" to listOf("运维工程师", "DBA", "系统管理员", "网络工程师", "IT支持", "SRE"),
            "硬件" to listOf("嵌入式", "单片机", "电路设计", "FPGA", "驱动开发", "射频工程师"),
            "产品" to listOf("产品经理", "产品助理", "产品总监", "数据产品", "游戏策划", "移动产品"),
            "运营" to listOf("内容运营", "用户运营", "活动运营", "新媒体", "社区运营", "数据运营", "SEO"),
            "设计" to listOf("UI设计", "交互设计", "视觉设计", "平面设计", "用户研究", "动效设计"),
            "编辑/记者" to listOf("编辑", "记者", "文案", "主编", "撰稿人"),
            "游戏" to listOf("游戏开发", "游戏策划", "游戏美术", "Unity3D", "Cocos2d-x"),
            "市场BD" to listOf("市场推广", "商务拓展", "品牌", "公关", "渠道", "大客户"),
        )

        fun sections(context: Context, category: CYLSearchCategory): List<CYLExampleMenuSection> {
            fun section(key: String, titles: List<String>) = CYLExampleMenuSection(CYLExampleLocalizedString(context, key), titles.map { CYLExampleMenuItem(it) })
            return when (category) {
                CYLSearchCategory.PEOPLE -> listOf(
                    section("认识同行", listOf("百度研发", "腾讯工程师", "搜狗开发", "腾讯开发", "搜狗研究员")),
                    section("找投资", listOf("创投", "IDG资本", "晨兴资本", "合伙人", "投资经理")),
                    section("谈合作", listOf("CEO", "副总裁", "VP", "总经理", "总监")),
                    section("挖人才", listOf("Java", "Android", "JS", "C++", "HTML/CSS", "iOS", "PHP", "前端")))
                CYLSearchCategory.FEEDS -> listOf(section("热门动态关键词",
                    listOf("投资", "创业", "o2o", "社交", "招聘", "运营", "线下聚会", "脉脉", "融资", "在线教育", "硬件", "电商", "产品经理")))
                CYLSearchCategory.GOSSIP -> listOf(
                    section("热门词", listOf("百度", "新浪", "程序猿", "离职", "阿里", "360", "创业", "工资", "跳槽", "小三", "裁员", "加班", "女同事", "产品经理", "投资人", "老板")),
                    section("我关注的标签", listOf("社交", "移动", "程序猿")))
                CYLSearchCategory.JOBS -> emptyList()
            }
        }

        fun placeholder(context: Context, category: CYLSearchCategory) =
            CYLExampleLocalizedString(context, listOf("搜人名,职位,公司...", "搜动态", "搜八卦", "搜职位")[category.ordinal])

        /**
         * `maimaiStyle()`: Maimai's hot tags (grey outlined boxes, grey section titles).
         */
        fun maimaiStyle(): CYLMenuStyle {
            val style = CYLMenuStyle()
            style.setTitleTextAttributes(CYLFont.systemFont(14f), Color.rgb(89, 89, 89), CYLControlState.NORMAL)
            style.normalAppearance.borderColor = Color.rgb(204, 204, 204)
            style.normalAppearance.borderWidth = 1f
            style.normalAppearance.cornerRadius = 2f
            style.normalAppearance.margin = 14f
            style.itemHeight = 32f
            style.interitemSpacing = 14f
            style.lineSpacing = 14f
            style.sectionInsets = CYLEdgeInsets(4f, 24f, 14f, 16f)
            style.headerHeight = 32f
            style.headerFont = CYLFont.systemFont(13f)
            style.headerTextColor = Color.rgb(153, 153, 153)
            return style
        }
    }

    init {
        industryButton.apply {
            isAllCaps = false
            background = null
            stateListAnimator = null
            minWidth = 0
            minimumWidth = 0
            minHeight = 0
            minimumHeight = 0
            setPadding(0, 0, 0, 0)
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 13f)
            setTextColor(com.cyl.classifymenu.CYLAppTintColor)
            setOnClickListener { showIndustryMenu() }
        }
        updateIndustryButton()
        val titles = listOf("找人", "动态", "八卦", "职位")
        val icons = listOf(R.drawable.ic_search_people, R.drawable.ic_search_feeds, R.drawable.ic_search_gossip, R.drawable.ic_search_jobs)
        val pages = ArrayList<Fragment>()
        val attributes = ArrayList<Map<String, Any?>>()
        for (category in CYLSearchCategory.values()) {
            val tags = makeTagListView()
            tagListViews[category] = tags
            val content: View = if (category == CYLSearchCategory.JOBS) LinearLayout(context).apply {
                addView(makeJobSidebar(), LinearLayout.LayoutParams((90 * d).toInt(), LinearLayout.LayoutParams.MATCH_PARENT))
                addView(tags, LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.MATCH_PARENT, 1f))
            } else tags
            pages.add(CYLViewHostFragment().also { it.content = content.apply { setBackgroundColor(Color.WHITE) } })
            attributes.add(mapOf(
                CYLConstants.CYLTabBarItemTitle to CYLExampleLocalizedString(context, titles[category.ordinal]),
                CYLConstants.CYLTabBarItemImage to ContextCompat.getDrawable(context, icons[category.ordinal]),
            ))
            reloadTags(category)
        }
        val tabs = CYLTabBarController(context as FragmentActivity, pages, attributes)
        tabs.delegate = this
        categoryTabBarController = tabs
        view = FrameLayout(context).apply {
            setBackgroundColor(Color.WHITE)
            addView(tabs.view, FrameLayout.LayoutParams(FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.MATCH_PARENT))
        }
        select(CYLSearchCategory.PEOPLE)
    }

    private fun makeTagListView() = CYLTagListView(context).apply {
        style = maimaiStyle()
        selectionMode = CYLMenuSelectionMode.CYLMenuSelectionModeNone
        menuDelegate = this@CYLSearchCategoryScreen
    }

    private fun makeJobSidebar(): View {
        val list = LinearLayout(context).apply { orientation = LinearLayout.VERTICAL }
        jobCategories.forEachIndexed { index, name ->
            val row = TextView(context).apply {
                text = CYLExampleLocalizedString(context, name)
                gravity = Gravity.CENTER
                maxLines = 2
                setTextSize(TypedValue.COMPLEX_UNIT_SP, 15f)
                setTextColor(Color.BLACK)
                isClickable = true
                isFocusable = true
                setOnClickListener { selectJobCategory(index) }
            }
            jobRows.add(row)
            list.addView(row, LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, (50 * d).toInt()))
        }
        return ScrollView(context).apply { setBackgroundColor(Color.rgb(242, 242, 247)); addView(list) }
    }

    fun tagListView(category: CYLSearchCategory): CYLTagListView = tagListViews.getValue(category)

    val tagListView: CYLTagListView get() = tagListView(category)

    fun select(category: CYLSearchCategory) {
        categoryTabBarController.selectedIndex = category.ordinal
        categoryDidChange(category)
    }

    private fun categoryDidChange(category: CYLSearchCategory) {
        this.category = category
        searchBar.placeholder = placeholder(context, category)
        if (category == CYLSearchCategory.JOBS) selectJobCategory(jobCategoryIndex)
    }

    private fun reloadTags(category: CYLSearchCategory) {
        val sections = if (category == CYLSearchCategory.JOBS) {
            val name = jobCategories[jobCategoryIndex]
            listOf(CYLExampleMenuSection(CYLExampleLocalizedString(context, "热搜职位关键词:"), jobKeywords[name].orEmpty().map { CYLExampleMenuItem(it) }).also {
                (industryButton.parent as? ViewGroup)?.removeView(industryButton)
                it.accessoryView = industryButton
            })
        } else sections(context, category)
        val source = CYLExampleMenuSource(sections)
        menuSources[category] = source
        val view = tagListView(category)
        view.menuDataSource = source
        view.reloadMenuData()
    }

    fun selectJobCategory(index: Int) {
        jobCategoryIndex = index.coerceIn(0, jobCategories.size - 1)
        jobRows.forEachIndexed { row, label ->
            val selected = row == jobCategoryIndex
            label.setBackgroundColor(if (selected) Color.WHITE else Color.TRANSPARENT)
            label.setTextColor(if (selected) com.cyl.classifymenu.CYLAppTintColor else Color.BLACK)
            label.isSelected = selected
        }
        reloadTags(CYLSearchCategory.JOBS)
    }

    fun selectIndustry(industry: String) {
        this.industry = industry
        updateIndustryButton()
        tagListView(CYLSearchCategory.JOBS).reloadMenuData()
    }

    private fun updateIndustryButton() {
        val name = CYLExampleLocalizedString(context, industry)
        industryButton.text = CYLExampleLocalizedString(context, "行业: %@ ▾", name)
        industryButton.contentDescription = CYLExampleLocalizedString(context, "行业 %@", name)
        androidx.core.view.ViewCompat.setStateDescription(industryButton, CYLExampleLocalizedString(context, "选择行业"))
    }

    private fun showIndustryMenu() {
        PopupMenu(context, industryButton).apply {
            industries().forEachIndexed { index, industry ->
                menu.add(0, index, index, CYLExampleLocalizedString(context, industry)).apply { isCheckable = true; isChecked = industry == this@CYLSearchCategoryScreen.industry }
            }
            menu.setGroupCheckable(0, true, true)
            setOnMenuItemClickListener { selectIndustry(industries()[it.itemId]); true }
        }.show()
    }

    override fun menuDidSelectItemAtIndexPath(menu: Any, indexPath: CYLIndexPath) {
        for ((category, source) in menuSources) if (tagListViews[category] === menu) searchBar.text = source.item(indexPath).title
    }

    override fun tabBarController_didSelectViewController(tabBarController: CYLTabBarController, viewController: CYLViewController) {
        val index = tabBarController.viewControllers.indexOf(viewController)
        if (index >= 0) categoryDidChange(CYLSearchCategory.values()[index])
    }
}
