package com.cyl.classifymenu

import kotlin.math.max

/**
 * `CYLCollectionViewLeftAlignedLayout`: a flow layout whose rows start at the leading edge (or are centered / at the
 * trailing edge, `rowAlignment`): items in order, a new row when the next one does not fit, items centered in their
 * row's height. `frames` places one section's items (dp).
 */
class CYLCollectionViewLeftAlignedLayout {

    /** A `CYLTagRowAlignment` raw value: 0 leading, 1 center, 2 trailing. */
    var rowAlignment: Int = 0

    /**
     * The frames of items of `sizes` in a section that starts at `top`, `width` wide, with `insets`, the spacing between
     * items and between rows. Returns the frames and the bottom of the last row (before the bottom inset).
     */
    fun frames(sizes: List<CYLSize>, top: Float, width: Float, insets: CYLEdgeInsets, interitemSpacing: Float, lineSpacing: Float, rightToLeft: Boolean = false): Pair<List<CYLRect>, Float> {
        val contentWidth = max(0f, width - insets.left - insets.right)
        val rows = ArrayList<IntRange>()
        var start = 0
        var used = 0f
        for (index in sizes.indices) {
            val itemWidth = minOf(sizes[index].width, contentWidth)
            if (index > start && used + interitemSpacing + itemWidth > contentWidth) {
                rows.add(start until index)
                start = index
                used = 0f
            }
            used += (if (index > start) interitemSpacing else 0f) + itemWidth
        }
        if (start < sizes.size) rows.add(start until sizes.size)
        val frames = ArrayList<CYLRect>(sizes.size)
        var y = top + insets.top
        rows.forEachIndexed { rowIndex, row ->
            val rowHeight = row.maxOf { sizes[it].height }
            val rowWidth = row.sumOf { minOf(sizes[it].width, contentWidth).toDouble() }.toFloat() + interitemSpacing * (row.count() - 1)
            val offset = when (rowAlignment) {
                CYLTagRowAlignment.CYLTagRowAlignmentCenter.ordinal -> (contentWidth - rowWidth) / 2
                CYLTagRowAlignment.CYLTagRowAlignmentTrailing.ordinal -> contentWidth - rowWidth
                else -> 0f
            }
            var x = insets.left + max(0f, offset)
            for (index in row) {
                val size = sizes[index]
                val itemWidth = minOf(size.width, contentWidth)
                val frameX = if (rightToLeft) width - x - itemWidth else x
                frames.add(CYLRect(frameX, y + (rowHeight - size.height) / 2, itemWidth, size.height))
                x += itemWidth + interitemSpacing
            }
            y += rowHeight + if (rowIndex < rows.size - 1) lineSpacing else 0f
        }
        return frames to y
    }
}

/**
 * `UICollectionViewDelegateLeftAlignedLayout`: the delegate protocol of the left-aligned layout; on Android the list
 * view computes the sizes itself, so it declares nothing.
 */
interface UICollectionViewDelegateLeftAlignedLayout
