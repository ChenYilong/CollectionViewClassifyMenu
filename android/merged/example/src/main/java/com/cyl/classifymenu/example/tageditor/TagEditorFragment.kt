package com.cyl.classifymenu.example.tageditor

import android.app.Dialog
import android.content.Context
import android.graphics.Color
import android.graphics.Typeface
import android.graphics.drawable.GradientDrawable
import android.os.Bundle
import android.text.Editable
import android.text.TextWatcher
import android.util.TypedValue
import android.view.Gravity
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.view.Window
import android.view.WindowManager
import android.view.inputmethod.EditorInfo
import android.widget.Button
import android.widget.EditText
import android.widget.FrameLayout
import android.widget.LinearLayout
import android.widget.ScrollView
import android.widget.TextView
import androidx.appcompat.app.AlertDialog
import androidx.core.view.ViewCompat
import androidx.fragment.app.Fragment
import com.cyl.classifymenu.CYLControlState
import com.cyl.classifymenu.CYLEdgeInsets
import com.cyl.classifymenu.CYLFont
import com.cyl.classifymenu.CYLIndexPath
import com.cyl.classifymenu.CYLMenuDataSource
import com.cyl.classifymenu.CYLMenuDelegate
import com.cyl.classifymenu.CYLMenuFoldControl
import com.cyl.classifymenu.CYLMenuFoldControlContent
import com.cyl.classifymenu.CYLMenuFoldControlPosition
import com.cyl.classifymenu.CYLMenuItemType
import com.cyl.classifymenu.CYLMenuSelectionMode
import com.cyl.classifymenu.CYLMenuStyle
import com.cyl.classifymenu.CYLMenuTitlePosition
import com.cyl.classifymenu.CYLSize
import com.cyl.classifymenu.CYLTagImagePlacement
import com.cyl.classifymenu.CYLTagListView
import com.cyl.classifymenu.example.classify.classifyNavigationBar
import com.cyl.classifymenu.tagListViewWithConfigurationFile

private val CYLLabelSecondary = Color.argb(153, 60, 60, 67)
private val CYLLabelTertiary = Color.argb(76, 60, 60, 67)
private val CYLGray6 = Color.rgb(242, 242, 247)

/**
 * The tag editor example (`Example-Swift/CYLTagEditorExample`) on Android, one tab with its two screens, Edit tags
 * (`CYLRemarkViewController`, the editor in a sheet) and Fold styles (`CYLFoldStylesViewController`), switched at the top.
 */
class TagEditorFragment : Fragment() {
    var store: CYLTagStore? = null
        private set
    private var page: FrameLayout? = null
    var remarkView: CYLRemarkView? = null
        private set
    var foldStylesView: CYLFoldStylesView? = null
        private set

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View {
        val context = inflater.context
        val data = CYLTagData.bundled(context)
        val store = CYLTagStore(data.tags, data.recentTags).also { this.store = it }
        val d = context.resources.displayMetrics.density
        val title = TextView(context).apply { text = CYLTagEditorLocalizedString(context, "编辑标签") }
        val page = FrameLayout(context).also { this.page = it }
        val edit = segment(context, CYLTagEditorLocalizedString(context, "编辑标签"))
        val styles = segment(context, CYLTagEditorLocalizedString(context, "折叠样式"))
        val segments = LinearLayout(context).apply {
            setPadding((16 * d).toInt(), (8 * d).toInt(), (16 * d).toInt(), (8 * d).toInt())
            addView(edit, LinearLayout.LayoutParams(0, (36 * d).toInt(), 1f))
            addView(styles, LinearLayout.LayoutParams(0, (36 * d).toInt(), 1f).apply { leftMargin = (8 * d).toInt() })
        }
        fun show(stylesSelected: Boolean) {
            edit.isSelected = !stylesSelected
            styles.isSelected = stylesSelected
            title.text = CYLTagEditorLocalizedString(context, if (stylesSelected) "折叠样式" else "编辑标签")
            page.removeAllViews()
            val view = if (stylesSelected) foldStylesView ?: CYLFoldStylesView(context, data).also { foldStylesView = it }
            else remarkView ?: CYLRemarkView(context, store, data.selectedTags).also { remarkView = it }
            page.addView(view)
        }
        edit.setOnClickListener { show(false) }
        styles.setOnClickListener { show(true) }
        show(false)
        return LinearLayout(context).apply {
            orientation = LinearLayout.VERTICAL
            setBackgroundColor(Color.WHITE)
            addView(classifyNavigationBar(context, null, title, null), LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, (48 * d).toInt()))
            addView(segments)
            addView(page, LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, 0, 1f))
        }
    }

    private fun segment(context: Context, text: String) = Button(context).apply {
        this.text = text
        isAllCaps = false
        stateListAnimator = null
        val d = context.resources.displayMetrics.density
        background = android.graphics.drawable.StateListDrawable().apply {
            addState(intArrayOf(android.R.attr.state_selected), GradientDrawable().apply { setColor(CYLTagEditorStyle.green); cornerRadius = 8 * d })
            addState(intArrayOf(), GradientDrawable().apply { setColor(CYLGray6); cornerRadius = 8 * d })
        }
        setTextColor(android.content.res.ColorStateList(arrayOf(intArrayOf(android.R.attr.state_selected), intArrayOf()), intArrayOf(Color.WHITE, Color.BLACK)))
    }
}

