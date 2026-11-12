/*
 * Copyright 2015 lujun
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * Modified: translated from Java to Kotlin (2026).
 */

package com.cyl.classifymenu.example.lujun

import android.app.AlertDialog
import android.content.ClipData
import android.graphics.Bitmap
import android.graphics.Color
import android.graphics.drawable.Drawable
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import android.widget.EditText
import android.widget.Toast
import androidx.fragment.app.Fragment
import co.lujun.androidtagview.TagContainerLayout
import co.lujun.androidtagview.TagView
import com.bumptech.glide.Glide
import com.bumptech.glide.request.RequestOptions
import com.bumptech.glide.request.target.CustomTarget
import com.bumptech.glide.request.transition.Transition
import com.cyl.classifymenu.example.R

/**
 * The "TagContainer" tab: AndroidTagView's MainActivity (co.lujun.sample) as a page: five TagContainerLayouts
 * (avatars and crosses, a long list, RTL and selection, a short list, custom colors) and the add field.
 */
class LujunTagContainerFragment : Fragment() {

    private lateinit var mTagContainerLayout1: TagContainerLayout
    private lateinit var mTagContainerLayout2: TagContainerLayout
    private lateinit var mTagContainerLayout3: TagContainerLayout
    private lateinit var mTagContainerLayout4: TagContainerLayout
    private lateinit var mTagcontainerLayout5: TagContainerLayout

    /** The first container (avatars, crosses, long press to delete). */
    val firstContainer: TagContainerLayout
        get() = mTagContainerLayout1

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View =
        inflater.inflate(R.layout.lujun_content_main, container, false)

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        val list1 = ArrayList<String>()
        list1.add("Java")
        list1.add("C++")
        list1.add("Python")
        list1.add("Swift")
        list1.add("你好，这是一个TAG。你好，这是一个TAG。你好，这是一个TAG。你好，这是一个TAG。")
        list1.add("PHP")
        list1.add("JavaScript")
        list1.add("Html")
        list1.add("Welcome to use AndroidTagView!")

        val list2 = ArrayList<String>()
        list2.add("China")
        list2.add("USA")
        list2.add("Austria")
        list2.add("Japan")
        list2.add("Sudan")
        list2.add("Spain")
        list2.add("UK")
        list2.add("Germany")
        list2.add("Niger")
        list2.add("Poland")
        list2.add("Norway")
        list2.add("Uruguay")
        list2.add("Brazil")

        val list3 = arrayOf("Persian", "波斯语", "فارسی", "Hello", "你好", "سلام")
        val list4 = arrayOf("Adele", "Whitney Houston")

        val list5 = ArrayList<String>()
        list5.add("Custom Red Color")
        list5.add("Custom Blue Color")

        mTagContainerLayout1 = view.findViewById(R.id.tagcontainerLayout1)
        mTagContainerLayout2 = view.findViewById(R.id.tagcontainerLayout2)
        mTagContainerLayout3 = view.findViewById(R.id.tagcontainerLayout3)
        mTagContainerLayout4 = view.findViewById(R.id.tagcontainerLayout4)
        mTagcontainerLayout5 = view.findViewById(R.id.tagcontainerLayout5)

        mTagContainerLayout1.setDefaultImageDrawableID(R.drawable.lujun_yellow_avatar)

        // Set custom click listener
        mTagContainerLayout1.setOnTagClickListener(object : TagView.OnTagClickListener {
            override fun onTagClick(position: Int, text: String) {
                Toast.makeText(requireContext(), "click-position:$position, text:$text", Toast.LENGTH_SHORT).show()
            }

            override fun onTagLongClick(position: Int, text: String) {
                val dialog = AlertDialog.Builder(requireContext())
                    .setTitle("long click")
                    .setMessage("You will delete this tag!")
                    .setPositiveButton("Delete") { _, _ ->
                        if (position < mTagContainerLayout1.childCount) {
                            mTagContainerLayout1.removeTag(position)
                        }
                    }
                    .setNegativeButton("Cancel") { dialog, _ -> dialog.dismiss() }
                    .create()
                dialog.show()
            }

            override fun onSelectedTagDrag(position: Int, text: String) {}

            override fun onTagCrossClick(position: Int) {
                Toast.makeText(requireContext(), "Click TagView cross! position = $position", Toast.LENGTH_SHORT).show()
            }
        })

