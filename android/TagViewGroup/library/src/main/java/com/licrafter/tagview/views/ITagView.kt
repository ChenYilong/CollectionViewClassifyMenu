package com.licrafter.tagview.views

import com.licrafter.tagview.DIRECTION

/**
 * A view a TagViewGroup lays out around its dot: a tag (TagTextView) or the ripple (RippleView). The size and
 * layout methods are the ones every android.view.View already has.
 */
interface ITagView {
    fun setDirection(direction: DIRECTION)
    fun getDirection(): DIRECTION
    fun getMeasuredWidth(): Int
    fun getMeasuredHeight(): Int
    fun getTop(): Int
    fun getLeft(): Int
    fun getRight(): Int
    fun getBottom(): Int
    fun layout(left: Int, top: Int, right: Int, bottom: Int)
}
