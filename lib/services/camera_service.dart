import 'dart:io';
import 'dart:ui' show Offset, Size;
import 'package:gridshot_camera/models/app_settings.dart';
import 'package:flutter/foundation.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:gridshot_camera/main.dart';
import 'package:gridshot_camera/models/grid_style.dart';
import 'package:gridshot_camera/models/shooting_mode.dart';
import 'package:gridshot_camera/services/settings_service.dart';

class CameraService extends ChangeNotifier {
  CameraController? _controller;
  bool _isInitialized = false;
  bool _isDisposed = false;
  bool _isInitializing = false;
  String? _lastError;

  CameraController? get controller => _isDisposed ? null : _controller;
  bool get isInitialized =>
      _isInitialized && !_isDisposed && _controller != null;
  bool get hasError => _lastError != null;
  String? get lastError => _lastError;
  bool get isDisposed => _isDisposed;
  bool get isInitializing => _isInitializing;

  /// カメラを初期化
  Future<bool> initialize({CameraDescription? preferredCamera}) async {
    if (_isDisposed) {
      debugPrint('CameraService: 既に破棄済みのため初期化をスキップします');
      return false;
    }

    if (_isInitializing) {
      debugPrint('CameraService: 既に初期化中です');
      return false;
    }

    _isInitializing = true;

    try {
      _lastError = null;

      // 既存のコントローラーを安全に破棄
      await _safeDisposeController();

      // カメラが利用可能かチェック
      if (cameras.isEmpty) {
        _lastError = 'カメラデバイスが見つかりません';
        _isInitializing = false;
        if (!_isDisposed) notifyListeners();
        return false;
      }

      // 使用するカメラを選択（背面カメラを優先）
      CameraDescription camera;
      if (preferredCamera != null) {
        camera = preferredCamera;
      } else {
        camera = cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.back,
          orElse: () => cameras.first,
        );
      }

      // カメラコントローラーを作成
      _controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false, // 音声は不要
        imageFormatGroup: Platform.isAndroid
            ? ImageFormatGroup.jpeg
            : ImageFormatGroup.bgra8888,
      );

      // disposeチェック
      if (_isDisposed) {
        await _safeDisposeController();
        _isInitializing = false;
        return false;
      }

      await _controller!.initialize();

      // 再度disposeチェック（初期化中に破棄された可能性）
      if (_isDisposed) {
        await _safeDisposeController();
        _isInitializing = false;
        return false;
      }

      // フラッシュを自動に設定
      await _controller!.setFlashMode(FlashMode.auto);

      // フォーカスモードを自動に設定
      await _controller!.setFocusMode(FocusMode.auto);

