package com.cyl.classifymenu

import android.view.View
import android.widget.FrameLayout
import androidx.test.platform.app.InstrumentationRegistry
import org.junit.Assert.assertEquals
import org.junit.Test

/**
 * On a device: a tag sized by `widthForTitle` shows its whole title (no "…"). "Book Club" and "Recruiters" were cut
 * short on API 37 at 420 dpi (CYLSearchViewController's contact tags); Robolectric's fonts did not show it.
 */
class CYLTagTitleFitDeviceTest {

    private fun probe(title: String, deletable: Boolean, renamable: Boolean, inset: Float): String? {
        var result: String? = null
        val instrumentation = InstrumentationRegistry.getInstrumentation()
        instrumentation.runOnMainSync {
            val context = instrumentation.targetContext
            val style = CYLMenuStyle().apply {
                for (state in listOf(CYLControlState.NORMAL, CYLControlState.SELECTED)) {
                    val appearance = appearanceForState(state)
                    appearance.font = CYLFont.systemFont(16f)
                    appearance.contentInsets = CYLEdgeInsets(0f, inset, 0f, inset)
                }
                itemHeight = 36f
            }
            val button = CYLTagButton(context)
            button.style = style
            button.title = title
            button.showsDeleteIndicator = deletable
            button.showsRenameIndicator = renamable
            val density = context.resources.displayMetrics.density
            // The list rounds a cell's edges to pixels: a 262.5 px tag can get 262 px.
            val width = Math.floor((CYLTagButton.widthForTitle(title, CYLSize.ZERO, deletable, renamable, style) * density).toDouble()).toInt()
            val height = Math.round(36 * density)
            FrameLayout(context).addView(button, FrameLayout.LayoutParams(width, height))
            button.measure(View.MeasureSpec.makeMeasureSpec(width, View.MeasureSpec.EXACTLY), View.MeasureSpec.makeMeasureSpec(height, View.MeasureSpec.EXACTLY))
            button.layout(0, 0, width, height)
            val label = button.titleLabel
            val layout = label.layout
            val desired = android.text.Layout.getDesiredWidth(title, label.paint)
            val measured = CYLTagButton.textWidth(title, style.titleFontForState(CYLControlState.NORMAL)) * density
            if (layout == null || layout.getEllipsisCount(0) != 0) {
                result = "$title${if (renamable) " (editing)" else ""} inset $inset: label ${label.width}px, desired $desired, measureText $measured, " +
                    "padding ${label.totalPaddingLeft}+${label.totalPaddingRight}, letterSpacing ${label.letterSpacing}"
            }
        }
        return result
    }

    @Test
    fun titlesFitTheirMeasuredWidth() {
        val titles = listOf("Book Club", "Recruiters", "College Classmates", "Family", "Friends", "Coworkers", "Clients",
            "Gym Buddies", "Neighbors", "Volunteers", "Investors", "Mentors", "Alumni", "Wedding Guests", "Tennis")
        val cut = ArrayList<String>()
        for (inset in listOf(14f, 13.5f, 12.3f, 15.1f, 9.7f)) for (title in titles) {
            probe(title, false, false, inset)?.let { cut.add(it) }
            probe(title, true, true, inset)?.let { cut.add(it) }
        }
        assertEquals("cut short with an ellipsis", emptyList<String>(), cut)
    }
}
