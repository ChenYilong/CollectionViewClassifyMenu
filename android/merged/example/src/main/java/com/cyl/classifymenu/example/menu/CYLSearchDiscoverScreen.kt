package com.cyl.classifymenu.example.menu

import android.annotation.SuppressLint
import android.content.Context
import android.graphics.BitmapFactory
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.Path
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.graphics.drawable.GradientDrawable
import android.text.InputType
import android.util.TypedValue
import android.view.Gravity
import android.view.MotionEvent
import android.view.View
import android.view.inputmethod.EditorInfo
import android.view.inputmethod.InputMethodManager
import android.widget.EditText
import android.widget.FrameLayout
import android.widget.ImageButton
import android.widget.LinearLayout
import android.widget.ScrollView
import android.widget.TextView
import androidx.appcompat.app.AlertDialog
import androidx.core.content.ContextCompat
import com.cyl.classifymenu.CYLControlState
import com.cyl.classifymenu.CYLEdgeInsets
import com.cyl.classifymenu.CYLFont
import com.cyl.classifymenu.CYLIndexPath
import com.cyl.classifymenu.CYLMenuDataSource
import com.cyl.classifymenu.CYLMenuDelegate
import com.cyl.classifymenu.CYLMenuFoldControl
import com.cyl.classifymenu.CYLMenuFoldControlContent
import com.cyl.classifymenu.CYLMenuFoldControlPosition
import com.cyl.classifymenu.CYLMenuSelectionMode
import com.cyl.classifymenu.CYLMenuStyle
import com.cyl.classifymenu.CYLSize
import com.cyl.classifymenu.CYLTagListView
import com.cyl.classifymenu.cyl_imageWithRenderingModeAlwaysOriginal
import com.cyl.classifymenu.example.R
import org.json.JSONObject
import kotlin.random.Random

/**
 * `CYLDiscoverTopic`: a topic of the discover grid, with an optional "hot" icon.
 */
data class CYLDiscoverTopic(val title: String, val icon: String? = null)

/**
 * `CYLSearchDiscoverData`: the demo's data, `search-discover.json` of the current language (else Simplified Chinese).
 */
data class CYLSearchDiscoverData(val version: Int, val discoverCount: Int, val recentSearches: List<String>, val discover: List<CYLDiscoverTopic>) {
    companion object {
        fun bundled(context: Context): CYLSearchDiscoverData {
            val text = listOf(CYLExampleLocalization.localizedPath("search-discover.json"), CYLExampleLocalization.path("zh-Hans.lproj/search-discover.json")).firstNotNullOfOrNull { path ->
                try { context.assets.open(path).use { it.readBytes().toString(Charsets.UTF_8) } } catch (error: Exception) { null }
            } ?: return CYLSearchDiscoverData(1, 6, emptyList(), emptyList())
            val json = JSONObject(text)
            val recent = json.getJSONArray("recentSearches").let { array -> (0 until array.length()).map { array.getString(it) } }
            val topics = json.getJSONArray("discover").let { array ->
                (0 until array.length()).map { array.getJSONObject(it).let { topic -> CYLDiscoverTopic(topic.getString("title"), topic.optString("icon").ifEmpty { null }) } }
            }
            return CYLSearchDiscoverData(json.optInt("version", 1), json.optInt("discoverCount", 6), recent, topics)
        }

        /**
         * The hot icon of the current language (discover-hot@3x.png of its .lproj), labeled for TalkBack.
         */
        fun hotIcon(context: Context): Drawable? = try {
            context.assets.open(CYLExampleLocalization.localizedPath("discover-hot@3x.png")).use { BitmapFactory.decodeStream(it) }?.let { bitmap ->
                bitmap.density = 480
                // A colored picture: drawn in its own colors, as the PNG (not a template image) is on iOS.
                BitmapDrawable(context.resources, bitmap).cyl_imageWithRenderingModeAlwaysOriginal()
            }
        } catch (error: Exception) {
            null
        }
    }

