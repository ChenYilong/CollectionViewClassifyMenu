package com.cyl.classifymenu.example.menu

import android.content.Context
import android.graphics.Color
import android.os.Bundle
import android.util.TypedValue
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.LinearLayout
import android.widget.ScrollView
import android.widget.TextView
import androidx.activity.OnBackPressedCallback
import androidx.fragment.app.Fragment
import com.cyl.classifymenu.example.tageditor.CYLSymbolDrawable

/**
 * The menu example (`Example/CYLMenuExample`) as one tab: a home list with one row per part of the iOS example's tab
 * bar (scenario 1, scenario 2, styles, animations); a row opens that part in the tab's own navigation stack.
 */
class MenuFragment : Fragment() {
    lateinit var navigator: CYLMenuNavigator
        private set

    private val back = object : OnBackPressedCallback(false) {
        override fun handleOnBackPressed() {
            navigator.pop()
            isEnabled = navigator.depth > 1
        }
    }

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View {
        val context = requireContext()
        navigator = CYLMenuNavigator(context)
        navigator.push(CYLMenuHomeScreen(context, navigator) { back.isEnabled = navigator.depth > 1 })
        // A pushed screen hides the app's tab bar, as hidesBottomBarWhenPushed does on iOS; it comes back at the root.
        navigator.onDepthChanged = {
            back.isEnabled = navigator.depth > 1
            (activity as? com.cyl.classifymenu.example.MainActivity)?.tabBarController?.setTabBarHidden(navigator.depth > 1, true)
        }
        requireActivity().onBackPressedDispatcher.addCallback(viewLifecycleOwner, back)
        return navigator
    }
}

/**
 * The home list of the menu tab: the parts of the iOS example, in its tab bar's order.
 */
class CYLMenuHomeScreen(context: Context, navigator: CYLMenuNavigator, onOpen: () -> Unit) : CYLMenuScreen {
    override val title: CharSequence = context.getString(com.cyl.classifymenu.example.R.string.menu_title)
    override val view: View

    init {
        val d = context.resources.displayMetrics.density
        val parts = listOf<Pair<String, (() -> CYLMenuScreen)?>>(
            "场景一：评价筛选" to { CYLProductScreen(context, navigator) },
            "场景二：搜索分类" to { CYLSearchHomeScreen(context, navigator) },
            "样式" to null,
            "动效" to null,
        )
        val list = LinearLayout(context).apply { orientation = LinearLayout.VERTICAL; setBackgroundColor(Color.WHITE) }
        for ((key, make) in parts) {
            val row = LinearLayout(context).apply {
                gravity = android.view.Gravity.CENTER_VERTICAL
                setPadding((16 * d).toInt(), 0, (16 * d).toInt(), 0)
                minimumHeight = (52 * d).toInt()
                val label = TextView(context).apply {
                    text = CYLExampleLocalizedString(context, key)
                    setTextSize(TypedValue.COMPLEX_UNIT_SP, 17f)
                    setTextColor(if (make != null) Color.BLACK else Color.GRAY)
                }
                addView(label, LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.WRAP_CONTENT, 1f))
                addView(android.widget.ImageView(context).apply {
                    setImageDrawable(CYLSymbolDrawable("chevron.right", 14f, d).also { it.setTint(Color.rgb(196, 196, 199)) })
                    importantForAccessibility = View.IMPORTANT_FOR_ACCESSIBILITY_NO
                }, LinearLayout.LayoutParams((14 * d).toInt(), (14 * d).toInt()))
                isEnabled = make != null
                isClickable = true
                isFocusable = true
                contentDescription = label.text
                setBackgroundResource(TypedValue().also { context.theme.resolveAttribute(android.R.attr.selectableItemBackground, it, true) }.resourceId)
                setOnClickListener { make?.let { navigator.push(it()); onOpen() } }
            }
            list.addView(row)
            list.addView(View(context).apply { setBackgroundColor(Color.rgb(224, 224, 224)) }, LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, 1).apply { leftMargin = (16 * d).toInt() })
        }
        view = ScrollView(context).apply { setBackgroundColor(Color.rgb(242, 242, 247)); addView(list) }
    }
}
