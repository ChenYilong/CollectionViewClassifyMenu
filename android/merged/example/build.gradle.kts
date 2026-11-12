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
    exclude("**/._*", "**/.claude/**", "**/*.md")
    into(layout.buildDirectory.dir("generated/cylBundles"))
}
tasks.named("preBuild") { dependsOn(copyExampleBundles) }
