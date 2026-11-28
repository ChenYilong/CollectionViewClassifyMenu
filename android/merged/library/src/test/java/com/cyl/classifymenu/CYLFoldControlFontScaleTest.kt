package com.cyl.classifymenu

import android.content.Context
import android.content.res.Resources
import androidx.test.core.app.ApplicationProvider
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.GraphicsMode

/**
 * `CYL_FOLD_CONTROL_MAX_FONT_SCALE`: the More / fold control stops growing with the system font size at that factor, while tags
 * and titles keep scaling up to `CYLMaximumFontScale`.
 */
@RunWith(RobolectricTestRunner::class)
@GraphicsMode(GraphicsMode.Mode.NATIVE)
class CYLFoldControlFontScaleTest {

    private var savedFontScale = 1f

    @Before
    fun rememberTheFontScale() {
        savedFontScale = Resources.getSystem().configuration.fontScale
    }

    @After
    fun restoreTheFontScale() {
        setFontScale(savedFontScale)
    }

    /** The views read the system resources' font scale (`CYLMenuStyle` does when no scale is passed). */
    private fun setFontScale(scale: Float) {
        Resources.getSystem().configuration.fontScale = scale
    }

    private fun control() = CYLMenuFoldControl.foldControlWithPosition(CYLMenuFoldControlPosition.HEADER_TRAILING, CYLMenuFoldControlContent.CYLMenuFoldControlContentIconAndTitle)

    private fun foldButton(inline: Boolean): CYLTagFoldButton {
        val button = CYLTagFoldButton(ApplicationProvider.getApplicationContext<Context>())
        if (inline) button.applyInlineFoldControl(control(), CYLMenuStyle(), false, false) else button.applyFoldControl(control(), null, false, false)
        return button
    }

    @Test
    fun theCapIsBelowTheScaleOfTagsAndTitles() {
        assertEquals(1.3f, CYL_FOLD_CONTROL_MAX_FONT_SCALE, 0.0001f)
        assertTrue(CYL_FOLD_CONTROL_MAX_FONT_SCALE < CYLMaximumFontScale)
    }

    @Test
    fun theFoldControlSizeAtFontScaleTwoEqualsTheSizeAtTheCap() {
        setFontScale(CYL_FOLD_CONTROL_MAX_FONT_SCALE)
        val atCap = CYLTagFoldButton.sizeForFoldControl(control(), false)
        val inlineAtCap = CYLTagFoldButton.inlineSizeForFoldControl(control(), CYLMenuStyle(), false)
        setFontScale(CYLMaximumFontScale)
        val scaled = CYLTagFoldButton.sizeForFoldControl(control(), false)
        val inline = CYLTagFoldButton.inlineSizeForFoldControl(control(), CYLMenuStyle(), false)
        assertEquals(atCap.width, scaled.width, 0.001f)
        assertEquals(atCap.height, scaled.height, 0.001f)
        assertEquals(inlineAtCap.width, inline.width, 0.001f)
        assertEquals(inlineAtCap.height, inline.height, 0.001f)
    }

    @Test
    fun theFoldControlFontStopsAtTheCapWhileTagsAndTitlesKeepScaling() {
        setFontScale(CYLMaximumFontScale)
        val standalone = foldButton(inline = false).style!!.titleFontForState(CYLControlState.NORMAL)
        assertEquals(FOLD_FONT_SIZE * CYL_FOLD_CONTROL_MAX_FONT_SCALE, standalone.size, 0.001f)
        val tag = CYLMenuStyle()
        val tagSize = tag.normalAppearance.font.size
        assertEquals("the inline fold control is capped too", tagSize * CYL_FOLD_CONTROL_MAX_FONT_SCALE,
            foldButton(inline = true).style!!.titleFontForState(CYLControlState.NORMAL).size, 0.001f)
        assertEquals("a tag scales normally", tagSize * CYLMaximumFontScale, tag.titleFontForState(CYLControlState.NORMAL).size, 0.001f)
        assertEquals("the header title scales normally", tag.headerFont.size * CYLMaximumFontScale, tag.headerFontForTraitCollection().size, 0.001f)
    }

    @Test
    fun belowTheCapTheFoldControlScalesNormally() {
        setFontScale(1.15f)
        assertEquals(FOLD_FONT_SIZE * 1.15f, foldButton(inline = false).style!!.titleFontForState(CYLControlState.NORMAL).size, 0.001f)
    }

    @Test
    fun theMaximumScaleIsKeptByCopy() {
        val style = CYLMenuStyle()
        style.maximumFontScale = CYL_FOLD_CONTROL_MAX_FONT_SCALE
        assertEquals(CYL_FOLD_CONTROL_MAX_FONT_SCALE, style.copy().maximumFontScale, 0.0001f)
        assertEquals(CYLMaximumFontScale, CYLMenuStyle().maximumFontScale, 0.0001f)
    }

    private companion object {
        const val FOLD_FONT_SIZE = 13f
    }
}
