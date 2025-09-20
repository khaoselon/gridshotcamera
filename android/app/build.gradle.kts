plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.mkproject.gridshot_camera"
    compileSdk = 36

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
        
        // カメラ関連のパフォーマンス改善
        ndk {
            abiFilters += listOf("arm64-v8a", "armeabi-v7a", "x86_64")
        }
        
        // メモリ効率化
        multiDexEnabled = true
    }

    buildTypes {
        debug {
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = false
            isDebuggable = true
            
            // デバッグ時のメモリ設定
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
        
        release {
            // 開発中は debug キーでOK。ストア配布時は正式署名に差し替え
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = true
            isShrinkResources = true
            
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
    
    // パッケージング設定
    packagingOptions {
        pickFirst("**/libc++_shared.so")
        pickFirst("**/libjsc.so")
    }
    
    // コンパイル設定
    compileOptions {
        isCoreLibraryDesugaringEnabled = true
    }
    
    // 署名設定（開発用）
    signingConfigs {
        getByName("debug") {
            storeFile = file("debug.keystore")
            storePassword = "android"
            keyAlias = "androiddebugkey"
            keyPassword = "android"
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

dependencies {
    // デシュガリング（API 21+のサポート改善）
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}