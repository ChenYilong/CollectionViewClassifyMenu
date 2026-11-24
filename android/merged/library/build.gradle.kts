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
        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
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
        // The instrumented test APK defaults to minSdk (23) as its target; Android 14 and later refuse to install an
        // APK that targets less than 24 (INSTALL_FAILED_DEPRECATED_SDK_VERSION), so connectedDebugAndroidTest stalled.
        targetSdk = 35
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
    androidTestImplementation("androidx.test:runner:1.3.0")
    androidTestImplementation("junit:junit:4.13.2")
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
                // The AAR carries META-INF/classifymenu/LICENSE, NOTICE and LICENSE-APACHE-2.0 (AGENTS.md, "License in
                // every published package"): MIT, with Apache-2.0 for the translated AndroidTagView and android-tagview.
                pom {
                    licenses {
                        license {
                            name.set("The MIT License")
                            url.set("https://opensource.org/licenses/MIT")
                        }
                        license {
                            name.set("The Apache License, Version 2.0")
                            url.set("https://www.apache.org/licenses/LICENSE-2.0.txt")
                        }
                    }
                }
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
// A plain task that copies in its action, not a `Copy` task: a `Copy` task declares build/repo as its output, and on its
// first run after a clean Gradle removes that folder's "stale" files first, which deleted the library's own artifact
// (com.cyl:classifymenu) published just before, so the React Native and Flutter hosts could not resolve it.
val publishAnimatedItemToBuildRepository by tasks.registering {
    val repo = layout.buildDirectory.dir("repo")
    val staging = cylTabBarBuild?.let { File(it.projectDir, "build/staging-deploy") }
    if (cylTabBarBuild != null) {
        dependsOn(cylTabBarBuild.task(":cylanimateditem:publishReleasePublicationToStagingRepository"))
    }
    doLast {
        if (staging != null) {
            copy {
                from(staging) { include("io/github/chenyilong/cyltabbarcontroller-animateditem/**") }
                into(repo)
            }
        }
    }
}
// The copy runs first: on its first run Gradle deletes the "stale" files of its output folder, the shared build/repo, so
// copying after the library's publication removed com/cyl/classifymenu (the Flutter and React Native hosts then could not
// resolve com.cyl:classifymenu).
tasks.matching { it.name == "publishReleasePublicationToBuildRepository" }.configureEach {
    dependsOn(publishAnimatedItemToBuildRepository)
}
