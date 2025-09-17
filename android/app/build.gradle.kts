plugins {
    id("com.android.application")
    // 旧: id("kotlin-android")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.mkproject.gridshot_camera"
    compileSdk = 36
    ndkVersion = "28.0.12433566"

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

                // NDK R27の場合の16KB対応設定
        externalNativeBuild {
            cmake {
                arguments "-DANDROID_SUPPORT_FLEXIBLE_PAGE_SIZES=ON"
            }
    }

    buildTypes {
        release {
            // 開発中なら debug キーでOK。ストア配布時は正式な署名に差し替え
            signingConfig = signingConfigs.getByName("debug")
            // minifyEnabled = false など必要に応じて
        }
    }
}

// ★ Kotlin の JVM ツールチェーンを 17 指定（推奨）
kotlin {
    jvmToolchain(17)
}

// Flutter プロジェクト連携
flutter {
    source = "../.."
}
