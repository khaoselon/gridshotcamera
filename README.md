# GridShot Camera

<div align="center">
  <img src="assets/images/app_icon.png" alt="GridShot Camera Logo" width="120" height="120">
  
  **革新的なグリッド撮影カメラアプリ**
  
  [![Flutter](https://img.shields.io/badge/Flutter-3.32.0--0.2.pre-blue.svg)](https://flutter.dev/)
  [![Dart](https://img.shields.io/badge/Dart-3.9.0--196.1.beta-blue.svg)](https://dart.dev/)
  [![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20Android-lightgrey.svg)](https://flutter.dev/)
  [![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
</div>

## 📱 概要

GridShot Cameraは、複数の写真を美しいグリッド形式で合成できる革新的なカメラアプリです。2つの独特な撮影モードで、従来のカメラアプリでは実現できない創造的な写真作品を作成できます。

### ✨ 主な特徴

- **2つの撮影モード**
  - 🏷️ **カタログモード**: 複数の被写体を各マスに収めて一覧化
  - 🎨 **不可能合成モード**: 同じシーンを分割順に撮影してシームレスに合成

- **柔軟なグリッドスタイル**
  - 2×2、2×3、3×2、3×3 の4種類のグリッドレイアウト

- **高品質な画像処理**
  - 端末のネイティブ解像度を活用
  - カスタマイズ可能な画質設定
  - 境界線の色・太さを自由に設定

- **多言語対応**
  - 🇯🇵 日本語
  - 🇺🇸 English

- **ユーザーフレンドリー**
  - 直感的なUI/UX
  - リアルタイムプレビュー
  - 撮影ガイダンス表示

## 🎯 撮影モード詳細

### 📸 カタログモード
複数の異なる被写体を各グリッドセルに配置し、商品カタログのような一覧写真を作成します。

**使用例:**
- 商品カタログ作成
- コレクション写真
- Before/After比較
- 料理のバリエーション撮影

### 🌟 不可能合成モード
同一シーンを分割して撮影し、物理的に不可能な構図を作成します。

**使用例:**
- アーティスティックな作品制作
- トリックアート
- 時間の経過を表現
- ユニークなポートレート

## 🛠️ 技術仕様

### 開発環境
- **Flutter**: 3.32.0-0.2.pre (Channel beta)
- **Dart SDK**: ^3.9.0-196.1.beta
- **Android SDK**: 35.0.0
- **Xcode**: 16.2
- **対象OS**: iOS 13.0+ / Android API 21+

### 主要ライブラリ
```yaml
dependencies:
  flutter: sdk: flutter
  camera: ^0.11.0+2              # カメラ機能
  image: ^4.2.0                  # 画像処理
  google_mobile_ads: ^5.1.0      # 広告表示
  permission_handler: ^11.3.1    # 権限管理
  shared_preferences: ^2.3.2     # 設定保存
  gal: ^2.3.2                    # ギャラリー保存
  share_plus: ^7.2.2             # 共有機能
  app_tracking_transparency: ^2.0.5  # ATT対応
```

### アーキテクチャ
```
lib/
├── main.dart                    # アプリケーションエントリーポイント
├── models/                      # データモデル
│   ├── app_settings.dart        # アプリ設定
│   ├── grid_style.dart          # グリッドスタイル
│   └── shooting_mode.dart       # 撮影モード
├── screens/                     # 画面
│   ├── home_screen.dart         # ホーム画面
│   ├── camera_screen.dart       # カメラ画面
│   ├── preview_screen.dart      # プレビュー画面
│   └── settings_screen.dart     # 設定画面
├── services/                    # ビジネスロジック
│   ├── camera_service.dart      # カメラ制御
│   ├── image_composer_service.dart  # 画像合成
│   ├── settings_service.dart    # 設定管理
│   ├── permission_service.dart  # 権限管理
│   └── ad_service.dart          # 広告管理
├── widgets/                     # 再利用可能ウィジェット
└── l10n/                        # 多言語化ファイル
```

## 🚀 セットアップ手順

### 前提条件
- Flutter SDK (3.32.0-0.2.pre以上)
- Android Studio / Xcode
- 実機またはエミュレータ

### 1. リポジトリのクローン
```bash
git clone https://github.com/your-username/gridshot_camera.git
cd gridshot_camera
```

### 2. 依存関係のインストール
```bash
flutter pub get
```

### 3. 多言語化ファイルの生成
```bash
flutter gen-l10n
```

### 4. プラットフォーム固有の設定

#### Android設定
`android/app/src/main/AndroidManifest.xml`で必要な権限が設定済み：
- CAMERA (カメラアクセス)
- READ_MEDIA_IMAGES (Android 13+)
- INTERNET (広告表示)

#### iOS設定
`ios/Runner/Info.plist`で必要な権限が設定済み：
- NSCameraUsageDescription
- NSPhotoLibraryUsageDescription
- NSUserTrackingUsageDescription

### 5. アプリの実行
```bash
# デバッグモード
flutter run

# リリースモード
flutter run --release
```

## 📋 必要な権限

### Android
- `CAMERA` - 写真撮影
- `READ_MEDIA_IMAGES` - 画像アクセス (Android 13+)
- `WRITE_EXTERNAL_STORAGE` - ファイル保存 (Android 10以下)
- `INTERNET` - 広告表示
- `ACCESS_NETWORK_STATE` - ネットワーク状態確認

### iOS
- `NSCameraUsageDescription` - カメラアクセス
- `NSPhotoLibraryUsageDescription` - 写真ライブラリアクセス
- `NSPhotoLibraryAddUsageDescription` - 写真保存
- `NSUserTrackingUsageDescription` - App Tracking Transparency

## 🎛️ 主要設定項目

### 撮影設定
- **画像品質**: 高/中/低 (95%/75%/50%)
- **グリッド境界線**: 表示/非表示
- **境界線色**: カスタマイズ可能
- **境界線太さ**: 0.5px〜10px

### アプリ設定
- **言語**: 日本語/English
- **広告表示**: ON/OFF
- **App Tracking**: 許可/拒否

## 📁 ビルド構成

### ファイル構成（重要なファイル）
```
gridshot_camera/
├── android/
│   ├── app/build.gradle.kts     # Android Gradle設定
│   └── build.gradle.kts         # プロジェクトレベル設定
├── ios/
│   ├── Runner.xcodeproj/        # Xcodeプロジェクト
│   └── Podfile                  # CocoaPods設定
├── lib/
│   ├── main.dart               # アプリエントリーポイント
│   └── [各種Dartファイル]
├── assets/                     # リソースファイル
├── pubspec.yaml               # パッケージ設定
└── README.md                  # このファイル
```

### ビルドコマンド
```bash
# Android APK
flutter build apk --release

# Android Bundle (Play Store用)
flutter build appbundle --release

# iOS (App Store用)
flutter build ios --release
```

## 🧪 テスト

### ユニットテスト実行
```bash
flutter test
```

### 統合テスト実行
```bash
flutter drive --target=test_driver/app.dart
```

## 📊 パフォーマンス最適化

### 画像処理最適化
- 非同期処理による UI の応答性確保
- メモリ効率的な画像合成アルゴリズム
- 一時ファイルの適切な管理

### バッテリー効率
- カメラリソースの適切な管理
- バックグラウンド処理の最小化
- 効率的なライフサイクル管理

## 🐛 トラブルシューティング

### よくある問題

#### カメラが起動しない
```bash
# 権限確認
adb shell pm grant com.example.gridshot_camera android.permission.CAMERA
```

#### ビルドエラー
```bash
# キャッシュクリア
flutter clean
flutter pub get
```

#### iOS App Tracking Transparency
- iOS 14.5+ でのATT対応済み
- Info.plistの設定確認

### デバッグ情報出力
```dart
// CameraServiceのデバッグ情報
CameraService.debugPrintStatus();

// 設定情報のデバッグ出力
SettingsService.instance.debugPrintSettings();
```

## 🤝 コントリビューション

### バグレポート
Issue作成時に以下の情報を含めてください：
- 端末情報（機種、OS バージョン）
- Flutter バージョン
- 再現手順
- エラーメッセージ

### 機能リクエスト
新機能の提案は Issue で詳細をお聞かせください。

### プルリクエスト
1. フォークして機能ブランチを作成
2. コミットメッセージは日本語/英語どちらでも可
3. プルリクエストの説明を詳記

## 📝 ライセンス

このプロジェクトは MIT ライセンスの下で公開されています。詳細は [LICENSE](LICENSE) ファイルをご覧ください。

## 📞 サポート

- **GitHub Issues**: バグ報告・機能リクエスト
- **メール**: gridshot.support@example.com
- **ドキュメント**: [Wiki](https://github.com/your-username/gridshot_camera/wiki)

## 🏆 クレジット

### 開発者
- **GridShot Camera Team** - メイン開発

### 使用ライブラリ
- [Flutter](https://flutter.dev/) - UI フレームワーク
- [Camera Plugin](https://pub.dev/packages/camera) - カメラ機能
- [Image](https://pub.dev/packages/image) - 画像処理
- [Google Mobile Ads](https://pub.dev/packages/google_mobile_ads) - 広告SDK

## 📈 今後の予定

### v1.1.0 (予定)
- [ ] 新しいグリッドスタイル (4×4, 5×5)
- [ ] フィルター機能
- [ ] クラウド同期

<!-- ### v1.2.0 (予定)
- [ ] 動画撮影対応
- [ ] AI補正機能
- [ ] ソーシャル共有強化
-->
---

<div align="center">
  <p>❤️ GridShot Camera を使って素晴らしい作品を作りましょう！</p>
  
  ⭐ このプロジェクトが役立ったら、ぜひスターをお願いします！
</div>