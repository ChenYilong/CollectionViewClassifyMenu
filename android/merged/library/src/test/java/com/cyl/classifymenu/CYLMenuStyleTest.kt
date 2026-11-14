package com.cyl.classifymenu

import android.graphics.Color
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNotSame
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner

/** The Android port of the iOS style, colors, tags and strings (CYLMenuStyle, CYLTagColors, CYLTag, CYLMenuResources). */
@RunWith(RobolectricTestRunner::class)
class CYLMenuStyleTest {

    @Test
    fun defaultStyleMatchesIOS() {
        val style = CYLMenuStyle.defaultStyle()
        assertEquals(30f, style.itemHeight)
        assertEquals(10f, style.interitemSpacing)
        assertEquals(CYLEdgeInsets(10f, 16f, 10f, 16f), style.sectionInsets)
        assertEquals(CYLAppTintColor, style.selectedAppearance.backgroundColor)
        assertEquals(Color.WHITE, style.selectedAppearance.textColor)
        assertEquals("×", style.deleteIndicatorTitle)
        style.deleteIndicatorTitle = ""
        assertEquals("×", style.deleteIndicatorTitle)
    }

    @Test
    fun appearanceForStatePrefersDisabledThenSelected() {
        val style = CYLMenuStyle.defaultStyle()
        assertTrue(style.appearanceForState(CYLControlState.DISABLED or CYLControlState.SELECTED) === style.disabledAppearance)
        assertTrue(style.appearanceForState(CYLControlState.SELECTED) === style.selectedAppearance)
        assertTrue(style.appearanceForState(CYLControlState.NORMAL) === style.normalAppearance)
        style.setIconColor(null, CYLControlState.NORMAL)
        assertEquals(style.normalAppearance.textColor, style.iconColorForState(CYLControlState.NORMAL))
    }

    @Test
    fun displayedTitleTruncatesAndReversesWholeCharacters() {
        val style = CYLMenuStyle.tagContainerStyle()
        assertEquals(23, style.maximumTitleLength)
        assertEquals("Welcome to use AndroidT...", style.displayedTitleForTitle("Welcome to use AndroidTagView!"))
        style.maximumTitleLength = 0
        style.reversesTitleCharacters = true
        assertEquals("diordnA", style.displayedTitleForTitle("Android"))
        assertEquals("👍🏽a", style.displayedTitleForTitle("a👍🏽"))
    }

    @Test
    fun copyIsDeep() {
        val style = CYLMenuStyle.tagCloudStyle()
        val copy = style.copy()
        assertNotSame(style.normalAppearance, copy.normalAppearance)
        copy.normalAppearance.backgroundColor = Color.RED
        assertEquals(Color.rgb(0, 0xBF, 0xFF), style.normalAppearance.backgroundColor)
        assertEquals(5f, copy.lineSpacing)
    }

    @Test
    fun appearanceSanitizesLengths() {
        val appearance = CYLTagAppearance()
        appearance.cornerRadius = -3f
        appearance.borderWidth = Float.NaN
        appearance.margin = 12f
        assertEquals(0f, appearance.cornerRadius)
        assertEquals(0f, appearance.borderWidth)
        assertEquals(CYLEdgeInsets(5f, 12f, 5f, 12f), appearance.contentInsets)
    }

    @Test
    fun colorsThemesAndApplying() {
        assertNull(CYLTagColors.colorsForTheme(CYLTagColorTheme.CYLTagColorThemeNone, 0))
        val cyan = CYLTagColors.colorsForTheme(CYLTagColorTheme.CYLTagColorThemePureCyan, 0)!!
        assertEquals(Color.argb(0x33, 0x00, 0xBC, 0xD4), cyan.backgroundColor)
        assertEquals(Color.argb(0x88, 0x00, 0xBC, 0xD4), cyan.borderColor)
        val style = cyan.styleByApplyingToStyle(null)
        assertEquals(cyan.backgroundColor, style.normalAppearance.backgroundColor)
        assertEquals(cyan.selectedBackgroundColor, style.selectedAppearance.backgroundColor)
        assertEquals("F44336", CYLTagColors.paletteHexByName["RED"])
    }

    @Test
    fun tagStyleOverridesTheListStyle() {
        val tag = CYLTag("Java", "#00BFFF")
        assertEquals(Color.rgb(0, 0xBF, 0xFF), tag.backgroundColor)
        assertTrue(tag.hasCustomStyle)
        tag.cornerRadius = 0f
        tag.textSize = 18f
        val style = tag.styleWithBaseStyle(CYLMenuStyle.defaultStyle())
        assertEquals(0f, style.selectedAppearance.cornerRadius)
        assertEquals(18f, style.normalAppearance.font.size)
        assertFalse(CYLTag("plain").hasCustomStyle)
    }

    @Test
    fun tagDataSourceCachesStylesAndMovesTags() {
        val source = CYLTagDataSource(listOf(CYLTag("a"), CYLTag("b", Color.RED), CYLTag("c")))
        assertEquals(3, source.menuNumberOfItemsInSection(0))
        assertNull(source.menuStyleForItemAtIndexPath(CYLIndexPath(0, 0)))
        val style = source.menuStyleForItemAtIndexPath(CYLIndexPath(1, 0))
        assertTrue(style === source.menuStyleForItemAtIndexPath(CYLIndexPath(1, 0)))
        source.moveTagAtIndex(0, 2)
        assertEquals(listOf("b", "c", "a"), source.tags.map { it.title })
        source.menuRemoveItemAtIndexPath(CYLIndexPath(0, 0))
        assertEquals(listOf("c", "a"), source.tags.map { it.title })
    }

    @Test
    fun localizedStringsInEveryLanguage() {
        assertEquals(listOf("en", "zh-Hans", "zh-Hant"), CYLMenuResources.availableLanguages())
        val english = CYLMenuResources.localizedStringForKey("CYLMenuExpand", "en")
        val chinese = CYLMenuResources.localizedStringForKey("CYLMenuExpand", "zh-Hans")
        assertTrue(english.isNotEmpty() && english != "CYLMenuExpand")
        assertTrue(chinese != english)
        assertEquals("NoSuchKey", CYLMenuResources.localizedStringForKey("NoSuchKey", "zh-Hant"))
        CYLMenuResources.preferredLanguage = "zh-Hant"
        assertEquals("zh-Hant", CYLMenuResources.currentLanguage())
        CYLMenuResources.preferredLanguage = null
    }

    @Test
    fun colorsFromStrings() {
        assertEquals(Color.argb(0x80, 0x11, 0x22, 0x33), CYLMenuColorFromString("#11223380"))
        assertEquals(Color.rgb(0xAA, 0xBB, 0xCC), CYLMenuColorFromString("#ABC"))
        assertEquals(Color.rgb(0, 122, 255), CYLMenuColorFromString("systemBlueColor"))
        assertNull(CYLMenuColorFromString("not a color"))
    }
}
