package com.cyl.classifymenu

import android.app.Activity
import android.os.Looper
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import android.widget.TextView
import androidx.test.core.app.ApplicationProvider
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.Robolectric
import org.robolectric.RobolectricTestRunner
import org.robolectric.Shadows.shadowOf
import org.robolectric.annotation.GraphicsMode
import java.time.Duration

private class CYLHeaderBoardGapSource(vararg counts: Int) : CYLMenuDataSource {
    val sections = counts.map { count -> (0 until count).map { "Tag %02d".format(it) } }
    override fun numberOfSectionsInMenu() = sections.size
    override fun menuNumberOfItemsInSection(section: Int) = sections[section].size
    override fun menuTitleForSection(section: Int) = "Section $section"
    override fun menuTitleForItemAtIndexPath(indexPath: CYLIndexPath) = sections[indexPath.section][indexPath.item]
}

/**
 * The gap between the header and the board is short under `insetGrouped` with no header divider (docs/tag-section-style.md):
 * the header is sized to its text (a title line plus 8, not below the fold control) and the board starts 4 below it. With the
 * divider on, and in the plain style, the old values stay. Robolectric's font metrics can be fake (a line may have no
 * height), so every expectation is written relative to the line height the list itself measures.
 */
@RunWith(RobolectricTestRunner::class)
@GraphicsMode(GraphicsMode.Mode.NATIVE)
class CYLTagHeaderBoardGapTest {

    private fun makeList(style: CYLMenuStyle, vararg counts: Int, setup: (CYLTagListView) -> Unit = {}): CYLTagListView {
        val activity = Robolectric.buildActivity(Activity::class.java).setup().get()
        val list = CYLTagListView(activity)
        list.style = style
        list.menuDataSource = CYLHeaderBoardGapSource(*counts)
        setup(list)
        activity.setContentView(FrameLayout(activity).apply { addView(list, FrameLayout.LayoutParams(WIDTH_PX, FrameLayout.LayoutParams.WRAP_CONTENT)) })
        list.reloadMenuData()
        shadowOf(Looper.getMainLooper()).idleFor(Duration.ofMillis(100))
        return list
    }

    private fun descendants(view: View): List<View> =
        if (view is ViewGroup) (0 until view.childCount).flatMap { val child = view.getChildAt(it); listOf(child) + descendants(child) } else emptyList()

    private fun line(style: CYLMenuStyle): Float = Math.ceil(CYLTagButton.fontLineHeight(style.headerFontForTraitCollection()).toDouble()).toFloat()

    private fun divider(): CYLMenuStyle = CYLMenuStyle().also { it.headerSeparatorStyle = CYLHeaderSeparatorStyle.CYLHeaderSeparatorStyleLine }

    private fun plain(): CYLMenuStyle = CYLMenuStyle.plainSectionStyle()

    private fun tagY(list: CYLTagListView, item: Int, section: Int): Float = (list.tagButtonAtIndexPath(CYLIndexPath(item, section))!!.parent as View).top.toFloat()

    @Test
    fun theHeaderIsTheTitleLinePlusPaddingWithoutADivider() {
        val style = CYLMenuStyle()
        val list = makeList(style, 3)
        val frame = list.sectionFrame(0)!!
        // Not the fixed 36: a header sized to its text (no fold control here to raise it).
        assertEquals(line(style) + HEADER_BOARD_TITLE_PADDING, frame.headerHeight, 0.5f)
        assertEquals(8f, HEADER_BOARD_TITLE_PADDING, 0f)
        val title = descendants(list).filterIsInstance<TextView>().first { it.text == "Section 0" }
        assertEquals("the title block is as tall as the header", frame.headerHeight.toInt(), title.height)
    }

    @Test
    fun theHeaderIsNeverBelowTheFoldControl() {
        val fold = CYLMenuFoldControl.foldControlWithPosition(CYLMenuFoldControlPosition.HEADER_TRAILING, CYLMenuFoldControlContent.CYLMenuFoldControlContentIconAndTitle)
        val style = CYLMenuStyle()
        val list = makeList(style, TAGS_IN_TWO_ROWS) {
            it.defaultVisibleRows = 1
            it.foldControl = fold
        }
        assertTrue(list.canFoldSection(0))
        val foldHeight = CYLTagFoldButton.sizeForFoldControl(fold, false).height
        assertEquals(maxOf(line(style) + HEADER_BOARD_TITLE_PADDING, foldHeight), list.sectionFrame(0)!!.headerHeight, 0.5f)
        assertTrue(list.sectionFrame(0)!!.headerHeight >= foldHeight)
    }

