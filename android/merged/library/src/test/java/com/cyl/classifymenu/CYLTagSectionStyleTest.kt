package com.cyl.classifymenu

import android.app.Activity
import android.graphics.Color
import android.os.Looper
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import android.widget.TextView
import androidx.test.core.app.ApplicationProvider
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.Robolectric
import org.robolectric.RobolectricTestRunner
import org.robolectric.Shadows.shadowOf
import org.robolectric.annotation.Config
import org.robolectric.annotation.GraphicsMode
import java.time.Duration

/** Sections of same-length titles ("Tag 00"), so every tag has the same width and the row count follows the tag count. */
private class CYLSectionStyleSource(vararg counts: Int) : CYLMenuDataSource {
    val sections = counts.map { count -> (0 until count).map { "Tag %02d".format(it) } }
    override fun numberOfSectionsInMenu() = sections.size
    override fun menuNumberOfItemsInSection(section: Int) = sections[section].size
    override fun menuTitleForSection(section: Int) = "Section $section"
    override fun menuTitleForItemAtIndexPath(indexPath: CYLIndexPath) = sections[indexPath.section][indexPath.item]
}

/**
 * The section style of the tag list (docs/tag-section-style.md): the card, the header band and the header divider, their
 * colors, and the one column function behind every measuring and layout pass. The default frames are in
 * CYLTagListDefaultFramesTest.
 */
@RunWith(RobolectricTestRunner::class)
@GraphicsMode(GraphicsMode.Mode.NATIVE)
class CYLTagSectionStyleTest {

    private val context = ApplicationProvider.getApplicationContext<android.content.Context>()

    private fun makeList(style: CYLMenuStyle, vararg counts: Int, setup: (CYLTagListView) -> Unit = {}): CYLTagListView {
        val activity = Robolectric.buildActivity(Activity::class.java).setup().get()
        val list = CYLTagListView(activity)
        list.style = style
        list.menuDataSource = CYLSectionStyleSource(*counts)
        setup(list)
        activity.setContentView(FrameLayout(activity).apply { addView(list, FrameLayout.LayoutParams(WIDTH_PX, FrameLayout.LayoutParams.WRAP_CONTENT)) })
        list.reloadMenuData()
        shadowOf(Looper.getMainLooper()).idleFor(Duration.ofMillis(100))
        return list
    }

    private fun insetGrouped(): CYLMenuStyle = CYLMenuStyle().also { it.sectionStyle = CYLSectionStyle.CYLSectionStyleInsetGrouped }

    /** The default style with the card opted out: the look these tests were written against, before the default flipped. */
    private fun plain(): CYLMenuStyle = CYLMenuStyle.plainSectionStyle()

    private fun descendants(view: View): List<View> =
        if (view is ViewGroup) (0 until view.childCount).flatMap { val child = view.getChildAt(it); listOf(child) + descendants(child) } else emptyList()

    private fun tagFrame(list: CYLTagListView, item: Int, section: Int): CYLRect {
        val cell = list.tagButtonAtIndexPath(CYLIndexPath(item, section))!!.parent as View
        return CYLRect(cell.left.toFloat(), cell.top.toFloat(), cell.width.toFloat(), cell.height.toFloat())
    }

    private fun tagCount(list: CYLTagListView, section: Int) =
        generateSequence(0) { it + 1 }.takeWhile { list.tagButtonAtIndexPath(CYLIndexPath(it, section)) != null }.count()

    private fun rowStarts(list: CYLTagListView, section: Int) = (0 until tagCount(list, section)).map { tagFrame(list, it, section) }.map { it.y }.distinct().size

    // MARK: Geometry

    @Test
    fun thePlainStyleDrawsNothingAndTheTagsSpanTheColumn() {
        val list = makeList(plain(), 6, 3)
        for (section in 0..1) {
            val frame = list.sectionFrame(section)!!
            assertNull(frame.card)
            assertNull(frame.headerBand)
            assertNull(frame.headerSeparator)
            assertEquals(16f, frame.headerInsetLeft)
            assertEquals(16f, frame.headerInsetRight)
        }
        assertEquals(CYLRect(16f, 0f, WIDTH_PX - 32f, 0f), list.contentColumn(0))
        assertEquals(list.contentColumn(0), list.tagColumn(0))
    }

    @Test
    fun theCardContainsEveryTagFrame() {
        val list = makeList(insetGrouped(), 16, 3)
        for (section in 0..1) {
            val card = list.sectionFrame(section)!!.card!!
            assertEquals(list.contentColumn(section).x, card.x)
            assertEquals(list.contentColumn(section).width, card.width)
            for (item in 0 until tagCount(list, section)) {
                val tag = tagFrame(list, item, section)
                assertTrue("tag $section.$item $tag in $card", tag.x >= card.x + CYLSectionStyleMetrics.CARD_PADDING && tag.maxX <= card.maxX - CYLSectionStyleMetrics.CARD_PADDING)
                assertTrue("tag $section.$item $tag in $card", tag.y >= card.y + CYLSectionStyleMetrics.CARD_PADDING && tag.maxY <= card.maxY - CYLSectionStyleMetrics.CARD_PADDING)
            }
        }
        // The next section starts below the card and the section's bottom inset.
        val first = list.sectionFrame(0)!!
        assertEquals(first.top + first.height, list.sectionFrame(1)!!.top)
        assertTrue(list.sectionFrame(1)!!.top >= first.card!!.maxY)
    }

    @Test
    fun theCardAddsItsPaddingToTheHeightAndNarrowsTheColumn() {
        val plain = makeList(plain(), 3)
        val grouped = makeList(insetGrouped(), 3)
        // The grouped header is sized to its text and the board is 4 below it (not the section's top inset): one section's difference.
        val headerDelta = grouped.sectionFrame(0)!!.headerHeight - plain.sectionFrame(0)!!.headerHeight
        val offsetDelta = HEADER_BOARD_SPACING - plain().sectionInsets.top
        assertEquals(plain.heightThatFitsWidth(WIDTH_PX.toFloat()) + 2 * CYLSectionStyleMetrics.CARD_PADDING + headerDelta + offsetDelta, grouped.heightThatFitsWidth(WIDTH_PX.toFloat()), 0.5f)
        assertEquals(grouped.contentHeight, grouped.heightThatFitsWidth(WIDTH_PX.toFloat()), 0.5f)
        assertEquals(WIDTH_PX - 32f - 2 * CYLSectionStyleMetrics.CARD_PADDING, grouped.tagColumn(0).width)
        assertEquals(16f + CYLSectionStyleMetrics.CARD_PADDING, grouped.tagColumn(0).x)
    }

