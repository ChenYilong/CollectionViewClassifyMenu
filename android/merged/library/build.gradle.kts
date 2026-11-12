// The merged library: android-tagview (me.kaede.tagview), AndroidTagView (co.lujun.androidtagview) and TagViewGroup
// (com.licrafter.tagview) with all their public APIs, synced by ../scripts/sync_merged_sources.py, and the Android API
// of the iOS core (com.cyl.classifymenu, docs/android-api.md).
plugins {
    alias(libs.plugins.android.library)
    alias(libs.plugins.kotlin.android)
}

android {
    namespace = "com.cyl.classifymenu"
    compileSdk = 35
    defaultConfig {
        minSdk = 23
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
    implementation(libs.androidx.appcompat)
    implementation(libs.androidx.customview)
    implementation(libs.androidx.recyclerview)
    testImplementation(libs.junit)
    testImplementation(libs.robolectric)
    testImplementation(libs.androidx.test.core)
}
