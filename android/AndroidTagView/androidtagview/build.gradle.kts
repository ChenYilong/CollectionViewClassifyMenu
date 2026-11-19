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
    namespace = "co.lujun.androidtagview"
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
}

dependencies {
    implementation(libs.androidx.appcompat)
    implementation(libs.androidx.customview)
}

afterEvaluate {
    publishing {
        publications {
            create<MavenPublication>("release") {
                from(components["release"])
                groupId = "co.lujun"
                artifactId = "androidtagview"
                version = "0.1.0"
                pom {
                    licenses {
                        license {
                            name.set("The Apache License, Version 2.0")
                            url.set("https://www.apache.org/licenses/LICENSE-2.0.txt")
                        }
                    }
                }
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
