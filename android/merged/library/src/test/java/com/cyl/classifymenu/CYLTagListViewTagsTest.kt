package com.cyl.classifymenu

import android.app.Activity
import android.content.pm.ApplicationInfo
import android.graphics.Color
import android.graphics.Typeface
import android.os.Looper
import android.os.SystemClock
import android.view.MotionEvent
import android.view.View
import android.widget.FrameLayout
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNotEquals
import org.junit.Assert.assertSame
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.Robolectric
import org.robolectric.RobolectricTestRunner
import org.robolectric.Shadows.shadowOf
import org.robolectric.annotation.GraphicsMode
import java.time.Duration

/**
 * The tag API of `CYLTagListView` (the tags of android-tagview and AndroidTagView it absorbed): taps, long presses and
 * the cross, selection, the reading direction and row alignment, wide tags, colors and the text style. These are the
 * behaviors the deleted TagView and TagContainerLayout tests checked, asked of the list.
 */
@RunWith(RobolectricTestRunner::class)
@GraphicsMode(GraphicsMode.Mode.NATIVE)
class CYLTagListViewTagsTest {

    private class Page(val root: FrameLayout, val list: CYLTagListView)

    private fun frames() = shadowOf(Looper.getMainLooper()).idleFor(Duration.ofMillis(FRAME_MILLIS))

    private fun makePage(titles: List<String>, supportsRtl: Boolean = false, setup: CYLTagListView.() -> Unit = {}): Page {
        val activity = Robolectric.buildActivity(Activity::class.java).setup().get()
        if (supportsRtl) activity.applicationInfo.flags = activity.applicationInfo.flags or ApplicationInfo.FLAG_SUPPORTS_RTL
        val list = CYLTagListView(activity)
        list.isScrollEnabled = false
        list.setup()
        list.setTagsWithTitles(titles)
        val root = FrameLayout(activity).apply { addView(list, FrameLayout.LayoutParams(FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.WRAP_CONTENT)) }
        activity.setContentView(root)
        list.reloadMenuData()
        frames()
        return Page(root, list)
    }

    private fun button(page: Page, index: Int) = page.list.tagButtonAtIndexPath(CYLIndexPath(index, 0))!!

    private fun cell(page: Page, index: Int) = button(page, index).parent as View

    /** The left and right edges of a tag in the list's coordinates. */
    private fun horizontalEdges(page: Page, index: Int): Pair<Int, Int> {
        val listLocation = IntArray(2).also { page.list.getLocationOnScreen(it) }
        val location = IntArray(2).also { cell(page, index).getLocationOnScreen(it) }
        val left = location[0] - listLocation[0]
        return left to left + cell(page, index).width
    }

    /** The cross of a tag is a control of its cell over the delete indicator. */
    private fun tapCross(page: Page, index: Int) {
        val cell = cell(page, index) as android.view.ViewGroup
        val control = (0 until cell.childCount).map { cell.getChildAt(it) }.single { it !== button(page, index) && it.visibility == View.VISIBLE && it.isClickable }
        control.performClick()
    }

    private fun touch(page: Page, action: Int, downTime: Long, index: Int) {
        val view = cell(page, index)
        val location = IntArray(2).also { view.getLocationOnScreen(it) }
        val rootLocation = IntArray(2).also { page.root.getLocationOnScreen(it) }
        val event = MotionEvent.obtain(downTime, SystemClock.uptimeMillis(), action, location[0] + view.width / 2f - rootLocation[0], location[1] + view.height / 2f - rootLocation[1], 0)
        page.root.dispatchTouchEvent(event)
        event.recycle()
    }

    private fun tap(page: Page, index: Int) {
        val down = SystemClock.uptimeMillis()
        touch(page, MotionEvent.ACTION_DOWN, down, index)
        touch(page, MotionEvent.ACTION_UP, down, index)
        frames()
    }

    /** Presses a tag until the long press is recognized, then ends the gesture with [end]. */
    private fun hold(page: Page, index: Int, end: Int) {
        val down = SystemClock.uptimeMillis()
        touch(page, MotionEvent.ACTION_DOWN, down, index)
        shadowOf(Looper.getMainLooper()).idleFor(Duration.ofMillis(LONG_PRESS_MILLIS))
        touch(page, end, down, index)
        frames()
    }

    @Test
    fun aTapReportsThePositionAndTheTag() {
        val taps = ArrayList<Pair<Int, String>>()
        val page = makePage(listOf("a", "b", "c")) { tagClickHandler = { index, tag -> taps.add(index to tag.title) } }
        tap(page, 1)
        assertEquals(listOf(1 to "b"), taps)
        tap(page, 1)
        assertEquals("the same tag again", listOf(1 to "b", 1 to "b"), taps)
    }

