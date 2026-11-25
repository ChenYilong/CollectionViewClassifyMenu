package com.cyl.classifymenu

import android.app.Activity
import android.content.pm.ApplicationInfo
import android.graphics.drawable.ColorDrawable
import android.os.Looper
import android.view.Gravity
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.TextView
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.Robolectric
import org.robolectric.RobolectricTestRunner
import org.robolectric.Shadows.shadowOf
import org.robolectric.annotation.GraphicsMode
import java.time.Duration

/** One section of same-length tags ("Tag 00"), optionally with a section icon, so the header has an icon, a title and a fold control. */
private class CYLSectionRtlSource(private val count: Int, private val withIcon: Boolean) : CYLMenuDataSource {
    override fun numberOfSectionsInMenu() = 1
    override fun menuNumberOfItemsInSection(section: Int) = count
    override fun menuTitleForSection(section: Int) = "Section $section"
    override fun menuTitleForItemAtIndexPath(indexPath: CYLIndexPath) = "Tag %02d".format(indexPath.item)
    override fun menuImageForSection(section: Int) = if (withIcon) ColorDrawable(android.graphics.Color.RED) else null
}

/**
 * Right to left for the section-style views (docs/tag-section-style.md): the header title, the section icon, the fold control,
 * the header band, the divider and the card honour the layout direction. Every frame is the mirror image of the left-to-right
 * one inside the list's width. The list is 320 px wide at density 1, so px = dp.
 */
@RunWith(RobolectricTestRunner::class)
@GraphicsMode(GraphicsMode.Mode.NATIVE)
class CYLTagSectionRtlTest {

    private fun makeList(style: CYLMenuStyle, rtl: Boolean, withIcon: Boolean = false, setup: (CYLTagListView) -> Unit = {}): CYLTagListView {
        val activity = Robolectric.buildActivity(Activity::class.java).setup().get()
        // The app's android:supportsRtl, as the test of the tag rows does: without it a view always resolves to left to right.
        activity.applicationInfo.flags = activity.applicationInfo.flags or ApplicationInfo.FLAG_SUPPORTS_RTL
        val list = CYLTagListView(activity)
        if (rtl) list.layoutDirection = View.LAYOUT_DIRECTION_RTL
        list.style = style
        list.menuDataSource = CYLSectionRtlSource(MANY_TAGS, withIcon)
        setup(list)
        activity.setContentView(FrameLayout(activity).apply { addView(list, FrameLayout.LayoutParams(WIDTH_PX, FrameLayout.LayoutParams.WRAP_CONTENT)) })
        list.reloadMenuData()
        shadowOf(Looper.getMainLooper()).idleFor(Duration.ofMillis(100))
        return list
    }

    private fun insetGrouped(): CYLMenuStyle = CYLMenuStyle().also { it.sectionStyle = CYLSectionStyle.CYLSectionStyleInsetGrouped }

    private fun plain(): CYLMenuStyle = CYLMenuStyle.plainSectionStyle()

    private fun descendants(view: View): List<View> =
        if (view is ViewGroup) (0 until view.childCount).flatMap { val child = view.getChildAt(it); listOf(child) + descendants(child) } else emptyList()

    private fun title(list: CYLTagListView) = descendants(list).filterIsInstance<TextView>().first { it.text == "Section 0" }

    private fun icon(list: CYLTagListView) = descendants(list).filterIsInstance<ImageView>().first { it.drawable is ColorDrawable && it.visibility == View.VISIBLE }

    private fun foldButton(list: CYLTagListView) = descendants(list).filterIsInstance<CYLTagFoldButton>().first { it.visibility == View.VISIBLE }

    private fun tagFrame(list: CYLTagListView, item: Int): CYLRect {
        val cell = list.tagButtonAtIndexPath(CYLIndexPath(item, 0))!!.parent as View
        return CYLRect(cell.left.toFloat(), cell.top.toFloat(), cell.width.toFloat(), cell.height.toFloat())
    }

