package com.cyl.classifymenu

import android.annotation.SuppressLint
import android.content.Context
import android.graphics.drawable.Drawable
import android.util.AttributeSet
import android.view.MotionEvent
import android.view.ViewGroup
import android.widget.ImageView
import kotlin.math.abs

/**
 * `CYLImageTagView`: a picture with tag groups (TagViewGroup's sample): groups from models, edit mode (drag the dots,
 * tap a tag to turn it), show / hide all groups, groups moved apart vertically when they would overlap, and event
 * handlers. Lengths are dp.
 */
@SuppressLint("ClickableViewAccessibility")
class CYLImageTagView @JvmOverloads constructor(context: Context, attrs: AttributeSet? = null) : ViewGroup(context, attrs) {

    private val density: Float get() = resources.displayMetrics.density

    /**
     * The picture, filling the view (center crop).
     */
    val imageView: ImageView = ImageView(context).apply {
        scaleType = ImageView.ScaleType.CENTER_CROP
        importantForAccessibility = IMPORTANT_FOR_ACCESSIBILITY_YES
        setOnClickListener { handleImageTap() }
        isClickable = false
    }

    private val groups = ArrayList<CYLImageTagGroup>()
    private val views = ArrayList<CYLImageTagGroupView>()

    init {
        clipChildren = true
        addView(imageView)
        updatePictureAccessibility()
    }

    /**
     * The picture (`imageView`'s drawable).
     */
    var image: Drawable?
        get() = imageView.drawable
        set(value) {
            imageView.setImageDrawable(value)
            updatePictureAccessibility()
        }

    /**
     * The groups (copies); setting them replaces every group.
     */
    var tagGroups: List<CYLImageTagGroup>
        get() = groups.toList()
        set(value) {
            removeAllTagGroups()
            value.forEach { addTagGroup(it) }
        }

    /**
     * `-addTagGroup:`: adds a copy of the group and its view.
     */
    fun addTagGroup(group: CYLImageTagGroup) {
        val model = group.copy()
        val view = CYLImageTagGroupView(context)
        view.delegate = groupDelegate
        view.tags = model.tags
        view.percentPosition = model.percentPosition
        view.draggable = editing
        view.showsRipple = !editing
        applyAccessibility(view)
        groups.add(model)
        views.add(view)
        groupConfiguration?.invoke(view, views.size - 1)
        addView(view)
        requestLayout()
    }

    /**
     * `-removeTagGroupAtIndex:`.
     */
    fun removeTagGroupAtIndex(index: Int) {
        if (index !in views.indices) return
        removeView(views.removeAt(index))
        groups.removeAt(index)
    }

    /**
     * `-removeAllTagGroups`.
     */
    fun removeAllTagGroups() {
        views.forEach { removeView(it) }
        views.clear()
        groups.clear()
    }

    /**
     * The group views, in order.
     */
    val groupViews: List<CYLImageTagGroupView> get() = views.toList()

    /**
     * Edit mode: dots can be dragged and a tap turns a tag; no ripple.
     */
    var editing: Boolean = false
        set(value) {
            field = value
            requestLayout()
            for (view in views) {
                view.draggable = value
                view.showsRipple = !value
                applyAccessibility(view)
            }
        }

    /**
     * `isEditing`.
     */
    val isEditing: Boolean get() = editing

    /**
     * `-toggleTagGroupsAnimated:`: shows hidden groups and hides shown ones.
     */
    fun toggleTagGroupsAnimated(animated: Boolean) {
        for (view in views) {
            if (view.isGroupHidden) view.showAnimated(animated, null) else view.hideAnimated(animated, null)
        }
    }

    /**
     * Called for every new group view, to style it.
     */
    var groupConfiguration: ((groupView: CYLImageTagGroupView, groupIndex: Int) -> Unit)? = null

    // MARK: Events

    var imageTapHandler: (() -> Unit)? = null
        set(value) {
            field = value
            updatePictureAccessibility()
        }
    var circleTapHandler: ((groupIndex: Int) -> Unit)? = null
    var tagTapHandler: ((groupIndex: Int, tagIndex: Int, tag: CYLImageTag) -> Unit)? = null
    var longPressHandler: ((groupIndex: Int) -> Unit)? = null
    var dragHandler: ((groupIndex: Int, percentPosition: CYLPoint) -> Unit)? = null

    // MARK: Accessibility

    var imageAccessibilityHint: String? = null
        set(value) {
            field = value
            updatePictureAccessibility()
        }

    var longPressAccessibilityActionName: String? = null
        set(value) {
            field = value
            views.forEach { it.longPressAccessibilityActionName = value }
        }

