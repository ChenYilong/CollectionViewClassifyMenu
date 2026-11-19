# android-tagview (Kotlin)

A Kotlin transcription of [kaedea/android-tagview](https://github.com/kaedea/android-tagview) at `b546a5f`
(2016-06-15): the `library` module (`me.kaede.tagview`: `TagView`, `Tag`, `OnTagClickListener`,
`OnTagDeleteListener`) and the `sample` app (main screen, activity result, ListView and RecyclerView screens),
class by class and method by method. Changes: Kotlin instead of Java, AndroidX instead of the support library,
AGP 8 namespaces, minimum SDK 23.

Copyright (c) kaedea. Licensed under the Apache License, Version 2.0
(<https://www.apache.org/licenses/LICENSE-2.0>), as the original README states; this folder is a modified version
(translated to Kotlin). The sample's images (`drawable-xxhdpi`, launcher icons) are copied from the original.

Build (from this repository): `android/scripts/gradle.sh android-tagview assembleDebug`.
