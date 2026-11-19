package com.cyl.classifymenu

import android.app.Activity
import android.os.Looper
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.Robolectric
import org.robolectric.RobolectricTestRunner
import org.robolectric.Shadows.shadowOf
import org.robolectric.annotation.GraphicsMode
import java.time.Duration

/** Sections of tags with stable ids ("id-<first title>"), moved with them and kept by a rename. */
private class CYLRenamableTagSource(var sections: MutableList<MutableList<String>>) : CYLMenuDataSource, CYLMenuDelegate {
    var editableSections: Set<Int>? = null
    var renames = false
    var identifiers: MutableList<MutableList<String>> = sections.map { s -> s.map { "id-$it" }.toMutableList() }.toMutableList()
    val events = ArrayList<String>()
    var finishedItems: Map<String, List<CYLTagListCacheItem>>? = null

    override fun numberOfSectionsInMenu() = sections.size
    override fun menuNumberOfItemsInSection(section: Int) = sections[section].size
    override fun menuTitleForSection(section: Int) = if (section == 0) "Recent" else "My Tags"
    override fun menuTitleForItemAtIndexPath(indexPath: CYLIndexPath) = sections[indexPath.section][indexPath.item]
    override fun menuSectionAllowsEditing(section: Int) = editableSections?.contains(section) ?: true
    override fun menuIdentifierForItemAtIndexPath(indexPath: CYLIndexPath) = identifiers[indexPath.section][indexPath.item]
    override fun supportsRenamingItems() = renames
    override fun menuRenameItemAtIndexPath(indexPath: CYLIndexPath, title: String) {
        sections[indexPath.section][indexPath.item] = title
    }
    override fun menuRemoveItemAtIndexPath(indexPath: CYLIndexPath) {
        sections[indexPath.section].removeAt(indexPath.item)
        identifiers[indexPath.section].removeAt(indexPath.item)
    }
    override fun menuMoveItemAtIndexPath(sourceIndexPath: CYLIndexPath, toIndexPath: CYLIndexPath) {
        sections[toIndexPath.section].add(toIndexPath.item, sections[sourceIndexPath.section].removeAt(sourceIndexPath.item))
        identifiers[toIndexPath.section].add(toIndexPath.item, identifiers[sourceIndexPath.section].removeAt(sourceIndexPath.item))
    }
    override fun supportsMovingItems() = true
    override fun menuShowsClearButtonForSection(section: Int) = section == 0
    override fun menuDidRenameItemAtIndexPath(menu: Any, indexPath: CYLIndexPath, title: String) {
        events.add("rename ${indexPath.item}-${indexPath.section} $title")
    }
    override fun menuDidRequestNewItemWithName(menu: Any, name: String, atIndexPath: CYLIndexPath) {
        sections[atIndexPath.section].add(atIndexPath.item, name)
        identifiers[atIndexPath.section].add(atIndexPath.item, "id-$name")
        (menu as? CYLTagListView)?.reloadMenuData()
    }
    override fun menuDidFinishEditingWithItems(menu: Any, items: Map<String, List<CYLTagListCacheItem>>) {
        finishedItems = items
    }
    override fun menuDidTapClearButtonInSection(menu: Any, section: Int) {
        events.add("clear $section")
    }
}

/** A remote source that answers with fixed items. */
private class CYLFakeItemsRemoteSource(val items: Map<String, List<CYLTagListCacheItem>>) : CYLTagListRemoteSource {
    override fun fetchSectionsWithKeys(keys: List<String>, completion: (Map<String, List<String>>?, Throwable?) -> Unit) {
        completion(items.mapValues { (_, list) -> list.map { it.title } }, null)
    }
    override fun fetchItemsWithKeys(keys: List<String>, completion: (Map<String, List<CYLTagListCacheItem>>?, Throwable?) -> Unit) {
        completion(items, null)
    }
}

