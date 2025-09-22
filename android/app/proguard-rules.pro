# Flutter関連の設定
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# カメラプラグイン関連
-keep class io.flutter.plugins.camera.** { *; }
-keep class io.flutter.plugins.camera.media.** { *; }
-dontwarn io.flutter.plugins.camera.**

# Google Mobile Ads関連
-keep class com.google.android.gms.ads.** { *; }
-keep class com.google.ads.** { *; }
-dontwarn com.google.android.gms.ads.**

# Camera2 API関連
-keep class android.hardware.camera2.** { *; }
-keep class android.hardware.Camera.** { *; }
-dontwarn android.hardware.camera2.**

# パーミッション関連
-keep class io.flutter.plugins.permission_handler.** { *; }
-dontwarn io.flutter.plugins.permission_handler.**

# ファイルアクセス関連
-keep class io.flutter.plugins.pathprovider.** { *; }
-keep class androidx.core.content.FileProvider.** { *; }

# Gal（ギャラリー保存）関連
-keep class studio.midoridesign.gal.** { *; }
-dontwarn studio.midoridesign.gal.**

# App Tracking Transparency
-keep class io.flutter.plugins.app_tracking_transparency.** { *; }
-dontwarn io.flutter.plugins.app_tracking_transparency.**

# Share Plus関連
-keep class dev.fluttercommunity.plus.share.** { *; }
-dontwarn dev.fluttercommunity.plus.share.**

# Kotlin関連
-dontwarn kotlin.**
-keep class kotlin.** { *; }

# 一般的なAndroid設定
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses
-keepattributes EnclosingMethod

# デバッグビルド時の設定
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile

# メモリリーク防止
-dontwarn java.lang.invoke.**
-dontwarn **$$serializer
-keepclassmembers class **$WhenMappings {
    <fields>;
}

# R8/ProGuard最適化設定
-allowaccessmodification
-repackageclasses

# --- Play Core / Feature Delivery / SplitInstall を保持 ---
-keep class com.google.android.play.core.** { *; }
-keep class com.google.android.play.core.splitinstall.** { *; }
-keep class com.google.android.play.core.splitcompat.** { *; }
-keep class com.google.android.play.core.tasks.** { *; }
-dontwarn com.google.android.play.core.**
