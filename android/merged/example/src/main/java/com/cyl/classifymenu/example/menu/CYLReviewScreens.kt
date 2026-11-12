package com.cyl.classifymenu.example.menu

import android.content.Context
import android.graphics.Color
import android.graphics.Typeface
import android.util.TypedValue
import android.view.Gravity
import android.view.View
import android.widget.Button
import android.widget.LinearLayout
import android.widget.ProgressBar
import android.widget.ScrollView
import android.widget.TextView
import com.cyl.classifymenu.CYLAppTintColor
import com.cyl.classifymenu.CYLControlState
import com.cyl.classifymenu.CYLEdgeInsets
import com.cyl.classifymenu.CYLFont
import com.cyl.classifymenu.CYLIndexPath
import com.cyl.classifymenu.CYLMenuDelegate
import com.cyl.classifymenu.CYLMenuFoldControl
import com.cyl.classifymenu.CYLMenuFoldControlContent
import com.cyl.classifymenu.CYLMenuFoldControlPosition
import com.cyl.classifymenu.CYLMenuFoldStyle
import com.cyl.classifymenu.CYLMenuSelectionMode
import com.cyl.classifymenu.CYLMenuStyle
import com.cyl.classifymenu.CYLSize
import com.cyl.classifymenu.CYLTagListView
import com.cyl.classifymenu.example.tageditor.CYLSymbolDrawable

private val CYLSecondaryText = Color.argb(153, 60, 60, 67)

/**
 * `CYLReviewListViewController.reviewFilterStyle()`: Taobao's review filter (grey boxes, orange when selected).
 */
fun reviewFilterStyle(): CYLMenuStyle {
    val orange = Color.rgb(255, 79, 0)
    val style = CYLMenuStyle()
    val font = CYLFont.systemFont(12f)
    style.setTitleTextAttributes(font, Color.rgb(77, 77, 77), CYLControlState.NORMAL)
    style.setTitleTextAttributes(font, Color.WHITE, CYLControlState.SELECTED)
    style.setTitleTextAttributes(font, Color.rgb(179, 179, 179), CYLControlState.DISABLED)
    style.imageSize = CYLSize(13f, 13f)
    style.imageTitleSpacing = 3f
    for (appearance in listOf(style.normalAppearance, style.selectedAppearance, style.disabledAppearance)) {
        appearance.cornerRadius = 2f
        appearance.margin = 8f
        appearance.borderWidth = 0.5f
        appearance.backgroundColor = Color.rgb(245, 245, 245)
        appearance.borderColor = Color.rgb(224, 224, 224)
    }
    style.selectedAppearance.backgroundColor = orange
    style.selectedAppearance.borderColor = orange
    style.itemHeight = 28f
    style.interitemSpacing = 8f
    style.lineSpacing = 10f
    style.sectionInsets = CYLEdgeInsets(10f, 12f, 6f, 12f)
    style.foldControlColor = Color.rgb(115, 115, 115)
    return style
}

private fun label(context: Context, text: String, sizeSp: Float, color: Int, bold: Boolean = false) = TextView(context).apply {
    this.text = text
    setTextSize(TypedValue.COMPLEX_UNIT_SP, sizeSp)
    setTextColor(color)
    if (bold) typeface = Typeface.DEFAULT_BOLD
}

/**
 * `CYLProductViewController`: the product, its price and the review keywords (two rows, cut), "查看更多评价".
 */
class CYLProductScreen(private val context: Context, private val navigator: CYLMenuNavigator) : CYLMenuScreen, CYLMenuDelegate {
    private val store = CYLReviewStore.shared(context)
    override val title: CharSequence = CYLExampleLocalizedString(context, "宝贝详情")
    val previewView = CYLTagListView(context)
    var previewFilterIndexes: List<Int> = emptyList()
        private set
    override val view: View