    /** `rtl` sits where `ltr` does, flipped inside the list's width (a header is as wide as the list), at the same size and height. */
    private fun assertMirrored(message: String, ltr: View, rtl: View) {
        assertEquals("$message: right edge", WIDTH_PX - ltr.left.toFloat(), rtl.right.toFloat(), 0.5f)
        assertEquals("$message: left edge", WIDTH_PX - ltr.right.toFloat(), rtl.left.toFloat(), 0.5f)
        assertEquals("$message: same size", ltr.width.toFloat(), rtl.width.toFloat(), 0.5f)
        assertEquals("$message: same vertical position", ltr.top.toFloat(), rtl.top.toFloat(), 0.5f)
    }

    @Test
    fun theHeaderTitleIsMeasuredFromTheTrailingEdge() {
        val ltr = makeList(insetGrouped(), rtl = false)
        val rtl = makeList(insetGrouped(), rtl = true)
        val leading = 16f + CYLSectionStyleMetrics.CARD_PADDING
        assertEquals(leading, title(ltr).left.toFloat(), 0.5f)
        assertEquals("right to left: the title starts where the tags start, from the right", WIDTH_PX - leading, title(rtl).right.toFloat(), 0.5f)
        assertMirrored("title", title(ltr), title(rtl))
        // The section frame keeps the leading / trailing distances of the title.
        assertEquals(leading, rtl.sectionFrame(0)!!.headerInsetLeft, 0.5f)
    }

    @Test
    fun theTitleTextAlignsToTheRightWhenRightToLeft() {
        val rtl = makeList(plain(), rtl = true)
        assertEquals(Gravity.START, title(rtl).gravity and Gravity.RELATIVE_HORIZONTAL_GRAVITY_MASK)
        assertEquals(View.LAYOUT_DIRECTION_RTL, title(rtl).layoutDirection)
    }

    @Test
    fun theSectionIconIsOnTheRightAndTheTitleFollowsItOnItsLeft() {
        val ltr = makeList(insetGrouped(), rtl = false, withIcon = true)
        val rtl = makeList(insetGrouped(), rtl = true, withIcon = true)
        assertMirrored("icon", icon(ltr), icon(rtl))
        assertTrue("left to right the icon stays left of the title", icon(ltr).right <= title(ltr).left)
        assertTrue("right to left the icon is right of the title", icon(rtl).left >= title(rtl).right)
        assertMirrored("title beside the icon", title(ltr), title(rtl))
    }

    @Test
    fun theFoldControlSitsAtTheMirroredSide() {
        for (position in listOf(CYLMenuFoldControlPosition.HEADER_TRAILING, CYLMenuFoldControlPosition.HEADER_LEADING)) {
            fun make(rtl: Boolean) = makeList(insetGrouped(), rtl) {
                it.defaultVisibleRows = 1
                it.foldControl = CYLMenuFoldControl.foldControlWithPosition(position, CYLMenuFoldControlContent.CYLMenuFoldControlContentIconAndTitle)
            }
            val ltr = make(false)
            val rtl = make(true)
            assertTrue("$position: the section folds", ltr.canFoldSection(0))
            assertMirrored("$position fold control", foldButton(ltr), foldButton(rtl))
            assertMirrored("$position title", title(ltr), title(rtl))
            if (position == CYLMenuFoldControlPosition.HEADER_TRAILING) {
                assertTrue("left to right the trailing control is right of the title", foldButton(ltr).left >= title(ltr).right - 1)
                assertTrue("right to left the trailing control is at the left, before the title", foldButton(rtl).right <= title(rtl).left + 1)
            }
        }
    }

