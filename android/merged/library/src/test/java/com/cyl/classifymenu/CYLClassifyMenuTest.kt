package com.cyl.classifymenu

import android.graphics.Bitmap
import android.graphics.Color
import android.view.View
import android.widget.FrameLayout
import androidx.fragment.app.FragmentActivity
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Assert.fail
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.Robolectric
import org.robolectric.RobolectricTestRunner
import org.robolectric.Shadows.shadowOf
import android.os.Looper

/**
 * The Android port of the classify menu, the multiple filter and their categories (`ClassifyMenu/`, `MultipleFilter/`).
 */
@RunWith(RobolectricTestRunner::class)
class CYLClassifyMenuTest {

    private class Source(val sections: List<List<String>>) : CYLMenuDataSource {
        override fun numberOfSectionsInMenu() = sections.size
        override fun menuNumberOfItemsInSection(section: Int) = sections[section].size
        override fun menuTitleForSection(section: Int) = "Section $section"
        override fun menuTitleForItemAtIndexPath(indexPath: CYLIndexPath) = sections[indexPath.section][indexPath.item]
        override fun menuItemIsExclusiveAtIndexPath(indexPath: CYLIndexPath) = indexPath.item == 0
    }

    private class Delegate : CYLMenuDelegate {
        var selected: CYLIndexPath? = null
        var confirmed: List<CYLIndexPath>? = null
        override fun menuDidSelectItemAtIndexPath(menu: Any, indexPath: CYLIndexPath) { selected = indexPath }
        override fun menuDidConfirmSelectedItems(menu: Any, indexPaths: List<CYLIndexPath>) { confirmed = indexPaths }
    }

    private fun activity(): FragmentActivity = Robolectric.buildActivity(FragmentActivity::class.java).setup().get()

    private fun idle() = shadowOf(Looper.getMainLooper()).idle()

    @Test
    fun viewFrameHelpersAndDescriptions() {
        val activity = activity()
        val view = View(activity)
        view.layout(0, 0, 100, 100)
        val d = activity.resources.displayMetrics.density
        view.cyl_setX(10f)
        assertEquals(10f, view.cyl_x(), 1f / d)
        view.cyl_setSize(CYLSize(30f, 20f))
        assertEquals(30f, view.cyl_width(), 1f / d)
        assertEquals(20f, view.cyl_height(), 1f / d)
        assertEquals(view.cyl_x() + view.cyl_width(), view.cyl_maxX(), 1f / d)
        var tapped = false
        view.cyl_setTarget { tapped = true }
        view.performClick()
        assertTrue(tapped)
        assertEquals("2 (\n\ta,\n\tb,\n)", listOf("a", "b").cyl_descriptionWithLocale(null))
        assertTrue(mapOf("k" to "v").cyl_descriptionWithLocale(null).contains("k = v;"))
        val bitmap = Bitmap.createBitmap(20, 10, Bitmap.Config.ARGB_8888).apply { eraseColor(Color.RED) }
        val blurred = bitmap.cyl_blurredImageWithRadius(4f, 2, Color.WHITE)
        assertEquals(20, blurred.width)
        assertEquals(10, blurred.height)
        assertEquals((30 * d), view.cyl_captureWithWidth(30f).width.toFloat(), 1f)
    }

    @Test
    fun paramsToolSelectsTheFirstItemByDefault() {
        val tool = CYLFilterParamsTool()
        tool.dataSources = listOf(listOf("All", "A"), listOf("All", "B", "C"))
        assertEquals(listOf(listOf(true, false), listOf(true, false, false)), tool.filterParamsArray)
        assertEquals(false, tool.filterParamsDictionary[kMultipleFilterSettingModified])
        assertTrue(tool.filename.endsWith(kMultipleFilterSetting))
    }

