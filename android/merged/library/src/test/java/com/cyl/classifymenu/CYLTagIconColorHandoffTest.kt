package com.cyl.classifymenu

import android.graphics.Bitmap
import android.graphics.Color
import android.graphics.drawable.BitmapDrawable
import androidx.test.core.app.ApplicationProvider
import com.cyl.animateditem.CYLAnimatedItemView
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config

/**
 * The tag hands the style's explicit icon color through the item's subclass-explicit channel and an unset one through the built-in
 * level; the integrator-owned `iconColor` is never written. The dark-glass contrast adaptation is the shared
 * CYLAnimatedItemView's job (CYLAnimatedItemContrast), not the tag's.
 */
@RunWith(RobolectricTestRunner::class)
class CYLTagIconColorHandoffTest {

    private val context = ApplicationProvider.getApplicationContext<android.content.Context>()

    @After
    fun resetGlassGate() {
        CYLAnimatedItemView.liquidGlassActiveOverride = null
    }

    private fun tag(icon: Int?): CYLTagButton {
        CYLAnimatedItemView.liquidGlassActiveOverride = true
        val style = CYLMenuStyle()
        style.backgroundStyle = CYLTagBackgroundStyle.CYLTagBackgroundStyleLiquidGlass
        if (icon != null) style.setIconColor(icon, CYLControlState.NORMAL)
        val image = BitmapDrawable(context.resources, Bitmap.createBitmap(28, 28, Bitmap.Config.ARGB_8888))
        val button = CYLTagButton(context, "Tag", image)
        button.layout(0, 0, 300, 100)
        button.style = style
        return button
    }

    @Test
    @Config(qualifiers = "night")
    fun aDarkGlassTagHandsTheExplicitIconColorThroughTheChannelUnchanged() {
        val darkTeal = Color.rgb(0, 77, 77)
        val button = tag(darkTeal)
        assertNull("the integrator-owned iconColor is never written", button.iconColor)
        assertEquals(darkTeal, button.explicitIconColor)
        assertEquals(darkTeal, button.resolvedIconColor())
    }

    @Test
    @Config(qualifiers = "night")
    fun anUnsetIconColorGoesThroughTheBuiltInLevelNotTheExplicitOne() {
        val button = tag(null)
        assertNull(button.iconColor)
        assertNull("an unset color is never explicit", button.explicitIconColor)
        assertEquals(CYLTagAppearance().resolvedTextColor(context), button.resolvedIconColor())
    }
}
