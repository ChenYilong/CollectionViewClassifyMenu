package com.licrafter.tagview

import android.database.DataSetObservable
import android.database.DataSetObserver
import android.util.Log
import android.view.View
import android.view.ViewGroup
import com.licrafter.tagview.views.ITagView

/**
 * Supplies the tags of a TagViewGroup, as a PagerAdapter supplies pages: `getCount()` tags, each made by
 * `getItem(position)`. Call `notifyDataSetChanged()` after the data changes; the group rebuilds its tags.
 */
abstract class TagAdapter {

    private val observable = DataSetObservable()

    abstract fun getCount(): Int

    abstract fun getItem(position: Int): ITagView

    /**
     * Makes the tag at `position` and adds it to `container` (the TagViewGroup).
     */
    fun instantiateItem(container: ViewGroup, position: Int): ITagView {
        val itemId = getItemId(position)
        val tagView = getItem(position)
        if (DEBUG) Log.d(TAG, "instantiateItem position=$position id=$itemId")
        container.addView(tagView as View)
        return tagView
    }

    fun isViewFromObject(view: View, obj: Any): Boolean = view === obj

    /**
     * Removes the tag made for `position` from `container`.
     */
    fun destroyItem(container: ViewGroup, position: Int, tagView: ITagView) {
        if (DEBUG) Log.d(TAG, "destroyItem position=$position")
        container.removeView(tagView as View)
    }

    fun getItemId(position: Int): Int = position

    fun notifyDataSetChanged() {
        observable.notifyChanged()
    }

    fun registerDataSetObserver(observer: DataSetObserver) {
        observable.registerObserver(observer)
    }

    fun unregisterDataSetObserver(observer: DataSetObserver) {
        observable.unregisterObserver(observer)
    }

    companion object {
        const val DEBUG = false
        const val TAG = "TagAdapter"
    }
}
