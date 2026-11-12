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

import android.animation.ValueAnimator
import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.BitmapShader
import android.graphics.Canvas
import android.graphics.Paint
import android.graphics.Path
import android.graphics.RectF
import android.graphics.Region
import android.graphics.Shader
import android.graphics.Typeface
import android.os.Build
import android.text.TextUtils
import android.view.MotionEvent
import android.view.View
import androidx.customview.widget.ViewDragHelper
import co.lujun.androidtagview.Utils.dp2px
import kotlin.math.abs
import kotlin.math.max
import kotlin.math.min
import kotlin.math.roundToInt

/**
 * Author: lujun(http://blog.lujun.co)
 * Date: 2015-12-31 11:47
 */
open class TagView : View {

    /** Border width */
    private var mBorderWidth = 0f

    /** Border radius */
    private var mBorderRadius = 0f

    /** Text size */
    private var mTextSize = 0f

    /** Horizontal padding for this view, include left & right padding (left & right padding are equal) */
    private var mHorizontalPadding = 0

    /** Vertical padding for this view, include top & bottom padding (top & bottom padding are equal) */
    private var mVerticalPadding = 0

    /** TagView border color */
    private var mBorderColor = 0

    /** TagView background color */
    private var mBackgroundColor = 0

    /** TagView selected background color */
    private var mSelectedBackgroundColor = 0

    /** TagView text color */
    private var mTextColor = 0

    /** Whether this view clickable */
    private var isViewClickable = false

    /** Whether this view selectable */
    private var isViewSelectable = false

    /** Whether this view selected */
    private var isViewSelected = false

    /** The max length for this tag view */
    private var mTagMaxLength = 0

    /** OnTagClickListener for click action */
    private var mOnTagClickListener: OnTagClickListener? = null

    /** Move slop (default 5dp) */
    private var mMoveSlop = 5

    /** Scroll slop threshold 4dp */
    private var mSlopThreshold = 4

    /** How long trigger long click callback (default 500ms) */
    private val mLongPressTime = 500

    /** Text direction (support: TEXT_DIRECTION_RTL & TEXT_DIRECTION_LTR, default TEXT_DIRECTION_LTR) */
    private var mTextDirection = View.TEXT_DIRECTION_LTR

    /** The distance between baseline and descent */
    private var bdDistance = 0f

    /** Whether to support 'letters show with RTL (eg: Android to diordnA)' style (default false) */
    private var mTagSupportLettersRTL = false

    private lateinit var mPaint: Paint
    private lateinit var mRipplePaint: Paint

    private lateinit var mRectF: RectF

    private var mAbstractText: String = ""
    private var mOriginText: String = ""

    private var isUp = false
    private var isMoved = false
    private var isExecLongClick = false

    private var mLastX = 0
    private var mLastY = 0

    private var fontH = 0f
    private var fontW = 0f

    private var mTouchX = 0f
    private var mTouchY = 0f

    /** The ripple effect duration (default 1000ms) */
    private var mRippleDuration = 1000

    private var mRippleRadius = 0f

    private var mRippleColor = 0

    private var mRippleAlpha = 0

    private lateinit var mPath: Path

    private var mTypeface: Typeface? = null

    private var mRippleValueAnimator: ValueAnimator? = null

    private var mBitmapImage: Bitmap? = null

    private var mEnableCross = false

    private var mCrossAreaWidth = 0f

    private var mCrossAreaPadding = 0f

    private var mCrossColor = 0

    private var mCrossLineWidth = 0f

    private var unSupportedClipPath = false

    private val mLongClickHandle = Runnable {
        if (!isMoved && !isUp) {
            val state = (parent as TagContainerLayout).getTagViewState()
            if (state == ViewDragHelper.STATE_IDLE) {
                isExecLongClick = true
                mOnTagClickListener?.onTagLongClick(tag as Int, getText())
            }
        }
    }

    constructor(context: Context, text: String?) : super(context) {
        init(context, text)
    }

    constructor(context: Context, text: String?, defaultImageID: Int) : super(context) {
        init(context, text)
        mBitmapImage = BitmapFactory.decodeResource(resources, defaultImageID)
    }

    private fun init(context: Context, text: String?) {
        mPaint = Paint(Paint.ANTI_ALIAS_FLAG)
        mRipplePaint = Paint(Paint.ANTI_ALIAS_FLAG)
        mRipplePaint.style = Paint.Style.FILL
        mRectF = RectF()
        mPath = Path()
        mOriginText = text ?: ""
        mMoveSlop = dp2px(context, mMoveSlop.toFloat()).toInt()
        mSlopThreshold = dp2px(context, mSlopThreshold.toFloat()).toInt()
    }