    init {
        val d = context.resources.displayMetrics.density
        val pad = (16 * d).toInt()
        val items = ArrayList<CYLExampleMenuItem>()
        val indexes = ArrayList<Int>()
        store.filters.forEachIndexed { index, filter -> if (filter.isKeyword) { items.add(CYLExampleMenuItem(store.title(context, filter))); indexes.add(index) } }
        previewFilterIndexes = indexes
        val source = CYLExampleMenuSource(listOf(CYLExampleMenuSection(CYLExampleLocalizedString(context, "关键词"), items)))
        val style = reviewFilterStyle().also { it.sectionInsets = CYLEdgeInsets(4f, 0f, 12f, 0f) }
        previewView.style = style
        previewView.selectionMode = CYLMenuSelectionMode.CYLMenuSelectionModeNone
        previewView.showsSectionHeaders = false
        previewView.foldStyle = CYLMenuFoldStyle.CYLMenuFoldStyleTruncate
        previewView.defaultVisibleRows = 2
        previewView.isScrollEnabled = false
        previewView.menuDelegate = this
        previewView.menuDataSource = source
        previewView.reloadMenuData()
        val card = LinearLayout(context).apply {
            orientation = LinearLayout.VERTICAL
            setBackgroundColor(Color.WHITE)
            setPadding(pad, (12 * d).toInt(), pad, (12 * d).toInt())
            addView(label(context, "潮牌电镀镜面MLGB字母iphone6手机壳苹果6plus手机壳情侣5S外壳潮", 16f, Color.BLACK))
            addView(label(context, "¥9.90-14.90", 22f, Color.rgb(255, 79, 0), true))
        }
        val reviews = LinearLayout(context).apply {
            orientation = LinearLayout.VERTICAL
            setBackgroundColor(Color.WHITE)
            setPadding(pad, (8 * d).toInt(), pad, 0)
            addView(label(context, CYLExampleLocalizedString(context, "宝贝评价(%lu)", store.reviews.size), 15f, Color.BLACK))
            addView(previewView)
            for (review in store.reviews.take(2)) addView(label(context, "${review.user}\n${review.text}", 13f, CYLSecondaryText).also { it.setPadding(0, (6 * d).toInt(), 0, 0) })
            addView(Button(context).apply {
                text = CYLExampleLocalizedString(context, "查看更多评价")
                isAllCaps = false
                background = null
                setTextColor(CYLAppTintColor)
                setOnClickListener { showReviews(0) }
            }, LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, (44 * d).toInt()))
        }
        view = ScrollView(context).apply {
            setBackgroundColor(Color.rgb(242, 242, 247))
            addView(LinearLayout(context).apply {
                orientation = LinearLayout.VERTICAL
                addView(card)
                addView(reviews, LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT).apply { topMargin = 1 })
            })
        }
    }

    fun showReviews(filterIndex: Int): CYLReviewListScreen = CYLReviewListScreen(context, filterIndex).also { navigator.push(it) }

    override fun menuDidSelectItemAtIndexPath(menu: Any, indexPath: CYLIndexPath) {
        showReviews(previewFilterIndexes[indexPath.item])
    }
}

/**
 * `CYLReviewListViewController`: the filters (several, "全部" exclusive, two rows with a chevron), the filtering mode
 * (memory, network, database) and the matching reviews, with what was sent and found.
 */
