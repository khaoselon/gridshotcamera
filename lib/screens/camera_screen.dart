import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../l10n/app_localizations.dart';
import 'package:gridshot_camera/models/grid_style.dart';
import 'package:gridshot_camera/models/shooting_mode.dart';
import 'package:gridshot_camera/services/camera_service.dart';
import 'package:gridshot_camera/services/ad_service.dart';
import 'package:gridshot_camera/services/settings_service.dart';
import 'package:gridshot_camera/screens/preview_screen.dart';
import 'package:gridshot_camera/widgets/grid_preview_widget.dart';
import 'package:gridshot_camera/widgets/loading_widget.dart';
import 'package:gridshot_camera/widgets/segmented_progress_bar.dart';

class CameraScreen extends StatefulWidget {
  final ShootingMode mode;
  final GridStyle gridStyle;

  const CameraScreen({super.key, required this.mode, required this.gridStyle});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  late CameraService _cameraService;
  late ShootingSession _session;

  bool _isInitializing = true;
  bool _isTakingPicture = false;
  String? _errorMessage;
  bool _isScreenDisposed = false;

  // アニメーション関連
  late AnimationController _flashAnimationController;
  late AnimationController _progressAnimationController;
  late Animation<double> _flashAnimation;
  late Animation<double> _progressAnimation;

  // UI状態
  double _currentZoom = 1.0;
  double _minZoom = 1.0;
  double _maxZoom = 1.0;
  FlashMode _currentFlashMode = FlashMode.auto;

  // 広告関連は削除（カメラ画面では広告を表示しない）

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _initializeSession();
    _initializeAnimations();
    _initializeCamera(); // 権限チェックを削除し直接初期化