    private fun onDealText() {
        mAbstractText = if (!TextUtils.isEmpty(mOriginText)) {
            if (mOriginText.length <= mTagMaxLength) mOriginText
            else mOriginText.substring(0, mTagMaxLength - 3) + "..."
        } else {
            ""
        }
        mPaint.typeface = mTypeface
        mPaint.textSize = mTextSize
        val fontMetrics = mPaint.fontMetrics
        fontH = fontMetrics.descent - fontMetrics.ascent
        if (mTextDirection == View.TEXT_DIRECTION_RTL) {
            fontW = 0f
            for (c in mAbstractText.toCharArray()) {
                fontW += mPaint.measureText(c.toString())
            }
        } else {
            fontW = mPaint.measureText(mAbstractText)
        }
    }

    override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
        super.onMeasure(widthMeasureSpec, heightMeasureSpec)
        val height = mVerticalPadding * 2 + fontH.toInt()
        val width = mHorizontalPadding * 2 + fontW.toInt() + (if (isEnableCross()) height else 0) + (if (isEnableImage()) height else 0)
        mCrossAreaWidth = min(max(mCrossAreaWidth, height.toFloat()), width.toFloat())
        setMeasuredDimension(width, height)
    }

    override fun onSizeChanged(w: Int, h: Int, oldw: Int, oldh: Int) {
        super.onSizeChanged(w, h, oldw, oldh)
        mRectF.set(mBorderWidth, mBorderWidth, w - mBorderWidth, h - mBorderWidth)
    }

    override fun onDraw(canvas: Canvas) {
        // draw background
        mPaint.style = Paint.Style.FILL
        mPaint.color = if (getIsViewSelected()) mSelectedBackgroundColor else mBackgroundColor
        canvas.drawRoundRect(mRectF, mBorderRadius, mBorderRadius, mPaint)

        // draw border
        mPaint.style = Paint.Style.STROKE
        mPaint.strokeWidth = mBorderWidth
        mPaint.color = mBorderColor
        canvas.drawRoundRect(mRectF, mBorderRadius, mBorderRadius, mPaint)

        // draw ripple for TagView
        drawRipple(canvas)

        // draw text
        mPaint.style = Paint.Style.FILL
        mPaint.color = mTextColor

        if (mTextDirection == View.TEXT_DIRECTION_RTL) {
            if (mTagSupportLettersRTL) {
                var tmpX = (if (isEnableCross()) width + height else width) / 2 + fontW / 2
                for (c in mAbstractText.toCharArray()) {
                    val sc = c.toString()
                    tmpX -= mPaint.measureText(sc)
                    canvas.drawText(sc, tmpX, height / 2 + fontH / 2 - bdDistance, mPaint)
                }
            } else {
                canvas.drawText(
                    mAbstractText,
                    (if (isEnableCross()) width + fontW else width.toFloat()) / 2 - fontW / 2,
                    height / 2 + fontH / 2 - bdDistance, mPaint
                )
            }
        } else {
            canvas.drawText(
                mAbstractText,
                (if (isEnableCross()) width - height else width) / 2 - fontW / 2 + (if (isEnableImage()) height / 2 else 0),
                height / 2 + fontH / 2 - bdDistance, mPaint
            )
        }

        // draw cross
        drawCross(canvas)

        // draw image
        drawImage(canvas)
    }

    override fun dispatchTouchEvent(event: MotionEvent): Boolean {
        if (isViewClickable) {
            val y = event.y.toInt()
            val x = event.x.toInt()
            when (event.action) {
                MotionEvent.ACTION_DOWN -> {
                    parent?.requestDisallowInterceptTouchEvent(true)
                    mLastY = y
                    mLastX = x
                }
                MotionEvent.ACTION_MOVE -> {
                    if (!isViewSelected && (abs(mLastY - y) > mSlopThreshold || abs(mLastX - x) > mSlopThreshold)) {
                        parent?.requestDisallowInterceptTouchEvent(false)
                        isMoved = true
                        return false
                    }
                }
            }
        }
        return super.dispatchTouchEvent(event)
    }

    override fun onTouchEvent(event: MotionEvent): Boolean {
        val action = event.action
        if (action == MotionEvent.ACTION_DOWN) {
            mRippleRadius = 0.0f
            mTouchX = event.x
            mTouchY = event.y
            splashRipple()
        }
        val listener = mOnTagClickListener
        if (isEnableCross() && isClickCrossArea(event) && listener != null) {
            if (action == MotionEvent.ACTION_UP) {
                listener.onTagCrossClick(tag as Int)
            }
            return true
        } else if (isViewClickable && listener != null) {
            val x = event.x.toInt()
            val y = event.y.toInt()
            when (action) {
                MotionEvent.ACTION_DOWN -> {
                    mLastY = y
                    mLastX = x
                    isMoved = false
                    isUp = false
                    isExecLongClick = false
                    postDelayed(mLongClickHandle, mLongPressTime.toLong())
                }
                MotionEvent.ACTION_MOVE -> {
                    if (!isMoved && (abs(mLastX - x) > mMoveSlop || abs(mLastY - y) > mMoveSlop)) {
                        isMoved = true
                        if (isViewSelected) {
                            listener.onSelectedTagDrag(tag as Int, getText())
                        }
                    }
                }
                MotionEvent.ACTION_UP -> {
                    isUp = true
                    if (!isExecLongClick && !isMoved) {
                        listener.onTagClick(tag as Int, getText())
                    }
                }
            }
            return true
        }
        return super.onTouchEvent(event)
    }

    private fun isClickCrossArea(event: MotionEvent): Boolean {
        if (mTextDirection == View.TEXT_DIRECTION_RTL) {
            return event.x <= mCrossAreaWidth
        }
        return event.x >= width - mCrossAreaWidth
    }

    private fun drawImage(canvas: Canvas) {
        val image = mBitmapImage
        if (isEnableImage() && image != null) {
            val scaledImageBitmap = Bitmap.createScaledBitmap(image, (height - mBorderWidth).roundToInt(), (height - mBorderWidth).roundToInt(), false)

            val paint = Paint()
            paint.isAntiAlias = true
            paint.shader = BitmapShader(scaledImageBitmap, Shader.TileMode.CLAMP, Shader.TileMode.CLAMP)
            val rect = RectF(mBorderWidth, mBorderWidth, height - mBorderWidth, height - mBorderWidth)
            canvas.drawRoundRect(rect, rect.height() / 2, rect.height() / 2, paint)
        }
    }

    private fun drawCross(canvas: Canvas) {
        if (isEnableCross()) {
            mCrossAreaPadding = if (mCrossAreaPadding > height / 2) (height / 2).toFloat() else mCrossAreaPadding
            val rtl = mTextDirection == View.TEXT_DIRECTION_RTL
            val ltX = if (rtl) mCrossAreaPadding.toInt() else (width - height + mCrossAreaPadding).toInt()
            val ltY = mCrossAreaPadding.toInt()
            val lbX = if (rtl) mCrossAreaPadding.toInt() else (width - height + mCrossAreaPadding).toInt()
            val lbY = (height - mCrossAreaPadding).toInt()
            val rtX = if (rtl) (height - mCrossAreaPadding).toInt() else (width - mCrossAreaPadding).toInt()
            val rtY = mCrossAreaPadding.toInt()
            val rbX = if (rtl) (height - mCrossAreaPadding).toInt() else (width - mCrossAreaPadding).toInt()
            val rbY = (height - mCrossAreaPadding).toInt()

            mPaint.style = Paint.Style.STROKE
            mPaint.color = mCrossColor
            mPaint.strokeWidth = mCrossLineWidth
            canvas.drawLine(ltX.toFloat(), ltY.toFloat(), rbX.toFloat(), rbY.toFloat(), mPaint)
            canvas.drawLine(lbX.toFloat(), lbY.toFloat(), rtX.toFloat(), rtY.toFloat(), mPaint)
        }
    }

    private fun drawRipple(canvas: Canvas?) {
        if (isViewClickable && canvas != null && !unSupportedClipPath) {
            try {
                canvas.save()
                mPath.reset()

                canvas.clipPath(mPath)
                mPath.addRoundRect(mRectF, mBorderRadius, mBorderRadius, Path.Direction.CCW)

                // bug: https://github.com/whilu/AndroidTagView/issues/88
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    canvas.clipPath(mPath)
                } else {
                    @Suppress("DEPRECATION")
                    canvas.clipPath(mPath, Region.Op.REPLACE)
                }

                canvas.drawCircle(mTouchX, mTouchY, mRippleRadius, mRipplePaint)
                canvas.restore()
            } catch (e: UnsupportedOperationException) {
                unSupportedClipPath = true
            }
        }
    }

    private fun splashRipple() {
        if (mTouchX > 0 && mTouchY > 0) {
            mRipplePaint.color = mRippleColor
            mRipplePaint.alpha = mRippleAlpha
            val maxDis = max(max(max(mTouchX, mTouchY), abs(measuredWidth - mTouchX)), abs(measuredHeight - mTouchY))

            val animator = ValueAnimator.ofFloat(0.0f, maxDis).setDuration(mRippleDuration.toLong())
            animator.addUpdateListener { animation ->
                val animValue = animation.animatedValue as Float
                mRippleRadius = if (animValue >= maxDis) 0f else animValue
                postInvalidate()
            }
            animator.start()
            mRippleValueAnimator = animator
        }
    }

    fun getText(): String = mOriginText

    fun getIsViewClickable(): Boolean = isViewClickable

    fun getIsViewSelected(): Boolean = isViewSelected

    fun setTagMaxLength(maxLength: Int) {
        mTagMaxLength = maxLength
        onDealText()
    }

    fun setOnTagClickListener(listener: OnTagClickListener?) {
        mOnTagClickListener = listener
    }

    fun getTagBackgroundColor(): Int = mBackgroundColor

    fun getTagSelectedBackgroundColor(): Int = mSelectedBackgroundColor

    fun setTagBackgroundColor(color: Int) {
        mBackgroundColor = color
    }

    fun setTagSelectedBackgroundColor(color: Int) {
        mSelectedBackgroundColor = color
    }

    fun setTagBorderColor(color: Int) {
        mBorderColor = color
    }

    fun setTagTextColor(color: Int) {
        mTextColor = color
    }

    fun setBorderWidth(width: Float) {
        mBorderWidth = width
    }

    fun setBorderRadius(radius: Float) {
        mBorderRadius = radius
    }

    fun setTextSize(size: Float) {
        mTextSize = size
        onDealText()
    }

    fun setHorizontalPadding(padding: Int) {
        mHorizontalPadding = padding
    }

    fun setVerticalPadding(padding: Int) {
        mVerticalPadding = padding
    }

    fun setIsViewClickable(clickable: Boolean) {
        isViewClickable = clickable
    }

    fun setImage(newImage: Bitmap?) {
        mBitmapImage = newImage
        invalidate()
    }

    fun setIsViewSelectable(viewSelectable: Boolean) {
        isViewSelectable = viewSelectable
    }

    // TODO (upstream): change background color
    fun selectView() {
        if (isViewSelectable && !getIsViewSelected()) {
            isViewSelected = true
            postInvalidate()
        }
    }

    fun deselectView() {
        if (isViewSelectable && getIsViewSelected()) {
            isViewSelected = false
            postInvalidate()
        }
    }

    interface OnTagClickListener {
        fun onTagClick(position: Int, text: String)
        fun onTagLongClick(position: Int, text: String)
        fun onSelectedTagDrag(position: Int, text: String)
        fun onTagCrossClick(position: Int)
    }

    override fun getTextDirection(): Int = mTextDirection

    override fun setTextDirection(textDirection: Int) {
        mTextDirection = textDirection
    }

    fun setTypeface(typeface: Typeface?) {
        mTypeface = typeface
        onDealText()
    }

    fun setRippleAlpha(mRippleAlpha: Int) {
        this.mRippleAlpha = mRippleAlpha
    }

    fun setRippleColor(mRippleColor: Int) {
        this.mRippleColor = mRippleColor
    }

    fun setRippleDuration(mRippleDuration: Int) {
        this.mRippleDuration = mRippleDuration
    }

    fun setBdDistance(bdDistance: Float) {
        this.bdDistance = bdDistance
    }

    fun isEnableImage(): Boolean = mBitmapImage != null && mTextDirection != View.TEXT_DIRECTION_RTL

    fun isEnableCross(): Boolean = mEnableCross

    fun setEnableCross(mEnableCross: Boolean) {
        this.mEnableCross = mEnableCross
    }

    fun getCrossAreaWidth(): Float = mCrossAreaWidth

    fun setCrossAreaWidth(mCrossAreaWidth: Float) {
        this.mCrossAreaWidth = mCrossAreaWidth
    }

    fun getCrossLineWidth(): Float = mCrossLineWidth

    fun setCrossLineWidth(mCrossLineWidth: Float) {
        this.mCrossLineWidth = mCrossLineWidth
    }

    fun getCrossAreaPadding(): Float = mCrossAreaPadding

    fun setCrossAreaPadding(mCrossAreaPadding: Float) {
        this.mCrossAreaPadding = mCrossAreaPadding
    }

    fun getCrossColor(): Int = mCrossColor

    fun setCrossColor(mCrossColor: Int) {
        this.mCrossColor = mCrossColor
    }

    fun isTagSupportLettersRTL(): Boolean = mTagSupportLettersRTL

    fun setTagSupportLettersRTL(mTagSupportLettersRTL: Boolean) {
        this.mTagSupportLettersRTL = mTagSupportLettersRTL
    }
}
