package com.cyl.classifymenu

import android.graphics.Bitmap
import android.graphics.Color
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
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
 * Under Liquid Glass an UNSET tag background is ignored (docs/tag-liquid-glass.md): the tag hands the glass only an explicit
 * color, so the glass's frosted default shows the backdrop. Flat tags and glass where none is drawn are unchanged.
 */
@RunWith(RobolectricTestRunner::class)
class CYLTagGlassBackgroundTest {

    private val context = ApplicationProvider.getApplicationContext<android.content.Context>()

    @After
    fun resetGlassGate() {
        CYLAnimatedItemView.liquidGlassActiveOverride = null
    }

    private fun icon(): Drawable = BitmapDrawable(context.resources, Bitmap.createBitmap(28, 28, Bitmap.Config.ARGB_8888))

    private fun glassStyle(): CYLMenuStyle = CYLMenuStyle().also { it.backgroundStyle = CYLTagBackgroundStyle.CYLTagBackgroundStyleLiquidGlass }

    private fun tag(style: CYLMenuStyle, selected: Boolean = false): CYLTagButton {
        val button = CYLTagButton(context, "Tag", icon())
        button.layout(0, 0, 300, 100)
        button.style = style
        if (selected) button.isSelected = true
        return button
    }

    @Test
    fun appearanceKnowsWhetherABackgroundWasSet() {
        val appearance = CYLTagAppearance()
        assertNull(appearance.explicitBackgroundColor)
        assertEquals("the built-in default is still white", Color.WHITE, appearance.backgroundColor)
        appearance.backgroundColor = Color.RED
        assertEquals(Color.RED, appearance.explicitBackgroundColor)
        assertEquals(Color.RED, appearance.clone().explicitBackgroundColor)
        appearance.resetBackgroundColor()
        assertNull(appearance.explicitBackgroundColor)
        appearance.backgroundColor = Color.GREEN
        appearance.reset()
        assertNull(appearance.explicitBackgroundColor)
    }

    @Test
    fun glassWithAnUnsetNormalBackgroundHandsNoColor() {
        CYLAnimatedItemView.liquidGlassActiveOverride = true
        assertNull(tag(glassStyle()).itemBackgroundColor)
    }

    @Test
    fun glassWithAnUnsetDisabledBackgroundHandsNoColor() {
        CYLAnimatedItemView.liquidGlassActiveOverride = true
        val button = CYLTagButton(context, "Tag", icon())
        button.layout(0, 0, 300, 100)
        button.style = glassStyle()
        button.isEnabled = false
        assertNull(button.itemBackgroundColor)
    }

    @Test
    @Config(qualifiers = "night")
    fun glassWithAnUnsetNormalBackgroundHandsNoColorInDarkModeToo() {
        CYLAnimatedItemView.liquidGlassActiveOverride = true
        assertNull(tag(glassStyle()).itemBackgroundColor)
    }

    @Test
    fun glassWithAnExplicitColorHandsItUnchanged() {
        CYLAnimatedItemView.liquidGlassActiveOverride = true
        val style = glassStyle().also { it.normalAppearance.backgroundColor = 0x80FF0000.toInt() }
        // The alpha x 0.75 rule belongs to the glass view; the tag hands the color as the app set it.
        assertEquals(0x80FF0000.toInt(), tag(style).itemBackgroundColor)
    }

    @Test
    fun glassWithAnExplicitWhiteIsStillExplicit() {
        CYLAnimatedItemView.liquidGlassActiveOverride = true
        val style = glassStyle().also { it.normalAppearance.backgroundColor = Color.WHITE }
        assertEquals(Color.WHITE, tag(style).itemBackgroundColor)
    }

    @Test
    fun theSelectedTintIsExplicitAndKeepsAlphaOne() {
        CYLAnimatedItemView.liquidGlassActiveOverride = true
        val style = glassStyle()
        val button = tag(style, selected = true)
        assertEquals(style.selectedAppearance.explicitBackgroundColor, button.itemBackgroundColor)
        assertEquals(CYLAppTintColor, button.itemBackgroundColor)
        assertEquals(1f, button.itemGlassTintAlpha)
    }

    @Test
    fun flatIsUnchanged() {
        CYLAnimatedItemView.liquidGlassActiveOverride = true
        val flat = CYLMenuStyle()
        assertEquals(Color.WHITE, tag(flat).itemBackgroundColor)
        flat.normalAppearance.backgroundColor = Color.RED
        assertEquals(Color.RED, tag(flat).itemBackgroundColor)
    }

    @Test
    @Config(qualifiers = "night")
    fun flatKeepsTheDarkDefaultInDarkMode() {
        assertEquals(CYLSystemColors.SECONDARY_BACKGROUND_DARK, tag(CYLMenuStyle()).itemBackgroundColor)
    }

    @Test
    fun glassWhereTheDeviceDrawsNoneIsFlatAndUnchanged() {
        CYLAnimatedItemView.liquidGlassActiveOverride = false
        assertEquals(Color.WHITE, tag(glassStyle()).itemBackgroundColor)
        val style = glassStyle().also { it.normalAppearance.backgroundColor = Color.RED }
        assertEquals(Color.RED, tag(style).itemBackgroundColor)
    }

    @Test
    fun theConfigurationNeverWritesTheDefaultAsAnExplicitColor() {
        val appearance = CYLTagAppearance()
        appearance.applyConfiguration(mapOf("textColor" to "#112233", "cornerRadius" to 4))
        assertNull(appearance.explicitBackgroundColor)
        val style = CYLMenuStyle.styleWithConfiguration(mapOf("backgroundStyle" to "liquidGlass"))
        for (state in listOf(CYLControlState.NORMAL, CYLControlState.DISABLED)) assertNull(style.appearanceForState(state).explicitBackgroundColor)
        appearance.applyConfiguration(mapOf("backgroundColor" to "#FF0000"))
        assertEquals(Color.RED, appearance.explicitBackgroundColor)
    }

    @Test
    fun theFoldControlAndTheOutlinedCellDoNotTurnTheDefaultIntoAnExplicitColor() {
        val outlined = CYLTagCreateCell.styleWithStyle(CYLMenuStyle())
        assertNull(outlined.normalAppearance.explicitBackgroundColor)
        val listColor = CYLMenuStyle().also { it.backgroundColor = Color.TRANSPARENT }
        assertEquals(Color.TRANSPARENT, CYLTagCreateCell.styleWithStyle(listColor).normalAppearance.explicitBackgroundColor)
    }
}