    @Test
    fun rowsAreCountedAtTheReducedWidth() {
        val wide = CYLEdgeInsets(60f, 60f, 60f, 60f)
        val plain = makeList(plain(), 12)
        val style = insetGrouped().also { it.sectionContentInsets = wide }
        val grouped = makeList(style, 12)
        val tagWidth = tagFrame(plain, 0, 0).width
        val spacing = plain().interitemSpacing
        fun rowsAt(column: Float): Int {
            val perRow = ((column + spacing) / (tagWidth + spacing)).toInt()
            return (12 + perRow - 1) / perRow
        }
        assertEquals(rowsAt(WIDTH_PX - 32f), plain.numberOfRowsInSection(0))
        assertEquals(rowsAt(WIDTH_PX - 32f - 120f), grouped.numberOfRowsInSection(0))
        assertTrue(grouped.numberOfRowsInSection(0) > plain.numberOfRowsInSection(0))
        assertEquals(grouped.numberOfRowsInSection(0), rowStarts(grouped, 0))
        // The height follows the rows counted at the reduced width.
        assertEquals(grouped.contentHeight, grouped.heightThatFitsWidth(WIDTH_PX.toFloat()), 0.5f)
    }

    @Test
    fun theHeaderTitleStartsWhereTheTagsDoInBothStyles() {
        for (style in listOf(insetGrouped(), plain())) {
            val list = makeList(style, 4)
            val title = descendants(list).filterIsInstance<TextView>().first { it.text == "Section 0" }
            assertEquals(tagFrame(list, 0, 0).x, title.left.toFloat(), 0.5f)
            assertEquals(tagFrame(list, 0, 0).x, list.sectionFrame(0)!!.headerInsetLeft, 0.5f)
        }
        // Under the board: the board's padding inside the 16 margin, as in the first version.
        val grouped = makeList(insetGrouped(), 4)
        val frame = grouped.sectionFrame(0)!!
        assertEquals(16f + CYLSectionStyleMetrics.CARD_PADDING, descendants(grouped).filterIsInstance<TextView>().first { it.text == "Section 0" }.left.toFloat(), 0.5f)
        assertEquals(WIDTH_PX - frame.card!!.maxX + CYLSectionStyleMetrics.CARD_PADDING, frame.headerInsetRight, 0.5f)
    }

    @Test
    fun aHeaderFoldControlEndsWhereTheTagsEnd() {
        fun make(style: CYLMenuStyle) = makeList(style, TAGS_IN_TWO_ROWS) {
            it.defaultVisibleRows = 1
            it.foldControl = CYLMenuFoldControl.foldControlWithPosition(CYLMenuFoldControlPosition.HEADER_TRAILING, CYLMenuFoldControlContent.CYLMenuFoldControlContentIconAndTitle)
        }
        fun fold(list: CYLTagListView) = descendants(list).filterIsInstance<CYLTagFoldButton>().first { it.visibility == View.VISIBLE }
        val grouped = make(insetGrouped())
        assertTrue(grouped.canFoldSection(0))
        // The tags' trailing edge (the column's); the control keeps its glyph padding overhang of 6, as in the plain style.
        assertEquals(grouped.tagColumn(0).maxX + FOLD_OVERHANG, fold(grouped).right.toFloat(), 0.5f)
        assertEquals(WIDTH_PX - 16f - CYLSectionStyleMetrics.CARD_PADDING + FOLD_OVERHANG, fold(grouped).right.toFloat(), 0.5f)
        val plain = make(plain())
        assertEquals(WIDTH_PX - 16f + FOLD_OVERHANG, fold(plain).right.toFloat(), 0.5f)
    }

    // MARK: The board inset

    @Test
    fun theDefaultBoardInsetIsUnsetAndGivesTheFirstVersionNumbers() {
        assertNull(CYLMenuStyle().sectionBoardInset)
        val list = makeList(insetGrouped(), 4)
        assertEquals(CYLRect(16f, 0f, WIDTH_PX - 32f, 0f), list.contentColumn(0))
        assertEquals(16f, list.sectionFrame(0)!!.card!!.x, 0.001f)
        assertEquals(304f, list.sectionFrame(0)!!.card!!.maxX, 0.001f)
        assertEquals(28f, list.tagColumn(0).x, 0.001f)
        assertEquals(292f, list.tagColumn(0).maxX, 0.001f)
        // Unset is the same as a set 12.
        val twelve = makeList(insetGrouped().also { it.sectionBoardInset = CYLSectionStyleMetrics.CARD_PADDING }, 4)
        assertEquals(list.sectionFrame(0)!!.card, twelve.sectionFrame(0)!!.card)
        assertEquals(list.tagColumn(0), twelve.tagColumn(0))
        assertEquals(list.contentHeight, twelve.contentHeight, 0.001f)
    }

    @Test
    fun theBoardIsTheInsetBeyondTheContentColumnOnBothSides() {
        for (inset in listOf(0f, 4f, 20f)) {
            val list = makeList(insetGrouped().also { it.sectionBoardInset = inset }, 4)
            val card = list.sectionFrame(0)!!.card!!
            val content = list.tagColumn(0)
            assertEquals("board left == content left - inset", content.x - inset, card.x, 0.001f)
            assertEquals("board right == content right + inset", content.maxX + inset, card.maxX, 0.001f)
            // The board is the margin column whatever the inset.
            assertEquals(16f, card.x, 0.001f)
            assertEquals(WIDTH_PX - 16f, card.maxX, 0.001f)
            val title = descendants(list).filterIsInstance<TextView>().first { it.text == "Section 0" }
            assertEquals(content.x, title.left.toFloat(), 0.5f)
            assertEquals(content.x, tagFrame(list, 0, 0).x, 0.5f)
        }
    }

    @Test
    fun anInsetOfZeroHugsTheTags() {
        val list = makeList(insetGrouped().also { it.sectionBoardInset = 0f }, 4)
        assertEquals(list.contentColumn(0), list.tagColumn(0))
        assertEquals(16f, list.tagColumn(0).x, 0.001f)
        assertEquals(WIDTH_PX - 16f, list.tagColumn(0).maxX, 0.001f)
        assertEquals(list.sectionFrame(0)!!.card!!.x, tagFrame(list, 0, 0).x, 0.5f)
    }

