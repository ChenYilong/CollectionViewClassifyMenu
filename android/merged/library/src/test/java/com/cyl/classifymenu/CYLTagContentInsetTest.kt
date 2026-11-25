package com.cyl.classifymenu

import androidx.test.core.app.ApplicationProvider
import com.cyl.animateditem.CYLAnimatedItemLiquidGlassContentInset
import com.cyl.animateditem.CYLAnimatedItemView
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config

/**
 * The content spacing of a tag: unset `itemContentHorizontalInset` is [CYLAnimatedItemLiquidGlassContentInset] on a drawn Liquid
 * Glass tag and 0 on a flat one (cylanimateditem's rule); the tag's title never starts nearer the border than that. Checked on the
 * grid style of the Discover section (clear background, leading alignment, margin 0).
 */
@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34])
class CYLTagContentInsetTest {

    private val context = ApplicationProvider.getApplicationContext<android.content.Context>()
    private val density = context.resources.displayMetrics.density

    @After
    fun resetGlassGate() {
        CYLAnimatedItemView.liquidGlassActiveOverride = null
    }

    private fun discoverStyle(glass: Boolean): CYLMenuStyle = CYLMenuStyle.gridStyleWithNumberOfItemsPerRow(2).also {
        if (glass) it.backgroundStyle = CYLTagBackgroundStyle.CYLTagBackgroundStyleLiquidGlass
    }

    private fun tag(style: CYLMenuStyle): CYLTagButton {
        val button = CYLTagButton(context, "Spring camping gear checklist", null)
        button.style = style
        val width = (160 * density).toInt()
        val height = (36 * density).toInt()
        button.measure(android.view.View.MeasureSpec.makeMeasureSpec(width, android.view.View.MeasureSpec.EXACTLY),
            android.view.View.MeasureSpec.makeMeasureSpec(height, android.view.View.MeasureSpec.EXACTLY))
        button.layout(0, 0, width, height)
        return button
    }

    @Test
    fun aDrawnGlassTagOfTheGridStyleKeepsTheGlassInsetFromTheBorder() {
        CYLAnimatedItemView.liquidGlassActiveOverride = true
        val button = tag(discoverStyle(glass = true))
        assertEquals(CYLAnimatedItemLiquidGlassContentInset, button.resolvedItemContentHorizontalInset, 0f)
        assertTrue("the title starts at least the glass inset from the left border: ${button.titleLabel.left} px",
            button.titleLabel.left >= (CYLAnimatedItemLiquidGlassContentInset * density).toInt() - 1)
        assertTrue("and ends at least the inset from the right border",
            button.width - button.titleLabel.right >= (CYLAnimatedItemLiquidGlassContentInset * density).toInt() - 1)
    }

    @Test
    fun aFlatTagOfTheGridStyleHasNoInset() {
        val button = tag(discoverStyle(glass = false))
        assertEquals(0f, button.resolvedItemContentHorizontalInset, 0f)
    }
}
