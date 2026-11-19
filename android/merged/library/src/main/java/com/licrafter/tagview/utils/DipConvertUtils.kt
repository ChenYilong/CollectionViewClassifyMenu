package com.licrafter.tagview.utils

import android.content.Context

/**
 * dp to px conversion.
 */
object DipConvertUtils {
    @JvmStatic
    fun dip2px(context: Context, dpValue: Float): Int = (dpValue * context.resources.displayMetrics.density + 0.5f).toInt()
}
