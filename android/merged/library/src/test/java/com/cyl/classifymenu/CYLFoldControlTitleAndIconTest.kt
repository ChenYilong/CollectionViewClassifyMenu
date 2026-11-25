package com.cyl.classifymenu

import android.app.Activity
import android.content.Context
import android.os.Looper
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import android.widget.TextView
import androidx.test.core.app.ApplicationProvider
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.Robolectric
import org.robolectric.RobolectricTestRunner
import org.robolectric.Shadows.shadowOf
import org.robolectric.annotation.GraphicsMode
import java.time.Duration

/** One section of same-length titles ("Tag 00") titled "Section". */
private class CYLTitleAndIconSource(count: Int) : CYLMenuDataSource {
    val titles = (0 until count).map { "Tag %02d".format(it) }
    override fun numberOfSectionsInMenu() = 1
    override fun menuNumberOfItemsInSection(section: Int) = titles.size
    override fun menuTitleForSection(section: Int) = "Section"
    override fun menuTitleForItemAtIndexPath(indexPath: CYLIndexPath) = titles[indexPath.item]
}

/**
 * `CYLMenuFoldControlContentTitleAndIcon` (iOS `titleAndIcon`, raw 3): the title and the chevron ALWAYS: "More" + chevron folded,
 * "Less" + the chevron turned expanded; the control keeps its size in both states, and a header shows it only on a foldable section.
 */
@RunWith(RobolectricTestRunner::class)
@GraphicsMode(GraphicsMode.Mode.NATIVE)
class CYLFoldControlTitleAndIconTest {

    private val context: Context get() = ApplicationProvider.getApplicationContext()

    private fun control(position: CYLMenuFoldControlPosition, content: CYLMenuFoldControlContent) =
        CYLMenuFoldControl.foldControlWithPosition(position, content)

    private fun titleAndIcon(position: CYLMenuFoldControlPosition) = control(position, CYLMenuFoldControlContent.CYLMenuFoldControlContentTitleAndIcon)

    private fun frames() = shadowOf(Looper.getMainLooper()).idleFor(Duration.ofMillis(100))

    private fun descendants(view: View): List<View> =
        if (view is ViewGroup) (0 until view.childCount).flatMap { val child = view.getChildAt(it); listOf(child) + descendants(child) } else emptyList()

    private fun makeList(count: Int, fold: CYLMenuFoldControl, headers: Boolean): CYLTagListView {
        val activity = Robolectric.buildActivity(Activity::class.java).setup().get()
        val list = CYLTagListView(activity)
        list.usePlainSections()
        list.menuDataSource = CYLTitleAndIconSource(count)
        list.showsSectionHeaders = headers
        list.defaultVisibleRows = 2
        list.foldControl = fold
        activity.setContentView(FrameLayout(activity).apply { addView(list, FrameLayout.LayoutParams(FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.WRAP_CONTENT)) })
        list.reloadMenuData()
        frames()
        return list
    }

    @Test
    fun theContentLogicOfTheFourContents() {
        val both = control(CYLMenuFoldControlPosition.FOOTER, CYLMenuFoldControlContent.CYLMenuFoldControlContentIconAndTitle)
        assertTrue(both.showsTitleWhenExpanded(false)); assertFalse(both.showsTitleWhenExpanded(true))
        assertTrue(both.showsImageWhenExpanded(false)); assertTrue(both.showsImageWhenExpanded(true))
        val title = control(CYLMenuFoldControlPosition.FOOTER, CYLMenuFoldControlContent.CYLMenuFoldControlContentTitle)
        assertTrue(title.showsTitleWhenExpanded(false)); assertTrue(title.showsTitleWhenExpanded(true))
        assertFalse(title.showsImageWhenExpanded(false)); assertFalse(title.showsImageWhenExpanded(true))
        val icon = control(CYLMenuFoldControlPosition.FOOTER, CYLMenuFoldControlContent.CYLMenuFoldControlContentIcon)
        assertFalse(icon.showsTitleWhenExpanded(false)); assertFalse(icon.showsTitleWhenExpanded(true))
        assertTrue(icon.showsImageWhenExpanded(false)); assertTrue(icon.showsImageWhenExpanded(true))
        val always = titleAndIcon(CYLMenuFoldControlPosition.FOOTER)
        assertTrue(always.showsTitleWhenExpanded(false)); assertTrue(always.showsTitleWhenExpanded(true))
        assertTrue(always.showsImageWhenExpanded(false)); assertTrue(always.showsImageWhenExpanded(true))
        assertEquals(3, CYLMenuFoldControlContent.CYLMenuFoldControlContentTitleAndIcon.ordinal)
    }

    @Test
    fun theTitlesAreTheLocalizedDefaultsAndCustomTitlesApply() {
        val always = titleAndIcon(CYLMenuFoldControlPosition.FOOTER)
        assertEquals("More", always.titleWhenExpanded(false))
        assertEquals("Less", always.titleWhenExpanded(true))
        always.title = "Show"
        always.collapseTitle = "Hide"
        assertEquals("Show", always.titleWhenExpanded(false))
        assertEquals("Hide", always.titleWhenExpanded(true))
    }

