package com.cyl.classifymenu

import android.graphics.drawable.GradientDrawable
import android.view.View
import androidx.test.core.app.ApplicationProvider
import org.junit.Assert.assertEquals
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config

/**
 * The corner radius is a plain number of dp everywhere (owner decision 2026-11-24; ClassifyMenu PR #35; iOS
 * `CYLTagButtonTests`): limited to half the tag height, 0 is SQUARE, half the height or more (for example 1000) is a capsule.
 * There is no special value and no `CYLTagCornerRadiusSquare`.
 */
@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34])
class CYLTagCornerRadiusTest {

    private val context = ApplicationProvider.getApplicationContext<android.content.Context>()
    private val density = context.resources.displayMetrics.density

    /** The corner radius, in dp, a 36 dp high tag draws with `radius` as the radius of its appearance. */
    private fun drawnRadius(radius: Float): Float {
        val style = CYLMenuStyle.defaultStyle()
        style.normalAppearance.cornerRadius = radius
        style.selectedAppearance.cornerRadius = radius
        style.disabledAppearance.cornerRadius = radius
        val button = CYLTagButton(context, "Tag", null)
        button.style = style
        val width = (120 * density).toInt()
        val height = (36 * density).toInt()
        button.measure(View.MeasureSpec.makeMeasureSpec(width, View.MeasureSpec.EXACTLY), View.MeasureSpec.makeMeasureSpec(height, View.MeasureSpec.EXACTLY))
        button.layout(0, 0, width, height)
        val field = CYLTagButton::class.java.getDeclaredField("box").apply { isAccessible = true }
        return (field.get(button) as GradientDrawable).cornerRadius / density
    }

    @Test
    fun zeroIsSquare() {
        assertEquals(0f, drawnRadius(0f), 0.01f)
    }

    @Test
    fun aSmallNumberIsDrawnAsItIs() {
        assertEquals(8f, drawnRadius(8f), 0.01f)
    }

    @Test
    fun halfTheHeightOrMoreIsACapsule() {
        assertEquals(18f, drawnRadius(18f), 0.01f)
        assertEquals(18f, drawnRadius(1000f), 0.01f)
    }
}
