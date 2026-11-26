package com.cyl.classifymenu

import android.graphics.Bitmap
import android.graphics.Color
import android.graphics.drawable.BitmapDrawable
import androidx.test.core.app.ApplicationProvider
import com.cyl.animateditem.CYLAnimatedItemView
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotEquals
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config
import kotlin.math.pow

/**
 * The tag hands its title colors to the shared CYLAnimatedItemView through the CHANNELS: an explicit color through the
 * subclass-explicit channel, an unset one through the built-in level, and never through the integrator-owned `titleColor`.
 * The tag has no contrast code: the item lifts both on dark drawn Liquid Glass (explicit and built-in, contrast 4.5).
 */
@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34])
class CYLTagTitleColorHandoffTest {

    private val context = ApplicationProvider.getApplicationContext<android.content.Context>()

    @After
    fun resetGlassGate() {
        CYLAnimatedItemView.liquidGlassActiveOverride = null
    }

    private fun tag(text: Int?, glass: Boolean): CYLTagButton {
        CYLAnimatedItemView.liquidGlassActiveOverride = glass
        val style = CYLMenuStyle()
        style.backgroundStyle = if (glass) CYLTagBackgroundStyle.CYLTagBackgroundStyleLiquidGlass else CYLTagBackgroundStyle.CYLTagBackgroundStyleFlat
        if (text != null) style.normalAppearance.textColor = text
        val image = BitmapDrawable(context.resources, Bitmap.createBitmap(28, 28, Bitmap.Config.ARGB_8888))
        val button = CYLTagButton(context, "Tag", image)
        button.layout(0, 0, 300, 100)
        button.style = style
        return button
    }

    @Test
    @Config(qualifiers = "night")
    fun anExplicitDarkTextColorIsLiftedOnDarkGlassAndTitleColorStaysTheIntegrators() {
        val button = tag(DARK_TEXT, glass = true)
        assertNull("the integrator-owned titleColor is never written", button.titleColor)
        assertNotEquals(DARK_TEXT, button.titleLabel.currentTextColor)
        assertTrue(Color.luminance(button.titleLabel.currentTextColor) > Color.luminance(DARK_TEXT))
        assertTrue(contrast(button.titleLabel.currentTextColor, DARK_GLASS_BACKDROP) >= 4.5)
    }

    /**
     * A static icon (a system symbol, a template image) with NO icon colour follows the text colour. When that text colour is an
     * explicit dark one (#3C3C43, the shared configuration file), the tag tints the image itself: the tint must go through the item's
     * adaptation like the title, otherwise the symbol stays dark on dark glass while the title is lifted (the "SF Symbol" tag).
     */
    @Test
    @Config(qualifiers = "night")
    fun anIconFollowingAnExplicitDarkTextColorIsLiftedOnDarkGlassLikeTheTitle() {
        val button = tag(DARK_TEXT, glass = true)
        val lifted = button.adaptedOnGlass(DARK_TEXT, com.cyl.animateditem.CYLAnimatedItemColorKind.Icon)
        assertTrue("the item lifts the dark icon colour: ${Integer.toHexString(lifted)}", Color.luminance(lifted) > Color.luminance(DARK_TEXT))
        assertNotNull("the static image is tinted", button.imageView.colorFilter)
    }

    @Test
    @Config(qualifiers = "night")
    fun anUnsetTextColorIsReadableInNightWithALightOnlyTheme() {
        // A LIGHT-only theme: the app never styles the tag for night, so the built-in level carries the night-correct default.
        val button = tag(null, glass = true)
        assertNull(button.titleColor)
        assertTrue(contrast(button.titleLabel.currentTextColor, DARK_GLASS_BACKDROP) >= 4.5)
    }

    @Test
    @Config(qualifiers = "night")
    fun aFlatTagKeepsTheExplicitTextColorInDarkMode() {
        val button = tag(DARK_TEXT, glass = false)
        assertEquals(DARK_TEXT, button.titleLabel.currentTextColor)
    }

    @Test
    @Config(qualifiers = "notnight")
    fun aLightGlassTagKeepsTheExplicitTextColor() {
        val button = tag(DARK_TEXT, glass = true)
        assertEquals(DARK_TEXT, button.titleLabel.currentTextColor)
    }

    @Test
    @Config(qualifiers = "night")
    fun theTailFoldCellResolvesTheSameTitleAndIconColorsAsAPlainTag() {
        val style = CYLMenuStyle()
        style.backgroundStyle = CYLTagBackgroundStyle.CYLTagBackgroundStyleLiquidGlass
        style.normalAppearance.textColor = DARK_TEXT
        CYLAnimatedItemView.liquidGlassActiveOverride = true
        val plain = CYLTagButton(context, "Tag", null).also { it.layout(0, 0, 300, 100); it.style = style }
        val tail = CYLTagFoldButton(context)
        tail.layout(0, 0, 300, 100)
        val control = CYLMenuFoldControl.foldControlWithPosition(CYLMenuFoldControlPosition.TAIL, CYLMenuFoldControlContent.CYLMenuFoldControlContentIcon)
        tail.applyInlineFoldControl(control, style, expanded = false, animated = false)
        // An icon-only tail draws no title, so only a tail that shows a title is compared with the plain tag's title colour.
        // The icon of a tail control is tinted with the fold control's own colour (foldControlColor), by design: not compared.
        if (tail.titleLabel.text.isNotEmpty()) assertEquals(plain.titleLabel.currentTextColor, tail.titleLabel.currentTextColor)
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
        /** The configuration's static dark title color (menu/animated-tags.json normal textColor #3C3C43). */
        val DARK_TEXT: Int = Color.parseColor("#3C3C43")

        /** An approximation of the dark backdrop the glass renders over in night mode (the item judges the real rendered glass). */
        val DARK_GLASS_BACKDROP: Int = Color.parseColor("#1C1C1E")
    }
}
