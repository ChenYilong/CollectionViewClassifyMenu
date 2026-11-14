package com.cyl.classifymenu

import android.os.Looper
import android.os.SystemClock
import android.view.MotionEvent
import android.view.View
import androidx.test.core.app.ApplicationProvider
import co.lujun.androidtagview.TagContainerLayout
import co.lujun.androidtagview.TagView
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.Shadows.shadowOf
import java.time.Duration

/**
 * Fixes of whilu/AndroidTagView's open issues in the Kotlin port (docs/android-upstream.md).
 */
@RunWith(RobolectricTestRunner::class)
class LujunTagContainerIssuesTest {
    private val context = ApplicationProvider.getApplicationContext<android.content.Context>()
    private val density = context.resources.displayMetrics.density

    private class Listener : TagView.OnTagClickListener {
        var clicks = 0
        var longClicks = 0
        override fun onTagClick(position: Int, text: String) { clicks++ }
        override fun onTagLongClick(position: Int, text: String) { longClicks++ }
        override fun onSelectedTagDrag(position: Int, text: String) {}
        override fun onTagCrossClick(position: Int) {}
    }

    private fun event(action: Int, x: Float, y: Float): MotionEvent {
        val now = SystemClock.uptimeMillis()
        return MotionEvent.obtain(now, now, action, x, y, 0)
    }

