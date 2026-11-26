package com.cyl.classifymenu

import android.app.Activity
import android.os.Looper
import android.os.SystemClock
import android.view.MotionEvent
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.Robolectric
import org.robolectric.RobolectricTestRunner
import org.robolectric.Shadows.shadowOf
import org.robolectric.annotation.GraphicsMode
import java.time.Duration

/** Three items; the second has a subtitle. Records the long presses it is told about. */
private class CYLSubtitleSource : CYLMenuDataSource, CYLMenuDelegate {
    val longPresses = ArrayList<Int>()
    override fun numberOfSectionsInMenu() = 1
    override fun menuNumberOfItemsInSection(section: Int) = 3
    override fun menuTitleForSection(section: Int) = "S"
    override fun menuTitleForItemAtIndexPath(indexPath: CYLIndexPath) = listOf("x", "y", "z")[indexPath.item]
    override fun menuSubtitleForItemAtIndexPath(indexPath: CYLIndexPath): String? = if (indexPath.item == 1) "about y" else null
    override fun menuDidLongPressItemAtIndexPath(menu: Any, indexPath: CYLIndexPath) { longPresses.add(indexPath.item) }
    override fun handlesLongPress() = true
}

/** A custom action that follows the finger, to check the end and the cancel reach the action that began. */
private class CYLFollowingAction : CYLTagLongPressAction {
    val log = ArrayList<String>()
    override fun canBegin(host: CYLTagLongPressHost, indexPath: CYLIndexPath) = indexPath.item == 1
    override fun begin(host: CYLTagLongPressHost, indexPath: CYLIndexPath): Boolean {
        log.add("begin ${indexPath.item}")
        return true
    }
    override fun end(host: CYLTagLongPressHost, destination: CYLIndexPath?, moved: Boolean) { log.add("end $moved") }
    override fun cancel(host: CYLTagLongPressHost) { log.add("cancel") }
}

/**
 * The long-press action of a list (`CYLTagListView.longPressAction`): the default keeps the behavior before the API
 * (reordering where the list can reorder, else the long press is reported; the reordering itself is
 * CYLTagEditingDragTest), and the built-in, combined and custom actions replace it. The contract is
 * docs/tag-long-press-action.md.
 */
@RunWith(RobolectricTestRunner::class)
@GraphicsMode(GraphicsMode.Mode.NATIVE)
class CYLTagLongPressActionTest {

    private class Page(val activity: Activity, val root: FrameLayout, val list: CYLTagListView, val source: CYLSubtitleSource)

    private fun frames() = shadowOf(Looper.getMainLooper()).idleFor(Duration.ofMillis(100))

    private fun makePage(): Page {
        val activity = Robolectric.buildActivity(Activity::class.java).setup().get()
        val source = CYLSubtitleSource()
        val list = CYLTagListView(activity)
        list.menuDataSource = source
        list.menuDelegate = source
        val root = FrameLayout(activity).apply { addView(list, FrameLayout.LayoutParams(FrameLayout.LayoutParams.MATCH_PARENT, 600)) }
        activity.setContentView(root)
        list.reloadMenuData()
        frames()
        return Page(activity, root, list, source)
    }

    private fun cells(view: View, out: MutableList<CYLTagListCell> = ArrayList()): List<CYLTagListCell> {
        if (view is CYLTagListCell) out.add(view)
        if (view is ViewGroup) for (i in 0 until view.childCount) cells(view.getChildAt(i), out)
        return out
    }

    private fun center(view: View): Pair<Float, Float> {
        val location = IntArray(2).also { view.getLocationOnScreen(it) }
        return (location[0] + view.width / 2f) to (location[1] + view.height / 2f)
    }

    private fun touch(page: Page, action: Int, downTime: Long, x: Float, y: Float) {
        val location = IntArray(2).also { page.root.getLocationOnScreen(it) }
        val event = MotionEvent.obtain(downTime, SystemClock.uptimeMillis(), action, x, y, 0)
        event.offsetLocation(-location[0].toFloat(), -location[1].toFloat())
        page.root.dispatchTouchEvent(event)
        event.recycle()
    }

    /** Presses the item [title] and holds it until the long press is recognized, then lifts the finger. */
    private fun longPress(page: Page, title: String) {
        val cell = cells(page.list).first { it.button.title.toString() == title }
        val (x, y) = center(cell)
        val down = SystemClock.uptimeMillis()
        touch(page, MotionEvent.ACTION_DOWN, down, x, y)
        shadowOf(Looper.getMainLooper()).idleFor(Duration.ofMillis(800))
        touch(page, MotionEvent.ACTION_UP, down, x, y)
        frames()
    }

