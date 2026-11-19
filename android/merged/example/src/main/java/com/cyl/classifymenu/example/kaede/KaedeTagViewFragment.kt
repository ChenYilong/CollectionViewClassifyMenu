package com.cyl.classifymenu.example.kaede

import android.app.Activity
import android.content.Intent
import android.graphics.Color
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.EditText
import android.widget.Toast
import androidx.activity.result.contract.ActivityResultContracts
import androidx.core.content.ContextCompat
import androidx.fragment.app.Fragment
import com.cyl.classifymenu.example.R
import me.kaede.tagview.OnTagClickListener
import me.kaede.tagview.OnTagDeleteListener
import me.kaede.tagview.Tag
import me.kaede.tagview.TagView
import java.util.Random

/**
 * The "TagView" tab: android-tagview's MainActivity (me.kaede.sample) as a page: the tag styles, add a tag, the
 * activity result, the ListView and RecyclerView screens.
 */
class KaedeTagViewFragment : Fragment(), View.OnClickListener {

    lateinit var tagView: TagView
        private set
    private lateinit var editText: EditText
    private val random = Random()
    private val subActivity = registerForActivityResult(ActivityResultContracts.StartActivityForResult()) { result ->
        if (result.resultCode == Activity.RESULT_OK) tagView.addTag(Tag("ADD AFTER ACTIVITY RESULT"))
    }

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View =
        inflater.inflate(R.layout.kaede_activity_main, container, false)

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        view.findViewById<View>(R.id.tv_add).setOnClickListener(this)
        view.findViewById<View>(R.id.tv_start_activity).setOnClickListener(this)
        view.findViewById<View>(R.id.tv_list_activity).setOnClickListener(this)
        view.findViewById<View>(R.id.tv_recyclerview_activity).setOnClickListener(this)
        editText = view.findViewById(R.id.edit_tag)
        tagView = view.findViewById(R.id.tagview)
        val context = requireContext()
        tagView.setOnTagClickListener(OnTagClickListener { position, tag ->
            Toast.makeText(context, "click tag id = " + tag.id + " position = " + position, Toast.LENGTH_SHORT).show()
        })
        tagView.setOnTagDeleteListener(OnTagDeleteListener { position, tag ->
            Toast.makeText(context, "delete tag id = " + tag.id + " position =" + position, Toast.LENGTH_SHORT).show()
        })
        tagView.addTags(resources.getStringArray(R.array.kaede_continents))
        val colors = resources.getStringArray(R.array.kaede_colors)
        for (i in 1 until colors.size) {
            val tag = Tag("Colorful Text")
            tag.tagTextColor = Color.parseColor(colors[i])
            tagView.addTag(tag)
        }
        for (item in colors) {
            val tag = Tag("Colorful Background")
            tag.layoutColor = Color.parseColor(item)
            tagView.addTag(tag)
        }
        tagView.addTag(Tag("Border").apply { layoutBorderSize = 1f })
        tagView.addTag(Tag("Border").apply { layoutBorderSize = 2f; layoutBorderColor = Color.parseColor(colors[1]) })
        tagView.addTag(Tag("Border").apply { layoutBorderSize = 3f; layoutBorderColor = Color.parseColor(colors[3]) })
        tagView.addTag(Tag("Round Corner").apply { radius = 0f })
        tagView.addTag(Tag("Round Corner").apply { radius = 20f })
        tagView.addTag(Tag("Round Corner").apply { radius = 60f })
        tagView.addTag(Tag("Deletable").apply { isDeletable = true })
        tagView.addTag(Tag("Custom Background").apply {
            tagTextColor = Color.parseColor(colors[0])
            background = ContextCompat.getDrawable(context, R.drawable.kaede_bg_tag)
        })
        tagView.addTag(Tag("Detail Tag").apply {
            tagTextColor = Color.parseColor("#FFFFFF")
            layoutColor = Color.parseColor("#DDDDDD")
            layoutColorPress = Color.parseColor("#555555")
            radius = 20f
            tagTextSize = 14f
            layoutBorderSize = 1f
            layoutBorderColor = Color.parseColor("#FFFFFF")
            isDeletable = true
        })
    }

    override fun onClick(v: View) {
        when (v.id) {
            R.id.tv_add -> {
                val text = editText.text.toString()
                val tag = Tag(if (text != "") text else "ADD A TAG")
                if (random.nextInt(2) == 0) tag.isDeletable = true
                tag.layoutColor = Color.parseColor(resources.getStringArray(R.array.kaede_colors)[random.nextInt(5)])
                tagView.addTag(tag)
            }
            R.id.tv_start_activity -> subActivity.launch(Intent(requireContext(), KaedeSubActivity::class.java))
            R.id.tv_list_activity -> startActivity(Intent(requireContext(), KaedeListViewActivity::class.java))
            R.id.tv_recyclerview_activity -> startActivity(Intent(requireContext(), KaedeRecyclerViewActivity::class.java))
        }
    }
}
