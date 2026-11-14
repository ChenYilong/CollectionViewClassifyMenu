allprojects {
    repositories {
        google()
        mavenCentral()
        // The Kotlin CYLTagListView the plugin wraps (android/merged/library, see the plugin's README.md).
        maven { url = uri(providers.gradleProperty("cyl.classifymenu.repo").getOrElse("${rootDir}/../../../../android/merged/library/build/repo")) }
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
