package com.cyl.classifymenu.example.licrafter

import android.app.AlertDialog
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import android.widget.LinearLayout
import android.widget.TextView
import android.widget.Toast
import androidx.fragment.app.Fragment
import com.cyl.classifymenu.example.R

/**
 * The plus button's page: the TagViewGroup editor (TagEditActivity) as a page. Save stores the groups in DataRepo,
 * which the TagViewGroup tab shows.
 */
class LicrafterTagEditFragment : Fragment() {

    lateinit var tagImageView: TagImageView
        private set

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View {
        val context = requireContext()
        tagImageView = TagImageView(context)
        tagImageView.setPicture(0)
        tagImageView.editing = true
        tagImageView.setTagGroups(DataRepo.tagGroups)
        tagImageView.onCircleClick = { Toast.makeText(context, R.string.licrafter_circle_click, Toast.LENGTH_SHORT).show() }
        tagImageView.onLongPress = { index -> confirmDelete(index) }
        val info = TextView(context).apply {
            text = getString(R.string.licrafter_edit_info)
            val padding = (16 * resources.displayMetrics.density).toInt()
            setPadding(padding, padding / 2, padding, padding / 2)
        }
        val create = Button(context).apply {
            text = getString(R.string.licrafter_create)
            setOnClickListener { TagEditDialog.show(context) { tagImageView.addTagGroup(it) } }
        }
        val save = Button(context).apply {
            text = getString(R.string.licrafter_save)
            setOnClickListener {
                DataRepo.tagGroups = tagImageView.getTagGroups()
                Toast.makeText(context, R.string.licrafter_save, Toast.LENGTH_SHORT).show()
            }
        }
        val buttons = LinearLayout(context).apply {
            addView(create, LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.WRAP_CONTENT, 1f))
            addView(save, LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.WRAP_CONTENT, 1f))
        }
        return LinearLayout(context).apply {
            orientation = LinearLayout.VERTICAL
            addView(tagImageView)
            addView(info)
            addView(buttons)
        }
    }

    private fun confirmDelete(index: Int) {
        AlertDialog.Builder(requireContext())
            .setTitle(R.string.licrafter_delete_group)
            .setMessage(R.string.licrafter_delete_group_message)
            .setNegativeButton(R.string.licrafter_cancel, null)
            .setPositiveButton(R.string.licrafter_ok) { _, _ -> tagImageView.removeTagGroup(index) }
            .show()
    }
}