    @Test
    fun theBandAndTheCardAreSymmetricSoTheyDoNotMove() {
        fun style() = insetGrouped().also { it.headerBackgroundColor = CYLSectionStyleColors.HEADER_BAND }
        val ltr = makeList(style(), rtl = false).sectionFrame(0)!!
        val rtl = makeList(style(), rtl = true).sectionFrame(0)!!
        assertEquals(ltr.card, rtl.card)
        assertEquals(ltr.headerBand, rtl.headerBand)
        assertEquals(ltr.top, rtl.top, 0.001f)
        assertEquals(ltr.height, rtl.height, 0.001f)
    }

    @Test
    fun theCardStillContainsEveryTagWhenRightToLeft() {
        val list = makeList(insetGrouped(), rtl = true)
        val card = list.sectionFrame(0)!!.card!!
        for (item in 0 until MANY_TAGS) {
            val tag = tagFrame(list, item)
            assertTrue("tag $item inside the card", tag.x >= card.x - 0.5f && tag.maxX <= card.maxX + 0.5f)
        }
        assertEquals("the first tag starts at the right padding of the card", card.maxX - CYLSectionStyleMetrics.CARD_PADDING, tagFrame(list, 0).maxX, 0.5f)
    }

    @Test
    fun anAsymmetricBandSwapsSidesLikeTheTags() {
        // sectionInsets are leading / trailing: right to left, the leading inset (10) is on the right.
        fun style() = plain().also {
            it.sectionInsets = CYLEdgeInsets(10f, 10f, 10f, 30f)
            it.headerBackgroundColor = CYLSectionStyleColors.HEADER_BAND
        }
        val ltr = makeList(style(), rtl = false).sectionFrame(0)!!.headerBand!!
        val rtl = makeList(style(), rtl = true).sectionFrame(0)!!.headerBand!!
        assertEquals(10f, ltr.x, 0.001f)
        assertEquals(WIDTH_PX - 30f, ltr.maxX, 0.001f)
        assertEquals(30f, rtl.x, 0.001f)
        assertEquals(WIDTH_PX - 10f, rtl.maxX, 0.001f)
    }

    @Test
    fun theDividerInsetsSwapSides() {
        fun style() = plain().also {
            it.headerSeparatorStyle = CYLHeaderSeparatorStyle.CYLHeaderSeparatorStyleLine
            it.headerSeparatorInsets = CYLEdgeInsets(0f, 5f, 0f, 7f)
        }
        val ltr = makeList(style(), rtl = false).sectionFrame(0)!!.headerSeparator!!
        val rtl = makeList(style(), rtl = true).sectionFrame(0)!!.headerSeparator!!
        assertEquals(16f + 5f, ltr.x, 0.001f)
        assertEquals(WIDTH_PX - 16f - 7f, ltr.maxX, 0.001f)
        // The leading inset (5) is on the right now, the trailing one (7) on the left.
        assertEquals(16f + 7f, rtl.x, 0.001f)
        assertEquals(WIDTH_PX - 16f - 5f, rtl.maxX, 0.001f)
        assertEquals(ltr.y, rtl.y, 0.001f)
        assertEquals(ltr.height, rtl.height, 0.001f)
    }

    @Test
    fun theTagRowsMirrorAndLeftToRightKeepsItsFrames() {
        val ltr = makeList(insetGrouped(), rtl = false)
        val rtl = makeList(insetGrouped(), rtl = true)
        for (item in 0 until MANY_TAGS) {
            val a = tagFrame(ltr, item)
            val b = tagFrame(rtl, item)
            assertEquals(WIDTH_PX - a.maxX, b.x, 0.5f)
            assertEquals(a.y, b.y, 0.5f)
        }
        // The left-to-right frames are the ones the other tests assert.
        assertEquals(16f + CYLSectionStyleMetrics.CARD_PADDING, tagFrame(ltr, 0).x, 0.5f)
        assertEquals(ltr.contentHeight, rtl.contentHeight, 0.5f)
    }

    private companion object {
        const val WIDTH_PX = 320
        const val MANY_TAGS = 16
    }
}
