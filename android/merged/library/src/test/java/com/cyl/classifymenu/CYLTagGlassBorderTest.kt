package com.cyl.classifymenu

import android.graphics.Color
import androidx.test.core.app.ApplicationProvider
import com.cyl.animateditem.CYLAnimatedItemView
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config

/**
 * Under DRAWN Liquid Glass a tag does not carry the core's built-in default border (normal, selected, disabled): it is handed
 * as no border (width 0) so the shared glass rim shows. An EXPLICIT border (setter, configuration key, preset) is kept as
 * before. Flat tags, and glass where none is drawn, keep the default border. The tail fold cell equals a plain tag.
 */
@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34])
class CYLTagGlassBorderTest {

    private val context = ApplicationProvider.getApplicationContext<android.content.Context>()

    @After
    fun resetGlassGate() {
        CYLAnimatedItemView.liquidGlassActiveOverride = null
    }

    private fun glassStyle(): CYLMenuStyle = CYLMenuStyle().also { it.backgroundStyle = CYLTagBackgroundStyle.CYLTagBackgroundStyleLiquidGlass }

    private fun tag(style: CYLMenuStyle, selected: Boolean = false, enabled: Boolean = true): CYLTagButton {
        val button = CYLTagButton(context, "Tag", null)
        button.layout(0, 0, 300, 100)
        button.style = style
        if (selected) button.isSelected = true
        if (!enabled) button.isEnabled = false
        return button
    }

    private fun tail(style: CYLMenuStyle): CYLTagFoldButton {
        val button = CYLTagFoldButton(context)
        button.layout(0, 0, 300, 100)
        val control = CYLMenuFoldControl.foldControlWithPosition(CYLMenuFoldControlPosition.TAIL, CYLMenuFoldControlContent.CYLMenuFoldControlContentIcon)
        button.applyInlineFoldControl(control, style, expanded = false, animated = false)
        return button
    }

    @Test
    fun theDefaultBorderIsReadableButNotExplicit() {
        val style = CYLMenuStyle()
        for (appearance in listOf(style.normalAppearance, style.selectedAppearance, style.disabledAppearance)) {
            assertFalse(appearance.hasExplicitBorder)
            assertNotNull("the effective default is still readable", appearance.borderColor)
            assertTrue(appearance.borderWidth > 0f)
        }
    }

    @Test
    fun settersMarkTheBorderExplicitAndCopyAndResetFollowTheBackgroundRule() {
        val appearance = CYLTagAppearance()
        assertFalse(appearance.hasExplicitBorder)
        appearance.borderColor = Color.RED
        assertTrue(appearance.hasExplicitBorder)
        assertTrue("clone keeps the flag", appearance.clone().hasExplicitBorder)
        assertEquals(Color.RED, appearance.clone().borderColor)
        val widthOnly = CYLTagAppearance().also { it.borderWidth = 2f }
        assertFalse("a width alone is not an explicit border under glass", widthOnly.hasExplicitBorder)
        assertFalse(widthOnly.clone().hasExplicitBorder)
        assertFalse("a style copy keeps the default as a default", CYLMenuStyle().copy().normalAppearance.hasExplicitBorder)
        assertTrue(glassStyle().also { it.normalAppearance.borderColor = Color.BLUE }.copy().normalAppearance.hasExplicitBorder)
        appearance.reset()
        assertFalse(appearance.hasExplicitBorder)
        assertNull(appearance.borderColor)
        assertEquals(0f, appearance.borderWidth)
    }

    @Test
    fun configurationKeysMarkTheBorderExplicit() {
        val appearance = CYLTagAppearance()
        appearance.applyConfiguration(mapOf(CYLTagAppearanceCornerRadius to 4))
        assertFalse(appearance.hasExplicitBorder)
        appearance.applyConfiguration(mapOf(CYLTagAppearanceBorderWidth to 2))
        assertTrue(appearance.hasExplicitBorder)
        val colored = CYLTagAppearance().also { it.applyConfiguration(mapOf(CYLTagAppearanceBorderColor to "#FF0000")) }
        assertTrue(colored.hasExplicitBorder)
    }

    @Test
    fun glassWithAnUnsetBorderHandsNoBorderInEveryState() {
        CYLAnimatedItemView.liquidGlassActiveOverride = true
        val style = glassStyle()
        for (button in listOf(tag(style), tag(style, selected = true), tag(style, enabled = false))) {
            assertEquals(0f, button.itemBorderWidth)
            assertNull(button.itemBorderColor)
        }
    }

    @Test
    fun glassWithAnExplicitBorderKeepsColorAndWidth() {
        CYLAnimatedItemView.liquidGlassActiveOverride = true
        val style = glassStyle().also {
            it.normalAppearance.borderColor = Color.BLUE
            it.normalAppearance.borderWidth = 2f
            it.selectedAppearance.borderColor = Color.GREEN
            it.selectedAppearance.borderWidth = 3f
        }
        val normal = tag(style)
        assertEquals(Color.BLUE, normal.itemBorderColor)
        assertEquals(2f, normal.itemBorderWidth)
        val selected = tag(style, selected = true)
        assertEquals(Color.GREEN, selected.itemBorderColor)
        assertEquals(3f, selected.itemBorderWidth)
        assertEquals("the disabled state was not set: no border", 0f, tag(style, enabled = false).itemBorderWidth)
    }

    @Test
    fun flatKeepsTheDefaultBorder() {
        CYLAnimatedItemView.liquidGlassActiveOverride = true
        val flat = tag(CYLMenuStyle())
        assertEquals(CYLMenuStyle().normalAppearance.borderColor, flat.itemBorderColor)
        assertTrue(flat.itemBorderWidth > 0f)
        assertEquals(CYLAppTintColor, tag(CYLMenuStyle(), selected = true).itemBorderColor)
    }

    @Test
    fun glassWhereNoneIsDrawnKeepsTheDefaultBorder() {
        CYLAnimatedItemView.liquidGlassActiveOverride = false
        val button = tag(glassStyle())
        assertEquals(CYLMenuStyle().normalAppearance.borderColor, button.itemBorderColor)
        assertTrue(button.itemBorderWidth > 0f)
    }

    @Test
    fun theTailCellEqualsAPlainTagForAnUnsetAndAnExplicitBorder() {
        CYLAnimatedItemView.liquidGlassActiveOverride = true
        val unset = glassStyle()
        assertEquals(0f, tail(unset).itemBorderWidth)
        assertEquals(tag(unset).itemBorderWidth, tail(unset).itemBorderWidth)
        assertEquals(tag(unset).itemBorderColor, tail(unset).itemBorderColor)
        val explicit = glassStyle().also {
            it.normalAppearance.borderColor = Color.BLUE
            it.normalAppearance.borderWidth = 2f
        }
        assertEquals(tag(explicit).itemBorderWidth, tail(explicit).itemBorderWidth)
        assertEquals(Color.BLUE, tail(explicit).itemBorderColor)
        CYLAnimatedItemView.liquidGlassActiveOverride = false
        val flat = CYLMenuStyle()
        assertEquals(tag(flat).itemBorderWidth, tail(flat).itemBorderWidth)
        assertEquals(tag(flat).itemBorderColor, tail(flat).itemBorderColor)
    }
}
