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

    override fun onSizeChanged(w: Int, h: Int, oldw: Int, oldh: Int) {
        super.onSizeChanged(w, h, oldw, oldh)
        LogUtil.v(TAG, "[onSizeChanged]w = $w")
        mWidth = w
    }

    override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
        super.onMeasure(widthMeasureSpec, heightMeasureSpec)
        LogUtil.v(TAG, "[onMeasure]getMeasuredWidth = $measuredWidth")
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

    private fun drawTags() {
        LogUtil.v(TAG, "[drawTags]visibility = " + (visibility == View.VISIBLE))
        if (visibility != View.VISIBLE) return
        LogUtil.v(TAG, "[drawTags]mWidth = $mWidth")
        LogUtil.d(TAG, "[drawTags]add tags, tag count = " + mTags.size)
        // clear all tags
        removeAllViews()
        // layout padding left & layout padding right
        var total = (paddingLeft + paddingRight).toFloat()
        var listIndex = 1 // list index
        var indexBottom = 1 // the tag to add below
        var indexHeader = 1 // the header tag of this line
        var tagPre: Tag? = null
        for (item in mTags) {
            val position = listIndex - 1
            val tag = item
            // inflate tag layout
            val tagLayout = mInflater.inflate(R.layout.tagview_item, null)
            tagLayout.id = listIndex
            tagLayout.background = getSelector(tag)
            // tag text
            val tagView = tagLayout.findViewById<TextView>(R.id.tv_tag_item_contain)
            tagView.text = tag.text
            val params = tagView.layoutParams as LinearLayout.LayoutParams
            params.setMargins(textPaddingLeft, textPaddingTop, textPaddingRight, texPaddingBottom)
            tagView.layoutParams = params
            tagView.setTextColor(tag.tagTextColor)
            tagView.setTextSize(TypedValue.COMPLEX_UNIT_SP, tag.tagTextSize)
            tagLayout.setOnClickListener { mClickListener?.onTagClick(position, tag) }
            // calculate the tag layout width
            var tagWidth = tagView.paint.measureText(tag.text) + textPaddingLeft + textPaddingRight
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
                tagWidth += deletableView.paint.measureText(tag.deleteIcon) + deletableView.paddingLeft + deletableView.paddingRight
            } else {
                deletableView.visibility = View.GONE
            }
            val tagParams = LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT)
            // add the margin of each line
            tagParams.bottomMargin = lineMargin
            if (mWidth <= total + tagMargin + tagWidth + ResolutionUtil.dpToPx(context, Constants.LAYOUT_WIDTH_OFFSET)) {
                // needs a new line
                tagParams.addRule(BELOW, indexBottom)
                // reset total (layout padding left & layout padding right)
                total = (paddingLeft + paddingRight).toFloat()
                indexBottom = listIndex
                indexHeader = listIndex
            } else {
                // same line
                tagParams.addRule(ALIGN_TOP, indexHeader)
                // not the header of the line
                if (listIndex != indexHeader) {
                    tagParams.addRule(RIGHT_OF, listIndex - 1)
                    tagParams.leftMargin = tagMargin
                    total += tagMargin
                    if (tagPre != null && tagPre.tagTextSize < tag.tagTextSize) {
                        indexBottom = listIndex
                    }
                }
            }
            total += tagWidth
            addView(tagLayout, tagParams)
            tagPre = tag
            listIndex++
        }
    }

    private fun getSelector(tag: Tag): Drawable {
        tag.background?.let { return it }
        val states = StateListDrawable()
        val gdNormal = GradientDrawable()
        gdNormal.setColor(tag.layoutColor)
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
