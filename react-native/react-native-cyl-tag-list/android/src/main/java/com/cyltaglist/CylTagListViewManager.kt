package com.cyltaglist

import android.graphics.Color
import com.facebook.react.module.annotations.ReactModule
import com.facebook.react.uimanager.SimpleViewManager
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.ViewManagerDelegate
import com.facebook.react.uimanager.annotations.ReactProp
import com.facebook.react.viewmanagers.CylTagListViewManagerInterface
import com.facebook.react.viewmanagers.CylTagListViewManagerDelegate

@ReactModule(name = CylTagListViewManager.NAME)
class CylTagListViewManager : SimpleViewManager<CylTagListView>(),
  CylTagListViewManagerInterface<CylTagListView> {
  private val mDelegate: ViewManagerDelegate<CylTagListView>

  init {
    mDelegate = CylTagListViewManagerDelegate(this)
  }

  override fun getDelegate(): ViewManagerDelegate<CylTagListView>? {
    return mDelegate
  }

  override fun getName(): String {
    return NAME
  }

  public override fun createViewInstance(context: ThemedReactContext): CylTagListView {
    return CylTagListView(context)
  }

  @ReactProp(name = "color")
  override fun setColor(view: CylTagListView?, color: Int?) {
    view?.setBackgroundColor(color ?: Color.TRANSPARENT)
  }

  companion object {
    const val NAME = "CylTagListView"
  }
}
