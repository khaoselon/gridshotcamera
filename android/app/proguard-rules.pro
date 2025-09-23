########################################
# Flutter / PlatformView（反射対策）
########################################
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }
-dontwarn io.flutter.**

########################################
# Camera / CameraX
########################################
# Flutter camera plugin
-keep class io.flutter.plugins.camera.** { *; }
-keep class io.flutter.plugins.camera.media.** { *; }
-dontwarn io.flutter.plugins.camera.**

# AndroidX CameraX（manifestサービスや反射参照あり）
-keep class androidx.camera.** { *; }
-dontwarn androidx.camera.**

# 低レベルAPI（参照あり）
-keep class android.hardware.camera2.** { *; }
-keep class android.hardware.Camera.** { *; }
-dontwarn android.hardware.camera2.**

########################################
# Google Mobile Ads / Play services
########################################
-keep class com.google.android.gms.ads.** { *; }
-keep class com.google.android.gms.common.** { *; }
-keep class com.google.android.gms.internal.ads.** { *; }
-dontwarn com.google.android.gms.**

########################################
# WebView（Ads内部で利用）
########################################
-keep class android.webkit.** { *; }

########################################
# 権限/共有・ファイル系 Flutter プラグイン
########################################
-keep class io.flutter.plugins.permission_handler.** { *; }
-dontwarn io.flutter.plugins.permission_handler.**

-keep class io.flutter.plugins.pathprovider.** { *; }
-keep class androidx.core.content.FileProvider.** { *; }

# Share Plus
-keep class dev.fluttercommunity.plus.share.** { *; }
-dontwarn dev.fluttercommunity.plus.share.**

########################################
# あなたの任意プラグイン/コード
########################################
# Gal（ギャラリー保存）を使っている場合
-keep class studio.midoridesign.gal.** { *; }
-dontwarn studio.midoridesign.gal.**

########################################
# AndroidX Startup / WorkManager / ProfileInstaller
########################################
-keep class androidx.startup.** { *; }
-dontwarn androidx.startup.**

-keep class androidx.work.** { *; }
-dontwarn androidx.work.**

-keep class androidx.profileinstaller.** { *; }
-dontwarn androidx.profileinstaller.**

########################################
# Kotlin（広すぎる keep は避け、メタデータに限定）
########################################
-keep class kotlin.Metadata { *; }
-dontwarn kotlin.**

########################################
# 一般的な keep / デバッグで行番号保持（スタック可読性）
########################################
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses
-keepattributes EnclosingMethod
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile

# コンパイラ生成の補助クラス
-dontwarn java.lang.invoke.**
-dontwarn **$$serializer
-keepclassmembers class **$WhenMappings { <fields>; }

########################################
# Play Core / Feature Delivery / SplitInstall
########################################
-keep class com.google.android.play.core.** { *; }
-keep class com.google.android.play.core.splitinstall.** { *; }
-keep class com.google.android.play.core.splitcompat.** { *; }
-keep class com.google.android.play.core.tasks.** { *; }
-dontwarn com.google.android.play.core.**

########################################
# メディエーション等を後で入れるときは、
# 各アダプタのドキュメントに従って追加 keep を入れてください。
########################################
