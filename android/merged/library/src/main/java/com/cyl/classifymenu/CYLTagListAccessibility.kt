package com.cyl.classifymenu

import android.view.View
import androidx.core.view.AccessibilityDelegateCompat
import androidx.core.view.ViewCompat
import androidx.core.view.accessibility.AccessibilityNodeInfoCompat

/** The title of a tag list (`CYLTagListTitleAccessibilityIdentifier`). */
const val CYLTagListTitleAccessibilityIdentifier: String = "CYLTagListTitle"

/** The fold control. */
const val CYLTagListFoldControlAccessibilityIdentifier: String = "CYLTagListFoldControl"

/** A tag. */
const val CYLTagListItemAccessibilityIdentifier: String = "CYLTagListItem"

/** The "+ New tag" item. */
const val CYLTagCreateItemAccessibilityIdentifier: String = "CYLTagCreateItem"

/** The More button of a section header. */
const val CYLTagListMoreButtonAccessibilityIdentifier: String = "CYLTagListMoreButton"

/** A tag's delete control. */
const val CYLTagListDeleteAccessibilityIdentifier: String = "CYLTagListDeleteButton"

/**
 * `UIAccessibilityCustomAction`: a named action TalkBack, Switch Access and Voice Access offer on a view.
 */
class CYLAccessibilityAction(val name: String, val handler: () -> Boolean)

/** `accessibilityIdentifier`: stored as a view tag (`R.id.cyl_accessibility_identifier`) for tests and tools. */
var View.cyl_accessibilityIdentifier: String?
    get() = getTag(R.id.cyl_accessibility_identifier) as? String
    set(value) = setTag(R.id.cyl_accessibility_identifier, value)

/** Finds the descendants (and this view) whose `cyl_accessibilityIdentifier` is `identifier`. */
fun View.cyl_viewsWithAccessibilityIdentifier(identifier: String): List<View> {
    val found = ArrayList<View>()
    fun visit(view: View) {
        if (view.cyl_accessibilityIdentifier == identifier) found.add(view)
        if (view is android.view.ViewGroup) for (index in 0 until view.childCount) visit(view.getChildAt(index))
    }
    visit(this)
    return found
}

/**
 * The accessibility of a core view: a button (or not), its selected / enabled state, a hint, and custom actions, as
 * `accessibilityTraits`, `accessibilityHint` and `accessibilityCustomActions` on iOS.
 */
internal object CYLAccessibilityNode {
    fun apply(view: View, isButton: Boolean, selected: Boolean?, hint: String?, actions: List<CYLAccessibilityAction>) {
        ViewCompat.setAccessibilityDelegate(view, object : AccessibilityDelegateCompat() {
            override fun onInitializeAccessibilityNodeInfo(host: View, info: AccessibilityNodeInfoCompat) {
                super.onInitializeAccessibilityNodeInfo(host, info)
                if (isButton) info.className = android.widget.Button::class.java.name
                selected?.let {
                    info.isCheckable = true
                    info.isChecked = it
                }
                hint?.let { info.hintText = it }
                actions.forEachIndexed { index, action ->
                    info.addAction(AccessibilityNodeInfoCompat.AccessibilityActionCompat(ACTION_BASE + index, action.name))
                }
            }

            override fun performAccessibilityAction(host: View, action: Int, args: android.os.Bundle?): Boolean {
                val index = action - ACTION_BASE
                if (index in actions.indices) return actions[index].handler()
                return super.performAccessibilityAction(host, action, args)
            }
        })
    }

    /** Custom action ids (any id outside the standard ones). */
    private const val ACTION_BASE = 0x7f0f0000
}