/**
 * `CYLTagEditorViewController.tagStyle()` and the example's colors.
 */
object CYLTagEditorStyle {
    val green: Int = Color.rgb(7, 193, 96)
    val linkColor: Int = Color.rgb(87, 107, 149)

    fun tagStyle(): CYLMenuStyle {
        val style = CYLMenuStyle()
        val font = CYLFont.systemFont(16f)
        for (state in listOf(CYLControlState.NORMAL, CYLControlState.SELECTED, CYLControlState.DISABLED)) {
            val appearance = style.appearanceForState(state)
            appearance.font = font
            appearance.cornerRadius = 6f
            appearance.borderWidth = 0f
            appearance.margin = 14f
        }
        style.normalAppearance.backgroundColor = CYLGray6
        style.normalAppearance.textColor = Color.BLACK
        style.selectedAppearance.backgroundColor = Color.argb(26, 7, 193, 96)
        style.selectedAppearance.textColor = green
        style.itemHeight = 36f
        style.interitemSpacing = 12f
        style.lineSpacing = 12f
        style.sectionInsets = CYLEdgeInsets(4f, 16f, 20f, 16f)
        style.headerHeight = 40f
        style.headerFont = CYLFont.systemFont(15f)
        style.headerTextColor = CYLLabelSecondary
        style.headerHorizontalInset = 16f
        style.backgroundColor = Color.WHITE
        style.imageSize = CYLSize(14f, 14f)
        style.imageTitleSpacing = 6f
        return style
    }
}

/**
 * `CYLRemarkViewController`: "Edit remarks": a name field and the chosen tags ("Tags >" opens the editor).
 */
class CYLRemarkView(context: Context, val store: CYLTagStore, tags: List<String>) : ScrollView(context), CYLMenuDataSource, CYLMenuDelegate {
    var tags: List<String> = tags.filter(store::contains)
        private set
    val tagsView = CYLTagListView(context)
    private val d = context.resources.displayMetrics.density

