package com.licrafter.sample

import android.app.AlertDialog
import android.os.Bundle
import android.widget.Button
import android.widget.LinearLayout
import android.widget.TextView
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.licrafter.sample.utils.DataRepo
import com.licrafter.sample.views.TagEditDialog
import com.licrafter.sample.views.TagImageView

/**
 * Create, drag, turn and delete groups, then save them to DataRepo.
 */
class TagEditActivity : AppCompatActivity() {

    lateinit var tagImageView: TagImageView
        private set

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        title = getString(R.string.title_edit)
        tagImageView = TagImageView(this)
        tagImageView.setPicture(0)
        tagImageView.editing = true
        tagImageView.onCircleClick = { Toast.makeText(this, R.string.circle_click, Toast.LENGTH_SHORT).show() }
        tagImageView.onLongPress = { index -> confirmDelete(index) }
        val info = TextView(this).apply {
            text = getString(R.string.edit_info)
            val padding = (16 * resources.displayMetrics.density).toInt()
            setPadding(padding, padding / 2, padding, padding / 2)
        }
        val create = Button(this).apply {
            text = getString(R.string.create)
            setOnClickListener { TagEditDialog.show(this@TagEditActivity) { tagImageView.addTagGroup(it) } }
        }
        val save = Button(this).apply {
            text = getString(R.string.save)
            setOnClickListener { save() }
        }
        val buttons = LinearLayout(this).apply {
            addView(create, LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.WRAP_CONTENT, 1f))
            addView(save, LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.WRAP_CONTENT, 1f))
        }
        setContentView(LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            addView(tagImageView)
            addView(info)
            addView(buttons)
        })
    }

    private fun confirmDelete(index: Int) {
        AlertDialog.Builder(this)
            .setTitle(R.string.delete_group)
            .setMessage(R.string.delete_group_message)
            .setNegativeButton(R.string.cancel, null)
            .setPositiveButton(R.string.ok) { _, _ -> tagImageView.removeTagGroup(index) }
            .show()
    }

    fun save() {
        DataRepo.tagGroups = tagImageView.getTagGroups()
        setResult(RESULT_OK)
        finish()
    }
}
