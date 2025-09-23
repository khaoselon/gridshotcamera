// android/app/build.gradle.kts
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties().apply {
    val keystorePropertiesFile = rootProject.file("key.properties")
    if (keystorePropertiesFile.exists()) {
        load(keystorePropertiesFile.inputStream())
    }
}

android {
    namespace = "com.mkproject.gridshot_camera"
    compileSdk = 36

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // Java 8+ API desugaring（古め端末の互換性を上げる）
        isCoreLibraryDesugaringEnabled = true
    }
    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.mkproject.gridshot_camera"
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // Flutter 標準アプリケーションクラス
        manifestPlaceholders["applicationName"] = "io.flutter.embedding.android.FlutterApplication"

        // 64K 超対策
        multiDexEnabled = true
    }

    signingConfigs {
        create("release") {
            // key.properties から取得
            storeFile = keystoreProperties["storeFile"]?.toString()?.let { file(it) }
            storePassword = keystoreProperties["storePassword"]?.toString()
            keyAlias = keystoreProperties["keyAlias"]?.toString()
            keyPassword = keystoreProperties["keyPassword"]?.toString()
        }
        // debug は自動の debug.keystore でOK
    }

    buildTypes {
        getByName("debug") {
            isMinifyEnabled = false
            isDebuggable = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
        getByName("release") {
            // 署名
            signingConfig = signingConfigs.getByName("release")

            // R8最適化＆リソース縮小（ProGuardルールで安全化）
            isMinifyEnabled = true
            isShrinkResources = true

            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
    }

    // ネイティブ重複対策（必要なときだけ有効化）
    packagingOptions {
        // まずはコメントアウトで様子見。必要になれば個別に開放する。
        // pickFirst("**/libc++_shared.so")
        // pickFirst("**/libjsc.so")
    }
}

kotlin {
    jvmToolchain(17)
}

flutter {
    source = "../.."
}

dependencies {
    // Java 8+ desugaring
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")

    implementation("androidx.appcompat:appcompat:1.6.1")

    // 64K 超対策（MultiDex）
    implementation("androidx.multidex:multidex:2.0.1")

    // Play Feature Delivery（使っているので現状維持）
    implementation("com.google.android.play:feature-delivery:2.1.0")
    implementation("com.google.android.play:feature-delivery-ktx:2.1.0")
}
