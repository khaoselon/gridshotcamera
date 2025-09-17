// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'GridShot Camera';

  @override
  String get homeTitle => '撮影モード選択';

  @override
  String get catalogMode => 'ならべ撮り撮影';

  @override
  String get catalogModeDescription => '複数の被写体を各マスに収めて一覧化';

  @override
  String get impossibleMode => 'グリッド合成撮影';

  @override
  String get impossibleModeDescription => '同じシーンを分割順に撮影して合成';

  @override
  String get gridStyle => 'グリッドスタイル';

  @override
  String get grid2x2 => '2×2';

  @override
  String get grid2x3 => '2×3';

  @override
  String get grid3x2 => '3×2';

  @override
  String get grid3x3 => '3×3';

  @override
  String get startShooting => '撮影開始';

  @override
  String get settings => '設定';

  @override
  String get cameraTitle => '撮影中';

  @override
  String currentPosition(String position) {
    return '現在位置: $position';
  }

  @override
  String get tapToShoot => 'タップで撮影';

  @override
  String get retake => '撮り直し';

  @override
  String get next => '次へ';

  @override
  String get complete => '完了';

  @override
  String get previewTitle => 'プレビュー';

  @override
  String get save => '保存';

  @override
  String get share => '共有';

  @override
  String get cancel => 'キャンセル';

  @override
  String get settingsTitle => '設定';

  @override
  String get language => '言語';

  @override
  String get japanese => '日本語';

  @override
  String get english => 'English';

  @override
  String get gridBorder => 'グリッド境界線';

  @override
  String get borderColor => '境界線の色';

  @override
  String get borderWidth => '境界線の太さ';

  @override
  String get imageQuality => '画像品質';

  @override
  String get high => '高';

  @override
  String get medium => '中';

  @override
  String get low => '低';

  @override
  String get adSettings => '広告設定';

  @override
  String get showAds => '広告を表示';

  @override
  String get cameraPermission => 'カメラ許可';

  @override
  String get cameraPermissionMessage => '写真を撮影するためにカメラへのアクセスが必要です。設定でカメラアクセスを許可してください。';

  @override
  String get storagePermission => 'ストレージ許可';

  @override
  String get storagePermissionMessage => '写真を保存するためにストレージへのアクセスが必要です。';

  @override
  String get openSettings => '設定を開く';

  @override
  String get error => 'エラー';

  @override
  String get saveSuccess => '画像が保存されました';

  @override
  String get saveFailed => '画像の保存に失敗しました';

  @override
  String get shareSuccess => '画像が共有されました';

  @override
  String get loading => '読み込み中...';

  @override
  String get processing => '処理中...';

  @override
  String get compositing => '合成中...';

  @override
  String get trackingPermissionTitle => 'アプリトラッキング許可';

  @override
  String get trackingPermissionMessage => '広告をパーソナライズするために、他のアプリでのアクティビティ追跡を許可してください。';

  @override
  String get allow => '許可';

  @override
  String get dontAllow => '許可しない';

  @override
  String get selectPhotoStyle => '撮影したい写真のスタイルを選択してください';

  @override
  String get shootingMode => '撮影モード';

  @override
  String selectedGrid(String gridStyle) {
    return '選択中: $gridStyle';
  }

  @override
  String get checkingPermissions => '権限確認中...';

  @override
  String get confirmation => '確認';

  @override
  String get retakePhotos => '撮影をやり直しますか？';

  @override
  String get takeNewPhoto => '新しく撮影する';

  @override
  String get shootingInfo => '撮影情報';

  @override
  String get mode => 'モード';

  @override
  String get gridStyleInfo => 'グリッドスタイル';

  @override
  String get photoCount => '撮影枚数';

  @override
  String get shootingDate => '撮影日時';

  @override
  String get saving => '保存中...';

  @override
  String get sharing => '共有中...';

  @override
  String get catalogModeDisplay => 'ならべ撮り撮影';

  @override
  String get impossibleModeDisplay => 'グリッド合成撮影';

  @override
  String get resetSettings => '設定をリセット';

  @override
  String get appInfo => 'アプリ情報';

  @override
  String get version => 'バージョン';

  @override
  String get developer => '開発者';

  @override
  String get aboutAds => '広告について';

  @override
  String get selectBorderColor => '境界線の色を選択';

  @override
  String get resetConfirmation => 'すべての設定を初期値に戻しますか？この操作は取り消せません。';

  @override
  String get reset => 'リセット';

  @override
  String get settingsReset => '設定がリセットされました';

  @override
  String get retry => '再試行';

  @override
  String get preparingCamera => 'カメラを準備中...';

  @override
  String get cameraError => 'カメラエラー';

  @override
  String get initializationFailed => '初期化に失敗しました';

  @override
  String get unsupportedDevice => 'サポートされていないデバイスです';

  @override
  String get permissionDenied => '権限が拒否されました';

  @override
  String get unknownError => '不明なエラーが発生しました';

  @override
  String get tryAgain => '再試行';

  @override
  String get goBack => '戻る';

  @override
  String photosCount(int count) {
    return '$count枚';
  }

  @override
  String compositingProgress(int current, int total) {
    return '$total枚中$current枚目を合成中...';
  }

  @override
  String get pleaseWait => '少々お待ちください...';

  @override
  String get imageInfo => '画像情報';

  @override
  String get fileSize => 'ファイルサイズ';

  @override
  String get dimensions => '解像度';

  @override
  String get format => 'フォーマット';

  @override
  String get quality => '品質';

  @override
  String get highQuality => '最高品質 (95%) - ファイルサイズ大';

  @override
  String get mediumQuality => '中品質 (75%) - バランス良好';

  @override
  String get lowQuality => '低品質 (50%) - ファイルサイズ小';

  @override
  String get gridBorderDescription => '撮影時にグリッド線を表示します';

  @override
  String currentColor(String colorName) {
    return '現在の色: $colorName';
  }

  @override
  String borderWidthValue(String width) {
    return '${width}px';
  }

  @override
  String get appDescription => '本アプリは広告収益によって運営されています';

  @override
  String get teamName => 'GridShot Camera Team';

  @override
  String get white => '白';

  @override
  String get black => '黒';

  @override
  String get red => '赤';

  @override
  String get blue => '青';

  @override
  String get green => '緑';

  @override
  String get yellow => '黄';

  @override
  String get orange => 'オレンジ';

  @override
  String get purple => '紫';

  @override
  String get pink => 'ピンク';

  @override
  String get cyan => 'シアン';

  @override
  String get gray => 'グレー';

  @override
  String get magenta => 'マゼンタ';

  @override
  String get custom => 'カスタム';

  @override
  String get lightColor => '明るい色';

  @override
  String get darkColor => '暗い色';

  @override
  String get redTone => '赤系';

  @override
  String get greenTone => '緑系';

  @override
  String get blueTone => '青系';

  @override
  String get systemDefault => 'System Default';
}