/**
 * Renaming in editing mode, item ids and the header's clear button, as iOS `CYLTagListEditingTests` (990cf115,
 * cea04255, d58c4e6f, 3af1b7cd).
 */
@RunWith(RobolectricTestRunner::class)
@GraphicsMode(GraphicsMode.Mode.NATIVE)
class CYLTagListRenamingTest {

    private fun frames() = shadowOf(Looper.getMainLooper()).idleFor(Duration.ofMillis(100))

    private fun makeList(source: CYLRenamableTagSource): CYLTagListView {
        val activity = Robolectric.buildActivity(Activity::class.java).setup().get()
        val list = CYLTagListView(activity)
        list.menuDataSource = source
        list.menuDelegate = source
        list.selectionMode = CYLMenuSelectionMode.CYLMenuSelectionModeMultiple
        activity.setContentView(FrameLayout(activity).apply { addView(list, FrameLayout.LayoutParams(FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.WRAP_CONTENT)) })
        list.reloadMenuData()
        frames()
        return list
    }

    private fun cell(list: CYLTagListView, item: Int, section: Int): CYLTagListCell? =
        list.tagButtonAtIndexPath(CYLIndexPath(item, section))?.parent as? CYLTagListCell

    private fun find(view: View, identifier: String): View? {
        if (view.cyl_accessibilityIdentifier == identifier) return view
        if (view is ViewGroup) for (i in 0 until view.childCount) find(view.getChildAt(i), identifier)?.let { return it }
        return null
    }