    @Test
    fun aSetInsetOverridesTheLeadingAndTrailingPartsOfTheContentInsets() {
        val style = insetGrouped().also {
            it.sectionContentInsets = CYLEdgeInsets(30f, 40f, 30f, 8f)
            it.sectionBoardInset = 6f
        }
        val list = makeList(style, 4)
        val card = list.sectionFrame(0)!!.card!!
        assertEquals(card.x + 6f, list.tagColumn(0).x, 0.001f)
        assertEquals(card.maxX - 6f, list.tagColumn(0).maxX, 0.001f)
        // Unset: the content insets' own leading and trailing parts, as before.
        val unset = makeList(insetGrouped().also { it.sectionContentInsets = CYLEdgeInsets(30f, 40f, 30f, 8f) }, 4)
        val unsetCard = unset.sectionFrame(0)!!.card!!
        assertEquals(unsetCard.x + 40f, unset.tagColumn(0).x, 0.001f)
        assertEquals(unsetCard.maxX - 8f, unset.tagColumn(0).maxX, 0.001f)
    }

    @Test
    fun theTopAndBottomOfTheContentInsetsStillApplyWithABoardInset() {
        fun height(top: Float, bottom: Float, inset: Float?) = makeList(insetGrouped().also {
            it.sectionContentInsets = CYLEdgeInsets(top, 12f, bottom, 12f)
            it.sectionBoardInset = inset
        }, 4).contentHeight
        // 9 more on the top and 9 more on the bottom: 18 taller (the tags stay on one row at both widths).
        assertEquals(height(12f, 12f, 12f) + 18f, height(21f, 21f, 12f), 0.5f)
        assertEquals(height(30f, 5f, null), height(30f, 5f, 0f), 0.5f)
        val list = makeList(insetGrouped().also {
            it.sectionContentInsets = CYLEdgeInsets(30f, 12f, 5f, 12f)
            it.sectionBoardInset = 0f
        }, 4)
        val card = list.sectionFrame(0)!!.card!!
        assertEquals(card.y + 30f, tagFrame(list, 0, 0).y, 0.5f)
    }

    @Test
    fun aNegativeBoardInsetIsZeroAndTheConfigurationKeyParses() {
        assertEquals(0f, CYLMenuStyle().also { it.sectionBoardInset = -5f }.sectionBoardInset)
        assertEquals("sectionBoardInset", CYLMenuStyleSectionBoardInset)
        assertEquals(7f, CYLMenuStyle.styleWithConfiguration(mapOf(CYLMenuStyleSectionBoardInset to 7)).sectionBoardInset)
        assertEquals(0f, CYLMenuStyle.styleWithConfiguration(mapOf(CYLMenuStyleSectionBoardInset to 0)).sectionBoardInset)
        assertEquals(0f, CYLMenuStyle.styleWithConfiguration(mapOf(CYLMenuStyleSectionBoardInset to -3)).sectionBoardInset)
        assertNull(CYLMenuStyle.styleWithConfiguration(emptyMap()).sectionBoardInset)
    }

    @Test
    fun copyKeepsTheBoardInset() {
        assertEquals(9f, CYLMenuStyle().also { it.sectionBoardInset = 9f }.copy().sectionBoardInset)
        assertEquals(0f, CYLMenuStyle().also { it.sectionBoardInset = 0f }.copy().sectionBoardInset)
        assertNull(CYLMenuStyle().copy().sectionBoardInset)
    }

    @Test
    fun theBoardInsetDoesNotChangeThePlainStyle() {
        val plain = makeList(plain(), 4)
        val withInset = makeList(plain().also { it.sectionBoardInset = 30f }, 4)
        assertEquals(plain.tagColumn(0), withInset.tagColumn(0))
        assertEquals(plain.contentHeight, withInset.contentHeight, 0.001f)
        assertNull(withInset.sectionFrame(0)!!.card)
    }

    @Test
    fun theDefaultHeaderFontIs17Semibold() {
        val style = CYLMenuStyle()
        assertEquals(17f, style.headerFont.size, 0f)
        assertEquals(CYLSectionStyleMetrics.HEADER_FONT_SIZE, style.headerFont.size, 0f)
        assertEquals(600, CYLFont.WEIGHT_SEMIBOLD)
        if (android.os.Build.VERSION.SDK_INT >= 28) assertEquals(CYLFont.WEIGHT_SEMIBOLD, style.headerFont.typeface.weight)
        // Before API 28 the closest to semibold is bold: not the regular typeface (Robolectric does not report isBold for it).
        else assertTrue("before API 28 the header font is not the regular system font", style.headerFont.typeface !== CYLFont.systemFont(17f).typeface)
        // An app that sets the font wins.
        assertEquals(20f, CYLMenuStyle().also { it.headerFont = CYLFont.systemFont(20f) }.headerFont.size, 0f)
        // The header's title view draws it.
        val title = descendants(makeList(plain(), 2)).filterIsInstance<TextView>().first { it.text == "Section 0" }
        assertEquals(17f * context.resources.displayMetrics.density, title.textSize, 0.01f)
        assertEquals(style.headerFont.isBold, title.typeface.isBold)
    }

    @Test
    fun theHeaderGrowsWithTheHeaderFont() {
        fun header(font: CYLFont): Float =
            makeList(plain().also { it.headerHeight = 0f; it.headerFont = font }, 3).sectionFrame(0)!!.headerHeight
        val line17 = Math.ceil(CYLTagButton.fontLineHeight(CYLFont.semiboldSystemFont(17f)).toDouble()).toFloat()
        assertEquals(line17 + 12f, header(CYLFont.semiboldSystemFont(17f)), 0.5f)
        // (Robolectric's fallback font metrics can give every size the same line, so the strict growth is not asserted.)
        assertTrue("a bigger header font never makes a shorter header", header(CYLFont.semiboldSystemFont(40f)) >= header(CYLFont.semiboldSystemFont(17f)))
        assertTrue("17 is at least as tall as 14", header(CYLFont.semiboldSystemFont(17f)) >= header(CYLFont.systemFont(14f)))
        // With the default fixed headerHeight (36) the 17 sp line plus 12 still fits: the header is the fixed height.
        assertEquals(maxOf(36f, line17 + 12f), makeList(plain(), 3).sectionFrame(0)!!.headerHeight, 0.5f)
    }

