package com.licrafter.sample

import android.content.Intent
import android.os.Bundle
import android.widget.Button
import android.widget.LinearLayout
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.licrafter.sample.utils.DataRepo
import com.licrafter.sample.views.TagImageView

/**
 * A picture with two tag groups: a tap on the picture shows or hides them; buttons open the editor and the list.
 */
class MainActivity : AppCompatActivity() {

    lateinit var tagImageView: TagImageView
        private set

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        title = getString(R.string.title_main)
        tagImageView = TagImageView(this)
        tagImageView.setPicture(0)
        tagImageView.setTagGroups(DataRepo.tagGroups)
        tagImageView.onCircleClick = { toast(getString(R.string.circle_click)) }
        tagImageView.onLongPress = { toast(getString(R.string.circle_click)) }
        tagImageView.onTagClick = { _, _, title -> toast(getString(R.string.tag_click, title)) }
        val create = Button(this).apply {
            text = getString(R.string.create_tags)
            setOnClickListener { startActivityForResult(Intent(this@MainActivity, TagEditActivity::class.java), 0) }
        }
        val list = Button(this).apply {
            text = getString(R.string.tag_list)
            setOnClickListener { startActivity(Intent(this@MainActivity, TagListActivity::class.java)) }
        }
        val buttons = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            addView(create, LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.WRAP_CONTENT, 1f))
            addView(list, LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.WRAP_CONTENT, 1f))
        }
        setContentView(LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            addView(tagImageView)
            addView(buttons)
        })
    }

    @Deprecated("Deprecated in Java")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (resultCode == RESULT_OK) tagImageView.setTagGroups(DataRepo.tagGroups)
    }

    private fun toast(text: String) = Toast.makeText(this, text, Toast.LENGTH_SHORT).show()
}
