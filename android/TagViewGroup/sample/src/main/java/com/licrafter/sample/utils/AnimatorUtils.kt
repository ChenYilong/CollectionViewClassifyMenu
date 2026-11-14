package com.licrafter.sample.utils

import android.animation.Animator
import android.animation.AnimatorSet
import android.animation.ObjectAnimator
import android.animation.PropertyValuesHolder
import com.licrafter.tagview.TagViewGroup

/**
 * Show and hide animators of a TagViewGroup, built on its animation properties: the dot springs out, then the lines
 * grow and the tags fade in; hiding runs it backwards.
 */
object AnimatorUtils {

    fun getTagShowAnimator(group: TagViewGroup): Animator {
        val radius = group.getCircleRadius()
        val inner = group.getCircleInnerRadius()
        val circle = ObjectAnimator.ofPropertyValuesHolder(
            group,
            PropertyValuesHolder.ofInt(TagViewGroup.CIRCLE_RADIUS, 0, radius * 3 / 2, radius),
            PropertyValuesHolder.ofInt(TagViewGroup.CIRCLE_INNER_RADIUS, 0, inner * 3 / 2, inner),
        ).setDuration(400)
        val lines = ObjectAnimator.ofFloat(group, TagViewGroup.LINES_RATIO, 0f, 1f).setDuration(300)
        val alpha = ObjectAnimator.ofFloat(group, TagViewGroup.TAG_ALPHA, 0f, 1f).setDuration(300)
        return AnimatorSet().apply {
            play(circle).before(lines)
            play(lines).with(alpha)
        }
    }

    fun getTagHideAnimator(group: TagViewGroup): Animator {
        val alpha = ObjectAnimator.ofFloat(group, TagViewGroup.TAG_ALPHA, 1f, 0f).setDuration(200)
        val lines = ObjectAnimator.ofFloat(group, TagViewGroup.LINES_RATIO, 1f, 0f).setDuration(200)
        val circle = ObjectAnimator.ofPropertyValuesHolder(
            group,
            PropertyValuesHolder.ofInt(TagViewGroup.CIRCLE_RADIUS, group.getCircleRadius(), 0),
            PropertyValuesHolder.ofInt(TagViewGroup.CIRCLE_INNER_RADIUS, group.getCircleInnerRadius(), 0),
        ).setDuration(200)
        return AnimatorSet().apply {
            play(alpha).with(lines)
            play(circle).after(lines)
        }
    }
}