    // バナー広告のロードは削除（カメラ画面では広告を表示しない）
  }

  @override
  void dispose() {
    debugPrint('CameraScreen: dispose開始');
    _isScreenDisposed = true;

    WidgetsBinding.instance.removeObserver(this);
    _flashAnimationController.dispose();
    _progressAnimationController.dispose();

    // CameraServiceの破棄
    _cameraService.dispose();

    // バナー広告の破棄は削除（元々作成していないため）
    super.dispose();
    debugPrint('CameraScreen: dispose完了');
  }

  void _initializeSession() {
    _session = ShootingSession(mode: widget.mode, gridStyle: widget.gridStyle);
  }

  void _initializeAnimations() {
    _flashAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _flashAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_flashAnimationController);

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _progressAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  /// カメラ初期化（権限チェックを削除）
  Future<void> _initializeCamera() async {
    if (_isScreenDisposed) return;

    setState(() {
      _isInitializing = true;
      _errorMessage = null;
    });

    try {
      debugPrint('カメラサービスを初期化します');

      // カメラサービス初期化（権限はホーム画面で確認済み）
      _cameraService = CameraService();
      _cameraService.addListener(_onCameraServiceChanged);

      final success = await _cameraService.initialize();
      if (success && mounted && !_isScreenDisposed) {
        // ズーム範囲を取得
        _minZoom = 1.0;
        _maxZoom = await _cameraService.getMaxZoomLevel();
        _currentZoom = await _cameraService.getCurrentZoomLevel();

        // 撮影設定を適用
        await _cameraService.applyShootingSettings(_session);

        setState(() {
          _isInitializing = false;
        });

        // プログレスアニメーションを開始
        _updateProgressAnimation();

        debugPrint('カメラの初期化が完了しました');
      } else if (mounted && !_isScreenDisposed) {
        setState(() {
          _isInitializing = false;
          _errorMessage = _cameraService.lastError ?? 'カメラの初期化に失敗しました';
        });
      }
    } catch (e) {
      debugPrint('カメラ初期化エラー: $e');
      if (mounted && !_isScreenDisposed) {
        setState(() {
          _isInitializing = false;
          _errorMessage = 'カメラの初期化中にエラーが発生しました: $e';
        });
      }
    }
  }

  void _onCameraServiceChanged() {
    if (mounted && !_isScreenDisposed) {
      setState(() {
        if (_cameraService.hasError) {
          _errorMessage = _cameraService.lastError;
        } else {
          _errorMessage = null;
        }
      });
    }
  }

  // バナー広告のロードメソッドは削除

  void _updateProgressAnimation() {
    if (_isScreenDisposed) return;

    final progress = _session.progress;
    _progressAnimationController.animateTo(progress);
  }

  Future<void> _takePicture() async {
    if (_isTakingPicture || !_cameraService.isInitialized || _isScreenDisposed)
      return;

    setState(() {
      _isTakingPicture = true;
    });

    try {
      // フラッシュアニメーション
      _flashAnimationController.forward().then((_) {
        if (!_isScreenDisposed) {
          _flashAnimationController.reverse();
        }
      });

      // 撮影実行
      final currentPosition = _session.currentPosition;
      final filePath = await _cameraService.takePicture(
        position: currentPosition,
      );

      if (filePath != null && mounted && !_isScreenDisposed) {
        // 撮影成功
        final capturedImage = CapturedImage(
          filePath: filePath,
          timestamp: DateTime.now(),
          position: currentPosition,
        );

        _session.captureImage(capturedImage);

        // プログレスアニメーションを更新
        _updateProgressAnimation();

        // 撮影完了の効果音やハプティックフィードバック
        HapticFeedback.lightImpact();

        // 次の位置に移動
        if (!_session.isCompleted) {
          _session.moveToNext();
        }

        // 全て撮影完了した場合
        if (_session.isCompleted) {
          await _onShootingCompleted();
        }
      } else if (mounted && !_isScreenDisposed) {
        _showError('撮影に失敗しました');
      }
    } catch (e) {
      if (mounted && !_isScreenDisposed) {
        _showError('撮影中にエラーが発生しました: $e');
      }
    } finally {
      if (mounted && !_isScreenDisposed) {
        setState(() {
          _isTakingPicture = false;
        });
      }
    }
  }

  Future<void> _onShootingCompleted() async {
    if (_isScreenDisposed) return;

    // 完了時の広告表示
    await AdService.instance.showInterstitialAd();

    if (!mounted || _isScreenDisposed) return;

    // プレビュー画面に移動
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => PreviewScreen(session: _session)),
    );
  }

  void _retakeCurrentPicture() {
    if (_session.hasCurrentImage && !_isScreenDisposed) {
      setState(() {
        _session.capturedImages[_session.currentIndex] = null;
        _updateProgressAnimation();
      });
    }
  }

  Future<void> _toggleFlashMode() async {
    if (_isScreenDisposed) return;

    await _cameraService.toggleFlashMode();
    if (mounted && !_isScreenDisposed && _cameraService.controller != null) {
      setState(() {
        _currentFlashMode = _cameraService.controller!.value.flashMode;
      });
    }
  }

  Future<void> _switchCamera() async {
    if (_isScreenDisposed) return;
    await _cameraService.switchCamera();
  }

  void _onZoomChanged(double zoom) {
    if (_isScreenDisposed) return;

    final clampedZoom = zoom.clamp(_minZoom, _maxZoom);
    _cameraService.setZoomLevel(clampedZoom);
    setState(() {
      _currentZoom = clampedZoom;
    });
  }

  void _onTapToFocus(TapUpDetails details) {
    if (!_cameraService.isInitialized || _isScreenDisposed) return;

    final renderBox = context.findRenderObject() as RenderBox;
    final tapPosition = details.localPosition;
    final screenSize = renderBox.size;

    _cameraService.setFocusPoint(tapPosition, screenSize);

    // フォーカスポイントの視覚的フィードバック
    _showFocusPoint(tapPosition);
  }

  void _showFocusPoint(Offset position) {
    // フォーカスポイントの視覚的表示（実装を簡略化）
    HapticFeedback.selectionClick();
  }

  void _showError(String message) {
    if (_isScreenDisposed) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_isScreenDisposed) return;

    // より安全なライフサイクル管理
    switch (state) {
      case AppLifecycleState.inactive:
        // アプリが非アクティブになった時の処理
        debugPrint('CameraScreen: アプリが非アクティブになりました');
        break;
      case AppLifecycleState.paused:
        // アプリがバックグラウンドに移った時の処理
        debugPrint('CameraScreen: アプリがバックグラウンドに移りました');
        break;
      case AppLifecycleState.resumed:
        // アプリがフォアグラウンドに戻った時の処理
        debugPrint('CameraScreen: アプリがフォアグラウンドに戻りました');
        if (!_cameraService.isInitialized && !_cameraService.isInitializing) {
          _initializeCamera();
        }
        break;
      case AppLifecycleState.detached:
        // アプリが終了する時の処理
        debugPrint('CameraScreen: アプリが終了します');
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: _buildBody(context, l10n, theme),
    );
  }

  Widget _buildBody(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    if (_isInitializing) {
      return LoadingWidget(message: l10n.loading);
    }

    if (_errorMessage != null) {
      return _buildErrorView(l10n);
    }

    return Stack(
      children: [
        // カメラプレビュー
        _buildCameraPreview(),

        // フラッシュオーバーレイ
        AnimatedBuilder(
          animation: _flashAnimation,
          builder: (context, child) {
            return _flashAnimation.value > 0
                ? Container(
                    color: Colors.white.withValues(
                      alpha: _flashAnimation.value * 0.8,
                    ),
                  )
                : const SizedBox.shrink();
          },
        ),

        // グリッドオーバーレイ
        _buildGridOverlay(),

        // UI コントロール
        _buildUIControls(l10n, theme),

        // バナー広告は削除（カメラ画面では表示しない）
      ],
    );
  }

  Widget _buildErrorView(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              l10n.error,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _initializeCamera,
              child: Text(l10n.retry),
            ), // 多言語化対応
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                l10n.cancel,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraPreview() {
    // より厳密な状態チェック
    if (!_cameraService.isInitialized ||
        _cameraService.controller == null ||
        _cameraService.isDisposed ||
        !_cameraService.controller!.value.isInitialized) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Text(
            AppLocalizations.of(context)!.preparingCamera, // 多言語化対応
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      );
    }

    return GestureDetector(
      onTapUp: _onTapToFocus,
      onScaleUpdate: (details) {
        if (details.scale != 1.0) {
          final zoom = (_currentZoom * details.scale).clamp(_minZoom, _maxZoom);
          _onZoomChanged(zoom);
        }
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final controller = _cameraService.controller!;
          final screenSize = Size(constraints.maxWidth, constraints.maxHeight);

          // カメラのアスペクト比を取得
          final cameraAspectRatio = controller.value.aspectRatio;

          // 画面のアスペクト比を計算
          final screenAspectRatio = screenSize.width / screenSize.height;

          double scaleX, scaleY;
          if (cameraAspectRatio > screenAspectRatio) {
            // カメラの方が横長の場合、高さに合わせる
            scaleY = screenSize.height;
            scaleX = screenSize.height * cameraAspectRatio;
          } else {
            // カメラの方が縦長の場合、幅に合わせる
            scaleX = screenSize.width;
            scaleY = screenSize.width / cameraAspectRatio;
          }

          return Center(
            child: ClipRect(
              child: Container(
                width: scaleX,
                height: scaleY,
                child: CameraPreview(controller),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGridOverlay() {
    final settings = SettingsService.instance.currentSettings;

    return Positioned.fill(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return GridOverlay(
            gridStyle: widget.gridStyle,
            size: Size(constraints.maxWidth, constraints.maxHeight),
            currentIndex: _session.currentIndex,
            borderColor: settings.showGridBorder
                ? settings.borderColor
                : Colors.transparent,
            borderWidth: settings.showGridBorder ? settings.borderWidth : 0,
            showCellNumbers: true,
            shootingMode: widget.mode,
          );
        },
      ),
    );
  }

  Widget _buildUIControls(AppLocalizations l10n, ThemeData theme) {
    return SafeArea(
      child: Column(
        children: [
          // 上部コントロール
          _buildTopControls(l10n),

          const Spacer(),

          // 下部コントロール
          _buildBottomControls(l10n, theme),
        ],
      ),
    );
  }

  Widget _buildTopControls(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          // 戻るボタン
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            style: IconButton.styleFrom(
              backgroundColor: Colors.black.withValues(alpha: 0.5),
            ),
          ),

          const Spacer(),

          // 撮影情報
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Text(
                  l10n.currentPosition(_session.currentPosition.displayString),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // セグメント化されたプログレスバー
                DetailedSegmentedProgressBar(
                  gridStyle: widget.gridStyle,
                  completedCount: _session.completedCount,
                  currentIndex: _session.currentIndex,
                  width: 140,
                  height: 6,
                  showLabels: false, // ラベルは上で表示しているのでfalse
                ),

                const SizedBox(height: 6),
                Text(
                  '${_session.completedCount}/${_session.gridStyle.totalCells}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),

          const Spacer(),

          // カメラ切り替え
          IconButton(
            onPressed: _switchCamera,
            icon: const Icon(Icons.flip_camera_ios, color: Colors.white),
            style: IconButton.styleFrom(
              backgroundColor: Colors.black.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls(AppLocalizations l10n, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // フラッシュ切り替え
          IconButton(
            onPressed: _toggleFlashMode,
            icon: Icon(_getFlashIcon()),
            color: Colors.white,
            style: IconButton.styleFrom(
              backgroundColor: Colors.black.withValues(alpha: 0.5),
            ),
          ),

          // 撮り直しボタン
          if (_session.hasCurrentImage)
            IconButton(
              onPressed: _retakeCurrentPicture,
              icon: const Icon(Icons.refresh, color: Colors.white),
              style: IconButton.styleFrom(
                backgroundColor: Colors.black.withValues(alpha: 0.5),
              ),
            )
          else
            const SizedBox(width: 48),

          // 撮影ボタン
          _buildShutterButton(l10n),

          // ズームスライダー（縦向き）
          if (_maxZoom > _minZoom)
            _buildZoomSlider()
          else
            const SizedBox(width: 48),

          const SizedBox(width: 48), // バランス調整用
        ],
      ),
    );
  }

  Widget _buildShutterButton(AppLocalizations l10n) {
    return GestureDetector(
      onTap: _isTakingPicture ? null : _takePicture,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(color: Colors.white, width: 4),
        ),
        child: _isTakingPicture
            ? const CircularProgressIndicator(
                color: Colors.blue,
                strokeWidth: 3,
              )
            : Icon(Icons.camera_alt, size: 40, color: Colors.black),
      ),
    );
  }

  Widget _buildZoomSlider() {
    return Container(
      height: 150,
      child: RotatedBox(
        quarterTurns: -1,
        child: Slider(
          value: _currentZoom,
          min: _minZoom,
          max: _maxZoom,
          divisions: 20,
          onChanged: _onZoomChanged,
          activeColor: Colors.white,
          inactiveColor: Colors.white.withValues(alpha: 0.3),
        ),
      ),
    );
  }

  // バナー広告のビルドメソッドは削除

  IconData _getFlashIcon() {
    switch (_currentFlashMode) {
      case FlashMode.auto:
        return Icons.flash_auto;
      case FlashMode.always:
        return Icons.flash_on;
      case FlashMode.off:
        return Icons.flash_off;
      case FlashMode.torch:
        return Icons.flashlight_on;
    }
  }
}
