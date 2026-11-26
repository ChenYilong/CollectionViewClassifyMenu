package com.cyl.classifymenu

import android.graphics.Bitmap
import android.graphics.Color
import android.graphics.drawable.BitmapDrawable
import androidx.test.core.app.ApplicationProvider
import com.cyl.animateditem.CYLAnimatedItemView
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotEquals
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config

/**
 * The tag hands the item an EXPLICIT text color as `titleColor` (null while it is the built-in default) and never sets the
 * title color on top, so the shared CYLAnimatedItemView lifts a dark explicit color on dark Liquid Glass (CYLAnimatedItemContrast).
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
    fun anExplicitDarkTextColorIsHandedToTheItemAndLiftedOnDarkGlass() {
        val button = tag(DARK_TEXT, glass = true)
        assertEquals(DARK_TEXT, button.titleColor)
        assertNotEquals(DARK_TEXT, button.titleLabel.currentTextColor)
        assertTrue(Color.luminance(button.titleLabel.currentTextColor) > Color.luminance(DARK_TEXT))
    }

    @Test
    @Config(qualifiers = "night")
    fun anUnsetTextColorIsHandedAsUnsetAndKeepsTheBuiltInColor() {
        val button = tag(null, glass = true)
        assertNull(button.titleColor)
        assertEquals(CYLTagAppearance().resolvedTextColor(context), button.titleLabel.currentTextColor)
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

    private companion object {
        /** The configuration's static dark title color (menu/animated-tags.json normal textColor #3C3C43). */
        val DARK_TEXT: Int = Color.parseColor("#3C3C43")
    }
}
