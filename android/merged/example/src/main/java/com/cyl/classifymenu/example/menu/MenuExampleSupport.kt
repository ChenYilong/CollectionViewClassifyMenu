package com.cyl.classifymenu.example.menu

import android.content.Context
import android.graphics.Color
import android.graphics.Typeface
import android.graphics.drawable.Drawable
import android.net.Uri
import android.util.TypedValue
import android.view.Gravity
import android.view.View
import android.widget.FrameLayout
import android.widget.ImageButton
import android.widget.LinearLayout
import android.widget.TextView
import androidx.core.view.ViewCompat
import com.cyl.classifymenu.CYLAppTintColor
import com.cyl.classifymenu.CYLIndexPath
import com.cyl.classifymenu.CYLMenuDataSource
import java.util.Locale

/**
 * The menu example's resources: its iOS bundle (`Example/CYLMenuExample/CYLMenuExample.bundle`), synced into the app's
 * assets as `CYLMenuExample.bundle/…` (strings, search data, configurations, animations).
 */
object CYLExampleLocalization {
    const val BUNDLE = "CYLMenuExample.bundle"
    private val tables = HashMap<String, Map<String, String>>()

    fun language(): String {
        val locale = Locale.getDefault()
        if (locale.language != "zh") return "en"
        return if (locale.script == "Hant" || locale.country in setOf("TW", "HK", "MO")) "zh-Hant" else "zh-Hans"
    }

    /**
     * The asset path of a file of the current language.
     */
    fun localizedPath(file: String) = "$BUNDLE/${language()}.lproj/$file"

    /**
     * The asset path of a file of the bundle.
     */
    fun path(file: String) = "$BUNDLE/$file"

    fun table(context: Context): Map<String, String> = tables.getOrPut(language()) {
        val text = try {
            context.assets.open(localizedPath("Localizable.strings")).use { it.readBytes().toString(Charsets.UTF_8) }
        } catch (e: Exception) {
            ""
        }
        val entry = Regex("\"((?:[^\"\\\\]|\\\\.)*)\"\\s*=\\s*\"((?:[^\"\\\\]|\\\\.)*)\"\\s*;")
        entry.findAll(text.replace(Regex("/\\*.*?\\*/", RegexOption.DOT_MATCHES_ALL), "")).associate {
            it.groupValues[1].replace("\\\"", "\"") to it.groupValues[2].replace("\\\"", "\"").replace("\\n", "\n")
        }
    }
}

/**
 * `CYLExampleLocalizedString`: the menu example's lookup (its own bundle); `%@` and `%lu` / `%ld` take `arguments`.
 */
fun CYLExampleLocalizedString(context: Context, key: String, vararg arguments: Any): String {
    val format = CYLExampleLocalization.table(context)[key] ?: key
    if (arguments.isEmpty()) return format
    return String.format(format.replace("%@", "%s").replace("%lu", "%d").replace("%ld", "%d"), *arguments)
}

/**
 * `CYLExampleMenuItem`.
 */
class CYLExampleMenuItem(var title: String) {
    var image: Drawable? = null
    var selectedImage: Drawable? = null
    var animationURL: Uri? = null
    var isEnabled = true
    var isExclusive = false
    var value: Any? = null
}

/**
 * `CYLExampleMenuSection`.
 */
class CYLExampleMenuSection(var title: String, var items: List<CYLExampleMenuItem>) {
    var image: Drawable? = null
    var accessoryView: View? = null

    constructor(title: String, titles: List<String>, @Suppress("UNUSED_PARAMETER") fromTitles: Boolean) : this(title, titles.map { CYLExampleMenuItem(it) })
}

/**
 * `CYLExampleMenuSource`: sections of items, every optional data source method answered from them.
 */
class CYLExampleMenuSource(var sections: List<CYLExampleMenuSection>) : CYLMenuDataSource {
    fun item(indexPath: CYLIndexPath) = sections[indexPath.section].items[indexPath.item]
    override fun numberOfSectionsInMenu() = sections.size
    override fun menuNumberOfItemsInSection(section: Int) = sections[section].items.size
    override fun menuTitleForSection(section: Int) = sections[section].title
    override fun menuTitleForItemAtIndexPath(indexPath: CYLIndexPath) = item(indexPath).title
    override fun menuImageForItemAtIndexPath(indexPath: CYLIndexPath) = item(indexPath).image
    override fun menuSelectedImageForItemAtIndexPath(indexPath: CYLIndexPath) = item(indexPath).selectedImage
    override fun menuAnimationURLForItemAtIndexPath(indexPath: CYLIndexPath) = item(indexPath).animationURL
    override fun menuImageForSection(section: Int) = sections[section].image
    override fun menuAccessoryViewForSection(section: Int) = sections[section].accessoryView
    override fun menuItemIsEnabledAtIndexPath(indexPath: CYLIndexPath) = item(indexPath).isEnabled
    override fun menuItemIsExclusiveAtIndexPath(indexPath: CYLIndexPath) = item(indexPath).isExclusive
}

/**
 * A screen of the menu example (a view controller on iOS): its title and its view.
 */
interface CYLMenuScreen {
    val title: CharSequence
    val view: View

