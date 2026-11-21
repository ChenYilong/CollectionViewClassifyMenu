package com.cyl.classifymenu

import android.app.Activity
import android.os.Looper
import android.os.SystemClock
import android.view.MotionEvent
import android.view.View
import android.widget.FrameLayout
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.Robolectric
import org.robolectric.RobolectricTestRunner
import org.robolectric.Shadows.shadowOf
import org.robolectric.annotation.Config
import org.robolectric.annotation.GraphicsMode
import java.time.Duration

/**
 * The word picker (选词填入, iOS cf5d9f7e): one cell per character, 9 equal cells per row, the picked text in text order,
 * and smear selection driven by real touch events on the cells.
 */
@RunWith(RobolectricTestRunner::class)
@GraphicsMode(GraphicsMode.Mode.NATIVE)
@Config(qualifiers = "w411dp-h914dp-420dpi")
class CYLWordPickerTest {

    private val message = "Hi, I'm Alex from Design 👋"

    private class Recorder : CYLMenuDelegate {
        var changes = 0
        override fun menuDidChangeSelectedItems(menu: Any, indexPaths: List<CYLIndexPath>) {
            changes++
        }
    }

    private fun frames() = shadowOf(Looper.getMainLooper()).idleFor(Duration.ofMillis(100))

    private fun wordPicker(text: String): CYLTagListView {
        val activity = Robolectric.buildActivity(Activity::class.java).setup().get()
        val list = CYLTagListView(activity)
        list.style = CYLMenuStyle.wordPicker()
        list.selectionMode = CYLMenuSelectionMode.CYLMenuSelectionModeMultiple
        list.allowsSmearSelection = true
        list.setTagsWithCharactersOfText(text)
        activity.setContentView(FrameLayout(activity).apply { addView(list, FrameLayout.LayoutParams(FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.MATCH_PARENT)) })
        frames()
        return list
    }

    private fun cell(list: CYLTagListView, item: Int): CYLTagListCell = list.tagButtonAtIndexPath(CYLIndexPath(item, 0))!!.parent as CYLTagListCell

    /** Records the gesture state callbacks in order. */
    private class GestureRecorder : CYLMenuDelegate {
        val events = ArrayList<String>()
        override fun menuDidChangeReordering(menu: Any, reordering: Boolean) {
            events.add("reordering $reordering")
        }

        override fun menuDidChangeSmearing(menu: Any, smearing: Boolean) {
            events.add("smearing $smearing")
        }
    }

    @Test
    fun gestureStateCallbacksComeInPairs() {
        // As the mini program's reorderingchange / smearingchange: true at the start, false at the drop or the cancel.
        val list = wordPicker("ABCDEFGHIJ")
        val recorder = GestureRecorder()
        list.menuDelegate = recorder
        // A smear.
        val first = cell(list, 0)
        touch(list, first, MotionEvent.ACTION_DOWN, 0)
        touch(list, first, MotionEvent.ACTION_MOVE, 3)
        touch(list, first, MotionEvent.ACTION_UP, 3)
        // A drag (long press, move, drop), then a cancelled drag.
        list.allowsSmearSelection = false
        list.allowsReordering = true
        frames()
        fun longPress(item: Int): View {
            val target = cell(list, item)
            touch(list, target, MotionEvent.ACTION_DOWN, item)
            shadowOf(Looper.getMainLooper()).idleFor(Duration.ofMillis(800))
            return target
        }
        val dragged = longPress(1)
        touch(list, dragged, MotionEvent.ACTION_MOVE, 4)
        touch(list, dragged, MotionEvent.ACTION_UP, 4)
        val cancelled = longPress(2)
        touch(list, cancelled, MotionEvent.ACTION_CANCEL, 2)
        assertEquals(listOf("smearing true", "smearing false", "reordering true", "reordering false",
            "reordering true", "reordering false"), recorder.events)
    }

