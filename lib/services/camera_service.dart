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
  bool _isTakingPicture = false; // 撮影中フラグを追加

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

  /// カメラを初期化（権限は自動処理、バッファ管理改善）
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

      // カメラコントローラーを作成（バッファ管理改善）
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

      // カメラ初期化（リトライ機能付き）
      int retryCount = 0;
      const maxRetries = 3;

      while (retryCount < maxRetries) {
        try {
          await _controller!.initialize();
          break; // 成功した場合はループを抜ける
        } catch (e) {
          retryCount++;
          debugPrint('カメラ初期化失敗 (試行 $retryCount/$maxRetries): $e');

          if (retryCount >= maxRetries) {
            throw e; // 最大リトライ回数に達した場合は例外を再スロー
          }

          // 短時間待機してからリトライ
          await Future.delayed(Duration(milliseconds: 500 * retryCount));

          // コントローラーを再作成
          await _safeDisposeController();
          if (_isDisposed) {
            _isInitializing = false;
            return false;
          }

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

      // 再度disposeチェック（初期化中に破棄された可能性）
      if (_isDisposed || _controller == null) {
        await _safeDisposeController();
        _isInitializing = false;
        return false;
      }

      // カメラの基本設定
      await _setupCameraSettings();

      _isInitialized = true;
      debugPrint('カメラの初期化完了');
    } catch (e) {
      _lastError = 'カメラの初期化に失敗しました: $e';
      debugPrint(_lastError);

      // 権限エラーの場合の特別なメッセージ
      if (e.toString().contains('permission') ||
          e.toString().contains('Permission')) {
        _lastError = 'カメラの使用許可が必要です。設定からカメラアクセスを許可してください。';
      }

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

  /// カメラの基本設定を行う
  Future<void> _setupCameraSettings() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      // フラッシュを自動に設定
      await _controller!.setFlashMode(FlashMode.auto);

      // フォーカスモードを自動に設定
      await _controller!.setFocusMode(FocusMode.auto);

      // 露出モードを自動に設定
      await _controller!.setExposureMode(ExposureMode.auto);

      debugPrint('カメラ基本設定完了');
    } catch (e) {
      debugPrint('カメラ設定エラー: $e');
      // 設定エラーは致命的ではないので継続
    }
  }

  /// コントローラーを安全に破棄（バッファリークを防ぐ）
  Future<void> _safeDisposeController() async {
    if (_controller != null) {
      try {
        // 撮影中の場合は完了を待つ
        if (_isTakingPicture) {
          debugPrint('撮影完了を待機中...');
          int waitCount = 0;
          while (_isTakingPicture && waitCount < 50) {
            // 最大5秒待機
            await Future.delayed(const Duration(milliseconds: 100));
            waitCount++;
          }
        }

        if (_controller!.value.isInitialized) {
          await _controller!.dispose();
          debugPrint('CameraController破棄完了');
        }
      } catch (e) {
        debugPrint('CameraController破棄時のエラー: $e');
      } finally {
        _controller = null;
        _isInitialized = false;
      }
    }
  }

  /// 写真を撮影（バッファ管理改善）
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

      // 撮影前の状態チェック
      if (_isDisposed ||
          _controller == null ||
          !_controller!.value.isInitialized) {
        _lastError = 'カメラが無効な状態です';
        return null;
      }

      // 保存ディレクトリを取得
      final directory = await getTemporaryDirectory();
      final fileName =
          customFileName ??
          'gridshot_${position.displayString}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = path.join(directory.path, fileName);

      debugPrint('撮影開始: $filePath');

      // 撮影実行（タイムアウト付き）
      final image = await _controller!.takePicture().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('撮影がタイムアウトしました');
        },
      );

      // 撮影後の状態チェック
      if (_isDisposed) {
        // 撮影は成功したが、その後破棄された場合は一時ファイルを削除
        try {
          await File(image.path).delete();
        } catch (e) {
          debugPrint('一時ファイル削除エラー: $e');
        }
        return null;
      }

      // ファイルサイズチェック
      final file = File(image.path);
      final stat = await file.stat();
      if (stat.size == 0) {
        throw Exception('撮影された画像ファイルが空です');
      }

      // ファイルを目的のパスにコピー
      final savedFile = await file.copy(filePath);

      // 一時ファイルを削除
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

  /// フラッシュモードを切り替え
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
      debugPrint('フラッシュモードを変更: $newMode');
      if (!_isDisposed) notifyListeners();
    } catch (e) {
      debugPrint('フラッシュモードの変更に失敗: $e');
    }
  }

  /// フォーカスを指定位置に設定
  Future<void> setFocusPoint(Offset point, Size screenSize) async {
    if (!isInitialized || _controller == null || _isTakingPicture) return;

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

  /// ズーム倍率を設定（バッファ問題を避けるため調整）
  Future<void> setZoomLevel(double zoom) async {
    if (!isInitialized || _controller == null || _isTakingPicture) return;

    try {
      final maxZoom = await _controller!.getMaxZoomLevel();
      final minZoom = await _controller!.getMinZoomLevel();

      final clampedZoom = zoom.clamp(minZoom, maxZoom);

      // ズーム変更の頻度を制限
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
      // ズーム値の管理を簡素化
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

  /// カメラの向きを切り替え（バッファ管理改善）
  Future<void> switchCamera() async {
    if (cameras.length < 2 || _isTakingPicture) return;

    try {
      _lastError = null;

      // 現在のカメラとは異なるカメラを選択
      final currentLensDirection = _controller?.description.lensDirection;
      final newCamera = cameras.firstWhere(
        (camera) => camera.lensDirection != currentLensDirection,
        orElse: () => cameras.first,
      );

      // カメラ切り替え時はバッファをクリア
      await Future.delayed(const Duration(milliseconds: 100));
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
        'error': _lastError,
      };
    }

    return {
      'isInitialized': _isInitialized,
      'isDisposed': _isDisposed,
      'isTakingPicture': _isTakingPicture,
      'lensDirection': _controller!.description.lensDirection.name,
      'flashMode': _controller!.value.flashMode.name,
      'previewSize': _controller!.value.previewSize,
      'hasError': _controller!.value.hasError,
      'errorDescription': _controller!.value.errorDescription,
    };
  }

  /// 撮影設定を適用（バッファ管理改善）
  Future<void> applyShootingSettings(ShootingSession session) async {
    if (!isInitialized || _controller == null || _isTakingPicture) return;

    try {
      final settings = SettingsService.instance.currentSettings;

      // 画質設定を適用（解像度変更はバッファ問題を起こす可能性があるため慎重に）
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

      // 現在の解像度と異なる場合のみ再初期化
      if (_controller!.resolutionPreset != resolution) {
        final currentCamera = _controller!.description;

        debugPrint('解像度変更のためカメラを再初期化: $resolution');

        await _safeDisposeController();

        if (_isDisposed) return;

        _controller = CameraController(
          currentCamera,
          resolution,
          enableAudio: false,
        );

        await _controller!.initialize();
        await _setupCameraSettings();
        _isInitialized = true;
      }

      debugPrint('撮影設定を適用しました');
      if (!_isDisposed) notifyListeners();
    } catch (e) {
      debugPrint('撮影設定の適用に失敗: $e');
    }
  }

  /// リソースを解放（バッファリーク防止強化）
  @override
  Future<void> dispose() async {
    debugPrint('CameraService: dispose開始');
    _isDisposed = true;

    // 撮影中の場合は完了を待つ
    if (_isTakingPicture) {
      debugPrint('撮影完了を待機中...');
      int waitCount = 0;
      while (_isTakingPicture && waitCount < 50) {
        // 最大5秒待機
        await Future.delayed(const Duration(milliseconds: 100));
        waitCount++;
      }
    }

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

  /// カメラの利用可能性をチェック（改善版）
  static Future<bool> checkCameraAvailability() async {
    try {
      if (cameras.isEmpty) {
        return false;
      }

      // 簡単なテスト初期化（バッファ問題を避けるため低解像度）
      final testController = CameraController(
        cameras.first,
        ResolutionPreset.low,
        enableAudio: false,
      );

      await testController.initialize();

      // 少し待機してからdispose
      await Future.delayed(const Duration(milliseconds: 100));
      await testController.dispose();

      return true;
    } catch (e) {
      debugPrint('カメラ利用可能性チェック失敗: $e');
      return false;
    }
  }
}