    @Test
    fun aPlainHeaderWithABandInsetsItsTitleFromTheBand() {
        val style = plain().also { it.headerBackgroundColor = CYLSectionStyleColors.HEADER_BAND }
        val list = makeList(style, 4)
        val frame = list.sectionFrame(0)!!
        assertEquals(CYLRect(16f, 0f, WIDTH_PX - 32f, 36f), frame.headerBand)
        assertEquals(16f + CYLSectionStyleMetrics.HEADER_BAND_PADDING, frame.headerInsetLeft)
        val title = descendants(list).filterIsInstance<TextView>().first { it.text == "Section 0" }
        assertEquals(frame.headerInsetLeft, title.left.toFloat(), 0.5f)
        // The band is inside the header: the frames of the tags did not move.
        assertEquals(makeList(plain(), 4).contentHeight, list.contentHeight, 0.5f)
    }

    @Test
    fun theDividerSitsAtTheHeaderBottomAndAddsNoHeight() {
        val none = makeList(plain(), 6, 3)
        val style = plain().also { it.headerSeparatorStyle = CYLHeaderSeparatorStyle.CYLHeaderSeparatorStyleLine }
        val line = makeList(style, 6, 3)
        assertEquals(none.contentHeight, line.contentHeight, 0.0f)
        assertEquals(none.heightThatFitsWidth(WIDTH_PX.toFloat()), line.heightThatFitsWidth(WIDTH_PX.toFloat()), 0.0f)
        for (section in 0..1) {
            val frame = line.sectionFrame(section)!!
            val divider = frame.headerSeparator!!
            assertEquals(CYLSectionStyleMetrics.SEPARATOR_THICKNESS, divider.height)
            assertEquals(frame.top + frame.headerHeight, divider.maxY, 0.001f)
            // The same left and right edges as the column: the card's and the band's, not the title's x.
            assertEquals(line.contentColumn(section).x, divider.x)
            assertEquals(line.contentColumn(section).maxX, divider.maxX, 0.001f)
            assertEquals(none.sectionFrame(section)!!.top, frame.top)
            assertEquals(none.sectionFrame(section)!!.height, frame.height)
        }
    }

    @Test
    fun theDividerSharesItsEdgesWithTheCardAndTheBandUnderInsetGrouped() {
        val style = insetGrouped().also {
            it.headerSeparatorStyle = CYLHeaderSeparatorStyle.CYLHeaderSeparatorStyleLine
            it.headerBackgroundColor = CYLSectionStyleColors.HEADER_BAND
        }
        val frame = makeList(style, 3).sectionFrame(0)!!
        assertEquals(frame.card!!.x, frame.headerSeparator!!.x)
        assertEquals(frame.card!!.maxX, frame.headerSeparator!!.maxX, 0.001f)
        assertEquals(frame.headerBand!!.x, frame.headerSeparator!!.x)
        assertEquals(frame.headerBand!!.maxX, frame.headerSeparator!!.maxX, 0.001f)
        // The card, the band and the divider keep the board's edges; the title block has the tags' edges inside them.
        assertEquals(frame.card!!.x + CYLSectionStyleMetrics.CARD_PADDING, frame.headerInsetLeft, 0.001f)
    }

    @Test
    fun theDividerInsetsOverrideTheColumnEdges() {
        val style = plain().also {
            it.headerSeparatorStyle = CYLHeaderSeparatorStyle.CYLHeaderSeparatorStyleLine
            it.headerSeparatorInsets = CYLEdgeInsets(0f, 5f, 0f, 7f)
        }
        val divider = makeList(style, 3).sectionFrame(0)!!.headerSeparator!!
        assertEquals(16f + 5f, divider.x)
        assertEquals(WIDTH_PX - 16f - 7f, divider.maxX)
    }

    @Test
    fun aSectionFoldsAtTheReducedWidth() {
        fun make(style: CYLMenuStyle) = makeList(style, TAGS_IN_TWO_ROWS) {
            it.showsSectionHeaders = false
            it.defaultVisibleRows = 2
            it.foldControl = CYLMenuFoldControl.foldControlWithPosition(CYLMenuFoldControlPosition.TAIL, CYLMenuFoldControlContent.CYLMenuFoldControlContentIcon)
        }
        val plain = make(plain())
        assertEquals(2, plain.numberOfRowsInSection(0))
        assertFalse(plain.canFoldSection(0))
        val narrow = make(insetGrouped().also { it.sectionContentInsets = CYLEdgeInsets(12f, 40f, 12f, 40f) })
        assertTrue(narrow.numberOfRowsInSection(0) > 2)
        assertTrue(narrow.canFoldSection(0))
        assertTrue(narrow.numberOfVisibleItemsInSection(0) < TAGS_IN_TWO_ROWS)
    }

    // MARK: Colors

    @Test
    @Config(qualifiers = "notnight")
    fun theColorDefaultsInLightMode() {
        val style = insetGrouped()
        assertNull(style.sectionBackgroundColor)
        assertNull(style.headerBackgroundColor)
        assertNull(style.headerSeparatorColor)
        assertEquals(Color.WHITE, style.resolvedSectionBackgroundColor(context))
        assertEquals(0xFFF2F2F7.toInt(), style.resolvedBackgroundColor(context))
        assertEquals(0xFFEFEFF4.toInt(), CYLSectionStyleColors.headerBand(context))
        assertEquals(0x4A3C3C43, style.resolvedHeaderSeparatorColor(context))
    }

    @Test
    @Config(qualifiers = "night")
    fun theColorDefaultsInDarkMode() {
        val style = insetGrouped()
        assertEquals(0xFF1C1C1E.toInt(), style.resolvedSectionBackgroundColor(context))
        assertEquals(Color.BLACK, style.resolvedBackgroundColor(context))
        assertEquals(0xFF2C2C2EL.toInt(), CYLSectionStyleColors.headerBand(context))
        assertEquals(0x99545458L.toInt(), style.resolvedHeaderSeparatorColor(context))
        // A color the host sets wins in either mode.
        style.sectionBackgroundColor = Color.RED
        style.headerSeparatorColor = Color.GREEN
        assertEquals(Color.RED, style.resolvedSectionBackgroundColor(context))
        assertEquals(Color.GREEN, style.resolvedHeaderSeparatorColor(context))
    }

