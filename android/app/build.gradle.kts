plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.mkproject.gridshot_camera"
    compileSdk = 36
    // ndkVersion = "28.0.12433566" // ← C/C++使うときだけ

    // ★ Java 17 に統一
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.mkproject.gridshot_camera"
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    } // ← これが抜けてた！

    buildTypes {
        release {
            // 開発中は debug キーでOK。ストア配布時は正式署名に差し替え
            signingConfig = signingConfigs.getByName("debug")
            // minifyEnabled = false など必要に応じて
        }
    }
}

// ★ Kotlin の JVM ツールチェーンを 17 指定
kotlin {
    jvmToolchain(17)
}

// Flutter 連携
flutter {
    source = "../.."
}
