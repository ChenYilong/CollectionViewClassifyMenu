package com.cyl.classifymenu

import android.view.View
import androidx.test.core.app.ApplicationProvider
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNotSame
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner

/**
 * The Android port of the picture tags (`CYLImageTagGroupView.h`, `CYLImageTagView.h`).
 */
@RunWith(RobolectricTestRunner::class)
class CYLImageTagTest {

    private val context = ApplicationProvider.getApplicationContext<android.content.Context>()

    private fun <T : View> laidOut(view: T, width: Int = 1080, height: Int = 1080): T {
        view.measure(View.MeasureSpec.makeMeasureSpec(width, View.MeasureSpec.EXACTLY), View.MeasureSpec.makeMeasureSpec(height, View.MeasureSpec.EXACTLY))
        view.layout(0, 0, width, height)
        return view
    }

    private fun intersects(a: CYLRect, b: CYLRect) = a.x < b.maxX && b.x < a.maxX && a.y < b.maxY && b.y < a.maxY

    @Test
    fun modelsCopyAndDirectionsCycle() {
        val tag = CYLImageTag.tagWithTitle("Coat", CYLImageTagDirection.CYLImageTagDirectionRightTop).apply { link = "https://example.com" }
        val group = CYLImageTagGroup.groupWithTags(listOf(tag), CYLPoint(0.3f, 0.4f))
        val copy = group.copy()
        assertNotSame(group.tags[0], copy.tags[0])
        assertEquals("https://example.com", copy.tags[0].link)
        assertEquals(CYLImageTagDirection.CYLImageTagDirectionLeftCenter, CYLImageTagDirectionNext(CYLImageTagDirection.CYLImageTagDirectionRightBottomStraight))
        assertEquals(CYLImageTagDirection.CYLImageTagDirectionLeftCenter, CYLImageTagDirectionNext(CYLImageTagDirection.CYLImageTagDirectionCenter))
        assertEquals(CYLImageTagDirection.CYLImageTagDirectionLeftTop, CYLImageTagDirectionNext(CYLImageTagDirection.CYLImageTagDirectionLeftCenter))
        assertEquals(6, CYLImageTagGroup.defaultDirectionsForTagCount(9).size)
        assertEquals(listOf(CYLImageTagDirection.CYLImageTagDirectionRightCenter), CYLImageTagGroup.defaultDirectionsForTagCount(1))
    }

    @Test
    fun groupLaysTagsOutAroundTheDotInsideTheView() {
        val group = CYLImageTagGroupView(context)
        group.tags = CYLImageTagGroup.defaultDirectionsForTagCount(6).mapIndexed { i, d -> CYLImageTag("Tag $i", d) }
        group.percentPosition = CYLPoint(0.98f, 0.02f)
        laidOut(group)
        assertEquals(6, group.tagViews.size)
        val bounds = CYLRect(0f, 0f, 1080f / context.resources.displayMetrics.density, 1080f / context.resources.displayMetrics.density)
        val occupied = group.occupiedFrame
        assertTrue("occupied $occupied inside $bounds", occupied.x >= -0.5f && occupied.y >= -0.5f && occupied.maxX <= bounds.maxX + 0.5f && occupied.maxY <= bounds.maxY + 0.5f)
        val frames = group.tagViews.map { group.frameOfTagView(it)!! }
        val left = frames.filterIndexed { i, _ -> i >= 3 }
        left.forEach { assertTrue(it.maxX <= group.centerPoint.x + 0.5f) }
        frames.take(3).forEach { assertTrue(it.x >= group.centerPoint.x - 0.5f) }
        assertEquals(1f, CYLPoint(1.5f, -2f).let { group.percentPosition = it; group.percentPosition.x })
        assertEquals(0f, group.percentPosition.y)
    }

    @Test
    fun hideAndShowWithoutAnimationAndAccessibility() {
        val group = laidOut(CYLImageTagGroupView(context))
        group.tags = listOf(CYLImageTag("Coat", CYLImageTagDirection.CYLImageTagDirectionRightTop), CYLImageTag("Bag", CYLImageTagDirection.CYLImageTagDirectionLeftTop))
        assertTrue(group.circleAccessibilityElement.contentDescription.toString().contains("Coat"))
        assertTrue(group.circleAccessibilityElement.contentDescription.toString().contains("Bag"))
        var hidden = false
        group.hideAnimated(false) { hidden = true }
        assertTrue(hidden && group.isGroupHidden && group.visibility == View.GONE)
        group.showAnimated(false, null)
        assertFalse(group.isGroupHidden)
        assertEquals(1f, group.linesProgress)
        group.animateValueForKey(CYLImageTagGroupKeyTagAlpha, listOf(1f, 0.25f), 0.0, null)
        assertEquals(0.25f, group.tagAlpha)
        group.showsRipple = true
        assertNotNull(group.rippleView)
        group.showsRipple = false
        assertNull(group.rippleView)
    }

    @Test
    fun pictureMovesOverlappingGroupsApartAndTurnsTagsWhileEditing() {
        val view = CYLImageTagView(context)
        val tags = listOf(CYLImageTag("Coat", CYLImageTagDirection.CYLImageTagDirectionRightCenter))
        view.tagGroups = listOf(CYLImageTagGroup(tags, CYLPoint(0.5f, 0.5f)), CYLImageTagGroup(tags, CYLPoint(0.5f, 0.5f)))
        laidOut(view)
        val (a, b) = view.groupViews
        assertFalse("groups still overlap", intersects(a.occupiedFrame, b.occupiedFrame))
        var tapped: CYLImageTag? = null
        view.tagTapHandler = { _, _, tag -> tapped = tag }
        view.editing = true
        a.delegate!!.groupViewDidTapTagAtIndex(a, 0)
        assertEquals(CYLImageTagDirection.CYLImageTagDirectionRightTop, tapped!!.direction)
        assertEquals(CYLImageTagDirection.CYLImageTagDirectionRightTop, view.tagGroups[0].tags[0].direction)
        assertTrue(a.draggable && !a.showsRipple)
        var dragged: CYLPoint? = null
        view.dragHandler = { _, p -> dragged = p }
        a.delegate!!.groupViewDidDragToPercentPosition(a, CYLPoint(0.2f, 0.7f))
        assertEquals(CYLPoint(0.2f, 0.7f), dragged)
        assertEquals(CYLPoint(0.2f, 0.7f), view.tagGroups[0].percentPosition)
        view.removeTagGroupAtIndex(0)
        assertEquals(1, view.groupViews.size)
        view.removeAllTagGroups()
        assertTrue(view.tagGroups.isEmpty())
    }
}
