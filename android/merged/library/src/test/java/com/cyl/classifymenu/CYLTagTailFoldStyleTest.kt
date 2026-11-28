package com.cyl.classifymenu

import android.graphics.Color
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
 * The inline (tail) fold cell uses the SAME style strategy as every other tag (docs/tag-section-style.md): the same shared
 * Liquid Glass or flat style from the same configuration. Only its content (icon, chevron) is the fold control's, and
 * `foldControlColor` tints the icon only.
 */
@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34])
class CYLTagTailFoldStyleTest {

    private val context = ApplicationProvider.getApplicationContext<android.content.Context>()

    @After
    fun resetGlassGate() {
        CYLAnimatedItemView.liquidGlassActiveOverride = null
    }

    private fun glassStyle(): CYLMenuStyle = CYLMenuStyle().also { it.backgroundStyle = CYLTagBackgroundStyle.CYLTagBackgroundStyleLiquidGlass }

    private fun tag(style: CYLMenuStyle): CYLTagButton {
        val button = CYLTagButton(context, "Tag", null)
        button.layout(0, 0, 300, 100)
        button.style = style
        return button
    }

    private fun tail(style: CYLMenuStyle): CYLTagFoldButton {
        val button = CYLTagFoldButton(context)
        button.layout(0, 0, 300, 100)
        val control = CYLMenuFoldControl.foldControlWithPosition(CYLMenuFoldControlPosition.TAIL, CYLMenuFoldControlContent.CYLMenuFoldControlContentIcon)
        button.applyInlineFoldControl(control, style, expanded = false, animated = false)
        return button
    }

    private fun assertSameShapeAsATag(style: CYLMenuStyle) {
        val tag = tag(style)
        val tail = tail(style)
        assertEquals(tag.itemBackgroundStyle, tail.itemBackgroundStyle)
        assertEquals(tag.itemBackgroundColor, tail.itemBackgroundColor)
        assertEquals(tag.itemGlassTintAlpha, tail.itemGlassTintAlpha)
        assertEquals(tag.itemCornerRadius, tail.itemCornerRadius)
        assertEquals(tag.itemBorderWidth, tail.itemBorderWidth)
        assertEquals(tag.itemBorderColor, tail.itemBorderColor)
    }

    @Test
    fun glassTailHasTheTagsGlassStyleAndNoTintWhileUnset() {
        CYLAnimatedItemView.liquidGlassActiveOverride = true
        val style = glassStyle()
        assertSameShapeAsATag(style)
        assertNull("an unset background stays unset: the frosted default", tail(style).itemBackgroundColor)
    }

    @Test
    fun glassTailHasTheTagsExplicitBackgroundRadiusAndBorder() {
        CYLAnimatedItemView.liquidGlassActiveOverride = true
        val style = glassStyle().also {
            it.normalAppearance.backgroundColor = 0x80FF0000.toInt()
            it.normalAppearance.cornerRadius = 6f
            it.normalAppearance.borderColor = Color.BLUE
            it.normalAppearance.borderWidth = 2f
        }
        assertSameShapeAsATag(style)
        assertEquals(0x80FF0000.toInt(), tail(style).itemBackgroundColor)
        assertEquals(6f, tail(style).itemCornerRadius)
        assertEquals(Color.BLUE, tail(style).itemBorderColor)
    }

    @Test
    fun flatTailHasTheTagsFlatStyle() {
        CYLAnimatedItemView.liquidGlassActiveOverride = true
        val style = CYLMenuStyle()
        assertSameShapeAsATag(style)
        assertEquals(Color.WHITE, tail(style).itemBackgroundColor)
    }

    @Test
    fun flatTailHasTheTagsExplicitBackgroundRadiusAndBorder() {
        val style = CYLMenuStyle().also {
            it.normalAppearance.backgroundColor = Color.RED
            it.normalAppearance.cornerRadius = 0f
            it.normalAppearance.borderColor = Color.GREEN
            it.normalAppearance.borderWidth = 1f
        }
        assertSameShapeAsATag(style)
        assertEquals(Color.RED, tail(style).itemBackgroundColor)
        assertEquals(Color.GREEN, tail(style).itemBorderColor)
    }

    @Test
    fun foldControlColorTintsOnlyTheIcon() {
        for (glass in listOf(true, false)) {
            CYLAnimatedItemView.liquidGlassActiveOverride = glass
            val plain = if (glass) glassStyle() else CYLMenuStyle()
            val tinted = (if (glass) glassStyle() else CYLMenuStyle()).also { it.foldControlColor = Color.MAGENTA }
            val before = tail(plain)
            val after = tail(tinted)
            assertEquals(Color.MAGENTA, tinted.let { after.style!!.iconColorForState(CYLControlState.NORMAL) })
            assertEquals(after.itemBackgroundStyle, before.itemBackgroundStyle)
            assertEquals(after.itemBackgroundColor, before.itemBackgroundColor)
            assertEquals(after.itemCornerRadius, before.itemCornerRadius)
            assertEquals(after.itemBorderWidth, before.itemBorderWidth)
            assertEquals(after.itemBorderColor, before.itemBorderColor)
            assertEquals(after.style!!.normalAppearance.textColor, before.style!!.normalAppearance.textColor)
        }
    }
}