    init {
        val column = LinearLayout(context).apply { orientation = LinearLayout.VERTICAL }
        val title = TextView(context).apply {
            text = CYLTagEditorLocalizedString(context, "编辑备注")
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 28f)
            typeface = Typeface.DEFAULT_BOLD
            gravity = Gravity.CENTER
            setTextColor(Color.BLACK)
            ViewCompat.setAccessibilityHeading(this, true)
        }
        val name = EditText(context).apply {
            hint = CYLTagEditorLocalizedString(context, "备注名")
            contentDescription = hint
            background = GradientDrawable().apply { setColor(CYLGray6); cornerRadius = 8 * d }
            setPadding((12 * d).toInt(), 0, (12 * d).toInt(), 0)
            setSingleLine()
        }
        tagsView.title = CYLTagEditorLocalizedString(context, "标签")
        tagsView.titleImage = CYLSymbolDrawable("chevron.right", 12f, d)
        val titleStyle = CYLTagListView.defaultTitleStyle()
        for (state in listOf(CYLControlState.NORMAL, CYLControlState.SELECTED, CYLControlState.DISABLED)) {
            titleStyle.appearanceForState(state).font = CYLFont.systemFont(15f)
            titleStyle.appearanceForState(state).textColor = CYLLabelSecondary
            titleStyle.setIconColor(CYLLabelTertiary, state)
        }
        titleStyle.imagePlacement = CYLTagImagePlacement.CYLTagImagePlacementTrailing
        titleStyle.imageSize = CYLSize(12f, 12f)
        titleStyle.imageTitleSpacing = 4f
        tagsView.titleStyle = titleStyle
        tagsView.titleView.setOnClickListener { editTags() }
        tagsView.titleView.isClickable = true
        tagsView.style = CYLTagEditorStyle.tagStyle()
        tagsView.selectionMode = CYLMenuSelectionMode.CYLMenuSelectionModeNone
        tagsView.showsSectionHeaders = false
        tagsView.isScrollEnabled = false
        tagsView.menuDataSource = this
        tagsView.menuDelegate = this
        column.addView(title, LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT).apply { topMargin = (48 * d).toInt() })
        column.addView(name, LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, (48 * d).toInt()).apply { topMargin = (36 * d).toInt(); leftMargin = (16 * d).toInt(); rightMargin = (16 * d).toInt() })
        column.addView(tagsView, LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT).apply { topMargin = (12 * d).toInt() })
        addView(column)
        tagsView.reloadMenuData()
    }

    /**
     * `-editTags:`: the editor as a sheet over 78 % of the screen.
     */
    fun editTags(): CYLTagEditorView {
        val dialog = Dialog(context)
        val editor = CYLTagEditorView(context, store, tags)
        editor.onDone = { updateTags(it); dialog.dismiss() }
        editor.onCancel = { dialog.dismiss() }
        dialog.requestWindowFeature(Window.FEATURE_NO_TITLE)
        dialog.setContentView(editor)
        dialog.window?.let { window ->
            window.setGravity(Gravity.BOTTOM)
            window.setBackgroundDrawable(GradientDrawable().apply { setColor(Color.WHITE); cornerRadii = floatArrayOf(16 * d, 16 * d, 16 * d, 16 * d, 0f, 0f, 0f, 0f) })
            window.setLayout(WindowManager.LayoutParams.MATCH_PARENT, (resources.displayMetrics.heightPixels * 0.78f).toInt())
            window.setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_ADJUST_RESIZE)
        }
        dialog.show()
        return editor
    }

    fun updateTags(tags: List<String>) {
        this.tags = tags
        tagsView.reloadMenuData()
    }

    override fun numberOfSectionsInMenu() = 1
    override fun menuNumberOfItemsInSection(section: Int) = maxOf(tags.size, 1)
    override fun menuTitleForSection(section: Int) = CYLTagEditorLocalizedString(context, "标签")
    override fun menuTitleForItemAtIndexPath(indexPath: CYLIndexPath) = if (tags.isEmpty()) CYLTagEditorLocalizedString(context, "添加标签") else tags[indexPath.item]
    override fun menuImageForItemAtIndexPath(indexPath: CYLIndexPath) = if (tags.isEmpty()) CYLSymbolDrawable("plus", 14f, d) else null
    override fun menuDidSelectItemAtIndexPath(menu: Any, indexPath: CYLIndexPath) { editTags() }
}

/**
 * `CYLTagEditorViewController`: Cancel / title / Done, a search field, and the tags: recent, mine (with Manage and
 * "+ New tag") or the search results (with "+ New tag "…""); several can be chosen; Manage deletes.
 */
class CYLTagEditorView(context: Context, val store: CYLTagStore, selected: List<String>) : LinearLayout(context), CYLMenuDataSource, CYLMenuDelegate {
    sealed class Item {
        data class Tag(val tag: String) : Item()
        data class Create(val name: String?) : Item()
    }

    enum class SectionKind { RECENT, MINE, RESULTS }

    data class Section(val kind: SectionKind, val title: String, val items: List<Item>)

    val initialSelection = selected.filter(store::contains)
    var selectedTags: MutableList<String> = initialSelection.toMutableList()
        private set
    var query = ""
        private set
    var isManaging = false
        private set
    var sections: List<Section> = emptyList()
        private set
    var onDone: ((List<String>) -> Unit)? = null
    var onCancel: (() -> Unit)? = null

