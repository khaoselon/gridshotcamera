import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

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

/// ★ 追加：モック撮影フラグ（dart-define で切替）
const kUseMockCamera =
    bool.fromEnvironment('USE_MOCK_CAMERA', defaultValue: false);

/// ★ 追加：モック連番リスト（必要なら増やす）
const List<String> kMockSequence = [
  'assets/mock/image1.png',
  'assets/mock/image2.png',
  'assets/mock/image3.png',
  'assets/mock/image4.png',
];

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
  Timer? _debounceTimer;

  // 画面遷移状態管理
  bool _isPreviewVisible = false;
  bool _isDisposing = false;
  bool _isTransitioning = false;

  // アニメーション
  late AnimationController _flashAnimationController;
  late AnimationController _progressAnimationController;
  late Animation<double> _flashAnimation;
  late Animation<double> _progressAnimation;

  // UI状態
  double _currentZoom = 1.0;
  double _minZoom = 1.0;
  double _maxZoom = 1.0;
  FlashMode _currentFlashMode = FlashMode.auto;

  // サムネイル透過度
  double _thumbnailOpacity = 0.4;
  bool _showOpacitySlider = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _initializeSession();
    _initializeAnimations();

    AdService.instance.setHeavyProcessingActive(true);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 300));
      if (_isScreenDisposed || _isDisposing) return;

      if (kUseMockCamera) {
        // ★ モック時：カメラ初期化なしで即表示
        setState(() {
          _isInitializing = false;
          _errorMessage = null;
        });
        AdService.instance.setHeavyProcessingActive(false);
        return;
      }

      // 実カメラ
      _initializeCamera();
    });
  }

  @override
  void dispose() {
    debugPrint('CameraScreen: dispose開始（BufferQueue対策版）');
    _isScreenDisposed = true;
    _isDisposing = true;

    _debounceTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);

    _disposeResourcesInOrder();

    super.dispose();
    debugPrint('CameraScreen: dispose完了');
  }

  Future<void> _disposeResourcesInOrder() async {
    debugPrint('CameraScreen: リソース解放開始（BufferQueue対策版）');

    try {
      _flashAnimationController.dispose();
      _progressAnimationController.dispose();

      if (_isPreviewVisible) {
        _isPreviewVisible = false;
        await Future.delayed(const Duration(milliseconds: 100));
      }

      if (!kUseMockCamera) {
        _cameraService.removeListener(_onCameraServiceChanged);
        await _cameraService.dispose();
        await Future.delayed(const Duration(milliseconds: 200));
      }

      AdService.instance.setHeavyProcessingActive(false);
    } catch (e) {
      debugPrint('リソース解放中のエラー: $e');
    }

    debugPrint('CameraScreen: リソース解放完了（BufferQueue対策版）');
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
    _flashAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_flashAnimationController);
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _progressAnimationController, curve: Curves.easeInOut),
    );
  }

  Future<void> _initializeCamera() async {
    if (_isScreenDisposed || _isDisposing) return;

    setState(() {
      _isInitializing = true;
      _errorMessage = null;
    });

    try {
      debugPrint('カメラサービスを初期化します（BufferQueue対策版）');

      _cameraService = CameraService();
      _cameraService.addListener(_onCameraServiceChanged);

      final success = await _cameraService.initialize();

      if (success && mounted && !_isScreenDisposed && !_isDisposing) {
        _isPreviewVisible = true;
        _cameraService.setPreviewBound(true);

        try {
          _minZoom = 1.0;
          _maxZoom = await _cameraService.getMaxZoomLevel();
          _currentZoom = await _cameraService.getCurrentZoomLevel();
        } catch (_) {
          _minZoom = 1.0;
          _maxZoom = 1.0;
          _currentZoom = 1.0;
        }

        await _cameraService.applyShootingSettings(_session);

        if (!_isScreenDisposed && !_isDisposing) {
          setState(() => _isInitializing = false);
          _updateProgressAnimation();
          AdService.instance.setHeavyProcessingActive(false);
          debugPrint('カメラの初期化が完了しました（BufferQueue対策版）');
        }
      } else if (mounted && !_isScreenDisposed && !_isDisposing) {
        setState(() {
          _isInitializing = false;
          _errorMessage = _cameraService.lastError ?? 'カメラの初期化に失敗しました';
        });
      }
    } catch (e) {
      debugPrint('カメラ初期化エラー: $e');
      if (mounted && !_isScreenDisposed && !_isDisposing) {
        setState(() {
          _isInitializing = false;
          _errorMessage = 'カメラの初期化中にエラーが発生しました: $e';
        });
      }
    }
  }

  void _onCameraServiceChanged() {
    if (mounted && !_isScreenDisposed && !_isDisposing) {
      setState(() {
        _errorMessage =
            _cameraService.hasError ? _cameraService.lastError : null;
        _isTakingPicture = _cameraService.isTakingPicture;
      });
    }
  }

  void _updateProgressAnimation() {
    if (_isScreenDisposed || _isDisposing) return;
    _progressAnimationController.animateTo(_session.progress);
  }

  Future<void> _takePicture() async {
    if (_isTakingPicture ||
        _isScreenDisposed ||
        _isDisposing ||
        _isTransitioning) return;
    // 実カメラのときだけ初期化チェック
    if (!kUseMockCamera && !_cameraService.isInitialized) return;

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _executeTakePicture();
    });
  }

  Future<void> _executeTakePicture() async {
    if (_isTakingPicture ||
        _isScreenDisposed ||
        _isDisposing ||
        _isTransitioning) return;
    if (!kUseMockCamera && !_cameraService.isInitialized) return;

    AdService.instance.setHeavyProcessingActive(true);
    setState(() => _isTakingPicture = true);

    try {
      _flashAnimationController.forward().then((_) {
        if (!_isScreenDisposed && !_isDisposing)
          _flashAnimationController.reverse();
      });

      final currentPosition = _session.currentPosition;

      String? filePath;
      if (kUseMockCamera) {
        // ★ モック：現在セルに応じたアセットを一時ファイルに保存
        final asset = _currentMockAsset();
        filePath = await _saveAssetToTempFile(
          assetPath: asset,
          filenamePrefix: 'mock_${currentPosition.displayString}_',
        );
      } else {
        // 実カメラ
        filePath = await _cameraService.takePicture(position: currentPosition);
      }

      if (filePath != null && mounted && !_isScreenDisposed && !_isDisposing) {
        final capturedImage = CapturedImage(
          filePath: filePath,
          timestamp: DateTime.now(),
          position: currentPosition,
        );

        _session.captureImage(capturedImage);
        _updateProgressAnimation();
        HapticFeedback.lightImpact();

        if (!_session.isCompleted) {
          _session.moveToNext(); // 次セルへ → プレビューも image1→image2 と切替わる
        }

        if (_session.isCompleted) {
          await _onShootingCompleted();
        } else {
          AdService.instance.setHeavyProcessingActive(false);
        }
      } else if (mounted && !_isScreenDisposed && !_isDisposing) {
        _showError('撮影に失敗しました');
      }
    } catch (e) {
      if (mounted && !_isScreenDisposed && !_isDisposing) {
        _showError('撮影中にエラーが発生しました: $e');
      }
    } finally {
      if (mounted && !_isScreenDisposed && !_isDisposing) {
        setState(() => _isTakingPicture = false);
        if (!_session.isCompleted) {
          AdService.instance.setHeavyProcessingActive(false);
        }
      }
    }
  }

  Future<void> _onShootingCompleted() async {
    if (_isScreenDisposed || _isDisposing || _isTransitioning) return;
    _isTransitioning = true;

    try {
      debugPrint('★ 撮影完了 - 安全な画面遷移を開始');
      AdService.instance.setHeavyProcessingActive(true);

      if (!kUseMockCamera && _isPreviewVisible) {
        _isPreviewVisible = false;
        _cameraService.setPreviewBound(false);
        await Future.delayed(const Duration(milliseconds: 150));
      }
      await Future.delayed(const Duration(milliseconds: 100));

      if (!mounted || _isScreenDisposed || _isDisposing) return;

      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(
        builder: (context) => PreviewScreen(session: _session),
      ))
          .then((_) {
        Future.delayed(const Duration(milliseconds: 500), () {
          AdService.instance.showInterstitialAd();
        });
      });
    } catch (e) {
      debugPrint('★ 安全な画面遷移エラー: $e');
      if (mounted && !_isScreenDisposed && !_isDisposing) {
        try {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
                builder: (context) => PreviewScreen(session: _session)),
          );
        } catch (_) {}
      }
    }
  }

  void _retakeCurrentPicture() {
    if (_session.hasCurrentImage &&
        !_isScreenDisposed &&
        !_isDisposing &&
        !_isTakingPicture &&
        !_isTransitioning) {
      setState(() {
        _session.capturedImages[_session.currentIndex] = null;
        _updateProgressAnimation();
      });
    }
  }

  Future<void> _toggleFlashMode() async {
    if (kUseMockCamera) return; // モック時は無効
    if (_isScreenDisposed ||
        _isDisposing ||
        _isTakingPicture ||
        _isTransitioning) return;

    await _cameraService.toggleFlashMode();
    if (mounted &&
        !_isScreenDisposed &&
        !_isDisposing &&
        _cameraService.controller != null) {
      setState(
          () => _currentFlashMode = _cameraService.controller!.value.flashMode);
    }
  }

  Future<void> _switchCamera() async {
    if (kUseMockCamera) return; // モック時は無効
    if (_isScreenDisposed ||
        _isDisposing ||
        _isTakingPicture ||
        _isTransitioning) return;

    setState(() => _isInitializing = true);

    if (_isPreviewVisible) {
      _isPreviewVisible = false;
      _cameraService.setPreviewBound(false);
      await Future.delayed(const Duration(milliseconds: 150));
    }

    await _cameraService.switchCamera();

    if (!_isScreenDisposed && !_isDisposing) {
      _isPreviewVisible = true;
      _cameraService.setPreviewBound(true);
      setState(() => _isInitializing = false);
    }
  }

  void _onZoomChanged(double zoom) {
    if (kUseMockCamera) return; // モック時は無効
    if (_isScreenDisposed ||
        _isDisposing ||
        _isTakingPicture ||
        _isTransitioning) return;

    final clampedZoom = zoom.clamp(_minZoom, _maxZoom);
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 100), () {
      _cameraService.setZoomLevel(clampedZoom);
    });
    setState(() => _currentZoom = clampedZoom);
  }

  void _onTapToFocus(TapUpDetails details) {
    if (kUseMockCamera) return; // モック時は無効
    if (!_cameraService.isInitialized ||
        _isScreenDisposed ||
        _isDisposing ||
        _isTakingPicture ||
        _isTransitioning) {
      return;
    }

    final renderBox = context.findRenderObject() as RenderBox;
    final tapPosition = details.localPosition;
    final screenSize = renderBox.size;

    _cameraService.setFocusPoint(tapPosition, screenSize);
    _showFocusPoint(tapPosition);
  }

  void _showFocusPoint(Offset position) {
    HapticFeedback.selectionClick();
  }

  void _showError(String message) {
    if (_isScreenDisposed || _isDisposing) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
        ),
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_isScreenDisposed || _isDisposing) return;
    if (kUseMockCamera) return; // モック時は何もしない

    switch (state) {
      case AppLifecycleState.inactive:
        if (_isPreviewVisible) _cameraService.setPreviewBound(false);
        break;
      case AppLifecycleState.paused:
        break;
      case AppLifecycleState.resumed:
        if (!_cameraService.isInitialized &&
            !_cameraService.isInitializing &&
            !_isTakingPicture &&
            !_isDisposing &&
            !_isTransitioning) {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (!_isScreenDisposed && !_isDisposing) _initializeCamera();
          });
        } else if (_cameraService.isInitialized && !_isPreviewVisible) {
          _isPreviewVisible = true;
          _cameraService.setPreviewBound(true);
        }
        break;
      case AppLifecycleState.detached:
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
      body: OrientationBuilder(
        builder: (context, orientation) {
          return _buildBody(context, l10n, theme, orientation);
        },
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
    Orientation orientation,
  ) {
    if (_isInitializing) {
      return LoadingWidget(message: l10n.loading);
    }

    if (!kUseMockCamera && _errorMessage != null) {
      return _buildErrorView(l10n);
    }

    return Stack(
      children: [
        _buildCameraPreview(),
        AnimatedBuilder(
          animation: _flashAnimation,
          builder: (context, child) {
            return _flashAnimation.value > 0
                ? Container(
                    color: Colors.white
                        .withValues(alpha: _flashAnimation.value * 0.8))
                : const SizedBox.shrink();
          },
        ),
        _buildGridOverlay(),
        _buildOpacitySlider(),
        if (orientation == Orientation.portrait)
          _buildPortraitUIControls(l10n, theme)
        else
          _buildLandscapeUIControls(l10n, theme),
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
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              l10n.error,
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
                onPressed: _isTakingPicture ? null : _initializeCamera,
                child: Text(l10n.retry)),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel,
                  style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraPreview() {
    // ★ モック時：セル進行に合わせて image1.png → image2.png をプレビュー表示
    if (kUseMockCamera) {
      final asset = _currentMockAsset();
      return Positioned.fill(
        child: FittedBox(
          fit: BoxFit.cover,
          child: Image.asset(asset),
        ),
      );
    }

    if (!_cameraService.isInitialized ||
        _cameraService.controller == null ||
        _cameraService.isDisposed ||
        !_cameraService.controller!.value.isInitialized ||
        !_isPreviewVisible) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Text(
            AppLocalizations.of(context)!.preparingCamera,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      );
    }

    return GestureDetector(
      onTapUp: _onTapToFocus,
      onScaleUpdate: (details) {
        if (details.scale != 1.0 && !_isTakingPicture) {
          final zoom = (_currentZoom * details.scale).clamp(_minZoom, _maxZoom);
          _onZoomChanged(zoom);
        }
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final controller = _cameraService.controller!;
          final screenSize = Size(constraints.maxWidth, constraints.maxHeight);
          final cameraAspectRatio = controller.value.aspectRatio;
          final screenAspectRatio = screenSize.width / screenSize.height;

          double scaleX, scaleY;
          if (cameraAspectRatio > screenAspectRatio) {
            scaleY = screenSize.height;
            scaleX = screenSize.height * cameraAspectRatio;
          } else {
            scaleX = screenSize.width;
            scaleY = screenSize.width / cameraAspectRatio;
          }

          return Center(
            child: ClipRect(
              child: SizedBox(
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

    final effectiveBorderWidth =
        settings.showGridBorder ? settings.borderWidth : 1.0;

    final effectiveBorderColor = settings.showGridBorder
        ? settings.borderColor
        : Colors.white.withOpacity(0.4);

    return Positioned.fill(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return GridOverlay(
            key: ValueKey(
              'grid_${widget.mode.name}_${widget.gridStyle.name}_${_thumbnailOpacity.toStringAsFixed(2)}',
            ),
            gridStyle: widget.gridStyle,
            size: Size(constraints.maxWidth, constraints.maxHeight),
            currentIndex: _session.currentIndex,
            borderColor: effectiveBorderColor,
            borderWidth: effectiveBorderWidth,
            showCellNumbers: true,
            shootingMode: widget.mode,
            capturedImages: _session.capturedImages,
            thumbnailOpacity: _thumbnailOpacity,
          );
        },
      ),
    );
  }

  Widget _buildPortraitUIControls(AppLocalizations l10n, ThemeData theme) {
    return SafeArea(
      child: Column(
        children: [
          _buildTopControls(l10n),
          const Spacer(),
          _buildBottomControls(l10n, theme),
        ],
      ),
    );
  }

  Widget _buildLandscapeUIControls(AppLocalizations l10n, ThemeData theme) {
    return SafeArea(
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildControlButton(
                    icon: Icons.arrow_back,
                    onPressed: () => Navigator.of(context).pop()),
                _buildControlButton(
                    icon: _getFlashIcon(),
                    onPressed: _isTakingPicture ? null : _toggleFlashMode),
                _buildControlButton(
                    icon: Icons.flip_camera_ios,
                    onPressed: _isTakingPicture ? null : _switchCamera),
                if (_maxZoom > _minZoom) _buildVerticalZoomSlider(),
              ],
            ),
          ),
          const Spacer(),
          SizedBox(
            width: 160,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCompactShootingInfo(l10n),
                _buildShutterButton(l10n),
                if (_session.hasCurrentImage)
                  _buildControlButton(
                    icon: Icons.refresh,
                    onPressed: _isTakingPicture ? null : _retakeCurrentPicture,
                  )
                else
                  const SizedBox(height: 48),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback? onPressed,
    Color? backgroundColor,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white, size: 24),
        style: IconButton.styleFrom(
          backgroundColor:
              backgroundColor ?? Colors.black.withValues(alpha: 0.5),
          shape: const CircleBorder(),
          padding: const EdgeInsets.all(12),
        ),
      ),
    );
  }

  Widget _buildVerticalZoomSlider() {
    return SizedBox(
      height: 80,
      child: RotatedBox(
        quarterTurns: -1,
        child: Slider(
          value: _currentZoom,
          min: _minZoom,
          max: _maxZoom,
          divisions: 20,
          onChanged: _isTakingPicture ? null : _onZoomChanged,
          activeColor: Colors.white,
          inactiveColor: Colors.white.withValues(alpha: 0.3),
        ),
      ),
    );
  }

  Widget _buildCompactShootingInfo(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            l10n.currentPosition(_session.currentPosition.displayString),
            style: const TextStyle(
                color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          DetailedSegmentedProgressBar(
            gridStyle: widget.gridStyle,
            completedCount: _session.completedCount,
            currentIndex: _session.currentIndex,
            width: 100,
            height: 4,
            showLabels: false,
          ),
          const SizedBox(height: 4),
          Text(
            '${_session.completedCount}/${_session.gridStyle.totalCells}',
            style: const TextStyle(color: Colors.white70, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildTopControls(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            style: IconButton.styleFrom(
                backgroundColor: Colors.black.withValues(alpha: 0.5)),
          ),
          const Spacer(),
          _buildShootingInfo(l10n),
          const Spacer(),
          if (!_showOpacitySlider) ...[
            IconButton(
              onPressed: () => setState(() => _showOpacitySlider = true),
              icon: const Icon(Icons.opacity_outlined, color: Colors.white),
              style: IconButton.styleFrom(
                  backgroundColor: Colors.black.withValues(alpha: 0.5)),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _isTakingPicture ? null : _switchCamera,
              icon: const Icon(Icons.flip_camera_ios, color: Colors.white),
              style: IconButton.styleFrom(
                  backgroundColor: Colors.black.withValues(alpha: 0.5)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOpacitySlider() {
    if (!_showOpacitySlider) return const SizedBox.shrink();

    return Positioned(
      top: 80,
      right: 16,
      child: Container(
        width: 60,
        height: 220,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(30),
          border:
              Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
        ),
        child: Column(
          children: [
            GestureDetector(
              onTap: () => setState(() => _showOpacitySlider = false),
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.close, color: Colors.white, size: 20),
              ),
            ),
            const SizedBox(height: 4),
            const Icon(Icons.opacity, color: Colors.white, size: 20),
            const SizedBox(height: 8),
            Expanded(
              child: RotatedBox(
                quarterTurns: -1,
                child: SliderTheme(
                  data: const SliderThemeData(
                    trackHeight: 6,
                    thumbShape: RoundSliderThumbShape(enabledThumbRadius: 10),
                    overlayShape: RoundSliderOverlayShape(overlayRadius: 18),
                  ),
                  child: Slider(
                    value: _thumbnailOpacity,
                    min: 0.0,
                    max: 1.0,
                    divisions: 10,
                    activeColor: Colors.blue,
                    inactiveColor: Colors.white54,
                    onChanged: (v) => setState(() => _thumbnailOpacity = v),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${(_thumbnailOpacity * 100).round()}%',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShootingInfo(AppLocalizations l10n) {
    return Container(
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
                color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          DetailedSegmentedProgressBar(
            gridStyle: widget.gridStyle,
            completedCount: _session.completedCount,
            currentIndex: _session.currentIndex,
            width: 140,
            height: 6,
            showLabels: false,
          ),
          const SizedBox(height: 6),
          Text(
            '${_session.completedCount}/${_session.gridStyle.totalCells}',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
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
          IconButton(
            onPressed: _isTakingPicture ? null : _toggleFlashMode,
            icon: Icon(_getFlashIcon()),
            color: Colors.white,
            style: IconButton.styleFrom(
                backgroundColor: Colors.black.withValues(alpha: 0.5)),
          ),
          if (_session.hasCurrentImage)
            IconButton(
              onPressed: _isTakingPicture ? null : _retakeCurrentPicture,
              icon: const Icon(Icons.refresh, color: Colors.white),
              style: IconButton.styleFrom(
                  backgroundColor: Colors.black.withValues(alpha: 0.5)),
            )
          else
            const SizedBox(width: 48),
          _buildShutterButton(l10n),
          if (_maxZoom > _minZoom)
            _buildZoomSlider()
          else
            const SizedBox(width: 48),
          const SizedBox(width: 48),
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
          color: _isTakingPicture ? Colors.grey : Colors.white,
          border: Border.all(color: Colors.white, width: 4),
        ),
        child: _isTakingPicture
            ? const CircularProgressIndicator(
                color: Colors.blue, strokeWidth: 3)
            : Icon(Icons.camera_alt,
                size: 40, color: _isTakingPicture ? Colors.grey : Colors.black),
      ),
    );
  }

  Widget _buildZoomSlider() {
    return SizedBox(
      height: 150,
      child: RotatedBox(
        quarterTurns: -1,
        child: Slider(
          value: _currentZoom,
          min: _minZoom,
          max: _maxZoom,
          divisions: 20,
          onChanged: _isTakingPicture ? null : _onZoomChanged,
          activeColor: Colors.white,
          inactiveColor: Colors.white.withValues(alpha: 0.3),
        ),
      ),
    );
  }

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

  // ==== ★ ここからモック連番ヘルパー ====

  /// 現在セルに対応するモックアセットを返す（足りなければ最後を使い回し）
  String _currentMockAsset() {
    final i = _session.currentIndex;
    if (i < kMockSequence.length) return kMockSequence[i];
    return kMockSequence.last;
  }

  /// アセットを一時ファイルへ保存してパスを返す
  Future<String> _saveAssetToTempFile({
    required String assetPath,
    String filenamePrefix = 'mock_',
  }) async {
    final bytes = await rootBundle.load(assetPath);
    final data = bytes.buffer.asUint8List();

    final dir = await getTemporaryDirectory();
    final fileName =
        '${filenamePrefix}${DateTime.now().millisecondsSinceEpoch}${p.extension(assetPath).isNotEmpty ? p.extension(assetPath) : '.png'}';

    final file = File(p.join(dir.path, fileName));
    await file.writeAsBytes(data, flush: true);
    return file.path;
  }
}
