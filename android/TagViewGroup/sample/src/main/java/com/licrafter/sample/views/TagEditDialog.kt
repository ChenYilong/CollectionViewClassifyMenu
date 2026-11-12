package com.licrafter.sample.views

import android.app.AlertDialog
import android.content.Context
import android.widget.EditText
import android.widget.LinearLayout
import com.licrafter.sample.R
import com.licrafter.sample.model.TagGroupModel
import com.licrafter.sample.model.TagModel
import com.licrafter.sample.utils.DirectionUtils

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
                hint = context.getString(R.string.tag_hint, index)
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
            .setTitle(R.string.title_edit)
            .setView(content)
            .setNegativeButton(R.string.cancel, null)
            .setPositiveButton(R.string.ok) { _, _ ->
                createTagGroup(fields.map { it.text.toString() })?.let(onCreate)
            }
            .show()
    }
}