    @Test
    fun classifyMenuFoldsExpandsAndSelects() {
        val activity = activity()
        val container = FrameLayout(activity).apply { id = View.generateViewId() }
        activity.setContentView(container)
        val menu = CYLClassifyMenuViewController()
        val delegate = Delegate()
        menu.menuDataSource = Source(listOf(listOf("One"), (1..40).map { "Tag number $it" }))
        menu.menuDelegate = delegate
        activity.supportFragmentManager.beginTransaction().add(container.id, menu).commitNow()
        container.measure(View.MeasureSpec.makeMeasureSpec(1080, View.MeasureSpec.EXACTLY), View.MeasureSpec.makeMeasureSpec(1920, View.MeasureSpec.EXACTLY))
        container.layout(0, 0, 1080, 1920)
        idle()
        container.measure(View.MeasureSpec.makeMeasureSpec(1080, View.MeasureSpec.EXACTLY), View.MeasureSpec.makeMeasureSpec(1920, View.MeasureSpec.EXACTLY))
        container.layout(0, 0, 1080, 1920)
        assertEquals(1, menu.numberOfVisibleItemsInSection(0))
        val folded = menu.numberOfVisibleItemsInSection(1)
        assertTrue("folded $folded", folded in 1 until 40)
        menu.setSectionExpanded(1, true)
        assertEquals(40, menu.numberOfVisibleItemsInSection(1))
        menu.defaultVisibleRows = 0
        assertEquals(1, menu.defaultVisibleRows)
        val cell = (menu.view as android.view.ViewGroup).cyl_findAll(CYLCollectionViewCell::class.java).first { it.section == 1 && it.row == 2 }
        cell.button.performClick()
        assertEquals(CYLIndexPath(2, 1), delegate.selected)
        menu.selectedIndexPath = CYLIndexPath(2, 1)
        assertTrue((menu.view as android.view.ViewGroup).cyl_findAll(CYLCollectionViewCell::class.java).first { it.section == 1 && it.row == 2 }.button.isSelected)
        menu.reloadMenuData()
        assertFalse(menu.isSectionExpanded(1))
    }

    @Test
    fun multipleFilterKeepsExclusiveItemsAlone() {
        val activity = activity()
        val container = FrameLayout(activity)
        activity.setContentView(container)
        container.layout(0, 0, 1080, 1920)
        val filter = CYLMultipleFilterController()
        val delegate = Delegate()
        filter.menuDataSource = Source(listOf(listOf("All", "Red", "Blue"), listOf("All", "S", "M")))
        filter.menuDelegate = delegate
        filter.reloadMenuData()
        assertEquals(listOf(CYLIndexPath(0, 0), CYLIndexPath(0, 1)), filter.selectedIndexPaths())
        filter.selectItemAtIndexPath(CYLIndexPath(1, 0))
        filter.selectItemAtIndexPath(CYLIndexPath(2, 0))
        assertEquals(listOf(CYLIndexPath(1, 0), CYLIndexPath(2, 0), CYLIndexPath(0, 1)), filter.selectedIndexPaths())
        filter.selectItemAtIndexPath(CYLIndexPath(0, 0))
        assertEquals(listOf(CYLIndexPath(0, 0), CYLIndexPath(0, 1)), filter.selectedIndexPaths())
        filter.selectItemAtIndexPath(CYLIndexPath(1, 1))
        filter.selectItemAtIndexPath(CYLIndexPath(1, 1))
        assertEquals(listOf(CYLIndexPath(0, 0), CYLIndexPath(0, 1)), filter.selectedIndexPaths())
        try {
            filter.setSelectedIndexPaths(listOf(CYLIndexPath(0, 0), CYLIndexPath(1, 0)))
            fail("expected a conflict")
        } catch (e: IllegalArgumentException) {
        }
        filter.setSelectedIndexPaths(listOf(CYLIndexPath(1, 0), CYLIndexPath(2, 1)))
        filter.showInView(container)
        idle()
        assertTrue(filter.isShowing)
        filter.confirmButtonClicked(null)
        idle()
        assertEquals(listOf(CYLIndexPath(1, 0), CYLIndexPath(2, 1)), delegate.confirmed)
        filter.restoreButtonClicked(null)
        idle()
        assertEquals(listOf(CYLIndexPath(0, 0), CYLIndexPath(0, 1)), delegate.confirmed)
    }
}

private fun <T : View> android.view.ViewGroup.cyl_findAll(type: Class<T>): List<T> {
    val result = ArrayList<T>()
    for (index in 0 until childCount) {
        val child = getChildAt(index)
        if (type.isInstance(child)) result.add(type.cast(child)!!)
        if (child is android.view.ViewGroup) result.addAll(child.cyl_findAll(type))
    }
    return result
}
