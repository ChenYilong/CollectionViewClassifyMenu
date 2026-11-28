package com.cyl.classifymenu

import android.app.Activity
import android.os.Looper
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import android.widget.TextView
import androidx.test.core.app.ApplicationProvider
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.Robolectric
import org.robolectric.RobolectricTestRunner
import org.robolectric.Shadows.shadowOf
import org.robolectric.annotation.GraphicsMode
import java.time.Duration

private const val CYL_LONG_HEADER = "A very long section header that cannot fit one line of a phone-width list, so it wraps onto several lines when it may, one two three four five six seven eight nine ten"
private const val CYL_SHORT_HEADER = "Short"

private class CYLHeaderTitleSource(private val title: String) : CYLMenuDataSource {
    override fun numberOfSectionsInMenu() = 1
    override fun menuNumberOfItemsInSection(section: Int) = 3
    override fun menuTitleForSection(section: Int) = title
    override fun menuTitleForItemAtIndexPath(indexPath: CYLIndexPath) = "Tag ${indexPath.item}"
}

/**
 * `CYLMenuStyle.headerMaxLines`: a section header's title wraps up to that many lines and the header grows with it; the default
 * (`CYLHeaderTitleMaxLines.SINGLE`) keeps today's fixed `headerHeight` and an ellipsized title.
 */
@RunWith(RobolectricTestRunner::class)
@GraphicsMode(GraphicsMode.Mode.NATIVE)
class CYLTagHeaderMaxLinesTest {

    private fun makeList(maxLines: Int, title: String = CYL_LONG_HEADER): CYLTagListView {
        val activity = Robolectric.buildActivity(Activity::class.java).setup().get()
        val list = CYLTagListView(activity)
        list.style = CYLMenuStyle.plainSectionStyle().also { it.headerMaxLines = maxLines }
        list.menuDataSource = CYLHeaderTitleSource(title)
        activity.setContentView(FrameLayout(activity).apply { addView(list, FrameLayout.LayoutParams(WIDTH_PX, FrameLayout.LayoutParams.WRAP_CONTENT)) })
        list.reloadMenuData()
        shadowOf(Looper.getMainLooper()).idleFor(Duration.ofMillis(100))
        return list
    }

    private fun descendants(view: View): List<View> =
        if (view is ViewGroup) (0 until view.childCount).flatMap { val child = view.getChildAt(it); listOf(child) + descendants(child) } else emptyList()

    private fun titleLabel(list: CYLTagListView, title: String) = descendants(list).filterIsInstance<TextView>().first { it.text == title }

    private fun headerHeight(list: CYLTagListView) = list.sectionFrame(0)!!.headerHeight

    /** The header the style must give: `headerHeight`, or the wrapped title plus the padding, from the same helper the list uses. */
    private fun expectedHeader(maxLines: Int, title: String): Float {
        val style = CYLMenuStyle()
        val font = style.headerFontForTraitCollection()
        val line = Math.ceil(CYLTagButton.fontLineHeight(font).toDouble()).toFloat()
        // The room of a plain header without icon or fold control: the list width minus both header insets.
        val room = WIDTH_PX - 2 * style.headerHorizontalInset
        val text = if (maxLines > 1) CYLTagButton.wrappedTextHeight(title, font, room, maxLines) else line
        return maxOf(style.headerHeight, text + HEADER_PADDING)
    }

    @Test
    fun theDefaultIsOneLineAndTheHeaderKeepsItsFixedHeight() {
        assertEquals(CYLHeaderTitleMaxLines.SINGLE, CYLMenuStyle().headerMaxLines)
        val list = makeList(CYLHeaderTitleMaxLines.SINGLE)
        assertEquals(CYLMenuStyle().headerHeight, headerHeight(list), 0.001f)
        assertEquals(1, titleLabel(list, CYL_LONG_HEADER).maxLines)
    }

