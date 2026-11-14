package com.cyl.classifymenu

import android.graphics.drawable.GradientDrawable
import android.graphics.drawable.StateListDrawable
import android.view.View
import android.widget.RelativeLayout
import android.widget.TextView
import androidx.test.core.app.ApplicationProvider
import me.kaede.tagview.Tag
import me.kaede.tagview.TagView
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotEquals
import org.junit.Assert.assertSame
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config

/**
 * Fixes of kaedea/android-tagview's open issues in the Kotlin port (docs/android-upstream.md).
 */
@RunWith(RobolectricTestRunner::class)
class AndroidTagviewIssuesTest {
    private val context = ApplicationProvider.getApplicationContext<android.content.Context>()

    private fun rules(view: TagView, index: Int) = (view.getChildAt(index).layoutParams as RelativeLayout.LayoutParams).rules

    private fun width(view: TagView, index: Int): Int {
        val child = view.getChildAt(index)
        child.measure(View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED), View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED))
        return child.measuredWidth
    }

    private fun text(view: TagView, index: Int) = view.getChildAt(index).findViewById<TextView>(com.cyl.classifymenu.R.id.tv_tag_item_contain)

    @Test
    fun issue24MaxWidthWrapsLines() {
        // #24 / #20 / #11: the lines follow the given width (a list item measured before it has one).
        val view = TagView(context)
        view.addTags(arrayOf("alpha", "beta"))
        view.setMaxWidth(width(view, 0) + 4)
        assertNotEquals(0, rules(view, 1)[RelativeLayout.BELOW])
        view.setMaxWidth(10_000)
        assertEquals(0, rules(view, 1)[RelativeLayout.BELOW])
    }

    @Test
    fun issue14WrapContentUsesTheOfferedWidth() {
        // #14: measuring with the width the parent offers (AT_MOST, wrap_content) arranges the lines for it.
        val view = TagView(context)
        view.addTags(arrayOf("alpha", "beta"))
        view.measure(View.MeasureSpec.makeMeasureSpec(width(view, 0) + 4, View.MeasureSpec.AT_MOST), View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED))
        assertNotEquals(0, rules(view, 1)[RelativeLayout.BELOW])
    }

    @Test
    fun issue9TagsThatFitShareALine() {
        // #9: the real measured width decides the line, so two tags that fit stay together (no "…").
        val view = TagView(context)
        view.addTags(arrayOf("alpha", "beta"))
        val needed = width(view, 0) + width(view, 1) + view.getTagMargin() + 40
        view.setMaxWidth(needed)
        assertEquals(0, rules(view, 1)[RelativeLayout.BELOW])
    }

    @Test
    fun issue13ViewsAreReused() {
        // #13 / #17 / #19: adding a tag binds the existing views again instead of inflating them.
        val view = TagView(context)
        view.addTag(Tag("alpha"))
        val first = view.getChildAt(0)
        view.addTag(Tag("beta"))
        assertSame(first, view.getChildAt(0))
    }

    @Test
    fun issue16ReplaceAndCheckATag() {
        // #10 / #16 / #19: one tag changes without touching the others; a checked tag shows the checked colors.
        val view = TagView(context)
        view.addTags(arrayOf("alpha", "beta"))
        val other = view.getChildAt(1)
        view.replaceAtPosition(0, Tag("gamma"))
        assertEquals("gamma", text(view, 0).text.toString())
        assertSame(other, view.getChildAt(1))
        view.isSingleSelectionMode = true
        view.checkedTextColor = 0xFFFF0000.toInt()
        view.setTagChecked(1, true)
        assertEquals(0xFFFF0000.toInt(), text(view, 1).currentTextColor)
    }

    @Test
    @Config(sdk = [34]) // GradientDrawable.getColor() is API 24+.
    fun issue25PressedColorCanBeTheNormalColor() {
        // #25: a tag whose layoutColorPress is its layoutColor does not change when pressed.
        val view = TagView(context)
        view.addTag(Tag("alpha").apply { layoutColorPress = layoutColor })
        val background = view.getChildAt(0).background as StateListDrawable
        background.state = intArrayOf(android.R.attr.state_pressed)
        val pressed = (background.current as GradientDrawable).color?.defaultColor
        background.state = intArrayOf()
        assertEquals((background.current as GradientDrawable).color?.defaultColor, pressed)
    }

    @Test
    fun issue29SingleLine() {
        // #29: every tag on one line (put the TagView in a HorizontalScrollView to scroll).
        val view = TagView(context)
        view.addTags(arrayOf("alpha", "beta", "gamma"))
        view.isSingleLine = true
        view.setMaxWidth(10)
        for (index in 1 until view.childCount) assertEquals(0, rules(view, index)[RelativeLayout.BELOW])
    }
}
