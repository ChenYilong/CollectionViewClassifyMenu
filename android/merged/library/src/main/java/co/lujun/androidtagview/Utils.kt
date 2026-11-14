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

import android.content.Context
import android.graphics.Color
import kotlin.math.min
import kotlin.math.roundToInt

/**
 * Author: lujun(http://blog.lujun.co)
 * Date: 2016-12-7 21:53
 */
object Utils {

    @JvmStatic
    fun dp2px(context: Context, dp: Float): Float {
        val scale = context.resources.displayMetrics.density
        return dp * scale + 0.5f
    }

    @JvmStatic
    @Suppress("DEPRECATION")
    fun sp2px(context: Context, sp: Float): Float {
        val scale = context.resources.displayMetrics.scaledDensity
        return sp * scale
    }

    /**
     * If the color is dark, make it lighter and vice versa.
     *
     * @param color in int
     * @param factor the factor greater than 0.0 and smaller than 1.0
     * @return int
     */
    @JvmStatic
    fun manipulateColorBrightness(color: Int, factor: Float): Int {
        val a = Color.alpha(color)
        var r = Color.red(color)
        var g = Color.green(color)
        var b = Color.blue(color)
        if (r > 127) r = 255 - ((255 - r) * factor).roundToInt()
        if (g > 127) g = 255 - ((255 - g) * factor).roundToInt()
        if (b > 127) b = 255 - ((255 - b) * factor).roundToInt()
        return Color.argb(a, min(r, 255), min(g, 255), min(b, 255))
    }
}
