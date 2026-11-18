plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.cyl.cyl_tag_list_example"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.cyl.cyl_tag_list_example"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
            // The tag list finds CYLTabBarController's animation engine and Lottie by reflection.
            proguardFiles("proguard-rules.pro")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

// CYLTabBarController's Android library (tab bar and animation engine) comes from flutter_cyltabbar (pubspec.yaml),
// which compiles Example-Android/cyltabbar and tabpages of its checkout; CYLTagListView finds the engine there at run
// time to play the Lottie and Rive icons. The animated icon + title component
// io.github.chenyilong:cyltabbarcontroller-animateditem comes once, with com.cyl:classifymenu (cyl.classifymenu.repo):
// gradle.properties sets cylAnimatedItemProvided, so flutter_cyltabbar does not compile a second copy.
dependencies {
    implementation("com.airbnb.android:lottie:6.6.2")
    implementation("app.rive:rive-android:10.3.0")
    implementation("androidx.fragment:fragment-ktx:1.8.5")
}
