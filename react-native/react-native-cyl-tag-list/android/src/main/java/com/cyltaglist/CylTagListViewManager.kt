package com.cyltaglist

import com.facebook.react.common.MapBuilder
import com.facebook.react.module.annotations.ReactModule
import com.facebook.react.uimanager.SimpleViewManager
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.ViewManagerDelegate
import com.facebook.react.viewmanagers.CylTagListViewManagerDelegate
import com.facebook.react.viewmanagers.CylTagListViewManagerInterface

/**
 * The manager of the Fabric view CylTagListView: props, the playAll command and the direct events.
 */
@ReactModule(name = CylTagListViewManager.NAME)
class CylTagListViewManager : SimpleViewManager<CylTagListView>(), CylTagListViewManagerInterface<CylTagListView> {
  private val delegate = CylTagListViewManagerDelegate(this)

  override fun getDelegate(): ViewManagerDelegate<CylTagListView> = delegate

  override fun getName() = NAME

  override fun createViewInstance(context: ThemedReactContext) = CylTagListView(context)

  override fun setConfiguration(view: CylTagListView, value: String?) = view.setConfiguration(value)

  override fun setAnimationSpeed(view: CylTagListView, value: Float) = view.setAnimationSpeed(value)

  override fun setAnimationLoops(view: CylTagListView, value: Boolean) = view.setAnimationLoops(value)

  override fun playAll(view: CylTagListView) = view.playAll()

  override fun getExportedCustomDirectEventTypeConstants(): MutableMap<String, Any> = MapBuilder.of(
    "topTagTap", MapBuilder.of("registrationName", "onTagTap"),
    "topTagLongPress", MapBuilder.of("registrationName", "onTagLongPress"),
    "topSelectionChange", MapBuilder.of("registrationName", "onSelectionChange"),
    "topContentHeightChange", MapBuilder.of("registrationName", "onContentHeightChange"),
  )

  companion object {
    const val NAME = "CylTagListView"
  }
}
