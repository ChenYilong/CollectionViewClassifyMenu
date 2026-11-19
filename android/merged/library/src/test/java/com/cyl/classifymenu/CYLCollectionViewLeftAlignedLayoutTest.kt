package com.cyl.classifymenu

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

/**
 * The upstream fixes of the iOS layout (docs/CYLCollectionViewLeftAlignedLayout.md), checked on the Kotlin port.
 */
class CYLCollectionViewLeftAlignedLayoutTest {

    private val insets = CYLEdgeInsets(10f, 16f, 10f, 16f)

    private fun assertLeftAligned(frames: List<CYLRect>, width: Float, spacing: Float) {
        frames.forEachIndexed { index, frame ->
            assertTrue("item $index before the leading inset", frame.x >= insets.left - 0.01f)
            assertTrue("item $index past the trailing inset", frame.maxX <= width - insets.right + 0.01f)
            frames.forEachIndexed { other, o ->
                if (other != index) assertFalse("items $index and $other overlap",
                    frame.x < o.maxX - 0.01f && o.x < frame.maxX - 0.01f && frame.y < o.maxY - 0.01f && o.y < frame.maxY - 0.01f)
            }
            val previous = frames.getOrNull(index - 1)
            if (previous != null && kotlin.math.abs((previous.y + previous.height / 2) - (frame.y + frame.height / 2)) < 1f) {
                assertEquals(previous.maxX + spacing, frame.x, 0.01f)
            } else {
                assertEquals(insets.left, frame.x, 0.01f)
            }
        }
    }

    /** PR #20, #31, issues #26, #27: full-width items with fractional heights each start a row at the leading inset. */
    @Test
    fun fullWidthItemsWithFractionalHeights() {
        val sizes = (0 until 12).map { CYLSize(320f - 32f, 33.333333f + (it % 2) * 0.333333f) }
        val (frames, _) = CYLCollectionViewLeftAlignedLayout().frames(sizes, 0f, 320f, insets, 0.333333f, 0.333333f)
        assertLeftAligned(frames, 320f, 0.333333f)
        assertEquals(12, frames.map { it.y }.distinct().size)
    }

    /** Issue #33: wider-than-content items are clamped, nothing passes the trailing inset. */
    @Test
    fun itemsNeverPassTheTrailingInset() {
        val sizes = (0 until 25).map { CYLSize(if (it % 7 == 0) 400f else 37.7f + (it % 4) * 31.3f, 30f) }
        for (width in listOf(320f, 375f, 414f)) {
            val (frames, _) = CYLCollectionViewLeftAlignedLayout().frames(sizes, 0f, width, insets, 8f, 8f)
            assertLeftAligned(frames, width, 8f)
        }
    }

    /** Issues #2, #29: 2000 items of different sizes, laid out quickly. */
    @Test
    fun twoThousandItemsOfDifferentSizes() {
        val sizes = (0 until 2000).map { CYLSize(30f + (it * 53) % 200, 24f + (it % 3) * 18) }
        val start = System.nanoTime()
        val (frames, bottom) = CYLCollectionViewLeftAlignedLayout().frames(sizes, 0f, 375f, insets, 8f, 8f)
        assertTrue((System.nanoTime() - start) / 1e9 < 1.0)
        assertEquals(2000, frames.size)
        assertTrue(bottom > 0f)
        frames.forEachIndexed { index, frame ->
            assertTrue(frame.x >= insets.left - 0.01f && frame.maxX <= 375f - insets.right + 0.01f)
            if (index > 0) assertTrue(frame.y >= frames[index - 1].y - 50f)
        }
    }
}
