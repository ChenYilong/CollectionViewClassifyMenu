package me.kaede.sample

import android.graphics.Color
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.BaseAdapter
import android.widget.ListView
import androidx.appcompat.app.AppCompatActivity
import me.kaede.tagview.Tag
import me.kaede.tagview.TagView

class ListViewActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_list_view)

        val listView = findViewById<ListView>(R.id.list)
        val adapter = MyAdapter()
        listView.adapter = adapter
        val datas = ArrayList<ListData>()
        for (i in 0..50) {
            datas.add(ListData("ITEM $i"))
        }
        adapter.setDatas(datas)
    }

    class ListData(@JvmField var text: String)

    class ViewHolder {
        lateinit var tagView: TagView
    }

    inner class MyAdapter : BaseAdapter() {
        private var datas: List<ListData> = ArrayList()

        fun setDatas(datas: List<ListData>) {
            this.datas = datas
            notifyDataSetChanged()
        }

        override fun getCount(): Int = datas.size

        override fun getItem(position: Int): ListData = datas[position]

        override fun getItemId(position: Int): Long = position.toLong()

        override fun getView(position: Int, convertView: View?, parent: ViewGroup): View {
            var view = convertView
            if (view == null) {
                view = LayoutInflater.from(parent.context).inflate(R.layout.item_list_tag, parent, false)
                val holder = ViewHolder()
                holder.tagView = view.findViewById(R.id.tagview_item_list)
                view.tag = holder
            }
            val holder = view!!.tag as ViewHolder?
            if (holder != null) {
                holder.tagView.removeAllTags()
                val tags = ArrayList<Tag>()
                var tag = Tag(getItem(position).text)
                tag.layoutColor = Color.parseColor("#F06292")
                tags.add(tag)
                tag = Tag(getItem(position).text)
                tag.layoutColor = Color.parseColor("#90CAF9")
                tags.add(tag)
                tag = Tag(getItem(position).text)
                tag.layoutColor = Color.parseColor("#80DEEA")
                tags.add(tag)
                holder.tagView.addTags(tags)
            }
            return view
        }
    }
}
