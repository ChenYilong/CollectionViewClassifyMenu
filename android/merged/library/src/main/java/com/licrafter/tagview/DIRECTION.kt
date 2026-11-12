package com.licrafter.tagview

/**
 * Where a tag sits relative to the group's dot. "Straight" tags are reached by a diagonal line (tilt distance);
 * the others by a vertical line (vertical distance) then a horizontal one under the tag.
 */
enum class DIRECTION {
    LEFT_CENTER,
    LEFT_TOP,
    LEFT_TOP_STRAIGHT,
    LEFT_BOTTOM,
    LEFT_BOTTOM_STRAIGHT,
    RIGHT_CENTER,
    RIGHT_TOP,
    RIGHT_TOP_STRAIGHT,
    RIGHT_BOTTOM,
    RIGHT_BOTTOM_STRAIGHT;

    /**
     * True for the five directions on the left of the dot.
     */
    val isLeft: Boolean
        get() = this == LEFT_CENTER || this == LEFT_TOP || this == LEFT_TOP_STRAIGHT || this == LEFT_BOTTOM || this == LEFT_BOTTOM_STRAIGHT
}
