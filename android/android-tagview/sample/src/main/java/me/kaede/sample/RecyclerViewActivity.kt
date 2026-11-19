package me.kaede.sample

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import me.kaede.tagview.Tag
import me.kaede.tagview.TagView

class RecyclerViewActivity : AppCompatActivity() {
    private val mDataSet = Array(21) { "TEXT" }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_recycler_view)
        val recyclerView = findViewById<RecyclerView>(R.id.recycler)
        val adapter = MyAdapter(mDataSet)
        recyclerView.layoutManager = LinearLayoutManager(this)
        recyclerView.adapter = adapter
    }

    class MyAdapter(private val mDataSet: Array<String>) : RecyclerView.Adapter<MyAdapter.ViewHolder>() {

        class ViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
            var textView: TextView? = null
            var tagView: TagView? = null
        }

        override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
            val vh: ViewHolder
            if (viewType == 0) {
                val v = LayoutInflater.from(parent.context).inflate(R.layout.item_list_text, parent, false)
                vh = ViewHolder(v)
                vh.textView = v.findViewById(R.id.tv)
            } else {
                val v = LayoutInflater.from(parent.context).inflate(R.layout.item_list_tag, parent, false)
                vh = ViewHolder(v)
                vh.tagView = v.findViewById(R.id.tagview_item_list)
            }
            return vh
        }

        override fun onBindViewHolder(holder: ViewHolder, position: Int) {
            val textView = holder.textView
            val tagView = holder.tagView
            if (textView != null) {
                textView.text = mDataSet[position]
            } else if (tagView != null) {
                tagView.removeAllTags()
                val tagList = ArrayList<Tag>()
                tagList.add(Tag("FOOTER 1"))
                tagList.add(Tag("FOOTER 2"))
                tagView.addTags(tagList)
            }
        }

        override fun getItemCount(): Int = mDataSet.size + 1

        override fun getItemViewType(position: Int): Int = if (position < mDataSet.size) 0 else 1
    }
}
