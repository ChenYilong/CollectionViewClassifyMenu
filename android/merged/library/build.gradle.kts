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
    // CYLTagButton subclasses CYLTabBarController's CYLAnimatedItemView (module :cylanimateditem; guide:
    // https://github.com/ChenYilong/CYLTabBarController/blob/feat/cross-platform-components/docs/Animated-Item.md), so it
    // is part of the API. It holds the animation engine, which reaches Lottie, libpag, rive-android and SVGAPlayer by
    // reflection: the core adds none of them; an app that plays animated icons adds the libraries it needs. The
    // version is CYLTabBarController's (its podspec); settings.gradle.kts builds the pinned commit in its place.
    api("io.github.chenyilong:cyltabbarcontroller-animateditem:1.100.0")
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
            // `publishReleasePublicationToBuildRepository` checks the artifact locally (the React Native and Flutter
            // hosts read it from build/repo); a Maven Central (Sonatype)
            // repository with credentials is added here for a release.
            maven {
                name = "build"
                url = uri(layout.buildDirectory.dir("repo"))
            }
        }
    }
}

// The React Native and Flutter hosts resolve com.cyl:classifymenu from build/repo; its POM needs
// io.github.chenyilong:cyltabbarcontroller-animateditem, which is not on Maven Central yet. Publishing the library also
// publishes that module of the pinned CYLTabBarController (the included build's `staging` repository) and copies it
// next to the library.
val cylTabBarBuild = gradle.includedBuilds.firstOrNull { File(it.projectDir, "cylanimateditem").isDirectory }
val publishAnimatedItemToBuildRepository by tasks.registering(Copy::class) {
    if (cylTabBarBuild != null) {
        dependsOn(cylTabBarBuild.task(":cylanimateditem:publishReleasePublicationToStagingRepository"))
        from(File(cylTabBarBuild.projectDir, "build/staging-deploy")) {
            include("io/github/chenyilong/cyltabbarcontroller-animateditem/**")
        }
    }
    into(layout.buildDirectory.dir("repo"))
}
tasks.matching { it.name == "publishReleasePublicationToBuildRepository" }.configureEach {
    finalizedBy(publishAnimatedItemToBuildRepository)
}
