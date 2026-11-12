package com.cyl.classifymenu

import android.view.View
import androidx.test.core.app.ApplicationProvider
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner

/**
 * A tag title that does not fit its cell ends with "…" inside the cell, instead of being cut at the cell's edge
 * (docs/issue-progress.md, "Android tag titles cut at the cell edge").
 */
@RunWith(RobolectricTestRunner::class)
class CYLTagTitleEllipsisTest {

    @Test
    fun aLongTitleIsLaidOutAtTheWidthOfItsFrame() {
        val button = CYLTagButton(ApplicationProvider.getApplicationContext())
        button.style = CYLMenuStyle.gridStyleWithNumberOfItemsPerRow(2)
        button.title = "Switching your cat's food without upsetting its stomach"
        // Narrower than the title however the test environment measures text (Robolectric may count one pixel per
        // character), so the title must be shortened.
        val width = 40
        val height = 96
        button.measure(View.MeasureSpec.makeMeasureSpec(width, View.MeasureSpec.EXACTLY), View.MeasureSpec.makeMeasureSpec(height, View.MeasureSpec.EXACTLY))
        button.layout(0, 0, width, height)
        val label = button.titleLabel
        assertTrue("the title stays inside the cell: ${label.right} <= $width", label.right <= width)
        assertTrue("the title view is measured at its frame", label.measuredWidth == label.width)
        // The text layout is as wide as the frame: that is what makes maxLines = 1 + ellipsize = END end the title with
        // "…" (Robolectric's text engine does not draw the ellipsis; the emulator screenshot in docs/ shows it).
        val layout = label.layout
        assertTrue("the title is laid out", layout != null)
        assertTrue("the text layout fits the frame: ${layout!!.width} == ${label.width}", layout.width == label.width)
    }
}
