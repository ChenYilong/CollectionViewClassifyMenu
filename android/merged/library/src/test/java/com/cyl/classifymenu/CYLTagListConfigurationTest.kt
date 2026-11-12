package com.cyl.classifymenu

import android.graphics.Color
import android.net.Uri
import android.view.View
import androidx.test.core.app.ApplicationProvider
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Assert.fail
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import java.io.File

/**
 * The Android port of `CYLTagListView+CYLConfiguration`: the same dictionaries and files as on iOS.
 */
@RunWith(RobolectricTestRunner::class)
class CYLTagListConfigurationTest {

    private val context = ApplicationProvider.getApplicationContext<android.content.Context>()

    private fun laidOut(view: CYLTagListView, widthPx: Int = 1080): CYLTagListView {
        view.measure(View.MeasureSpec.makeMeasureSpec(widthPx, View.MeasureSpec.EXACTLY), View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED))
        view.layout(0, 0, view.measuredWidth, view.measuredHeight)
        return view
    }

    @Test
    fun styleReadsNumbersSizesInsetsColorsAndFonts() {
        val style = CYLMenuStyle.styleWithConfiguration(mapOf(
            CYLMenuStyleItemHeight to "36", CYLMenuStyleImageSize to 18, CYLMenuStyleSectionInsets to "{4, 8, 4, 8}",
            CYLMenuStyleBackgroundColor to "#FF0000", CYLMenuStyleHeaderFont to mapOf("size" to 20, "weight" to "bold"),
            CYLMenuStyleImagePlacement to "trailing", CYLMenuStyleLayoutCentered to "no",
            CYLMenuStyleSelected to mapOf(CYLTagAppearanceBackgroundColor to "#00FF00", CYLTagAppearanceCornerRadius to 9),
        ))
        assertEquals(36f, style.itemHeight)
        assertEquals(CYLSize(18f, 18f), style.imageSize)
        assertEquals(CYLEdgeInsets(4f, 8f, 4f, 8f), style.sectionInsets)
        assertEquals(Color.RED, style.backgroundColor)
        assertEquals(20f, style.headerFont.size)
        assertEquals(CYLTagImagePlacement.CYLTagImagePlacementTrailing, style.imagePlacement)
        assertEquals(false, style.layoutCentered)
        assertEquals(Color.GREEN, style.selectedAppearance.backgroundColor)
        assertEquals(9f, style.selectedAppearance.cornerRadius)
    }

    @Test
    fun foldControlFromAPositionNameOrADictionary() {
        val bottom = CYLMenuFoldControl.foldControlWithConfiguration("bottom")!!
        assertEquals(CYLMenuFoldControlPosition.CYLMenuFoldControlPositionBottom, bottom.position)
        assertEquals(CYLMenuFoldControlContent.CYLMenuFoldControlContentIcon, bottom.content)
        val custom = CYLMenuFoldControl.foldControlWithConfiguration(mapOf(CYLMenuFoldControlKeyPosition to "topLeft",
            CYLMenuFoldControlKeyTitle to "More", CYLMenuFoldControlKeyRotatesImage to false))!!
        assertEquals(CYLMenuFoldControlPosition.CYLMenuFoldControlPositionTopLeading, custom.position)
        assertEquals("More", custom.title)
        assertEquals(false, custom.rotatesImageWhenExpanded)
        assertNull(CYLMenuFoldControl.foldControlWithConfiguration(listOf(1)))
    }

    @Test
    fun animationURLCarriesSortedEncodedOptions() {
        val url = CYLMenuAnimationURLWithOptions(Uri.parse("file:///a/truck.riv"), mapOf("stateMachine" to "State Machine 1", "artboard" to "Truck"))
        assertEquals("artboard=Truck&stateMachine=State%20Machine%201", url!!.encodedFragment)
        assertNull(CYLMenuAnimationURLWithOptions(null, mapOf("a" to "b")))
    }

    @Test
    fun listAppliesSectionsSelectionAndFolding() {
        val list = CYLTagListView.tagListViewWithConfiguration(context, mapOf(
            CYLTagListViewSelectionMode to "multiple",
            CYLTagListViewFoldControl to "bottom",
            CYLTagListViewDefaultVisibleRows to 1,
            CYLTagListViewTitle to "Filters",
            CYLTagListViewSections to listOf(
                mapOf(CYLTagSectionTitle to "Color", CYLTagSectionItems to listOf("Red", mapOf(CYLTagItemTitle to "Blue", CYLTagItemEnabled to false))),
                mapOf(CYLTagSectionTitle to "Size", CYLTagSectionItems to (1..30).map { "Size $it" },
                    CYLTagSectionStyle to mapOf(CYLMenuStyleItemHeight to 40)),
            ),
            CYLTagListViewSelectedItems to listOf("0-0", listOf(1, 2)),
        ))
        laidOut(list)
        assertEquals(CYLMenuSelectionMode.CYLMenuSelectionModeMultiple, list.selectionMode)
        assertEquals("Filters", list.title)
        assertNotNull(list.configurationDataSource)
        assertEquals(listOf(CYLIndexPath(0, 0), CYLIndexPath(2, 1)), list.selectedIndexPaths)
        assertEquals(listOf("Red", "Size 3"), list.selectedTitles)
        assertEquals(false, list.menuDataSource!!.menuItemIsEnabledAtIndexPath(CYLIndexPath(1, 0)))
        assertEquals(40f, list.menuDataSource!!.menuStyleForSection(1)!!.itemHeight)
        assertTrue(list.canFoldSection(1))
        assertTrue(list.numberOfVisibleItemsInSection(1) < 30)
        list.setExpanded(true, 1, false)
        assertEquals(30, list.numberOfVisibleItemsInSection(1))
        assertTrue(list.contentHeight > 0)
    }

    @Test
    fun tagsFromTitlesAndDictionaries() {
        val list = CYLTagListView.tagListViewWithConfiguration(context, mapOf(
            CYLTagListViewTags to listOf("One", mapOf(CYLTagItemTitle to "Two", CYLTagItemIdentifier to 7, CYLTagItemDeletable to true)),
        ))
        assertEquals(listOf("One", "Two"), list.tags.map { it.title })
        assertEquals(7, list.tags[1].identifier)
        assertTrue(list.tags[1].isDeletable)
    }

    @Test
    fun filesInJSONAndPropertyListFormat() {
        val folder = File(context.cacheDir, "config").apply { mkdirs() }
        val json = File(folder, "tags.json").apply { writeText("""{"title":"JSON","sections":[{"title":"A","items":["x","y"]}]}""") }
        val plist = File(folder, "tags.plist").apply {
            writeText("""<?xml version="1.0" encoding="UTF-8"?><plist version="1.0"><dict><key>title</key><string>Plist</string>
                <key>defaultVisibleRows</key><integer>2</integer><key>scrollEnabled</key><false/>
                <key>tags</key><array><string>a</string><string>b</string></array></dict></plist>""")
        }
        val fromJSON = CYLTagListView.tagListViewWithConfigurationFile(context, json.absolutePath)
        assertEquals("JSON", fromJSON.title)
        assertEquals(2, fromJSON.menuDataSource!!.menuNumberOfItemsInSection(0))
        val fromPlist = CYLTagListView.tagListViewWithConfigurationFile(context, plist.absolutePath)
        assertEquals("Plist", fromPlist.title)
        assertEquals(2, fromPlist.defaultVisibleRows)
        assertEquals(false, fromPlist.isScrollEnabled)
        assertEquals(listOf("a", "b"), fromPlist.tags.map { it.title })
        try {
            CYLTagListView.configurationWithContentsOfFile(context, File(folder, "missing.json").absolutePath)
            fail("expected an error")
        } catch (e: CYLMenuConfigurationException) {
            assertEquals(CYLMenuConfigurationError.CYLMenuConfigurationErrorFileNotFound, e.error)
            assertEquals(CYLMenuConfigurationErrorDomain, e.domain)
        }
        val yaml = File(folder, "tags.yaml").apply { writeText("title: x") }
        try {
            CYLTagListView.configurationWithContentsOfFile(context, yaml.absolutePath)
            fail("expected an error")
        } catch (e: CYLMenuConfigurationException) {
            assertEquals(CYLMenuConfigurationError.CYLMenuConfigurationErrorUnsupportedFormat, e.error)
        }
    }
}
