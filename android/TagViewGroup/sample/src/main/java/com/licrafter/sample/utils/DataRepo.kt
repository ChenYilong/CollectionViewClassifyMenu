package com.licrafter.sample.utils

import com.licrafter.sample.model.TagGroupModel
import com.licrafter.sample.model.TagModel
import com.licrafter.tagview.DIRECTION

/**
 * The groups in memory, shared by the three screens.
 */
object DataRepo {
    var tagGroups: List<TagGroupModel> = initialGroups()

    fun initialGroups(): List<TagGroupModel> = listOf(
        TagGroupModel(
            mutableListOf(
                TagModel("头层牛皮", DIRECTION.RIGHT_TOP, "http://www.baidu.com"),
                TagModel("英伦加绒青年棕色保暖鞋子。", DIRECTION.RIGHT_CENTER, "http://blog.licrafter.com"),
                TagModel("PLAYBOY/花花公子", DIRECTION.RIGHT_BOTTOM, "http://mc.licrafter.com"),
            ),
            0.4f, 0.5f,
        ),
        TagGroupModel(mutableListOf(TagModel("很不错的鞋子", DIRECTION.RIGHT_CENTER, "http://mc.licrafter.com")), 0.3f, 0.2f),
    )
}
