package com.licrafter.tagview.utils

import android.graphics.Point
import com.licrafter.tagview.DIRECTION
import com.licrafter.tagview.TagViewGroup
import com.licrafter.tagview.views.ITagView
import com.licrafter.tagview.views.RippleView
import kotlin.math.max

/**
 * Geometry shared by TagViewGroup's measure, layout and drawing.
 */
object TagGroupUtils {

    /**
     * The space the group's tags need around the dot: [left, top, right, bottom] in px. Never less than the dot's
     * radius on each side.
     */
    @JvmStatic
    fun getTagViewUsed(group: TagViewGroup): IntArray {
        val radius = group.getCircleRadius()
        var leftMax = radius
        var topMax = radius
        var rightMax = radius
        var bottomMax = radius
        val v = group.getVDistance()
        val t = group.getTitlDistance()
        for (child in group.getTagList()) {
            if (child is RippleView) continue
            val w = child.getMeasuredWidth()
            val h = child.getMeasuredHeight()
            when (child.getDirection()) {
                DIRECTION.RIGHT_TOP_STRAIGHT -> { rightMax = max(rightMax, t + w); topMax = max(topMax, h + t) }
                DIRECTION.RIGHT_TOP -> { rightMax = max(rightMax, w); topMax = max(topMax, h + v) }
                DIRECTION.RIGHT_CENTER -> { rightMax = max(rightMax, w); topMax = max(topMax, max(v, h)) }
                DIRECTION.RIGHT_BOTTOM -> { rightMax = max(rightMax, w); bottomMax = max(bottomMax, v) }
                DIRECTION.RIGHT_BOTTOM_STRAIGHT -> { rightMax = max(rightMax, t + w); bottomMax = max(bottomMax, t) }
                DIRECTION.LEFT_TOP -> { leftMax = max(leftMax, w); topMax = max(topMax, h + v) }
                DIRECTION.LEFT_TOP_STRAIGHT -> { leftMax = max(leftMax, w + t); topMax = max(topMax, h + t) }
                DIRECTION.LEFT_CENTER -> { leftMax = max(leftMax, w); topMax = max(topMax, max(v, h)) }
                DIRECTION.LEFT_BOTTOM -> { leftMax = max(leftMax, w); bottomMax = max(bottomMax, v) }
                DIRECTION.LEFT_BOTTOM_STRAIGHT -> { leftMax = max(leftMax, w + t); bottomMax = max(bottomMax, t) }
            }
        }
        return intArrayOf(leftMax, topMax, rightMax, bottomMax)
    }

    /**
     * The top-left corner of `child` for the group's current dot, from its direction and size.
     */
    @JvmStatic
    fun getStartPoint(group: TagViewGroup, child: ITagView): Point {
        val center = group.getCenterPoint()
        val centerX = center.x
        val centerY = center.y
        val w = child.getMeasuredWidth()
        val h = child.getMeasuredHeight()
        if (child is RippleView) {
            return Point(centerX - w / 2, centerY - h / 2)
        }
        val v = group.getVDistance()
        val t = group.getTitlDistance()
        val x: Int
        val y: Int
        when (child.getDirection()) {
            DIRECTION.RIGHT_TOP_STRAIGHT -> { x = centerX + t; y = centerY - t - h }
            DIRECTION.RIGHT_TOP -> { x = centerX; y = centerY - v - h }
            DIRECTION.RIGHT_CENTER -> { x = centerX; y = centerY - h }
            DIRECTION.RIGHT_BOTTOM -> { x = centerX; y = centerY + v - h }
            DIRECTION.RIGHT_BOTTOM_STRAIGHT -> { x = centerX + t; y = centerY + t - h }
            DIRECTION.LEFT_TOP -> { x = centerX - w; y = centerY - v - h }
            DIRECTION.LEFT_TOP_STRAIGHT -> { x = centerX - w - t; y = centerY - t - h }
            DIRECTION.LEFT_CENTER -> { x = centerX - w; y = centerY - h }
            DIRECTION.LEFT_BOTTOM -> { x = centerX - w; y = centerY + v - h }
            DIRECTION.LEFT_BOTTOM_STRAIGHT -> { x = centerX - w - t; y = centerY + t - h }
        }
        return Point(x, y)
    }
}
