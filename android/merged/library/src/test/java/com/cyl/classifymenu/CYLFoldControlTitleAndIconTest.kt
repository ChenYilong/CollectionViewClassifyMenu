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

    // MARK: The title's room next to the fold control, More, clear and the accessory (docs/tag-section-style.md)

    private fun roomList(
        source: CYLMenuDataSource, fold: CYLMenuFoldControl, rtl: Boolean = false, maxLines: Int = CYLHeaderTitleMaxLines.SINGLE,
    ): CYLTagListView {
        val activity = Robolectric.buildActivity(Activity::class.java).setup().get()
        // The app's android:supportsRtl: without it a view always resolves to left to right.
        activity.applicationInfo.flags = activity.applicationInfo.flags or android.content.pm.ApplicationInfo.FLAG_SUPPORTS_RTL
        val list = CYLTagListView(activity)
        if (rtl) list.layoutDirection = View.LAYOUT_DIRECTION_RTL
        list.style = CYLMenuStyle.plainSectionStyle().also { it.headerMaxLines = maxLines }
        list.menuDataSource = source
        list.defaultVisibleRows = 2
        list.foldControl = fold
        activity.setContentView(FrameLayout(activity).apply { addView(list, FrameLayout.LayoutParams(WIDTH_PX, FrameLayout.LayoutParams.WRAP_CONTENT)) })
        list.reloadMenuData()
        frames()
        return list
    }

    private fun accessory(list: CYLTagListView) = descendants(list).first { it.tag == ACCESSORY_TAG }

    private fun more(list: CYLTagListView) = descendants(list).first { it.cyl_accessibilityIdentifier == CYLTagListMoreButtonAccessibilityIdentifier }

    private fun clear(list: CYLTagListView) = descendants(list).first { it.cyl_accessibilityIdentifier == CYLTagListClearButtonAccessibilityIdentifier }

    private fun foldButtonOf(list: CYLTagListView) = descendants(list).filterIsInstance<CYLTagFoldButton>().single()

    private fun titleOf(list: CYLTagListView) = descendants(list).filterIsInstance<TextView>().first { it.text.toString() == ROOM_TITLE }

    private fun headerOf(list: CYLTagListView) = list.sectionFrame(0)!!.headerHeight

    /** The fold control's natural width: the wider of the folded and expanded control. */
    private fun naturalFold(fold: CYLMenuFoldControl) =
        maxOf(CYLTagFoldButton.sizeForFoldControl(fold, false).width, CYLTagFoldButton.sizeForFoldControl(fold, true).width)

    private fun headerFont() = CYLMenuStyle.plainSectionStyle().headerFontForTraitCollection()

    /** What the other header views take: the clear line, More (its box minus the transparent trailing padding) and the accessory. */
    private fun clearTake() = Math.ceil(CYLTagButton.fontLineHeight(headerFont()).toDouble()).toFloat() + SPACING

    private fun moreTake() = MORE_SIZE - Math.floor(((MORE_SIZE - MORE_GLYPH) / 2).toDouble()).toFloat() + MORE_GAP

    private fun accessoryTake(inner: Float) = minOf(ACCESSORY_WIDTH, inner * ACCESSORY_MAX_FRACTION) + SPACING

    private fun trailingFold(foldWidth: Float) = foldWidth - OVERHANG + SPACING

    private fun fixedSource(more: Boolean = false, clear: Boolean = false, withAccessory: Boolean = false, title: String = ROOM_TITLE): CYLMenuDataSource =
        object : CYLMenuDataSource {
            private val accessoryView = View(context).apply { tag = ACCESSORY_TAG; minimumWidth = ACCESSORY_WIDTH.toInt(); minimumHeight = 10 }
            override fun numberOfSectionsInMenu() = 1
            override fun menuNumberOfItemsInSection(section: Int) = 20
            override fun menuTitleForSection(section: Int) = title
            override fun menuTitleForItemAtIndexPath(indexPath: CYLIndexPath) = "Tag %02d".format(indexPath.item)
            override fun menuShowsMoreButtonInSection(section: Int) = more
            override fun menuShowsClearButtonForSection(section: Int) = clear
            override fun menuAccessoryViewForSection(section: Int): View? = if (withAccessory) accessoryView else null
        }

    private fun foldTrailing() = titleAndIcon(CYLMenuFoldControlPosition.HEADER_TRAILING)

    @Test
    fun withNoFoldControlTheTitleRoomIsTheInnerWidth() {
        val list = roomList(fixedSource(), CYLMenuFoldControl.noFoldControl())
        assertEquals(INNER, titleOf(list).width.toFloat(), 0.5f)
        assertEquals(HEADER_INSET, titleOf(list).left.toFloat(), 0.5f)
        // An unfoldable section reserves nothing even with the control set.
        val unfoldable = roomList(object : CYLMenuDataSource by fixedSource() { override fun menuNumberOfItemsInSection(section: Int) = 2 }, foldTrailing())
        assertEquals(INNER, titleOf(unfoldable).width.toFloat(), 0.5f)
    }

    @Test
    fun theFoldControlAloneTakesAtMostFortyPercentAndTheTitleKeepsTheRest() {
        val fold = foldTrailing()
        val list = roomList(fixedSource(), fold)
        val foldWidth = minOf(naturalFold(fold), INNER * FOLD_ALONE_FRACTION)
        assertTrue("the fold control is at most 40% of the inner width", foldButtonOf(list).width <= INNER * FOLD_ALONE_FRACTION + 0.5f)
        assertEquals(foldWidth, foldButtonOf(list).width.toFloat(), 1f)
        assertEquals(INNER - trailingFold(foldWidth), titleOf(list).width.toFloat(), 1f)
        assertTrue("the title ends one spacing before the fold control", titleOf(list).right + SPACING <= foldButtonOf(list).left + 1f)
    }

    @Test
    fun aLongCollapseTitleIsCappedAndTheTitleStillGetsItsRoom() {
        val fold = foldTrailing().also { it.collapseTitle = "Show fewer tags in this section of the list" }
        val list = roomList(fixedSource(), fold)
        assertTrue("the natural width is above the cap", naturalFold(fold) > INNER * FOLD_ALONE_FRACTION)
        assertEquals(INNER * FOLD_ALONE_FRACTION, foldButtonOf(list).width.toFloat(), 1f)
        assertEquals(INNER - trailingFold(INNER * FOLD_ALONE_FRACTION), titleOf(list).width.toFloat(), 1f)
    }

    @Test
    fun foldMoreClearAndAccessoryTogetherFitTheInnerWidth() {
        val fold = foldTrailing().also { it.collapseTitle = "Show fewer tags in this section of the list" }
        val list = roomList(fixedSource(more = true, clear = true, withAccessory = true), fold)
        val foldWidth = minOf(naturalFold(fold), INNER * FOLD_SHARED_FRACTION)
        assertTrue("the fold control is at most 30% of the inner width", foldButtonOf(list).width <= INNER * FOLD_SHARED_FRACTION + 0.5f)
        assertEquals(foldWidth, foldButtonOf(list).width.toFloat(), 1f)
        val fixed = clearTake() + moreTake() + trailingFold(foldWidth) + accessoryTake(INNER)
        assertEquals(maxOf(headerFont().size, INNER - fixed), titleOf(list).width.toFloat(), 1f)
        assertTrue("the title and everything beside it fit the inner width", titleOf(list).width + fixed <= INNER + 1f)
        // The accessory is the view next to the title: the title ends one spacing before it, which ends one spacing before the fold control.
        assertTrue("title end + spacing <= accessory start", titleOf(list).right + SPACING <= accessory(list).left + 1f)
        assertTrue("accessory end + spacing <= fold control start", accessory(list).right + SPACING <= foldButtonOf(list).left + 1f)
        assertTrue("title end + spacing <= fold control start", titleOf(list).right + SPACING <= foldButtonOf(list).left + 1f)
        assertTrue("the accessory is capped at 30% of the inner width", accessory(list).width <= INNER * ACCESSORY_MAX_FRACTION + 0.5f)
        assertTrue("the clear button stays inside the trailing edge", clear(list).right <= WIDTH_PX - HEADER_INSET + 1f)
        assertTrue("More does not move left of the fold control's glyph box", more(list).left >= foldButtonOf(list).left)
    }

    @Test
    fun collapsedAndExpandedGiveTheSameTitleRoomAndFoldWidth() {
        val list = roomList(fixedSource(more = true), foldTrailing().also { it.collapseTitle = "Show fewer tags in this section of the list" })
        val titleWidth = titleOf(list).width
        val foldWidth = foldButtonOf(list).width
        list.setExpanded(true, 0, false)
        frames()
        assertEquals("Show fewer tags in this section of the list", foldButtonOf(list).titleLabel.text.toString())
        assertEquals(titleWidth, titleOf(list).width)
        assertEquals(foldWidth, foldButtonOf(list).width)
    }

    @Test
    fun aTwoLineAndAnUnlimitedHeaderWrapAtTheSameRoomTheRenderGivesTheTitle() {
        val font = headerFont()
        val line = Math.ceil(CYLTagButton.fontLineHeight(font).toDouble()).toFloat()
        val fold = foldTrailing()
        val room = INNER - trailingFold(minOf(naturalFold(fold), INNER * FOLD_ALONE_FRACTION))
        for (maxLines in listOf(2, CYLHeaderTitleMaxLines.UNLIMITED)) {
            val list = roomList(fixedSource(title = ROOM_LONG_TITLE), fold, maxLines = maxLines)
            val label = descendants(list).filterIsInstance<TextView>().first { it.text.toString() == ROOM_LONG_TITLE }
            assertEquals("the render's title width is the height's room", room, label.width.toFloat(), 1f)
            val text = CYLTagButton.wrappedTextHeight(ROOM_LONG_TITLE, font, room, maxLines)
            assertEquals("the header grows by the wrapped lines at that room", maxOf(maxOf(CYLMenuStyle.plainSectionStyle().headerHeight, text + HEADER_PADDING), CYLTagFoldButton.sizeForFoldControl(fold, false).height), headerOf(list), 0.5f)
            if (line > 0f) assertEquals("whole lines", 0f, (text / line) - Math.rint((text / line).toDouble()).toFloat(), 0.01f)
        }
    }

    @Test
    fun rightToLeftMirrorsTheFoldOnlyAndTheFullHeader() {
        val fold = foldTrailing().also { it.collapseTitle = "Show fewer tags in this section of the list" }
        for (full in listOf(false, true)) {
            fun make(rtl: Boolean) = roomList(fixedSource(more = full, clear = full, withAccessory = full), fold, rtl)
            val ltr = make(false)
            val rtl = make(true)
            fun mirrored(message: String, a: View, b: View) {
                assertEquals("$message right edge", WIDTH_PX - a.left.toFloat(), b.right.toFloat(), 1f)
                assertEquals("$message left edge", WIDTH_PX - a.right.toFloat(), b.left.toFloat(), 1f)
            }
            mirrored("fold control (full=$full)", foldButtonOf(ltr), foldButtonOf(rtl))
            assertEquals("same title room (full=$full)", titleOf(ltr).width, titleOf(rtl).width)
            assertEquals("the title starts at the leading edge, from the right", WIDTH_PX - HEADER_INSET, titleOf(rtl).right.toFloat(), 1f)
            assertTrue("title end + spacing <= fold control start, mirrored", titleOf(rtl).left - SPACING >= foldButtonOf(rtl).right - 1f)
            if (full) {
                mirrored("accessory", accessory(ltr), accessory(rtl))
                mirrored("More", more(ltr), more(rtl))
                mirrored("clear", clear(ltr), clear(rtl))
                assertTrue("fold width <= 30% of the inner width", foldButtonOf(rtl).width <= INNER * FOLD_SHARED_FRACTION + 0.5f)
            }
        }
    }

    @Test
    fun aShortTitleInADefaultSingleLineHeaderKeepsItsGeometry() {
        val noFold = roomList(fixedSource(title = ROOM_TITLE), CYLMenuFoldControl.noFoldControl())
        assertEquals(CYLMenuStyle.plainSectionStyle().headerHeight, headerOf(noFold), 0.001f)
        assertEquals(HEADER_INSET, titleOf(noFold).left.toFloat(), 0.5f)
        val withFold = roomList(fixedSource(title = ROOM_TITLE), foldTrailing())
        assertEquals(HEADER_INSET, titleOf(withFold).left.toFloat(), 0.5f)
        assertEquals("the control's right edge keeps the 6 dp overhang", WIDTH_PX - HEADER_INSET + OVERHANG, foldButtonOf(withFold).right.toFloat(), 0.5f)
        val foldHeight = CYLTagFoldButton.sizeForFoldControl(foldTrailing(), false).height
        assertEquals(maxOf(headerOf(noFold), foldHeight), headerOf(withFold), 0.5f)
    }

    private companion object {
        const val WIDTH_PX = 320
        /** The plain header's horizontal inset (`CYLMenuStyle.headerHorizontalInset`), dp. */
        const val HEADER_INSET = 16f
        const val INNER = WIDTH_PX - 2 * HEADER_INSET
        /** HEADER_ITEM_SPACING, HEADER_FOLD_OVERHANG, HEADER_MORE_GAP and the fractions of the list view. */
        const val SPACING = 8f
        const val OVERHANG = 6f
        const val MORE_GAP = 4f
        const val MORE_SIZE = 44f
        const val MORE_GLYPH = 22f
        const val FOLD_ALONE_FRACTION = 0.4f
        const val FOLD_SHARED_FRACTION = 0.3f
        const val ACCESSORY_MAX_FRACTION = 0.3f
        const val ACCESSORY_WIDTH = 200f
        const val HEADER_PADDING = 12f
        const val ACCESSORY_TAG = "headerRoomAccessory"
        const val ROOM_TITLE = "Section room"
        const val ROOM_LONG_TITLE = "A very long section header that cannot fit one line next to a fold control, so it wraps onto several lines when it may, one two three four five six seven eight nine ten"
    }
}
