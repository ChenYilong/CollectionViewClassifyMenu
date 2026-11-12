package com.cyl.classifymenu

import android.graphics.drawable.GradientDrawable
import android.os.SystemClock
import android.view.MotionEvent
import android.view.View
import android.widget.TextView
import androidx.test.core.app.ApplicationProvider
import com.licrafter.tagview.DIRECTION
import com.licrafter.tagview.TagAdapter
import com.licrafter.tagview.TagViewGroup
import com.licrafter.tagview.views.ITagView
import com.licrafter.tagview.views.TagTextView
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner

/**
 * Fixes and answers of shellljx/TagViewGroup's open issues in the Kotlin port (docs/android-upstream.md).
 */
@RunWith(RobolectricTestRunner::class)
class TagViewGroupIssuesTest {
    private val context = ApplicationProvider.getApplicationContext<android.content.Context>()

    /**
     * A rounded-rectangle tag (issue #9: "like Xiaohongshu"): any view that implements ITagView.
     */
    class RoundedTag(context: android.content.Context) : TextView(context), ITagView {
        private var direction = DIRECTION.RIGHT_CENTER
        init {
            text = "Rounded"
            background = GradientDrawable().apply { cornerRadius = 12f; setColor(0x99000000.toInt()) }
        }
        override fun setDirection(direction: DIRECTION) { this.direction = direction }
        override fun getDirection() = direction
    }

    private fun group(item: ITagView): TagViewGroup = TagViewGroup(context).apply {
        setTagAdapter(object : TagAdapter() {
            override fun getCount() = 1
            override fun getItem(position: Int) = item
        })
    }

    @Test
    fun issue9CustomTagViews() {
        // #8 / #9: a custom ITagView is laid out like the built-in TagTextView.
        val view = group(RoundedTag(context))
        view.measure(View.MeasureSpec.makeMeasureSpec(1080, View.MeasureSpec.AT_MOST), View.MeasureSpec.makeMeasureSpec(1920, View.MeasureSpec.AT_MOST))
        assertTrue(view.getChildAt(view.childCount - 1) is RoundedTag)
    }

    @Test
    fun issue7WrapContentDoesNotFillAndTouchesPassThrough() {
        // #7: wrap_content measures the tags (not the whole parent), and a touch outside the dot and tags is not taken,
        // so a ViewPager behind still swipes; no drag listener, no intercepted swipe.
        val view = group(TagTextView(context).apply { text = "Tag" })
        view.measure(View.MeasureSpec.makeMeasureSpec(1080, View.MeasureSpec.AT_MOST), View.MeasureSpec.makeMeasureSpec(1920, View.MeasureSpec.AT_MOST))
        assertTrue(view.measuredWidth < 1080)
        assertTrue(view.measuredHeight < 1920)
        // Laid out over the whole page (as in a ViewPager), a touch far from the dot and the tags is not taken.
        view.layout(0, 0, 1080, 1920)
        val now = SystemClock.uptimeMillis()
        val down = MotionEvent.obtain(now, now, MotionEvent.ACTION_DOWN, 1000f, 1800f, 0)
        assertFalse(view.onTouchEvent(down))
        down.recycle()
    }
}
