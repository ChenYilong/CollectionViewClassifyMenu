// The example: one CYLTabBarController (by commit, see ../settings.gradle.kts) with a tab per example.
plugins {
    alias(libs.plugins.android.application)
    alias(libs.plugins.kotlin.android)
}

android {
    // The shared example database of every platform (Example-Shared/Database/cyl_places.sqlite, docs/cross-platform.md).
    sourceSets["main"].assets.srcDir("../../../Example-Shared/Database")
    // The iOS examples' bundles (strings, data, animations), each under its own folder: see copyExampleBundles.
    sourceSets["main"].assets.srcDir(layout.buildDirectory.dir("generated/cylBundles"))
    // The menu example's tab icons and Lottie images (its Assets.xcassets), as drawables: see copyExampleImages.
    sourceSets["main"].res.srcDir(layout.buildDirectory.dir("generated/cylRes"))
    namespace = "com.cyl.classifymenu.example"
    compileSdk = 35
    defaultConfig {
        applicationId = "com.cyl.classifymenu.example"
        minSdk = 23
        targetSdk = 35
        versionCode = 1
        versionName = "1.0"
    }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    kotlinOptions {
        jvmTarget = "17"
    }
    testOptions {
        unitTests.isIncludeAndroidResources = true
    }
}

dependencies {
    implementation(project(":library"))
    // CYLTabBarController for Android: the commit in gradle.properties, built from source by the included build.
    implementation("io.github.chenyilong:cyltabbarcontroller:0.0.0")
    implementation(libs.androidx.appcompat)
    implementation(libs.androidx.fragment.ktx)
    implementation(libs.androidx.recyclerview)
    implementation(libs.androidx.coordinatorlayout)
    implementation(libs.material)
    implementation(libs.glide)
    // Animated tag icons (the Styles and Animations screens of the menu example): CYLTabBarController's animation
    // engine registers Lottie, PAG and Rive when their libraries are present (GIF needs none).
    implementation(libs.lottie)
    implementation(libs.libpag)
    implementation(libs.rive)
    testImplementation(libs.junit)
    testImplementation(libs.robolectric)
    testImplementation(libs.androidx.test.core)
}

// The iOS examples' resource bundles, used as they are (no copies in the repository): CYLTagEditorExample.bundle
// (Example-Swift) and CYLMenuExample.bundle (Example), synced into build/generated/cylBundles before every build and
// read as assets under their own folder names (<Name>.bundle/<language>.lproj/…).
val copyExampleBundles by tasks.registering(Sync::class) {
    from("../../../Example-Swift/CYLTagEditorExample/CYLTagEditorExample.bundle") { into("CYLTagEditorExample.bundle") }
    from("../../../Example/CYLMenuExample/CYLMenuExample.bundle") { into("CYLMenuExample.bundle") }
    // CYLTabBarController's Example-PAG icons (pag-ios/*.pag), shared by the iOS examples.
    from("../../../Example-Shared/PAGResources")
    exclude("**/._*", "**/.claude/**", "**/*.md")
    into(layout.buildDirectory.dir("generated/cylBundles"))
}
// The PNGs of the menu example's asset catalog (TabBarIcon, LottieImages), used as they are: <name>@3x.png goes to
// drawable-xxhdpi, @2x to drawable-xhdpi and 1x to drawable-mdpi, so `"image": "home_normal"` finds the same picture.
val copyExampleImages by tasks.registering(Sync::class) {
    from("../../../Example/CYLMenuExample/Assets.xcassets") {
        include("TabBarIcon/**/*.png", "LottieImages/**/*.png")
        exclude("**/._*")
    }
    includeEmptyDirs = false
    duplicatesStrategy = DuplicatesStrategy.EXCLUDE
    eachFile {
        val base = name.removeSuffix(".png")
        val (resourceName, folder) = when {
            base.endsWith("@3x") -> base.removeSuffix("@3x") to "drawable-xxhdpi"
            base.endsWith("@2x") -> base.removeSuffix("@2x") to "drawable-xhdpi"
            else -> base to "drawable-mdpi"
        }
        path = "$folder/$resourceName.png"
    }
    into(layout.buildDirectory.dir("generated/cylRes"))
}
tasks.named("preBuild") { dependsOn(copyExampleBundles, copyExampleImages) }