    /**
     * A view shown in the bar instead of the title (`navigationItem.titleView`), such as a search bar.
     */
    val titleView: View? get() = null

    /**
     * Whether the navigation bar is hidden while this screen is on top (`setNavigationBarHidden(_:animated:)`).
     */
    val hidesNavigationBar: Boolean get() = false
}

/**
 * The navigation controller of a part of the menu example: a bar (back button and title) over a stack of screens.
 */
class CYLMenuNavigator(context: Context) : LinearLayout(context) {
    private val stack = ArrayList<CYLMenuScreen>()
    private val d = context.resources.displayMetrics.density
    private val titleLabel = TextView(context).apply {
        gravity = Gravity.CENTER
        setTextSize(TypedValue.COMPLEX_UNIT_SP, 17f)
        typeface = Typeface.DEFAULT_BOLD
        setTextColor(Color.WHITE)
        maxLines = 1
        ellipsize = android.text.TextUtils.TruncateAt.END
        ViewCompat.setAccessibilityHeading(this, true)
    }
    private val back = ImageButton(context).apply {
        background = null
        setImageDrawable(com.cyl.classifymenu.example.tageditor.CYLSymbolDrawable("chevron.left", 22f, d).also { it.setTint(Color.WHITE) })
        contentDescription = context.getString(androidx.appcompat.R.string.abc_action_bar_up_description)
        setOnClickListener { pop() }
    }
    private val trailingSlot = FrameLayout(context)
    private val titleSlot = FrameLayout(context)
    private val content = FrameLayout(context)
    private val bar: LinearLayout

    init {
        orientation = VERTICAL
        bar = LinearLayout(context).apply {
            gravity = Gravity.CENTER_VERTICAL
            setBackgroundColor(CYLAppTintColor)
            addView(back, LayoutParams((44 * d).toInt(), (44 * d).toInt()))
            addView(FrameLayout(context).apply {
                addView(titleLabel, FrameLayout.LayoutParams(FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.MATCH_PARENT))
                addView(titleSlot, FrameLayout.LayoutParams(FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.MATCH_PARENT))
            }, LayoutParams(0, LayoutParams.MATCH_PARENT, 1f))
            addView(trailingSlot, LayoutParams((88 * d).toInt(), LayoutParams.MATCH_PARENT))
        }
        addView(bar, LayoutParams(LayoutParams.MATCH_PARENT, (48 * d).toInt()))
        addView(content, LayoutParams(LayoutParams.MATCH_PARENT, 0, 1f))
    }

    /**
     * Called after every push and pop.
     */
    var onDepthChanged: (() -> Unit)? = null

    val top: CYLMenuScreen? get() = stack.lastOrNull()
    val depth: Int get() = stack.size

    fun push(screen: CYLMenuScreen) {
        stack.add(screen)
        show()
    }

    fun pop(): Boolean {
        if (stack.size <= 1) return false
        stack.removeAt(stack.size - 1)
        show()
        return true
    }

    /**
     * Puts `view` at the trailing end of the bar (a bar button item), for the top screen.
     */
    fun setTrailing(view: View?) {
        trailingSlot.removeAllViews()
        view?.let { trailingSlot.addView(it, FrameLayout.LayoutParams(FrameLayout.LayoutParams.WRAP_CONTENT, FrameLayout.LayoutParams.MATCH_PARENT, Gravity.END)) }
        // Wide enough for its buttons, never narrower than the space that keeps the title centered.
        trailingSlot.layoutParams = trailingSlot.layoutParams?.apply { width = if (view == null) (88 * d).toInt() else LayoutParams.WRAP_CONTENT }
        trailingSlot.minimumWidth = (88 * d).toInt()
    }

    fun refreshTitle() {
        titleLabel.text = top?.title
    }

    private fun show() {
        content.removeAllViews()
        setTrailing(null)
        top?.let {
            (it.view.parent as? android.view.ViewGroup)?.removeView(it.view)
            content.addView(it.view)
        }
        titleLabel.text = top?.title
        titleSlot.removeAllViews()
        val titleView = top?.titleView
        titleView?.let {
            (it.parent as? android.view.ViewGroup)?.removeView(it)
            titleSlot.addView(it, FrameLayout.LayoutParams(FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.MATCH_PARENT))
        }
        titleLabel.visibility = if (titleView == null) View.VISIBLE else View.INVISIBLE
        trailingSlot.layoutParams = trailingSlot.layoutParams?.apply { width = if (titleView == null) (88 * d).toInt() else (12 * d).toInt() }
        trailingSlot.minimumWidth = if (titleView == null) (88 * d).toInt() else 0
        back.visibility = if (stack.size > 1) View.VISIBLE else View.INVISIBLE
        bar.visibility = if (top?.hidesNavigationBar == true) View.GONE else View.VISIBLE
        // Last, so the bar items a screen sets (setTrailing) are not reset above.
        (top as? CYLMenuScreenLifecycle)?.screenDidAppear(this)
        onDepthChanged?.invoke()
    }
}

/**
 * Called when a screen becomes the top one (`-viewWillAppear:`).
 */
interface CYLMenuScreenLifecycle {
    fun screenDidAppear(navigator: CYLMenuNavigator)
}
