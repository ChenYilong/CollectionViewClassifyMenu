package com.cyl.classifymenu

import android.app.Activity
import android.os.Looper
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import androidx.test.core.app.ApplicationProvider
import com.cyl.animateditem.CYLAnimatedItemView
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertNull
import org.junit.Assert.assertSame
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.Robolectric
import org.robolectric.RobolectricTestRunner
import org.robolectric.Shadows.shadowOf
import org.robolectric.annotation.Config
import org.robolectric.annotation.GraphicsMode
import java.time.Duration

/** Two sections of same-length titles; the second is long enough to fold under `defaultVisibleRows`. */
private class CYLBackdropDataSource(vararg counts: Int) : CYLMenuDataSource {
    val sections = counts.map { count -> (0 until count).map { "Tag %02d".format(it) } }
    override fun numberOfSectionsInMenu() = sections.size
    override fun menuNumberOfItemsInSection(section: Int) = sections[section].size
    override fun menuTitleForSection(section: Int) = "Section $section"
    override fun menuTitleForItemAtIndexPath(indexPath: CYLIndexPath) = sections[indexPath.section][indexPath.item]
}

/**
 * `CYLTagListView.backdropSource` (docs/tag-section-style.md "Android backdropSource"): one parameter forwarded to every glass
 * host the list makes (the tags, the tail fold cell, the section boards). The glass layer itself is internal to the
 * animated item module, so the tests read `CYLAnimatedItemView.itemGlassBackdropSource`, which that module's own test
 * (CYLLiquidGlassTest) pins to the layer.
 */
@RunWith(RobolectricTestRunner::class)
@GraphicsMode(GraphicsMode.Mode.NATIVE)
class CYLTagListBackdropSourceTest {

    private val context = ApplicationProvider.getApplicationContext<android.content.Context>()

    @After
    fun resetGlassGate() {
        CYLAnimatedItemView.liquidGlassActiveOverride = null
    }

    private fun sectionStyle(glassBoard: Boolean): CYLMenuStyle = CYLMenuStyle().also {
        it.sectionStyle = CYLSectionStyle.CYLSectionStyleInsetGrouped
        if (glassBoard) it.sectionBackgroundStyle = CYLTagBackgroundStyle.CYLTagBackgroundStyleLiquidGlass
    }

    /** A list with a data source and the tail fold control, not yet attached: section 1 has more tags than `defaultVisibleRows` rows. */
    private fun newList(activity: Activity): CYLTagListView {
        val list = CYLTagListView(activity)
        list.menuDataSource = CYLBackdropDataSource(SHORT_SECTION_TAGS, LONG_SECTION_TAGS)
        list.defaultVisibleRows = FOLDED_ROWS
        list.foldControl = CYLMenuFoldControl.foldControlWithPosition(CYLMenuFoldControlPosition.TAIL, CYLMenuFoldControlContent.CYLMenuFoldControlContentIcon)
        return list
    }

    private fun attachAndLoad(activity: Activity, list: CYLTagListView) {
        activity.setContentView(FrameLayout(activity).apply { addView(list, FrameLayout.LayoutParams(WIDTH_PX, FrameLayout.LayoutParams.WRAP_CONTENT)) })
        list.reloadMenuData()
        shadowOf(Looper.getMainLooper()).idleFor(Duration.ofMillis(IDLE_MILLIS))
    }

    private fun makeList(style: CYLMenuStyle): CYLTagListView {
        val activity = Robolectric.buildActivity(Activity::class.java).setup().get()
        val list = newList(activity)
        list.style = style
        attachAndLoad(activity, list)
        return list
    }

    private fun descendants(view: View): List<View> =
        if (view is ViewGroup) (0 until view.childCount).flatMap { val child = view.getChildAt(it); listOf(child) + descendants(child) } else emptyList()

    private fun tags(list: CYLTagListView): List<CYLTagButton> =
        (0 until SECTION_COUNT).flatMap { section ->
            generateSequence(0) { it + 1 }.map { list.tagButtonAtIndexPath(CYLIndexPath(it, section)) }.takeWhile { it != null }.filterNotNull().toList()
        }

    private fun foldButtons(list: CYLTagListView) = descendants(list).filterIsInstance<CYLTagFoldCell>().map { it.foldButton }

    /** The section boards: exactly the library's glass item, not a tag button. */
    private fun boards(list: CYLTagListView) = descendants(list).filter { it.javaClass == CYLAnimatedItemView::class.java }.map { it as CYLAnimatedItemView }

    private fun glassHosts(list: CYLTagListView): List<CYLAnimatedItemView> = tags(list) + foldButtons(list) + boards(list)

    private fun plate(): View = View(context)