    @Test
    @Config(qualifiers = "notnight")
    fun aColorTheAppSetIsKeptInLightMode() {
        val style = insetGrouped().also {
            it.sectionBackgroundColor = Color.RED
            it.headerSeparatorColor = Color.GREEN
        }
        assertEquals(Color.RED, style.resolvedSectionBackgroundColor(context))
        assertEquals(Color.GREEN, style.resolvedHeaderSeparatorColor(context))
    }

    @Test
    @Config(qualifiers = "notnight")
    fun theGroupedBackgroundReplacesAnUnsetBackgroundOnlyUnderInsetGrouped() {
        assertEquals(Color.WHITE, plain().resolvedBackgroundColor(context))
        assertEquals(0xFFF2F2F7.toInt(), insetGrouped().resolvedBackgroundColor(context))
        // Set by the app: kept, even when it is the default white.
        val set = insetGrouped().also { it.backgroundColor = Color.WHITE }
        assertEquals(Color.WHITE, set.resolvedBackgroundColor(context))
        // The rule survives copy(): a set background stays set, an unset one stays unset.
        assertEquals(Color.WHITE, set.copy().resolvedBackgroundColor(context))
        assertEquals(0xFFF2F2F7.toInt(), insetGrouped().copy().resolvedBackgroundColor(context))
    }

    private fun backgroundPixel(list: CYLTagListView): Int = list.backgroundColorInUse

    // MARK: The default list background follows light / dark mode (docs/tag-section-style.md)

    @Test
    @Config(qualifiers = "notnight")
    fun theDefaultListBackgroundIsWhiteInLightMode() {
        // The plain look: an unset background is the system background (the card default is the grouped background).
        assertEquals(Color.WHITE, plain().resolvedBackgroundColor(context))
        assertEquals(Color.WHITE, backgroundPixel(makeList(plain(), 3)))
    }

    @Test
    @Config(qualifiers = "night")
    fun theDefaultListBackgroundIsBlackInDarkMode() {
        assertEquals(Color.BLACK, plain().resolvedBackgroundColor(context))
        assertEquals(Color.BLACK, backgroundPixel(makeList(plain(), 3)))
        assertEquals(Color.BLACK, plain().copy().resolvedBackgroundColor(context))
    }

    @Test
    @Config(qualifiers = "notnight")
    fun aSetTransparentBackgroundWinsInLightMode() {
        val style = CYLMenuStyle().also { it.backgroundColor = Color.TRANSPARENT }
        assertEquals(Color.TRANSPARENT, style.resolvedBackgroundColor(context))
        assertEquals(Color.TRANSPARENT, backgroundPixel(makeList(style, 3)))
    }

    @Test
    @Config(qualifiers = "night")
    fun aSetTransparentBackgroundWinsInDarkMode() {
        val style = CYLMenuStyle().also { it.backgroundColor = Color.TRANSPARENT }
        assertEquals(Color.TRANSPARENT, style.resolvedBackgroundColor(context))
        assertEquals(Color.TRANSPARENT, style.copy().resolvedBackgroundColor(context))
        assertEquals(Color.TRANSPARENT, backgroundPixel(makeList(style, 3)))
    }

    @Test
    @Config(qualifiers = "night")
    fun aSetWhiteBackgroundIsKeptInDarkMode() {
        val style = CYLMenuStyle().also { it.backgroundColor = Color.WHITE }
        assertEquals(Color.WHITE, style.resolvedBackgroundColor(context))
    }

    @Test
    @Config(qualifiers = "notnight")
    fun theTintOnTheDefaultBackgroundIsDarkInLightMode() {
        assertEquals(Color.BLACK, CYLMenuStyle().resolvedTintColor(context))
        assertEquals(Color.BLACK, titleColor(makeList(CYLMenuStyle(), 2)))
    }

    @Test
    @Config(qualifiers = "night")
    fun theTintOnTheDefaultBackgroundIsLightInDarkMode() {
        assertEquals(Color.WHITE, CYLMenuStyle().resolvedTintColor(context))
        assertEquals(Color.WHITE, CYLMenuStyle().resolvedHeaderTextColor(context))
        assertEquals(Color.WHITE, titleColor(makeList(CYLMenuStyle(), 2)))
    }

    @Test
    @Config(qualifiers = "notnight")
    fun theListDrawsTheGroupedBackgroundUnderInsetGrouped() {
        assertEquals(0xFFF2F2F7.toInt(), backgroundPixel(makeList(insetGrouped(), 3)))
        assertEquals(Color.WHITE, backgroundPixel(makeList(plain(), 3)))
    }

    /** Switching the mode while the list is shown updates it, with no reload; colors the app set are kept. */
    @Test
    @Config(qualifiers = "notnight")
    fun switchingTheModeUpdatesAShownList() {
        val controller = Robolectric.buildActivity(Activity::class.java).setup()
        val activity = controller.get()
        val list = CYLTagListView(activity)
        list.style = insetGrouped()
        list.menuDataSource = CYLSectionStyleSource(3)
        activity.setContentView(FrameLayout(activity).apply { addView(list, FrameLayout.LayoutParams(WIDTH_PX, FrameLayout.LayoutParams.WRAP_CONTENT)) })
        list.reloadMenuData()
        shadowOf(Looper.getMainLooper()).idleFor(Duration.ofMillis(100))
        assertEquals(0xFFF2F2F7.toInt(), backgroundPixel(list))
        org.robolectric.RuntimeEnvironment.setQualifiers("+night")
        list.dispatchConfigurationChanged(activity.resources.configuration)
        assertEquals(Color.BLACK, backgroundPixel(list))
    }

    @Test
    @Config(qualifiers = "night")
    fun aBackgroundTheAppSetIsKeptInDarkMode() {
        val style = insetGrouped().also { it.backgroundColor = Color.RED }
        assertEquals(Color.RED, style.resolvedBackgroundColor(context))
        assertEquals(Color.RED, backgroundPixel(makeList(style, 3)))
    }

    // MARK: The card's background style

