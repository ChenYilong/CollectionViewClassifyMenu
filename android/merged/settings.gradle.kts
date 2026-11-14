// The merged library of the three Kotlin tag libraries in android/, and one example app whose tabs are a
// CYLTabBarController (Android) built from a configuration file, one tab per example.
import java.io.File
import java.util.Properties

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
rootProject.name = "CYLClassifyMenuAndroid"
include(":library", ":example")

// MARK: CYLTabBarController by commit
// Gradle has no Maven coordinate for a commit of a repository whose root is not a Gradle build, so the commit in
// gradle.properties is checked out here (a sparse, blobless clone: only Example-Android, Example-Shared and docs) and
// its Android build is included; the example asks for the Maven coordinates and gets that commit's modules.
val properties = Properties().apply { file("gradle.properties").inputStream().use { load(it) } }
val cylCommit: String = properties.getProperty("cyl.tabbar.commit")
val cylRepo: String = properties.getProperty("cyl.tabbar.repo")

fun git(directory: File?, vararg arguments: String): Boolean = try {
    ProcessBuilder(listOf("git") + arguments).directory(directory).redirectErrorStream(true).start().let { process ->
        process.inputStream.bufferedReader().readText()
        process.waitFor() == 0
    }
} catch (error: Exception) {
    false
}

fun checkout(): File? {
    val directory = file(".cyltabbar/$cylCommit")
    if (File(directory, "Example-Android/settings.gradle.kts").exists()) return directory
    directory.deleteRecursively()
    directory.parentFile.mkdirs()
    val ok = git(null, "clone", "--quiet", "--filter=blob:none", "--no-checkout", cylRepo, directory.path) &&
        git(directory, "sparse-checkout", "set", "Example-Android", "Example-Shared", "docs") &&
        git(directory, "checkout", "--quiet", cylCommit)
    return if (ok && File(directory, "Example-Android/settings.gradle.kts").exists()) directory else null
}

val cylRoot: File = checkout() ?: run {
    val local = File(properties.getProperty("cyl.tabbar.localPath"))
    val fallback = if (local.isAbsolute) local else file(local.path)
    logger.warn("CYLTabBarController $cylCommit could not be checked out; using the local folder $fallback")
    fallback
}

includeBuild(File(cylRoot, "Example-Android")) {
    dependencySubstitution {
        substitute(module("io.github.chenyilong:cyltabbarcontroller")).using(project(":cyltabbar"))
        substitute(module("io.github.chenyilong:cyltabbarcontroller-pages")).using(project(":tabpages"))
    }
}
