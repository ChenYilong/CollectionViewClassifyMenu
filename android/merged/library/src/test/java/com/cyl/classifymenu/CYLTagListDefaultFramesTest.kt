package com.cyl.classifymenu

import android.app.Activity
import android.os.Looper
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import org.junit.Assert.assertEquals
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.Robolectric
import org.robolectric.RobolectricTestRunner
import org.robolectric.Shadows.shadowOf
import org.robolectric.annotation.GraphicsMode
import java.time.Duration

/** Three sections of mixed title lengths, so the rows wrap differently in each. */
private class CYLDefaultFramesSource : CYLMenuDataSource {
    val sections = listOf(
        listOf("Alpha", "Beta", "Gamma", "Delta", "Epsilon", "Zeta", "Eta", "Theta", "Iota", "Kappa"),
        listOf("One", "Two", "Three"),
        listOf("A longer title here", "Another long title", "Short", "Medium title", "Tiny", "Wrapping tag number six"),
    )
    override fun numberOfSectionsInMenu() = sections.size
    override fun menuNumberOfItemsInSection(section: Int) = sections[section].size
    override fun menuTitleForSection(section: Int) = "Section $section"
    override fun menuTitleForItemAtIndexPath(indexPath: CYLIndexPath) = sections[indexPath.section][indexPath.item]
}

/**
 * The default style gives the frames it gave before the section style (card, header band, header divider) existed: this
 * snapshot was taken from the code without it. A change to the default layout must be deliberate, and update it.
 */
@RunWith(RobolectricTestRunner::class)
@GraphicsMode(GraphicsMode.Mode.NATIVE)
class CYLTagListDefaultFramesTest {

    private fun descendants(view: View): List<View> =
        if (view is ViewGroup) (0 until view.childCount).flatMap { val child = view.getChildAt(it); listOf(child) + descendants(child) } else emptyList()

    private fun makeList(): CYLTagListView {
        val activity = Robolectric.buildActivity(Activity::class.java).setup().get()
        val list = CYLTagListView(activity)
        list.menuDataSource = CYLDefaultFramesSource()
        activity.setContentView(FrameLayout(activity).apply { addView(list, FrameLayout.LayoutParams(WIDTH_PX, FrameLayout.LayoutParams.WRAP_CONTENT)) })
        list.reloadMenuData()
        shadowOf(Looper.getMainLooper()).idleFor(Duration.ofMillis(100))
        return list
    }

    private fun box(view: View) = "${view.left},${view.top},${view.width},${view.height}"

    /** Every tag cell (section.item: x,y,w,h), every header (x,y,w,h) and the content height. */
    private fun snapshot(list: CYLTagListView): List<String> {
        val result = ArrayList<String>()
        for (section in 0 until SECTIONS) {
            val header = descendants(list).first { it.javaClass.simpleName == "HeaderView" && headerIndex(list, it) == section }
            result.add("header $section ${box(header)}")
            var item = 0
            while (true) {
                val button = list.tagButtonAtIndexPath(CYLIndexPath(item, section)) ?: break
                result.add("tag $section.$item ${box(button.parent as View)}")
                item++
            }
        }
        result.add("contentHeight ${list.contentHeight} fits ${list.heightThatFitsWidth(WIDTH_PX.toFloat())}")
        return result
    }

    /** The headers are added in section order. */
    private fun headerIndex(list: CYLTagListView, header: View): Int =
        descendants(list).filter { it.javaClass.simpleName == "HeaderView" }.indexOf(header)

    @Test
    fun theDefaultStyleKeepsEveryFrame() {
        val lines = snapshot(makeList())
        assertEquals(EXPECTED, lines)
    }

    private companion object {
        const val WIDTH_PX = 320
        const val SECTIONS = 3
        val EXPECTED: List<String> = listOf(
            "header 0 0,0,320,36",
            "tag 0.0 16,46,25,30",
            "tag 0.1 51,46,24,30",
            "tag 0.2 85,46,25,30",
            "tag 0.3 120,46,25,30",
            "tag 0.4 155,46,27,30",
            "tag 0.5 192,46,24,30",
            "tag 0.6 226,46,23,30",
            "tag 0.7 259,46,25,30",
            "tag 0.8 16,86,24,30",
            "tag 0.9 50,86,25,30",
            "header 1 0,126,320,36",
            "tag 1.0 16,172,23,30",
            "tag 1.1 49,172,23,30",
            "tag 1.2 82,172,25,30",
            "header 2 0,212,320,36",
            "tag 2.0 16,258,39,30",
            "tag 2.1 65,258,38,30",
            "tag 2.2 113,258,25,30",
            "tag 2.3 148,258,32,30",
            "tag 2.4 190,258,24,30",
            "tag 2.5 224,258,43,30",
            "contentHeight 298.0 fits 298.0",
        )
    }
}
