package com.cyl.classifymenu

import android.content.Context
import android.graphics.Color
import android.graphics.Typeface
import android.graphics.drawable.GradientDrawable
import android.text.Editable
import android.text.TextWatcher
import android.util.AttributeSet
import android.util.TypedValue
import android.view.Gravity
import android.view.KeyEvent
import android.view.inputmethod.EditorInfo
import android.widget.Button
import android.widget.EditText
import android.widget.LinearLayout
import android.widget.TextView
import kotlin.math.ceil
import kotlin.math.max

/**
 * `CYLTagListAddItemView`: the "add tag" control of `CYLTagListView` in editing mode, a text field and an Add button.
 * The list places it below its last section and reports a submitted name through `menuDidRequestNewItemWithName`;
 * customize its field and button (hint, text sizes, colors) as needed.
 */
open class CYLTagListAddItemView @JvmOverloads constructor(context: Context, attrs: AttributeSet? = null) : LinearLayout(context, attrs) {
    private val density: Float get() = resources.displayMetrics.density

    companion object {
        /** `textFieldIdentifier`: the text field's identifier ("CYLTagListAddItemField", its tag here). */
        const val textFieldIdentifier: String = "CYLTagListAddItemField"

        /** `addButtonIdentifier`: the Add button's identifier ("CYLTagListAddItemButton", its tag here). */
        const val addButtonIdentifier: String = "CYLTagListAddItemButton"
    }

    /** The name field. Its hint and TalkBack label are the localized "Tag name" (`CYLMenuAddTagPlaceholder`). */
    val textField: EditText = EditText(context).apply {
        hint = CYLMenuLocalizedString("CYLMenuAddTagPlaceholder", "The add control's field")
        contentDescription = hint
        tag = textFieldIdentifier
        setTextSize(TypedValue.COMPLEX_UNIT_SP, 17f)
        isSingleLine = true
        imeOptions = EditorInfo.IME_ACTION_DONE
        background = GradientDrawable().apply {
            cornerRadius = 8 * density
            setColor(Color.argb(255, 242, 242, 247))
        }
        setPadding((12 * density).toInt(), 0, (12 * density).toInt(), 0)
    }

    /** The Add button (`CYLMenuAddTag`); it is enabled while the field has a name. */
    val addButton: Button = Button(context).apply {
        text = CYLMenuLocalizedString("CYLMenuAddTag", "The add control's button")
        tag = addButtonIdentifier
        isAllCaps = false
        setTextSize(TypedValue.COMPLEX_UNIT_SP, 17f)
        setTypeface(typeface, Typeface.BOLD)
        isEnabled = false
    }

    /** Called with the trimmed name when the Add button or the keyboard's Done key is tapped; the field is cleared. */
    var submitHandler: ((String) -> Unit)? = null

    /** The height of the control, px: 44 dp by default, larger with a larger font scale. */
    open val preferredHeight: Int
        get() {
            val line = max(textField.lineHeight, addButton.lineHeight).toFloat()
            return max((44 * density).toInt(), ceil(line + 20 * density).toInt())
        }

    /** The trimmed name in the field. */
    open val name: String get() = textField.text?.toString()?.trim().orEmpty()

    /** `isRenaming`: whether the control renames a tag (`beginRenamingWithTitle`) instead of adding one. */
    var isRenaming: Boolean = false
        private set

    /**
     * `-beginRenamingWithTitle:`: renames a tag; the field shows `title` with the keyboard up, the button reads "Done"
     * (`CYLMenuRenameDone`); the next submit reports the new name, then the control adds tags again.
     */
    open fun beginRenamingWithTitle(title: String) {
        isRenaming = true
        textField.setText(title)
        textField.hint = CYLMenuLocalizedString("CYLMenuRenamePlaceholder", "The rename field")
        textField.contentDescription = textField.hint
        addButton.text = CYLMenuLocalizedString("CYLMenuRenameDone", "The rename button")
        addButton.isEnabled = name.isNotEmpty()
        textField.requestFocus()
        textField.selectAll()
        (context.getSystemService(Context.INPUT_METHOD_SERVICE) as? android.view.inputmethod.InputMethodManager)
            ?.showSoftInput(textField, 0)
    }

    /** `-endRenaming`: leaves renaming without a change; the field is cleared and adds tags again. */
    open fun endRenaming() {
        if (!isRenaming) return
        isRenaming = false
        textField.setText("")
        textField.hint = CYLMenuLocalizedString("CYLMenuAddTagPlaceholder", "The add control's field")
        textField.contentDescription = textField.hint
        addButton.text = CYLMenuLocalizedString("CYLMenuAddTag", "The add control's button")
        addButton.isEnabled = false
    }

    init {
        orientation = HORIZONTAL
        gravity = Gravity.CENTER_VERTICAL
        addView(textField, LayoutParams(0, LayoutParams.MATCH_PARENT, 1f))
        addView(addButton, LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.MATCH_PARENT).apply { leftMargin = (12 * density).toInt() })
        textField.addTextChangedListener(object : TextWatcher {
            override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {}
            override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {}
            override fun afterTextChanged(s: Editable?) {
                addButton.isEnabled = name.isNotEmpty()
            }
        })
        textField.setOnEditorActionListener { _: TextView, actionId: Int, event: KeyEvent? ->
            val done = actionId == EditorInfo.IME_ACTION_DONE || (event?.keyCode == KeyEvent.KEYCODE_ENTER && event.action == KeyEvent.ACTION_UP)
            if (done) {
                if (name.isEmpty()) textField.clearFocus() else submit()
            }
            done
        }
        addButton.setOnClickListener { submit() }
    }

    /**
     * `submit`: submits the name in the field (as the Add button does): calls `submitHandler` and clears the field.
     * An empty name does nothing. TalkBack announces "Tag added: <name>" (`CYLMenuTagAdded`).
     */
    open fun submit() {
        val name = this.name
        if (name.isEmpty()) return
        val renaming = isRenaming
        if (renaming) {
            endRenaming()
            (context.getSystemService(Context.INPUT_METHOD_SERVICE) as? android.view.inputmethod.InputMethodManager)
                ?.hideSoftInputFromWindow(textField.windowToken, 0)
        }
        textField.setText("")
        addButton.isEnabled = false
        submitHandler?.invoke(name)
        val key = if (renaming) "CYLMenuTagRenamed" else "CYLMenuTagAdded"
        announceForAccessibility(String.format(CYLMenuLocalizedString(key, "Announced after adding or renaming a tag").replace("%@", "%s"), name))
    }
}
