package com.cyl.cyl_tag_list

import android.content.Context
import android.view.View
import com.cyl.classifymenu.CYLIndexPath
import com.cyl.classifymenu.CYLMenuDelegate
import com.cyl.classifymenu.CYLTagListView
import com.cyl.classifymenu.applyConfiguration
import com.cyl.classifymenu.tagListViewWithConfiguration
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

/** Registers the platform view of `CylTagListView`: the Kotlin `CYLTagListView` of android/merged. */
class CylTagListPlugin : FlutterPlugin {
    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        binding.platformViewRegistry.registerViewFactory(VIEW_TYPE, CylTagListViewFactory(binding.binaryMessenger, binding.flutterAssets))
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) = Unit

    companion object {
        const val VIEW_TYPE = "com.cyl.cyl_tag_list/view"
    }
}

internal class CylTagListViewFactory(
    private val messenger: BinaryMessenger,
    private val assets: FlutterPlugin.FlutterAssets,
) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context, viewId: Int, args: Any?): PlatformView =
        CylTagListPlatformView(context, viewId, args, messenger, assets)
}

/** A `CYLTagListView` created from the configuration map Dart sends, and the method channel that drives it. */
internal class CylTagListPlatformView(
    context: Context,
    viewId: Int,
    args: Any?,
    messenger: BinaryMessenger,
    private val assets: FlutterPlugin.FlutterAssets,
) : PlatformView, CYLMenuDelegate, MethodChannel.MethodCallHandler {

    private val channel = MethodChannel(messenger, "${CylTagListPlugin.VIEW_TYPE}/$viewId")
    private val tagList: CYLTagListView

    init {
        @Suppress("UNCHECKED_CAST")
        val configuration = ((args as? Map<String, Any?>)?.get("configuration") as? Map<String, Any?>).orEmpty()
        tagList = CYLTagListView.tagListViewWithConfiguration(context, resolved(configuration))
        tagList.menuDelegate = this
        channel.setMethodCallHandler(this)
        // The height for the width Flutter gives the view, sent whenever that width changes (Dart may size the view
        // to it, so the view's own height says nothing).
        tagList.addOnLayoutChangeListener { view, left, _, right, _, oldLeft, _, oldRight, _ ->
            if (right - left != oldRight - oldLeft) sendContentHeight()
        }
    }

    private var sentHeight = -1.0

    private fun sendContentHeight() {
        val width = tagList.width / tagList.resources.displayMetrics.density
        if (width <= 0) return
        val height = tagList.heightThatFitsWidth(width).toDouble()
        if (kotlin.math.abs(height - sentHeight) < 0.5) return
        sentHeight = height
        channel.invokeMethod("onContentHeight", height)
    }

    override fun getView(): View = tagList

    override fun dispose() {
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "playAll" -> tagList.playAllAnimations()
            "setSpeed" -> tagList.animationSpeed = (call.arguments as? Number)?.toFloat()
            "setLoops" -> tagList.animationLoops = call.arguments as? Boolean ?: false
            "applyConfiguration" -> {
                @Suppress("UNCHECKED_CAST")
                (call.arguments as? Map<String, Any?>)?.let { tagList.applyConfiguration(resolved(it)) }
            }
            "contentHeight" -> {
                result.success(tagList.heightThatFitsWidth(tagList.width / tagList.resources.displayMetrics.density).toDouble())
                return
            }
            "state" -> {
                val source = tagList.menuDataSource
                val tagCount = (0 until (source?.numberOfSectionsInMenu() ?: 0)).sumOf { source?.menuNumberOfItemsInSection(it) ?: 0 }
                val state = mutableMapOf<String, Any?>("loops" to tagList.animationLoops, "tagCount" to tagCount)
                tagList.animationSpeed?.let { state["speed"] = it.toDouble() }
                result.success(state)
                return
            }
            else -> {
                result.notImplemented()
                return
            }
        }
        result.success(null)
    }

    override fun menuDidChangeContentHeight(menu: Any, height: Float) = sendContentHeight()

    override fun menuDidSelectItemAtIndexPath(menu: Any, indexPath: CYLIndexPath) {
        val title = tagList.menuDataSource?.menuTitleForItemAtIndexPath(indexPath).orEmpty()
        channel.invokeMethod("onTap", mapOf("section" to indexPath.section, "item" to indexPath.item, "title" to title))
    }

    /** "asset:<key>" becomes the Flutter asset inside the APK, which the core opens as file:///android_asset/… */
    @Suppress("UNCHECKED_CAST")
    private fun resolved(value: Map<String, Any?>): Map<String, Any?> = resolve(value) as Map<String, Any?>

    private fun resolve(value: Any?): Any? = when (value) {
        is String -> if (value.startsWith("asset:")) "file:///android_asset/" + assets.getAssetFilePathByName(value.removePrefix("asset:")) else value
        is Map<*, *> -> value.entries.associate { (key, item) -> key as String to resolve(item) }
        is List<*> -> value.map { resolve(it) }
        else -> value
    }
}
