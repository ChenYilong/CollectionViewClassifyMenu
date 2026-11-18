package com.cyl.classifymenu

import android.app.Activity
import android.os.Looper
import android.os.SystemClock
import android.view.MotionEvent
import android.view.View
import android.widget.FrameLayout
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.Robolectric
import org.robolectric.RobolectricTestRunner
import org.robolectric.Shadows.shadowOf
import org.robolectric.annotation.GraphicsMode
import java.time.Duration

/** Sections of tags that can be removed, moved and added to; `editableSections` alone take part in editing. */
private class CYLEditableTagSource(var sections: MutableList<MutableList<String>>) : CYLMenuDataSource, CYLMenuDelegate {
    var editableSections: Set<Int>? = null
    val events = ArrayList<String>()

    override fun numberOfSectionsInMenu() = sections.size
    override fun menuNumberOfItemsInSection(section: Int) = sections[section].size
    override fun menuTitleForSection(section: Int) = "Section $section"
    override fun menuTitleForItemAtIndexPath(indexPath: CYLIndexPath) = sections[indexPath.section][indexPath.item]
    override fun menuSectionAllowsEditing(section: Int) = editableSections?.contains(section) ?: true
    override fun menuRemoveItemAtIndexPath(indexPath: CYLIndexPath) {
        sections[indexPath.section].removeAt(indexPath.item)
    }
    override fun menuMoveItemAtIndexPath(sourceIndexPath: CYLIndexPath, toIndexPath: CYLIndexPath) {
        val title = sections[sourceIndexPath.section].removeAt(sourceIndexPath.item)
        sections[toIndexPath.section].add(toIndexPath.item, title)
    }
    override fun supportsMovingItems() = true
    override fun menuDidSelectItemAtIndexPath(menu: Any, indexPath: CYLIndexPath) {
        events.add("select ${indexPath.item}-${indexPath.section}")
    }
    override fun menuDidChangeEditing(menu: Any, editing: Boolean) {
        events.add(if (editing) "edit" else "done")
    }
    override fun menuDidRequestNewItemWithName(menu: Any, name: String, atIndexPath: CYLIndexPath) {
        events.add("add $name at ${atIndexPath.item}-${atIndexPath.section}")
        sections[atIndexPath.section].add(atIndexPath.item, name)
        (menu as? CYLTagListView)?.reloadMenuData()
    }
}

/**
 * `CYLTagListView`'s editing mode and its cache, as iOS `CYLTagListEditingTests`: delete indicators and the add control
 * only while editing, a tap reports without selecting, folding off while editing, reordering of the editable sections,
 * and the edits saved in every cache policy.
 */
@RunWith(RobolectricTestRunner::class)
@GraphicsMode(GraphicsMode.Mode.NATIVE)
class CYLTagListEditingTest {

    private fun frames() = shadowOf(Looper.getMainLooper()).idleFor(Duration.ofMillis(100))