    /**
     * The first selection: the first `discoverCount` topics, so the first screen is always the same.
     */
    val initialTopics: List<CYLDiscoverTopic> get() = discover.take(maxOf(0, discoverCount))

    /**
     * Another random selection of `discoverCount` topics; it differs from `current` whenever the pool allows.
     */
    fun randomTopics(current: List<CYLDiscoverTopic>, random: Random): List<CYLDiscoverTopic> {
        val count = minOf(maxOf(0, discoverCount), discover.size)
        val picked = discover.filter { it !in current }.shuffled(random).take(count).toMutableList()
        if (picked.size < count) picked += discover.filter { it !in picked }.shuffled(random).take(count - picked.size)
        return picked
    }
}

/**
 * `CYLRecentSearchSource`: the recent searches (no section when empty), a clear button as the section's accessory.
 */
class CYLRecentSearchSource(private val context: Context) : CYLMenuDataSource {
    var searches: MutableList<String> = ArrayList()
    val clearButton = ImageButton(context)
    override fun numberOfSectionsInMenu() = if (searches.isEmpty()) 0 else 1
    override fun menuNumberOfItemsInSection(section: Int) = searches.size
    override fun menuTitleForSection(section: Int) = CYLExampleLocalizedString(context, "最近搜索")
    override fun menuTitleForItemAtIndexPath(indexPath: CYLIndexPath) = searches[indexPath.item]
    override fun menuAccessoryViewForSection(section: Int): View = clearButton
    override fun menuAccessibilityHintForItemAtIndexPath(indexPath: CYLIndexPath) = CYLExampleLocalizedString(context, "轻点两下搜索")
}

/**
 * `CYLDiscoverSource`: the discover topics, two per row, with a More button ("换一批") in the header.
 */
class CYLDiscoverSource(private val context: Context) : CYLMenuDataSource {
    var topics: List<CYLDiscoverTopic> = emptyList()
    private val hot by lazy { CYLSearchDiscoverData.hotIcon(context) }
    override fun numberOfSectionsInMenu() = 1
    override fun menuNumberOfItemsInSection(section: Int) = topics.size
    override fun menuTitleForSection(section: Int) = CYLExampleLocalizedString(context, "发现")
    override fun menuTitleForItemAtIndexPath(indexPath: CYLIndexPath) = topics[indexPath.item].title
    override fun menuImageForItemAtIndexPath(indexPath: CYLIndexPath) = if (topics[indexPath.item].icon == "hot") (hot as? com.cyl.classifymenu.CYLOriginalImageDrawable)?.image?.constantState?.newDrawable(context.resources)?.mutate()?.cyl_imageWithRenderingModeAlwaysOriginal() else null
    override fun menuAccessibilityHintForItemAtIndexPath(indexPath: CYLIndexPath) = CYLExampleLocalizedString(context, "轻点两下搜索")
    override fun menuShowsMoreButtonInSection(section: Int) = true
    override fun menuAccessibilityLabelForMoreButtonInSection(section: Int) = CYLExampleLocalizedString(context, "换一批")
}

/**
 * `CYLAskBackgroundView`: the ask area's background, rising in a curve at the top.
 */
class CYLAskBackgroundView(context: Context) : View(context) {
    private val paint = Paint(Paint.ANTI_ALIAS_FLAG).apply { color = Color.rgb(242, 242, 247) }
    private val path = Path()

    init {
        importantForAccessibility = IMPORTANT_FOR_ACCESSIBILITY_NO
    }

    override fun onDraw(canvas: Canvas) {
        val rise = minOf(height.toFloat(), 40 * resources.displayMetrics.density)
        path.reset()
        path.moveTo(0f, rise)
        path.quadTo(width / 2f, -rise, width.toFloat(), rise)
        path.lineTo(width.toFloat(), height.toFloat())
        path.lineTo(0f, height.toFloat())
        path.close()
        canvas.drawPath(path, paint)
    }
}