    @Test
    fun theConfigurationStringIsTitleAndIconAlwaysAndTheOldAliasesAreUnchanged() {
        fun content(name: String) = CYLMenuFoldControl.foldControlWithConfiguration(
            mapOf(CYLMenuFoldControlKeyPosition to "headerTrailing", CYLMenuFoldControlKeyContent to name))!!.content
        assertEquals(CYLMenuFoldControlContent.CYLMenuFoldControlContentTitleAndIcon, content("titleAndIconAlways"))
        assertEquals(CYLMenuFoldControlContent.CYLMenuFoldControlContentIconAndTitle, content("iconAndTitle"))
        assertEquals(CYLMenuFoldControlContent.CYLMenuFoldControlContentIconAndTitle, content("titleAndIcon"))
        assertEquals(CYLMenuFoldControlContent.CYLMenuFoldControlContentTitle, content("title"))
        assertEquals(CYLMenuFoldControlContent.CYLMenuFoldControlContentIcon, content("icon"))
    }

    @Test
    fun aHeaderControlShowsMoreFoldedAndLessExpandedWithTheChevronTurned() {
        val button = CYLTagFoldButton(context)
        val fold = titleAndIcon(CYLMenuFoldControlPosition.HEADER_TRAILING)
        button.applyFoldControl(fold, null, false, false)
        assertEquals("More", button.titleLabel.text.toString())
        assertNotNull(button.image)
        assertEquals(0f, button.imageView.rotation, 0.01f)
        button.applyFoldControl(fold, null, true, false)
        assertEquals("Less", button.titleLabel.text.toString())
        assertNotNull(button.image)
        assertEquals(180f, button.imageView.rotation, 0.01f)
    }

    @Test
    fun theControlSizeIsTheSameFoldedAndExpandedStandaloneAndInline() {
        val fold = titleAndIcon(CYLMenuFoldControlPosition.TAIL)
        val folded = CYLTagFoldButton.sizeForFoldControl(fold, false)
        val expanded = CYLTagFoldButton.sizeForFoldControl(fold, true)
        assertEquals(folded.width, expanded.width, 0.001f)
        assertEquals(folded.height, expanded.height, 0.001f)
        val inlineFolded = CYLTagFoldButton.inlineSizeForFoldControl(fold, CYLMenuStyle(), false)
        val inlineExpanded = CYLTagFoldButton.inlineSizeForFoldControl(fold, CYLMenuStyle(), true)
        assertEquals(inlineFolded.width, inlineExpanded.width, 0.001f)
        assertEquals(inlineFolded.height, inlineExpanded.height, 0.001f)
        // A longer collapse title widens both states (the wider of the two titles).
        fold.collapseTitle = "Show fewer tags in this section"
        assertTrue(CYLTagFoldButton.sizeForFoldControl(fold, false).width > folded.width)
        assertEquals(CYLTagFoldButton.sizeForFoldControl(fold, false).width, CYLTagFoldButton.sizeForFoldControl(fold, true).width, 0.001f)
    }

    @Test
    fun theTailCellOfARealListShowsMoreThenLessAtTheSameSize() {
        val list = makeList(20, titleAndIcon(CYLMenuFoldControlPosition.TAIL), headers = false)
        assertTrue(list.canFoldSection(0))
        val cell = descendants(list).filterIsInstance<CYLTagFoldCell>().single()
        assertEquals("More", cell.foldButton.titleLabel.text.toString())
        val foldedWidth = cell.measuredWidth
        val foldedHeight = cell.measuredHeight
        list.setExpanded(true, 0, false)
        frames()
        val expandedCell = descendants(list).filterIsInstance<CYLTagFoldCell>().single()
        assertEquals("Less", expandedCell.foldButton.titleLabel.text.toString())
        assertEquals(foldedWidth, expandedCell.measuredWidth)
        assertEquals(foldedHeight, expandedCell.measuredHeight)
    }

    @Test
    fun aHeaderOnAFoldableSectionShowsTheControlAndAnUnfoldableOneReservesNothing() {
        val foldable = makeList(20, titleAndIcon(CYLMenuFoldControlPosition.HEADER_TRAILING), headers = true)
        val shown = descendants(foldable).filterIsInstance<CYLTagFoldButton>().single()
        assertEquals(View.VISIBLE, shown.visibility)
        assertEquals("More", shown.titleLabel.text.toString())

        val unfoldable = makeList(2, titleAndIcon(CYLMenuFoldControlPosition.HEADER_TRAILING), headers = true)
        assertFalse(unfoldable.canFoldSection(0))
        assertEquals(View.GONE, descendants(unfoldable).filterIsInstance<CYLTagFoldButton>().single().visibility)
        val none = makeList(2, CYLMenuFoldControl.noFoldControl(), headers = true)
        fun sectionTitle(list: CYLTagListView) = descendants(list).filterIsInstance<TextView>().first { it.text.toString() == "Section" }
        assertEquals("the title has the same room as with no fold control", sectionTitle(none).width, sectionTitle(unfoldable).width)
    }
}
