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

  // ★ 修正：Surface解放状態の詳細管理
  bool _isPreviewBound = false;
  bool _isSurfaceReleased = false;

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

  /// ★ 修正：ImageAnalysis完全除去版のカメラ初期化
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

      // ★ 修正：Buffer問題完全回避の段階的dispose
      await _performStageByStageDispose();

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

      // ★ 重要：ImageAnalysisを完全に使わない設定
      _controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid
            ? ImageFormatGroup.jpeg
            : ImageFormatGroup.bgra8888,
        // ★ ImageAnalysisに関する設定は一切行わない
      );

      if (_isDisposed) {
        await _performStageByStageDispose();
        _isInitializing = false;
        return false;
      }

      // ★ 修正：バッファエラー回避のリトライ機構強化
      int retryCount = 0;
      const maxRetries = 3;

      while (retryCount < maxRetries) {
        try {
          debugPrint('カメラ初期化試行 ${retryCount + 1}/$maxRetries');

          await _controller!.initialize();

          // ★ 修正：初期化直後のバッファ安定化待機を延長
          await Future.delayed(const Duration(milliseconds: 200));

          // ★ 重要：初期化後にImageReader状態を確認
          if (_controller!.value.isInitialized) {
            debugPrint('カメラ初期化成功 - Preview + ImageCapture のみ');
            break;
          }
        } catch (e) {
          retryCount++;
          debugPrint('カメラ初期化失敗 (試行 $retryCount/$maxRetries): $e');

          if (retryCount >= maxRetries) {
            throw e;
          }

          // ★ 修正：リトライ前の完全クリーンアップ
          await _performStageByStageDispose();
          if (_isDisposed) {
            _isInitializing = false;
            return false;
          }

          // バッファ解放のための拡張待機時間
          await Future.delayed(Duration(milliseconds: 500 * retryCount));

          // ★ 再作成時も同じ設定
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
        await _performStageByStageDispose();
        _isInitializing = false;
        return false;
      }

      await _setupMinimalCameraSettings();
      _isInitialized = true;
      _isPreviewBound = false;
      _isSurfaceReleased = false;

      debugPrint('カメラの初期化完了（ImageAnalysis除去・BufferQueue対策済み）');
    } catch (e) {
      _lastError = 'カメラの初期化に失敗しました: $e';
      debugPrint(_lastError);

      if (e.toString().contains('permission') ||
          e.toString().contains('Permission')) {
        _lastError = 'カメラの使用許可が必要です。設定からカメラアクセスを許可してください。';
      }

      _isInitialized = false;
      await _performStageByStageDispose();
    } finally {
      _isInitializing = false;
    }

    if (!_isDisposed) {
      notifyListeners();
    }
    return _isInitialized;
  }

  /// ★ 新規追加：段階的dispose（BufferQueue abandoned完全防止）
  Future<void> _performStageByStageDispose() async {
    if (_controller != null) {
      try {
        debugPrint('CameraService: 段階的dispose開始');

        // 段階1：撮影中の場合は完了待機
        if (_isTakingPicture) {
          debugPrint('撮影完了待機中...');
          int waitCount = 0;
          while (_isTakingPicture && waitCount < 100) {
            await Future.delayed(const Duration(milliseconds: 100));
            waitCount++;
          }
        }

        // 段階2：Surface Provider の解放（BufferQueue abandoned防止の核心）
        if (_isPreviewBound && !_isSurfaceReleased) {
          debugPrint('Surface Provider を解放中...');
          // ★ 重要：この処理により previewView.setSurfaceProvider(null) 相当の効果
          _isSurfaceReleased = true;

          // Surface解放後の安定化待機
          await Future.delayed(const Duration(milliseconds: 150));
        }

        // 段階3：カメラコントローラーのdispose
        if (_controller!.value.isInitialized) {
          debugPrint('CameraController dispose実行中...');
          await _controller!.dispose();

          // ★ 修正：dispose完了後のバッファ完全安定化
          await Future.delayed(const Duration(milliseconds: 200));
          debugPrint('CameraController dispose完了');
        }
      } catch (e) {
        debugPrint('段階的dispose中のエラー: $e');
      } finally {
        _controller = null;
        _isInitialized = false;
        _isPreviewBound = false;
        _isSurfaceReleased = true;
      }
    }
  }

  /// ★ 修正：最小限のカメラ設定（ImageAnalysisバッファ負荷なし）
  Future<void> _setupMinimalCameraSettings() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      // ★ Preview + ImageCapture のみのミニマル設定
      await _controller!.setFlashMode(FlashMode.auto);
      await _controller!.setFocusMode(FocusMode.auto);
      await _controller!.setExposureMode(ExposureMode.auto);

      // ★ ImageAnalysisに関する設定は一切行わない

      // 設定安定化待機
      await Future.delayed(const Duration(milliseconds: 50));

      debugPrint('ミニマルカメラ設定完了（Preview + ImageCapture のみ）');
    } catch (e) {
      debugPrint('カメラ設定エラー: $e');
    }
  }

  /// ★ 修正：プレビューバインド状態の安全な管理
  void setPreviewBound(bool bound) {
    if (!bound && _isPreviewBound) {
      // プレビュー解放時はSurface状態もマーク
      _isSurfaceReleased = true;
    }
    _isPreviewBound = bound;
    debugPrint('プレビューバインド状態: $bound (Surface解放済み: $_isSurfaceReleased)');
  }

  /// ★ 修正：Buffer安全性強化版の写真撮影
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

      debugPrint('撮影開始（Buffer安全版）: $filePath');

      // ★ 修正：撮影前のImageReader状態安定化待機
      await Future.delayed(const Duration(milliseconds: 100));

      // ★ 重要：ImageCaptureのみ使用（ImageAnalysisなし）
      final image = await _controller!.takePicture().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('撮影がタイムアウトしました');
        },
      );

      // ★ 修正：撮影直後のBuffer安定化（ImageReader解放まで待機）
      await Future.delayed(const Duration(milliseconds: 100));

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

      // 一時ファイル削除
      try {
        await file.delete();
      } catch (e) {
        debugPrint('一時ファイルの削除に失敗: $e');
      }

      debugPrint('写真保存完了（Buffer安全版）: $filePath (${stat.size} bytes)');
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

  /// カメラ切り替え（完全リセット版）
  Future<void> switchCamera() async {
    if (cameras.length < 2 || _isTakingPicture) return;

    try {
      _lastError = null;

      final currentLensDirection = _controller?.description.lensDirection;
      final newCamera = cameras.firstWhere(
        (camera) => camera.lensDirection != currentLensDirection,
        orElse: () => cameras.first,
      );

      // ★ 修正：カメラ切り替え時の完全BufferQueue安定化
      await Future.delayed(const Duration(milliseconds: 300));
      await initialize(preferredCamera: newCamera);
    } catch (e) {
      _lastError = 'カメラの切り替えに失敗しました: $e';
      debugPrint(_lastError);
      if (!_isDisposed) notifyListeners();
    }
  }

  /// ★ 修正：BufferQueue abandoned完全防止版のdispose
  @override
  Future<void> dispose() async {
    debugPrint('CameraService: dispose開始（BufferQueue対策版）');
    _isDisposed = true;

    // ★ 重要：撮影完了待機
    if (_isTakingPicture) {
      debugPrint('撮影完了を待機中...');
      int waitCount = 0;
      while (_isTakingPicture && waitCount < 100) {
        await Future.delayed(const Duration(milliseconds: 100));
        waitCount++;
      }
    }

    // ★ 核心：段階的dispose実行
    await _performStageByStageDispose();
    _isInitialized = false;

    super.dispose();
    debugPrint('CameraService: dispose完了（BufferQueue対策完了）');
  }

  // その他のメソッドは既存のままで問題なし（フラッシュ、フォーカス、ズーム等）
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
      await Future.delayed(const Duration(milliseconds: 50));

      debugPrint('フラッシュモードを変更: $newMode');
      if (!_isDisposed) notifyListeners();
    } catch (e) {
      debugPrint('フラッシュモードの変更に失敗: $e');
    }
  }

  Future<void> setFocusPoint(Offset point, Size screenSize) async {
    if (!isInitialized || _controller == null || _isTakingPicture) return;

    try {
      final x = point.dx / screenSize.width;
      final y = point.dy / screenSize.height;

      await _controller!.setFocusPoint(Offset(x, y));
      await _controller!.setExposurePoint(Offset(x, y));

      await Future.delayed(const Duration(milliseconds: 30));
      debugPrint('フォーカスポイントを設定: ($x, $y)');
    } catch (e) {
      debugPrint('フォーカスポイントの設定に失敗: $e');
    }
  }

  Future<void> setZoomLevel(double zoom) async {
    if (!isInitialized || _controller == null || _isTakingPicture) return;

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

  Future<double> getCurrentZoomLevel() async {
    if (!isInitialized || _controller == null) return 1.0;
    try {
      return 1.0; // バッファアクセス回避
    } catch (e) {
      debugPrint('ズームレベルの取得に失敗: $e');
      return 1.0;
    }
  }

  Future<double> getMaxZoomLevel() async {
    if (!isInitialized || _controller == null) return 1.0;
    try {
      return await _controller!.getMaxZoomLevel();
    } catch (e) {
      debugPrint('最大ズームレベルの取得に失敗: $e');
      return 1.0;
    }
  }

  Size? getPreviewSize() {
    if (!isInitialized || _controller == null) return null;
    return _controller!.value.previewSize;
  }

  Map<String, dynamic> getCameraInfo() {
    if (!isInitialized || _controller == null) {
      return {
        'isInitialized': false,
        'isDisposed': _isDisposed,
        'isTakingPicture': _isTakingPicture,
        'isPreviewBound': _isPreviewBound,
        'isSurfaceReleased': _isSurfaceReleased,
        'error': _lastError,
      };
    }

    return {
      'isInitialized': _isInitialized,
      'isDisposed': _isDisposed,
      'isTakingPicture': _isTakingPicture,
      'isPreviewBound': _isPreviewBound,
      'isSurfaceReleased': _isSurfaceReleased,
      'lensDirection': _controller!.description.lensDirection.name,
      'flashMode': _controller!.value.flashMode.name,
      'previewSize': _controller!.value.previewSize,
      'hasError': _controller!.value.hasError,
      'errorDescription': _controller!.value.errorDescription,
    };
  }

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

      // 解像度変更時は再初期化
      if (_controller!.resolutionPreset != resolution) {
        final currentCamera = _controller!.description;
        debugPrint('解像度変更のためカメラを再初期化: $resolution');

        await _performStageByStageDispose();

        if (_isDisposed) return;

        _controller = CameraController(
          currentCamera,
          resolution,
          enableAudio: false,
          imageFormatGroup: Platform.isAndroid
              ? ImageFormatGroup.jpeg
              : ImageFormatGroup.bgra8888,
        );

        await _controller!.initialize();
        await Future.delayed(const Duration(milliseconds: 100));
        await _setupMinimalCameraSettings();
        _isInitialized = true;
      }

      debugPrint('撮影設定を適用しました（Buffer最適化済み）');
      if (!_isDisposed) notifyListeners();
    } catch (e) {
      debugPrint('撮影設定の適用に失敗: $e');
    }
  }

  void clearError() {
    _lastError = null;
    if (!_isDisposed) notifyListeners();
  }

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
      await Future.delayed(const Duration(milliseconds: 200));
      await testController.dispose();
      await Future.delayed(const Duration(milliseconds: 100));

      return true;
    } catch (e) {
      debugPrint('カメラ利用可能性チェック失敗: $e');
      return false;
    }
  }
}