    @Test
    fun theCardIsFlatByDefaultAndTheKeyParses() {
        assertEquals(CYLTagBackgroundStyle.CYLTagBackgroundStyleFlat, plain().sectionBackgroundStyle)
        val style = CYLMenuStyle.styleWithConfiguration(mapOf(CYLMenuStyleSectionBackgroundStyle to "liquidGlass"))
        assertEquals(CYLTagBackgroundStyle.CYLTagBackgroundStyleLiquidGlass, style.sectionBackgroundStyle)
        assertEquals(CYLTagBackgroundStyle.CYLTagBackgroundStyleLiquidGlass, style.copy().sectionBackgroundStyle)
        assertEquals(CYLTagBackgroundStyle.CYLTagBackgroundStyleFlat,
            CYLMenuStyle.styleWithConfiguration(mapOf(CYLMenuStyleSectionBackgroundStyle to "nonsense")).sectionBackgroundStyle)
    }

    private fun glassCards(list: CYLTagListView) = descendants(list).filter { it.javaClass == com.cyl.animateditem.CYLAnimatedItemView::class.java }

    @Test
    @Config(sdk = [30])
    fun glassFallsBackToFlatWhereTheDeviceDrawsNoneWithTheSameGeometry() {
        val flat = makeList(insetGrouped(), 6, 3)
        val glass = makeList(insetGrouped().also { it.sectionBackgroundStyle = CYLTagBackgroundStyle.CYLTagBackgroundStyleLiquidGlass }, 6, 3)
        assertEquals(CYLTagBackgroundStyle.CYLTagBackgroundStyleFlat, glass.style!!.resolvedSectionBackgroundStyle)
        assertTrue(glassCards(glass).isEmpty())
        assertEquals(flat.contentHeight, glass.contentHeight, 0f)
        for (section in 0..1) assertEquals(flat.sectionFrame(section), glass.sectionFrame(section))
    }

    @Test
    @Config(sdk = [34])
    fun aGlassCardIsTheLibrariesGlassWithTheCardFrame() {
        val flat = makeList(insetGrouped(), 6, 3)
        val style = insetGrouped().also {
            it.sectionBackgroundStyle = CYLTagBackgroundStyle.CYLTagBackgroundStyleLiquidGlass
            it.sectionBackgroundColor = Color.RED
        }
        val glass = makeList(style, 6, 3)
        val cards = glassCards(glass)
        assertEquals(2, cards.size)
        cards.forEachIndexed { section, view ->
            val card = glass.sectionFrame(section)!!.card!!
            assertEquals(card, CYLRect(view.left.toFloat(), view.top.toFloat(), view.width.toFloat(), view.height.toFloat()))
            val item = view as com.cyl.animateditem.CYLAnimatedItemView
            assertEquals(Color.RED, item.itemBackgroundColor)
            assertEquals(CYLSectionStyleMetrics.CARD_CORNER_RADIUS, item.itemCornerRadius)
        }
        assertEquals(flat.contentHeight, glass.contentHeight, 0f)
    }

    // MARK: copy() and configuration

    @Test
    fun theDefaultsAreTheNamedConstants() {
        val style = CYLMenuStyle()
        assertEquals("the card is the default look (owner, revised decision)", CYLSectionStyle.CYLSectionStyleInsetGrouped, style.sectionStyle)
        assertEquals(10f, style.sectionCornerRadius)
        assertEquals(CYLEdgeInsets(12f, 12f, 12f, 12f), style.sectionContentInsets)
        assertEquals(0f, style.headerCornerRadius)
        assertEquals(CYLEdgeInsets(0f, 12f, 0f, 12f), style.headerContentInsets)
        assertEquals(CYLHeaderSeparatorStyle.CYLHeaderSeparatorStyleNone, style.headerSeparatorStyle)
        assertEquals(0.5f, style.headerSeparatorThickness)
        assertNull(style.headerSeparatorInsets)
        assertNull("no header band by default", style.headerBackgroundColor)
        assertEquals(CYLTagBackgroundStyle.CYLTagBackgroundStyleFlat, style.sectionBackgroundStyle)
        assertTrue(style.isInsetGrouped)
    }

    @Test
    fun theNewDefaultIsTheCardAndPlainOptsOut() {
        // A list that sets nothing draws the card, with the same frame function the explicit insetGrouped uses.
        val list = makeList(CYLMenuStyle(), 6, 3)
        for (section in 0..1) {
            val frame = list.sectionFrame(section)!!
            val card = frame.card
            assertNotNull("the default list draws a card in section $section", card)
            assertEquals(list.contentColumn(section).x, card!!.x)
            assertEquals(list.contentColumn(section).width, card.width)
            assertNull("the divider is off by default", frame.headerSeparator)
            assertNull("the header band is off by default", frame.headerBand)
        }
        assertEquals(16f + CYLSectionStyleMetrics.CARD_PADDING, list.tagColumn(0).x)
        assertEquals(WIDTH_PX - 32f - 2 * CYLSectionStyleMetrics.CARD_PADDING, list.tagColumn(0).width)
        val optedOut = makeList(plain(), 6, 3)
        assertNull("plain draws no card", optedOut.sectionFrame(0)!!.card)
        assertEquals(CYLRect(16f, 0f, WIDTH_PX - 32f, 0f), optedOut.contentColumn(0))
        // The default list is the explicit insetGrouped list (the card list is no longer always taller than the plain one: its header is sized to the text).
        val explicit = makeList(CYLMenuStyle().also { it.sectionStyle = CYLSectionStyle.CYLSectionStyleInsetGrouped }, 6, 3)
        assertEquals(explicit.contentHeight, list.contentHeight, 0f)
    }

    @Test
    @Config(qualifiers = "notnight")
    fun aDefaultListGetsTheGroupedBackgroundAndATintThatFollowsIt() {
        assertEquals(0xFFF2F2F7.toInt(), backgroundPixel(makeList(CYLMenuStyle(), 3)))
        assertEquals(0xFFF2F2F7.toInt(), CYLMenuStyle().resolvedBackgroundColor(context))
        assertEquals("the tint is chosen against the grouped background", Color.BLACK, CYLMenuStyle().resolvedTintColor(context))
        // An app that sets the background keeps it, and plain keeps the white the list painted before.
        assertEquals(Color.WHITE, backgroundPixel(makeList(CYLMenuStyle().also { it.backgroundColor = Color.WHITE }, 3)))
        assertEquals(Color.WHITE, backgroundPixel(makeList(plain(), 3)))
    }

    @Test
    @Config(qualifiers = "night")
    fun aDefaultListIsBlackInDarkModeAndItsTintIsLight() {
        assertEquals(Color.BLACK, backgroundPixel(makeList(CYLMenuStyle(), 3)))
        assertEquals(Color.WHITE, CYLMenuStyle().resolvedTintColor(context))
        // plain: the unset background is the system background (black in dark mode), so its tint is light there too.
        assertEquals(Color.WHITE, plain().resolvedTintColor(context))
    }