    private fun updatePictureAccessibility() {
        val label = (imageView.drawable as? CYLBadgeDrawable)?.accessibilityLabel
        imageView.contentDescription = if (!label.isNullOrEmpty()) label else CYLMenuLocalizedString("CYLImageTagPicture", "A picture with tags")
        imageView.isClickable = imageTapHandler != null
        CYLAccessibilityNode.apply(imageView, imageTapHandler != null, null, imageAccessibilityHint, emptyList())
    }

    private fun applyAccessibility(view: CYLImageTagGroupView) {
        view.longPressAccessibilityActionName = longPressAccessibilityActionName
        view.tagAccessibilityHint = if (editing) CYLMenuLocalizedString("CYLImageTagTurnHint", "Hint of a tag in edit mode") else null
    }

    // MARK: Layout

    override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
        val width = MeasureSpec.getSize(widthMeasureSpec)
        val height = MeasureSpec.getSize(heightMeasureSpec)
        setMeasuredDimension(width, height)
        val w = MeasureSpec.makeMeasureSpec(width, MeasureSpec.EXACTLY)
        val h = MeasureSpec.makeMeasureSpec(height, MeasureSpec.EXACTLY)
        for (index in 0 until childCount) getChildAt(index).measure(w, h)
    }

    override fun onLayout(changed: Boolean, l: Int, t: Int, r: Int, b: Int) {
        for (index in 0 until childCount) getChildAt(index).layout(0, 0, r - l, b - t)
        separateGroups()
    }

    private fun intersects(a: CYLRect, b: CYLRect): Boolean = a.x < b.maxX && b.x < a.maxX && a.y < b.maxY && b.y < a.maxY

    /**
     * Moves each group's dot up or down by the least distance that keeps it clear of the groups before it (not while
     * editing, where the dots stay where they are dragged).
     */
    private fun separateGroups() {
        val spacing = 4f
        val placed = ArrayList<CYLRect>()
        val height = this.height / density
        for (view in views) {
            view.displayOffset = CYLPoint()
            view.layoutGroup()
            if (editing || view.isGroupHidden) {
                placed.add(view.occupiedFrame)
                continue
            }
            val frame = view.occupiedFrame
            fun clear(dy: Float): Boolean {
                val moved = CYLRect(frame.x, frame.y + dy, frame.width, frame.height)
                if (moved.y < 0 || moved.maxY > height) return false
                val grown = CYLRect(moved.x, moved.y - spacing / 2, moved.width, moved.height + spacing)
                return placed.none { intersects(grown, it) }
            }
            if (clear(0f)) {
                placed.add(frame)
                continue
            }
            var best = Float.MAX_VALUE
            for (other in placed) {
                for (dy in listOf(other.maxY + spacing - frame.y, other.y - spacing - frame.maxY)) {
                    if (abs(dy) < abs(best) && clear(dy)) best = dy
                }
            }
            if (best != Float.MAX_VALUE) {
                view.displayOffset = CYLPoint(0f, best)
                view.layoutGroup()
            }
            placed.add(view.occupiedFrame)
        }
    }

    // MARK: Touches

    override fun onTouchEvent(event: MotionEvent): Boolean {
        if (event.actionMasked == MotionEvent.ACTION_DOWN) return true
        if (event.actionMasked == MotionEvent.ACTION_UP) handleImageTap()
        return true
    }

    private fun handleImageTap() {
        imageTapHandler?.invoke()
    }

    private val groupDelegate = object : CYLImageTagGroupViewDelegate {
        override fun groupViewDidTapCircle(groupView: CYLImageTagGroupView) {
            val index = views.indexOf(groupView)
            if (index >= 0) circleTapHandler?.invoke(index)
        }

        override fun groupViewDidTapTagAtIndex(groupView: CYLImageTagGroupView, index: Int) {
            val groupIndex = views.indexOf(groupView)
            if (groupIndex < 0 || index !in groups[groupIndex].tags.indices) return
            val tag = groups[groupIndex].tags[index]
            if (editing) {
                tag.direction = CYLImageTagDirectionNext(tag.direction)
                groupView.tags = groups[groupIndex].tags
                groupView.tagViews.getOrNull(index)?.let { view ->
                    post { view.sendAccessibilityEvent(android.view.accessibility.AccessibilityEvent.TYPE_VIEW_FOCUSED) }
                }
            }
            tagTapHandler?.invoke(groupIndex, index, tag)
        }

        override fun groupViewDidLongPress(groupView: CYLImageTagGroupView) {
            val index = views.indexOf(groupView)
            if (index >= 0) longPressHandler?.invoke(index)
        }

        override fun groupViewDidDragToPercentPosition(groupView: CYLImageTagGroupView, percentPosition: CYLPoint) {
            val index = views.indexOf(groupView)
            if (index < 0) return
            groups[index].percentPosition = percentPosition
            dragHandler?.invoke(index, percentPosition)
        }

        override fun handlesLongPress(): Boolean = true
    }
}
