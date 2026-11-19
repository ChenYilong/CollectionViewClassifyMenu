package com.cyl.classifymenu.example.licrafter

import com.cyl.classifymenu.example.R

import android.app.AlertDialog
import android.os.Bundle
import android.widget.Button
import android.widget.LinearLayout
import android.widget.TextView
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity

/**
 * Create, drag, turn and delete groups, then save them to DataRepo.
 */
class LicrafterTagEditActivity : AppCompatActivity() {

    lateinit var tagImageView: TagImageView
        private set

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        title = getString(R.string.licrafter_title_edit)
        tagImageView = TagImageView(this)
        tagImageView.setPicture(0)
        tagImageView.editing = true
        tagImageView.onCircleClick = { Toast.makeText(this, R.string.licrafter_circle_click, Toast.LENGTH_SHORT).show() }
        tagImageView.onLongPress = { index -> confirmDelete(index) }
        val info = TextView(this).apply {
            text = getString(R.string.licrafter_edit_info)
            val padding = (16 * resources.displayMetrics.density).toInt()
            setPadding(padding, padding / 2, padding, padding / 2)
        }
        val create = Button(this).apply {
            text = getString(R.string.licrafter_create)
            setOnClickListener { TagEditDialog.show(this@LicrafterTagEditActivity) { tagImageView.addTagGroup(it) } }
        }
        val save = Button(this).apply {
            text = getString(R.string.licrafter_save)
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
            .setTitle(R.string.licrafter_delete_group)
            .setMessage(R.string.licrafter_delete_group_message)
            .setNegativeButton(R.string.licrafter_cancel, null)
            .setPositiveButton(R.string.licrafter_ok) { _, _ -> tagImageView.removeTagGroup(index) }
            .show()
    }

    fun save() {
        DataRepo.tagGroups = tagImageView.getTagGroups()
        setResult(RESULT_OK)
        finish()
    }
}
