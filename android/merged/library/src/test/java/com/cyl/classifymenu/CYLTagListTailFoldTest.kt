package com.cyl.classifymenu

import android.app.Activity
import android.os.Looper
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.Robolectric
import org.robolectric.RobolectricTestRunner
import org.robolectric.Shadows.shadowOf
import org.robolectric.annotation.GraphicsMode
import java.time.Duration

/** One section of same-length titles ("Tag 00"), so every tag has the same width and the row count follows the tag count. */
private class CYLTailFoldSource(count: Int) : CYLMenuDataSource {
    val titles = (0 until count).map { "Tag %02d".format(it) }
    override fun numberOfSectionsInMenu() = 1
    override fun menuNumberOfItemsInSection(section: Int) = titles.size
    override fun menuTitleForSection(section: Int) = "Section"
    override fun menuTitleForItemAtIndexPath(indexPath: CYLIndexPath) = titles[indexPath.item]
}

/**
 * The tail fold control only appears when the tags need more than defaultVisibleRows rows (iOS CYLTagListFoldingTests,
 * HarmonyOS TagListTailFold.test.ets).
 */
@RunWith(RobolectricTestRunner::class)
@GraphicsMode(GraphicsMode.Mode.NATIVE)
class CYLTagListTailFoldTest {

    private fun frames() = shadowOf(Looper.getMainLooper()).idleFor(Duration.ofMillis(100))

    private fun makeList(count: Int): CYLTagListView {
        val activity = Robolectric.buildActivity(Activity::class.java).setup().get()
        val list = CYLTagListView(activity)
        list.menuDataSource = CYLTailFoldSource(count)
        list.showsSectionHeaders = false
        list.defaultVisibleRows = 2
        list.foldControl = CYLMenuFoldControl.foldControlWithPosition(CYLMenuFoldControlPosition.TAIL, CYLMenuFoldControlContent.CYLMenuFoldControlContentIcon)
        activity.setContentView(FrameLayout(activity).apply { addView(list, FrameLayout.LayoutParams(FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.WRAP_CONTENT)) })
        list.reloadMenuData()
        frames()
        return list
    }

    private fun descendants(view: View): List<View> =
        if (view is ViewGroup) (0 until view.childCount).flatMap { val child = view.getChildAt(it); listOf(child) + descendants(child) } else emptyList()

    private fun foldCells(list: CYLTagListView) = descendants(list).filterIsInstance<CYLTagFoldCell>()

    private fun tagCellCount(list: CYLTagListView) = generateSequence(0) { it + 1 }.takeWhile { list.tagButtonAtIndexPath(CYLIndexPath(it, 0)) != null }.count()

    /** Tags in reading order, then the fold cell: it is the last item. */
    private fun assertFoldCellIsLast(list: CYLTagListView, tags: Int) {
        assertEquals(tags, tagCellCount(list))
        val folds = foldCells(list)
        assertEquals(1, folds.size)
        val fold = folds[0]
        val last = list.tagButtonAtIndexPath(CYLIndexPath(tags - 1, 0))!!.parent as View
        assertTrue("the fold cell follows the last tag", fold.top > last.top || (fold.top == last.top && fold.left > last.left))
    }

    @Test
    fun noSectionCanFoldBeforeTheListKnowsItsWidth() {
        val activity = Robolectric.buildActivity(Activity::class.java).setup().get()
        val list = CYLTagListView(activity)
        list.menuDataSource = CYLTailFoldSource(TAGS_IN_TWO_ROWS)
        list.defaultVisibleRows = 2
        list.foldControl = CYLMenuFoldControl.foldControlWithPosition(CYLMenuFoldControlPosition.HEADER_TRAILING, CYLMenuFoldControlContent.CYLMenuFoldControlContentIcon)
        list.reloadMenuData()
        // Not attached, no width: every tag would be a row of its own (6 rows), which is no layout.
        assertFalse(list.canFoldSection(0))
    }

    @Test
    fun hasNoFoldCellWhenTheTagsFitInFewerRowsThanDefaultVisibleRows() {
        val list = makeList(TAGS_IN_ONE_ROW)
        assertEquals(1, list.numberOfRowsInSection(0))
        assertFalse(list.canFoldSection(0))
        assertEquals(TAGS_IN_ONE_ROW, list.numberOfVisibleItemsInSection(0))
        assertEquals(TAGS_IN_ONE_ROW, tagCellCount(list))
        assertTrue("no fold cell", foldCells(list).isEmpty())
    }

    @Test
    fun hasNoFoldCellWhenTheTagsFitExactlyDefaultVisibleRows() {
        val list = makeList(TAGS_IN_TWO_ROWS)
        assertEquals(2, list.numberOfRowsInSection(0))
        assertFalse(list.canFoldSection(0))
        assertEquals(TAGS_IN_TWO_ROWS, list.numberOfVisibleItemsInSection(0))
        assertEquals(TAGS_IN_TWO_ROWS, tagCellCount(list))
        assertTrue("no fold cell", foldCells(list).isEmpty())
    }

    @Test
    fun endsWithTheFoldCellWhenTheTagsNeedOneRowMoreThanDefaultVisibleRows() {
        val list = makeList(TAGS_IN_THREE_ROWS)
        assertEquals(3, list.numberOfRowsInSection(0))
        assertTrue(list.canFoldSection(0))
        assertFalse(list.isSectionExpanded(0))
        val visible = list.numberOfVisibleItemsInSection(0)
        assertTrue(visible < TAGS_IN_THREE_ROWS)
        assertFoldCellIsLast(list, visible)
        list.setExpanded(true, 0, false)
        frames()
        assertTrue(list.isSectionExpanded(0))
        assertEquals(TAGS_IN_THREE_ROWS, list.numberOfVisibleItemsInSection(0))
        assertFoldCellIsLast(list, TAGS_IN_THREE_ROWS)
        list.setExpanded(false, 0, false)
        frames()
        assertFalse(list.isSectionExpanded(0))
        assertEquals(visible, list.numberOfVisibleItemsInSection(0))
        assertFoldCellIsLast(list, visible)
    }

    private companion object {
        const val TAGS_IN_ONE_ROW = 2
        const val TAGS_IN_TWO_ROWS = 16
        const val TAGS_IN_THREE_ROWS = 17
    }
}
