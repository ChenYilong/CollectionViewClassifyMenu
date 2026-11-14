# CYLTagListView (com.cyl.classifymenu) finds these classes by name: keep them through R8.
-keep class com.cyl.tabbar.** { *; }
-keep class com.airbnb.lottie.** { *; }
-dontwarn com.cyl.tabbar.**
-dontwarn javax.annotation.Nullable
