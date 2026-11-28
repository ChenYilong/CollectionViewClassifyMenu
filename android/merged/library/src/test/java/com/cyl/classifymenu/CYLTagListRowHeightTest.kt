package com.cyl.classifymenu

import android.app.Activity
import android.os.Looper
import android.view.View
import android.widget.FrameLayout
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.Robolectric
import org.robolectric.RobolectricTestRunner
import org.robolectric.Shadows.shadowOf
import org.robolectric.annotation.GraphicsMode
import java.time.Duration

/** Tags "Tag 00"…; the tag at `tallItem` has its own, taller style (a custom tag or icon height). */
private class CYLRowHeightSource(count: Int, private val tallItem: Int, private val tallStyle: CYLMenuStyle) : CYLMenuDataSource {
    val titles = (0 until count).map { "Tag %02d".format(it) }
    override fun numberOfSectionsInMenu() = 1
    override fun menuNumberOfItemsInSection(section: Int) = titles.size
    override fun menuTitleForSection(section: Int) = "Section"
    override fun menuTitleForItemAtIndexPath(indexPath: CYLIndexPath) = titles[indexPath.item]
    override fun menuStyleForItemAtIndexPath(indexPath: CYLIndexPath): CYLMenuStyle? = if (indexPath.item == tallItem) tallStyle else null
}

/** 40 tags; every tag from `tallFrom` on has its own, taller style. */
private class CYLTallFromSource(var tallFrom: Int = Int.MAX_VALUE) : CYLMenuDataSource {
    val tall = CYLMenuStyle().apply { itemHeight = 80f }
    override fun numberOfSectionsInMenu() = 1
    override fun menuNumberOfItemsInSection(section: Int) = 40
    override fun menuTitleForSection(section: Int) = "Section"
    override fun menuTitleForItemAtIndexPath(indexPath: CYLIndexPath) = "Tag %02d".format(indexPath.item)
    override fun menuStyleForItemAtIndexPath(indexPath: CYLIndexPath): CYLMenuStyle? = if (indexPath.item >= tallFrom) tall else null
}

/** Every row is as tall as its tallest tag, and `maxItemHeight` limits it (iOS CYLTagListLayoutTests). */
@RunWith(RobolectricTestRunner::class)
@GraphicsMode(GraphicsMode.Mode.NATIVE)
class CYLTagListRowHeightTest {

    private fun makeList(count: Int = 12, tallItem: Int = 1): CYLTagListView {
        val activity = Robolectric.buildActivity(Activity::class.java).setup().get()
        val tall = CYLMenuStyle().apply { itemHeight = 80f }
        val list = CYLTagListView(activity)
        list.menuDataSource = CYLRowHeightSource(count, tallItem, tall)
        list.showsSectionHeaders = false
        activity.setContentView(FrameLayout(activity).apply { addView(list, FrameLayout.LayoutParams(600, FrameLayout.LayoutParams.WRAP_CONTENT)) })
        list.reloadMenuData()
        shadowOf(Looper.getMainLooper()).idleFor(Duration.ofMillis(100))
        return list
    }

    private fun heights(list: CYLTagListView): Map<Int, Set<Int>> =
        (0 until 12).mapNotNull { list.tagButtonAtIndexPath(CYLIndexPath(it, 0))?.parent as? View }
            .groupBy({ it.top }, { it.height }).mapValues { it.value.toSet() }

    @Test
    fun everyTagOfARowIsAsTallAsTheRowsTallest() {
        val list = makeList()
        assertEquals(Float.MAX_VALUE, list.maxItemHeight, 0f)
        assertTrue("tags of a row share one height", heights(list).values.all { it.size == 1 })
        val first = list.tagButtonAtIndexPath(CYLIndexPath(0, 0))!!.parent as View
        val tall = list.tagButtonAtIndexPath(CYLIndexPath(1, 0))!!.parent as View
        assertTrue(tall.height > 0)
        assertEquals("a short tag beside it is stretched", tall.height, first.height)
    }

