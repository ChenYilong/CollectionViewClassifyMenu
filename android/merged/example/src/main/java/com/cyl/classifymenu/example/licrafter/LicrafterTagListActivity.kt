package com.cyl.classifymenu.example.licrafter

import com.cyl.classifymenu.example.R

import android.os.Bundle
import android.view.ViewGroup
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView

/**
 * 30 pictures, each with one group of DataRepo.
 */
class LicrafterTagListActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        title = getString(R.string.licrafter_title_list)
        val recycler = RecyclerView(this)
        recycler.layoutManager = LinearLayoutManager(this)
        recycler.adapter = ImageAdapter()
        setContentView(recycler)
    }

    private inner class ImageAdapter : RecyclerView.Adapter<ImageAdapter.Holder>() {

        inner class Holder(val tagImageView: TagImageView) : RecyclerView.ViewHolder(tagImageView)

        override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): Holder {
            val view = TagImageView(parent.context)
            view.layoutParams = RecyclerView.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT).apply {
                val margin = (4 * parent.resources.displayMetrics.density).toInt()
                setMargins(0, margin, 0, margin)
            }
            return Holder(view)
        }

        /**
         * The items whose groups are hidden (TagViewGroup issue #4).
         */
        val hiddenPositions = HashSet<Int>()

        override fun getItemCount(): Int = 30

        override fun onBindViewHolder(holder: Holder, position: Int) {
            val groups = DataRepo.tagGroups
            holder.tagImageView.setPicture(position % 3, 400)
            holder.tagImageView.setTagGroups(if (groups.isEmpty()) emptyList() else listOf(groups[position % groups.size]))
            // Issue #4: each item keeps its own hidden state; a recycled view takes the state of the item it shows.
            holder.tagImageView.groupsHidden = position in hiddenPositions
            holder.tagImageView.onGroupsHiddenChanged = { hidden -> if (hidden) hiddenPositions.add(position) else hiddenPositions.remove(position) }
            holder.tagImageView.onCircleClick = { toast(getString(R.string.licrafter_circle_click)) }
            holder.tagImageView.onLongPress = { toast(getString(R.string.licrafter_circle_click)) }
            holder.tagImageView.onTagClick = { _, _, title -> toast(getString(R.string.licrafter_tag_click, title)) }
        }
    }

    private fun toast(text: String) = Toast.makeText(this, text, Toast.LENGTH_SHORT).show()
}
