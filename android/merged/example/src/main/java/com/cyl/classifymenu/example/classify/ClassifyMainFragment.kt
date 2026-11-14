package com.cyl.classifymenu.example.classify

import android.content.Context
import android.graphics.Color
import android.graphics.Typeface
import android.os.Bundle
import android.text.SpannableString
import android.text.Spanned
import android.text.style.ForegroundColorSpan
import android.util.TypedValue
import android.view.Gravity
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.LinearLayout
import android.widget.TextView
import androidx.annotation.StringRes
import androidx.appcompat.widget.SwitchCompat
import androidx.core.view.ViewCompat
import com.cyl.classifymenu.CYLClassifyMenuViewController
import com.cyl.classifymenu.CYLIndexPath
import com.cyl.classifymenu.CYLMenuDataSource
import com.cyl.classifymenu.CYLMenuDelegate
import com.cyl.classifymenu.example.R

/**
 * The Classify demo's string lookup (`CYLDemoLocalizedString`): the example's own resources, never the library's.
 */
fun CYLDemoLocalizedString(context: Context, @StringRes key: Int): String = context.getString(key)

/**
 * `CYLMainViewController`, its single-choice part (the Classify tab): the classify menu with a header (one or two
 * rows by default), the selected tag as the title, and, as the iOS example's menu linkage, the selected tag queried
 * on the local SQLite `places` table, with the results below the menu. The multiple-choice filter has its own tab
 * (`FilterDemoFragment`).
 */
class ClassifyMainFragment : CYLClassifyMenuViewController(), CYLMenuDelegate {

    var classifySource: CYLMenuDataSource? = null

    var titleLabel: TextView? = null
        private set
    var rowsCountBydefaultSwitch: SwitchCompat? = null
        private set
    private var navigationTitle: TextView? = null

    /**
     * The local database the selected tag queries.
     */
    var database: ClassifyPlacesDatabase? = null
        private set

    /**
     * The selected tag (null for every tag), the last query and its rows.
     */
    var selectedTag: String? = null
        private set
    var lastQuery: ClassifySQLQuery = ClassifyPlacesDatabase.query(null, emptyList(), emptyList())
        private set
    var results: List<Map<String, Any>> = emptyList()
        private set
    var resultsView: ClassifyResultsView? = null
        private set

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View {
        val context = inflater.context
        val classify = ClassifyDemoDataSource.classifyDataSource(context)
        classifySource = classify
        menuDataSource = classify
        menuDelegate = this
        menuHeaderView = makeDemoHeaderView(context)
        val results = ClassifyResultsView(context)
        resultsView = results
        menuFooterView = results
        database = ClassifyPlacesDatabase(context)
        val menu = super.onCreateView(inflater, container, savedInstanceState)
        val title = TextView(context).apply { text = menuTitle }
        navigationTitle = title
        val column = LinearLayout(context).apply { orientation = LinearLayout.VERTICAL }
        column.addView(classifyNavigationBar(context, null, title, null), LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, dp(context, 48f)))
        column.addView(menu, LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, 0, 1f))
        runQuery()
        return column
    }

    override fun onDestroyView() {
        database?.close()
        super.onDestroyView()
    }

    private fun dp(context: Context, value: Float) = (value * context.resources.displayMetrics.density).toInt()

    /**
     * `-makeDemoHeaderView`: the title (with "one row" / "two rows" in red), the switch, the hint and the subtitle.
     */
    private fun makeDemoHeaderView(context: Context): View {
        val header = LinearLayout(context).apply {
            orientation = LinearLayout.VERTICAL
            setBackgroundColor(Color.WHITE)
            setPadding(dp(context, 16f), dp(context, 20f), dp(context, 16f), dp(context, 12f))
        }
        val row = LinearLayout(context).apply { gravity = Gravity.CENTER_VERTICAL }
        val title = TextView(context).apply {
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 18f)
            typeface = Typeface.DEFAULT_BOLD
            setTextColor(Color.rgb(42, 185, 160))
            ViewCompat.setAccessibilityHeading(this, true)
        }
        titleLabel = title
        val toggle = SwitchCompat(context).apply {
            contentDescription = CYLDemoLocalizedString(context, R.string.classify_show_two_rows)
            setOnCheckedChangeListener { _, _ -> rowsCountBydefaultSwitchClicked(this) }
        }
        rowsCountBydefaultSwitch = toggle
        row.addView(title, LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.WRAP_CONTENT, 1f))
        row.addView(toggle)
        fun small(@StringRes text: Int) = TextView(context).apply {
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 12f)
            setTextColor(Color.argb(153, 60, 60, 67))
            setText(text)
        }
        header.addView(row)
        header.addView(small(R.string.classify_tag_hint), LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT).apply { topMargin = dp(context, 4f) })
        header.addView(small(R.string.classify_subtitle), LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT).apply { topMargin = dp(context, 8f) })
        rowsCountBydefaultSwitchClicked(toggle)
        return header
    }

    /**
     * `-rowsCountBydefaultSwitchClicked:`.
     */
    fun rowsCountBydefaultSwitchClicked(sender: SwitchCompat) {
        val context = sender.context
        defaultVisibleRows = if (sender.isChecked) 2 else 1
        val title = CYLDemoLocalizedString(context, if (sender.isChecked) R.string.classify_title_two_rows else R.string.classify_title_one_row)
        val highlight = CYLDemoLocalizedString(context, if (sender.isChecked) R.string.classify_two_rows else R.string.classify_one_row)
        val text = SpannableString(title)
        val start = title.indexOf(highlight)
        if (start >= 0) text.setSpan(ForegroundColorSpan(Color.RED), start, start + highlight.length, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE)
        titleLabel?.text = text
    }

    /**
     * As a tap on the classify menu: selects the tag, or clears it when it is already selected.
     */
    fun selectClassifyItem(indexPath: CYLIndexPath) {
        val deselect = selectedIndexPath == indexPath
        selectedIndexPath = if (deselect) null else indexPath
        selectedTag = if (deselect) null else classifySource?.menuTitleForItemAtIndexPath(indexPath)
        navigationTitle?.text = selectedTag ?: menuTitle
        runQuery()
    }

    private fun runQuery() {
        val database = database ?: return
        val query = ClassifyPlacesDatabase.query(selectedTag, emptyList(), emptyList())
        lastQuery = query
        results = try { database.rows(query) } catch (e: Exception) { emptyList() }
        resultsView?.show(selectedTag, emptyList(), emptyList(), query, results, database.countOfTable("places"))
        updateMenuLayout()
    }

    override fun menuDidSelectItemAtIndexPath(menu: Any, indexPath: CYLIndexPath) {
        if (menu === this) selectClassifyItem(indexPath)
    }

    /**
     * The title shown in the navigation bar (for tests).
     */
    val shownTitle: CharSequence? get() = navigationTitle?.text
}
