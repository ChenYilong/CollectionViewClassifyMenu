package com.cyl.classifymenu.example.menu

import android.app.Activity
import android.os.Looper
import android.os.SystemClock
import android.view.MotionEvent
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import android.widget.TextView
import com.cyl.classifymenu.CYLIndexPath
import com.cyl.classifymenu.CYLMenuSelectionMode
import com.cyl.classifymenu.CYLTagListCell
import com.cyl.classifymenu.CYLTagLongPressActions
import com.cyl.classifymenu.CYLTagTitleMaxLines
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertTrue
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.Robolectric
import org.robolectric.RobolectricTestRunner
import org.robolectric.Shadows.shadowOf
import org.robolectric.annotation.GraphicsMode
import java.time.Duration

/**
 * The query scenarios screen is one tag list (docs/instructions/examples.md "Sectioned lists in demos use the tag
 * list"): a section and a header per group, a tap opens the scenario like the old row, a long press shows the old
 * explanation in the callout, and the More / Less control only appears on a section that needs more than two rows.
 */
@RunWith(RobolectricTestRunner::class)
@GraphicsMode(GraphicsMode.Mode.NATIVE)
class CYLQueryScenariosScreenTest {

    private companion object {
        const val NARROW_WIDTH_PX = 60
        const val WIDE_WIDTH_PX = 4000
        const val LIST_HEIGHT_PX = 2000
        const val FRAME_MILLIS = 100L
        const val LONG_PRESS_MILLIS = 800L
        const val SECTION_WITH_THREE_SCENARIOS = 0
        const val SECTION_WITH_ONE_SCENARIO = 1
        const val SECTION_WITH_ONE_MORE_SCENARIO = 2
        const val CALLOUT_CLASS = "CYLTagCalloutBubble"
    }

    /** Robolectric closes its database connections after each test; the app's shared selections database must be opened again. */
    @Before
    fun forgetTheSharedSelectionsDatabase() {
        CYLExampleSelections::class.java.getDeclaredField("shared").apply { isAccessible = true }.set(null, null)
    }

    private class Page(val navigator: CYLMenuNavigator, val screen: CYLQueryScenariosScreen, val root: FrameLayout)

    private fun frames() = shadowOf(Looper.getMainLooper()).idleFor(Duration.ofMillis(FRAME_MILLIS))

    private fun makePage(widthPx: Int = NARROW_WIDTH_PX): Page {
        val activity = Robolectric.buildActivity(Activity::class.java).setup().get()
        val navigator = CYLMenuNavigator(activity)
        val screen = CYLQueryScenariosScreen(activity, navigator)
        val root = FrameLayout(activity).apply { addView(screen.view, FrameLayout.LayoutParams(widthPx, LIST_HEIGHT_PX)) }
        activity.setContentView(root)
        screen.screenDidAppear(navigator)
        frames()
        return Page(navigator, screen, root)
    }

    private fun descendants(view: View, out: MutableList<View> = ArrayList()): List<View> {
        out.add(view)
        if (view is ViewGroup) for (i in 0 until view.childCount) descendants(view.getChildAt(i), out)
        return out
    }

    private fun cell(page: Page, title: String) = descendants(page.screen.tagList).filterIsInstance<CYLTagListCell>().first { it.button.title.toString() == title }

    private fun center(view: View): Pair<Float, Float> {
        val location = IntArray(2).also { view.getLocationOnScreen(it) }
        return (location[0] + view.width / 2f) to (location[1] + view.height / 2f)
    }

    private fun touch(page: Page, action: Int, downTime: Long, x: Float, y: Float) {
        val location = IntArray(2).also { page.root.getLocationOnScreen(it) }
        val event = MotionEvent.obtain(downTime, SystemClock.uptimeMillis(), action, x, y, 0)
        event.offsetLocation(-location[0].toFloat(), -location[1].toFloat())
        page.root.dispatchTouchEvent(event)
        event.recycle()
    }

    private fun tap(page: Page, title: String) {
        val (x, y) = center(cell(page, title))
        val down = SystemClock.uptimeMillis()
        touch(page, MotionEvent.ACTION_DOWN, down, x, y)
        touch(page, MotionEvent.ACTION_UP, down, x, y)
        frames()
    }

    private fun longPress(page: Page, title: String) {
        val (x, y) = center(cell(page, title))
        val down = SystemClock.uptimeMillis()
        touch(page, MotionEvent.ACTION_DOWN, down, x, y)
        shadowOf(Looper.getMainLooper()).idleFor(Duration.ofMillis(LONG_PRESS_MILLIS))
        touch(page, MotionEvent.ACTION_UP, down, x, y)
        frames()
    }

    /** The texts of the callouts the window manager shows now (the popup of a long press is a window of its own). */
    private fun calloutTexts(): List<String> {
        val global = Class.forName("android.view.WindowManagerGlobal").getMethod("getInstance").invoke(null)!!
        val field = global.javaClass.getDeclaredField("mViews").apply { isAccessible = true }
        val windows = (field.get(global) as List<*>).filterIsInstance<View>()
        return windows.flatMap { descendants(it) }.filter { it.javaClass.simpleName == CALLOUT_CLASS }.map { (it as TextView).text.toString() }
    }

