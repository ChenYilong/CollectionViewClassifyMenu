package me.kaede.tagview

import android.util.Log

internal object LogUtil {

    const val PREFIX = "[kaede]"

    fun v(tag: String, msg: String) {
        if (!Constants.DEBUG) return
        Log.v(tag, PREFIX + msg)
    }

    fun d(tag: String, msg: String) {
        if (!Constants.DEBUG) return
        Log.d(tag, PREFIX + msg)
    }

    fun i(tag: String, msg: String) {
        Log.i(tag, PREFIX + msg)
    }

    fun w(tag: String, msg: String) {
        Log.w(tag, PREFIX + msg)
    }

    fun e(tag: String, msg: String) {
        Log.e(tag, PREFIX + msg)
    }
}
