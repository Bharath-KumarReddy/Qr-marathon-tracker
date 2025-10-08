// android/app/build.gradle.kts

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")   // must come after Android + Kotlin
    id("com.google.gms.google-services")      // Firebase plugin
}

android {
    namespace = "com.example.og"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.example.og"
        minSdk = flutter.minSdkVersion                    // Firebase minimum requirement
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true          // Prevents 64K method overflow
    }

    buildTypes {
        // ✅ Debug build configuration (used during development)
        debug {
            isMinifyEnabled = false
            isShrinkResources = false
        }

        // ✅ Release build configuration
        release {
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = false      // set to true for release optimization
            isShrinkResources = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

flutter {
    source = "../.."
}
