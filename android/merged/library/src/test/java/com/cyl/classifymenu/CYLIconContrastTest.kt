package com.cyl.classifymenu

import android.graphics.Bitmap
import android.graphics.Color
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import androidx.test.core.app.ApplicationProvider
import com.cyl.animateditem.CYLAnimatedItemView
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config

/**
 * CYLIconContrast: an explicit icon color too dark for dark Liquid Glass is lifted to 3:1 (hue and saturation kept); everything
 * else is unchanged (docs/tag-liquid-glass.md "Dark glass icon lift"). Mirrors iOS `CYLIconContrastTests`; Android colors are
 * static, so the iOS dynamic-color cases do not exist here.
 */
@RunWith(RobolectricTestRunner::class)
class CYLIconContrastTest {

    private val context = ApplicationProvider.getApplicationContext<android.content.Context>()

    @After
    fun resetGlassGate() {
        CYLAnimatedItemView.liquidGlassActiveOverride = null
    }

    private fun luminance(color: Int): Double =
        CYLMenuRelativeLuminance(Color.red(color) / CHANNEL_MAX, Color.green(color) / CHANNEL_MAX, Color.blue(color) / CHANNEL_MAX)

    private fun contrast(color: Int, glassTint: Int? = null, tintAlpha: Float? = null): Double =
        CYLIconContrast.contrastRatio(luminance(color), CYLIconContrast.glassReferenceLuminance(glassTint, tintAlpha))

    private fun hue(color: Int): Float =
        CYLIconContrast.hslFromRGB(Color.red(color) / CHANNEL_MAX.toFloat(), Color.green(color) / CHANNEL_MAX.toFloat(), Color.blue(color) / CHANNEL_MAX.toFloat())[0]

    private fun lightness(color: Int): Float =
        CYLIconContrast.hslFromRGB(Color.red(color) / CHANNEL_MAX.toFloat(), Color.green(color) / CHANNEL_MAX.toFloat(), Color.blue(color) / CHANNEL_MAX.toFloat())[2]

    @Test
    fun theConstants() {
        assertEquals(3f, CYLIconContrast.minimumContrastRatio, 0f)
        assertEquals(0.14f, CYLIconContrast.frostedGlassWhiteAlpha, 0f)
        assertEquals(0.75f, CYLIconContrast.defaultGlassTintShare, 0f)
        assertEquals(0.005f, CYLIconContrast.lightnessStep, 0f)
        // White at 0.14 over black is about #242424.
        val reference = CYLIconContrast.glassReferenceLuminance(null, null)
        assertEquals(CYLMenuRelativeLuminance(GREY_36, GREY_36, GREY_36), reference, 0.002)
        assertEquals("alpha 0 is the frosted default", reference, CYLIconContrast.glassReferenceLuminance(Color.TRANSPARENT, null), 0.0)
    }

    @Test
    fun staticTealRedAndBlueReach3To1OnTheFrostedReferenceWithTheirHue() {
        for (icon in listOf(Color.rgb(48, 176, 199), Color.rgb(255, 59, 48), Color.rgb(0, 122, 255))) {
            val lifted = CYLIconContrast.liftedIconColor(icon, null, null)
            assertTrue("contrast of $icon", contrast(lifted) >= CYLIconContrast.minimumContrastRatio - 0.01)
            assertEquals("hue kept: $icon", hue(icon), hue(lifted), 0.01f)
            assertTrue(lightness(lifted) <= 1f)
        }
    }

    @Test
    fun aDarkStaticColorIsLiftedAndNeverAboveWhite() {
        val darkTeal = Color.rgb(0, 64, 64)
        val lifted = CYLIconContrast.liftedIconColor(darkTeal, null, null)
        assertTrue(contrast(darkTeal) < 3)
        assertTrue(contrast(lifted) >= 2.99)
        assertEquals(hue(darkTeal), hue(lifted), 0.01f)
        // Black cannot keep a hue: it is lifted to a gray, capped at white.
        val black = CYLIconContrast.liftedIconColor(Color.BLACK, null, null)
        assertTrue(contrast(black) >= 2.99)
        assertTrue(Color.red(black) <= 255)
    }