    private val d = context.resources.displayMetrics.density
    val tagListView = CYLTagListView(context)
    val searchField = EditText(context)
    val doneButton = Button(context)
    val manageButton = Button(context).apply {
        isAllCaps = false
        background = null
        stateListAnimator = null
        setTextSize(TypedValue.COMPLEX_UNIT_SP, 15f)
        setTextColor(CYLTagEditorStyle.linkColor)
        setPadding(0, 0, 0, 0)
        minWidth = 0
        minimumWidth = 0
        minHeight = 0
        minimumHeight = 0
        setOnClickListener { toggleManaging() }
    }

    init {
        orientation = VERTICAL
        val cancel = Button(context).apply {
            text = CYLTagEditorLocalizedString(context, "取消")
            isAllCaps = false
            background = null
            setTextColor(Color.BLACK)
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 17f)
            setOnClickListener { onCancel?.invoke() }
        }
        val title = TextView(context).apply {
            text = CYLTagEditorLocalizedString(context, "编辑标签")
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 17f)
            typeface = Typeface.DEFAULT_BOLD
            gravity = Gravity.CENTER
            setTextColor(Color.BLACK)
            ViewCompat.setAccessibilityHeading(this, true)
        }
        doneButton.apply {
            text = CYLTagEditorLocalizedString(context, "完成")
            isAllCaps = false
            stateListAnimator = null
            minWidth = (56 * d).toInt()
            minimumWidth = (56 * d).toInt()
            minHeight = 0
            minimumHeight = 0
            setPadding((12 * d).toInt(), 0, (12 * d).toInt(), 0)
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 17f)
            typeface = Typeface.DEFAULT_BOLD
            setOnClickListener { done() }
        }
        val bar = LinearLayout(context).apply {
            gravity = Gravity.CENTER_VERTICAL
            setPadding((8 * d).toInt(), (16 * d).toInt(), (20 * d).toInt(), 0)
            addView(cancel)
            addView(title, LayoutParams(0, LayoutParams.WRAP_CONTENT, 1f))
            addView(doneButton, LayoutParams(LayoutParams.WRAP_CONTENT, (32 * d).toInt()))
        }
        searchField.apply {
            hint = CYLTagEditorLocalizedString(context, "搜索")
            contentDescription = CYLTagEditorLocalizedString(context, "搜索标签")
            background = GradientDrawable().apply { setColor(CYLGray6); cornerRadius = 10 * d }
            setPadding((12 * d).toInt(), 0, (12 * d).toInt(), 0)
            setSingleLine()
            imeOptions = EditorInfo.IME_ACTION_SEARCH
            addTextChangedListener(object : TextWatcher {
                override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {}
                override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {}
                override fun afterTextChanged(s: Editable?) {
                    val next = CYLTagStore.normalizedName(s?.toString().orEmpty())
                    if (next != query) { query = next; reload() }
                }
            })
            setOnEditorActionListener { _, _, _ -> if (store.canCreate(query)) createTag(query); true }
        }
        tagListView.style = CYLTagEditorStyle.tagStyle()
        tagListView.selectionMode = CYLMenuSelectionMode.CYLMenuSelectionModeMultiple
        tagListView.allowsEmptySelection = true
        tagListView.menuDataSource = this
        tagListView.menuDelegate = this
        addView(bar)
        addView(searchField, LayoutParams(LayoutParams.MATCH_PARENT, (44 * d).toInt()).apply { topMargin = (26 * d).toInt(); leftMargin = (16 * d).toInt(); rightMargin = (16 * d).toInt() })
        addView(tagListView, LayoutParams(LayoutParams.MATCH_PARENT, 0, 1f).apply { topMargin = (12 * d).toInt() })
        reload()
    }

    fun makeSections(): List<Section> {
        if (query.isNotEmpty()) {
            val items = store.tagsMatching(query).map<String, Item> { Item.Tag(it) }.toMutableList()
            if (store.canCreate(query)) items.add(Item.Create(CYLTagStore.normalizedName(query)))
            return listOf(Section(SectionKind.RESULTS, CYLTagEditorLocalizedString(context, "搜索结果"), items))
        }
        val result = ArrayList<Section>()
        if (store.recentTags.isNotEmpty()) result.add(Section(SectionKind.RECENT, CYLTagEditorLocalizedString(context, "最近使用"), store.recentTags.map { Item.Tag(it) }))
        result.add(Section(SectionKind.MINE, CYLTagEditorLocalizedString(context, "我的标签"), store.tags.map<String, Item> { Item.Tag(it) } + Item.Create(null)))
        return result
    }

    fun reload() {
        sections = makeSections()
        manageButton.text = CYLTagEditorLocalizedString(context, if (isManaging) "退出管理" else "管理")
        manageButton.contentDescription = "${manageButton.text}, ${CYLTagEditorLocalizedString(context, if (isManaging) "轻点两下完成管理" else "轻点两下选择或删除标签")}"
        tagListView.reloadMenuData()
        syncSelection()
        updateDoneButton()
    }

    fun syncSelection() {
        tagListView.selectedIndexPaths = sections.flatMapIndexed { section, content ->
            content.items.mapIndexedNotNull { item, element -> if (element is Item.Tag && element.tag in selectedTags) CYLIndexPath(item, section) else null }
        }
    }

    val isDoneEnabled: Boolean get() = query.isEmpty() && (selectedTags.isNotEmpty() || selectedTags.toSet() != initialSelection.toSet())

    fun updateDoneButton() {
        doneButton.isEnabled = isDoneEnabled
        doneButton.background = GradientDrawable().apply { setColor(if (isDoneEnabled) CYLTagEditorStyle.green else Color.argb(41, 120, 120, 128)); cornerRadius = 4 * d }
        doneButton.setTextColor(if (isDoneEnabled) Color.WHITE else CYLLabelTertiary)
    }

    fun select(tag: String) {
        if (tag !in selectedTags) selectedTags.add(tag)
        syncSelection()
        updateDoneButton()
    }

    fun deselect(tag: String) {
        selectedTags.remove(tag)
        syncSelection()
        updateDoneButton()
    }

    fun createTag(name: String): String? {
        val tag = store.createTag(name) ?: return null
        if (tag !in selectedTags) selectedTags.add(tag)
        searchField.setText("")
        query = ""
        reload()
        announceForAccessibility(CYLTagEditorLocalizedString(context, "已新建标签：%@", tag))
        return tag
    }

    fun promptForNewTag() {
        val field = EditText(context).apply { hint = CYLTagEditorLocalizedString(context, "标签名称"); setSingleLine() }
        AlertDialog.Builder(context)
            .setTitle(CYLTagEditorLocalizedString(context, "新建标签"))
            .setView(FrameLayout(context).apply { setPadding((20 * d).toInt(), 0, (20 * d).toInt(), 0); addView(field) })
            .setNegativeButton(CYLTagEditorLocalizedString(context, "取消"), null)
            .setPositiveButton(CYLTagEditorLocalizedString(context, "确定")) { _, _ -> createTag(field.text.toString()) }
            .show()
    }

    fun toggleManaging() {
        isManaging = !isManaging
        reload()
    }

    fun confirmDeleting(tag: String) {
        AlertDialog.Builder(context)
            .setTitle(CYLTagEditorLocalizedString(context, "删除标签「%@」？", tag))
            .setNegativeButton(CYLTagEditorLocalizedString(context, "取消"), null)
            .setPositiveButton(CYLTagEditorLocalizedString(context, "删除")) { _, _ -> deleteTag(tag) }
            .show()
    }

    fun deleteTag(tag: String) {
        store.deleteTag(tag)
        selectedTags.remove(tag)
        reload()
    }

    fun done() {
        if (!isDoneEnabled) return
        store.markUsed(selectedTags)
        onDone?.invoke(selectedTags.toList())
    }

    private fun item(indexPath: CYLIndexPath) = sections[indexPath.section].items[indexPath.item]

    override fun numberOfSectionsInMenu() = sections.size
    override fun menuNumberOfItemsInSection(section: Int) = sections[section].items.size
    override fun menuTitleForSection(section: Int) = sections[section].title
    override fun menuTitleForItemAtIndexPath(indexPath: CYLIndexPath) = when (val element = item(indexPath)) {
        is Item.Tag -> element.tag
        is Item.Create -> element.name.orEmpty()
    }
    override fun menuItemTypeAtIndexPath(indexPath: CYLIndexPath) = if (item(indexPath) is Item.Create) CYLMenuItemType.CYLMenuItemTypeCreate else CYLMenuItemType.CYLMenuItemTypeTag
    override fun menuItemIsSelectableAtIndexPath(indexPath: CYLIndexPath) = !isManaging
    override fun menuAccessibilityHintForItemAtIndexPath(indexPath: CYLIndexPath): String? =
        if (isManaging && sections[indexPath.section].kind == SectionKind.MINE && item(indexPath) is Item.Tag) CYLTagEditorLocalizedString(context, "轻点两下删除此标签") else null
    override fun menuAccessoryViewForSection(section: Int): View? = if (sections[section].kind == SectionKind.MINE) manageButton else null

    override fun menuDidSelectItemAtIndexPath(menu: Any, indexPath: CYLIndexPath) {
        val element = item(indexPath) as? Item.Tag ?: return
        if (isManaging) confirmDeleting(element.tag) else select(element.tag)
    }

    override fun menuDidRequestNewItemWithName(menu: Any, name: String, atIndexPath: CYLIndexPath) {
        if (name.isEmpty()) promptForNewTag() else createTag(name)
    }

    override fun menuDidDeselectItemAtIndexPath(menu: Any, indexPath: CYLIndexPath) {
        (item(indexPath) as? Item.Tag)?.let { deselect(it.tag) }
    }
}

