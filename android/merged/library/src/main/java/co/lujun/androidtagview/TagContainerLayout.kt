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

package co.lujun.androidtagview

import com.cyl.classifymenu.R

import android.content.Context
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.RectF
import android.graphics.Typeface
import android.util.AttributeSet
import android.view.Gravity
import android.view.MotionEvent
import android.view.View
import android.view.ViewGroup
import androidx.annotation.DrawableRes
import androidx.customview.widget.ViewDragHelper
import co.lujun.androidtagview.Utils.dp2px
import co.lujun.androidtagview.Utils.sp2px
import kotlin.math.abs
import kotlin.math.ceil
import kotlin.math.max
import kotlin.math.min

/**
 * Author: lujun(http://blog.lujun.co)
 * Date: 2015-12-30 17:14
 */
open class TagContainerLayout @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null,
    defStyleAttr: Int = 0,
) : ViewGroup(context, attrs, defStyleAttr) {

    /** Vertical interval, default 5(dp) */
    private var mVerticalInterval = 0

    /** The list to store the tags color info */
    private var mColorArrayList: List<IntArray>? = null

    /** Horizontal interval, default 5(dp) */
    private var mHorizontalInterval = 0

    /** TagContainerLayout border width(default 0.5dp) */
    private var mBorderWidth = 0.5f

    /** TagContainerLayout border radius(default 10.0dp) */
    private var mBorderRadius = 10.0f

    /** The sensitive of the ViewDragHelper(default 1.0f, normal) */
    private var mSensitivity = 1.0f

    /** TagView average height */
    private var mChildHeight = 0

    /** TagContainerLayout border color(default #22FF0000) */
    private var mBorderColor = Color.parseColor("#22FF0000")

    /** TagContainerLayout background color(default #11FF0000) */
    private var mBackgroundColor = Color.parseColor("#11FF0000")

    /** The container layout gravity(default left) */
    private var mGravity = Gravity.LEFT

    /** The max line count of TagContainerLayout */
    private var mMaxLines = 0

    /**
     * Every tag on one line (issues #42 / #106 / #115): measured as wide as its tags when the width is unspecified,
     * as in a HorizontalScrollView, which then scrolls them.
     */
    private var mSingleLine = false

    /**
     * The lines the tags need, before `mMaxLines` limits the height (issues #58 / #63: the rest scrolls).
     */
    private var mTotalLines = 0

    /**
     * The line of each tag (`getVisibleTagCount`, issue #80).
     */
    private var mViewLines = IntArray(0)

    private val mTouchSlop = android.view.ViewConfiguration.get(context).scaledTouchSlop
    private var mScrollLastY = 0f
    private var mScrollingContent = false

    /** The max length for TagView(default max length 23) */
    private var mTagMaxLength = 23

    /** TagView Border width(default 0.5dp) */
    private var mTagBorderWidth = 0.5f

    /** TagView Border radius(default 15.0dp) */
    private var mTagBorderRadius = 15.0f

    /** TagView Text size(default 14sp) */
    private var mTagTextSize = 14f

    /** Text direction(support:TEXT_DIRECTION_RTL & TEXT_DIRECTION_LTR, default TEXT_DIRECTION_LTR) */
    private var mTagTextDirection = View.TEXT_DIRECTION_LTR

    /** Horizontal padding for TagView, include left & right padding(left & right padding are equal, default 10dp) */
    private var mTagHorizontalPadding = 10

    /** Vertical padding for TagView, include top & bottom padding(top & bottom padding are equal, default 8dp) */
    private var mTagVerticalPadding = 8

    /** TagView border color(default #88F44336) */
    private var mTagBorderColor = Color.parseColor("#88F44336")

    /** TagView background color(default #33F44336) */
    private var mTagBackgroundColor = Color.parseColor("#33F44336")

    /** Selected TagView background color(default #33FF7669) */
    private var mSelectedTagBackgroundColor = Color.parseColor("#33FF7669")

    /**
     * The text color of selected tags (issues #29 / #114, `tag_selected_text_color`); null keeps the text color.
     */
    private var mSelectedTagTextColor: Int? = null

    /**
     * Whether the selected background was set (XML or code): it then wins over the theme's (issues #29 / #114).
     */
    private var mSelectedColorSet = false

    /**
     * The minimum width of the tags, in pixels (issues #73 / #75, `tag_min_width`).
     */
    private var mTagMinWidth = 0

    /**
     * A tap selects or deselects a tag (issues #12 / #22 / #123, `tag_select_on_click`; needs `tag_selectable`).
     */
    private var mSelectTagOnClick = false

    /**
     * Selecting a tag deselects the others (issue #6, `container_single_selection`).
     */
    private var mSingleSelection = false

    /**
     * The colors of the next tag added with addTag(text, position, colors) (issue #76).
     */
    private var mNextTagColors: IntArray? = null

    /** TagView text color(default #FF666666) */
    private var mTagTextColor = Color.parseColor("#FF666666")

    /** TagView typeface */
    private var mTagTypeface: Typeface = Typeface.DEFAULT

    /**
     * TagView text font family, e.g. "sans-serif-medium" (whilu/AndroidTagView PR #110, `tag_text_font_family`).
     */
    private var mTagTextFontFamily: String? = null

    /**
     * TagView text style: Typeface.NORMAL, BOLD, ITALIC or BOLD_ITALIC (PR #110, `tag_text_style`).
     */
    private var mTagTextStyle: Int = Typeface.NORMAL

    /** Whether TagView can clickable(default unclickable) */
    private var isTagViewClickable = false

    /** Whether TagView can selectable(default unselectable) */
    private var isTagViewSelectable = false

    /** Tags */
    private var mTags: List<String>? = null

    /** Default image for new tags */
    private var mDefaultImageDrawableID = -1

    /** Can drag TagView(default false) */
    private var mDragEnable = false

    /** TagView drag state(default STATE_IDLE) */
    private var mTagViewState = ViewDragHelper.STATE_IDLE

    /** The distance between baseline and descent(default 2.75dp) */
    private var mTagBdDistance = 2.75f

    /** OnTagClickListener for TagView */
    private var mOnTagClickListener: TagView.OnTagClickListener? = null

    /** Whether to support 'letters show with RTL(eg: Android to diordnA)' style(default false) */
    private var mTagSupportLettersRTL = false

    private val mPaint: Paint

    private val mRectF: RectF

    private val mViewDragHelper: ViewDragHelper

    private val mChildViews: MutableList<View>

    private var mViewPos: IntArray = IntArray(0)

    /** View theme(default PURE_CYAN) */
    private var mTheme = ColorFactory.PURE_CYAN

    /** The ripple effect duration(In milliseconds, default 1000ms) */
    private var mRippleDuration = 1000

    /** The ripple effect color(default #EEEEEE) */
    private var mRippleColor = 0

    /** The ripple effect color alpha(the value may between 0 - 255, default 128) */
    private var mRippleAlpha = 128

    /** Enable draw cross icon(default false) */
    private var mEnableCross = false

    /** The cross area width(your cross click area, default equal to the TagView's height) */
    private var mCrossAreaWidth = 0.0f

    /** The padding of the cross area(default 10dp) */
    private var mCrossAreaPadding = 10.0f

    /** The cross icon color(default Color.BLACK) */
    private var mCrossColor = Color.BLACK

    /** The cross line width(default 1dp) */
    private var mCrossLineWidth = 1.0f

    /** TagView background resource */
    private var mTagBackgroundResource = 0

    init {
        val attributes = context.obtainStyledAttributes(attrs, R.styleable.AndroidTagView, defStyleAttr, 0)
        mVerticalInterval = attributes.getDimension(R.styleable.AndroidTagView_vertical_interval, dp2px(context, DEFAULT_INTERVAL)).toInt()
        mHorizontalInterval = attributes.getDimension(R.styleable.AndroidTagView_horizontal_interval, dp2px(context, DEFAULT_INTERVAL)).toInt()
        mBorderWidth = attributes.getDimension(R.styleable.AndroidTagView_container_border_width, dp2px(context, mBorderWidth))
        mBorderRadius = attributes.getDimension(R.styleable.AndroidTagView_container_border_radius, dp2px(context, mBorderRadius))
        mTagBdDistance = attributes.getDimension(R.styleable.AndroidTagView_tag_bd_distance, dp2px(context, mTagBdDistance))
        mBorderColor = attributes.getColor(R.styleable.AndroidTagView_container_border_color, mBorderColor)
        mBackgroundColor = attributes.getColor(R.styleable.AndroidTagView_container_background_color, mBackgroundColor)
        mDragEnable = attributes.getBoolean(R.styleable.AndroidTagView_container_enable_drag, false)
        mSensitivity = attributes.getFloat(R.styleable.AndroidTagView_container_drag_sensitivity, mSensitivity)
        mGravity = attributes.getInt(R.styleable.AndroidTagView_container_gravity, mGravity)
        mMaxLines = attributes.getInt(R.styleable.AndroidTagView_container_max_lines, mMaxLines)
        mSingleLine = attributes.getBoolean(R.styleable.AndroidTagView_container_single_line, mSingleLine)
        mTagMaxLength = attributes.getInt(R.styleable.AndroidTagView_tag_max_length, mTagMaxLength)
        mTheme = attributes.getInt(R.styleable.AndroidTagView_tag_theme, mTheme)
        mTagBorderWidth = attributes.getDimension(R.styleable.AndroidTagView_tag_border_width, dp2px(context, mTagBorderWidth))
        mTagBorderRadius = attributes.getDimension(R.styleable.AndroidTagView_tag_corner_radius, dp2px(context, mTagBorderRadius))
        mTagHorizontalPadding = attributes.getDimension(R.styleable.AndroidTagView_tag_horizontal_padding, dp2px(context, mTagHorizontalPadding.toFloat())).toInt()
        mTagVerticalPadding = attributes.getDimension(R.styleable.AndroidTagView_tag_vertical_padding, dp2px(context, mTagVerticalPadding.toFloat())).toInt()
        mTagTextSize = attributes.getDimension(R.styleable.AndroidTagView_tag_text_size, sp2px(context, mTagTextSize))
        mTagBorderColor = attributes.getColor(R.styleable.AndroidTagView_tag_border_color, mTagBorderColor)
        mTagBackgroundColor = attributes.getColor(R.styleable.AndroidTagView_tag_background_color, mTagBackgroundColor)
        mSelectedColorSet = attributes.hasValue(R.styleable.AndroidTagView_tag_selected_background_color)
        mSelectedTagBackgroundColor = attributes.getColor(R.styleable.AndroidTagView_tag_selected_background_color, mSelectedTagBackgroundColor)
        if (attributes.hasValue(R.styleable.AndroidTagView_tag_selected_text_color)) mSelectedTagTextColor = attributes.getColor(R.styleable.AndroidTagView_tag_selected_text_color, 0)
        mTagMinWidth = attributes.getDimensionPixelSize(R.styleable.AndroidTagView_tag_min_width, mTagMinWidth)
        mSelectTagOnClick = attributes.getBoolean(R.styleable.AndroidTagView_tag_select_on_click, mSelectTagOnClick)
        mSingleSelection = attributes.getBoolean(R.styleable.AndroidTagView_container_single_selection, mSingleSelection)
        // Issue #57: colors set in XML without a tag_theme are used (the default theme, pure cyan, replaced them).
        val explicitColors = listOf(R.styleable.AndroidTagView_tag_background_color, R.styleable.AndroidTagView_tag_border_color,
            R.styleable.AndroidTagView_tag_text_color).any { attributes.hasValue(it) }
        if (explicitColors && !attributes.hasValue(R.styleable.AndroidTagView_tag_theme)) mTheme = ColorFactory.NONE
        mTagTextColor = attributes.getColor(R.styleable.AndroidTagView_tag_text_color, mTagTextColor)
        mTagTextDirection = attributes.getInt(R.styleable.AndroidTagView_tag_text_direction, mTagTextDirection)
        mTagTextFontFamily = attributes.getString(R.styleable.AndroidTagView_tag_text_font_family)
        mTagTextStyle = attributes.getInt(R.styleable.AndroidTagView_tag_text_style, mTagTextStyle)
        isTagViewClickable = attributes.getBoolean(R.styleable.AndroidTagView_tag_clickable, false)
        isTagViewSelectable = attributes.getBoolean(R.styleable.AndroidTagView_tag_selectable, false)
        mRippleColor = attributes.getColor(R.styleable.AndroidTagView_tag_ripple_color, Color.parseColor("#EEEEEE"))
        mRippleAlpha = attributes.getInteger(R.styleable.AndroidTagView_tag_ripple_alpha, mRippleAlpha)
        mRippleDuration = attributes.getInteger(R.styleable.AndroidTagView_tag_ripple_duration, mRippleDuration)
        mEnableCross = attributes.getBoolean(R.styleable.AndroidTagView_tag_enable_cross, mEnableCross)
        mCrossAreaWidth = attributes.getDimension(R.styleable.AndroidTagView_tag_cross_width, dp2px(context, mCrossAreaWidth))
        mCrossAreaPadding = attributes.getDimension(R.styleable.AndroidTagView_tag_cross_area_padding, dp2px(context, mCrossAreaPadding))
        mCrossColor = attributes.getColor(R.styleable.AndroidTagView_tag_cross_color, mCrossColor)
        mCrossLineWidth = attributes.getDimension(R.styleable.AndroidTagView_tag_cross_line_width, dp2px(context, mCrossLineWidth))
        mTagSupportLettersRTL = attributes.getBoolean(R.styleable.AndroidTagView_tag_support_letters_rlt, mTagSupportLettersRTL)
        mTagBackgroundResource = attributes.getResourceId(R.styleable.AndroidTagView_tag_background, mTagBackgroundResource)
        attributes.recycle()

        mPaint = Paint(Paint.ANTI_ALIAS_FLAG)
        mRectF = RectF()
        mChildViews = ArrayList()
        mViewDragHelper = ViewDragHelper.create(this, mSensitivity, DragHelperCallBack())
        setWillNotDraw(false)
        setTagMaxLength(mTagMaxLength)
        setTagHorizontalPadding(mTagHorizontalPadding)
        setTagVerticalPadding(mTagVerticalPadding)

        if (isInEditMode) {
            addTag("sample tag")
        }
    }

    override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
        super.onMeasure(widthMeasureSpec, heightMeasureSpec)

        measureChildren(widthMeasureSpec, heightMeasureSpec)
        val childCount = childCount
        val lines = if (childCount == 0) 0 else getChildLines(childCount)
        val widthSpecSize = MeasureSpec.getSize(widthMeasureSpec)
        val heightSpecSize = MeasureSpec.getSize(heightMeasureSpec)
        val heightSpecMode = MeasureSpec.getMode(heightMeasureSpec)

        // Single line in a HorizontalScrollView (unspecified width): as wide as the tags (#42 / #106 / #115).
        var width = widthSpecSize
        if (mSingleLine && MeasureSpec.getMode(widthMeasureSpec) == MeasureSpec.UNSPECIFIED && childCount > 0) {
            width = paddingLeft + paddingRight + (0 until childCount).sumOf { getChildAt(it).measuredWidth } + mHorizontalInterval * (childCount - 1)
        }
        if (childCount == 0) {
            setMeasuredDimension(0, 0)
        } else if (heightSpecMode == MeasureSpec.AT_MOST || heightSpecMode == MeasureSpec.UNSPECIFIED) {
            setMeasuredDimension(width, (mVerticalInterval + mChildHeight) * lines - mVerticalInterval + paddingTop + paddingBottom)
        } else {
            setMeasuredDimension(width, heightSpecSize)
        }
    }

    override fun onSizeChanged(w: Int, h: Int, oldw: Int, oldh: Int) {
        super.onSizeChanged(w, h, oldw, oldh)
        mRectF.set(0f, 0f, w.toFloat(), h.toFloat())
    }

    override fun onLayout(changed: Boolean, l: Int, t: Int, r: Int, b: Int) {
        val childCount = childCount
        if (childCount <= 0) {
            return
        }
        val availableW = measuredWidth - paddingLeft - paddingRight
        var curRight = measuredWidth - paddingRight
        var curTop = paddingTop
        var curLeft = paddingLeft
        var sPos = 0
        mViewPos = IntArray(childCount * 2)
        mViewLines = IntArray(childCount)

        for (i in 0 until childCount) {
            val childView = getChildAt(i)
            if (childView.visibility != GONE) {
                val width = childView.measuredWidth
                if (mGravity == Gravity.RIGHT) {
                    if (!mSingleLine && curRight - width < paddingLeft) {
                        curRight = measuredWidth - paddingRight
                        curTop += mChildHeight + mVerticalInterval
                    }
                    mViewPos[i * 2] = curRight - width
                    mViewPos[i * 2 + 1] = curTop
                    curRight -= width + mHorizontalInterval
                } else if (mGravity == Gravity.CENTER) {
                    if (!mSingleLine && curLeft + width - paddingLeft > availableW) {
                        val leftW = measuredWidth - mViewPos[(i - 1) * 2] - getChildAt(i - 1).measuredWidth - paddingRight
                        for (j in sPos until i) {
                            mViewPos[j * 2] = mViewPos[j * 2] + leftW / 2
                        }
                        sPos = i
                        curLeft = paddingLeft
                        curTop += mChildHeight + mVerticalInterval
                    }
                    mViewPos[i * 2] = curLeft
                    mViewPos[i * 2 + 1] = curTop
                    curLeft += width + mHorizontalInterval

                    if (i == childCount - 1) {
                        val leftW = measuredWidth - mViewPos[i * 2] - childView.measuredWidth - paddingRight
                        for (j in sPos until childCount) {
                            mViewPos[j * 2] = mViewPos[j * 2] + leftW / 2
                        }
                    }
                } else {
                    if (!mSingleLine && curLeft + width - paddingLeft > availableW) {
                        curLeft = paddingLeft
                        curTop += mChildHeight + mVerticalInterval
                    }
                    mViewPos[i * 2] = curLeft
                    mViewPos[i * 2 + 1] = curTop
                    curLeft += width + mHorizontalInterval
                }
            }
        }

        // the line of each tag (#80)
        var line = 0
        for (i in 1 until childCount) {
            if (mViewPos[i * 2 + 1] > mViewPos[(i - 1) * 2 + 1]) line++
            mViewLines[i] = line
        }

        // layout all child views
        for (i in 0 until mViewPos.size / 2) {
            val childView = getChildAt(i)
            childView.layout(mViewPos[i * 2], mViewPos[i * 2 + 1], mViewPos[i * 2] + childView.measuredWidth, mViewPos[i * 2 + 1] + mChildHeight)
        }
    }

    override fun onDraw(canvas: Canvas) {
        super.onDraw(canvas)

        mPaint.style = Paint.Style.FILL
        mPaint.color = mBackgroundColor
        canvas.drawRoundRect(mRectF, mBorderRadius, mBorderRadius, mPaint)

        mPaint.style = Paint.Style.STROKE
        mPaint.strokeWidth = mBorderWidth
        mPaint.color = mBorderColor
        canvas.drawRoundRect(mRectF, mBorderRadius, mBorderRadius, mPaint)
    }

    override fun onInterceptTouchEvent(ev: MotionEvent): Boolean = try {
        interceptContentScroll(ev) || mViewDragHelper.shouldInterceptTouchEvent(ev)
    } catch (error: RuntimeException) {
        // Issue #26: ViewDragHelper throws ArrayIndexOutOfBoundsException / IllegalArgumentException for pointer ids
        // it never saw (a second finger, a gesture that began outside); the event is simply not intercepted.
        false
    }

    override fun onTouchEvent(event: MotionEvent): Boolean {
        // Issues #21 / #27 / #64 / #108 / #112: the container took every touch, so a parent (a list item, a clickable
        // layout) never got its click and the container's own click listener never fired. Only dragging needs them.
        if (!mDragEnable) return scrollContent(event) || super.onTouchEvent(event)
        try {
            mViewDragHelper.processTouchEvent(event)
        } catch (error: RuntimeException) {
            return false
        }
        return true
    }

    /**
     * The height of every line, padding included (the content scrolls when it is taller than the view: #58 / #63).
     */
    private fun contentHeight(): Int =
        if (mTotalLines == 0) 0 else (mVerticalInterval + mChildHeight) * mTotalLines - mVerticalInterval + paddingTop + paddingBottom

    private fun maxContentScroll(): Int = max(0, contentHeight() - height)

    override fun computeVerticalScrollRange(): Int = max(contentHeight(), height)

    override fun computeVerticalScrollOffset(): Int = scrollY

    override fun computeVerticalScrollExtent(): Int = height

    /**
     * Takes a vertical drag over a container whose lines go beyond `container_max_lines` (#58 / #63); a tap still goes
     * to the tag.
     */
    private fun interceptContentScroll(ev: MotionEvent): Boolean {
        if (mDragEnable || maxContentScroll() <= 0) return false
        when (ev.actionMasked) {
            MotionEvent.ACTION_DOWN -> { mScrollLastY = ev.y; mScrollingContent = false }
            MotionEvent.ACTION_MOVE -> if (abs(ev.y - mScrollLastY) > mTouchSlop) {
                mScrollingContent = true
                mScrollLastY = ev.y
                parent?.requestDisallowInterceptTouchEvent(true)
            }
        }
        return mScrollingContent
    }

    private fun scrollContent(event: MotionEvent): Boolean {
        if (maxContentScroll() <= 0) return false
        when (event.actionMasked) {
            MotionEvent.ACTION_DOWN -> { mScrollLastY = event.y; return true }
            MotionEvent.ACTION_MOVE -> {
                val dy = (mScrollLastY - event.y).toInt()
                if (!mScrollingContent && abs(dy) <= mTouchSlop) return true
                mScrollingContent = true
                mScrollLastY = event.y
                scrollTo(0, min(max(scrollY + dy, 0), maxContentScroll()))
                return true
            }
            MotionEvent.ACTION_UP, MotionEvent.ACTION_CANCEL -> {
                val scrolled = mScrollingContent
                mScrollingContent = false
                return scrolled
            }
        }
        return false
    }

    /**
     * The number of tags on the visible lines (issue #80): all of them without `container_max_lines`.
     */
    fun getVisibleTagCount(): Int {
        if (mMaxLines <= 0 || mSingleLine) return childCount
        return mViewLines.count { it < mMaxLines }
    }

    /**
     * Every tag on one line (issues #42 / #106 / #115); `container_single_line` in XML.
     */
    fun setSingleLine(singleLine: Boolean) {
        mSingleLine = singleLine
        requestLayout()
    }

    fun isSingleLine(): Boolean = mSingleLine

    override fun computeScroll() {
        super.computeScroll()
        if (mViewDragHelper.continueSettling(true)) {
            requestLayout()
        }
    }

    private fun getChildLines(childCount: Int): Int {
        val availableW = measuredWidth - paddingLeft - paddingRight
        var lines = 1
        var curLineW = 0
        for (i in 0 until childCount) {
            val childView = getChildAt(i)
            val dis = childView.measuredWidth + mHorizontalInterval
            val height = childView.measuredHeight
            mChildHeight = if (i == 0) height else min(mChildHeight, height)
            curLineW += dis
            if (!mSingleLine && curLineW - mHorizontalInterval > availableW) {
                lines++
                curLineW = dis
            }
        }
        mTotalLines = lines
        // Issue #74: the height is that of the lines the tags need, at most `mMaxLines` (it was always mMaxLines).
        return if (mMaxLines <= 0) lines else min(lines, mMaxLines)
    }

    private fun onUpdateColorFactory(): IntArray = when (mTheme) {
        ColorFactory.RANDOM -> ColorFactory.onRandomBuild()
        ColorFactory.PURE_TEAL -> ColorFactory.onPureBuild(ColorFactory.PURE_COLOR.TEAL)
        ColorFactory.PURE_CYAN -> ColorFactory.onPureBuild(ColorFactory.PURE_COLOR.CYAN)
        else -> intArrayOf(mTagBackgroundColor, mTagBorderColor, mTagTextColor, mSelectedTagBackgroundColor)
    }

    private fun onSetTag() {
        val tags = mTags ?: throw RuntimeException("NullPointer exception!")
        removeAllTags()
        if (tags.isEmpty()) {
            return
        }
        for (i in tags.indices) {
            onAddTag(tags[i], mChildViews.size)
        }
        postInvalidate()
    }

    private fun onAddTag(text: String, position: Int) {
        if (position < 0 || position > mChildViews.size) {
            throw RuntimeException("Illegal position!")
        }
        val tagView = if (mDefaultImageDrawableID != -1) {
            TagView(context, text, mDefaultImageDrawableID)
        } else {
            TagView(context, text)
        }
        initTagView(tagView, position)
        mChildViews.add(position, tagView)
        if (position < mChildViews.size) {
            for (i in position until mChildViews.size) {
                mChildViews[i].tag = i
            }
        } else {
            tagView.tag = position
        }
        addView(tagView, position)
    }

    private fun initTagView(tagView: TagView, position: Int) {
        val colorList = mColorArrayList
        val nextColors = mNextTagColors
        mNextTagColors = null
        tagView.setTag(R.id.androidtagview_own_colors, nextColors != null)
        val colors: IntArray = if (nextColors != null) {
            nextColors
        } else if (colorList != null && colorList.isNotEmpty()) {
            if (colorList.size == mTags?.size && colorList[position].size >= 4) {
                colorList[position]
            } else {
                throw RuntimeException("Illegal color list!")
            }
        } else {
            onUpdateColorFactory()
        }

        tagView.setTagBackgroundColor(colors[0])
        tagView.setTagBorderColor(colors[1])
        tagView.setTagTextColor(colors[2])
        tagView.setTagSelectedBackgroundColor(if (mSelectedColorSet && nextColors == null) mSelectedTagBackgroundColor else colors[3])
        tagView.setTagSelectedTextColor(mSelectedTagTextColor)
        tagView.setTagMinWidth(mTagMinWidth)
        tagView.selectOnClick = mSelectTagOnClick
        tagView.setTagMaxLength(mTagMaxLength)
        tagView.textDirection = mTagTextDirection
        // PR #110: the font family and text style, when set, replace the typeface.
        val family = mTagTextFontFamily
        when {
            family == null && mTagTextStyle != Typeface.NORMAL -> tagView.setTypeface(Typeface.defaultFromStyle(mTagTextStyle))
            family != null -> tagView.setTypeface(Typeface.create(family, mTagTextStyle))
            else -> tagView.setTypeface(mTagTypeface)
        }
        tagView.setBorderWidth(mTagBorderWidth)
        tagView.setBorderRadius(mTagBorderRadius)
        tagView.setTextSize(mTagTextSize)
        tagView.setHorizontalPadding(mTagHorizontalPadding)
        tagView.setVerticalPadding(mTagVerticalPadding)
        tagView.setIsViewClickable(isTagViewClickable)
        tagView.setIsViewSelectable(isTagViewSelectable)
        tagView.setBdDistance(mTagBdDistance)
        tagView.setOnTagClickListener(mOnTagClickListener)
        tagView.setRippleAlpha(mRippleAlpha)
        tagView.setRippleColor(mRippleColor)
        tagView.setRippleDuration(mRippleDuration)
        tagView.setEnableCross(mEnableCross)
        tagView.setCrossAreaWidth(mCrossAreaWidth)
        tagView.setCrossAreaPadding(mCrossAreaPadding)
        tagView.setCrossColor(mCrossColor)
        tagView.setCrossLineWidth(mCrossLineWidth)
        tagView.setTagSupportLettersRTL(mTagSupportLettersRTL)
        tagView.setBackgroundResource(mTagBackgroundResource)
    }

    private fun invalidateTags() {
        for (view in mChildViews) {
            (view as TagView).setOnTagClickListener(mOnTagClickListener)
        }
    }

    private fun onRemoveTag(position: Int) {
        if (position < 0 || position >= mChildViews.size) {
            throw RuntimeException("Illegal position!")
        }
        mChildViews.removeAt(position)
        removeViewAt(position)
        for (i in position until mChildViews.size) {
            mChildViews[i].tag = i
        }
    }

    private fun onRemoveConsecutiveTags(positions: List<Int>) {
        val smallestPosition = positions.min()
        for (position in positions) {
            if (position < 0 || position >= mChildViews.size) {
                throw RuntimeException("Illegal position!")
            }
            mChildViews.removeAt(smallestPosition)
            removeViewAt(smallestPosition)
        }
        for (i in smallestPosition until mChildViews.size) {
            mChildViews[i].tag = i
        }
    }

    private fun onGetNewPosition(view: View): IntArray {
        val left = view.left
        val top = view.top
        var bestMatchLeft = mViewPos[(view.tag as Int) * 2]
        var bestMatchTop = mViewPos[(view.tag as Int) * 2 + 1]
        var tmpTopDis = abs(top - bestMatchTop)
        for (i in 0 until mViewPos.size / 2) {
            if (abs(top - mViewPos[i * 2 + 1]) < tmpTopDis) {
                bestMatchTop = mViewPos[i * 2 + 1]
                tmpTopDis = abs(top - mViewPos[i * 2 + 1])
            }
        }
        var rowChildCount = 0
        var tmpLeftDis = 0
        for (i in 0 until mViewPos.size / 2) {
            if (mViewPos[i * 2 + 1] == bestMatchTop) {
                if (rowChildCount == 0) {
                    bestMatchLeft = mViewPos[i * 2]
                    tmpLeftDis = abs(left - bestMatchLeft)
                } else if (abs(left - mViewPos[i * 2]) < tmpLeftDis) {
                    bestMatchLeft = mViewPos[i * 2]
                    tmpLeftDis = abs(left - bestMatchLeft)
                }
                rowChildCount++
            }
        }
        return intArrayOf(bestMatchLeft, bestMatchTop)
    }

    private fun onGetCoordinateReferPos(left: Int, top: Int): Int {
        var pos = 0
        for (i in 0 until mViewPos.size / 2) {
            if (left == mViewPos[i * 2] && top == mViewPos[i * 2 + 1]) {
                pos = i
            }
        }
        return pos
    }

    private fun onChangeView(view: View, newPos: Int, originPos: Int) {
        mChildViews.removeAt(originPos)
        mChildViews.add(newPos, view)
        for (child in mChildViews) {
            child.tag = mChildViews.indexOf(child)
        }
        removeViewAt(originPos)
        addView(view, newPos)
    }

    private fun ceilTagBorderWidth(): Int = ceil(mTagBorderWidth.toDouble()).toInt()

    private inner class DragHelperCallBack : ViewDragHelper.Callback() {

        override fun onViewDragStateChanged(state: Int) {
            super.onViewDragStateChanged(state)
            mTagViewState = state
        }

        override fun tryCaptureView(child: View, pointerId: Int): Boolean {
            // Issues #59 / #65: only a drag keeps the parent (a ScrollView) from scrolling; without drag the touch on a
            // tag no longer blocks it.
            if (mDragEnable) requestDisallowInterceptTouchEvent(true)
            return mDragEnable
        }

        override fun clampViewPositionHorizontal(child: View, left: Int, dx: Int): Int {
            val leftX = paddingLeft
            val rightX = width - child.width - paddingRight
            return min(max(left, leftX), rightX)
        }

        override fun clampViewPositionVertical(child: View, top: Int, dy: Int): Int {
            val topY = paddingTop
            val bottomY = height - child.height - paddingBottom
            return min(max(top, topY), bottomY)
        }

        override fun getViewHorizontalDragRange(child: View): Int = measuredWidth - child.measuredWidth

        override fun getViewVerticalDragRange(child: View): Int = measuredHeight - child.measuredHeight

        override fun onViewReleased(releasedChild: View, xvel: Float, yvel: Float) {
            super.onViewReleased(releasedChild, xvel, yvel)
            requestDisallowInterceptTouchEvent(false)
            val pos = onGetNewPosition(releasedChild)
            val posRefer = onGetCoordinateReferPos(pos[0], pos[1])
            onChangeView(releasedChild, posRefer, releasedChild.tag as Int)
            mViewDragHelper.settleCapturedViewAt(pos[0], pos[1])
            invalidate()
        }
    }

    /** Get current drag view state. */
    fun getTagViewState(): Int = mTagViewState

    /** Get TagView text baseline and descent distance. */
    fun getTagBdDistance(): Float = mTagBdDistance

    /** Set TagView text baseline and descent distance. */
    fun setTagBdDistance(tagBdDistance: Float) {
        mTagBdDistance = dp2px(context, tagBdDistance)
    }

    /** Set tags */
    fun setTags(tags: List<String>) {
        mTags = tags
        onSetTag()
    }

    /** Set tags with own color */
    fun setTags(tags: List<String>, colorArrayList: List<IntArray>) {
        mTags = tags
        mColorArrayList = colorArrayList
        onSetTag()
    }

    /** Set tags */
    fun setTags(vararg tags: String) {
        mTags = tags.asList()
        onSetTag()
    }

    /** Inserts the specified TagView into this ContainerLayout at the end. */
    fun addTag(text: String) {
        addTag(text, mChildViews.size)
    }

    /**
     * Inserts the specified TagView into this ContainerLayout at the specified location.
     * The TagView is inserted before the current element at the specified location.
     */
    fun addTag(text: String, position: Int) {
        onAddTag(text, position)
        postInvalidate()
    }

    /**
     * Adds a tag with its own colors (issue #76): background, border, text, selected background.
     */
    fun addTag(text: String, colors: IntArray) = addTag(text, mChildViews.size, colors)

    /**
     * Inserts a tag with its own colors at `position` (issue #76).
     */
    fun addTag(text: String, position: Int, colors: IntArray) {
        require(colors.size >= 4) { "colors: background, border, text, selected background" }
        mNextTagColors = colors
        addTag(text, position)
    }

    /** Remove a TagView in specified position. */
    fun removeTag(position: Int) {
        onRemoveTag(position)
        postInvalidate()
    }

    /** Remove TagView in multiple consecutive positions. */
    fun removeConsecutiveTags(positions: List<Int>) {
        onRemoveConsecutiveTags(positions)
        postInvalidate()
    }

    /** Remove all TagViews. */
    fun removeAllTags() {
        mChildViews.clear()
        removeAllViews()
        postInvalidate()
    }

    /** Set OnTagClickListener for TagView. */
    fun setOnTagClickListener(listener: TagView.OnTagClickListener?) {
        mOnTagClickListener = listener
        invalidateTags()
    }

    /** Toggle select a tag */
    fun toggleSelectTagView(position: Int) {
        if (isTagViewSelectable) {
            val tagView = mChildViews[position] as TagView
            if (tagView.getIsViewSelected()) {
                tagView.deselectView()
            } else {
                selectTagView(position)
            }
        }
    }

    /** Select a tag (single selection: the others are deselected, issue #6) */
    fun selectTagView(position: Int) {
        if (!isTagViewSelectable) return
        if (mSingleSelection) {
            for ((index, view) in mChildViews.withIndex()) if (index != position) (view as TagView).deselectView()
        }
        (mChildViews[position] as TagView).selectView()
    }

    /**
     * Selecting a tag deselects the others (issue #6); `container_single_selection` in XML.
     */
    fun setSingleSelection(single: Boolean) {
        mSingleSelection = single
    }

    fun isSingleSelection(): Boolean = mSingleSelection

    /**
     * A tap selects or deselects a tag (issues #12 / #22 / #123); needs `setIsTagViewClickable(true)` and
     * `setIsTagViewSelectable(true)` (`tag_clickable`, `tag_selectable`).
     */
    fun setSelectTagViewOnClick(select: Boolean) {
        mSelectTagOnClick = select
        mChildViews.forEach { (it as TagView).selectOnClick = select }
    }

    /**
     * The background color of selected tags (issues #29 / #114), for the tags shown and the next ones.
     */
    fun setSelectedTagBackgroundColor(color: Int) {
        mSelectedTagBackgroundColor = color
        mSelectedColorSet = true
        applyColorsToTags()
    }

    fun getSelectedTagBackgroundColor(): Int = mSelectedTagBackgroundColor

    /**
     * The text color of selected tags (issues #29 / #114); null keeps the text color.
     */
    fun setSelectedTagTextColor(color: Int?) {
        mSelectedTagTextColor = color
        mChildViews.forEach { (it as TagView).setTagSelectedTextColor(color) }
    }

    /**
     * The minimum width of the tags, in pixels (issues #73 / #75: same-size tags).
     */
    fun setTagMinWidth(width: Int) {
        mTagMinWidth = width
        mChildViews.forEach { (it as TagView).setTagMinWidth(width) }
        requestLayout()
    }

    /**
     * The theme and container colors applied to the tags already shown too (issue #77: they changed only new tags);
     * tags with their own colors (setTags with colors, addTag with colors) keep them.
     */
    private fun applyColorsToTags() {
        if (mColorArrayList?.isNotEmpty() == true) return
        for (view in mChildViews) {
            val tagView = view as TagView
            if (tagView.getTag(R.id.androidtagview_own_colors) == true) continue
            val colors = onUpdateColorFactory()
            tagView.setTagBackgroundColor(colors[0])
            tagView.setTagBorderColor(colors[1])
            tagView.setTagTextColor(colors[2])
            tagView.setTagSelectedBackgroundColor(if (mSelectedColorSet) mSelectedTagBackgroundColor else colors[3])
        }
    }

    /** Deselect a tag */
    fun deselectTagView(position: Int) {
        if (isTagViewSelectable) (mChildViews[position] as TagView).deselectView()
    }

    /** Return selected TagView positions */
    fun getSelectedTagViewPositions(): List<Int> {
        val selectedPositions = ArrayList<Int>()
        for (i in mChildViews.indices) {
            if ((mChildViews[i] as TagView).getIsViewSelected()) {
                selectedPositions.add(i)
            }
        }
        return selectedPositions
    }

    /** Return selected TagView text */
    fun getSelectedTagViewText(): List<String> {
        val selectedTagText = ArrayList<String>()
        for (i in mChildViews.indices) {
            val tagView = mChildViews[i] as TagView
            if (tagView.getIsViewSelected()) {
                selectedTagText.add(tagView.getText())
            }
        }
        return selectedTagText
    }

    /** Return number of child tags */
    fun size(): Int = mChildViews.size

    /** Get TagView text. */
    fun getTagText(position: Int): String = (mChildViews[position] as TagView).getText()

    /** Get a string list for all tags in TagContainerLayout. */
    fun getTags(): List<String> {
        val tmpList = ArrayList<String>()
        for (view in mChildViews) {
            if (view is TagView) {
                tmpList.add(view.getText())
            }
        }
        return tmpList
    }

    /** Set whether the child view can be dragged. */
    fun setDragEnable(enable: Boolean) {
        mDragEnable = enable
    }

    /** Get current view is drag enable attribute. */
    fun getDragEnable(): Boolean = mDragEnable

    /** Set vertical interval */
    fun setVerticalInterval(interval: Float) {
        mVerticalInterval = dp2px(context, interval).toInt()
        postInvalidate()
    }

    /** Get vertical interval in this view. */
    fun getVerticalInterval(): Int = mVerticalInterval

    /** Set horizontal interval. */
    fun setHorizontalInterval(interval: Float) {
        mHorizontalInterval = dp2px(context, interval).toInt()
        postInvalidate()
    }

    /** Get horizontal interval in this view. */
    fun getHorizontalInterval(): Int = mHorizontalInterval

    /** Get TagContainerLayout border width. */
    fun getBorderWidth(): Float = mBorderWidth

    /** Set TagContainerLayout border width. */
    fun setBorderWidth(width: Float) {
        mBorderWidth = width
    }

    /** Get TagContainerLayout border radius. */
    fun getBorderRadius(): Float = mBorderRadius

    /** Set TagContainerLayout border radius. */
    fun setBorderRadius(radius: Float) {
        mBorderRadius = radius
    }

    /** Get TagContainerLayout border color. */
    fun getBorderColor(): Int = mBorderColor

    /** Set TagContainerLayout border color. */
    fun setBorderColor(color: Int) {
        mBorderColor = color
    }

    /** Get TagContainerLayout background color. */
    fun getBackgroundColor(): Int = mBackgroundColor

    /** Set TagContainerLayout background color. */
    override fun setBackgroundColor(color: Int) {
        mBackgroundColor = color
    }

    /** Get container layout gravity. */
    fun getGravity(): Int = mGravity

    /** Set container layout gravity. */
    fun setGravity(gravity: Int) {
        mGravity = gravity
    }

    /** Get TagContainerLayout ViewDragHelper sensitivity. */
    fun getSensitivity(): Float = mSensitivity

    /** Set TagContainerLayout ViewDragHelper sensitivity. */
    fun setSensitivity(sensitivity: Float) {
        mSensitivity = sensitivity
    }

    /** Get default tag image */
    fun getDefaultImageDrawableID(): Int = mDefaultImageDrawableID

    /** Set default image for tags. */
    fun setDefaultImageDrawableID(imageID: Int) {
        mDefaultImageDrawableID = imageID
    }

    /** Set max line count for TagContainerLayout */
    fun setMaxLines(maxLines: Int) {
        mMaxLines = maxLines
        postInvalidate()
    }

    /** Get TagContainerLayout's max lines */
    fun getMaxLines(): Int = mMaxLines

    /** Set the TagView text max length(must greater or equal to 3). */
    fun setTagMaxLength(maxLength: Int) {
        mTagMaxLength = if (maxLength < TAG_MIN_LENGTH) TAG_MIN_LENGTH else maxLength
    }

    /** Get TagView max length. */
    fun getTagMaxLength(): Int = mTagMaxLength

    /** Set TagView theme. */
    fun setTheme(theme: Int) {
        mTheme = theme
        applyColorsToTags()
    }

    /** Get TagView theme. */
    fun getTheme(): Int = mTheme

    /** Get TagView is clickable. */
    fun getIsTagViewClickable(): Boolean = isTagViewClickable

    /** Set TagView is clickable */
    fun setIsTagViewClickable(clickable: Boolean) {
        isTagViewClickable = clickable
    }

    /** Get TagView is selectable. */
    fun getIsTagViewSelectable(): Boolean = isTagViewSelectable

    /** Set TagView is selectable */
    fun setIsTagViewSelectable(selectable: Boolean) {
        isTagViewSelectable = selectable
    }

    /** Get TagView border width. */
    fun getTagBorderWidth(): Float = mTagBorderWidth

    /** Set TagView border width. */
    fun setTagBorderWidth(width: Float) {
        mTagBorderWidth = width
    }

    /** Get TagView border radius. */
    fun getTagBorderRadius(): Float = mTagBorderRadius

    /** Set TagView border radius. */
    fun setTagBorderRadius(radius: Float) {
        mTagBorderRadius = radius
    }

    /** Get TagView text size. */
    fun getTagTextSize(): Float = mTagTextSize

    /** Set TagView text size. */
    fun setTagTextSize(size: Float) {
        mTagTextSize = size
    }

    /** Get TagView horizontal padding. */
    fun getTagHorizontalPadding(): Int = mTagHorizontalPadding

    /** Set TagView horizontal padding. */
    fun setTagHorizontalPadding(padding: Int) {
        val ceilWidth = ceilTagBorderWidth()
        mTagHorizontalPadding = if (padding < ceilWidth) ceilWidth else padding
    }

    /** Get TagView vertical padding. */
    fun getTagVerticalPadding(): Int = mTagVerticalPadding

    /** Set TagView vertical padding. */
    fun setTagVerticalPadding(padding: Int) {
        val ceilWidth = ceilTagBorderWidth()
        mTagVerticalPadding = if (padding < ceilWidth) ceilWidth else padding
    }

    /** Get TagView border color. */
    fun getTagBorderColor(): Int = mTagBorderColor

    /** Set TagView border color. */
    fun setTagBorderColor(color: Int) {
        mTagBorderColor = color
        applyColorsToTags()
    }

    /** Get TagView background color. */
    fun getTagBackgroundColor(): Int = mTagBackgroundColor

    /** Set TagView background color. */
    fun setTagBackgroundColor(color: Int) {
        mTagBackgroundColor = color
        applyColorsToTags()
    }

    /** Get TagView text color. */
    fun getTagTextColor(): Int = mTagTextColor

    /**
     * Set tag text direction, support: View.TEXT_DIRECTION_RTL and View.TEXT_DIRECTION_LTR,
     * default View.TEXT_DIRECTION_LTR
     */
    fun setTagTextDirection(textDirection: Int) {
        mTagTextDirection = textDirection
    }

    /**
     * Get TagView font family (PR #110).
     */
    fun getTagTextFontFamily(): String? = mTagTextFontFamily

    /**
     * Set TagView font family, e.g. "sans-serif-black" (PR #110); applies to tags added afterwards.
     */
    fun setTagTextFontFamily(fontFamily: String?) {
        mTagTextFontFamily = fontFamily
    }

    /**
     * Get TagView text style (PR #110).
     */
    fun getTagTextStyle(): Int = mTagTextStyle

    /**
     * Set TagView text style: Typeface.NORMAL, BOLD, ITALIC or BOLD_ITALIC (PR #110); applies to tags added afterwards.
     */
    fun setTagTextStyle(textStyle: Int) {
        mTagTextStyle = textStyle
    }

    /** Get TagView typeface. */
    fun getTagTypeface(): Typeface = mTagTypeface

    /** Set TagView typeface. */
    fun setTagTypeface(typeface: Typeface) {
        mTagTypeface = typeface
    }

    /** Get tag text direction */
    fun getTagTextDirection(): Int = mTagTextDirection

    /** Set TagView text color. */
    fun setTagTextColor(color: Int) {
        mTagTextColor = color
        applyColorsToTags()
    }

    /** Get the ripple effect color's alpha. */
    fun getRippleAlpha(): Int = mRippleAlpha

    /** Set TagView ripple effect alpha, the value may between 0 to 255, default is 128. */
    fun setRippleAlpha(mRippleAlpha: Int) {
        this.mRippleAlpha = mRippleAlpha
    }

    /** Get the ripple effect color. */
    fun getRippleColor(): Int = mRippleColor

    /** Set TagView ripple effect color. */
    fun setRippleColor(mRippleColor: Int) {
        this.mRippleColor = mRippleColor
    }

    /** Get the ripple effect duration. */
    fun getRippleDuration(): Int = mRippleDuration

    /** Set TagView ripple effect duration, default is 1000ms. */
    fun setRippleDuration(mRippleDuration: Int) {
        this.mRippleDuration = mRippleDuration
    }

    /** Get TagView cross color. */
    fun getCrossColor(): Int = mCrossColor

    /** Set TagView cross color, default Color.BLACK. */
    fun setCrossColor(mCrossColor: Int) {
        this.mCrossColor = mCrossColor
    }

    /** Get TagView cross area's padding. */
    fun getCrossAreaPadding(): Float = mCrossAreaPadding

    /** Set TagView cross area padding, default 10dp. */
    fun setCrossAreaPadding(mCrossAreaPadding: Float) {
        this.mCrossAreaPadding = mCrossAreaPadding
    }

    /** Get is the TagView's cross enable, default false. */
    fun isEnableCross(): Boolean = mEnableCross

    /** Enable or disable the TagView's cross. */
    fun setEnableCross(mEnableCross: Boolean) {
        this.mEnableCross = mEnableCross
    }

    /** Get TagView cross area width. */
    fun getCrossAreaWidth(): Float = mCrossAreaWidth

    /** Set TagView area width. */
    fun setCrossAreaWidth(mCrossAreaWidth: Float) {
        this.mCrossAreaWidth = mCrossAreaWidth
    }

    /** Get TagView cross line width. */
    fun getCrossLineWidth(): Float = mCrossLineWidth

    /** Set TagView cross line width, default 1dp. */
    fun setCrossLineWidth(mCrossLineWidth: Float) {
        this.mCrossLineWidth = mCrossLineWidth
    }

    /** Get the 'letters show with RTL(like: Android to diordnA)' style if it's enabled */
    fun isTagSupportLettersRTL(): Boolean = mTagSupportLettersRTL

    /** Set whether the 'support letters show with RTL(like: Android to diordnA)' style is enabled. */
    fun setTagSupportLettersRTL(mTagSupportLettersRTL: Boolean) {
        this.mTagSupportLettersRTL = mTagSupportLettersRTL
    }

    /** Get TagView in specified position. */
    fun getTagView(position: Int): TagView {
        if (position < 0 || position >= mChildViews.size) {
            throw RuntimeException("Illegal position!")
        }
        return mChildViews[position] as TagView
    }

    /** Get TagView background resource */
    fun getTagBackgroundResource(): Int = mTagBackgroundResource

    /** Set TagView background resource */
    fun setTagBackgroundResource(@DrawableRes tagBackgroundResource: Int) {
        mTagBackgroundResource = tagBackgroundResource
    }

    companion object {
        /** Default interval(dp) */
        private const val DEFAULT_INTERVAL = 5f

        /** Default tag min length */
        private const val TAG_MIN_LENGTH = 3
    }
}