    @Test
    @Config(sdk = [34])
    fun nullByDefaultReachesNoGlassHost() {
        CYLAnimatedItemView.liquidGlassActiveOverride = true
        val list = makeList(sectionStyle(glassBoard = true))
        assertNull(list.backdropSource)
        assertTrue(tags(list).isNotEmpty())
        assertEquals(1, foldButtons(list).size)
        assertEquals(SECTION_COUNT, boards(list).size)
        for (host in glassHosts(list)) assertNull(host.itemGlassBackdropSource)
    }

    @Test
    @Config(sdk = [34])
    fun settingItReachesEveryTagTheTailFoldCellAndTheSectionBoards() {
        CYLAnimatedItemView.liquidGlassActiveOverride = true
        val list = makeList(sectionStyle(glassBoard = true))
        val plate = plate()
        list.backdropSource = plate
        assertSame(plate, list.backdropSource)
        assertTrue(tags(list).size > SHORT_SECTION_TAGS)
        for (tag in tags(list)) assertSame(plate, tag.itemGlassBackdropSource)
        assertEquals(1, foldButtons(list).size)
        for (fold in foldButtons(list)) assertSame(plate, fold.itemGlassBackdropSource)
        assertEquals(SECTION_COUNT, boards(list).size)
        for (board in boards(list)) {
            assertNotNull("the board draws the glass", board.itemLiquidGlassView)
            assertSame(plate, board.itemGlassBackdropSource)
        }
        assertSame(plate, list.titleView.itemGlassBackdropSource)
    }

    @Test
    @Config(sdk = [34])
    fun aListBuiltWithTheSourceAlreadySetGivesItToEveryNewView() {
        CYLAnimatedItemView.liquidGlassActiveOverride = true
        val activity = Robolectric.buildActivity(Activity::class.java).setup().get()
        val plate = plate()
        val list = newList(activity)
        list.backdropSource = plate
        list.style = sectionStyle(glassBoard = true)
        attachAndLoad(activity, list)
        val hosts = glassHosts(list)
        assertTrue(hosts.size > SHORT_SECTION_TAGS)
        for (host in hosts) assertSame(plate, host.itemGlassBackdropSource)
    }

    @Test
    @Config(sdk = [34])
    fun aTagMadeAfterTheSetterTakesIt() {
        CYLAnimatedItemView.liquidGlassActiveOverride = true
        val list = makeList(sectionStyle(glassBoard = true))
        val plate = plate()
        list.backdropSource = plate
        val before = tags(list).toSet()
        list.reloadMenuData()
        shadowOf(Looper.getMainLooper()).idleFor(Duration.ofMillis(IDLE_MILLIS))
        val after = tags(list)
        assertTrue("the reload made new tag views", after.none { it in before })
        for (host in glassHosts(list)) assertSame(plate, host.itemGlassBackdropSource)
    }

    @Test
    @Config(sdk = [34])
    fun settingNullRestoresTheWindowRootEverywhere() {
        CYLAnimatedItemView.liquidGlassActiveOverride = true
        val list = makeList(sectionStyle(glassBoard = true))
        list.backdropSource = plate()
        list.backdropSource = null
        assertNull(list.backdropSource)
        for (host in glassHosts(list)) assertNull(host.itemGlassBackdropSource)
        assertNull(list.titleView.itemGlassBackdropSource)
    }

    @Test
    @Config(sdk = [34])
    fun anAncestorOfTheListIsPassedThroughUnchanged() {
        CYLAnimatedItemView.liquidGlassActiveOverride = true
        val list = makeList(sectionStyle(glassBoard = true))
        val ancestor = list.parent as View
        // The core does not guess: such a source makes the glass draw only its tint and rim (docs/tag-section-style.md).
        list.backdropSource = ancestor
        assertSame(ancestor, list.backdropSource)
        for (host in glassHosts(list)) assertSame(ancestor, host.itemGlassBackdropSource)
    }

    @Test
    @Config(sdk = [34])
    fun flatTagsKeepTheirLookWhereNoGlassIsDrawn() {
        val list = makeList(sectionStyle(glassBoard = false))
        val colors = tags(list).map { it.itemBackgroundColor }
        list.backdropSource = plate()
        assertTrue(boards(list).isEmpty())
        assertEquals(colors, tags(list).map { it.itemBackgroundColor })
        for (tag in tags(list)) assertNull("no glass layer on a flat tag", tag.itemLiquidGlassView)
    }

    @Test
    @Config(sdk = [34])
    fun aTagButtonMadeOutsideTheListIsUnaffected() {
        val list = makeList(sectionStyle(glassBoard = true))
        val outside = CYLTagButton(context)
        list.backdropSource = plate()
        assertNull(outside.itemGlassBackdropSource)
    }

    private companion object {
        const val WIDTH_PX = 320
        const val SECTION_COUNT = 2
        const val SHORT_SECTION_TAGS = 3
        const val LONG_SECTION_TAGS = 30
        const val FOLDED_ROWS = 2
        const val IDLE_MILLIS = 100L
    }
}