/**
 * `CYLFoldStylesViewController`: every fold control and title style on the same tags, then the lists made from the
 * configuration files (`fold-styles.json`, `.plist`; `.yaml` and `.xml` need CYLTabBarController's parser, as on iOS
 * without it, and show their error).
 */
class CYLFoldStylesView(context: Context, val data: CYLTagData) : ScrollView(context) {
    data class Demo(val title: String?, val foldControl: CYLMenuFoldControl, val titlePosition: CYLMenuTitlePosition = CYLMenuTitlePosition.CYLMenuTitlePositionTopLeading,
                    val titleImage: String? = null, val titleColor: Int? = null, val titleImageTrailing: Boolean = false,
                    val showsSectionHeaders: Boolean = true, val groups: List<Int>)

    private class Source(val sections: List<CYLTagEditorGroup>) : CYLMenuDataSource {
        override fun numberOfSectionsInMenu() = sections.size
        override fun menuNumberOfItemsInSection(section: Int) = sections[section].tags.size
        override fun menuTitleForSection(section: Int) = sections[section].title
        override fun menuTitleForItemAtIndexPath(indexPath: CYLIndexPath) = sections[indexPath.section].tags[indexPath.item]
    }

    val tagListViews = ArrayList<CYLTagListView>()
    val configurationErrors = LinkedHashMap<String, Exception>()
    private val sources = ArrayList<Source>()
    private val stack = LinearLayout(context).apply { orientation = LinearLayout.VERTICAL }
    private val d = context.resources.displayMetrics.density

