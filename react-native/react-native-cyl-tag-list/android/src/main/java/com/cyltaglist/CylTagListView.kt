package com.cyltaglist

import android.content.Context
import android.widget.FrameLayout
import com.cyl.classifymenu.CYLIndexPath
import com.cyl.classifymenu.CYLMenuDelegate
import com.cyl.classifymenu.CYLTagListView
import com.cyl.classifymenu.applyConfiguration
import com.cyl.classifymenu.tagListViewWithConfiguration
import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.ReactContext
import com.facebook.react.bridge.WritableMap
import com.facebook.react.uimanager.UIManagerHelper
import com.facebook.react.uimanager.events.Event
import org.json.JSONArray
import org.json.JSONObject

/**
 * The Fabric view: holds the Kotlin CYLTagListView (com.cyl:classifymenu), built from the configuration JSON.
 */
class CylTagListView(context: Context) : FrameLayout(context), CYLMenuDelegate {

  private var tagList: CYLTagListView? = null
  private var configurationJSON = ""
  private var speed = 0f
  private var loops = false
  private var sentHeight = -1.0

  fun setConfiguration(json: String?) {
    val text = json ?: ""
    if (text == configurationJSON) return
    configurationJSON = text
    val configuration = resolve(toKotlin(JSONObject(text.ifEmpty { "{}" })))
    @Suppress("UNCHECKED_CAST")
    val map = configuration as Map<String, Any?>
    val list = tagList
    if (list != null) {
      list.applyConfiguration(map)
    } else {
      val created = CYLTagListView.tagListViewWithConfiguration(context, map)
      created.menuDelegate = this
      addView(created, LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT))
      tagList = created
      applyPlayback()
    }
    sentHeight = -1.0
    sendContentHeight()
  }

  fun setAnimationSpeed(value: Float) {
    speed = value
    applyPlayback()
  }

  fun setAnimationLoops(value: Boolean) {
    loops = value
    applyPlayback()
  }

  fun playAll() {
    tagList?.playAllAnimations()
  }

  private fun applyPlayback() {
    tagList?.animationSpeed = if (speed > 0) speed else null
    tagList?.animationLoops = loops
  }

  // React Native lays out its own views only: lay out the native list whenever it asks for it.
  override fun requestLayout() {
    super.requestLayout()
    post(measureAndLayout)
  }

  private val measureAndLayout = Runnable {
    // The list sets its content width during a layout pass and asks to be measured again. That request stops at this
    // view (still in its own layout), and measure() skips a view without the flag, so the cells kept a size of 0. Mark
    // the subtree and repeat while the list asks for more (a few passes).
    var passes = 0
    do {
      forceLayoutTree(this)
      measure(MeasureSpec.makeMeasureSpec(width, MeasureSpec.EXACTLY), MeasureSpec.makeMeasureSpec(height, MeasureSpec.EXACTLY))
      layout(left, top, right, bottom)
      passes++
    } while (passes < 3 && needsLayout(this))
    // Laid out outside a traversal (React Native does not lay out native children): draw the new frames.
    invalidateTree(this)
  }

  private fun forceLayoutTree(view: android.view.View) {
    view.forceLayout()
    if (view is android.view.ViewGroup) for (i in 0 until view.childCount) forceLayoutTree(view.getChildAt(i))
  }

  private fun invalidateTree(view: android.view.View) {
    view.invalidate()
    if (view is android.view.ViewGroup) for (i in 0 until view.childCount) invalidateTree(view.getChildAt(i))
  }

  private fun needsLayout(view: android.view.View): Boolean =
    view.isLayoutRequested || (view is android.view.ViewGroup && (0 until view.childCount).any { needsLayout(view.getChildAt(it)) })

  override fun onSizeChanged(w: Int, h: Int, oldw: Int, oldh: Int) {
    super.onSizeChanged(w, h, oldw, oldh)
    // React Native sets the size with layout(), which does not measure the native list for it.
    post(measureAndLayout)
    if (w != oldw) sendContentHeight()
  }

  private fun sendContentHeight() {
    val list = tagList ?: return
    val density = resources.displayMetrics.density
    val width = width / density
    if (width <= 0) return
    val height = list.heightThatFitsWidth(width).toDouble()
    if (kotlin.math.abs(height - sentHeight) < 0.5) return
    sentHeight = height
    dispatch("topContentHeightChange", Arguments.createMap().apply { putDouble("height", height) })
  }

  private fun item(indexPath: CYLIndexPath): Map<String, Any> = mapOf(
    "section" to indexPath.section,
    "item" to indexPath.item,
    "title" to tagList?.menuDataSource?.menuTitleForItemAtIndexPath(indexPath).orEmpty(),
  )

  override fun menuDidChangeContentHeight(menu: Any, height: Float) = sendContentHeight()

  override fun menuDidSelectItemAtIndexPath(menu: Any, indexPath: CYLIndexPath) {
    val tag = item(indexPath)
    dispatch("topTagTap", Arguments.createMap().apply {
      putInt("section", tag["section"] as Int)
      putInt("item", tag["item"] as Int)
      putString("title", tag["title"] as String)
    })
  }

  override fun menuDidLongPressItemAtIndexPath(menu: Any, indexPath: CYLIndexPath) {
    val tag = item(indexPath)
    dispatch("topTagLongPress", Arguments.createMap().apply {
      putInt("section", tag["section"] as Int)
      putInt("item", tag["item"] as Int)
      putString("title", tag["title"] as String)
    })
  }

  override fun menuDidChangeSelectedItems(menu: Any, indexPaths: List<CYLIndexPath>) {
    val json = JSONArray(indexPaths.map { JSONObject(item(it)) }).toString()
    dispatch("topSelectionChange", Arguments.createMap().apply { putString("itemsJSON", json) })
  }

  private fun dispatch(name: String, payload: WritableMap) {
    val reactContext = context as? ReactContext ?: return
    val surfaceId = UIManagerHelper.getSurfaceId(reactContext)
    UIManagerHelper.getEventDispatcherForReactTag(reactContext, id)
      ?.dispatchEvent(CylTagListEvent(surfaceId, id, name, payload))
  }

  private class CylTagListEvent(surfaceId: Int, viewId: Int, private val name: String, private val payload: WritableMap) :
    Event<CylTagListEvent>(surfaceId, viewId) {
    override fun getEventName() = name
    override fun getEventData() = payload
  }

  private companion object {
    fun toKotlin(value: Any?): Any? = when (value) {
      is JSONObject -> value.keys().asSequence().associateWith { toKotlin(value.get(it)) }
      is JSONArray -> (0 until value.length()).map { toKotlin(value.get(it)) }
      JSONObject.NULL -> null
      else -> value
    }

    /** "asset:<name>" is a file of the app's assets, which the core opens as file:///android_asset/<name>. */
    fun resolve(value: Any?): Any? = when (value) {
      is String -> if (value.startsWith("asset:")) "file:///android_asset/" + value.removePrefix("asset:") else value
      is Map<*, *> -> value.entries.associate { (key, item) -> key as String to resolve(item) }
      is List<*> -> value.map { resolve(it) }
      else -> value
    }
  }
}