    @Test
    fun aDisabledTagReportsNoTap() {
        var taps = 0
        val page = makePage(listOf("on", "off")) { tagClickHandler = { _, _ -> taps++ } }
        page.list.tags[1].isEnabled = false
        page.list.reloadMenuData()
        frames()
        assertFalse(button(page, 1).isEnabled)
        tap(page, 1)
        assertEquals(0, taps)
        tap(page, 0)
        assertEquals(1, taps)
    }

    @Test
    fun aListThatDoesNotAllowTappingReportsNoTap() {
        var taps = 0
        val page = makePage(listOf("on")) {
            allowsTapping = false
            tagClickHandler = { _, _ -> taps++ }
        }
        tap(page, 0)
        assertEquals(0, taps)
        page.list.allowsTapping = true
        tap(page, 0)
        assertEquals(1, taps)
    }

    @Test
    fun aLongPressReportsOnceAndACancelledGestureReportsNothing() {
        val longPresses = ArrayList<Int>()
        var taps = 0
        val page = makePage(listOf("a", "b")) {
            tagLongPressHandler = { index, _ -> longPresses.add(index) }
            tagClickHandler = { _, _ -> taps++ }
        }
        hold(page, 0, MotionEvent.ACTION_CANCEL)
        assertTrue("the cancelled gesture is no tap", taps == 0)
        val down = SystemClock.uptimeMillis()
        touch(page, MotionEvent.ACTION_DOWN, down, 1)
        touch(page, MotionEvent.ACTION_CANCEL, down, 1)
        shadowOf(Looper.getMainLooper()).idleFor(Duration.ofMillis(LONG_PRESS_MILLIS))
        assertEquals("the long press of the first tag only", listOf(0), longPresses)
        hold(page, 1, MotionEvent.ACTION_UP)
        assertEquals(listOf(0, 1), longPresses)
        assertEquals("a long press is no tap", 0, taps)
    }

    @Test
    fun theCrossIsOnTheTagsThatAreDeletableAndDeletesThroughItsOwnTap() {
        val deleted = ArrayList<Pair<Int, String>>()
        val page = makePage(listOf("+ Add", "Abd", "def")) { tagDeleteHandler = { index, tag -> deleted.add(index to tag.title) } }
        page.list.tags.forEach { it.isDeletable = true }
        page.list.tags[0].isDeletable = false
        page.list.reloadMenuData()
        frames()
        assertFalse(button(page, 0).showsDeleteIndicator)
        assertTrue(button(page, 1).showsDeleteIndicator && button(page, 2).showsDeleteIndicator)
        tapCross(page, 1)
        assertEquals(listOf(1 to "Abd"), deleted)
        assertEquals(listOf("+ Add", "def"), page.list.tags.map { it.title })
    }

    @Test
    fun aTagIsKeptWhenTheListDoesNotRemoveItemsOnDelete() {
        val deleted = ArrayList<Int>()
        val page = makePage(listOf("a", "b")) {
            removesItemsOnDelete = false
            tagDeleteHandler = { index, _ -> deleted.add(index) }
        }
        page.list.tags.forEach { it.isDeletable = true }
        page.list.reloadMenuData()
        frames()
        page.list.deleteItemAtIndexPath(CYLIndexPath(0, 0))
        assertEquals(listOf(0), deleted)
        assertEquals(2, page.list.tags.size)
        page.list.removeTagAtIndex(0)
        assertEquals(listOf("b"), page.list.tags.map { it.title })
    }

    @Test
    fun singleSelectionChecksOneTag() {
        val page = makePage(listOf("a", "b")) { }
        page.list.selectionMode = CYLMenuSelectionMode.CYLMenuSelectionModeSingle
        tap(page, 0)
        assertEquals(listOf(CYLIndexPath(0, 0)), page.list.selectedIndexPaths)
        tap(page, 1)
        assertEquals(listOf(CYLIndexPath(1, 0)), page.list.selectedIndexPaths)
    }

