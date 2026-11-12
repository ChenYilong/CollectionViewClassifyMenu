# AndroidTagView (Kotlin)

A Kotlin transcription of [whilu/AndroidTagView](https://github.com/whilu/AndroidTagView) at `75a3bba`
(2019-03-16): the `androidtagview` module (`co.lujun.androidtagview`: `TagContainerLayout`, `TagView`,
`ColorFactory`, `Utils`) and the `sample` app, method by method. Changes: Kotlin instead of Java, AGP 8
namespaces, minimum SDK 23 (the API 11–17 software-layer workaround is gone), Glide 4.16 `CustomTarget` for the
removed `SimpleTarget`, `startDragAndDrop` for the deprecated `startDrag`. `TagView` overrides
`View.getTextDirection`/`setTextDirection`, as the Java class did implicitly.

Copyright 2015 lujun. Licensed under the Apache License, Version 2.0
(<https://www.apache.org/licenses/LICENSE-2.0>); every file keeps the original notice and says it was translated
to Kotlin. The sample's images (`yellow_avatar.png`, launcher icons) are copied from the original.

Build (from this repository): `android/scripts/gradle.sh AndroidTagView assembleDebug`.