/**
 * `CYLSearchDiscoverViewController`: a search field with the image search and Search buttons (no navigation bar),
 * the recent searches (folded to two rows, the chevron as the last tag, a clear button) and the discover grid (two
 * per row, cut with an ellipsis, a More button that picks others at random), and a hold-to-ask microphone.
 */
class CYLSearchDiscoverScreen(private val context: Context, private val navigator: CYLMenuNavigator,
                              val data: CYLSearchDiscoverData = CYLSearchDiscoverData.bundled(context)) : CYLMenuScreen, CYLMenuDelegate {
    override val title: CharSequence = CYLExampleLocalizedString(context, "最近搜索 + 发现")
    override val hidesNavigationBar = true
    val recentSource = CYLRecentSearchSource(context)
    val discoverSource = CYLDiscoverSource(context)
    var random: Random = Random.Default
    val searchField = EditText(context)
    val recentList = CYLTagListView(context, CYLMenuFoldControl.foldControlWithPosition(CYLMenuFoldControlPosition.TAIL, CYLMenuFoldControlContent.CYLMenuFoldControlContentIcon))
    val discoverList = CYLTagListView(context)
    val hintLabel = TextView(context)
    val micButton = ImageButton(context)
    private val d = context.resources.displayMetrics.density
    override val view: View

    companion object {
        private val separator = Color.rgb(198, 198, 200)

        private fun applyHeaderLook(style: CYLMenuStyle) {
            style.backgroundColor = Color.WHITE
            style.headerHeight = 44f
            style.headerFont = CYLFont(20f, android.graphics.Typeface.DEFAULT_BOLD)
            style.headerTextColor = Color.BLACK
            style.headerHorizontalInset = 16f
        }

        fun recentStyle() = CYLMenuStyle().apply {
            for (state in listOf(CYLControlState.NORMAL, CYLControlState.SELECTED, CYLControlState.DISABLED)) {
                appearanceForState(state).apply {
                    backgroundColor = Color.WHITE
                    borderColor = separator
                    borderWidth = 1f
                    cornerRadius = 0f
                    margin = 14f
                    font = CYLFont.systemFont(17f)
                    textColor = Color.BLACK
                }
            }
            itemHeight = 36f
            interitemSpacing = 12f
            lineSpacing = 12f
            sectionInsets = CYLEdgeInsets(4f, 16f, 24f, 16f)
            applyHeaderLook(this)
        }

        fun discoverStyle() = CYLMenuStyle.gridStyleWithNumberOfItemsPerRow(2).apply {
            for (state in listOf(CYLControlState.NORMAL, CYLControlState.SELECTED, CYLControlState.DISABLED)) {
                appearanceForState(state).font = CYLFont(17f, android.graphics.Typeface.create("sans-serif-medium", android.graphics.Typeface.NORMAL))
            }
            imageSize = CYLSize.ZERO
            itemHeight = 36f
            lineSpacing = 16f
            sectionInsets = CYLEdgeInsets(4f, 16f, 16f, 16f)
            applyHeaderLook(this)
        }
    }

    init {
        recentSource.searches = data.recentSearches.toMutableList()
        discoverSource.topics = data.initialTopics
        recentList.style = recentStyle()
        recentList.selectionMode = CYLMenuSelectionMode.CYLMenuSelectionModeNone
        recentList.defaultVisibleRows = 2
        recentList.isScrollEnabled = false
        recentList.menuDataSource = recentSource
        recentList.menuDelegate = this
        recentSource.clearButton.apply {
            background = null
            setImageResource(R.drawable.ic_discover_trash)
            setColorFilter(Color.argb(153, 60, 60, 67))
            contentDescription = CYLExampleLocalizedString(context, "清空最近搜索")
            setOnClickListener { clearRecentSearches() }
        }
        discoverList.style = discoverStyle()
        discoverList.selectionMode = CYLMenuSelectionMode.CYLMenuSelectionModeNone
        discoverList.isScrollEnabled = false
        discoverList.menuDataSource = discoverSource
        discoverList.menuDelegate = this
        view = FrameLayout(context).apply {
            setBackgroundColor(Color.WHITE)
            addView(LinearLayout(context).apply {
                orientation = LinearLayout.VERTICAL
                addView(makeSearchBar(), LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT))
                addView(ScrollView(context).apply {
                    addView(LinearLayout(context).apply {
                        orientation = LinearLayout.VERTICAL
                        addView(recentList)
                        addView(discoverList)
                        setPadding(0, 0, 0, (160 * d).toInt())
                    })
                }, LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, 0, 1f))
            })
            addView(makeAskArea(), FrameLayout.LayoutParams(FrameLayout.LayoutParams.MATCH_PARENT, (150 * d).toInt(), Gravity.BOTTOM))
        }
        reloadLists()
    }

    private fun makeSearchBar(): View {
        val back = ImageButton(context).apply {
            background = null
            setImageDrawable(com.cyl.classifymenu.example.tageditor.CYLSymbolDrawable("chevron.left", 20f, d).also { it.setTint(Color.BLACK) })
            contentDescription = CYLExampleLocalizedString(context, "返回")
            setOnClickListener { navigator.pop() }
        }
        searchField.apply {
            setSingleLine()
            inputType = InputType.TYPE_CLASS_TEXT
            imeOptions = EditorInfo.IME_ACTION_SEARCH
            background = null
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 16f)
            contentDescription = CYLExampleLocalizedString(context, "搜索")
            setOnEditorActionListener { _, action, _ -> if (action == EditorInfo.IME_ACTION_SEARCH) { searchTapped(); hideKeyboard(); true } else false }
        }
        val camera = ImageButton(context).apply {
            background = null
            setImageResource(R.drawable.ic_discover_camera)
            contentDescription = CYLExampleLocalizedString(context, "以图搜索")
            setOnClickListener { searchByImage() }
        }
        val search = TextView(context).apply {
            text = CYLExampleLocalizedString(context, "搜索")
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 17f)
            typeface = android.graphics.Typeface.DEFAULT_BOLD
            setTextColor(Color.BLACK)
            gravity = Gravity.CENTER
            setPadding((10 * d).toInt(), 0, (14 * d).toInt(), 0)
            isClickable = true
            isFocusable = true
            setOnClickListener { searchTapped() }
        }
        val field = LinearLayout(context).apply {
            gravity = Gravity.CENTER_VERTICAL
            background = GradientDrawable().apply { setColor(Color.WHITE); cornerRadius = 22 * d; setStroke(maxOf(1, d.toInt()), separator) }
            elevation = 2 * d
            setPadding((16 * d).toInt(), 0, 0, 0)
            addView(searchField, LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.MATCH_PARENT, 1f))
            addView(camera, LinearLayout.LayoutParams((36 * d).toInt(), (36 * d).toInt()))
            addView(View(context).apply { setBackgroundColor(separator); importantForAccessibility = View.IMPORTANT_FOR_ACCESSIBILITY_NO }, LinearLayout.LayoutParams(maxOf(1, d.toInt()), (18 * d).toInt()).apply { leftMargin = (4 * d).toInt() })
            addView(search, LinearLayout.LayoutParams(LinearLayout.LayoutParams.WRAP_CONTENT, LinearLayout.LayoutParams.MATCH_PARENT))
        }
        return LinearLayout(context).apply {
            gravity = Gravity.CENTER_VERTICAL
            setPadding((6 * d).toInt(), (8 * d).toInt(), (16 * d).toInt(), (8 * d).toInt())
            addView(back, LinearLayout.LayoutParams((40 * d).toInt(), (44 * d).toInt()))
            addView(field, LinearLayout.LayoutParams(0, (46 * d).toInt(), 1f))
        }
    }

    @SuppressLint("ClickableViewAccessibility")
    private fun makeAskArea(): View {
        showHint(CYLExampleLocalizedString(context, "按住提问，有问必答"))
        hintLabel.apply {
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 20f)
            setTextColor(Color.argb(153, 60, 60, 67))
            gravity = Gravity.CENTER
        }
        micButton.apply {
            setImageResource(R.drawable.ic_discover_mic)
            setColorFilter(Color.rgb(255, 59, 48))
            background = GradientDrawable().apply { setColor(Color.WHITE); cornerRadius = 26 * d }
            elevation = 4 * d
            contentDescription = CYLExampleLocalizedString(context, "按住提问")
            androidx.core.view.ViewCompat.setAccessibilityDelegate(this, object : androidx.core.view.AccessibilityDelegateCompat() {
                override fun onInitializeAccessibilityNodeInfo(host: View, info: androidx.core.view.accessibility.AccessibilityNodeInfoCompat) {
                    super.onInitializeAccessibilityNodeInfo(host, info)
                    info.hintText = CYLExampleLocalizedString(context, "按住说出问题，松开发送")
                }
            })
            setOnClickListener { announce(CYLExampleLocalizedString(context, "请按住麦克风按钮说出问题")) }
            setOnLongClickListener {
                val listening = CYLExampleLocalizedString(context, "正在聆听…")
                showHint(listening)
                announce(listening)
                true
            }
            setOnTouchListener { _, event ->
                if (event.actionMasked == MotionEvent.ACTION_UP || event.actionMasked == MotionEvent.ACTION_CANCEL) showHint(CYLExampleLocalizedString(context, "按住提问，有问必答"))
                false
            }
        }
        return FrameLayout(context).apply {
            addView(CYLAskBackgroundView(context), FrameLayout.LayoutParams(FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.MATCH_PARENT))
            addView(hintLabel, FrameLayout.LayoutParams(FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.WRAP_CONTENT, Gravity.TOP).apply { topMargin = (40 * d).toInt() })
            addView(micButton, FrameLayout.LayoutParams((52 * d).toInt(), (52 * d).toInt(), Gravity.BOTTOM or Gravity.CENTER_HORIZONTAL).apply { bottomMargin = (16 * d).toInt() })
        }
    }

    private fun showHint(text: String) {
        hintLabel.text = "$text ✨"
        hintLabel.contentDescription = text
    }

    private fun announce(text: String) = view.announceForAccessibility(text)

    private fun hideKeyboard() {
        (context.getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager).hideSoftInputFromWindow(searchField.windowToken, 0)
        searchField.clearFocus()
    }

    fun reloadLists() {
        searchField.hint = discoverSource.topics.firstOrNull()?.title ?: CYLExampleLocalizedString(context, "搜索")
        recentList.reloadMenuData()
        discoverList.reloadMenuData()
    }

    fun refreshDiscover() {
        discoverSource.topics = data.randomTopics(discoverSource.topics, random)
        reloadLists()
    }

    fun search(text: String) {
        val query = text.trim()
        if (query.isEmpty()) return
        searchField.setText(query)
        searchField.setSelection(query.length)
        recentSource.searches.remove(query)
        recentSource.searches.add(0, query)
        reloadLists()
        announce(CYLExampleLocalizedString(context, "正在搜索：%@", query))
    }

    fun searchTapped() = search(searchField.text.toString().ifEmpty { searchField.hint?.toString().orEmpty() })

    fun clearRecentSearches() {
        recentSource.searches.clear()
        reloadLists()
        announce(CYLExampleLocalizedString(context, "已清空最近搜索"))
    }

    fun searchByImage() {
        AlertDialog.Builder(context)
            .setTitle(CYLExampleLocalizedString(context, "以图搜索"))
            .setMessage(CYLExampleLocalizedString(context, "演示中暂不支持以图搜索。"))
            .setPositiveButton(CYLExampleLocalizedString(context, "好"), null)
            .show()
    }

    override fun menuDidSelectItemAtIndexPath(menu: Any, indexPath: CYLIndexPath) {
        if (menu === recentList) search(recentSource.searches[indexPath.item]) else search(discoverSource.topics[indexPath.item].title)
    }

    override fun menuDidTapMoreButtonInSection(menu: Any, section: Int) = refreshDiscover()
}
