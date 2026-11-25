package com.cyl.classifymenu

import android.graphics.Color
import androidx.test.core.app.ApplicationProvider
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config

/**
 * The list's own texts and icons (header title, fold controls, More and clear buttons) default to one tint that follows
 * dark mode, and a tag's default background and text follow it too (iOS `UIColor.label`, `secondarySystemBackground`):
 * light mode is unchanged, a color the host sets wins in either mode.
 */
@RunWith(RobolectricTestRunner::class)
class CYLDarkModeDefaultsTest {

    private val context = ApplicationProvider.getApplicationContext<android.content.Context>()

    @Test
    fun theListColorsAreUnsetByDefaultSoTheyFollowTheTheme() {
        val style = CYLMenuStyle()
        assertNull(style.headerTextColor)
        assertNull(style.foldControlColor)
        assertNull(style.moreButtonColor)
        assertNull(style.clearButtonColor)
    }

    @Test
    @Config(qualifiers = "night")
    fun inDarkModeTheOneTintIsLightAndTheTagDefaultsAreTheDarkSurface() {
        val style = CYLMenuStyle()
        val tint = CYLSystemColors.primary(context)
        // Readable on the dark surface: the tint is a light color.
        assertEquals(true, (Color.red(tint) + Color.green(tint) + Color.blue(tint)) / 3 > 127)
        assertEquals(tint, style.resolvedHeaderTextColor(context))
        assertEquals(tint, style.resolvedFoldControlColor(context))
        assertEquals(tint, style.resolvedMoreButtonColor(context))
        assertEquals(tint, style.resolvedClearButtonColor(context))
        val appearance = style.normalAppearance
        assertEquals(CYLSystemColors.SECONDARY_BACKGROUND_DARK, appearance.resolvedBackgroundColor(context))
        assertEquals(tint, appearance.resolvedTextColor(context))
    }

    @Test
    @Config(qualifiers = "notnight")
    fun inLightModeTheTagDefaultsAreUnchanged() {
        val appearance = CYLMenuStyle().normalAppearance
        assertEquals(Color.WHITE, appearance.resolvedBackgroundColor(context))
        assertEquals(CYLColor.white(0.25f), appearance.resolvedTextColor(context))
        assertEquals(Color.WHITE, appearance.backgroundColor)
    }

    @Test
    @Config(qualifiers = "night")
    fun aColorTheHostSetsWinsInDarkMode() {
        val style = CYLMenuStyle()
        style.headerTextColor = Color.RED
        style.foldControlColor = Color.GREEN
        style.moreButtonColor = Color.BLUE
        style.clearButtonColor = Color.YELLOW
        style.normalAppearance.backgroundColor = Color.MAGENTA
        style.normalAppearance.textColor = Color.CYAN
        assertEquals(Color.RED, style.resolvedHeaderTextColor(context))
        assertEquals(Color.GREEN, style.resolvedFoldControlColor(context))
        assertEquals(Color.BLUE, style.resolvedMoreButtonColor(context))
        assertEquals(Color.YELLOW, style.resolvedClearButtonColor(context))
        assertEquals(Color.MAGENTA, style.normalAppearance.resolvedBackgroundColor(context))
        assertEquals(Color.CYAN, style.normalAppearance.resolvedTextColor(context))
    }
}