    @Test
    fun theConfigurationKeyPlainOptsOutAndAnEmptyConfigurationIsTheCard() {
        val plainStyle = CYLMenuStyle.styleWithConfiguration(mapOf(CYLMenuStyleSectionStyle to "plain"))
        assertEquals(CYLSectionStyle.CYLSectionStylePlain, plainStyle.sectionStyle)
        assertFalse(plainStyle.isInsetGrouped)
        assertEquals(CYLSectionStyle.CYLSectionStylePlain, CYLMenuStyle.styleWithConfiguration(mapOf(CYLMenuStyleSectionStyle to "Plain")).sectionStyle)
        assertEquals(CYLSectionStyle.CYLSectionStylePlain, plainStyle.copy().sectionStyle)
        assertEquals(CYLSectionStyle.CYLSectionStyleInsetGrouped, CYLMenuStyle.styleWithConfiguration(emptyMap()).sectionStyle)
    }

    @Test
    fun everyLibraryLookThatIsACompleteLookOptsOut() {
        val looks = mapOf(
            "tagCloudStyle" to CYLMenuStyle.tagCloudStyle(),
            "tagContainerStyle" to CYLMenuStyle.tagContainerStyle(),
            "wordPicker" to CYLMenuStyle.wordPicker(),
            "grid" to CYLMenuStyle.gridStyleWithNumberOfItemsPerRow(3),
            "sectionTitle" to CYLMenuStyle.sectionTitle(),
            "filterTag" to CYLMenuStyle.filterTag(),
            "classifyMenuTag" to CYLMenuStyle.classifyMenuTag(),
            "defaultTitleStyle" to CYLTagListView.defaultTitleStyle(),
        )
        for ((name, style) in looks) assertEquals("$name stays flat", CYLSectionStyle.CYLSectionStylePlain, style.sectionStyle)
    }

    @Test
    fun copyKeepsTheSectionStyle() {
        val style = insetGrouped().also {
            it.sectionBackgroundColor = Color.RED
            it.sectionCornerRadius = 4f
            it.sectionContentInsets = CYLEdgeInsets(1f, 2f, 3f, 4f)
            it.headerBackgroundColor = Color.GREEN
            it.headerCornerRadius = 5f
            it.headerContentInsets = CYLEdgeInsets(0f, 6f, 0f, 7f)
            it.headerSeparatorStyle = CYLHeaderSeparatorStyle.CYLHeaderSeparatorStyleLine
            it.headerSeparatorColor = Color.BLUE
            it.headerSeparatorThickness = 2f
            it.headerSeparatorInsets = CYLEdgeInsets(0f, 8f, 0f, 9f)
        }
        val copy = style.copy()
        assertEquals(style.sectionStyle, copy.sectionStyle)
        assertEquals(Color.RED, copy.sectionBackgroundColor)
        assertEquals(4f, copy.sectionCornerRadius)
        assertEquals(style.sectionContentInsets, copy.sectionContentInsets)
        assertEquals(Color.GREEN, copy.headerBackgroundColor)
        assertEquals(5f, copy.headerCornerRadius)
        assertEquals(style.headerContentInsets, copy.headerContentInsets)
        assertEquals(CYLHeaderSeparatorStyle.CYLHeaderSeparatorStyleLine, copy.headerSeparatorStyle)
        assertEquals(Color.BLUE, copy.headerSeparatorColor)
        assertEquals(2f, copy.headerSeparatorThickness)
        assertEquals(style.headerSeparatorInsets, copy.headerSeparatorInsets)
    }

    @Test
    fun theConfigurationKeysParse() {
        val style = CYLMenuStyle.styleWithConfiguration(mapOf(
            CYLMenuStyleSectionStyle to "insetGrouped",
            CYLMenuStyleSectionBackgroundColor to "#112233",
            CYLMenuStyleSectionCornerRadius to 6,
            CYLMenuStyleSectionContentInsets to listOf(1, 2, 3, 4),
            CYLMenuStyleHeaderBackgroundColor to "#445566",
            CYLMenuStyleHeaderCornerRadius to 3,
            CYLMenuStyleHeaderContentInsets to mapOf("left" to 9, "right" to 10),
            CYLMenuStyleHeaderSeparatorStyle to "Line",
            CYLMenuStyleHeaderSeparatorColor to "#778899",
            CYLMenuStyleHeaderSeparatorThickness to 1,
            CYLMenuStyleHeaderSeparatorInsets to mapOf("left" to 11, "right" to 12),
        ))
        assertEquals(CYLSectionStyle.CYLSectionStyleInsetGrouped, style.sectionStyle)
        assertEquals(Color.rgb(0x11, 0x22, 0x33), style.sectionBackgroundColor)
        assertEquals(6f, style.sectionCornerRadius)
        assertEquals(CYLEdgeInsets(1f, 2f, 3f, 4f), style.sectionContentInsets)
        assertEquals(Color.rgb(0x44, 0x55, 0x66), style.headerBackgroundColor)
        assertEquals(3f, style.headerCornerRadius)
        assertEquals(CYLEdgeInsets(0f, 9f, 0f, 10f), style.headerContentInsets)
        assertEquals(CYLHeaderSeparatorStyle.CYLHeaderSeparatorStyleLine, style.headerSeparatorStyle)
        assertEquals(Color.rgb(0x77, 0x88, 0x99), style.headerSeparatorColor)
        assertEquals(1f, style.headerSeparatorThickness)
        assertEquals(CYLEdgeInsets(0f, 11f, 0f, 12f), style.headerSeparatorInsets)
        // Absent keys keep the defaults, and an unknown value keeps the current one.
        val untouched = CYLMenuStyle.styleWithConfiguration(mapOf(CYLMenuStyleSectionStyle to "nonsense"))
        assertEquals(CYLSectionStyle.CYLSectionStyleInsetGrouped, untouched.sectionStyle)
        assertNull(untouched.headerBackgroundColor)
        assertNotNull(untouched.sectionContentInsets)
    }

    // MARK: The default tint of the built-in views (tintColor)

    private fun titleColor(list: CYLTagListView) = descendants(list).filterIsInstance<TextView>().first { it.text == "Section 0" }.currentTextColor

