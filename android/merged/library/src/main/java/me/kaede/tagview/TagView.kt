package me.kaede.tagview

import com.cyl.classifymenu.R

import android.content.Context
import android.content.pm.ApplicationInfo
import android.graphics.Canvas
import android.graphics.drawable.Drawable
import android.graphics.drawable.GradientDrawable
import android.graphics.drawable.StateListDrawable
import android.util.AttributeSet
import android.util.TypedValue
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.LinearLayout
import android.widget.RelativeLayout
import android.widget.TextView

/**
 * Android TagView widget: lays tags out in lines, each tag a colored, rounded label with an optional delete
 * indicator.
 */
open class TagView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null,
    defStyleAttr: Int = 0,
    defStyleRes: Int = 0,
) : RelativeLayout(context, attrs, defStyleAttr, defStyleRes) {

    private var mWidth = 0
    private var lineMargin = 0
    private var tagMargin = 0
    private var textPaddingLeft = 0
    private var textPaddingRight = 0
    private var textPaddingTop = 0
    private var texPaddingBottom = 0
    private val mTags: MutableList<Tag> = ArrayList()
    private val mInflater: LayoutInflater
    private var mClickListener: OnTagClickListener? = null
    private var mDeleteListener: OnTagDeleteListener? = null

    /**
     * Single selection (kaedea/android-tagview PR #21, opt-in here so existing layouts keep their colors): a tap
     * checks the tag (`checkedLayoutColor`) and unchecks the others (their own colors). The checked positions are kept
     * in `checkedTagArray`.
     */
    var isSingleSelectionMode: Boolean = false

    /**
     * The background color of the checked tag in single selection mode (PR #21 used green).
     */
    var checkedLayoutColor: Int = android.graphics.Color.GREEN

    /**
     * The checked state of each tag position (single selection mode).
     */
    val checkedTagArray = android.util.SparseBooleanArray()

    init {
        LogUtil.v(TAG, "[init]")
        Constants.DEBUG = (context.applicationContext.applicationInfo.flags and ApplicationInfo.FLAG_DEBUGGABLE) != 0
        mInflater = context.getSystemService(Context.LAYOUT_INFLATER_SERVICE) as LayoutInflater
        // get AttributeSet
        val typeArray = context.obtainStyledAttributes(attrs, R.styleable.TagView, defStyleAttr, defStyleRes)
        lineMargin = typeArray.getDimension(R.styleable.TagView_lineMargin, ResolutionUtil.dpToPx(getContext(), Constants.DEFAULT_LINE_MARGIN).toFloat()).toInt()
        tagMargin = typeArray.getDimension(R.styleable.TagView_tagMargin, ResolutionUtil.dpToPx(getContext(), Constants.DEFAULT_TAG_MARGIN).toFloat()).toInt()
        textPaddingLeft = typeArray.getDimension(R.styleable.TagView_textPaddingLeft, ResolutionUtil.dpToPx(getContext(), Constants.DEFAULT_TAG_TEXT_PADDING_LEFT).toFloat()).toInt()
        textPaddingRight = typeArray.getDimension(R.styleable.TagView_textPaddingRight, ResolutionUtil.dpToPx(getContext(), Constants.DEFAULT_TAG_TEXT_PADDING_RIGHT).toFloat()).toInt()
        textPaddingTop = typeArray.getDimension(R.styleable.TagView_textPaddingTop, ResolutionUtil.dpToPx(getContext(), Constants.DEFAULT_TAG_TEXT_PADDING_TOP).toFloat()).toInt()
        texPaddingBottom = typeArray.getDimension(R.styleable.TagView_textPaddingBottom, ResolutionUtil.dpToPx(getContext(), Constants.DEFAULT_TAG_TEXT_PADDING_BOTTOM).toFloat()).toInt()
        typeArray.recycle()
        mWidth = ResolutionUtil.getScreenWidth(context)
    }


    override fun onDraw(canvas: Canvas) {
        super.onDraw(canvas)
        // View#onDraw is disabled in a view group; View#setWillNotDraw(false) enables it.
        LogUtil.v(TAG, "[onDraw]")
    }

    override fun onVisibilityChanged(changedView: View, visibility: Int) {
        LogUtil.v(TAG, "[onVisibilityChanged]")
        super.onVisibilityChanged(changedView, visibility)
    }

    override fun onAttachedToWindow() {
        super.onAttachedToWindow()
        LogUtil.v(TAG, "[onAttachedToWindow]")
    }

    /**
     * Binds every tag to a view (reusing the views of the previous pass: issues #13, #17, #19, android-tagview inflated
     * every tag again on each add or remove), measures each view's real width, then arranges the lines.
     */
    private fun drawTags() {
        LogUtil.v(TAG, "[drawTags]visibility = " + (visibility == View.VISIBLE))
        if (visibility != View.VISIBLE) return
        LogUtil.d(TAG, "[drawTags]add tags, tag count = " + mTags.size)
        val reusable = ArrayList<View>(childCount)
        for (index in 0 until childCount) reusable.add(getChildAt(index))
        removeAllViews()
        tagWidths.clear()
        for ((position, tag) in mTags.withIndex()) {
            val tagLayout = reusable.getOrNull(position) ?: mInflater.inflate(R.layout.tagview_item, this, false)
            if (tagLayout.id == View.NO_ID) tagLayout.id = View.generateViewId()
            bindTag(tagLayout, position, tag)
            addView(tagLayout, LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT))
        }
        arrangeTags(mWidth)
    }

    /**
     * Sets a tag view's appearance, listeners and measured width (`tagWidths`).
     */
    private fun bindTag(tagLayout: View, position: Int, tag: Tag) {
        val checked = isSingleSelectionMode && checkedTagArray.get(position, false)
        tagLayout.background = getSelector(tag, if (checked) checkedLayoutColor else tag.layoutColor)
        // tag text
        val tagView = tagLayout.findViewById<TextView>(R.id.tv_tag_item_contain)
        tagView.text = tag.text
        val params = tagView.layoutParams as LinearLayout.LayoutParams
        params.setMargins(textPaddingLeft, textPaddingTop, textPaddingRight, texPaddingBottom)
        tagView.layoutParams = params
        tagView.setTextColor(if (checked) checkedTextColor ?: tag.tagTextColor else tag.tagTextColor)
        tagView.setTextSize(TypedValue.COMPLEX_UNIT_SP, tag.tagTextSize)
        tagLayout.setOnClickListener {
            // PR #21: only an enabled, clickable tag reacts; single selection checks it and unchecks the others.
            if (!tagLayout.isEnabled || !tagLayout.isClickable) return@setOnClickListener
            if (isSingleSelectionMode && !checkedTagArray.get(position)) setTagChecked(position, true)
            mClickListener?.onTagClick(position, tag)
        }
        // PR #22 / #21: a tag that is not clickable is disabled.
        tagLayout.isEnabled = tag.clickable
        tagLayout.isClickable = tag.clickable
        // deletable text
        val deletableView = tagLayout.findViewById<TextView>(R.id.tv_tag_item_delete)
        if (tag.isDeletable) {
            deletableView.visibility = View.VISIBLE
            deletableView.text = tag.deleteIcon
            val offset = ResolutionUtil.dpToPx(context, 2f)
            deletableView.setPadding(offset, textPaddingTop, textPaddingRight + offset, texPaddingBottom)
            deletableView.setTextColor(tag.deleteIndicatorColor)
            deletableView.setTextSize(TypedValue.COMPLEX_UNIT_SP, tag.deleteIndicatorSize)
            deletableView.setOnClickListener {
                this@TagView.remove(position)
                mDeleteListener?.onTagDeleted(position, tag)
            }
        } else {
            deletableView.visibility = View.GONE
            deletableView.setOnClickListener(null)
        }
        // The real width of the tag (issue #9: the text width plus paddings came out a few pixels short of what the
        // TextView needs, so the text was cut with "…" although it fitted).
        tagLayout.measure(MeasureSpec.makeMeasureSpec(0, MeasureSpec.UNSPECIFIED), MeasureSpec.makeMeasureSpec(0, MeasureSpec.UNSPECIFIED))
        tagWidths[position] = tagLayout.measuredWidth.toFloat()
    }

    /**
     * Places the tags in lines of at most `width` pixels with RelativeLayout rules (no view is inflated or bound again),
     * so the lines follow the view's real width (issues #11, #14, #20, #24).
     */
    private fun arrangeTags(width: Int) {
        arrangedWidth = width
        var total = (paddingLeft + paddingRight).toFloat()
        var indexBottom = 0 // the tag to add below
        var indexHeader = 0 // the header tag of this line
        for (position in 0 until childCount) {
            val tagLayout = getChildAt(position)
            val tag = mTags[position]
            val tagWidth = tagWidths[position] ?: 0f
            val tagParams = tagLayout.layoutParams as LayoutParams
            for (rule in intArrayOf(BELOW, ALIGN_TOP, ALIGN_PARENT_START, END_OF, RIGHT_OF)) tagParams.removeRule(rule)
            tagParams.marginStart = 0
            tagParams.leftMargin = 0
            // add the margin of each line
            tagParams.bottomMargin = lineMargin
            val fits = width > total + tagMargin + tagWidth + ResolutionUtil.dpToPx(context, Constants.LAYOUT_WIDTH_OFFSET)
            if (position == 0 || (!isSingleLine && !fits)) {
                // a new line; the first tag has no line above it (PR #27: a first tag wider than the view was laid out
                // below itself and disappeared)
                if (position != 0) tagParams.addRule(BELOW, getChildAt(indexBottom).id)
                // PR #21 (right-to-left languages, issue #28): a line starts at the start edge, not always the left
                tagParams.addRule(ALIGN_PARENT_START)
                total = (paddingLeft + paddingRight).toFloat()
                indexBottom = position
                indexHeader = position
            } else {
                // same line, after the previous tag in the reading direction (END_OF, issue #28)
                tagParams.addRule(ALIGN_TOP, getChildAt(indexHeader).id)
                tagParams.addRule(END_OF, getChildAt(position - 1).id)
                tagParams.marginStart = tagMargin
                total += tagMargin
                if (mTags[position - 1].tagTextSize < tag.tagTextSize) indexBottom = position
            }
            total += tagWidth
            tagLayout.layoutParams = tagParams
        }
    }

    override fun onSizeChanged(w: Int, h: Int, oldw: Int, oldh: Int) {
        super.onSizeChanged(w, h, oldw, oldh)
        if (!hasMaxWidth && w > 0 && w != mWidth) {
            mWidth = w
            if (w != arrangedWidth) post { arrangeTags(mWidth); requestLayout() }
        }
    }

    override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
        // The width the parent offers (wrap_content included, issue #14), known before the children are measured.
        val offered = MeasureSpec.getSize(widthMeasureSpec)
        if (!hasMaxWidth && MeasureSpec.getMode(widthMeasureSpec) != MeasureSpec.UNSPECIFIED && offered > 0 && offered != arrangedWidth) {
            mWidth = offered
            arrangeTags(offered)
        }
        super.onMeasure(widthMeasureSpec, heightMeasureSpec)
    }

    /**
     * The width the lines may take, in pixels (issue #24's `setMaxWith`): fixes it instead of following the view's
     * width, for example in list items measured before they have a width. 0 follows the view again.
     */
    fun setMaxWidth(width: Int) {
        hasMaxWidth = width > 0
        mWidth = if (width > 0) width else ResolutionUtil.getScreenWidth(context)
        arrangeTags(mWidth)
        requestLayout()
    }

    /**
     * Replaces the tag at `position` and updates only its view (issues #10, #16, #19: changing one tag's colors no
     * longer needs removing and adding every tag).
     */
    fun replaceAtPosition(position: Int, tag: Tag) {
        if (position !in mTags.indices) return
        mTags[position] = tag
        val view = getChildAt(position) ?: return drawTags()
        bindTag(view, position, tag)
        arrangeTags(mWidth)
        requestLayout()
    }

    /**
     * Checks or unchecks the tag at `position` (single selection mode: checking unchecks the others), shown with
     * `checkedLayoutColor` and `checkedTextColor` (issue #16).
     */
    fun setTagChecked(position: Int, checked: Boolean) {
        if (position !in mTags.indices) return
        if (checked && isSingleSelectionMode) {
            for (index in mTags.indices) if (index != position && checkedTagArray.get(index)) {
                checkedTagArray.put(index, false)
                getChildAt(index)?.let { bindTag(it, index, mTags[index]) }
            }
        }
        checkedTagArray.put(position, checked)
        getChildAt(position)?.let { bindTag(it, position, mTags[position]) }
    }

    /**
     * The text color of a checked tag (issue #16); null keeps the tag's own text color.
     */
    var checkedTextColor: Int? = null

    /**
     * Every tag on one line, never wrapped (issue #29): put the TagView in a HorizontalScrollView to scroll them.
     */
    var isSingleLine: Boolean = false
        set(value) {
            field = value
            arrangeTags(mWidth)
            requestLayout()
        }

    private val tagWidths = HashMap<Int, Float>()
    private var arrangedWidth = -1
    private var hasMaxWidth = false

    private fun getSelector(tag: Tag, layoutColor: Int = tag.layoutColor): Drawable {
        tag.background?.takeIf { layoutColor == tag.layoutColor }?.let { return it }
        val states = StateListDrawable()
        val gdNormal = GradientDrawable()
        gdNormal.setColor(layoutColor)
        gdNormal.cornerRadius = tag.radius
        if (tag.layoutBorderSize > 0) {
            gdNormal.setStroke(ResolutionUtil.dpToPx(context, tag.layoutBorderSize), tag.layoutBorderColor)
        }
        val gdPress = GradientDrawable()
        gdPress.setColor(tag.layoutColorPress)
        gdPress.cornerRadius = tag.radius
        // state_pressed must be added first, or it never takes effect
        states.addState(intArrayOf(android.R.attr.state_pressed), gdPress)
        states.addState(intArrayOf(), gdNormal)
        return states
    }

    fun addTag(tag: Tag) {
        LogUtil.v(TAG, "[addTag]")
        mTags.add(tag)
        drawTags()
    }

    fun addTags(tags: Array<String>?) {
        LogUtil.v(TAG, "[addTags]")
        if (tags == null || tags.isEmpty()) return
        for (item in tags) {
            mTags.add(Tag(item))
        }
        drawTags()
    }

    fun addTags(tagList: List<Tag>?) {
        LogUtil.v(TAG, "[addTags]")
        if (tagList == null || tagList.isEmpty()) return
        mTags.addAll(tagList)
        drawTags()
    }

    fun getTags(): List<Tag> = mTags

    fun remove(position: Int) {
        LogUtil.v(TAG, "[remove]position = $position")
        mTags.removeAt(position)
        drawTags()
    }

    fun removeAllTags() {
        LogUtil.v(TAG, "[removeAllTags]")
        mTags.clear()
        drawTags()
    }

    fun getLineMargin(): Int = lineMargin

    fun setLineMargin(lineMargin: Float) {
        this.lineMargin = ResolutionUtil.dpToPx(context, lineMargin)
    }

    fun getTagMargin(): Int = tagMargin

    fun setTagMargin(tagMargin: Float) {
        this.tagMargin = ResolutionUtil.dpToPx(context, tagMargin)
    }

    fun getTextPaddingLeft(): Int = textPaddingLeft

    fun setTextPaddingLeft(textPaddingLeft: Float) {
        this.textPaddingLeft = ResolutionUtil.dpToPx(context, textPaddingLeft)
    }

    fun getTextPaddingRight(): Int = textPaddingRight

    fun setTextPaddingRight(textPaddingRight: Float) {
        this.textPaddingRight = ResolutionUtil.dpToPx(context, textPaddingRight)
    }

    fun getTextPaddingTop(): Int = textPaddingTop

    fun setTextPaddingTop(textPaddingTop: Float) {
        this.textPaddingTop = ResolutionUtil.dpToPx(context, textPaddingTop)
    }

    fun getTexPaddingBottom(): Int = texPaddingBottom

    fun setTexPaddingBottom(texPaddingBottom: Float) {
        this.texPaddingBottom = ResolutionUtil.dpToPx(context, texPaddingBottom)
    }

    fun setOnTagClickListener(clickListener: OnTagClickListener?) {
        mClickListener = clickListener
    }

    fun setOnTagDeleteListener(deleteListener: OnTagDeleteListener?) {
        mDeleteListener = deleteListener
    }

    companion object {
        const val TAG = "TagView"
    }
}
