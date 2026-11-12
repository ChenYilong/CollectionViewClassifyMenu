package com.licrafter.sample.views

import android.content.Context
import android.util.AttributeSet
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import android.widget.ImageView
import com.licrafter.sample.R
import com.licrafter.sample.model.TagGroupModel
import com.licrafter.sample.utils.AnimatorUtils
import com.licrafter.sample.utils.DirectionUtils
import com.licrafter.sample.utils.SamplePictures
import com.licrafter.tagview.TagAdapter
import com.licrafter.tagview.TagViewGroup
import com.licrafter.tagview.views.ITagView
import com.licrafter.tagview.views.RippleView
import com.licrafter.tagview.views.TagTextView

/**
 * A square picture with tag groups on it (layout_tag_imageview). A tap on the picture shows or hides the groups.
 * While editing, a group's dot can be dragged, a tapped tag turns to the next direction, and the data follows.
 */
class TagImageView @JvmOverloads constructor(context: Context, attrs: AttributeSet? = null) : FrameLayout(context, attrs) {

    val imageView = ImageView(context).apply { scaleType = ImageView.ScaleType.CENTER_CROP }
    private val groupViews = ArrayList<TagViewGroup>()
    private val groups = ArrayList<TagGroupModel>()
    private var groupsHidden = false

    var editing = false
        set(value) {
            field = value
            rebuildGroups()
        }

    /** The dot of group `index` was tapped. */
    var onCircleClick: ((index: Int) -> Unit)? = null

    /** Tag `tagIndex` of group `index` was tapped (not while editing: then it turns). */
    var onTagClick: ((index: Int, tagIndex: Int, title: String) -> Unit)? = null

    /** Group `index` was long-pressed. */
    var onLongPress: ((index: Int) -> Unit)? = null

    init {
        addView(imageView, LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT))
        imageView.setOnClickListener { if (!editing) toggleGroups() }
        imageView.contentDescription = SamplePictures.description(context, 0)
        imageView.accessibilityDelegate = null
        imageView.isClickable = true
        imageView.setTag(R.id.tag_hint, context.getString(R.string.toggle_hint))
    }

    override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
        // Square, as wide as it is given.
        super.onMeasure(widthMeasureSpec, MeasureSpec.makeMeasureSpec(MeasureSpec.getSize(widthMeasureSpec), MeasureSpec.EXACTLY))
    }

    fun setPicture(index: Int, size: Int = 750) {
        imageView.setImageBitmap(SamplePictures.picture(index, size))
        imageView.contentDescription = SamplePictures.description(context, index)
    }

    fun setTagGroups(models: List<TagGroupModel>) {
        groups.clear()
        models.forEach { groups.add(it.copy()) }
        rebuildGroups()
    }

    fun getTagGroups(): List<TagGroupModel> = groups.map { it.copy() }

    fun addTagGroup(model: TagGroupModel) {
        groups.add(model.copy())
        rebuildGroups()
    }

    fun removeTagGroup(index: Int) {
        if (index !in groups.indices) return
        groups.removeAt(index)
        rebuildGroups()
    }

    fun toggleGroups() {
        groupsHidden = !groupsHidden
        for (group in groupViews) {
            if (groupsHidden) group.startHideAnimator() else group.startShowAnimator()
        }
    }

    private fun rebuildGroups() {
        groupViews.forEach { removeView(it) }
        groupViews.clear()
        groups.forEachIndexed { index, model -> groupViews.add(makeGroup(index, model)) }
    }

    private fun makeGroup(index: Int, model: TagGroupModel): TagViewGroup {
        val group = TagViewGroup(context)
        group.setTagAdapter(object : TagAdapter() {
            override fun getCount(): Int = model.tags.size + 1

            override fun getItem(position: Int): ITagView {
                if (position == model.tags.size) return RippleView(context)
                val tag = model.tags[position]
                return TagTextView(context).apply {
                    text = tag.name
                    contentDescription = tag.name
                    setDirection(tag.direction)
                }
            }
        })
        group.setPercent(model.percentX, model.percentY)
        group.setShowAnimator(AnimatorUtils.getTagShowAnimator(group)).setHideAnimator(AnimatorUtils.getTagHideAnimator(group))
        group.setOnTagGroupClickListener(object : TagViewGroup.OnTagGroupClickListener {
            override fun onCircleClick(container: TagViewGroup) {
                onCircleClick?.invoke(index)
            }

            override fun onTagClick(container: TagViewGroup, tag: ITagView, position: Int) {
                if (editing) {
                    val model2 = model.tags[position]
                    model2.direction = DirectionUtils.next(model2.direction)
                    tag.setDirection(model2.direction)
                    container.requestLayout()
                } else {
                    onTagClick?.invoke(index, position, model.tags[position].name)
                }
            }

            override fun onLongPress(container: TagViewGroup) {
                onLongPress?.invoke(index)
            }
        })
        if (editing) {
            group.setOnTagGroupDragListener(object : TagViewGroup.OnTagGroupDragListener {
                override fun onDrag(container: TagViewGroup, percentX: Float, percentY: Float) {
                    model.percentX = percentX
                    model.percentY = percentY
                }
            })
        }
        group.contentDescription = model.tags.joinToString("，") { it.name }
        group.importantForAccessibility = View.IMPORTANT_FOR_ACCESSIBILITY_YES
        addView(group, LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT))
        if (groupsHidden) group.setTagAlpha(0f)
        return group
    }
}
