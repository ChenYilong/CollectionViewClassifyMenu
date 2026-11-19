package com.cyl.classifymenu

import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.view.View
import android.widget.FrameLayout
import androidx.test.platform.app.InstrumentationRegistry
import org.junit.Assert.assertTrue
import org.junit.Test

/**
 * On a device: a renamable tag's two editing icons (CYLTabBarController's `CYLAnimatedItemStackView` in a row, tinted
 * with `iconColor`) really draw: ink in each icon slot, in the indicator color.
 */
class CYLTagEditingIconsDeviceTest {

    @Test
    fun theEditIconAndTheCrossDraw() {
        val instrumentation = InstrumentationRegistry.getInstrumentation()
        var message = ""
        var ok = false
        instrumentation.runOnMainSync {
            val context = instrumentation.targetContext
            val style = CYLMenuStyle().apply { deleteIndicatorColor = Color.RED }
            val button = CYLTagButton(context)
            button.style = style
            button.title = "Family"
            button.showsDeleteIndicator = true
            button.showsRenameIndicator = true
            val density = context.resources.displayMetrics.density
            val width = Math.ceil((CYLTagButton.widthForTitle("Family", CYLSize.ZERO, true, true, style) * density).toDouble()).toInt()
            val height = Math.round(36 * density)
            FrameLayout(context).addView(button, FrameLayout.LayoutParams(width, height))
            button.measure(View.MeasureSpec.makeMeasureSpec(width, View.MeasureSpec.EXACTLY), View.MeasureSpec.makeMeasureSpec(height, View.MeasureSpec.EXACTLY))
            button.layout(0, 0, width, height)
            val icons = button.editingIndicatorsView.itemViews
            val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
            button.draw(Canvas(bitmap))
            fun redInk(view: View): Int {
                val origin = IntArray(2)
                var x0 = 0
                var y0 = 0
                var v: View? = view
                while (v != null && v !== button) { x0 += v.left; y0 += v.top; v = v.parent as? View }
                var count = 0
                for (x in x0 until x0 + view.width) for (y in y0 until y0 + view.height) {
                    val c = bitmap.getPixel(x.coerceIn(0, width - 1), y.coerceIn(0, height - 1))
                    if (Color.alpha(c) > 64 && Color.red(c) > 150 && Color.green(c) < 100) count++
                }
                origin[0] = x0
                return count
            }
            val edit = redInk(icons[0])
            val cross = redInk(icons[1])
            ok = edit > 0 && cross > 0
            message = "red pixels: edit icon $edit, cross $cross"
        }
        assertTrue(message, ok)
    }
}
