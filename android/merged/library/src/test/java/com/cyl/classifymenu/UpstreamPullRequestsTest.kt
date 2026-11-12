package com.cyl.classifymenu

import android.graphics.Typeface
import android.widget.RelativeLayout
import androidx.test.core.app.ApplicationProvider
import co.lujun.androidtagview.TagContainerLayout
import me.kaede.tagview.OnTagClickListener
import me.kaede.tagview.Tag
import me.kaede.tagview.TagView
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNotEquals
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner

/**
 * The open pull requests of the upstream libraries, translated and merged (docs/android-upstream.md):
 * kaedea/android-tagview #27, #22, #21 and whilu/AndroidTagView #110.
 */
@RunWith(RobolectricTestRunner::class)
class UpstreamPullRequestsTest {
    private val context = ApplicationProvider.getApplicationContext<android.content.Context>()

    private fun rules(view: TagView, index: Int) = (view.getChildAt(index).layoutParams as RelativeLayout.LayoutParams).rules

    @Test
    fun firstTagWiderThanTheViewIsNotBelowItself() {
        // PR #27: the first tag starts a new line when it is wider than the view, and must not be laid out below itself.
        val view = TagView(context)
        view.addTag(Tag("x".repeat(400)))
        assertEquals(1, view.childCount)
        assertEquals(0, rules(view, 0)[RelativeLayout.BELOW])
    }

    @Test
    fun notClickableTagIsDisabled() {
        // PR #22 / #21: Tag.clickable = false disables the tag's view and the click listener does not fire.
        val view = TagView(context)
        var taps = 0
        view.setOnTagClickListener(object : OnTagClickListener {
            override fun onTagClick(position: Int, tag: Tag) { taps++ }
        })
        view.addTag(Tag("on"))
        view.addTag(Tag("off").apply { clickable = false })
        assertFalse(view.getChildAt(1).isEnabled)
        view.getChildAt(1).performClick()
        view.getChildAt(0).performClick()
        assertEquals(1, taps)
    }

    @Test
    fun singleSelectionChecksOneTag() {
        // PR #21, opt-in: a tap checks the tag and unchecks the previous one.
        val view = TagView(context)
        view.isSingleSelectionMode = true
        view.addTags(listOf(Tag("a"), Tag("b")))
        view.getChildAt(0).performClick()
        assertTrue(view.checkedTagArray.get(0))
        view.getChildAt(1).performClick()
        assertFalse(view.checkedTagArray.get(0))
        assertTrue(view.checkedTagArray.get(1))
    }

    @Test
    fun linesUseStartAndEndRulesForRightToLeft() {
        // PR #21 (issue #28): tags follow the reading direction (ALIGN_PARENT_START / END_OF), not always the left.
        val view = TagView(context)
        view.addTags(listOf(Tag("a"), Tag("b")))
        assertNotEquals(0, rules(view, 0)[RelativeLayout.ALIGN_PARENT_START])
        assertNotEquals(0, rules(view, 1)[RelativeLayout.END_OF])
        assertEquals(0, rules(view, 1)[RelativeLayout.RIGHT_OF])
    }

    @Test
    fun containerAppliesTextStyleAndFontFamily() {
        // whilu/AndroidTagView PR #110: tag_text_style and tag_text_font_family.
        val container = TagContainerLayout(context)
        container.setTagTextStyle(Typeface.BOLD)
        container.addTag("bold")
        assertEquals(Typeface.BOLD, container.getTagTextStyle())
        container.setTagTextFontFamily("sans-serif-medium")
        container.addTag("medium")
        assertEquals("sans-serif-medium", container.getTagTextFontFamily())
        assertEquals(2, container.childCount)
    }
}
