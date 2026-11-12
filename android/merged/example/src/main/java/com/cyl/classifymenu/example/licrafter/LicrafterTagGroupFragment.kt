package com.cyl.classifymenu.example.licrafter

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import android.widget.LinearLayout
import android.widget.Toast
import androidx.activity.result.contract.ActivityResultContracts
import androidx.fragment.app.Fragment
import com.cyl.classifymenu.example.R

/**
 * The "TagViewGroup" tab: the TagViewGroup sample's main screen as a page: a picture with two groups (a tap shows or
 * hides them), the editor and the list.
 */
class LicrafterTagGroupFragment : Fragment() {

    lateinit var tagImageView: TagImageView
        private set
    private val editor = registerForActivityResult(ActivityResultContracts.StartActivityForResult()) { result ->
        if (result.resultCode == Activity.RESULT_OK) tagImageView.setTagGroups(DataRepo.tagGroups)
    }

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View {
        val context = requireContext()
        tagImageView = TagImageView(context)
        tagImageView.setPicture(0)
        tagImageView.setTagGroups(DataRepo.tagGroups)
        tagImageView.onCircleClick = { toast(getString(R.string.licrafter_circle_click)) }
        tagImageView.onLongPress = { toast(getString(R.string.licrafter_circle_click)) }
        tagImageView.onTagClick = { _, _, title -> toast(getString(R.string.licrafter_tag_click, title)) }
        val create = Button(context).apply {
            text = getString(R.string.licrafter_create_tags)
            setOnClickListener { editor.launch(Intent(context, LicrafterTagEditActivity::class.java)) }
        }
        val list = Button(context).apply {
            text = getString(R.string.licrafter_tag_list)
            setOnClickListener { startActivity(Intent(context, LicrafterTagListActivity::class.java)) }
        }
        val buttons = LinearLayout(context).apply {
            addView(create, LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.WRAP_CONTENT, 1f))
            addView(list, LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.WRAP_CONTENT, 1f))
        }
        return LinearLayout(context).apply {
            orientation = LinearLayout.VERTICAL
            addView(tagImageView)
            addView(buttons)
        }
    }

    override fun onResume() {
        super.onResume()
        tagImageView.setTagGroups(DataRepo.tagGroups)
    }

    private fun toast(text: String) = Toast.makeText(requireContext(), text, Toast.LENGTH_SHORT).show()
}
