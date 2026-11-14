package com.licrafter.sample.utils

import android.content.Context
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.LinearGradient
import android.graphics.Paint
import android.graphics.RectF
import android.graphics.Shader
import com.licrafter.sample.R

/**
 * The sample's pictures, drawn in code (the original sample's photo is not copied): a diagonal gradient with two soft
 * shapes, in three palettes (shoes, bag, clothes), and a spoken name for each.
 */
object SamplePictures {

    private val palettes = listOf(
        Triple(Color.rgb(140, 107, 84), Color.rgb(217, 194, 168), R.string.picture_shoes),
        Triple(Color.rgb(64, 89, 128), Color.rgb(179, 204, 230), R.string.picture_bag),
        Triple(Color.rgb(77, 115, 89), Color.rgb(199, 224, 191), R.string.picture_clothes),
    )

    fun picture(index: Int, size: Int = 750): Bitmap {
        val (dark, light, _) = palettes[index % palettes.size]
        val bitmap = Bitmap.createBitmap(size, size, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)
        val paint = Paint(Paint.ANTI_ALIAS_FLAG)
        paint.shader = LinearGradient(0f, 0f, size.toFloat(), size.toFloat(), light, dark, Shader.TileMode.CLAMP)
        canvas.drawRect(0f, 0f, size.toFloat(), size.toFloat(), paint)
        paint.shader = null
        paint.color = Color.argb(140, 255, 255, 255)
        val s = size.toFloat()
        canvas.drawOval(RectF(s * 0.30f, s * 0.38f, s * 0.46f, s * 0.70f), paint)
        canvas.drawOval(RectF(s * 0.54f, s * 0.28f, s * 0.70f, s * 0.60f), paint)
        return bitmap
    }

    fun description(context: Context, index: Int): String = context.getString(palettes[index % palettes.size].third)
}
