package com.cyl.classifymenu.example.classify

import android.content.Context
import android.graphics.Color
import android.text.SpannableStringBuilder
import android.text.Spanned
import android.text.style.ForegroundColorSpan
import android.text.style.RelativeSizeSpan
import android.util.TypedValue
import android.view.View
import android.widget.LinearLayout
import android.widget.TextView
import com.cyl.classifymenu.example.R

/**
 * The results of a query on the local `places` table, as the iOS menu linkage shows them: the conditions, the SQL
 * statement and the number of rows, then one row per place (name; category · tag · region · rating · price).
 */
class ClassifyResultsView(context: Context) : LinearLayout(context) {
    private fun dp(value: Float) = (value * resources.displayMetrics.density).toInt()

    private val statusLabel = TextView(context).apply {
        setTextSize(TypedValue.COMPLEX_UNIT_SP, 13f)
        setTextColor(Color.argb(153, 60, 60, 67))
    }
    private val rows = LinearLayout(context).apply {
        orientation = VERTICAL
        setBackgroundColor(Color.argb(73, 60, 60, 67))
    }

    init {
        orientation = VERTICAL
        setBackgroundColor(Color.rgb(242, 242, 247))
        setPadding(dp(16f), dp(10f), dp(16f), dp(16f))
        addView(statusLabel)
        addView(rows, LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT).apply { topMargin = dp(8f) })
    }

    /**
     * The status text (for tests).
     */
    val status: CharSequence get() = statusLabel.text

    /**
     * Shows `results` of `query` for the conditions (empty lists and a null tag read "All").
     */
    fun show(tag: String?, regions: List<String>, dishes: List<String>, query: ClassifySQLQuery, results: List<Map<String, Any>>, total: Int) {
        val all = CYLDemoLocalizedString(context, R.string.classify_all)
        val separator = CYLDemoLocalizedString(context, R.string.classify_separator)
        fun names(values: List<String>) = if (values.isEmpty()) all else values.joinToString(separator) { ClassifyDemoDataSource.shortTitle(it) }
        statusLabel.text = listOf(
            context.getString(R.string.classify_conditions, tag?.let { ClassifyDemoDataSource.shortTitle(it) } ?: all, names(regions), names(dishes)),
            query.displayString(),
            context.getString(R.string.classify_sqlite_count, results.size, total),
        ).joinToString("\n")
        rows.removeAllViews()
        if (results.isEmpty()) rows.addView(row(CYLDemoLocalizedString(context, R.string.classify_no_places), null))
        for (place in results) {
            val detail = String.format(java.util.Locale.ROOT, "%s · %s · %s · ★%.1f · ¥%d", place["category"],
                ClassifyDemoDataSource.shortTitle(place["tag"] as String), ClassifyDemoDataSource.shortTitle(place["region"] as String),
                place["rating"] as Double, place["price"] as Int)
            rows.addView(row(place["name"] as String, detail))
        }
    }

    private fun row(title: String, detail: String?): View {
        val text = SpannableStringBuilder(title)
        if (detail != null) {
            val start = text.length + 1
            text.append("\n").append(detail)
            text.setSpan(RelativeSizeSpan(0.8f), start, text.length, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE)
            text.setSpan(ForegroundColorSpan(Color.argb(153, 60, 60, 67)), start, text.length, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE)
        }
        return TextView(context).apply {
            this.text = text
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 16f)
            setTextColor(Color.BLACK)
            setBackgroundColor(Color.WHITE)
            setPadding(dp(12f), dp(8f), dp(12f), dp(8f))
            importantForAccessibility = IMPORTANT_FOR_ACCESSIBILITY_YES
            layoutParams = LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT).apply { bottomMargin = 1 }
        }
    }
}

/**
 * The tint-colored bar of the demo pages (the iOS navigation bar): an optional leading button, the title, an optional
 * trailing text button.
 */
internal fun classifyNavigationBar(context: Context, leading: View?, title: TextView, trailing: View?): View {
    val d = context.resources.displayMetrics.density
    return LinearLayout(context).apply {
        orientation = LinearLayout.HORIZONTAL
        gravity = android.view.Gravity.CENTER_VERTICAL
        setBackgroundColor(com.cyl.classifymenu.CYLAppTintColor)
        setPadding((4 * d).toInt(), 0, (8 * d).toInt(), 0)
        title.gravity = android.view.Gravity.CENTER
        title.setTextSize(TypedValue.COMPLEX_UNIT_SP, 17f)
        title.typeface = android.graphics.Typeface.DEFAULT_BOLD
        title.setTextColor(Color.WHITE)
        title.maxLines = 1
        title.ellipsize = android.text.TextUtils.TruncateAt.END
        androidx.core.view.ViewCompat.setAccessibilityHeading(title, true)
        val side = (44 * d).toInt()
        addView(leading ?: View(context), LinearLayout.LayoutParams(side, side))
        addView(title, LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.MATCH_PARENT, 1f))
        if (trailing != null) addView(trailing, LinearLayout.LayoutParams(LinearLayout.LayoutParams.WRAP_CONTENT, LinearLayout.LayoutParams.MATCH_PARENT))
        else addView(View(context), LinearLayout.LayoutParams(side, side))
    }
}
