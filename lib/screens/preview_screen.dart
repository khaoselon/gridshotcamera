import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../l10n/app_localizations.dart';
import 'package:gridshot_camera/models/shooting_mode.dart';
import 'package:gridshot_camera/models/grid_style.dart';
import 'package:gridshot_camera/services/image_composer_service.dart';
import 'package:gridshot_camera/services/ad_service.dart';
import 'package:gridshot_camera/services/settings_service.dart';
import 'package:gridshot_camera/widgets/loading_widget.dart';
import 'package:gridshot_camera/screens/camera_screen.dart';

class PreviewScreen extends StatefulWidget {
  final ShootingSession session;

  const PreviewScreen({super.key, required this.session});

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen>
    with TickerProviderStateMixin {
  String? _compositeImagePath;
  String? _errorMessage;
  bool _isCompositing = false;
  bool _isSaving = false;
  bool _isSharing = false;

  // アニメーション関連
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  // 広告関連
  BannerAd? _bannerAd;
  bool _isBannerAdReady = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startCompositing();
    _loadBannerAd();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _bannerAd?.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _fadeController.forward();
  }

  Future<void> _startCompositing() async {
    setState(() {
      _isCompositing = true;
      _errorMessage = null;
    });

    try {
      final result = await ImageComposerService.instance.composeGridImage(
        session: widget.session,
      );

      if (result.success && result.filePath != null && mounted) {
        setState(() {
          _compositeImagePath = result.filePath;
          _isCompositing = false;
        });

        // 合成完了のアニメーション
        _scaleController.forward();

        // 一時ファイルのクリーンアップを少し遅らせる
        Future.delayed(const Duration(seconds: 2), () {
          ImageComposerService.instance.cleanupTemporaryFiles(widget.session);
        });
      } else if (mounted) {
        setState(() {
          _errorMessage = result.message;
          _isCompositing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = '画像の合成中にエラーが発生しました: $e';
          _isCompositing = false;
        });
      }
    }
  }

  void _loadBannerAd() {
    if (!SettingsService.instance.shouldShowAds) return;

    AdService.instance.createBannerAd(
      onAdLoaded: (ad) {
        if (mounted) {
          setState(() {
            _bannerAd = ad as BannerAd;
            _isBannerAdReady = true;
          });
        }
      },
      onAdFailedToLoad: (ad, error) {
        if (mounted) {
          setState(() {
            _isBannerAdReady = false;
          });
        }
      },
    );
  }

  Future<void> _saveImage() async {
    if (_compositeImagePath == null || _isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final l10n = AppLocalizations.of(context)!;

      // 保存処理は既にImageComposerServiceで実行済み（ギャラリー保存も含む）
      // ここでは成功メッセージの表示のみ
      _showSuccessMessage(l10n.saveSuccess);

      // ハプティックフィードバック
      HapticFeedback.lightImpact();
    } catch (e) {
      _showErrorMessage('画像の保存に失敗しました: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _shareImage() async {
    if (_compositeImagePath == null || _isSharing) return;

    setState(() {
      _isSharing = true;
    });

    try {
      final l10n = AppLocalizations.of(context)!;

      await Share.shareXFiles(
        [XFile(_compositeImagePath!)],
        text: '${l10n.appTitle}で作成したグリッド写真',
        subject: l10n.appTitle,
      );

      _showSuccessMessage(l10n.shareSuccess);
    } catch (e) {
      _showErrorMessage('画像の共有に失敗しました: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSharing = false;
        });
      }
    }
  }

