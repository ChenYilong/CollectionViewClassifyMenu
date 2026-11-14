package com.cyl.classifymenu.example.licrafter

import android.app.AlertDialog
import android.content.Context
import android.widget.EditText
import android.widget.LinearLayout
import com.cyl.classifymenu.example.R

/**
 * Asks for up to three tag names and returns a new group at the picture's center with the sample's directions.
 */
object TagEditDialog {

    fun createTagGroup(names: List<String>): TagGroupModel? {
        val titles = names.map { it.trim() }.filter { it.isNotEmpty() }
        if (titles.isEmpty()) return null
        val directions = DirectionUtils.defaultDirections(titles.size)
        return TagGroupModel(titles.zip(directions).map { TagModel(it.first, it.second) }.toMutableList(), 0.5f, 0.5f)
    }

    fun show(context: Context, onCreate: (TagGroupModel) -> Unit) {
        val fields = (1..3).map { index ->
            EditText(context).apply {
                hint = context.getString(R.string.licrafter_tag_hint, index)
                contentDescription = hint
                isSingleLine = true
            }
        }
        val padding = (20 * context.resources.displayMetrics.density).toInt()
        val content = LinearLayout(context).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(padding, padding / 2, padding, 0)
            fields.forEach { addView(it) }
        }
        AlertDialog.Builder(context)
            .setTitle(R.string.licrafter_title_edit)
            .setView(content)
            .setNegativeButton(R.string.licrafter_cancel, null)
            .setPositiveButton(R.string.licrafter_ok) { _, _ ->
                createTagGroup(fields.map { it.text.toString() })?.let(onCreate)
            }
            .show()
    }
}
