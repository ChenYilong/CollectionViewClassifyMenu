package com.cyl.classifymenu

import android.graphics.Color
import androidx.test.core.app.ApplicationProvider
import com.cyl.animateditem.CYLAnimatedItemView
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config
import kotlin.math.pow

/**
 * The delete cross, the delete label and the rename / delete editing icons are drawn on the tag's glass, so the tag lifts their colour
 * through the item's own adaptation (adaptedOnGlass: dark drawn glass only, never disabled): icons 3:1, the text label 4.5:1.
 */
@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34])
class CYLTagDeleteIndicatorColorTest {

    private val context = ApplicationProvider.getApplicationContext<android.content.Context>()

    @After
    fun resetGlassGate() {
        CYLAnimatedItemView.liquidGlassActiveOverride = null
    }

    private fun tag(glass: Boolean, cross: Boolean, rename: Boolean, enabled: Boolean = true): CYLTagButton {
        CYLAnimatedItemView.liquidGlassActiveOverride = glass
        val style = CYLMenuStyle()
        style.backgroundStyle = if (glass) CYLTagBackgroundStyle.CYLTagBackgroundStyleLiquidGlass else CYLTagBackgroundStyle.CYLTagBackgroundStyleFlat
        style.deleteIndicatorColor = DARK_DELETE
        if (cross) style.deleteIndicatorLineWidth = CROSS_LINE_WIDTH
        val button = CYLTagButton(context, "Tag", null)
        button.layout(0, 0, 300, 100)
        button.style = style
        button.isEnabled = enabled
        button.showsDeleteIndicator = true
        button.showsRenameIndicator = rename
        return button
    }

    @Test
    @Config(qualifiers = "night")
    fun aDarkDeleteCrossIsLiftedOnDarkGlass() {
        val drawn = tag(glass = true, cross = true, rename = false).drawnCrossColor
        assertTrue(Color.luminance(drawn) > Color.luminance(DARK_DELETE))
        assertTrue(contrast(drawn, DARK_GLASS_BACKDROP) >= 3.0)
    }

    @Test
    @Config(qualifiers = "night")
    fun aDarkDeleteLabelIsLiftedToTheTextContrastOnDarkGlass() {
        val drawn = tag(glass = true, cross = false, rename = false).deleteIndicatorLabel.currentTextColor
        assertTrue(Color.luminance(drawn) > Color.luminance(DARK_DELETE))
        assertTrue(contrast(drawn, DARK_GLASS_BACKDROP) >= 4.5)
    }

    @Test
    @Config(qualifiers = "night")
    fun theEditingIconsAreLiftedOnDarkGlass() {
        val drawn = tag(glass = true, cross = false, rename = true).editingIndicatorsView.iconColor
        assertNotNull(drawn)
        assertTrue(Color.luminance(drawn!!) > Color.luminance(DARK_DELETE))
        assertTrue(contrast(drawn, DARK_GLASS_BACKDROP) >= 3.0)
    }

    @Test
    @Config(qualifiers = "night")
    fun aFlatTagKeepsTheExplicitDeleteColor() {
        assertEquals(DARK_DELETE, tag(glass = false, cross = true, rename = false).drawnCrossColor)
        assertEquals(DARK_DELETE, tag(glass = false, cross = false, rename = false).deleteIndicatorLabel.currentTextColor)
        assertEquals(DARK_DELETE, tag(glass = false, cross = false, rename = true).editingIndicatorsView.iconColor)
    }

    @Test
    @Config(qualifiers = "notnight")
    fun aLightGlassTagKeepsTheExplicitDeleteColor() {
        assertEquals(DARK_DELETE, tag(glass = true, cross = true, rename = false).drawnCrossColor)
        assertEquals(DARK_DELETE, tag(glass = true, cross = false, rename = false).deleteIndicatorLabel.currentTextColor)
        assertEquals(DARK_DELETE, tag(glass = true, cross = false, rename = true).editingIndicatorsView.iconColor)
    }

    @Test
    @Config(qualifiers = "night")
    fun aDisabledTagKeepsTheExplicitDeleteColor() {
        assertEquals(DARK_DELETE, tag(glass = true, cross = true, rename = false, enabled = false).drawnCrossColor)
    }

    /** WCAG contrast ratio of two opaque colors. */
    private fun contrast(foreground: Int, background: Int): Double {
        val a = relativeLuminance(foreground)
        val b = relativeLuminance(background)
        return (maxOf(a, b) + 0.05) / (minOf(a, b) + 0.05)
    }

    private fun relativeLuminance(color: Int): Double {
        fun channel(value: Int): Double {
            val v = value / 255.0
            return if (v <= 0.03928) v / 12.92 else ((v + 0.055) / 1.055).pow(2.4)
        }
        return 0.2126 * channel(Color.red(color)) + 0.7152 * channel(Color.green(color)) + 0.0722 * channel(Color.blue(color))
    }

    private companion object {
        /** An explicit dark delete colour that is unreadable on dark glass. */
        val DARK_DELETE: Int = Color.parseColor("#3C3C43")

        /** Stroke width (dp) that makes the delete indicator a drawn cross. */
        const val CROSS_LINE_WIDTH = 1.5f

        /** An approximation of the dark backdrop the glass renders over in night mode. */
        val DARK_GLASS_BACKDROP: Int = Color.parseColor("#1C1C1E")
    }
}
