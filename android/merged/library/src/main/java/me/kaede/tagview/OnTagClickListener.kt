package me.kaede.tagview

/**
 * Listener for tag clicks.
 */
fun interface OnTagClickListener {
    fun onTagClick(position: Int, tag: Tag)
}
