package com.cyl.classifymenu

import android.content.Context
import android.graphics.Color
import android.view.ContextThemeWrapper
import androidx.test.core.app.ApplicationProvider
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config

/**
 * The default text and icon tint (`CYLSystemColors.primary`) follows the MODE, not only the host theme: a host theme that is not a
 * DayNight theme keeps a dark `textColorPrimary` in night mode, which put dark text on dark glass (the Android example's theme is
 * `Theme.AppCompat.Light.DarkActionBar`). A DayNight theme keeps its own colour.
 */
@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34])
class CYLSystemPrimaryColorTest {

    private fun themed(theme: Int): Context = ContextThemeWrapper(ApplicationProvider.getApplicationContext<Context>(), theme)

    @Test
    @Config(qualifiers = "night")
    fun aLightOnlyThemeInNightModeGivesTheWhiteLabelColor() {
        assertEquals(Color.WHITE, CYLSystemColors.primary(themed(androidx.appcompat.R.style.Theme_AppCompat_Light)))
    }

    @Test
    @Config(qualifiers = "night")
    fun aDayNightThemeInNightModeKeepsItsLightTextColor() {
        val color = CYLSystemColors.primary(themed(androidx.appcompat.R.style.Theme_AppCompat_DayNight))
        assertTrue("the night text color of a DayNight theme is light: ${Integer.toHexString(color)}", Color.red(color) > 127)
    }

    @Test
    fun aLightThemeInDayModeKeepsItsDarkTextColor() {
        val color = CYLSystemColors.primary(themed(androidx.appcompat.R.style.Theme_AppCompat_Light))
        assertTrue("the day text color of a light theme is dark: ${Integer.toHexString(color)}", Color.red(color) < 128)
    }

    @Test
    fun aDarkOnlyThemeInDayModeGivesTheBlackLabelColor() {
        assertEquals(Color.BLACK, CYLSystemColors.primary(themed(androidx.appcompat.R.style.Theme_AppCompat)))
    }
}