      _isInitialized = true;
      debugPrint('カメラの初期化完了');
    } catch (e) {
      _lastError = 'カメラの初期化に失敗しました: $e';
      debugPrint(_lastError);
      _isInitialized = false;
      await _safeDisposeController();
    } finally {
      _isInitializing = false;
    }

    if (!_isDisposed) {
      notifyListeners();
    }
    return _isInitialized;
  }

  /// コントローラーを安全に破棄
  Future<void> _safeDisposeController() async {
    if (_controller != null) {
      try {
        if (_controller!.value.isInitialized) {
          await _controller!.dispose();
        }
      } catch (e) {
        debugPrint('CameraController破棄時のエラー: $e');
      }
      _controller = null;
    }
    _isInitialized = false;
  }

  /// 写真を撮影
  Future<String?> takePicture({
    required GridPosition position,
    String? customFileName,
  }) async {
    if (!isInitialized || _controller == null || _isDisposed) {
      _lastError = 'カメラが初期化されていません';
      if (!_isDisposed) notifyListeners();
      return null;
    }

    try {
      _lastError = null;

      // 保存ディレクトリを取得
      final directory = await getTemporaryDirectory();
      final fileName =
          customFileName ??
          'gridshot_${position.displayString}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = path.join(directory.path, fileName);

      // 撮影実行（disposeチェック付き）
      if (_isDisposed ||
          _controller == null ||
          !_controller!.value.isInitialized) {
        _lastError = 'カメラが無効な状態です';
        if (!_isDisposed) notifyListeners();
        return null;
      }

      final image = await _controller!.takePicture();

      // 撮影後のdisposeチェック
      if (_isDisposed) {
        // 撮影は成功したが、その後破棄された場合は一時ファイルを削除
        try {
          await File(image.path).delete();
        } catch (e) {
          debugPrint('一時ファイル削除エラー: $e');
        }
        return null;
      }

      // ファイルを目的のパスにコピー
      final file = File(image.path);
      final savedFile = await file.copy(filePath);

      // 一時ファイルを削除
      try {
        await file.delete();
      } catch (e) {
        debugPrint('一時ファイルの削除に失敗: $e');
      }

      debugPrint('写真を保存しました: $filePath');
      return savedFile.path;
    } catch (e) {
      _lastError = '写真の撮影に失敗しました: $e';
      debugPrint(_lastError);
      if (!_isDisposed) notifyListeners();
      return null;
    }
  }

  /// フラッシュモードを切り替え
  Future<void> toggleFlashMode() async {
    if (!isInitialized || _controller == null) return;

    try {
      final currentMode = _controller!.value.flashMode;
      FlashMode newMode;

      switch (currentMode) {
        case FlashMode.off:
          newMode = FlashMode.auto;
          break;
        case FlashMode.auto:
          newMode = FlashMode.always;
          break;
        case FlashMode.always:
          newMode = FlashMode.off;
          break;
        case FlashMode.torch:
          newMode = FlashMode.off;
          break;
      }

      await _controller!.setFlashMode(newMode);
      debugPrint('フラッシュモードを変更: $newMode');
      if (!_isDisposed) notifyListeners();
    } catch (e) {
      debugPrint('フラッシュモードの変更に失敗: $e');
    }
  }

  /// フォーカスを指定位置に設定
  Future<void> setFocusPoint(Offset point, Size screenSize) async {
    if (!isInitialized || _controller == null) return;

    try {
      // 画面座標をカメラ座標に変換
      final x = point.dx / screenSize.width;
      final y = point.dy / screenSize.height;

      await _controller!.setFocusPoint(Offset(x, y));
      await _controller!.setExposurePoint(Offset(x, y));

      debugPrint('フォーカスポイントを設定: ($x, $y)');
    } catch (e) {
      debugPrint('フォーカスポイントの設定に失敗: $e');
    }
  }

  /// ズーム倍率を設定
  Future<void> setZoomLevel(double zoom) async {
    if (!isInitialized || _controller == null) return;

    try {
      final maxZoom = await _controller!.getMaxZoomLevel();
      final minZoom = await _controller!.getMinZoomLevel();

      final clampedZoom = zoom.clamp(minZoom, maxZoom);
      await _controller!.setZoomLevel(clampedZoom);

      if (!_isDisposed) notifyListeners();
    } catch (e) {
      debugPrint('ズームレベルの設定に失敗: $e');
    }
  }

  /// 現在のズーム倍率を取得
  Future<double> getCurrentZoomLevel() async {
    if (!isInitialized || _controller == null) return 1.0;

    try {
      // 新しいFlutter版では、ズーム値は直接取得できないため、内部で管理
      return 1.0; // デフォルト値を返す
    } catch (e) {
      debugPrint('ズームレベルの取得に失敗: $e');
      return 1.0;
    }
  }

  /// 最大ズーム倍率を取得
  Future<double> getMaxZoomLevel() async {
    if (!isInitialized || _controller == null) return 1.0;

    try {
      return await _controller!.getMaxZoomLevel();
    } catch (e) {
      debugPrint('最大ズームレベルの取得に失敗: $e');
      return 1.0;
    }
  }

  /// カメラの向きを切り替え
  Future<void> switchCamera() async {
    if (cameras.length < 2) return;

    try {
      _lastError = null;

      // 現在のカメラとは異なるカメラを選択
      final currentLensDirection = _controller?.description.lensDirection;
      final newCamera = cameras.firstWhere(
        (camera) => camera.lensDirection != currentLensDirection,
        orElse: () => cameras.first,
      );

      await initialize(preferredCamera: newCamera);
    } catch (e) {
      _lastError = 'カメラの切り替えに失敗しました: $e';
      debugPrint(_lastError);
      if (!_isDisposed) notifyListeners();
    }
  }

  /// プレビューサイズを取得
  Size? getPreviewSize() {
    if (!isInitialized || _controller == null) return null;
    return _controller!.value.previewSize;
  }

  /// カメラの状態情報を取得
  Map<String, dynamic> getCameraInfo() {
    if (!isInitialized || _controller == null) {
      return {
        'isInitialized': false,
        'isDisposed': _isDisposed,
        'error': _lastError,
      };
    }

    return {
      'isInitialized': _isInitialized,
      'isDisposed': _isDisposed,
      'lensDirection': _controller!.description.lensDirection.name,
      'flashMode': _controller!.value.flashMode.name,
      'previewSize': _controller!.value.previewSize,
      'hasError': _controller!.value.hasError,
      'errorDescription': _controller!.value.errorDescription,
    };
  }

  /// 撮影設定を適用
  Future<void> applyShootingSettings(ShootingSession session) async {
    if (!isInitialized || _controller == null) return;

    try {
      final settings = SettingsService.instance.currentSettings;

      // 画質設定を適用（ここでは解像度で代用）
      ResolutionPreset resolution;
      switch (settings.imageQuality) {
        case ImageQuality.high:
          resolution = ResolutionPreset.high;
          break;
        case ImageQuality.medium:
          resolution = ResolutionPreset.medium;
          break;
        case ImageQuality.low:
          resolution = ResolutionPreset.low;
          break;
      }

      // 必要に応じてカメラを再初期化
      if (_controller!.resolutionPreset != resolution) {
        final currentCamera = _controller!.description;

        await _safeDisposeController();

        if (_isDisposed) return;

        _controller = CameraController(
          currentCamera,
          resolution,
          enableAudio: false,
        );

        await _controller!.initialize();
        _isInitialized = true;
      }

      debugPrint('撮影設定を適用しました');
      if (!_isDisposed) notifyListeners();
    } catch (e) {
      debugPrint('撮影設定の適用に失敗: $e');
    }
  }

  /// リソースを解放
  @override
  Future<void> dispose() async {
    debugPrint('CameraService: dispose開始');
    _isDisposed = true;

    await _safeDisposeController();

    _isInitialized = false;
    super.dispose();
    debugPrint('CameraService: dispose完了');
  }

  /// エラー状態をクリア
  void clearError() {
    _lastError = null;
    if (!_isDisposed) notifyListeners();
  }

  /// カメラの利用可能性をチェック
  static Future<bool> checkCameraAvailability() async {
    try {
      if (cameras.isEmpty) {
        return false;
      }

      // 簡単なテスト初期化
      final testController = CameraController(
        cameras.first,
        ResolutionPreset.low,
        enableAudio: false,
      );

      await testController.initialize();
      await testController.dispose();

      return true;
    } catch (e) {
      debugPrint('カメラ利用可能性チェック失敗: $e');
      return false;
    }
  }
}