    private fun tag(listener: Listener): TagView = TagView(context, "Tag").apply {
        tag = 0
        setIsViewClickable(true)
        setOnTagClickListener(listener)
        measure(View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED), View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED))
        layout(0, 0, measuredWidth, measuredHeight)
    }

    @Test
    fun longPressOfATagWithoutContainerDoesNotCrash() {
        // #25 / #38 / #53 / #83 / #87 / #92: the long press of a tag that left its container crashed (NPE).
        val listener = Listener()
        val view = tag(listener)
        view.dispatchTouchEvent(event(MotionEvent.ACTION_DOWN, 10f, 10f))
        shadowOf(Looper.getMainLooper()).idleFor(Duration.ofMillis(700))
        assertEquals(0, listener.longClicks)
    }

    @Test
    fun cancelledGestureFiresNoLongPress() {
        // #39: a gesture taken over by a parent (ACTION_CANCEL) gives no click and no long press later.
        val listener = Listener()
        val container = TagContainerLayout(context)
        val view = tag(listener)
        container.addView(view)
        view.dispatchTouchEvent(event(MotionEvent.ACTION_DOWN, 10f, 10f))
        view.dispatchTouchEvent(event(MotionEvent.ACTION_CANCEL, 10f, 10f))
        shadowOf(Looper.getMainLooper()).idleFor(Duration.ofMillis(700))
        assertEquals(0, listener.longClicks)
        assertEquals(0, listener.clicks)
    }

    @Test
    fun aSmallMovementStillClicks() {
        // #23 / #32 / #39: a finger moving 6 dp (less than the system's touch slop) still clicks the tag.
        val listener = Listener()
        val view = tag(listener)
        view.dispatchTouchEvent(event(MotionEvent.ACTION_DOWN, 10f, 10f))
        view.dispatchTouchEvent(event(MotionEvent.ACTION_MOVE, 10f + 6 * density, 10f))
        view.dispatchTouchEvent(event(MotionEvent.ACTION_UP, 10f + 6 * density, 10f))
        assertEquals(1, listener.clicks)
    }

    @Test
    fun containerLetsTouchesThroughWithoutDrag() {
        // #21 / #27 / #64 / #108 / #112: without drag the container no longer takes every touch.
        val container = TagContainerLayout(context)
        assertFalse(container.onTouchEvent(event(MotionEvent.ACTION_DOWN, 1f, 1f)))
        container.setDragEnable(true)
        assertTrue(container.onTouchEvent(event(MotionEvent.ACTION_DOWN, 1f, 1f)))
    }

    @Test
    fun containerClickListenerFires() {
        // #108 / #112: without drag, a touch on a container with a click listener goes to View's own handling (a
        // clickable view accepts it and clicks), and the listener fires.
        val container = TagContainerLayout(context)
        var clicks = 0
        container.setOnClickListener { clicks++ }
        container.layout(0, 0, 100, 100)
        assertTrue(container.onTouchEvent(event(MotionEvent.ACTION_DOWN, 5f, 5f)))
        container.performClick()
        assertEquals(1, clicks)
    }

    @Test
    fun interceptToleratesUnknownPointers() {
        // #26: ViewDragHelper's ArrayIndexOutOfBoundsException for a pointer it never saw does not crash.
        val container = TagContainerLayout(context)
        container.setDragEnable(true)
        assertFalse(container.onInterceptTouchEvent(event(MotionEvent.ACTION_MOVE, 5f, 5f)))
    }

    private fun container(tags: Int, width: Int, configure: TagContainerLayout.() -> Unit = {}): TagContainerLayout =
        TagContainerLayout(context).apply {
            configure()
            for (i in 0 until tags) addTag("Tag $i")
            measure(View.MeasureSpec.makeMeasureSpec(width, View.MeasureSpec.EXACTLY), View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED))
            layout(0, 0, measuredWidth, measuredHeight)
        }

    @Test
    fun maxLinesIsAnUpperBound() {
        // #74 / #28: container_max_lines (setMaxLines) limits the height; fewer lines need less height.
        val one = container(1, 1080)
        val limited = container(1, 1080) { setMaxLines(5) }
        assertEquals(5, limited.getMaxLines())
        assertEquals(one.measuredHeight, limited.measuredHeight)
    }

    @Test
    fun linesBeyondMaxLinesScroll() {
        // #58 / #63: with more lines than container_max_lines, a vertical drag scrolls to the others.
        val view = container(30, 300) { setMaxLines(1) }
        assertTrue(view.canScrollVertically(1))
        view.onTouchEvent(event(MotionEvent.ACTION_DOWN, 50f, 40f))
        view.onTouchEvent(event(MotionEvent.ACTION_MOVE, 50f, 10f))
        view.onTouchEvent(event(MotionEvent.ACTION_MOVE, 50f, -400f))
        assertTrue(view.scrollY > 0)
        view.onTouchEvent(event(MotionEvent.ACTION_MOVE, 50f, -100_000f))
        assertFalse(view.canScrollVertically(1))
    }

    @Test
    fun visibleTagCount() {
        // #80: the tags on the visible lines.
        val view = container(30, 300) { setMaxLines(1) }
        assertTrue(view.getVisibleTagCount() in 1 until 30)
        assertEquals(30, container(30, 300).getVisibleTagCount())
    }

    @Test
    fun singleLineForAHorizontalScrollView() {
        // #42 / #106 / #115: one line, as wide as the tags when the width is unspecified (HorizontalScrollView).
        val view = TagContainerLayout(context).apply {
            setSingleLine(true)
            for (i in 0 until 20) addTag("Tag $i")
            measure(View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED), View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED))
            layout(0, 0, measuredWidth, measuredHeight)
        }
        assertTrue(view.measuredWidth >= (0 until view.childCount).sumOf { view.getChildAt(it).measuredWidth })
        assertTrue((0 until view.childCount).all { view.getChildAt(it).top == view.getChildAt(0).top })
    }

    private fun tagAt(view: TagContainerLayout, index: Int) = view.getTagView(index)

    @Test
    fun xmlColorsWithoutAThemeAreUsed() {
        // #57: tag_background_color in XML, without tag_theme, is used (the default theme replaced it).
        val attrs = org.robolectric.Robolectric.buildAttributeSet()
            .addAttribute(com.cyl.classifymenu.R.attr.tag_background_color, "#FFFF0000").build()
        val view = TagContainerLayout(context, attrs)
        view.addTag("red")
        assertEquals(0xFFFF0000.toInt(), tagAt(view, 0).getTagBackgroundColor())
    }

    @Test
    fun colorSettersReachShownTags() {
        // #77: setTheme(NONE) and setTagBackgroundColor change the tags already shown, not only new ones.
        val view = TagContainerLayout(context)
        view.addTag("one")
        view.setTheme(co.lujun.androidtagview.ColorFactory.NONE)
        view.setTagBackgroundColor(android.graphics.Color.WHITE)
        assertEquals(android.graphics.Color.WHITE, tagAt(view, 0).getTagBackgroundColor())
    }

    @Test
    fun tagWithItsOwnColors() {
        // #76 / #20: a tag added with its own colors keeps them; one tag's color can be changed later.
        val view = TagContainerLayout(context)
        view.addTag("own", intArrayOf(0xFF112233.toInt(), 0, 0xFFFFFFFF.toInt(), 0))
        view.addTag("theme")
        view.setTheme(co.lujun.androidtagview.ColorFactory.NONE)
        view.setTagBackgroundColor(android.graphics.Color.WHITE)
        assertEquals(0xFF112233.toInt(), tagAt(view, 0).getTagBackgroundColor())
        tagAt(view, 1).setTagBackgroundColor(android.graphics.Color.BLACK)
        assertEquals(android.graphics.Color.BLACK, tagAt(view, 1).getTagBackgroundColor())
    }

    @Test
    fun selectionOnTapSingleAndColors() {
        // #12 / #22 / #123: a tap selects; #6: single selection; #107: toggleSelectTagView selects; #29 / #114: the
        // selected colors are settable.
        val view = container(3, 1080) {
            setIsTagViewClickable(true)
            setIsTagViewSelectable(true)
            setSelectTagViewOnClick(true)
            setSingleSelection(true)
        }
        view.setSelectedTagBackgroundColor(0xFF00FF00.toInt())
        assertEquals(0xFF00FF00.toInt(), tagAt(view, 0).getTagSelectedBackgroundColor())
        val first = tagAt(view, 0)
        first.dispatchTouchEvent(event(MotionEvent.ACTION_DOWN, 5f, 5f))
        first.dispatchTouchEvent(event(MotionEvent.ACTION_UP, 5f, 5f))
        assertTrue(first.getIsViewSelected())
        view.toggleSelectTagView(1)
        assertTrue(tagAt(view, 1).getIsViewSelected())
        assertFalse(first.getIsViewSelected())
        assertEquals(listOf(1), view.getSelectedTagViewPositions())
    }

    @Test
    fun minimumTagWidth() {
        // #73 / #75: tags at least as wide as tag_min_width (same-size tags).
        val view = container(2, 1080) { setTagMinWidth(400) }
        assertTrue((0 until view.childCount).all { view.getChildAt(it).measuredWidth >= 400 })
    }
}
