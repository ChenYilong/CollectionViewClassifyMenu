package com.cyl.classifymenu

import android.graphics.drawable.ColorDrawable
import android.view.Gravity
import android.view.View.MeasureSpec
import androidx.test.core.app.ApplicationProvider
import co.lujun.androidtagview.TagContainerLayout
import co.lujun.androidtagview.TagView
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config
import org.robolectric.annotation.GraphicsMode

/**
 * Tag layout fixes of whilu/AndroidTagView's open issues in the Kotlin port (docs/android-upstream.md).
 */
@RunWith(RobolectricTestRunner::class)
@GraphicsMode(GraphicsMode.Mode.NATIVE)
@Config(sdk = [34]) // native text metrics (StaticLayout, breakText)
class LujunTagLayoutIssuesTest {
    private val context = ApplicationProvider.getApplicationContext<android.content.Context>()
    private val longText = "A very long tag text that is much wider than the narrow container it is shown in"

    private fun spec(size: Int, mode: Int) = MeasureSpec.makeMeasureSpec(size, mode)
    private val unspecified = spec(0, MeasureSpec.UNSPECIFIED)

    private fun container(vararg tags: String, setup: TagContainerLayout.() -> Unit = {}) =
        TagContainerLayout(context).apply {
            setup()
            tags.forEach { addTag(it) }
        }

    private fun TagContainerLayout.measureAndLayout(width: Int, mode: Int) {
        measure(spec(width, mode), unspecified)
        layout(0, 0, measuredWidth, measuredHeight)
    }

    private fun measuredTag(text: String, setup: TagView.() -> Unit = {}) = TagView(context, text).apply {
        setTextSize(40f)
        setHorizontalPadding(20)
        setVerticalPadding(10)
        setup()
        measure(unspecified, unspecified)
    }

    @Test
    fun wrapContentIsAsWideAsTheTags() {
        // #17 / #100: wrap_content filled the parent's whole width.
        val view = container("One", "Two")
        view.measureAndLayout(1080, MeasureSpec.AT_MOST)
        val first = view.getTagView(0)
        val second = view.getTagView(1)
        val tags = first.measuredWidth + second.measuredWidth + (second.left - first.right)
        assertEquals(view.paddingLeft + view.paddingRight + tags, view.measuredWidth)
        assertTrue(view.measuredWidth < 1080)
    }

    @Test
    fun longTagWithCrossFitsTheContainer() {
        // #60 / #66: a long tag (with a cross) was wider than the container and cut off; its text is shortened.
        val view = container(longText) {
            setTagMaxLength(200)
            setEnableCross(true)
        }
        view.measureAndLayout(300, MeasureSpec.EXACTLY)
        val tag = view.getTagView(0)
        assertTrue(tag.measuredWidth <= 300 - view.paddingLeft - view.paddingRight)
        assertTrue(tag.getDisplayedText().endsWith("…"))
        assertEquals(longText, tag.getText())
    }

    @Test
    fun longTagTextWrapsWhenAsked() {
        // #19: the text of a tag wider than the container wraps onto more lines.
        val single = container("Short").apply { measureAndLayout(300, MeasureSpec.EXACTLY) }.getTagView(0)
        val view = container(longText) {
            setTagMaxLength(200)
            setTagTextWrap(true)
        }
        view.measureAndLayout(300, MeasureSpec.EXACTLY)
        val tag = view.getTagView(0)
        assertTrue(tag.getTextLineCount() > 1)
        assertTrue(tag.measuredHeight > single.measuredHeight)
        assertTrue(tag.measuredWidth <= 300)
        assertTrue(view.measuredHeight >= tag.measuredHeight)
    }

    @Test
    fun minimumHeightIsHonoured() {
        // #34: android:minHeight was ignored.
        val view = container("One") { minimumHeight = 500 }
        view.measureAndLayout(1080, MeasureSpec.EXACTLY)
        assertEquals(500, view.measuredHeight)
        val empty = container { minimumHeight = 300 }
        empty.measureAndLayout(1080, MeasureSpec.EXACTLY)
        assertEquals(300, empty.measuredHeight)
    }

    @Test
    fun startAndEndGravity() {
        // #68: Gravity.START and Gravity.END (relative to the layout direction) were not supported.
        val end = container("One", "Two") { setGravity(Gravity.END) }
        end.measureAndLayout(1080, MeasureSpec.EXACTLY)
        assertEquals(1080 - end.paddingRight, end.getTagView(0).right)
        val start = container("One", "Two") { setGravity(Gravity.START) }
        start.measureAndLayout(1080, MeasureSpec.EXACTLY)
        assertEquals(start.paddingLeft, start.getTagView(0).left)
    }

    @Test
    fun tagsHaveElevation() {
        // #79: tags could not have an elevation (shadow); the outline follows the rounded corners.
        val view = container("One") { setTagElevation(6f) }
        assertEquals(6f, view.getTagView(0).elevation)
        assertNotNull(view.getTagView(0).outlineProvider)
    }

    @Test
    fun drawablesAroundTheText() {
        // #101: drawables at the start, top, end and bottom of the text.
        val plain = measuredTag("Tag")
        val sides = measuredTag("Tag") {
            setTagDrawablePadding(8)
            setTagDrawables(ColorDrawable(), null, ColorDrawable(), null)
        }
        val stacked = measuredTag("Tag") {
            setTagDrawablePadding(8)
            setTagDrawables(null, ColorDrawable(), null, null)
        }
        assertTrue(sides.measuredWidth > plain.measuredWidth + 16)
        assertEquals(plain.measuredHeight, sides.measuredHeight)
        assertTrue(stacked.measuredHeight > plain.measuredHeight + 8)
        assertEquals(plain.measuredWidth, stacked.measuredWidth)
    }

    @Test
    fun spacingBetweenTextAndCross() {
        // #105: the distance between the text and the cross could not be set.
        val cross = measuredTag("Tag") { setEnableCross(true) }
        val spaced = measuredTag("Tag") {
            setEnableCross(true)
            setCrossSpacing(24)
        }
        assertEquals(cross.measuredWidth + 24, spaced.measuredWidth)
    }
}
