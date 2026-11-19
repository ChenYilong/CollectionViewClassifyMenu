package com.cyl.classifymenu

import android.app.Activity
import android.view.View
import android.widget.FrameLayout
import org.junit.Assert.assertEquals
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.Robolectric
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config
import org.robolectric.annotation.GraphicsMode

/**
 * A tag sized by `widthForTitle` shows its whole title (no "…"), at the density of a 1080 px wide phone (420 dpi):
 * "Book Club" and "Recruiters" were cut short on API 37 (CYLSearchViewController's contact tags).
 */
@RunWith(RobolectricTestRunner::class)
@GraphicsMode(GraphicsMode.Mode.NATIVE)
@Config(qualifiers = "w411dp-h914dp-420dpi")
class CYLTagTitleFitTest {

    private fun ellipsisCount(title: String, deletable: Boolean, renamable: Boolean): Int {
        val activity = Robolectric.buildActivity(Activity::class.java).setup().get()
        val style = CYLMenuStyle().apply {
            for (state in listOf(CYLControlState.NORMAL, CYLControlState.SELECTED)) appearanceForState(state).font = CYLFont.systemFont(16f)
            itemHeight = 36f
            appearanceForState(CYLControlState.NORMAL).cornerRadius = 6f
        }
        val button = CYLTagButton(activity)
        button.style = style
        button.title = title
        button.showsDeleteIndicator = deletable
        button.showsRenameIndicator = renamable
        val density = activity.resources.displayMetrics.density
        // The list rounds a cell's edges to pixels: a 262.5 px tag can get 262 px.
        val width = kotlin.math.floor(CYLTagButton.widthForTitle(title, CYLSize.ZERO, deletable, renamable, style) * density).toInt()
        val height = (36 * density).toInt()
        activity.setContentView(FrameLayout(activity).apply { addView(button, FrameLayout.LayoutParams(width, height)) })
        button.measure(View.MeasureSpec.makeMeasureSpec(width, View.MeasureSpec.EXACTLY), View.MeasureSpec.makeMeasureSpec(height, View.MeasureSpec.EXACTLY))
        button.layout(0, 0, width, height)
        val layout = button.titleLabel.layout ?: return -1
        return layout.getEllipsisCount(0)
    }

    @Test
    fun titlesFitTheirMeasuredWidth() {
        val titles = listOf("Book Club", "Recruiters", "College Classmates", "Family", "Friends", "Coworkers", "Clients",
            "Gym Buddies", "Neighbors", "Volunteers", "Investors", "Mentors", "Alumni", "Wedding Guests", "Tennis")
        val cut = ArrayList<String>()
        for (title in titles) {
            if (ellipsisCount(title, false, false) != 0) cut.add(title)
            if (ellipsisCount(title, true, true) != 0) cut.add("$title (editing)")
        }
        assertEquals("cut short with an ellipsis", emptyList<String>(), cut)
    }
}
