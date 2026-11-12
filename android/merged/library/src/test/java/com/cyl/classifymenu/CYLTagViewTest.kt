package com.cyl.classifymenu

import android.view.View
import android.view.ViewGroup
import androidx.test.core.app.ApplicationProvider
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.Shadows.shadowOf
import android.os.Looper

/**
 * The Android port of the TagCollectionView part of the pod (`CYLTagView`, `CYLTagGroup`, `CYLTagModel`, cells).
 */
@RunWith(RobolectricTestRunner::class)
class CYLTagViewTest {

    private val context = ApplicationProvider.getApplicationContext<android.content.Context>()

    private class Source : CYLMenuDataSource {
        val sections = listOf((1..12).map { "标签 $it 扩展文字" }, listOf("One"))
        var selected: CYLIndexPath? = null
        override fun numberOfSectionsInMenu() = sections.size
        override fun menuNumberOfItemsInSection(section: Int) = sections[section].size
        override fun menuTitleForSection(section: Int) = "Section $section"
        override fun menuTitleForItemAtIndexPath(indexPath: CYLIndexPath) = sections[indexPath.section][indexPath.item]
    }

    private fun <T : View> all(group: ViewGroup, type: Class<T>): List<T> = (0 until group.childCount).flatMap { index ->
        val child = group.getChildAt(index)
        (if (type.isInstance(child)) listOf(type.cast(child)!!) else emptyList()) + (if (child is ViewGroup) all(child, type) else emptyList())
    }

    @Test
    fun modelsMeasureTheirTitle() {
        val model = CYLTagModel.modelWithTitle("Hello")
        assertTrue(model.width > 50f)
        assertTrue(model.height >= 35f)
        val group = CYLTagGroup().apply { width = 320f; itemArr = (1..10).map { CYLTagModel.modelWithTitle("Tag number $it") } }
        assertTrue(group.firstRowCount in 1 until 10)
        assertEquals(10, group.cellsCountArrayPerRowInSections!!.sum())
        assertEquals(38f, group.height)
    }

    @Test
    fun viewShowsTheFirstRowUntilTheGroupOpens() {
        val view = CYLTagView.tagView(context)
        val source = Source()
        var selected: CYLIndexPath? = null
        view.menuDataSource = source
        view.menuDelegate = object : CYLMenuDelegate {
            override fun menuDidSelectItemAtIndexPath(menu: Any, indexPath: CYLIndexPath) { selected = indexPath }
        }
        view.measure(View.MeasureSpec.makeMeasureSpec(360, View.MeasureSpec.EXACTLY), View.MeasureSpec.makeMeasureSpec(640, View.MeasureSpec.EXACTLY))
        view.layout(0, 0, 360, 640)
        view.reloadMenuData()
        shadowOf(Looper.getMainLooper()).idle()
        assertEquals(2, view.groups.size)
        assertTrue(view.numberOfVisibleItemsInSection(0) in 1 until 12)
        val header = all(view, CYLTagHeaderCell::class.java).first { it.group?.section == 0 }
        header.btnClick()
        assertEquals(12, view.numberOfVisibleItemsInSection(0))
        val cell = all(view, CYLTagCell::class.java).first { it.model?.title == "标签 3 扩展文字" }
        cell.performClick()
        assertEquals(CYLIndexPath(2, 0), selected)
        view.showHeader = false
        assertTrue(all(view, CYLTagHeaderCell::class.java).isEmpty())
    }
}
