package co.lujun.androidtagview

import android.os.Looper
import android.view.View.MeasureSpec
import androidx.customview.widget.ViewDragHelper
import androidx.test.core.app.ApplicationProvider
import com.cyl.classifymenu.R
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertSame
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.Robolectric
import org.robolectric.RobolectricTestRunner
import org.robolectric.Shadows.shadowOf
import java.time.Duration

/**
 * API, drag and resource fixes of whilu/AndroidTagView's open issues in the Kotlin port (docs/android-upstream.md).
 */
@RunWith(RobolectricTestRunner::class)
class LujunTagApiIssuesTest {
    private val context = ApplicationProvider.getApplicationContext<android.content.Context>()

    private fun TagContainerLayout.measureAndLayout() {
        measure(MeasureSpec.makeMeasureSpec(1080, MeasureSpec.EXACTLY), MeasureSpec.makeMeasureSpec(0, MeasureSpec.UNSPECIFIED))
        layout(0, 0, measuredWidth, measuredHeight)
    }

    private fun container(vararg tags: String) = TagContainerLayout(context).apply {
        setTags(tags.toList())
        measureAndLayout()
    }

    @Test
    fun draggedTagIsDrawnAboveTheOthers() {
        // #7: a dragged tag went under the tags after it.
        val view = container("One", "Two", "Three", "Four", "Five")
        view.setDragEnable(true)
        val dragged = view.getTagView(2)
        view.dragHelper().captureChildView(dragged, 0)
        assertTrue((0 until 5).filter { it != 2 }.all { dragged.translationZ > view.getTagView(it).translationZ })
    }

    @Test
    fun reorderSlidesTheOtherTags() {
        // #24: after a reorder the other tags jumped to their new places; they slide.
        val view = container("One", "Two", "Three")
        val twoBefore = view.getTagView(1).left
        view.moveTag(0, 2)
        view.measureAndLayout()
        assertEquals(listOf("Two", "Three", "One"), view.getTags())
        val two = view.getTagView(0)
        assertEquals((twoBefore - two.left).toFloat(), two.translationX, 0.5f)
        shadowOf(Looper.getMainLooper()).idleFor(Duration.ofMillis(500))
        assertEquals(0f, two.translationX, 0.01f)
    }

    @Test
    fun getAllTagsAndRemoveByText() {
        // #117: all tags, in their current order; #121: a tag's position from its text, to remove it.
        val view = container("A", "B", "C")
        view.addTag("D")
        view.removeTag(0)
        assertEquals(listOf("B", "C", "D"), view.getTags())
        assertEquals(1, view.indexOfTag("C"))
        assertEquals(-1, view.indexOfTag("A"))
        assertTrue(view.removeTag("C"))
        assertFalse(view.removeTag("C"))
        assertEquals(listOf("B", "D"), view.getTags())
    }

    @Test
    fun inflatesFromXmlAttributes() {
        // #95 / #96: inflating TagContainerLayout from XML crashed (InflateException, NoClassDefFoundError of
        // androidx ViewDragHelper$Callback). The port is AndroidX-native and declares androidx.customview.
        val attrs = Robolectric.buildAttributeSet()
            .addAttribute(R.attr.tag_theme, "none")
            .addAttribute(R.attr.container_enable_drag, "true")
            .addAttribute(R.attr.tag_max_length, "10")
            .build()
        val view = TagContainerLayout(context, attrs)
        view.setTags(listOf("Inflated"))
        view.measureAndLayout()
        assertEquals(10, view.getTagMaxLength())
        assertNotNull(ViewDragHelper.Callback::class.java)
    }

    @Test
    fun defaultImageIsDecodedOnceAndShared() {
        // #86: every tag decoded its own full-size copy of the default image; the sample ran out of memory.
        val first = TagView(context, "A", android.R.drawable.ic_menu_gallery)
        val second = TagView(context, "B", android.R.drawable.ic_menu_gallery)
        assertNotNull(first.getImage())
        assertSame(first.getImage(), second.getImage())
        assertTrue(first.getImage()!!.width <= 512)
    }
}
