package com.cyl.classifymenu.example.licrafter

import com.licrafter.tagview.DIRECTION

/**
 * One tag of a group: its text, where it sits around the dot, and the page it links to.
 */
data class TagModel(var name: String, var direction: DIRECTION, var link: String? = null)

/**
 * A group of tags at (percentX, percentY) of the picture.
 */
data class TagGroupModel(val tags: MutableList<TagModel>, var percentX: Float, var percentY: Float) {
    fun copy(): TagGroupModel = TagGroupModel(tags.map { it.copy() }.toMutableList(), percentX, percentY)
}