  Future<void> _retakePhoto() async {
    // 確認ダイアログ
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('確認'),
        content: Text('撮影をやり直しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('撮り直し'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      // カメラ画面に戻る
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => CameraScreen(
            mode: widget.session.mode,
            gridStyle: widget.session.gridStyle,
          ),
        ),
      );
    }
  }

  void _goHome() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.previewTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _goHome,
        ),
        actions: [
          if (!_isCompositing && _compositeImagePath != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _retakePhoto,
              tooltip: l10n.retake,
            ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            Expanded(child: _buildContent(context, l10n, theme)),
            if (_isBannerAdReady &&
                _bannerAd != null &&
                SettingsService.instance.shouldShowAds)
              _buildBannerAd(),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    if (_isCompositing) {
      return _buildCompositingView(l10n);
    }

    if (_errorMessage != null) {
      return _buildErrorView(l10n);
    }

    if (_compositeImagePath != null) {
      return _buildPreviewView(l10n, theme);
    }

    return Container(); // 不明な状態
  }

  Widget _buildCompositingView(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // アプリロゴまたはアイコン（オプション）
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withOpacity(0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.grid_view_rounded,
              size: 40,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 40),

          // ローディングインジケーター
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              strokeWidth: 4,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
          ),

          const SizedBox(height: 32),

          // メインメッセージ
          Text(
            l10n.compositing,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          // サブメッセージ
          Text(
            '${widget.session.gridStyle.totalCells}枚の画像を合成中...',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          // モード表示
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Theme.of(context).primaryColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              _getModeDisplayName(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),

          const SizedBox(height: 40),

          // 進行状況テキスト
          Text(
            '少々お待ちください...',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
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
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: _startCompositing, child: Text('再試行')),
            const SizedBox(height: 12),
            TextButton(onPressed: _retakePhoto, child: Text('撮り直し')),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewView(AppLocalizations l10n, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 合成画像の表示（修正版：完全な画像を表示）
          ScaleTransition(
            scale: _scaleAnimation,
            child: Card(
              elevation: 8,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _buildImageDisplay(),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // 撮影情報
          _buildImageInfo(l10n, theme),

          const SizedBox(height: 32),

          // アクションボタン
          _buildActionButtons(l10n),
        ],
      ),
    );
  }

  /// 画像表示ウィジェット（修正版：アスペクト比を適切に処理）
  Widget _buildImageDisplay() {
    return FutureBuilder<Size?>(
      future: _getImageSize(_compositeImagePath!),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(
            height: 300,
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        final imageSize = snapshot.data!;

        // 画面幅に基づいて適切な表示サイズを計算
        final screenWidth = MediaQuery.of(context).size.width - 32; // パディング考慮
        final aspectRatio = imageSize.width / imageSize.height;

        // 最大高さを画面の70%に制限
        final maxHeight = MediaQuery.of(context).size.height * 0.7;
        final calculatedHeight = screenWidth / aspectRatio;
        final displayHeight = calculatedHeight > maxHeight
            ? maxHeight
            : calculatedHeight;
        final displayWidth = displayHeight * aspectRatio;

        return Container(
          width: displayWidth,
          height: displayHeight,
          child: Image.file(
            File(_compositeImagePath!),
            fit: BoxFit.contain, // 画像全体を表示（contain で完全に表示）
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[300],
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.broken_image, size: 48, color: Colors.grey[600]),
                    const SizedBox(height: 8),
                    Text(
                      '画像の読み込みに失敗しました',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  /// 画像のサイズを取得
  Future<Size?> _getImageSize(String imagePath) async {
    try {
      final file = File(imagePath);
      if (!await file.exists()) return null;

      final metadata = await ImageComposerService.instance.getImageMetadata(
        imagePath,
      );
      if (metadata == null) return null;

      return Size(metadata.width.toDouble(), metadata.height.toDouble());
    } catch (e) {
      debugPrint('画像サイズ取得エラー: $e');
      return null;
    }
  }

  Widget _buildImageInfo(AppLocalizations l10n, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '撮影情報',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('モード', _getModeDisplayName()),
            _buildInfoRow('グリッドスタイル', widget.session.gridStyle.displayName),
            _buildInfoRow('撮影枚数', '${widget.session.completedCount}枚'),
            _buildInfoRow('撮影日時', _formatDateTime(DateTime.now())),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildActionButtons(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 保存ボタン
        ElevatedButton.icon(
          onPressed: _isSaving ? null : _saveImage,
          icon: _isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Icon(Icons.save_alt),
          label: Text(
            _isSaving ? '保存中...' : l10n.save,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),

        const SizedBox(height: 12),

        // 共有ボタン
        OutlinedButton.icon(
          onPressed: _isSharing ? null : _shareImage,
          icon: _isSharing
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.share),
          label: Text(
            _isSharing ? '共有中...' : l10n.share,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),

        const SizedBox(height: 12),

        // 撮り直しボタン
        TextButton.icon(
          onPressed: _retakePhoto,
          icon: const Icon(Icons.camera_alt),
          label: Text('新しく撮影する', style: const TextStyle(fontSize: 16)),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildBannerAd() {
    return Container(
      alignment: Alignment.center,
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }

  String _getModeDisplayName() {
    switch (widget.session.mode) {
      case ShootingMode.catalog:
        return 'カタログモード';
      case ShootingMode.impossible:
        return '不可能合成モード';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