    @Test
    @Config(qualifiers = "night")
    fun theTintIsDarkOnALightBackgroundWhateverTheMode() {
        // A light background the app set (the unset default is black in dark mode, see theDefaultListBackgroundFollowsTheMode).
        val style = plain().also { it.backgroundColor = Color.WHITE }
        assertEquals(Color.BLACK, style.resolvedTintColor(context))
        assertEquals(Color.BLACK, style.resolvedHeaderTextColor(context))
        assertEquals(Color.BLACK, style.resolvedFoldControlColor(context))
        assertEquals(Color.BLACK, style.resolvedMoreButtonColor(context))
        assertEquals(Color.BLACK, style.resolvedClearButtonColor(context))
        assertEquals(Color.BLACK, titleColor(makeList(style, 2)))
        // The grouped background in light is light too; in dark mode it is black, so white.
        assertEquals(Color.WHITE, insetGrouped().resolvedTintColor(context))
    }

    @Test
    @Config(qualifiers = "notnight")
    fun theTintIsLightOnADarkBackgroundWhateverTheMode() {
        val style = plain().also { it.backgroundColor = Color.BLACK }
        assertEquals(Color.WHITE, style.resolvedTintColor(context))
        assertEquals(Color.WHITE, titleColor(makeList(style, 2)))
        assertEquals(Color.WHITE, plain().also { it.backgroundColor = 0xFF1C1C1E.toInt() }.resolvedTintColor(context))
        assertEquals(Color.BLACK, insetGrouped().resolvedTintColor(context))
    }

    @Test
    fun theTintLuminanceHasOneNamedThreshold() {
        assertEquals(0.179f, CYLTintLuminanceThreshold)
        assertEquals(1f, CYLMenuColorLuminance(Color.WHITE)!!, 0.001f)
        assertEquals(0f, CYLMenuColorLuminance(Color.BLACK)!!, 0.001f)
        assertNull(CYLMenuColorLuminance(Color.TRANSPARENT))
        assertNull(CYLMenuColorLuminance(0x80FFFFFF.toInt()))
    }

    @Test
    @Config(qualifiers = "night")
    fun aTransparentListFollowsTheSystemModeInDark() {
        val style = plain().also { it.backgroundColor = Color.TRANSPARENT }
        assertEquals(CYLSystemColors.primary(context), style.resolvedTintColor(context))
    }

    @Test
    @Config(qualifiers = "notnight")
    fun aTransparentListFollowsTheSystemModeInLight() {
        val style = plain().also { it.backgroundColor = Color.TRANSPARENT }
        assertEquals(CYLSystemColors.primary(context), style.resolvedTintColor(context))
        assertEquals(CYLSystemColors.primary(context), style.resolvedHeaderTextColor(context))
    }

    @Test
    @Config(qualifiers = "night")
    fun aTintTheAppSetWinsInBothModes() {
        val style = plain().also { it.tintColor = Color.RED }
        assertEquals(Color.RED, style.resolvedTintColor(context))
        assertEquals(Color.RED, style.resolvedHeaderTextColor(context))
        assertEquals(Color.RED, style.resolvedFoldControlColor(context, true))
        assertEquals(Color.RED, style.resolvedMoreButtonColor(context))
        assertEquals(Color.RED, titleColor(makeList(style, 2)))
    }

    @Test
    @Config(qualifiers = "notnight")
    fun underABandTheTintIsChosenAgainstTheBandColor() {
        val style = plain().also { it.headerBackgroundColor = CYLSectionStyleColors.HEADER_BAND_DARK }
        assertEquals(Color.WHITE, style.resolvedTintColor(context, true))
        assertEquals(Color.WHITE, style.resolvedHeaderTextColor(context, true))
        // Off the band the list's own white background decides.
        assertEquals(Color.BLACK, style.resolvedTintColor(context, false))
        assertEquals(Color.WHITE, titleColor(makeList(style, 2)))
    }

    @Test
    @Config(qualifiers = "night")
    fun colorsSetOnAViewWinOverTheTint() {
        val style = plain().also {
            it.tintColor = Color.RED
            it.headerTextColor = Color.GREEN
            it.foldControlColor = Color.BLUE
            it.moreButtonColor = Color.YELLOW
        }
        assertEquals(Color.GREEN, style.resolvedHeaderTextColor(context))
        assertEquals(Color.BLUE, style.resolvedFoldControlColor(context))
        assertEquals(Color.YELLOW, style.resolvedMoreButtonColor(context))
        assertEquals(Color.GREEN, style.resolvedClearButtonColor(context))
        assertEquals(Color.GREEN, titleColor(makeList(style, 2)))
    }

    @Test
    fun theTintKeyParsesAndCopyKeepsIt() {
        val style = CYLMenuStyle.styleWithConfiguration(mapOf(CYLMenuStyleTintColor to "#112233"))
        assertEquals(Color.rgb(0x11, 0x22, 0x33), style.tintColor)
        assertEquals(Color.rgb(0x11, 0x22, 0x33), style.copy().tintColor)
        assertNull(plain().tintColor)
    }

    @Test
    @Config(qualifiers = "notnight")
    fun switchingTheModeReResolvesTheTintOfAShownList() {
        val activity = Robolectric.buildActivity(Activity::class.java).setup().get()
        val list = CYLTagListView(activity)
        // The grouped background follows the mode, so does the tint chosen against it.
        list.style = insetGrouped()
        list.menuDataSource = CYLSectionStyleSource(2)
        activity.setContentView(FrameLayout(activity).apply { addView(list, FrameLayout.LayoutParams(WIDTH_PX, FrameLayout.LayoutParams.WRAP_CONTENT)) })
        list.reloadMenuData()
        shadowOf(Looper.getMainLooper()).idleFor(Duration.ofMillis(100))
        val light = titleColor(list)
        assertEquals(Color.BLACK, light)
        org.robolectric.RuntimeEnvironment.setQualifiers("+night")
        list.dispatchConfigurationChanged(activity.resources.configuration)
        shadowOf(Looper.getMainLooper()).idleFor(Duration.ofMillis(100))
        val dark = titleColor(list)
        assertEquals(Color.WHITE, dark)
    }

    private companion object {
        const val WIDTH_PX = 320
        /** The header fold control's glyph padding beyond the header's edge (HEADER_FOLD_OVERHANG of the list view), dp. */
        const val FOLD_OVERHANG = 6f
        const val TAGS_IN_TWO_ROWS = 16
    }
}