    companion object {
        val configurationFiles = listOf("fold-styles.json", "fold-styles.plist", "fold-styles.yaml", "fold-styles.xml")
        private fun fold(position: CYLMenuFoldControlPosition, content: CYLMenuFoldControlContent) = CYLMenuFoldControl.foldControlWithPosition(position, content)
    }

    fun demos(): List<Demo> {
        fun s(key: String) = CYLTagEditorLocalizedString(context, key)
        val bottom = CYLMenuFoldControlPosition.FOOTER
        val trailing = CYLMenuFoldControlPosition.HEADER_TRAILING
        val leading = CYLMenuFoldControlPosition.HEADER_LEADING
        val icon = CYLMenuFoldControlContent.CYLMenuFoldControlContentIcon
        val both = CYLMenuFoldControlContent.CYLMenuFoldControlContentIconAndTitle
        val text = CYLMenuFoldControlContent.CYLMenuFoldControlContentTitle
        val center = CYLMenuTitlePosition.CYLMenuTitlePositionTopCenter
        return listOf(
            Demo(s("底部箭头（淘宝评价筛选）"), fold(bottom, icon), titleImage = "star.bubble", showsSectionHeaders = false, groups = listOf(0)),
            Demo(s("底部：文字 + 箭头"), fold(bottom, both), titleImage = "briefcase", showsSectionHeaders = false, groups = listOf(2)),
            Demo(s("底部：仅文字"), fold(bottom, text), titleImage = "heart", showsSectionHeaders = false, groups = listOf(3)),
            Demo(s("右上角：文字 + 箭头（原分类菜单）"), fold(trailing, both), titleImage = "square.grid.2x2", groups = listOf(0, 2)),
            Demo(s("右上角：仅箭头"), fold(trailing, icon), titleImage = "chevron.down.square", groups = listOf(1, 3)),
            Demo(s("左上角：文字 + 箭头"), fold(leading, both), titleImage = "arrow.left.square", groups = listOf(2, 4)),
            Demo(s("标题居中，右上角仅文字"), fold(trailing, text), titlePosition = center, titleImage = "text.aligncenter", groups = listOf(5, 0)),
            Demo(s("标题：图标 + 文字（左上角）"), fold(bottom, icon), titleImage = "tag", showsSectionHeaders = false, groups = listOf(1)),
            Demo(null, fold(bottom, icon), titleImage = "person.2", showsSectionHeaders = false, groups = listOf(0)),
            Demo(s("标题：仅文字（居中）"), fold(bottom, both), titlePosition = center, showsSectionHeaders = false, groups = listOf(4)),
            Demo(s("标题：图标 + 文字（居中、绿色）"), fold(bottom, icon), titlePosition = center, titleImage = "leaf", titleColor = CYLTagEditorStyle.green, showsSectionHeaders = false, groups = listOf(3)),
            Demo(s("标题：文字 + 图标（图标在后）"), fold(bottom, icon), titleImage = "chevron.right", titleImageTrailing = true, showsSectionHeaders = false, groups = listOf(5)),
        )
    }

