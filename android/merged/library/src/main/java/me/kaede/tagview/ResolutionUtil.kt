package me.kaede.tagview

import android.content.Context
import android.util.TypedValue

internal object ResolutionUtil {

    fun dpToPx(c: Context, dipValue: Float): Int =
        TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, dipValue, c.resources.displayMetrics).toInt()

    fun spToPx(context: Context, spValue: Float): Int =
        TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_SP, spValue, context.resources.displayMetrics).toInt()

    fun getScreenWidth(context: Context): Int = context.resources.displayMetrics.widthPixels
}