    @Test
    fun hasOneSectionPerGroupAndEachHasATitle() {
        val page = makePage()
        val screen = page.screen
        assertEquals(CYLQueryScenariosScreen.DATABASE_SECTION + 1, screen.numberOfSectionsInMenu())
        val expected = listOf("场景：查询参数设置（多选）", "场景：菜单选择（移植原 Demo）", "场景：搜索历史与发现", "数据库（SQLite）").map { CYLExampleLocalizedString(page.root.context, it) }
        for (section in 0 until screen.numberOfSectionsInMenu()) assertEquals(expected[section], screen.menuTitleForSection(section))
        assertEquals(listOf(3, 1, 1, 3), (0 until screen.numberOfSectionsInMenu()).map { screen.menuNumberOfItemsInSection(it) })
        // The headers are drawn by the list.
        val drawn = descendants(page.screen.tagList).filterIsInstance<TextView>().map { it.text.toString() }
        for (title in expected) assertTrue("header $title", title in drawn)
    }

    @Test
    fun theTagsShowTheTitleAndTheDatabaseCountsAndAreConfiguredAsTheRuleSays() {
        val page = makePage()
        val screen = page.screen
        val list = screen.tagList
        assertEquals(screen.title(CYLQueryScenario.REVIEWS_DATABASE), screen.menuTitleForItemAtIndexPath(CYLIndexPath(0, 0)))
        val tables = (0 until screen.menuNumberOfItemsInSection(CYLQueryScenariosScreen.DATABASE_SECTION)).map { screen.menuTitleForItemAtIndexPath(CYLIndexPath(it, CYLQueryScenariosScreen.DATABASE_SECTION)) }
        assertEquals(listOf("reviews", "places", "selections"), tables.map { it.substringBefore(" · ") })
        assertTrue(tables.all { it.endsWith(CYLExampleLocalizedString(page.root.context, "%ld 行", it.substringAfter(" · ").takeWhile { c -> c.isDigit() }.toInt())) })
        for (section in 0 until screen.numberOfSectionsInMenu()) for (item in 0 until screen.menuNumberOfItemsInSection(section)) assertNotNull("icon $section/$item", screen.menuImageForItemAtIndexPath(CYLIndexPath(item, section)))
        assertEquals(CYLMenuSelectionMode.CYLMenuSelectionModeNone, list.selectionMode)
        assertEquals(CYLQueryScenariosScreen.DEFAULT_VISIBLE_ROWS, list.defaultVisibleRows)
        assertEquals(CYLQueryScenariosScreen.DEFAULT_VISIBLE_ROWS, 2)
        assertEquals(CYLTagLongPressActions.callout, list.longPressAction)
        assertEquals(3, list.style!!.titleMaxLines)
        assertTrue(list.style!!.titleMaxLines > CYLTagTitleMaxLines.SINGLE)
        assertEquals(0, list.style!!.numberOfItemsPerRow)
    }

    @Test
    fun aTapOpensTheScenarioLikeTheOldRowAndTheTagStaysUnselected() {
        val page = makePage()
        assertEquals(0, page.navigator.depth)
        tap(page, page.screen.title(CYLQueryScenario.REVIEWS_MEMORY))
        assertEquals(1, page.navigator.depth)
        assertTrue(page.navigator.top is CYLReviewListScreen)
        assertTrue(page.screen.tagList.selectedIndexPaths.isEmpty())
    }

    @Test
    fun aTapOnADatabaseCountDoesNothing() {
        val page = makePage()
        val title = page.screen.menuTitleForItemAtIndexPath(CYLIndexPath(0, CYLQueryScenariosScreen.DATABASE_SECTION))
        tap(page, title)
        assertEquals(0, page.navigator.depth)
        assertTrue(page.screen.tagList.selectedIndexPaths.isEmpty())
    }

    @Test
    fun aLongPressShowsTheSubtitleInTheCalloutAndDoesNotOpenTheScenario() {
        val page = makePage()
        val title = page.screen.title(CYLQueryScenario.MENU_LINKAGE)
        val subtitle = page.screen.menuSubtitleForItemAtIndexPath(CYLIndexPath(0, SECTION_WITH_ONE_SCENARIO))
        assertEquals(CYLExampleLocalizedString(page.root.context, "原 Demo 只实现了筛选界面，没有筛选数据；现在每次选择都会生成 SQL、查询数据库并显示结果，选择也保存在数据库中。"), subtitle)
        assertTrue(calloutTexts().isEmpty())
        longPress(page, title)
        assertEquals(listOf(subtitle), calloutTexts())
        assertEquals(0, page.navigator.depth)
        assertTrue(page.screen.tagList.selectedIndexPaths.isEmpty())
    }

    @Test
    fun theFoldControlOnlyAppearsOnASectionNeedingMoreThanTwoRows() {
        // Narrow: a tag fills the width, so a section of three tags takes three rows (Robolectric has no real text widths); a section of one tag takes one.
        val narrow = makePage(NARROW_WIDTH_PX).screen.tagList
        assertTrue(narrow.canFoldSection(SECTION_WITH_THREE_SCENARIOS))
        assertFalse(narrow.canFoldSection(SECTION_WITH_ONE_SCENARIO))
        assertFalse(narrow.canFoldSection(SECTION_WITH_ONE_MORE_SCENARIO))
        assertTrue(narrow.canFoldSection(CYLQueryScenariosScreen.DATABASE_SECTION))
        // Wide: the same three tags fit in one row (a tag is as wide as it needs), so nothing folds.
        val wide = makePage(WIDE_WIDTH_PX).screen.tagList
        for (section in 0 until CYLQueryScenariosScreen.DATABASE_SECTION + 1) assertFalse("section $section", wide.canFoldSection(section))
    }
}