    private fun titleStyle(demo: Demo): CYLMenuStyle {
        val style = CYLTagListView.defaultTitleStyle()
        demo.titleColor?.let { color ->
            for (state in listOf(CYLControlState.NORMAL, CYLControlState.SELECTED, CYLControlState.DISABLED)) {
                style.appearanceForState(state).textColor = color
                style.setIconColor(color, state)
            }
        }
        if (demo.titleImageTrailing) {
            style.imagePlacement = CYLTagImagePlacement.CYLTagImagePlacementTrailing
            style.imageSize = CYLSize(14f, 14f)
        }
        return style
    }

    init {
        setBackgroundColor(CYLGray6)
        stack.setPadding(0, (12 * d).toInt(), 0, (12 * d).toInt())
        addView(stack)
        val groups = data.groups ?: listOf(CYLTagEditorGroup(CYLTagEditorLocalizedString(context, "我的标签"), data.tags))
        for (demo in demos()) {
            val image = demo.titleImage?.let { CYLSymbolDrawable(it, 18f, d) }
            val list = CYLTagListView(context, demo.foldControl, demo.title, image, demo.titlePosition)
            if (demo.title == null) list.titleView.contentDescription = CYLTagEditorLocalizedString(context, "标题：仅图标")
            list.titleStyle = titleStyle(demo)
            list.style = CYLTagEditorStyle.tagStyle().also { it.backgroundColor = Color.WHITE }
            list.selectionMode = CYLMenuSelectionMode.CYLMenuSelectionModeMultiple
            list.defaultVisibleRows = 1
            list.isScrollEnabled = false
            list.showsSectionHeaders = demo.showsSectionHeaders
            val source = Source(demo.groups.mapNotNull { groups.getOrNull(it) })
            sources.add(source)
            list.menuDataSource = source
            add(list)
            list.reloadMenuData()
        }
        for (file in configurationFiles) {
            try {
                add(CYLTagListView.tagListViewWithConfigurationFile(context, CYLTagEditorLocalization.path(file)))
            } catch (e: Exception) {
                configurationErrors[file] = e
                stack.addView(TextView(context).apply {
                    text = "  $file: ${e.message}"
                    setTextColor(Color.RED)
                    setTextSize(TypedValue.COMPLEX_UNIT_SP, 13f)
                    setPadding((16 * d).toInt(), (4 * d).toInt(), (16 * d).toInt(), (4 * d).toInt())
                })
            }
        }
    }

    private fun add(list: CYLTagListView) {
        list.containerCornerRadius = 10f
        tagListViews.add(list)
        stack.addView(list, LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT).apply {
            leftMargin = (16 * d).toInt(); rightMargin = (16 * d).toInt(); bottomMargin = (12 * d).toInt()
        })
    }

    /**
     * Expands every list that folds (for screenshots and tests).
     */
    fun expandAll() {
        for (list in tagListViews) if (list.canFoldSection(0)) list.setExpanded(true, 0, false)
    }
}