    @Test
    fun cellsAndPickedText() {
        val list = wordPicker(message)
        val titles = list.tags.map { it.title }
        assertEquals("one cell per character (graphemes)", message.codePoints().count().toInt(), titles.size)
        assertEquals(message, titles.joinToString(""))
        assertTrue("an emoji is one cell", titles.contains("👋"))
        assertEquals("keeps the multiple selection", CYLMenuSelectionMode.CYLMenuSelectionModeMultiple, list.selectionMode)
        val first = cell(list, 0)
        val ninth = cell(list, 8)
        val tenth = cell(list, 9)
        assertEquals("equal cells", first.width.toFloat(), ninth.width.toFloat(), 1.5f)
        assertEquals("9 per row", first.top, ninth.top)
        assertTrue("the 10th starts the second row", tenth.top > first.bottom)
        val space = titles.indexOf(" ")
        assertEquals("a space is read, not silent", CYLMenuLocalizedString("CYLMenuSpaceCharacter", ""), cell(list, space).contentDescription)
        // The name, wherever it stands in the message (either order of the ends).
        val start = titles.joinToString("").let { text -> text.codePointCount(0, text.indexOf("Alex")) }
        list.selectItemsFromIndexPath(CYLIndexPath(start + 3, 0), CYLIndexPath(start, 0))
        assertEquals("Alex", list.selectedText)
        list.deselectAllItems()
        assertEquals("", list.selectedText)
    }

    /** Sends a touch event at the center of `item`'s cell to `target` (the cell the finger went down on). */
    private fun touch(list: CYLTagListView, target: View, action: Int, item: Int) {
        val over = cell(list, item)
        val location = IntArray(2)
        over.getLocationOnScreen(location)
        val rawX = location[0] + over.width / 2f
        val rawY = location[1] + over.height / 2f
        val own = IntArray(2)
        target.getLocationOnScreen(own)
        val now = SystemClock.uptimeMillis()
        // Made at the screen point (getRawX / getRawY), then moved into the target's own coordinates.
        val event = MotionEvent.obtain(now, now, action, rawX, rawY, 0)
        event.setLocation(rawX - own[0], rawY - own[1])
        target.dispatchTouchEvent(event)
        frames()
    }

    @Test
    fun severalSmearsAddUp() {
        // Owner's check (iOS testSeveralSmearsAddUp): each smear adds its range to the selection it began with.
        val list = wordPicker(message)
        val text = list.tags.joinToString("") { it.title }
        fun cellOf(index: Int) = text.codePointCount(0, index)
        fun smear(from: Int, to: Int) {
            val target = cell(list, from)
            touch(list, target, MotionEvent.ACTION_DOWN, from)
            touch(list, target, MotionEvent.ACTION_MOVE, (from + to) / 2)
            touch(list, target, MotionEvent.ACTION_MOVE, to)
            touch(list, target, MotionEvent.ACTION_UP, to)
        }
        val alex = cellOf(text.indexOf("Alex"))
        smear(alex, alex + 3)
        assertEquals("Alex", list.selectedText)
        // The second starts on the space before "Design".
        val design = cellOf(text.indexOf(" Design"))
        smear(design, design + 6)
        assertEquals("Alex Design", list.selectedText)
        // One that starts on a selected cell removes its range.
        smear(alex, alex + 3)
        assertEquals(" Design", list.selectedText)
    }

    @Test
    fun smearSelectsAndDeselectsARange() {
        val list = wordPicker("ABCDEFGHIJKL")
        val recorder = Recorder()
        list.menuDelegate = recorder
        fun smear(from: Int, vararg through: Int) {
            val target = cell(list, from)
            touch(list, target, MotionEvent.ACTION_DOWN, from)
            through.forEach { touch(list, target, MotionEvent.ACTION_MOVE, it) }
            touch(list, target, MotionEvent.ACTION_UP, through.last())
        }
        smear(2, 4, 10)
        assertEquals("from C across the row break to K", "CDEFGHIJK", list.selectedText)
        assertTrue(recorder.changes >= 2)
        smear(0, 1)
        assertEquals("ABCDEFGHIJK", list.selectedText)
        smear(5, 7)
        assertEquals("starting on a selected cell deselects", "ABCDEIJK", list.selectedText)
        // A tap still toggles one cell.
        val target = cell(list, 11)
        touch(list, target, MotionEvent.ACTION_DOWN, 11)
        touch(list, target, MotionEvent.ACTION_UP, 11)
        assertEquals("ABCDEIJKL", list.selectedText)
        // Only in multiple selection.
        list.selectionMode = CYLMenuSelectionMode.CYLMenuSelectionModeSingle
        list.deselectAllItems()
        smear(0, 3)
        assertTrue(list.selectedIndexPaths.size <= 1)
    }
}
