package com.licrafter.tagview.views

import android.content.Context
import android.graphics.Color
import android.util.AttributeSet
import android.util.TypedValue
import androidx.appcompat.widget.AppCompatTextView
import com.licrafter.tagview.DIRECTION
import com.licrafter.tagview.utils.DipConvertUtils

/**
 * A text tag of a TagViewGroup: white text with a soft shadow, readable on a photo, laid out on the side its
 * direction says. Text size follows the system font scale (sp).
 */
class TagTextView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null,
    defStyleAttr: Int = 0,
) : AppCompatTextView(context, attrs, defStyleAttr), ITagView {

    private var direction = DIRECTION.RIGHT_CENTER

    init {
        if (attrs == null) {
            setTextColor(Color.WHITE)
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 13f)
            setShadowLayer(3.5f, 0f, 0f, Color.argb(160, 0, 0, 0))
            val padding = DipConvertUtils.dip2px(context, 4f)
            setPadding(padding, padding / 2, padding, padding / 2)
        }
    }

    override fun getDirection(): DIRECTION = direction

    override fun setDirection(direction: DIRECTION) {
        this.direction = direction
        requestLayout()
    }
}