    @Test
    fun renamingShowsTwoIconsRenamesAndKeepsTheIdentifier() {
        val source = CYLRenamableTagSource(mutableListOf(mutableListOf("Recent A"), mutableListOf("Family", "Friends", "Clients")))
        source.editableSections = setOf(1)
        val list = makeList(source)
        val name = "CYLTagListRenamingTest.rename"
        CYLTagListStore(list.context, CYLTagListCachePolicy.CYLTagListCachePolicyUserDefaults, name).removeAllTitles()
        list.cacheName = name
        list.cachePolicy = CYLTagListCachePolicy.CYLTagListCachePolicyUserDefaults
        list.setEditing(true, animated = false)
        frames()
        assertFalse("no rename indicator without menuRenameItem", cell(list, 0, 1)!!.isRenamable)
        source.renames = true
        list.reloadMenuData()
        frames()
        val renamable = cell(list, 0, 1)!!
        assertTrue("a pencil before the cross", renamable.isRenamable)
        assertEquals("drawn by the two-icon stack view", View.VISIBLE, renamable.button.editingIndicatorsView.visibility)
        assertEquals(2, renamable.button.editingIndicatorsView.itemViews.size)
        assertEquals("a row", com.cyl.animateditem.CYLAnimatedItemAxis.Horizontal, renamable.button.editingIndicatorsView.axis)
        assertEquals("the editing spacing", 10f, renamable.button.editingIndicatorsView.spacingDp, 0f)
        assertTrue("tinted", renamable.button.editingIndicatorsView.iconColor != null)
        // Laid out as a row of two icon slots, the editing spacing apart (the pixels are checked on a device:
        // CYLTagEditingIconsDeviceTest).
        val tagButton = renamable.button
        tagButton.requestLayout()
        tagButton.measure(View.MeasureSpec.makeMeasureSpec(tagButton.width, View.MeasureSpec.EXACTLY), View.MeasureSpec.makeMeasureSpec(tagButton.height, View.MeasureSpec.EXACTLY))
        tagButton.layout(tagButton.left, tagButton.top, tagButton.right, tagButton.bottom)
        val icons = tagButton.editingIndicatorsView.itemViews
        assertTrue("two slots side by side", icons[0].width > 0 && icons[1].left - icons[0].right > 0 && icons[0].top == icons[1].top)
        assertTrue(renamable.button.renameIndicatorHitFrame.width > 0)
        // The defaults (d58c4e6f): 10 between the icons, left 4 and right 0 around them.
        val defaults = CYLMenuStyle()
        assertEquals(10f, defaults.editingIndicatorSpacing, 0f)
        assertEquals(CYLEdgeInsets(0f, 4f, 0f, 0f), defaults.editingIndicatorInsets)
        val wider = CYLMenuStyle().apply { editingIndicatorSpacing = 20f }
        assertEquals("editingIndicatorSpacing widens the tag by the extra space", 10f,
            CYLTagButton.widthForTitle("Family", CYLSize.ZERO, true, true, wider) - CYLTagButton.widthForTitle("Family", CYLSize.ZERO, true, true, defaults), 0.5f)
        val padded = CYLMenuStyle().apply { editingIndicatorInsets = CYLEdgeInsets(2f, 10f, 2f, 6f) }
        assertEquals("editingIndicatorInsets (left 10 + right 6 instead of 4 + 0) widens the tag", 12f,
            CYLTagButton.widthForTitle("Family", CYLSize.ZERO, true, true, padded) - CYLTagButton.widthForTitle("Family", CYLSize.ZERO, true, true, defaults), 0.5f)
        assertFalse("not outside the editable sections", cell(list, 0, 0)!!.isRenamable)
        assertTrue("a tap on the title renames too, by default", renamable.renamesOnTitleTap)
        val titleArea = find(renamable, CYLTagListRenameTitleAccessibilityIdentifier)
        assertNotNull(titleArea)
        assertTrue(titleArea!!.width > 0)
        titleArea.performClick()
        assertEquals("the title tap starts renaming", CYLIndexPath(0, 1), list.renamingIndexPath)
        list.finishRenamingToTitle("Family")
        assertNull("an unchanged name only ends renaming", list.renamingIndexPath)
        list.renamesOnTitleTapWhileEditing = false
        frames()
        assertFalse(cell(list, 0, 1)!!.renamesOnTitleTap)
        list.renamesOnTitleTapWhileEditing = true

        list.moveItemAtIndexPath(CYLIndexPath(1, 1), CYLIndexPath(0, 1))
        frames()
        list.beginRenamingItemAtIndexPath(CYLIndexPath(0, 1))
        assertEquals(CYLIndexPath(0, 1), list.renamingIndexPath)
        assertTrue(list.addItemView.isRenaming)
        assertEquals("the field shows the title to rename", "Friends", list.addItemView.textField.text.toString())
        list.addItemView.textField.setText("Best Friends")
        list.addItemView.submit()
        assertNull(list.renamingIndexPath)
        assertFalse("the control adds tags again", list.addItemView.isRenaming)
        assertEquals(listOf("Best Friends", "Family", "Clients"), source.sections[1])
        assertEquals("rename 0-1 Best Friends", source.events.last())
        val items = CYLTagListStore(list.context, CYLTagListCachePolicy.CYLTagListCachePolicyUserDefaults, name).cachedItemsForSection("1")
        assertEquals("reordered and renamed, the same ids", listOf("id-Friends", "id-Family", "id-Clients"), items?.map { it.identifier })
        assertEquals(listOf("Best Friends", "Family", "Clients"), items?.map { it.title })
        list.setEditing(false, animated = false)
        assertEquals(CYLTagListCacheItem("id-Friends", "Best Friends"), source.finishedItems?.get("1")?.first())
        CYLTagListStore(list.context, CYLTagListCachePolicy.CYLTagListCachePolicyUserDefaults, name).removeAllTitles()
    }

