package com.cyl.classifymenu

import android.content.Context
import android.util.AttributeSet
import android.view.ViewGroup

/**
 * `CYLTagFoldCell`: the inline fold control of a section, as the last item of its folded rows.
 */
class CYLTagFoldCell @JvmOverloads constructor(context: Context, attrs: AttributeSet? = null) : ViewGroup(context, attrs) {

    val foldButton: CYLTagFoldButton = CYLTagFoldButton(context).apply {
        isClickable = false
        isFocusable = false
        importantForAccessibility = IMPORTANT_FOR_ACCESSIBILITY_NO_HIDE_DESCENDANTS
    }

    init {
        addView(foldButton)
        importantForAccessibility = IMPORTANT_FOR_ACCESSIBILITY_YES
        isFocusable = true
        cyl_accessibilityIdentifier = CYLTagListFoldControlAccessibilityIdentifier
        CYLAccessibilityNode.apply(this, true, null, null, emptyList())
    }

    override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
        foldButton.measure(widthMeasureSpec, heightMeasureSpec)
        setMeasuredDimension(resolveSize(foldButton.measuredWidth, widthMeasureSpec), resolveSize(foldButton.measuredHeight, heightMeasureSpec))
    }

    override fun onLayout(changed: Boolean, l: Int, t: Int, r: Int, b: Int) {
        foldButton.layout(0, 0, r - l, b - t)
    }

    /** `-configureWithFoldControl:itemStyle:expanded:animated:`. */
    fun configureWithFoldControl(foldControl: CYLMenuFoldControl, itemStyle: CYLMenuStyle, expanded: Boolean, animated: Boolean) {
        foldButton.applyInlineFoldControl(foldControl, itemStyle, expanded, animated)
        contentDescription = foldButton.contentDescription
    }
}
