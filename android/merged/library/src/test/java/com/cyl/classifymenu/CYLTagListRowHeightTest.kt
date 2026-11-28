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

/** Every row is as tall as its tallest tag, and `maxItemHeight` limits it (iOS CYLTagListLayoutTests). */
@RunWith(RobolectricTestRunner::class)
@GraphicsMode(GraphicsMode.Mode.NATIVE)
class CYLTagListRowHeightTest {

    private fun makeList(): CYLTagListView {
        val activity = Robolectric.buildActivity(Activity::class.java).setup().get()
        val tall = CYLMenuStyle().apply { itemHeight = 80f }
        val list = CYLTagListView(activity)
        list.menuDataSource = CYLRowHeightSource(12, 1, tall)
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
}
