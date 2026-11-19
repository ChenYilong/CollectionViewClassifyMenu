package co.lujun.androidtagview

import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.ColorDrawable
import android.view.View.MeasureSpec
import androidx.test.core.app.ApplicationProvider
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config
import org.robolectric.annotation.GraphicsMode

/**
 * Delete icon (cross) fixes of whilu/AndroidTagView's open issues in the Kotlin port (docs/android-upstream.md).
 * In the library's package, for the internal `crossBounds()`.
 */
@RunWith(RobolectricTestRunner::class)
@GraphicsMode(GraphicsMode.Mode.NATIVE)
@Config(sdk = [34])
class LujunCrossIssuesTest {
    private val context = ApplicationProvider.getApplicationContext<android.content.Context>()
    private val unspecified = MeasureSpec.makeMeasureSpec(0, MeasureSpec.UNSPECIFIED)

    private fun container(vararg tags: String, setup: TagContainerLayout.() -> Unit = {}) =
        TagContainerLayout(context).apply {
            setup()
            tags.forEach { addTag(it) }
            measure(MeasureSpec.makeMeasureSpec(1080, MeasureSpec.EXACTLY), unspecified)
            layout(0, 0, measuredWidth, measuredHeight)
        }

    @Test
    fun crossIsVisibleWithALargePadding() {
        // #111: a padding of half the square or more (the 10 dp default on a small tag) shrank the cross to a point.
        val view = container("Tag") {
            setEnableCross(true)
            setCrossAreaPadding(100f)
        }
        val bounds = view.getTagView(0).crossBounds()
        val side = view.getTagView(0).measuredHeight
        assertTrue(bounds.width() >= side / 3f - 1)
        assertTrue(bounds.height() >= side / 3f - 1)
    }

    @Test
    fun crossDrawableReplacesTheLines() {
        // #70 / #118: the cross (delete icon) can be any drawable.
        val view = container("Tag") {
            setEnableCross(true)
            setCrossDrawable(android.R.drawable.ic_delete)
        }
        val tag = view.getTagView(0)
        val drawable = tag.getCrossDrawable()
        assertNotNull(drawable)
        tag.draw(Canvas(Bitmap.createBitmap(tag.width, tag.height, Bitmap.Config.ARGB_8888)))
        val bounds = tag.crossBounds()
        assertEquals(bounds.left.toInt(), drawable!!.bounds.left, 1)
        assertEquals(bounds.right.toInt(), drawable.bounds.right, 1)
        view.setCrossDrawable(0)
        assertNull(tag.getCrossDrawable())
        tag.setCrossDrawable(ColorDrawable())
        assertNotNull(tag.getCrossDrawable())
    }

    @Test
    fun crossOnEveryTagAndNotOnOne() {
        // #78: tag_enable_cross / setEnableCross(true) adds the delete icon; #119: one tag without it.
        val view = container("+ Add", "Abd", "def") { setEnableCross(true) }
        assertTrue((0 until 3).all { view.getTagView(it).isEnableCross() })
        val before = view.getTagView(0).measuredWidth
        view.setTagCrossEnabled(0, false)
        view.measure(MeasureSpec.makeMeasureSpec(1080, MeasureSpec.EXACTLY), unspecified)
        assertFalse(view.getTagView(0).isEnableCross())
        assertTrue(view.getTagView(1).isEnableCross())
        assertTrue(view.getTagView(0).measuredWidth < before)
    }
}

private fun assertEquals(expected: Int, actual: Int, delta: Int) =
    assertTrue("expected $expected ± $delta, was $actual", kotlin.math.abs(expected - actual) <= delta)
