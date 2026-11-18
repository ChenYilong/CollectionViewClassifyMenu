package com.cyl.classifymenu

import android.os.Looper
import android.os.SystemClock
import android.view.MotionEvent
import android.view.View
import android.view.ViewGroup
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

/**
 * Dragging a tag keeps every title whole (iOS a4517a3c fixed titles cut "Kot…" mid-drag, where the collection view showed
 * the new order with the old widths). On Android the dragged cell only translates and the titles and widths reload
 * together after the drop, so each tag keeps the width of its own title during and after the move.
 */
@RunWith(RobolectricTestRunner::class)
@GraphicsMode(GraphicsMode.Mode.NATIVE)
class CYLTagReorderWidthTest {

    private val titles = listOf("Swift", "Kotlin", "ArkTS", "Dart", "TypeScript", "Objective-C", "Java", "C++", "Rust", "Go")

    private fun cells(view: View, out: MutableList<CYLTagListCell> = ArrayList()): List<CYLTagListCell> {
        if (view is CYLTagListCell) out.add(view)
        if (view is ViewGroup) for (i in 0 until view.childCount) cells(view.getChildAt(i), out)
        return out
    }

    /** Title -> cell width (px). */
    private fun widths(list: CYLTagListView): Map<String, Int> =
        cells(list).filter { it.visibility == View.VISIBLE && it.width > 0 }.associate { it.button.title.toString() to it.width }

    /** Runs the main looper through a few frames, so requested layouts happen. */
    private fun frames() = shadowOf(Looper.getMainLooper()).idleFor(Duration.ofMillis(100))

    /** A touch at screen point (x, y), delivered to [view] in its own coordinates. */
    private fun touch(view: View, action: Int, downTime: Long, x: Float, y: Float) {
        val location = IntArray(2).also { view.getLocationOnScreen(it) }
        val event = MotionEvent.obtain(downTime, SystemClock.uptimeMillis(), action, x, y, 0)
        event.offsetLocation(-location[0].toFloat(), -location[1].toFloat())
        view.dispatchTouchEvent(event)
        event.recycle()
    }

    @Test
    fun aDraggedTagAndItsNeighboursKeepTheWidthOfTheirOwnTitles() {
        val context = Robolectric.buildActivity(android.app.Activity::class.java).setup().get()
        val list = CYLTagListView(context)
        list.setTagsWithTitles(titles)
        list.allowsReordering = true
        var moved: Pair<Int, Int>? = null
        list.tagMoveHandler = { from, to -> moved = from to to }
        val host = FrameLayout(context).apply { addView(list, FrameLayout.LayoutParams(FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.MATCH_PARENT)) }
        context.setContentView(host)
        frames()
        val before = widths(list)
        assertEquals("every tag is laid out", titles.toSet(), before.keys)
        assertTrue("the titles differ in width (the check means something)", before["Kotlin"] != before["Go"])

        val kotlin = cells(list).first { it.button.title.toString() == "Kotlin" }
        val go = cells(list).first { it.button.title.toString() == "Go" }
        val start = IntArray(2).also { kotlin.getLocationOnScreen(it) }
        val end = IntArray(2).also { go.getLocationOnScreen(it) }
        val sx = start[0] + kotlin.width / 2f
        val sy = start[1] + kotlin.height / 2f
        val ex = end[0] + go.width / 2f
        val ey = end[1] + go.height / 2f
        val down = SystemClock.uptimeMillis()
        touch(kotlin, MotionEvent.ACTION_DOWN, down, sx, sy)
        shadowOf(Looper.getMainLooper()).idleFor(Duration.ofMillis(800))
        assertTrue("a long press starts the drag", list.isReordering)
        for (step in 1..10) {
            touch(kotlin, MotionEvent.ACTION_MOVE, down, sx + (ex - sx) * step / 10, sy + (ey - sy) * step / 10)
            frames()
            assertEquals("mid-drag step $step: each tag keeps its own title's width", before, widths(list))
        }
        touch(kotlin, MotionEvent.ACTION_UP, down, ex, ey)
        frames()
        assertEquals("right after the drop", before, widths(list))
        frames()
        assertEquals("the move is reported", 1 to 9, moved)
        assertEquals("after the reload each tag still has its own title's width", before, widths(list))
    }
}