    private fun makeList(source: CYLEditableTagSource): CYLTagListView {
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

    private fun deletable(list: CYLTagListView, item: Int, section: Int) =
        list.tagButtonAtIndexPath(CYLIndexPath(item, section))?.showsDeleteIndicator == true

    private fun isInside(view: View, ancestor: View): Boolean {
        var parent = view.parent
        while (parent != null) {
            if (parent === ancestor) return true
            parent = parent.parent
        }
        return false
    }

    /** A tap on the item's cell, delivered as touches. */
    private fun tap(list: CYLTagListView, item: Int, section: Int) {
        val cell = list.tagButtonAtIndexPath(CYLIndexPath(item, section))!!.parent as View
        val down = SystemClock.uptimeMillis()
        val x = cell.width / 2f
        val y = cell.height / 2f
        for (action in listOf(MotionEvent.ACTION_DOWN, MotionEvent.ACTION_UP)) {
            val event = MotionEvent.obtain(down, SystemClock.uptimeMillis(), action, x, y, 0)
            cell.dispatchTouchEvent(event)
            event.recycle()
        }
        frames()
    }

    @Test
    fun editingShowsDeleteIndicatorsAndTheAddControlOnlyWhileEditing() {
        val source = CYLEditableTagSource(mutableListOf(mutableListOf("Recent A", "Recent B"), mutableListOf("Family", "Friends", "Clients")))
        source.editableSections = setOf(1)
        val list = makeList(source)
        assertFalse(list.isEditing)
        assertFalse("no delete indicator before editing", deletable(list, 0, 1))
        val heightBefore = list.contentHeight
        list.setEditing(true, animated = false)
        frames()
        assertTrue(list.isEditing)
        assertEquals(listOf("edit"), source.events)
        assertTrue("an editable section shows the delete indicator", deletable(list, 0, 1))
        assertFalse("a section outside editing does not", deletable(list, 0, 0))
        assertTrue("the add control is shown", isInside(list.addItemView, list))
        assertTrue(list.addItemView.height > 0)
        assertTrue("the add control adds to the content height", list.contentHeight > heightBefore)
        list.setEditing(false, animated = false)
        frames()
        assertFalse("leaving editing hides it", isInside(list.addItemView, list))
        assertEquals(heightBefore, list.contentHeight, 0.5f)
        assertFalse(deletable(list, 0, 1))
        assertEquals(listOf("edit", "done"), source.events)
    }

    @Test
    fun editingTapReportsWithoutSelectingAndDeleteRemoves() {
        val source = CYLEditableTagSource(mutableListOf(mutableListOf("Family", "Friends", "Clients")))
        val list = makeList(source)
        list.setEditing(true, animated = false)
        frames()
        tap(list, 1, 0)
        assertEquals("a tap still reports the item, so the host can open it", "select 1-0", source.events.last())
        assertTrue("but does not select it while editing", list.selectedIndexPaths.isEmpty())
        list.deleteItemAtIndexPath(CYLIndexPath(0, 0))
        assertEquals("the delete indicator removes the item", listOf("Friends", "Clients"), source.sections[0])
    }

    @Test
    fun editingUnfoldsAndAddsThroughTheAddControl() {
        val source = CYLEditableTagSource(mutableListOf((0 until 30).map { "Tag $it" }.toMutableList()))
        val list = makeList(source)
        list.showsSectionHeaders = false
        list.defaultVisibleRows = 2
        list.foldStyle = CYLMenuFoldStyle.CYLMenuFoldStyleFooterChevron
        frames()
        assertTrue(list.canFoldSection(0))
        assertTrue(list.numberOfVisibleItemsInSection(0) < 30)
        list.setEditing(true, animated = false)
        frames()
        assertFalse("editing shows every item", list.canFoldSection(0))
        assertEquals(30, list.numberOfVisibleItemsInSection(0))
        list.addItemView.textField.setText("  Book Club  ")
        list.addItemView.submit()
        assertEquals("trimmed, at the end of the editable section", "add Book Club at 30-0", source.events.last())
        assertEquals("Book Club", source.sections[0].last())
        assertEquals("the field is cleared", "", list.addItemView.textField.text.toString())
        list.setEditing(false, animated = false)
        frames()
        assertTrue("folding comes back after editing", list.canFoldSection(0))
    }

    @Test
    fun editingEnablesReorderingOfEditableSections() {
        val source = CYLEditableTagSource(mutableListOf(mutableListOf("Recent A", "Recent B"), mutableListOf("Family", "Friends")))
        source.editableSections = setOf(1)
        val list = makeList(source)
        assertFalse(list.allowsReordering)
        assertFalse(list.canMoveItemAtIndexPath(CYLIndexPath(0, 1)))
        list.setEditing(true, animated = false)
        assertTrue("an editable section's tags can be dragged while editing", list.canMoveItemAtIndexPath(CYLIndexPath(0, 1)))
        assertFalse("the other sections' cannot", list.canMoveItemAtIndexPath(CYLIndexPath(0, 0)))
        list.setEditing(false, animated = false)
        assertFalse(list.canMoveItemAtIndexPath(CYLIndexPath(0, 1)))
    }

    /** A remote source that answers at once with fixed sections, or fails. */
    private class CYLFakeRemoteSource(var sections: Map<String, List<String>>?) : CYLTagListRemoteSource {
        var fetchCount = 0
        override fun fetchSectionsWithKeys(keys: List<String>, completion: (Map<String, List<String>>?, Throwable?) -> Unit) {
            fetchCount += 1
            completion(sections, if (sections == null) IllegalStateException("CYLFake") else null)
        }
    }

    @Test
    fun finishingEditingReportsTheEditedSectionsForUploading() {
        val source = CYLEditableTagSource(mutableListOf(mutableListOf("Recent A"), mutableListOf("Family", "Friends", "Clients")))
        source.editableSections = setOf(1)
        val list = makeList(source)
        var reported: Map<String, List<String>>? = null
        list.editingFinishHandler = { reported = it }
        list.setEditing(true, animated = false)
        list.moveItemAtIndexPath(CYLIndexPath(2, 1), CYLIndexPath(0, 1))
        assertNull("nothing before editing ends", reported)
        list.setEditing(false, animated = false)
        assertEquals("the edited section, in its new order", mapOf("1" to listOf("Clients", "Family", "Friends")), reported)
    }

    private fun loads(policy: CYLTagListLoadPolicy, cached: List<String>?, remote: List<String>?): Pair<List<String>, List<String>?> {
        val activity = Robolectric.buildActivity(Activity::class.java).setup().get()
        val store = CYLTagListStore(activity, CYLTagListCachePolicy.CYLTagListCachePolicyUserDefaults, "CYLTagListEditingTest.load")
        store.removeAllTitles()
        if (cached != null) store.saveTitles(cached, "mine")
        val list = CYLTagListView(activity)
        list.cache = store
        list.remoteSource = CYLFakeRemoteSource(remote?.let { mapOf("mine" to it) })
        list.loadPolicy = policy
        val events = ArrayList<String>()
        list.loadSectionsWithKeys(listOf("mine")) { sections, origin ->
            val from = if (origin == CYLTagListDataOrigin.CYLTagListDataOriginCache) "cache" else "network"
            events.add("$from ${sections["mine"]?.joinToString(",") ?: "-"}")
        }
        frames()
        val stored = store.cachedTitlesForSection("mine")
        store.removeAllTitles()
        return events to stored
    }

    @Test
    fun loadPoliciesOrderTheCacheAndTheServer() {
        val refreshed = loads(CYLTagListLoadPolicy.CYLTagListLoadPolicyCacheThenNetwork, listOf("A", "B"), listOf("B", "A", "C"))
        assertEquals("the default: the cache, then the server", listOf("cache A,B", "network B,A,C"), refreshed.first)
        assertEquals("a download is saved to the cache", listOf("B", "A", "C"), refreshed.second)
        assertEquals("a failed download", listOf("cache A"), loads(CYLTagListLoadPolicy.CYLTagListLoadPolicyCacheThenNetwork, listOf("A"), null).first)
        assertEquals("a full cache: no download", listOf("cache A"), loads(CYLTagListLoadPolicy.CYLTagListLoadPolicyCacheFirst, listOf("A"), listOf("B")).first)
        assertEquals(listOf("network B"), loads(CYLTagListLoadPolicy.CYLTagListLoadPolicyCacheFirst, null, listOf("B")).first)
        assertEquals(listOf("network B"), loads(CYLTagListLoadPolicy.CYLTagListLoadPolicyNetworkFirst, listOf("A"), listOf("B")).first)
        assertEquals("the cache when it fails", listOf("cache A"), loads(CYLTagListLoadPolicy.CYLTagListLoadPolicyNetworkFirst, listOf("A"), null).first)
        val activity = Robolectric.buildActivity(Activity::class.java).setup().get()
        assertEquals("the core's default", CYLTagListLoadPolicy.CYLTagListLoadPolicyCacheThenNetwork, CYLTagListView(activity).loadPolicy)
    }

    @Test
    fun editsAreSavedInEveryCachePolicy() {
        for (policy in listOf(CYLTagListCachePolicy.CYLTagListCachePolicyDatabase, CYLTagListCachePolicy.CYLTagListCachePolicyUserDefaults,
                              CYLTagListCachePolicy.CYLTagListCachePolicySandboxFile)) {
            val source = CYLEditableTagSource(mutableListOf(mutableListOf("Recent A"), mutableListOf("Family", "Friends", "Clients")))
            source.editableSections = setOf(1)
            val list = makeList(source)
            val name = "CYLTagListEditingTest.${policy.ordinal}"
            CYLTagListStore(list.context, policy, name).removeAllTitles()
            list.cacheName = name
            list.cachePolicy = policy
            assertNull("nothing saved yet, $policy", list.cachedTitlesInSection(1))
            list.setEditing(true, animated = false)
            list.moveItemAtIndexPath(CYLIndexPath(2, 1), CYLIndexPath(0, 1))
            assertEquals("a drag is saved, $policy", listOf("Clients", "Family", "Friends"), list.cachedTitlesInSection(1))
            list.deleteItemAtIndexPath(CYLIndexPath(1, 1))
            list.addItemView.textField.setText("Book Club")
            list.addItemView.submit()
            assertNull("a section outside editing is not saved", list.cachedTitlesInSection(0))
            // A new store of the same policy and name reads it back, as after a relaunch.
            val reopened = CYLTagListStore(list.context, policy, name)
            assertEquals("$policy", listOf("Clients", "Friends", "Book Club"), reopened.cachedTitlesForSection("1"))
            reopened.saveTitles(emptyList(), "1")
            assertEquals("an emptied section differs from none", emptyList<String>(), reopened.cachedTitlesForSection("1"))
            reopened.removeAllTitles()
            assertNull(reopened.cachedTitlesForSection("1"))
            assertNull(CYLTagListStore.cacheWithPolicy(list.context, CYLTagListCachePolicy.CYLTagListCachePolicyNone, name))
        }
    }
}
