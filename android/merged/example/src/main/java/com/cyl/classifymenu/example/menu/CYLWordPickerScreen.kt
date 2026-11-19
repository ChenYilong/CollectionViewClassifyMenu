package com.cyl.classifymenu.example.menu

import android.content.Context
import android.graphics.Color
import android.graphics.Typeface
import android.graphics.drawable.GradientDrawable
import android.text.InputType
import android.util.TypedValue
import android.view.Gravity
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import android.widget.EditText
import android.widget.LinearLayout
import android.widget.TextView
import com.cyl.classifymenu.CYLIndexPath
import com.cyl.classifymenu.CYLMenuDelegate
import com.cyl.classifymenu.CYLMenuSelectionMode
import com.cyl.classifymenu.CYLMenuStyle
import com.cyl.classifymenu.CYLTagListView
import com.cyl.classifymenu.cyl_accessibilityIdentifier
import com.google.android.material.bottomsheet.BottomSheetDialog

/**
 * `CYLWordPickerDemoViewController` (选词填入, as WeChat's friend verification): a remark field, the friend's message
 * and a "选词填入" link that opens a sheet where the message is one cell per character; smearing across cells selects
 * them, and "填入" (off until something is selected) puts the selected characters, in text order, into the field.
 */
class CYLWordPickerScreen(private val context: Context) : CYLMenuScreen {

    companion object {
        /** The friend's message (user content, not localized). */
        const val MESSAGE = "我是群聊\"LANEPRO TEAM A🚧\"的Sunny"  // NOLOCALIZE: a friend's message (user content)
        const val SENDER = "Sunny"
    }

    private val d = context.resources.displayMetrics.density

    override val title: CharSequence = CYLExampleLocalizedString(context, "选词填入")

    val remarkField = EditText(context).apply {
        hint = CYLExampleLocalizedString(context, "添加备注")
        setTextSize(TypedValue.COMPLEX_UNIT_SP, 20f)
        inputType = InputType.TYPE_CLASS_TEXT
        background = GradientDrawable().apply { setColor(Color.rgb(242, 242, 247)); cornerRadius = 10 * d }
        setPadding((16 * d).toInt(), 0, (16 * d).toInt(), 0)
        minHeight = (52 * d).toInt()
        cyl_accessibilityIdentifier = "wordPicker.field"
    }

    /** The open sheet, for tests and the launch argument. */
    var sheet: CYLWordPickerSheet? = null
        private set

    override val view: View = LinearLayout(context).apply {
        orientation = LinearLayout.VERTICAL
        setBackgroundColor(Color.WHITE)
        setPadding((20 * d).toInt(), (20 * d).toInt(), (20 * d).toInt(), 0)
        addView(caption(CYLExampleLocalizedString(context, "备注")))
        addView(remarkField, LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT).apply { topMargin = (10 * d).toInt() })
        addView(TextView(context).apply {
            text = SENDER
            setTypeface(typeface, Typeface.BOLD)
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 17f)
            setTextColor(Color.rgb(88, 86, 214))
        }, LinearLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT).apply { topMargin = (16 * d).toInt() })
        addView(TextView(context).apply {
            text = "\"$MESSAGE\""
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 17f)
            setTextColor(Color.rgb(108, 108, 112))
        }, LinearLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT).apply { topMargin = (10 * d).toInt() })
        addView(TextView(context).apply {
            text = CYLExampleLocalizedString(context, "选词填入")
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 17f)
            setTextColor(Color.rgb(0, 122, 255))
            setPadding(0, (10 * d).toInt(), 0, (10 * d).toInt())
            isClickable = true
            isFocusable = true
            contentDescription = text
            cyl_accessibilityIdentifier = "wordPicker.pick"
            setOnClickListener { showPicker() }
        })
    }

    private fun caption(text: String) = TextView(context).apply {
        this.text = text
        setTextSize(TypedValue.COMPLEX_UNIT_SP, 15f)
        setTextColor(Color.rgb(108, 108, 112))
        isAccessibilityHeading = true
    }

    /** Opens the sheet; "填入" puts the picked text into the remark field. */
    fun showPicker() {
        val picker = CYLWordPickerSheet(context, MESSAGE) { picked -> remarkField.setText(picked) }
        sheet = picker
        picker.show()
    }
}

