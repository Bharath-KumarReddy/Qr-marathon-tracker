// android/build.gradle.kts

plugins {
    // ✅ Core Android + Kotlin
    id("com.android.application") apply false
    id("com.android.library") apply false
    id("org.jetbrains.kotlin.android") apply false

    // ✅ Firebase / Google Services plugin (no version conflict)
    id("com.google.gms.google-services") apply false
}

// ✅ Repository sources for all modules
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// ✅ Keep build directory structure clean
val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
    project.evaluationDependsOn(":app")
}

// ✅ Clean task
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
