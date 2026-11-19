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
import android.graphics.Outline
import android.graphics.Paint
import android.graphics.Path
import android.graphics.RectF
import android.graphics.Region
import android.graphics.Shader
import android.graphics.Typeface
import android.graphics.drawable.Drawable
import android.os.Build
import android.text.StaticLayout
import android.text.TextPaint
import android.text.TextUtils
import android.view.MotionEvent
import android.view.View
import android.view.ViewOutlineProvider
import androidx.customview.widget.ViewDragHelper
import co.lujun.androidtagview.Utils.dp2px
import kotlin.math.abs
import kotlin.math.ceil
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

    /**
     * The text color of a selected tag (issues #29 / #114); null keeps `mTextColor`.
     */
    private var mSelectedTextColor: Int? = null

    /**
     * The tag's minimum width in pixels (issues #73 / #75: tags of the same size).
     */
    private var mMinWidth = 0

    /**
     * A tap selects or deselects the tag (issues #12 / #22 / #123), through the container when it has one so that
     * single selection applies.
     */
    var selectOnClick = false

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

    /**
     * The distance between baseline and descent. Issue #104: null (the default) centres the text on its font
     * metrics; a value set by the caller keeps the old formula, which left the text about 2 dp low.
     */
    private var bdDistance: Float? = null

    /**
     * The widest the tag may be, in pixels (0: no limit). The container sets its own width, so a long tag, with or
     * without a cross, is never cut off at the container's edge (issues #60 / #66).
     */
    private var mMaxWidth = 0

    /**
     * Issue #19: text wider than the maximum width wraps onto more lines instead of being shortened with an ellipsis.
     */
    private var mTextWrap = false

    private var mTextLayout: StaticLayout? = null
    private var mDrawText: String = ""
    private var mTextW = 0f
    private var mTextH = 0f

    /**
     * The side of the square of the image and the cross: the height of a one-line tag.
     */
    private var mAccessorySize = 0

    /**
     * Issue #105: extra space between the text and the cross, in pixels.
     */
    private var mCrossSpacing = 0

    /**
     * Issue #101: drawables at the start, top, end and bottom of the text, each a square as tall as the text.
     */
    private val mDrawables = arrayOfNulls<Drawable>(4)

    private var mDrawablePadding = 0

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

    private var mScaledImage: Bitmap? = null
    private var mScaledImageSource: Bitmap? = null

    private var mEnableCross = false

    private var mCrossAreaWidth = 0f

    private var mCrossAreaPadding = 0f

    private var mCrossColor = 0

    private var mCrossLineWidth = 0f

    /**
     * Issues #70 / #118: a drawable drawn in the cross's square instead of the two lines; null draws the lines.
     */
    private var mCrossDrawable: Drawable? = null

    private var unSupportedClipPath = false

    private val mLongClickHandle = Runnable {
        if (!isMoved && !isUp) {
            // Issues #25 / #38 / #53 / #83 / #87 / #92: the tag may have left its container (removed, recycled) before
            // the long press fired; the unchecked cast of `parent` crashed with a NullPointerException.
            val state = (parent as? TagContainerLayout)?.getTagViewState() ?: return@Runnable
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
        mBitmapImage = decodeSharedImage(context, defaultImageID)
    }

    companion object {
        private val sharedImages = HashMap<Int, java.lang.ref.WeakReference<Bitmap>>()

        /**
         * Issue #86: every tag decoded its own full-size copy of the default image (scaled up for the screen density),
         * and the sample ran out of memory at launch. The image is decoded once per resource, at most 256 px, and
         * shared by the tags.
         */
        internal fun decodeSharedImage(context: Context, resId: Int): Bitmap? {
            sharedImages[resId]?.get()?.let { return it }
            val bounds = BitmapFactory.Options().apply { inJustDecodeBounds = true }
            BitmapFactory.decodeResource(context.resources, resId, bounds)
            var sample = 1
            while (bounds.outWidth / (sample * 2) >= 256 && bounds.outHeight / (sample * 2) >= 256) sample *= 2
            val bitmap = BitmapFactory.decodeResource(context.resources, resId, BitmapFactory.Options().apply { inSampleSize = sample })
            if (bitmap != null) sharedImages[resId] = java.lang.ref.WeakReference(bitmap)
            return bitmap
        }
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
        // Issues #23 / #32 / #39: 4–5 dp is below the system's touch slop, so the slight movement of a finger (more on
        // some devices) turned taps into moves and they were lost; the thresholds are at least the system's slop.
        val touchSlop = android.view.ViewConfiguration.get(context).scaledTouchSlop
        mMoveSlop = maxOf(mMoveSlop, touchSlop)
        mSlopThreshold = maxOf(mSlopThreshold, touchSlop)
        // Issue #79: a rounded outline, so an elevation casts a shadow of the tag's shape.
        outlineProvider = object : ViewOutlineProvider() {
            override fun getOutline(view: View, outline: Outline) {
                outline.setRoundRect(0, 0, view.width, view.height, mBorderRadius)
                // A translucent background casts a lighter shadow (it showed through as a dark band).
                val alpha = android.graphics.Color.alpha(mBackgroundColor) / 255f
                outline.alpha = alpha * alpha
            }
        }
    }

    private fun onDealText() {
        mAbstractText = if (!TextUtils.isEmpty(mOriginText)) {
            // A tag made without a container has no maximum length (0); substring(0, -3) crashed.
            if (mTagMaxLength <= 0 || mOriginText.length <= mTagMaxLength) mOriginText
            else mOriginText.substring(0, max(0, mTagMaxLength - 3)) + "..."
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

    private fun drawableSize(): Int = ceil(fontH).toInt()

    private fun drawableSpace(index: Int): Int = if (mDrawables[index] != null) drawableSize() + mDrawablePadding else 0

    private fun accessoriesWidth(): Int =
        (if (isEnableCross()) mAccessorySize + mCrossSpacing else 0) + (if (isEnableImage()) mAccessorySize else 0)

    override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
        mAccessorySize = mVerticalPadding * 2 + fontH.toInt()
        val fixedW = mHorizontalPadding * 2 + drawableSpace(0) + drawableSpace(2) + accessoriesWidth()
        mDrawText = mAbstractText
        mTextLayout = null
        mTextW = fontW
        mTextH = fontH
        if (mMaxWidth > 0 && fixedW + ceil(fontW) > mMaxWidth) {
            val available = max(1, mMaxWidth - fixedW)
            val textPaint = TextPaint(mPaint).apply { style = Paint.Style.FILL }
            if (mTextWrap) {
                val layout = StaticLayout.Builder.obtain(mAbstractText, 0, mAbstractText.length, textPaint, available)
                    .setIncludePad(false).build()
                mTextLayout = layout
                mTextW = (0 until layout.lineCount).maxOf { layout.getLineWidth(it) }
                mTextH = layout.height.toFloat()
            } else {
                val ellipsis = "\u2026"
                val fit = mPaint.breakText(mAbstractText, true, max(0f, available - mPaint.measureText(ellipsis)), null)
                mDrawText = mAbstractText.substring(0, fit).trimEnd() + ellipsis
                mTextW = mPaint.measureText(mDrawText)
            }
        }
        val height = max(max(mAccessorySize, suggestedMinimumHeight),
            mVerticalPadding * 2 + ceil(mTextH).toInt() + drawableSpace(1) + drawableSpace(3))
        var width = max(mMinWidth, fixedW + ceil(mTextW).toInt())
        if (mMaxWidth > 0) width = min(width, max(mMaxWidth, mMinWidth))
        mCrossAreaWidth = min(max(mCrossAreaWidth, mAccessorySize.toFloat()), width.toFloat())
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
        mPaint.color = if (getIsViewSelected()) mSelectedTextColor ?: mTextColor else mTextColor

        val rtl = mTextDirection == View.TEXT_DIRECTION_RTL
        val leftAccessory = (if (isEnableImage()) mAccessorySize else 0) +
            (if (rtl && isEnableCross()) mAccessorySize + mCrossSpacing else 0)
        val rightAccessory = if (!rtl && isEnableCross()) mAccessorySize + mCrossSpacing else 0
        val startSpace = drawableSpace(0)
        val blockW = startSpace + mTextW + drawableSpace(2)
        val textLeft = leftAccessory + (width - leftAccessory - rightAccessory - blockW) / 2f + startSpace
        val blockH = drawableSpace(1) + mTextH + drawableSpace(3)
        val textTop = (height - blockH) / 2f + drawableSpace(1)
        drawDrawables(canvas, textLeft, textTop)

        val layout = mTextLayout
        if (layout != null) {
            layout.paint.color = mPaint.color
            canvas.save()
            canvas.translate(textLeft, textTop)
            layout.draw(canvas)
            canvas.restore()
        } else {
            val fontMetrics = mPaint.fontMetrics
            val baseline = bdDistance?.let { textTop + fontH - it } ?: (textTop - fontMetrics.ascent)
            if (rtl && mTagSupportLettersRTL) {
                var tmpX = textLeft + mTextW
                for (c in mDrawText.toCharArray()) {
                    val sc = c.toString()
                    tmpX -= mPaint.measureText(sc)
                    canvas.drawText(sc, tmpX, baseline, mPaint)
                }
            } else {
                canvas.drawText(mDrawText, textLeft, baseline, mPaint)
            }
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

    override fun onDetachedFromWindow() {
        // A pending long press never fires for a tag that left the window (issues #25, #53).
        removeCallbacks(mLongClickHandle)
        super.onDetachedFromWindow()
    }

    override fun onTouchEvent(event: MotionEvent): Boolean {
        val action = event.actionMasked
        if (action == MotionEvent.ACTION_CANCEL) {
            // Issue #39: a parent (a list) took the gesture over: no click, and no long press later.
            isUp = true
            isMoved = true
            removeCallbacks(mLongClickHandle)
        }
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
        } else if (isViewClickable && (listener != null || selectOnClick)) {
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
                            listener?.onSelectedTagDrag(tag as Int, getText())
                        }
                    }
                }
                MotionEvent.ACTION_UP -> {
                    isUp = true
                    removeCallbacks(mLongClickHandle)
                    if (!isExecLongClick && !isMoved) {
                        if (selectOnClick && isViewSelectable) {
                            val container = parent as? TagContainerLayout
                            if (container != null) container.toggleSelectTagView(tag as Int)
                            else if (isViewSelected) deselectView() else selectView()
                        }
                        listener?.onTagClick(tag as Int, getText())
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

    private fun drawDrawables(canvas: Canvas, textLeft: Float, textTop: Float) {
        val size = drawableSize()
        val centerX = textLeft + mTextW / 2
        val centerY = textTop + mTextH / 2
        val lefts = floatArrayOf(textLeft - mDrawablePadding - size, centerX - size / 2f, textLeft + mTextW + mDrawablePadding, centerX - size / 2f)
        val tops = floatArrayOf(centerY - size / 2f, textTop - mDrawablePadding - size, centerY - size / 2f, textTop + mTextH + mDrawablePadding)
        for (i in 0 until 4) {
            val drawable = mDrawables[i] ?: continue
            val l = lefts[i].roundToInt()
            val t = tops[i].roundToInt()
            drawable.setBounds(l, t, l + size, t + size)
            drawable.draw(canvas)
        }
    }

    private fun drawImage(canvas: Canvas) {
        val image = mBitmapImage
        if (isEnableImage() && image != null) {
            val side = (mAccessorySize - mBorderWidth * 2).roundToInt().coerceAtLeast(1)
            // Issue #86: the scaled copy is made once per size, not on every draw.
            var scaledImageBitmap = mScaledImage
            if (scaledImageBitmap == null || mScaledImageSource !== image || scaledImageBitmap.width != side) {
                scaledImageBitmap = Bitmap.createScaledBitmap(image, side, side, true)
                mScaledImage = scaledImageBitmap
                mScaledImageSource = image
            }
            val top = (height - mAccessorySize) / 2f
            val paint = Paint()
            paint.isAntiAlias = true
            val rect = RectF(mBorderWidth, top + mBorderWidth, mBorderWidth + side, top + mBorderWidth + side)
            val shader = BitmapShader(scaledImageBitmap, Shader.TileMode.CLAMP, Shader.TileMode.CLAMP)
            shader.setLocalMatrix(android.graphics.Matrix().apply { setTranslate(rect.left, rect.top) })
            paint.shader = shader
            canvas.drawRoundRect(rect, rect.height() / 2, rect.height() / 2, paint)
        }
    }

    /**
     * The area the cross (or its drawable) is drawn in: the square as tall as a one-line tag, at the end (the start in
     * RTL), inset by the cross padding. Issue #111: the padding was allowed up to half the square, which shrank the
     * cross to a point and left an empty space; it now keeps the cross at least a third of the square.
     */
    internal fun crossBounds(): RectF {
        val side = mAccessorySize.toFloat()
        val padding = min(mCrossAreaPadding, side / 3f)
        val top = (height - side) / 2f
        val left = if (mTextDirection == View.TEXT_DIRECTION_RTL) 0f else width - side
        return RectF(left + padding, top + padding, left + side - padding, top + side - padding)
    }

    private fun drawCross(canvas: Canvas) {
        if (isEnableCross()) {
            val bounds = crossBounds()
            val drawable = mCrossDrawable
            if (drawable != null) {
                drawable.setBounds(bounds.left.roundToInt(), bounds.top.roundToInt(), bounds.right.roundToInt(), bounds.bottom.roundToInt())
                drawable.draw(canvas)
                return
            }
            mPaint.style = Paint.Style.STROKE
            mPaint.color = mCrossColor
            mPaint.strokeWidth = mCrossLineWidth
            canvas.drawLine(bounds.left, bounds.top, bounds.right, bounds.bottom, mPaint)
            canvas.drawLine(bounds.left, bounds.bottom, bounds.right, bounds.top, mPaint)
        }
    }

    private fun drawRipple(canvas: Canvas?) {
        if (isViewClickable && canvas != null && !unSupportedClipPath) {
            try {
                canvas.save()
                mPath.reset()

                // Issue #122: the clip used to be set to the empty path first, which hid the ripple entirely.
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
        invalidateOutline()
        // Issue #20: a change after the tag is shown (per tag, through getTagView) is drawn at once.
        postInvalidate()
    }

    fun setTagSelectedBackgroundColor(color: Int) {
        mSelectedBackgroundColor = color
        // Issue #20: a change after the tag is shown (per tag, through getTagView) is drawn at once.
        postInvalidate()
    }

    fun setTagBorderColor(color: Int) {
        mBorderColor = color
        // Issue #20: a change after the tag is shown (per tag, through getTagView) is drawn at once.
        postInvalidate()
    }

    /**
     * The text color of a selected tag (issues #29 / #114); null keeps the text color.
     */
    fun setTagSelectedTextColor(color: Int?) {
        mSelectedTextColor = color
        postInvalidate()
    }

    /**
     * The minimum width of the tag, in pixels (issues #73 / #75).
     */
    fun setTagMinWidth(width: Int) {
        mMinWidth = width
        requestLayout()
    }

    fun setTagTextColor(color: Int) {
        mTextColor = color
        // Issue #20: a change after the tag is shown (per tag, through getTagView) is drawn at once.
        postInvalidate()
    }

    fun setBorderWidth(width: Float) {
        mBorderWidth = width
    }

    fun setBorderRadius(radius: Float) {
        mBorderRadius = radius
        invalidateOutline()
    }

    /**
     * The widest the tag may be, in pixels; 0 removes the limit. Longer text is shortened with an ellipsis, or
     * wrapped when [setTextWrap] is on (issues #19 / #60 / #66). The container sets it to its own content width.
     */
    fun setTagMaxWidth(width: Int) {
        if (mMaxWidth != width) {
            mMaxWidth = width
            requestLayout()
        }
    }

    fun getTagMaxWidth(): Int = mMaxWidth

    /**
     * Wraps text wider than the maximum width onto more lines instead of shortening it (issue #19).
     */
    fun setTextWrap(wrap: Boolean) {
        mTextWrap = wrap
        requestLayout()
    }

    fun isTextWrap(): Boolean = mTextWrap

    /**
     * The number of text lines drawn: more than 1 only when the text wraps.
     */
    fun getTextLineCount(): Int = mTextLayout?.lineCount ?: 1

    /**
     * The text drawn, which ends with an ellipsis when it was shortened to fit the maximum width.
     */
    fun getDisplayedText(): String = mDrawText

    /**
     * Extra space between the text and the cross, in pixels (issue #105).
     */
    fun setCrossSpacing(spacing: Int) {
        mCrossSpacing = spacing
        requestLayout()
    }

    fun getCrossSpacing(): Int = mCrossSpacing

    /**
     * Drawables around the text (issue #101), each drawn as a square as tall as the text; null removes one.
     */
    fun setTagDrawables(start: Drawable?, top: Drawable?, end: Drawable?, bottom: Drawable?) {
        mDrawables[0] = start
        mDrawables[1] = top
        mDrawables[2] = end
        mDrawables[3] = bottom
        requestLayout()
        invalidate()
    }

    /**
     * The drawables around the text: start, top, end, bottom.
     */
    fun getTagDrawables(): Array<Drawable?> = mDrawables.copyOf()

    /**
     * The space between the text and its drawables, in pixels (issue #101).
     */
    fun setTagDrawablePadding(padding: Int) {
        mDrawablePadding = padding
        requestLayout()
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
        mScaledImage = null
        invalidate()
    }

    /**
     * The image drawn at the start of the tag (a downsampled, shared copy for the container's default image).
     */
    fun getImage(): Bitmap? = mBitmapImage

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

    /**
     * The distance between the baseline and the bottom of the text; null (the default) centres the text on its
     * font metrics (issue #104).
     */
    fun setBdDistance(bdDistance: Float?) {
        this.bdDistance = bdDistance
        invalidate()
    }

    fun isEnableImage(): Boolean = mBitmapImage != null && mTextDirection != View.TEXT_DIRECTION_RTL

    fun isEnableCross(): Boolean = mEnableCross

    /**
     * Shows or hides this tag's cross (delete icon). Issue #119: one tag can differ from the container's setting,
     * for example an "+ Add" tag without a cross; the tag is measured and drawn again at once.
     */
    fun setEnableCross(mEnableCross: Boolean) {
        if (this.mEnableCross != mEnableCross) {
            this.mEnableCross = mEnableCross
            requestLayout()
            invalidate()
        }
    }

    /**
     * A drawable for the cross (delete icon) instead of the two drawn lines (issues #70 / #118); null restores them.
     */
    fun setCrossDrawable(drawable: Drawable?) {
        mCrossDrawable = drawable
        invalidate()
    }

    fun getCrossDrawable(): Drawable? = mCrossDrawable

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