/**
 * `CYLWordPickerSheetViewController`: Cancel, "涂抹选择填入词", the character grid (`CYLMenuStyle.wordPicker()`, smear
 * selection) and "填入", off until something is selected.
 */
class CYLWordPickerSheet(context: Context, message: String, private val onFill: (String) -> Unit) : BottomSheetDialog(context), CYLMenuDelegate {

    private val d = context.resources.displayMetrics.density

    val tagListView = CYLTagListView(context).apply {
        style = CYLMenuStyle.wordPicker()
        selectionMode = CYLMenuSelectionMode.CYLMenuSelectionModeMultiple
        allowsSmearSelection = true
        isScrollEnabled = false
        setTagsWithCharactersOfText(message)
        cyl_accessibilityIdentifier = "wordPicker.list"
    }

    val fillButton = Button(context).apply {
        text = CYLExampleLocalizedString(context, "填入")
        setTextColor(Color.WHITE)
        isAllCaps = false
        background = GradientDrawable().apply { setColor(Color.rgb(52, 199, 89)); cornerRadius = 8 * d }
        cyl_accessibilityIdentifier = "wordPicker.fill"
        setOnClickListener { fillTapped() }
    }

    init {
        tagListView.menuDelegate = this
        val cancel = TextView(context).apply {
            text = CYLExampleLocalizedString(context, "取消")
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 20f)
            setTextColor(Color.BLACK)
            setPadding(0, (8 * d).toInt(), (8 * d).toInt(), (8 * d).toInt())
            isClickable = true
            isFocusable = true
            cyl_accessibilityIdentifier = "wordPicker.cancel"
            setOnClickListener { dismiss() }
        }
        val bar = LinearLayout(context).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER_VERTICAL
            addView(cancel)
            addView(View(context), LinearLayout.LayoutParams(0, 1, 1f))
            addView(fillButton, LinearLayout.LayoutParams((88 * d).toInt(), (40 * d).toInt()))
        }
        val hint = TextView(context).apply {
            text = CYLExampleLocalizedString(context, "涂抹选择填入词")
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 17f)
            setTypeface(typeface, Typeface.BOLD)
            setTextColor(Color.BLACK)
            isAccessibilityHeading = true
        }
        val content = LinearLayout(context).apply {
            orientation = LinearLayout.VERTICAL
            setPadding((16 * d).toInt(), (16 * d).toInt(), (16 * d).toInt(), (32 * d).toInt())
            setBackgroundColor(Color.WHITE)
            addView(bar)
            addView(hint, LinearLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT).apply { topMargin = (20 * d).toInt() })
            addView(tagListView, LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT).apply { topMargin = (20 * d).toInt() })
        }
        setContentView(content)
        updateFillButton()
    }

    /** "填入" is on only while something is selected. */
    fun updateFillButton() {
        val enabled = tagListView.selectedIndexPaths.isNotEmpty()
        fillButton.isEnabled = enabled
        fillButton.alpha = if (enabled) 1f else 0.4f
    }

    override fun menuDidChangeSelectedItems(menu: Any, indexPaths: List<CYLIndexPath>) = updateFillButton()

    override fun menuDidSelectItemAtIndexPath(menu: Any, indexPath: CYLIndexPath) = updateFillButton()

    override fun menuDidDeselectItemAtIndexPath(menu: Any, indexPath: CYLIndexPath) = updateFillButton()

    /** Puts the picked characters, in text order, into the field and closes the sheet. */
    fun fillTapped() {
        val picked = tagListView.selectedText
        if (picked.isEmpty()) return
        onFill(picked)
        dismiss()
    }
}
