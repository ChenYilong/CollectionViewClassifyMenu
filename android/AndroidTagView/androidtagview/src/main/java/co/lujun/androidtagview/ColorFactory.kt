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

import android.graphics.Color

/**
 * Author: lujun(http://blog.lujun.co)
 * Date: 2016-1-4 23:20
 *
 *                      ============= --border color
 *  background color---||-  Text --||--text color
 *                     =============
 */
object ColorFactory {

    const val BG_COLOR_ALPHA = "33"
    const val BD_COLOR_ALPHA = "88"

    const val RED = "F44336"
    const val LIGHTBLUE = "03A9F4"
    const val AMBER = "FFC107"
    const val ORANGE = "FF9800"
    const val YELLOW = "FFEB3B"
    const val LIME = "CDDC39"
    const val BLUE = "2196F3"
    const val INDIGO = "3F51B5"
    const val LIGHTGREEN = "8BC34A"
    const val GREY = "9E9E9E"
    const val DEEPPURPLE = "673AB7"
    const val TEAL = "009688"
    const val CYAN = "00BCD4"

    enum class PURE_COLOR { CYAN, TEAL }

    const val NONE = -1
    const val RANDOM = 0
    const val PURE_CYAN = 1
    const val PURE_TEAL = 2

    @JvmField
    val SHARP666666: Int = Color.parseColor("#FF666666")
    @JvmField
    val SHARP727272: Int = Color.parseColor("#FF727272")

    private val COLORS = arrayOf(RED, LIGHTBLUE, AMBER, ORANGE, YELLOW, LIME, BLUE, INDIGO, LIGHTGREEN, GREY, DEEPPURPLE, TEAL, CYAN)

    @JvmStatic
    fun onRandomBuild(): IntArray {
        val random = (Math.random() * COLORS.size).toInt()
        val bgColor = Color.parseColor("#" + BG_COLOR_ALPHA + COLORS[random])
        val bdColor = Color.parseColor("#" + BD_COLOR_ALPHA + COLORS[random])
        val tColor = SHARP666666
        val tColor2 = SHARP727272
        return intArrayOf(bgColor, bdColor, tColor, tColor2)
    }

    @JvmStatic
    fun onPureBuild(type: PURE_COLOR): IntArray {
        val color = if (type == PURE_COLOR.CYAN) CYAN else TEAL
        val bgColor = Color.parseColor("#" + BG_COLOR_ALPHA + color)
        val bdColor = Color.parseColor("#" + BD_COLOR_ALPHA + color)
        val tColor = SHARP727272
        val tColor2 = SHARP666666
        return intArrayOf(bgColor, bdColor, tColor, tColor2)
    }
}
