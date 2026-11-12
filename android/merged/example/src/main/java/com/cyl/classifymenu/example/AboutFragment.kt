package com.cyl.classifymenu.example

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ScrollView
import android.widget.TextView
import androidx.fragment.app.Fragment

/**
 * The "About" tab: the libraries merged in this app, their sources and licenses.
 */
class AboutFragment : Fragment() {

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View {
        val padding = (16 * resources.displayMetrics.density).toInt()
        val text = TextView(requireContext()).apply {
            setText(R.string.about_text)
            setPadding(padding, padding, padding, padding)
            setTextIsSelectable(true)
        }
        return ScrollView(requireContext()).apply { addView(text) }
    }
}