        mTagContainerLayout3.setOnTagClickListener(object : TagView.OnTagClickListener {
            override fun onTagClick(position: Int, text: String) {
                val selectedPositions = mTagContainerLayout3.getSelectedTagViewPositions()
                // deselect all tags when click on an unselected tag. Otherwise show toast.
                if (selectedPositions.isEmpty() || selectedPositions.contains(position)) {
                    Toast.makeText(requireContext(), "click-position:$position, text:$text", Toast.LENGTH_SHORT).show()
                } else {
                    // deselect all tags
                    for (i in selectedPositions) {
                        mTagContainerLayout3.deselectTagView(i)
                    }
                }
            }

            override fun onTagLongClick(position: Int, text: String) {
                mTagContainerLayout3.toggleSelectTagView(position)
                val selectedPositions = mTagContainerLayout3.getSelectedTagViewPositions()
                Toast.makeText(requireContext(), "selected-positions:$selectedPositions", Toast.LENGTH_SHORT).show()
            }

            override fun onSelectedTagDrag(position: Int, text: String) {
                val clip = ClipData.newPlainText("Text", text)
                val view: View = mTagContainerLayout3.getTagView(position)
                val shadow = View.DragShadowBuilder(view)
                view.startDragAndDrop(clip, shadow, java.lang.Boolean.TRUE, 0)
            }

            override fun onTagCrossClick(position: Int) {}
        })

        // After you set your own attributes for TagView, then set tag(s) or add tag(s)
        mTagContainerLayout1.setTags(list1)
        loadImages(list1)
        mTagContainerLayout2.setTags(list2)
        mTagContainerLayout3.setTags(*list3)
        mTagContainerLayout4.setTags(*list4)

        val colors = ArrayList<IntArray>()
        // int[] color = {backgroundColor, tagBorderColor, tagTextColor, tagSelectedBackgroundColor}
        val col1 = intArrayOf(Color.parseColor("#ff0000"), Color.parseColor("#000000"), Color.parseColor("#ffffff"), Color.parseColor("#999999"))
        val col2 = intArrayOf(Color.parseColor("#0000ff"), Color.parseColor("#000000"), Color.parseColor("#ffffff"), Color.parseColor("#999999"))
        colors.add(col1)
        colors.add(col2)

        mTagcontainerLayout5.setTags(list5, colors)
        val text = view.findViewById<EditText>(R.id.text_tag)
        val btnAddTag = view.findViewById<Button>(R.id.btn_add_tag)
        btnAddTag.setOnClickListener {
            mTagContainerLayout1.addTag(text.text.toString())
            // Add tag in the specified position: mTagContainerLayout1.addTag(text.text.toString(), 4)
        }
    }

    private fun loadImages(list: List<String>) {
        val avatars = arrayOf(
            "https://forums.oneplus.com/data/avatars/m/231/231279.jpg",
            "https://d1marr3m5x4iac.cloudfront.net/images/block/movies/17214/17214_aa.jpg",
            "https://lh3.googleusercontent.com/-KSI1bJ1aVS4/AAAAAAAAAAI/AAAAAAAAB9c/Vrgt6WyS5OU/il/photo.jpg",
        )
        for (i in list.indices) {
            val index = i
            Glide.with(mTagContainerLayout1.context)
                .asBitmap()
                .load(avatars[i % avatars.size])
                .apply(RequestOptions().override(85))
                .into(object : CustomTarget<Bitmap>() {
                    override fun onResourceReady(resource: Bitmap, transition: Transition<in Bitmap>?) {
                        mTagContainerLayout1.getTagView(index).setImage(resource)
                    }

                    override fun onLoadCleared(placeholder: Drawable?) {}
                })
            try {
                Thread.sleep(50)
            } catch (e: InterruptedException) {
                System.err.println(e.message)
            }
        }
    }
}