    @Test
    fun anExplicitGlassTintIsTheReferenceTimesTheAlphaRule() {
        val tint = Color.argb(204, 51, 153, 255)
        val blue = Color.rgb(0, 122, 255)
        val lifted = CYLIconContrast.liftedIconColor(blue, tint, null)
        assertTrue(contrast(lifted, tint) >= 2.99)
        // The selected tag tints at alpha 1: a brighter reference, so the lift is at least as strong.
        val selected = CYLIconContrast.liftedIconColor(blue, tint, 1f)
        assertTrue(contrast(selected, tint, 1f) >= 2.99)
        val share = 0.8 * 0.75
        val expected = CYLMenuRelativeLuminance(0.2 * share, 0.6 * share, 1.0 * share)
        assertEquals(expected, CYLIconContrast.glassReferenceLuminance(tint, null), 0.001)
    }

    @Test
    fun unchangedCases() {
        // Already passing: returned as the same color.
        assertEquals(Color.WHITE, CYLIconContrast.liftedIconColor(Color.WHITE, null, null))
        val bright = Color.rgb(153, 230, 255)
        assertTrue(contrast(bright) >= 3)
        assertEquals(bright, CYLIconContrast.liftedIconColor(bright, null, null))
    }

    @Test
    fun theLiftKeepsTheAlpha() {
        val translucent = Color.argb(128, 0, 64, 64)
        assertEquals(128, Color.alpha(CYLIconContrast.liftedIconColor(translucent, null, null)))
    }

    @Test
    fun thePureFunctionGivesTheSameOutputForTheSameInput() {
        val icon = Color.rgb(48, 176, 199)
        assertEquals(CYLIconContrast.liftedIconColor(icon, null, null), CYLIconContrast.liftedIconColor(icon, null, null))
    }

    // CYLTagButton

    private fun image(): Drawable = BitmapDrawable(context.resources, Bitmap.createBitmap(28, 28, Bitmap.Config.ARGB_8888))

    private fun tag(glass: Boolean, icon: Int?): CYLTagButton {
        CYLAnimatedItemView.liquidGlassActiveOverride = true
        val style = CYLMenuStyle()
        style.backgroundStyle = if (glass) CYLTagBackgroundStyle.CYLTagBackgroundStyleLiquidGlass else CYLTagBackgroundStyle.CYLTagBackgroundStyleFlat
        if (icon != null) style.setIconColor(icon, CYLControlState.NORMAL)
        val button = CYLTagButton(context, "Tag", image())
        button.layout(0, 0, 300, 100)
        button.style = style
        return button
    }

    /** The color of the icon's PorterDuff filter (the tag tints with `setColorFilter(int)`). */
    private fun tint(button: CYLTagButton): Int {
        val filter = button.imageView.colorFilter!!
        return filter.javaClass.getMethod("getColor").invoke(filter) as Int
    }

    @Test
    @Config(qualifiers = "night")
    fun aDarkGlassTagLiftsAnExplicitDarkTealIcon() {
        val darkTeal = Color.rgb(0, 77, 77)
        val lifted = tint(tag(glass = true, icon = darkTeal))
        assertTrue("lifted", Color.green(lifted) > Color.green(darkTeal) + LIFT_MARGIN)
        assertEquals(hue(darkTeal), hue(lifted), 0.01f)
    }

    @Test
    @Config(qualifiers = "night")
    fun aFlatTagDoesNotLiftInDarkMode() {
        val darkTeal = Color.rgb(0, 77, 77)
        assertEquals(darkTeal, tint(tag(glass = false, icon = darkTeal)))
    }

    @Test
    @Config(qualifiers = "notnight")
    fun aGlassTagDoesNotLiftInLightMode() {
        val darkTeal = Color.rgb(0, 77, 77)
        assertEquals(darkTeal, tint(tag(glass = true, icon = darkTeal)))
    }

    @Test
    @Config(qualifiers = "night")
    fun anUnsetIconColorIsNotLifted() {
        val button = tag(glass = true, icon = null)
        val style = button.style!!
        assertEquals(null, style.explicitIconColorForState(CYLControlState.NORMAL))
        assertEquals(style.iconColorForState(CYLControlState.NORMAL), tint(button))
    }

    private companion object {
        const val CHANNEL_MAX = 255.0
        const val GREY_36 = 36 / CHANNEL_MAX
        const val LIFT_MARGIN = 13
    }
}