    @Test
    fun maxItemHeightLimitsEveryTag() {
        val list = makeList()
        list.maxItemHeight = 30f
        shadowOf(Looper.getMainLooper()).idleFor(Duration.ofMillis(100))
        val limit = (list.tagButtonAtIndexPath(CYLIndexPath(0, 0))!!.parent as View).height
        assertTrue(heights(list).values.all { it.size == 1 && it.first() == limit })
        val unlimited = makeList()
        assertTrue("the limit made the tags shorter", limit < (unlimited.tagButtonAtIndexPath(CYLIndexPath(0, 0))!!.parent as View).height)
    }

    private fun descendants(view: View): List<View> =
        if (view is android.view.ViewGroup) (0 until view.childCount).flatMap { val child = view.getChildAt(it); listOf(child) + descendants(child) } else emptyList()

    /** The tail fold control is a tag like the others: it counts for the height of its row and is stretched to it. */
    @Test
    fun theTailFoldCellIsAsTallAsItsRow() {
        val list = makeList(count = 40, tallItem = 0)
        list.foldControl = CYLMenuFoldControl.foldControlWithPosition(CYLMenuFoldControlPosition.TAIL, CYLMenuFoldControlContent.CYLMenuFoldControlContentIcon)
        list.defaultVisibleRows = 1
        list.reloadMenuData()
        shadowOf(Looper.getMainLooper()).idleFor(Duration.ofMillis(100))
        val fold = descendants(list).filterIsInstance<CYLTagFoldCell>().single()
        val first = list.tagButtonAtIndexPath(CYLIndexPath(0, 0))!!.parent as View
        assertTrue(fold.height > 0)
        assertEquals("the fold cell is as tall as its row", first.height, fold.height)
        list.maxItemHeight = 30f
        shadowOf(Looper.getMainLooper()).idleFor(Duration.ofMillis(100))
        val limited = descendants(list).filterIsInstance<CYLTagFoldCell>().single()
        assertTrue("maxItemHeight limits the fold cell too", limited.height <= 30)
    }

    /**
     * The fold cell joins the last visible row first; a tag it pushes out is no member of that row, so its taller height
     * no longer counts for the tags that stay, nor for the content height.
     */
    @Test
    fun tagsPushedOutByTheTailFoldCellDoNotSetTheRowHeight() {
        for (width in 150..400 step 7) {
            val activity = Robolectric.buildActivity(Activity::class.java).setup().get()
            val source = CYLTallFromSource()
            val list = CYLTagListView(activity)
            list.menuDataSource = source
            list.showsSectionHeaders = false
            list.foldControl = CYLMenuFoldControl.foldControlWithPosition(CYLMenuFoldControlPosition.TAIL, CYLMenuFoldControlContent.CYLMenuFoldControlContentIcon)
            list.defaultVisibleRows = 1
            activity.setContentView(FrameLayout(activity).apply { addView(list, FrameLayout.LayoutParams(width, FrameLayout.LayoutParams.WRAP_CONTENT)) })
            list.reloadMenuData()
            shadowOf(Looper.getMainLooper()).idleFor(Duration.ofMillis(100))
            val visible = list.numberOfVisibleItemsInSection(0)
            if (visible >= 40) continue
            val before = list.heightThatFitsWidth(width.toFloat())
            source.tallFrom = visible
            list.reloadMenuData()
            shadowOf(Looper.getMainLooper()).idleFor(Duration.ofMillis(100))
            assertEquals("width $width", visible, list.numberOfVisibleItemsInSection(0))
            assertEquals("a hidden tag sets no row height, width $width", before, list.heightThatFitsWidth(width.toFloat()), 0.5f)
            val fold = descendants(list).filterIsInstance<CYLTagFoldCell>().single()
            for (item in 0 until visible) {
                val cell = list.tagButtonAtIndexPath(CYLIndexPath(item, 0))!!.parent as View
                if (cell.top == fold.top) assertEquals("shown tags share their row's height with the fold cell, width $width", fold.height, cell.height)
            }
        }
    }
}