    private fun tap(page: Page, title: String) {
        val cell = cells(page.list).first { it.button.title.toString() == title }
        val (x, y) = center(cell)
        val down = SystemClock.uptimeMillis()
        touch(page, MotionEvent.ACTION_DOWN, down, x, y)
        touch(page, MotionEvent.ACTION_UP, down, x, y)
        frames()
    }

    @Test
    fun theDefaultReportsALongPressWhenTheListCannotReorder() {
        val page = makePage()
        longPress(page, "x")
        assertEquals(listOf(0), page.source.longPresses)
        assertNull(page.list.calloutText)
    }

    @Test
    fun calloutShowsTheSubtitleReportsAndATapDismissesIt() {
        val page = makePage()
        page.list.longPressAction = CYLTagLongPressActions.first(listOf(CYLTagLongPressActions.callout, CYLTagLongPressActions.report))
        // An item without a subtitle: no callout, the long press is still reported by the next action.
        longPress(page, "x")
        assertNull(page.list.calloutText)
        assertEquals(listOf(0), page.source.longPresses)
        // An item with one: the callout shows its text and the long press is reported too.
        longPress(page, "y")
        assertEquals("about y", page.list.calloutText)
        assertEquals(listOf(0, 1), page.source.longPresses)
        // A tap elsewhere dismisses the callout.
        tap(page, "z")
        assertNull(page.list.calloutText)
    }

    @Test
    fun theCalloutStaysAfterTheFingerLiftsAndTheNextTouchDownDismissesIt() {
        val page = makePage()
        page.list.longPressAction = CYLTagLongPressActions.callout
        longPress(page, "y")
        assertEquals("about y", page.list.calloutText)
        // The popup must not dismiss itself on an outside touch: that made it vanish when the finger that began the press lifted.
        val field = CYLTagListView::class.java.getDeclaredField("calloutPopup").apply { isAccessible = true }
        val popup = field.get(page.list) as android.widget.PopupWindow
        assertFalse(popup.isOutsideTouchable)
        val down = android.view.MotionEvent.obtain(0L, 0L, android.view.MotionEvent.ACTION_DOWN, 1f, 1f, 0)
        page.list.dispatchTouchEvent(down)
        down.recycle()
        assertNull(page.list.calloutText)
    }

    @Test
    fun noneAndHandlerReplaceTheBuiltInBehavior() {
        val page = makePage()
        page.list.longPressAction = CYLTagLongPressActions.none
        longPress(page, "x")
        assertTrue(page.source.longPresses.isEmpty())
        val seen = ArrayList<String>()
        page.list.longPressAction = CYLTagLongPressActions.handler { host, indexPath ->
            seen.add("handler ${indexPath.item} ${host.canReorderItem(indexPath)}")
            host.showCallout("item ${indexPath.item}", indexPath)
        }
        longPress(page, "z")
        assertEquals(listOf("handler 2 false"), seen)
        assertEquals("item 2", page.list.calloutText)
        // No built-in action ran: nothing was reported.
        assertTrue(page.source.longPresses.isEmpty())
        page.list.longPressAction = CYLTagLongPressActions.none
        assertNull(page.list.calloutText)
    }

    @Test
    fun firstGivesThePressToTheFirstActionThatCanBegin() {
        val page = makePage()
        val following = CYLFollowingAction()
        page.list.longPressAction = CYLTagLongPressActions.first(listOf(following, CYLTagLongPressActions.report))
        longPress(page, "x")
        assertTrue(following.log.isEmpty())
        assertEquals(listOf(0), page.source.longPresses)
        assertFalse(page.list.reordering)
    }

    @Test
    fun aConfigurationNamesTheActionAndTheSubtitle() {
        val activity = Robolectric.buildActivity(Activity::class.java).setup().get()
        val list = CYLTagListView.tagListViewWithConfiguration(activity, mapOf(
            CYLTagListViewLongPressAction to "callout",
            CYLTagListViewSections to listOf(mapOf(CYLTagSectionItems to listOf(
                mapOf(CYLTagItemTitle to "a", CYLTagItemSubtitle to "about a"), "b")))))
        val source = list.menuDataSource!!
        assertEquals("about a", source.menuSubtitleForItemAtIndexPath(CYLIndexPath(0, 0)))
        assertNull(source.menuSubtitleForItemAtIndexPath(CYLIndexPath(1, 0)))
    }
}
