package me.kaede.tagview

/**
 * Listener for tag deletion.
 */
fun interface OnTagDeleteListener {
    fun onTagDeleted(position: Int, tag: Tag)
}
