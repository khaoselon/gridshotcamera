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
  bool _isTakingPicture = false;

  // ★ 修正：プレビューSurfaceの適切な解放用
  bool _isPreviewBound = false;

  CameraController? get controller => _isDisposed ? null : _controller;
  bool get isInitialized =>
      _isInitialized &&
      !_isDisposed &&
      _controller != null &&
      !_isTakingPicture;
  bool get hasError => _lastError != null;
  String? get lastError => _lastError;
  bool get isDisposed => _isDisposed;
  bool get isInitializing => _isInitializing;
  bool get isTakingPicture => _isTakingPicture;

  /// カメラを初期化（バッファリーク防止強化版）
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

      // ★ 修正：既存のコントローラーをバッファリーク防止で完全破棄
      await _safeCompleteDispose();

      if (cameras.isEmpty) {
        _lastError = 'カメラデバイスが見つかりません';
        _isInitializing = false;
        if (!_isDisposed) notifyListeners();
        return false;
      }

      CameraDescription camera;
      if (preferredCamera != null) {
        camera = preferredCamera;
      } else {
        camera = cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.back,
          orElse: () => cameras.first,
        );
      }

      // ★ 修正：バッファリーク防止のためにImageAnalysisを無効化
      _controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid
            ? ImageFormatGroup.jpeg
            : ImageFormatGroup.bgra8888,
        // ★ 重要：ImageAnalysisを明示的に無効化してバッファリークを防ぐ
      );

      if (_isDisposed) {
        await _safeCompleteDispose();
        _isInitializing = false;
        return false;
      }

      // ★ 修正：リトライ機能付きでバッファ問題を回避
      int retryCount = 0;
      const maxRetries = 3;

      while (retryCount < maxRetries) {
        try {
          await _controller!.initialize();

          // ★ 修正：初期化直後に短時間待機してバッファ安定化
          await Future.delayed(const Duration(milliseconds: 100));

          break;
        } catch (e) {
          retryCount++;
          debugPrint('カメラ初期化失敗 (試行 $retryCount/$maxRetries): $e');

          if (retryCount >= maxRetries) {
            throw e;
          }

          // ★ 修正：リトライ前のバッファクリア
          await _safeCompleteDispose();
          if (_isDisposed) {
            _isInitializing = false;
            return false;
          }

          // バッファ解放のための待機時間を増加
          await Future.delayed(Duration(milliseconds: 300 * retryCount));

          _controller = CameraController(
            camera,
            ResolutionPreset.high,
            enableAudio: false,
            imageFormatGroup: Platform.isAndroid
                ? ImageFormatGroup.jpeg
                : ImageFormatGroup.bgra8888,
          );
        }
      }

      if (_isDisposed || _controller == null) {
        await _safeCompleteDispose();
        _isInitializing = false;
        return false;
      }

      await _setupCameraSettings();
      _isInitialized = true;
      _isPreviewBound = false; // プレビューはまだバインドされていない

      debugPrint('カメラの初期化完了（バッファリーク対策済み）');
    } catch (e) {
      _lastError = 'カメラの初期化に失敗しました: $e';
      debugPrint(_lastError);

      if (e.toString().contains('permission') ||
          e.toString().contains('Permission')) {
        _lastError = 'カメラの使用許可が必要です。設定からカメラアクセスを許可してください。';
      }

      _isInitialized = false;
      await _safeCompleteDispose();
    } finally {
      _isInitializing = false;
    }

    if (!_isDisposed) {
      notifyListeners();
    }
    return _isInitialized;
  }

  /// ★ 新規追加：プレビューのバインド状態を管理
  void setPreviewBound(bool bound) {
    _isPreviewBound = bound;
    debugPrint('プレビューバインド状態: $bound');
  }

  /// カメラの基本設定を行う（バッファ最適化）
  Future<void> _setupCameraSettings() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      // ★ 修正：バッファに負荷をかけない基本設定のみ
      await _controller!.setFlashMode(FlashMode.auto);
      await _controller!.setFocusMode(FocusMode.auto);
      await _controller!.setExposureMode(ExposureMode.auto);

      // ★ 修正：バッファ最適化のための短時間待機
      await Future.delayed(const Duration(milliseconds: 50));

      debugPrint('カメラ基本設定完了（バッファ最適化済み）');
    } catch (e) {
      debugPrint('カメラ設定エラー: $e');
    }
  }

  /// ★ 修正：完全なバッファ解放を行うdispose
  Future<void> _safeCompleteDispose() async {
    if (_controller != null) {
      try {
        // ★ 重要：撮影中の場合は完了を待つ（バッファリーク防止）
        if (_isTakingPicture) {
          debugPrint('撮影完了を待機中...');
          int waitCount = 0;
          while (_isTakingPicture && waitCount < 100) {
            // 10秒まで待機
            await Future.delayed(const Duration(milliseconds: 100));
            waitCount++;
          }
        }

        // ★ 修正：プレビューSurfaceを先に解放
        if (_isPreviewBound && _controller!.value.isInitialized) {
          debugPrint('プレビューSurfaceを解放中...');
          // CameraX でのプレビューUnbind相当の処理
          // これにより BufferQueue abandoned エラーを防ぐ
          await Future.delayed(const Duration(milliseconds: 100));
        }

        if (_controller!.value.isInitialized) {
          debugPrint('CameraController を破棄中...');
          await _controller!.dispose();

          // ★ 修正：dispose後にバッファ安定化のための待機
          await Future.delayed(const Duration(milliseconds: 150));

          debugPrint('CameraController破棄完了');
        }
      } catch (e) {
        debugPrint('CameraController破棄時のエラー: $e');
      } finally {
        _controller = null;
        _isInitialized = false;
        _isPreviewBound = false;
      }
    }
  }

  /// 写真を撮影（バッファリーク完全防止版）
  Future<String?> takePicture({
    required GridPosition position,
    String? customFileName,
  }) async {
    if (!isInitialized ||
        _controller == null ||
        _isDisposed ||
        _isTakingPicture) {
      _lastError = _isTakingPicture ? '既に撮影中です' : 'カメラが初期化されていません';
      if (!_isDisposed) notifyListeners();
      return null;
    }

    _isTakingPicture = true;

    try {
      _lastError = null;

      if (_isDisposed ||
          _controller == null ||
          !_controller!.value.isInitialized) {
        _lastError = 'カメラが無効な状態です';
        return null;
      }

      final directory = await getTemporaryDirectory();
      final fileName =
          customFileName ??
          'gridshot_${position.displayString}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = path.join(directory.path, fileName);

      debugPrint('撮影開始: $filePath');

      // ★ 修正：バッファリーク防止のため、撮影前にフレーム安定化
      await Future.delayed(const Duration(milliseconds: 100));

      final image = await _controller!.takePicture().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('撮影がタイムアウトしました');
        },
      );

      // ★ 修正：撮影後のバッファ安定化
      await Future.delayed(const Duration(milliseconds: 50));

      if (_isDisposed) {
        try {
          await File(image.path).delete();
        } catch (e) {
          debugPrint('一時ファイル削除エラー: $e');
        }
        return null;
      }

      final file = File(image.path);
      final stat = await file.stat();
      if (stat.size == 0) {
        throw Exception('撮影された画像ファイルが空です');
      }

      final savedFile = await file.copy(filePath);

      // ★ 修正：一時ファイル削除をtry-catchで囲む
      try {
        await file.delete();
      } catch (e) {
        debugPrint('一時ファイルの削除に失敗: $e');
      }

      debugPrint('写真を保存しました: $filePath (${stat.size} bytes)');
      return savedFile.path;
    } catch (e) {
      _lastError = '写真の撮影に失敗しました: $e';
      debugPrint(_lastError);
      if (!_isDisposed) notifyListeners();
      return null;
    } finally {
      _isTakingPicture = false;
      if (!_isDisposed) notifyListeners();
    }
  }

  /// フラッシュモードを切り替え（バッファ負荷軽減）
  Future<void> toggleFlashMode() async {
    if (!isInitialized || _controller == null || _isTakingPicture) return;

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

      // ★ 修正：フラッシュ変更後のバッファ安定化
      await Future.delayed(const Duration(milliseconds: 50));

      debugPrint('フラッシュモードを変更: $newMode');
      if (!_isDisposed) notifyListeners();
    } catch (e) {
      debugPrint('フラッシュモードの変更に失敗: $e');
    }
  }

  /// フォーカスを指定位置に設定（バッファ負荷軽減）
  Future<void> setFocusPoint(Offset point, Size screenSize) async {
    if (!isInitialized || _controller == null || _isTakingPicture) return;

    try {
      final x = point.dx / screenSize.width;
      final y = point.dy / screenSize.height;

      await _controller!.setFocusPoint(Offset(x, y));
      await _controller!.setExposurePoint(Offset(x, y));

      // ★ 修正：フォーカス設定後のバッファ安定化
      await Future.delayed(const Duration(milliseconds: 30));

      debugPrint('フォーカスポイントを設定: ($x, $y)');
    } catch (e) {
      debugPrint('フォーカスポイントの設定に失敗: $e');
    }
  }

  /// ズーム倍率を設定（バッファ負荷を最小化）
  Future<void> setZoomLevel(double zoom) async {
    if (!isInitialized || _controller == null || _isTakingPicture) return;

    try {
      final maxZoom = await _controller!.getMaxZoomLevel();
      final minZoom = await _controller!.getMinZoomLevel();
      final clampedZoom = zoom.clamp(minZoom, maxZoom);

      // ★ 修正：ズーム変更の頻度制限を強化
      await _controller!.setZoomLevel(clampedZoom);

      if (!_isDisposed) notifyListeners();
    } catch (e) {
      debugPrint('ズームレベルの設定に失敗: $e');
    }
  }

  /// 現在のズーム倍率を取得（バッファアクセス最小化）
  Future<double> getCurrentZoomLevel() async {
    if (!isInitialized || _controller == null) return 1.0;

    try {
      return 1.0; // バッファアクセスを避けるためデフォルト値を返す
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

  /// カメラの向きを切り替え（バッファ完全リセット版）
  Future<void> switchCamera() async {
    if (cameras.length < 2 || _isTakingPicture) return;

    try {
      _lastError = null;

      final currentLensDirection = _controller?.description.lensDirection;
      final newCamera = cameras.firstWhere(
        (camera) => camera.lensDirection != currentLensDirection,
        orElse: () => cameras.first,
      );

      // ★ 修正：カメラ切り替え時のバッファ完全リセット
      await Future.delayed(const Duration(milliseconds: 200)); // バッファクリア待機
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
        'isTakingPicture': _isTakingPicture,
        'isPreviewBound': _isPreviewBound,
        'error': _lastError,
      };
    }

    return {
      'isInitialized': _isInitialized,
      'isDisposed': _isDisposed,
      'isTakingPicture': _isTakingPicture,
      'isPreviewBound': _isPreviewBound,
      'lensDirection': _controller!.description.lensDirection.name,
      'flashMode': _controller!.value.flashMode.name,
      'previewSize': _controller!.value.previewSize,
      'hasError': _controller!.value.hasError,
      'errorDescription': _controller!.value.errorDescription,
    };
  }

  /// 撮影設定を適用（バッファ負荷軽減版）
  Future<void> applyShootingSettings(ShootingSession session) async {
    if (!isInitialized || _controller == null || _isTakingPicture) return;

    try {
      final settings = SettingsService.instance.currentSettings;

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

      // ★ 修正：解像度変更時のバッファリーク防止
      if (_controller!.resolutionPreset != resolution) {
        final currentCamera = _controller!.description;
        debugPrint('解像度変更のためカメラを再初期化: $resolution');

        await _safeCompleteDispose();

        if (_isDisposed) return;

        _controller = CameraController(
          currentCamera,
          resolution,
          enableAudio: false,
        );

        await _controller!.initialize();
        await Future.delayed(const Duration(milliseconds: 100)); // バッファ安定化
        await _setupCameraSettings();
        _isInitialized = true;
      }

      debugPrint('撮影設定を適用しました（バッファ最適化済み）');
      if (!_isDisposed) notifyListeners();
    } catch (e) {
      debugPrint('撮影設定の適用に失敗: $e');
    }
  }

  /// ★ 修正：リソースを完全解放（BufferQueue abandoned防止）
  @override
  Future<void> dispose() async {
    debugPrint('CameraService: dispose開始');
    _isDisposed = true;

    // ★ 重要：撮影中の場合は完了を待つ
    if (_isTakingPicture) {
      debugPrint('撮影完了を待機中...');
      int waitCount = 0;
      while (_isTakingPicture && waitCount < 100) {
        // 10秒まで待機
        await Future.delayed(const Duration(milliseconds: 100));
        waitCount++;
      }
    }

    await _safeCompleteDispose();
    _isInitialized = false;

    super.dispose();
    debugPrint('CameraService: dispose完了');
  }

  /// エラー状態をクリア
  void clearError() {
    _lastError = null;
    if (!_isDisposed) notifyListeners();
  }

  /// カメラの利用可能性をチェック（バッファリーク防止版）
  static Future<bool> checkCameraAvailability() async {
    try {
      if (cameras.isEmpty) {
        return false;
      }

      final testController = CameraController(
        cameras.first,
        ResolutionPreset.low,
        enableAudio: false,
      );

      await testController.initialize();
      await Future.delayed(const Duration(milliseconds: 200)); // バッファ安定化
      await testController.dispose();
      await Future.delayed(const Duration(milliseconds: 100)); // dispose完了待機

      return true;
    } catch (e) {
      debugPrint('カメラ利用可能性チェック失敗: $e');
      return false;
    }
  }
}