    @Test
    fun tagsFollowTheReadingDirectionAndTheRowAlignment() {
        val ltr = makePage(listOf("a", "b"))
        assertTrue("left to right: the first tag is leftmost", horizontalEdges(ltr, 0).first < horizontalEdges(ltr, 1).first)
        val rtl = makePage(listOf("a", "b"), supportsRtl = true) { layoutDirection = View.LAYOUT_DIRECTION_RTL }
        assertTrue("right to left: the first tag is rightmost", horizontalEdges(rtl, 0).first > horizontalEdges(rtl, 1).first)
        val trailing = makePage(listOf("a", "b")) { style = CYLMenuStyle().apply { rowAlignment = CYLTagRowAlignment.CYLTagRowAlignmentTrailing } }
        val inset = trailing.list.style!!.sectionInsets.right
        val rightmost = maxOf(horizontalEdges(trailing, 0).second, horizontalEdges(trailing, 1).second)
        assertWithin(trailing.list.width - Math.round(inset * trailing.list.resources.displayMetrics.density), rightmost)
    }

    @Test
    fun aTagWiderThanTheViewStartsTheFirstRowAndFitsIt() {
        val page = makePage(listOf("x".repeat(WIDE_TITLE_LENGTH)))
        val (left, right) = horizontalEdges(page, 0)
        val inset = Math.round(page.list.style!!.sectionInsets.left * page.list.resources.displayMetrics.density)
        assertWithin(inset, left)
        assertTrue("the tag is inside the view", right <= page.list.width)
        assertEquals(1, page.list.numberOfRowsInSection(0))
    }

    @Test
    fun tagsThatFitShareARowAndTheOneThatDoesNotStartsTheNext() {
        val few = makePage(listOf("alpha", "beta"))
        assertEquals(1, few.list.numberOfRowsInSection(0))
        val many = makePage((0 until MANY_TAGS).map { "alpha $it" })
        assertTrue(many.list.numberOfRowsInSection(0) > 1)
        val firstLeft = horizontalEdges(many, 0).first
        val lastRowStarts = (0 until MANY_TAGS).count { horizontalEdges(many, it).first == firstLeft }
        assertEquals("one tag starts each row", many.list.numberOfRowsInSection(0), lastRowStarts)
        assertTrue(many.list.heightThatFitsWidth(many.list.width.toFloat()) > few.list.heightThatFitsWidth(few.list.width.toFloat()))
    }

    @Test
    fun aTagKeepsItsOwnColorsOverTheThemeAndTheThemeReachesShownTags() {
        val page = makePage(emptyList())
        val own = CYLTagColors(Color.rgb(OWN_RED, OWN_GREEN, OWN_BLUE), Color.BLACK, Color.WHITE, Color.GRAY)
        page.list.setTagsWithTitles(listOf("own", "theme"), listOf(own))
        page.list.colorTheme = CYLTagColorTheme.CYLTagColorThemeNone
        page.list.reloadMenuData()
        frames()
        val plain = button(page, 1).style!!.normalAppearance.backgroundColor
        assertEquals(own.backgroundColor, button(page, 0).style!!.normalAppearance.backgroundColor)
        page.list.colorTheme = CYLTagColorTheme.CYLTagColorThemePureTeal
        frames()
        assertNotEquals("the theme restyles a tag already shown", plain, button(page, 1).style!!.normalAppearance.backgroundColor)
        assertEquals("the tag with its own colors keeps them", own.backgroundColor, button(page, 0).style!!.normalAppearance.backgroundColor)
    }

    @Test
    fun theTextStyleAndTheFontFamilyReachTheTitle() {
        val family = Typeface.create("sans-serif-medium", Typeface.ITALIC)
        val page = makePage(listOf("bold")) {
            style = CYLMenuStyle().apply { listOf(normalAppearance, selectedAppearance, disabledAppearance).forEach { it.font = CYLFont(TITLE_SIZE, family) } }
        }
        assertSame(family, button(page, 0).titleLabel.typeface)
    }

    @Test
    fun tagsCanBeReadAndRemovedByTheirTitle() {
        val page = makePage(listOf("one", "two", "three"))
        assertEquals(listOf("one", "two", "three"), page.list.tags.map { it.title })
        page.list.removeTagAtIndex(page.list.tags.indexOfFirst { it.title == "two" })
        frames()
        assertEquals(listOf("one", "three"), page.list.tags.map { it.title })
        assertEquals("three", button(page, 1).title.toString())
    }

    private fun assertWithin(expected: Int, actual: Int) = assertTrue("expected $expected +-1, was $actual", Math.abs(expected - actual) <= 1)

    private companion object {
        // Longer than the double-tap timeout, so a second tap on a tag is a new tap.
        const val FRAME_MILLIS = 1000L
        const val LONG_PRESS_MILLIS = 800L
        const val WIDE_TITLE_LENGTH = 400
        const val MANY_TAGS = 12
        const val OWN_RED = 0x11
        const val OWN_GREEN = 0x22
        const val OWN_BLUE = 0x33
        const val TITLE_SIZE = 16f
    }
}
