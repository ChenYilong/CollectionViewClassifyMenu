package com.licrafter.sample.utils

import com.licrafter.tagview.DIRECTION
import com.licrafter.tagview.TagViewGroup

/**
 * The directions of a new group, and the order a tapped tag turns through.
 */
object DirectionUtils {

    private val turnOrder = listOf(
        DIRECTION.RIGHT_CENTER, DIRECTION.RIGHT_TOP, DIRECTION.RIGHT_TOP_STRAIGHT, DIRECTION.RIGHT_BOTTOM,
        DIRECTION.RIGHT_BOTTOM_STRAIGHT, DIRECTION.LEFT_CENTER, DIRECTION.LEFT_TOP, DIRECTION.LEFT_TOP_STRAIGHT,
        DIRECTION.LEFT_BOTTOM, DIRECTION.LEFT_BOTTOM_STRAIGHT,
    )

    fun next(direction: DIRECTION): DIRECTION = turnOrder[(turnOrder.indexOf(direction) + 1) % turnOrder.size]

    fun defaultDirections(count: Int): List<DIRECTION> = when (count) {
        0 -> emptyList()
        1 -> listOf(DIRECTION.RIGHT_CENTER)
        2 -> listOf(DIRECTION.RIGHT_TOP, DIRECTION.RIGHT_BOTTOM)
        else -> {
            val more = listOf(DIRECTION.LEFT_TOP, DIRECTION.LEFT_CENTER, DIRECTION.LEFT_BOTTOM)
            listOf(DIRECTION.RIGHT_TOP, DIRECTION.RIGHT_CENTER, DIRECTION.RIGHT_BOTTOM) +
                more.take(minOf(count, TagViewGroup.DEFAULT_MAX_TAG) - 3)
        }
    }
}
