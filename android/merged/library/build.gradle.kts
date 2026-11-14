// The merged library: android-tagview (me.kaede.tagview), AndroidTagView (co.lujun.androidtagview) and TagViewGroup
// (com.licrafter.tagview) with all their public APIs, synced by ../scripts/sync_merged_sources.py, and the Android API
// of the iOS core (com.cyl.classifymenu, docs/android-api.md).
plugins {
    alias(libs.plugins.android.library)
    alias(libs.plugins.kotlin.android)
    `maven-publish`
}

android {
    // Issue #120 (whilu/AndroidTagView): published as a Maven artifact (Maven Central layout, no jcenter); the
    // dependencies resolve from google() and mavenCentral() only (settings.gradle.kts).
    publishing {
        singleVariant("release") {
            withSourcesJar()
        }
    }
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

afterEvaluate {
    publishing {
        publications {
            create<MavenPublication>("release") {
                from(components["release"])
                groupId = "com.cyl"
                artifactId = "classifymenu"
                version = "0.1.0"
            }
        }
        repositories {
            // `publishReleasePublicationToBuildRepository` checks the artifact locally; a Maven Central (Sonatype)
            // repository with credentials is added here for a release.
            maven {
                name = "build"
                url = uri(layout.buildDirectory.dir("repo"))
            }
        }
    }
}
