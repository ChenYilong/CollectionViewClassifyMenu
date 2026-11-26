package com.cyl.classifymenu

import android.app.Activity
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.Robolectric
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.GraphicsMode

/**
 * A tag's title wraps up to `CYLMenuStyle.titleMaxLines` lines: 1 by default, a number of the app's choice, or
 * `CYLTagTitleMaxLines.UNLIMITED` (a named value, no literal at the call site).
 */
@RunWith(RobolectricTestRunner::class)
@GraphicsMode(GraphicsMode.Mode.NATIVE)
class CYLTagTitleMaxLinesTest {

    @Test
    fun theDefaultIsOneLineAndAValueBelowOneIsOne() {
        val style = CYLMenuStyle()
        assertEquals(CYLTagTitleMaxLines.SINGLE, style.titleMaxLines)
        style.titleMaxLines = 0
        assertEquals(CYLTagTitleMaxLines.SINGLE, style.titleMaxLines)
        style.titleMaxLines = 3
        assertEquals(3, style.copy().titleMaxLines)
        style.titleMaxLines = CYLTagTitleMaxLines.UNLIMITED
        assertEquals(CYLTagTitleMaxLines.UNLIMITED, style.titleMaxLines)
    }

    // Robolectric's font metrics are fake (a line has no height), so these checks hold for any metrics; the real wrapping
    // is looked at on the emulator (docs/tag-long-press-action.md, titleMaxLines).
    @Test
    fun theWrappedHeightNeverShrinksWithMoreLinesAndOneLineIsOneLine() {
        val font = CYLFont.systemFont(14f)
        val text = "a long title that wraps onto several lines when its room is narrow, one two three four five six"
        val all = CYLTagButton.wrappedTextHeight(text, font, 80f, CYLTagTitleMaxLines.UNLIMITED)
        val three = CYLTagButton.wrappedTextHeight(text, font, 80f, 3)
        val one = CYLTagButton.wrappedTextHeight(text, font, 80f, CYLTagTitleMaxLines.SINGLE)
        assertTrue("more lines are never shorter: all=$all three=$three one=$one", all >= three && three >= one)
        assertEquals("one line is one line height", Math.ceil(CYLTagButton.fontLineHeight(font).toDouble()).toFloat(), one, 0.5f)
    }

    @Test
    fun aOneLineStyleKeepsTheSingleLineHeightAndAWrappingOneNeverShrinks() {
        val text = "a long title that wraps onto several lines when its room is narrow, one two three four five six"
        val icon = CYLSize.ZERO
        val style = CYLMenuStyle()
        val single = CYLTagButton.heightForTitle(text, icon, style)
        assertEquals(single, CYLTagButton.heightForTitleWidth(text, icon, 100f, false, style), 0.001f)
        style.titleMaxLines = 3
        val three = CYLTagButton.heightForTitleWidth(text, icon, 100f, false, style)
        style.titleMaxLines = CYLTagTitleMaxLines.UNLIMITED
        val all = CYLTagButton.heightForTitleWidth(text, icon, 100f, false, style)
        assertTrue(three >= single && all >= three)
    }

    @Test
    fun aConfigurationSetsTheLimit() {
        val activity = Robolectric.buildActivity(Activity::class.java).setup().get()
        val three = CYLTagListView.tagListViewWithConfiguration(activity, mapOf(
            CYLTagListViewStyle to mapOf(CYLMenuStyleTitleMaxLines to 3),
            CYLTagListViewSections to listOf(mapOf(CYLTagSectionItems to listOf("a")))))
        assertEquals(3, three.style!!.titleMaxLines)
        val all = CYLTagListView.tagListViewWithConfiguration(activity, mapOf(
            CYLTagListViewStyle to mapOf(CYLMenuStyleTitleMaxLines to "unlimited"),
            CYLTagListViewSections to listOf(mapOf(CYLTagSectionItems to listOf("a")))))
        assertEquals(CYLTagTitleMaxLines.UNLIMITED, all.style!!.titleMaxLines)
    }
}