    @Test
    fun aValueBelowOneIsOneAndTheCopyKeepsTheValue() {
        val style = CYLMenuStyle()
        style.headerMaxLines = 0
        assertEquals(CYLHeaderTitleMaxLines.SINGLE, style.headerMaxLines)
        style.headerMaxLines = -4
        assertEquals(CYLHeaderTitleMaxLines.SINGLE, style.headerMaxLines)
        style.headerMaxLines = 3
        assertEquals(3, style.copy().headerMaxLines)
        style.headerMaxLines = CYLHeaderTitleMaxLines.UNLIMITED
        assertEquals(CYLHeaderTitleMaxLines.UNLIMITED, style.copy().headerMaxLines)
    }

    // Robolectric's font metrics can be fake (a line may have no height), so the expected height is the helper's own result: the
    // header equals it, never shrinks with more lines, and is taller than the fixed one whenever the helper says three lines are
    // taller than one. The real wrapping is looked at on the emulator.
    @Test
    fun threeLinesGrowTheHeaderForALongTitle() {
        val one = makeList(CYLHeaderTitleMaxLines.SINGLE)
        val three = makeList(3)
        val all = makeList(CYLHeaderTitleMaxLines.UNLIMITED)
        assertEquals(expectedHeader(3, CYL_LONG_HEADER), headerHeight(three), 0.5f)
        assertEquals(expectedHeader(CYLHeaderTitleMaxLines.UNLIMITED, CYL_LONG_HEADER), headerHeight(all), 0.5f)
        assertTrue("more lines are never shorter", headerHeight(all) >= headerHeight(three) && headerHeight(three) >= headerHeight(one))
        val font = CYLMenuStyle().headerFontForTraitCollection()
        val line = Math.ceil(CYLTagButton.fontLineHeight(font).toDouble()).toFloat()
        if (CYLTagButton.wrappedTextHeight(CYL_LONG_HEADER, font, WIDTH_PX - 32f, 3) + HEADER_PADDING > CYLMenuStyle().headerHeight && line > 0f) {
            assertTrue("a long title grows the header", headerHeight(three) > headerHeight(one))
            // The content grows by the same amount.
            assertEquals(one.contentHeight + (headerHeight(three) - headerHeight(one)), three.contentHeight, 1f)
        }
        assertEquals(3, titleLabel(three, CYL_LONG_HEADER).maxLines)
        assertEquals(headerHeight(three).toInt(), titleLabel(three, CYL_LONG_HEADER).height)
    }

    @Test
    fun aShortTitleKeepsTheFixedHeightWhateverTheLimit() {
        val three = makeList(3, CYL_SHORT_HEADER)
        assertEquals(CYLMenuStyle().headerHeight, headerHeight(three), 0.001f)
        assertEquals(makeList(CYLHeaderTitleMaxLines.SINGLE, CYL_SHORT_HEADER).contentHeight, three.contentHeight, 0.5f)
    }

    @Test
    fun theHeightThatFitsWidthFollowsTheGrownHeader() {
        val one = makeList(CYLHeaderTitleMaxLines.SINGLE)
        val three = makeList(3)
        val delta = headerHeight(three) - headerHeight(one)
        assertEquals(one.heightThatFitsWidth(WIDTH_PX.toFloat()) + delta, three.heightThatFitsWidth(WIDTH_PX.toFloat()), 1f)
    }

    @Test
    fun theConfigurationKeyParses() {
        val context = ApplicationProvider.getApplicationContext<android.content.Context>()
        fun styleOf(value: Any?) = CYLMenuStyle().also { it.applyConfiguration(mapOf(CYLMenuStyleHeaderMaxLines to value), context) }
        assertEquals("headerMaxLines", CYLMenuStyleHeaderMaxLines)
        assertEquals(3, styleOf(3).headerMaxLines)
        assertEquals(2, styleOf("2").headerMaxLines)
        assertEquals(CYLHeaderTitleMaxLines.UNLIMITED, styleOf("unlimited").headerMaxLines)
        assertEquals(CYLHeaderTitleMaxLines.SINGLE, styleOf(0).headerMaxLines)
        assertEquals(CYLHeaderTitleMaxLines.SINGLE, CYLMenuStyle().also { it.applyConfiguration(emptyMap(), context) }.headerMaxLines)
    }

    private companion object {
        const val WIDTH_PX = 320
        const val HEADER_PADDING = 12f
    }
}