    @Test
    fun theBoardStartsFourBelowTheHeader() {
        val list = makeList(CYLMenuStyle(), 6, 3)
        assertEquals(4f, HEADER_BOARD_SPACING, 0f)
        for (section in 0..1) {
            val frame = list.sectionFrame(section)!!
            val card = frame.card!!
            assertEquals(frame.top + frame.headerHeight + HEADER_BOARD_SPACING, card.y, 0.001f)
            assertEquals("the tags start one card padding inside the board", card.y + CYLSectionStyleMetrics.CARD_PADDING, tagY(list, 0, section), 0.5f)
            // The space below the board is unchanged: the section's bottom inset.
            assertEquals(frame.top + frame.height, card.maxY + CYLMenuStyle().sectionInsets.bottom, 0.001f)
        }
        val first = list.sectionFrame(0)!!
        assertEquals(first.top + first.height, list.sectionFrame(1)!!.top, 0.001f)
        assertEquals(list.contentHeight, list.heightThatFitsWidth(WIDTH_PX.toFloat()), 0.5f)
    }

    @Test
    fun theDividerKeepsTheOldHeaderAndTheOldInset() {
        val style = divider()
        val list = makeList(style, 6, 3)
        val frame = list.sectionFrame(0)!!
        assertEquals(maxOf(36f, line(style) + 12f), frame.headerHeight, 0.5f)
        assertEquals(frame.top + frame.headerHeight + style.sectionInsets.top, frame.card!!.y, 0.001f)
        assertEquals(frame.top + frame.headerHeight, frame.headerSeparator!!.maxY, 0.001f)
        assertEquals(list.contentHeight, list.heightThatFitsWidth(WIDTH_PX.toFloat()), 0.5f)
        // The two looks differ by the header and by the inset, in the content height too (two sections).
        val none = makeList(CYLMenuStyle(), 6, 3)
        val headerDelta = frame.headerHeight - none.sectionFrame(0)!!.headerHeight
        val insetDelta = style.sectionInsets.top - HEADER_BOARD_SPACING
        assertEquals(2 * (headerDelta + insetDelta), list.contentHeight - none.contentHeight, 0.5f)
    }

    @Test
    fun thePlainStyleKeepsTheOldHeaderAndTheOldInset() {
        val style = plain()
        val list = makeList(style, 6, 3)
        val frame = list.sectionFrame(0)!!
        assertEquals(maxOf(36f, line(style) + 12f), frame.headerHeight, 0.5f)
        assertEquals(frame.headerHeight + style.sectionInsets.top, tagY(list, 0, 0), 0.5f)
        assertEquals(list.contentHeight, list.heightThatFitsWidth(WIDTH_PX.toFloat()), 0.5f)
    }

    @Test
    fun anExplicitHeaderHeightIsTheMinimumUnderTheBoard() {
        val style = CYLMenuStyle().also { it.headerHeight = 60f }
        val list = makeList(style, 3)
        val frame = list.sectionFrame(0)!!
        assertEquals(maxOf(60f, line(style) + HEADER_BOARD_TITLE_PADDING), frame.headerHeight, 0.5f)
        assertEquals(frame.headerHeight + HEADER_BOARD_SPACING, frame.card!!.y, 0.001f)
        // An explicit value below the text is not a maximum: the text wins.
        val small = CYLMenuStyle().also { it.headerHeight = 0f }
        assertEquals(line(small) + HEADER_BOARD_TITLE_PADDING, makeList(small, 3).sectionFrame(0)!!.headerHeight, 0.5f)
    }

    @Test
    fun theHeaderHeightRemembersWhetherTheAppSetIt() {
        val untouched = CYLMenuStyle()
        assertFalse(untouched.isHeaderHeightSet)
        assertEquals(36f, untouched.headerHeight, 0f)
        assertFalse("the copy of an unset height is unset", untouched.copy().isHeaderHeightSet)
        val set = CYLMenuStyle().also { it.headerHeight = 36f }
        assertTrue("setting the default value still counts", set.isHeaderHeightSet)
        assertTrue(set.copy().isHeaderHeightSet)
        assertEquals(44f, CYLMenuStyle().also { it.headerHeight = 44f }.copy().headerHeight, 0f)
    }

    @Test
    fun theConfigurationKeySetsTheHeaderHeight() {
        assertEquals("headerHeight", CYLMenuStyleHeaderHeight)
        val style = CYLMenuStyle.styleWithConfiguration(mapOf(CYLMenuStyleHeaderHeight to 44))
        assertTrue(style.isHeaderHeightSet)
        assertEquals(44f, style.headerHeight, 0f)
        assertFalse(CYLMenuStyle.styleWithConfiguration(emptyMap()).isHeaderHeightSet)
        val context = ApplicationProvider.getApplicationContext<android.content.Context>()
        assertFalse(CYLMenuStyle().also { it.applyConfiguration(emptyMap(), context) }.isHeaderHeightSet)
    }

    private companion object {
        const val WIDTH_PX = 320
        const val TAGS_IN_TWO_ROWS = 16
    }
}
