// An API-compatible Kotlin reimplementation of shellljx/TagViewGroup (befcd9b): the original is GPL-3.0, so no code
// is copied; the sample is translated from this repository's own Swift port (Example/CYLMenuExample).
pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
    }
    versionCatalogs {
        create("libs") {
            from(files("../gradle/libs.versions.toml"))
        }
    }
}
rootProject.name = "TagViewGroup"
include(":library", ":sample")
