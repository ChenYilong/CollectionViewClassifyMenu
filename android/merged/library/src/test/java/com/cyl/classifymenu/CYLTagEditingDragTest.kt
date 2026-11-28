package com.cyl.classifymenu

import android.app.Activity
import android.os.Looper
import android.os.SystemClock
import android.view.MotionEvent
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import android.widget.LinearLayout
import android.widget.ScrollView
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.Robolectric
import org.robolectric.RobolectricTestRunner
import org.robolectric.Shadows.shadowOf
import org.robolectric.annotation.GraphicsMode
import java.time.Duration

/** Tags of one editable section; the data source moves and removes them. */
private class CYLDragSource(val titles: MutableList<String>) : CYLMenuDataSource, CYLMenuDelegate {
    override fun numberOfSectionsInMenu() = 1
    override fun menuNumberOfItemsInSection(section: Int) = titles.size
    override fun menuTitleForSection(section: Int) = "Contacts"
    override fun menuTitleForItemAtIndexPath(indexPath: CYLIndexPath) = titles[indexPath.item]
    override fun menuRemoveItemAtIndexPath(indexPath: CYLIndexPath) { titles.removeAt(indexPath.item) }
    override fun menuMoveItemAtIndexPath(sourceIndexPath: CYLIndexPath, toIndexPath: CYLIndexPath) {
        titles.add(toIndexPath.item, titles.removeAt(sourceIndexPath.item))
    }
    override fun supportsMovingItems() = true
}

/**
 * Dragging a tag in editing mode reorders it, and the pages around the list (an outer `ScrollView`, as a page with a
 * search bar) do not scroll while the drag lasts, and scroll again afterwards.
 */
@RunWith(RobolectricTestRunner::class)
@GraphicsMode(GraphicsMode.Mode.NATIVE)
class CYLTagEditingDragTest {

    private val titles = listOf("Family", "Friends", "Clients", "Neighbours", "Classmates", "Colleagues", "Teachers", "Doctors")

    private fun frames() = shadowOf(Looper.getMainLooper()).idleFor(Duration.ofMillis(100))

    private fun cells(view: View, out: MutableList<CYLTagListCell> = ArrayList()): List<CYLTagListCell> {
        if (view is CYLTagListCell) out.add(view)
        if (view is ViewGroup) for (i in 0 until view.childCount) cells(view.getChildAt(i), out)
        return out
    }

    /** A touch at screen point (x, y) delivered to [root] in its own coordinates, as the window delivers it. */
    private fun touch(root: View, action: Int, downTime: Long, x: Float, y: Float) {
        val location = IntArray(2).also { root.getLocationOnScreen(it) }
        val event = MotionEvent.obtain(downTime, SystemClock.uptimeMillis(), action, x, y, 0)
        event.offsetLocation(-location[0].toFloat(), -location[1].toFloat())
        root.dispatchTouchEvent(event)
        event.recycle()
    }

    private class Page(val activity: Activity, val outer: ScrollView, val list: CYLTagListView, val source: CYLDragSource)

    private fun makePage(): Page {
        val activity = Robolectric.buildActivity(Activity::class.java).setup().get()
        val source = CYLDragSource(titles.toMutableList())
        val list = CYLTagListView(activity)
        list.usePlainSections()
        list.menuDataSource = source
        list.menuDelegate = source
        list.isScrollEnabled = false
        val column = LinearLayout(activity).apply {
            orientation = LinearLayout.VERTICAL
            addView(View(activity), LinearLayout.LayoutParams(10, 120))
            addView(list, LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT))
            addView(View(activity), LinearLayout.LayoutParams(10, 3000))
        }
        val outer = ScrollView(activity).apply { addView(column) }
        activity.setContentView(FrameLayout(activity).apply { addView(outer, FrameLayout.LayoutParams(FrameLayout.LayoutParams.MATCH_PARENT, 600)) })
        list.reloadMenuData()
        list.setEditing(true, animated = false)
        frames()
        return Page(activity, outer, list, source)
    }

    private fun center(view: View): Pair<Float, Float> {
        val location = IntArray(2).also { view.getLocationOnScreen(it) }
        return (location[0] + view.width / 2f) to (location[1] + view.height / 2f)
    }

    @Test
    fun aLongPressAndDragInEditingModeReordersAndLocksTheOuterScroll() {
        val page = makePage()
        val first = cells(page.list).first { it.button.title.toString() == "Family" }
        val last = cells(page.list).first { it.button.title.toString() == "Doctors" }
        val (sx, sy) = center(first)
        val (ex, ey) = center(last)
        val down = SystemClock.uptimeMillis()
        touch(page.outer, MotionEvent.ACTION_DOWN, down, sx, sy)
        shadowOf(Looper.getMainLooper()).idleFor(Duration.ofMillis(800))
        assertTrue("a long press in editing mode starts the drag", page.list.isReordering)
        // Drag first upward-and-down far, the outer view must not scroll while dragging.
        for (step in 1..10) {
            touch(page.outer, MotionEvent.ACTION_MOVE, down, sx + (ex - sx) * step / 10, sy + (ey - sy) * step / 10 + 40 * step)
            frames()
            assertEquals("mid-drag step $step: the outer scroll stays", 0, page.outer.scrollY)
        }
        touch(page.outer, MotionEvent.ACTION_UP, down, ex, ey)
        frames()
        frames()
        assertEquals("the dragged tag moved to the end", "Family", page.source.titles.last())
        assertTrue("the drag ended", !page.list.isReordering)
    }

    @Test
    fun leavingTheWindowEndsADrag() {
        val page = makePage()
        val first = cells(page.list).first { it.button.title.toString() == "Family" }
        val (sx, sy) = center(first)
        touch(page.outer, MotionEvent.ACTION_DOWN, SystemClock.uptimeMillis(), sx, sy)
        shadowOf(Looper.getMainLooper()).idleFor(Duration.ofMillis(800))
        assertTrue(page.list.isReordering)
        (page.outer.parent as ViewGroup).removeView(page.outer)
        assertTrue("a drag does not outlive the list's window", !page.list.isReordering)
        assertEquals("nothing moved", titles, page.source.titles)
    }
}