class CYLReviewListScreen(private val context: Context, private val initialFilterIndex: Int, mode: CYLReviewFilteringMode = CYLReviewFilteringMode.MEMORY) :
    CYLMenuScreen, CYLMenuDelegate, CYLMenuScreenLifecycle {
    private val store = CYLReviewStore.shared(context)
    override val title: CharSequence = CYLExampleLocalizedString(context, "评价(%lu)", store.reviews.size)
    val filterView = CYLTagListView(context, CYLMenuFoldControl.foldControlWithPosition(CYLMenuFoldControlPosition.CYLMenuFoldControlPositionBottom, CYLMenuFoldControlContent.CYLMenuFoldControlContentIcon))
    var mode: CYLReviewFilteringMode = mode
        private set
    var query: CYLReviewQuerying = query(mode)
        private set
    var selectedFilters: List<CYLReviewFilter> = emptyList()
        private set
    var visibleReviews: List<CYLReview> = emptyList()
        private set
    var lastEvent: String? = null
        private set
    val statusLabel = label(context, "", 13f, CYLSecondaryText)
    private val spinner = ProgressBar(context).apply { isIndeterminate = true; visibility = View.GONE }
    private val list = LinearLayout(context).apply { orientation = LinearLayout.VERTICAL }
    private val source: CYLExampleMenuSource
    private val modeButtons = ArrayList<Button>()
    private val d = context.resources.displayMetrics.density
    override val view: View

    private fun query(mode: CYLReviewFilteringMode): CYLReviewQuerying = when (mode) {
        CYLReviewFilteringMode.NETWORK -> CYLNetworkReviewQuery(store)
        CYLReviewFilteringMode.DATABASE -> CYLDatabaseReviewQuery(context, store)
        else -> CYLMemoryReviewQuery(store)
    }

    init {
        val items = store.filters.map { filter ->
            CYLExampleMenuItem(store.title(context, filter)).apply {
                image = filter.image
                value = filter
                isEnabled = store.reviewsMatching(filter).isNotEmpty()
                isExclusive = filter.identifier == "all"
            }
        }
        source = CYLExampleMenuSource(listOf(CYLExampleMenuSection(CYLExampleLocalizedString(context, "评价"), items)))
        filterView.style = reviewFilterStyle()
        filterView.selectionMode = CYLMenuSelectionMode.CYLMenuSelectionModeMultiple
        filterView.showsSectionHeaders = false
        filterView.defaultVisibleRows = 2
        filterView.isScrollEnabled = false
        filterView.menuDelegate = this
        filterView.menuDataSource = source
        filterView.reloadMenuData()
        val modes = LinearLayout(context).apply {
            setPadding((12 * d).toInt(), (8 * d).toInt(), (12 * d).toInt(), 0)
            for ((index, key) in listOf("内存筛选", "网络筛选", "数据库筛选").withIndex()) {
                val button = Button(context).apply {
                    text = CYLExampleLocalizedString(context, key)
                    isAllCaps = false
                    stateListAnimator = null
                    setTextSize(TypedValue.COMPLEX_UNIT_SP, 13f)
                    minHeight = 0
                    minimumHeight = 0
                    minWidth = 0
                    minimumWidth = 0
                    setPadding(0, 0, 0, 0)
                    includeFontPadding = false
                    setOnClickListener { setMode(CYLReviewFilteringMode.values()[index]) }
                }
                modeButtons.add(button)
                addView(button, LinearLayout.LayoutParams(0, (34 * d).toInt(), 1f).apply { if (index > 0) leftMargin = (6 * d).toInt() })
            }
        }
        val status = LinearLayout(context).apply {
            gravity = Gravity.CENTER_VERTICAL
            setBackgroundColor(Color.rgb(242, 242, 247))
            setPadding((12 * d).toInt(), (4 * d).toInt(), (12 * d).toInt(), (8 * d).toInt())
            addView(spinner, LinearLayout.LayoutParams((20 * d).toInt(), (20 * d).toInt()).apply { rightMargin = (6 * d).toInt() })
            addView(statusLabel, LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.WRAP_CONTENT, 1f))
        }
        view = ScrollView(context).apply {
            setBackgroundColor(Color.WHITE)
            addView(LinearLayout(context).apply {
                orientation = LinearLayout.VERTICAL
                addView(modes)
                addView(filterView)
                addView(status)
                addView(list)
            })
        }
        val index = initialFilterIndex.coerceIn(0, items.size - 1)
        val selected = CYLIndexPath(index, 0)
        filterView.selectedIndexPaths = listOf(selected)
        if (index >= filterView.numberOfVisibleItemsInSection(0)) filterView.setExpanded(true, 0, false)
        lastEvent = CYLExampleLocalizedString(context, "点击「%@」", source.item(selected).title)
        updateModeButtons()
        refreshReviews()
    }

    override fun screenDidAppear(navigator: CYLMenuNavigator) {}

    fun setMode(mode: CYLReviewFilteringMode) {
        this.mode = mode
        query = query(mode)
        updateModeButtons()
        refreshReviews()
    }

    private fun updateModeButtons() {
        modeButtons.forEachIndexed { index, button ->
            val selected = index == mode.ordinal
            button.background = android.graphics.drawable.GradientDrawable().apply { setColor(if (selected) CYLAppTintColor else Color.rgb(238, 238, 239)); cornerRadius = 7 * d }
            button.setTextColor(if (selected) Color.WHITE else Color.BLACK)
            button.isSelected = selected
        }
    }

    fun selectFilterIndexes(indexes: List<Int>) {
        for (index in indexes) {
            val indexPath = CYLIndexPath(index, 0)
            filterView.selectItemAtIndexPath(indexPath)
            lastEvent = CYLExampleLocalizedString(context, "点击「%@」", source.item(indexPath).title)
        }
        refreshReviews()
    }

    fun refreshReviews() {
        selectedFilters = filterView.selectedIndexPaths.mapNotNull { (source.item(it).value as? CYLReviewFilter)?.takeIf { f -> f.identifier != "all" } }
        query.fetchReviewsMatching(selectedFilters) { show(it) }
        if (query.isLoading) {
            spinner.visibility = View.VISIBLE
            list.alpha = 0.5f
            updateStatus()
        }
    }

    private fun show(reviews: List<CYLReview>) {
        visibleReviews = reviews
        spinner.visibility = View.GONE
        list.alpha = 1f
        list.removeAllViews()
        if (reviews.isEmpty()) {
            list.addView(label(context, CYLExampleLocalizedString(context, "没有匹配的评价"), 15f, CYLSecondaryText).apply { gravity = Gravity.CENTER; setPadding(0, (40 * d).toInt(), 0, 0) },
                LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT))
        }
        for (review in reviews) {
            val row = LinearLayout(context).apply {
                setPadding((16 * d).toInt(), (10 * d).toInt(), (16 * d).toInt(), (10 * d).toInt())
                addView(android.widget.ImageView(context).apply {
                    setImageDrawable(CYLSymbolDrawable("person.crop.circle", 28f, d).also { it.setTint(CYLAppTintColor) })
                    importantForAccessibility = View.IMPORTANT_FOR_ACCESSIBILITY_NO
                }, LinearLayout.LayoutParams((28 * d).toInt(), (28 * d).toInt()).apply { rightMargin = (12 * d).toInt() })
                addView(LinearLayout(context).apply {
                    orientation = LinearLayout.VERTICAL
                    addView(label(context, review.user, 16f, Color.BLACK))
                    addView(label(context, "${review.text}\n${review.date} ${review.sku}", 13f, CYLSecondaryText))
                }, LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.WRAP_CONTENT, 1f))
                importantForAccessibility = View.IMPORTANT_FOR_ACCESSIBILITY_YES
                isFocusable = true
                contentDescription = "${review.user}, ${review.text}"
            }
            list.addView(row)
            list.addView(View(context).apply { setBackgroundColor(Color.rgb(224, 224, 224)) }, LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, 1).apply { leftMargin = (56 * d).toInt() })
        }
        updateStatus()
    }

    private fun updateStatus() {
        val names = selectedFilters.map { if (it.isKeyword) it.name else CYLExampleLocalizedString(context, it.name) }
        val selection = if (names.isEmpty()) CYLExampleLocalizedString(context, "全部") else names.joinToString(CYLExampleLocalizedString(context, "、"))
        val lines = arrayListOf("${lastEvent.orEmpty()} · ${CYLExampleLocalizedString(context, "已选：%@", selection)}")
        val count = visibleReviews.size
        when (val q = query) {
            is CYLNetworkReviewQuery -> {
                val url = q.lastRequestURL
                val queryString = url?.encodedQuery?.let { if (it.isEmpty()) "" else "?" + android.net.Uri.decode(it) } ?: ""
                lines.add("${CYLExampleLocalizedString(context, "网络筛选：向服务器发送条件")} · GET ${url?.path.orEmpty()}$queryString")
                lines.add(if (q.isLoading) CYLExampleLocalizedString(context, "加载中…") else CYLExampleLocalizedString(context, "服务器返回 %lu 条", count))
            }
            is CYLDatabaseReviewQuery -> {
                lines.add("${CYLExampleLocalizedString(context, "数据库筛选：条件生成 SQL，在 SQLite 中查询")} · ${CYLExampleLocalizedString(context, "匹配 %lu 条", count)}")
                lines.add(q.lastQuery?.displayString().orEmpty())
            }
            else -> lines.add("${CYLExampleLocalizedString(context, "内存筛选：在已加载的评价中立即匹配")} · ${CYLExampleLocalizedString(context, "匹配 %lu 条", count)}")
        }
        statusLabel.text = lines.joinToString("\n")
    }

    override fun menuDidSelectItemAtIndexPath(menu: Any, indexPath: CYLIndexPath) {
        lastEvent = CYLExampleLocalizedString(context, "点击「%@」", source.item(indexPath).title)
    }

    override fun menuDidDeselectItemAtIndexPath(menu: Any, indexPath: CYLIndexPath) {
        lastEvent = CYLExampleLocalizedString(context, "取消「%@」", source.item(indexPath).title)
    }

    override fun menuDidChangeSelectedItems(menu: Any, indexPaths: List<CYLIndexPath>) {
        if (indexPaths.isEmpty()) filterView.selectItemAtIndexPath(CYLIndexPath(0, 0))
        refreshReviews()
    }
}