    @Test
    fun loadItemsKeepsIdentifiersFromTheServer() {
        val activity = Robolectric.buildActivity(Activity::class.java).setup().get()
        val store = CYLTagListStore(activity, CYLTagListCachePolicy.CYLTagListCachePolicySandboxFile, "CYLTagListRenamingTest.items")
        store.removeAllTitles()
        store.saveItems(listOf(CYLTagListCacheItem("t1", "Family")), "mine")
        assertEquals("the titles follow the items", listOf("Family"), store.cachedTitlesForSection("mine"))
        val list = CYLTagListView(activity)
        list.cache = store
        val renamedOnServer = listOf(CYLTagListCacheItem("t2", "Work"), CYLTagListCacheItem("t1", "Home"))
        list.remoteSource = CYLFakeItemsRemoteSource(mapOf("mine" to renamedOnServer))
        val events = ArrayList<String>()
        list.loadItemsWithKeys(listOf("mine")) { items, origin ->
            val from = if (origin == CYLTagListDataOrigin.CYLTagListDataOriginCache) "cache" else "network"
            events.add("$from ${items["mine"]?.joinToString(",") ?: "-"}")
        }
        frames()
        assertEquals(listOf("cache t1:Family", "network t2:Work,t1:Home"), events)
        assertEquals("the server's items are saved with their ids", renamedOnServer, store.cachedItemsForSection("mine"))
        store.saveTitles(listOf("A"), "mine")
        assertEquals("plain titles: each title is its id", "A", store.cachedItemsForSection("mine")?.first()?.identifier)
        store.removeAllTitles()
    }

    @Test
    fun anExternalEditorRenamesAndAdds() {
        val source = CYLRenamableTagSource(mutableListOf(mutableListOf("Family", "Friends")))
        source.renames = true
        val list = makeList(source)
        list.showsAddItemViewWhileEditing = false
        var request: Pair<CYLIndexPath, String>? = null
        list.renameRequestHandler = { indexPath, title -> request = indexPath to title }
        list.setEditing(true, animated = false)
        frames()
        assertNull("no built-in field", list.addItemView.parent)
        list.beginRenamingItemAtIndexPath(CYLIndexPath(1, 0))
        assertEquals(CYLIndexPath(1, 0), request?.first)
        assertEquals("the host's editor gets the title", "Friends", request?.second)
        frames()
        assertNull("still no built-in field while the host renames", list.addItemView.parent)
        list.finishRenamingToTitle("Pals")
        assertEquals(listOf("Family", "Pals"), source.sections[0])
        list.beginRenamingItemAtIndexPath(CYLIndexPath(0, 0))
        list.cancelRenaming()
        assertNull(list.renamingIndexPath)
        assertEquals("cancelling changes nothing", listOf("Family", "Pals"), source.sections[0])
        list.submitNewItemNamed("  Clients ")
        assertEquals("the host's field adds, trimmed", listOf("Family", "Pals", "Clients"), source.sections[0])
    }

    @Test
    fun theHeaderClearButtonIsBuiltIn() {
        val source = CYLRenamableTagSource(mutableListOf(mutableListOf("Coworkers", "Clients"), mutableListOf("Family")))
        val list = makeList(source)
        var handled: Int? = null
        list.clearButtonHandler = { handled = it }
        frames()
        val buttons = ArrayList<View>()
        fun collect(view: View) {
            if (view.cyl_accessibilityIdentifier == CYLTagListClearButtonAccessibilityIdentifier && view.visibility == View.VISIBLE) buttons.add(view)
            if (view is ViewGroup) for (i in 0 until view.childCount) collect(view.getChildAt(i))
        }
        collect(list)
        assertEquals("only the first section shows it", 1, buttons.size)
        val clear = buttons.first()
        assertTrue(clear.width > 0 && clear.width == clear.height)
        assertEquals("read with the section title", "Clear Recent", clear.contentDescription)
        clear.performClick()
        assertEquals("clear 0", source.events.last())
        assertEquals(0, handled)
        assertNotNull("the core's trash icon, from CYLClassifyMenuImages.bundle", CYLMenuResources.imageNamed("cyl_trash"))
        assertEquals("CYLClassifyMenuImages.bundle", CYLMenuResources.imagesBundle)
    }
}
