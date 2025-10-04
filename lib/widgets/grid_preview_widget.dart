import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gridshot_camera/models/grid_style.dart';
import 'package:gridshot_camera/models/shooting_mode.dart';
import 'package:gridshot_camera/services/settings_service.dart';

class GridPreviewWidget extends StatefulWidget {
  final GridStyle gridStyle;
  final double size;
  final int? highlightIndex;
  final bool showBorders;
  final Color? borderColor;
  final double? borderWidth;

  const GridPreviewWidget({
    super.key,
    required this.gridStyle,
    required this.size,
    this.highlightIndex,
    this.showBorders = true,
    this.borderColor,
    this.borderWidth,
  });

  @override
  State<GridPreviewWidget> createState() => _GridPreviewWidgetState();
}

class _GridPreviewWidgetState extends State<GridPreviewWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initializePulseAnimation();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _initializePulseAnimation() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (widget.highlightIndex != null) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(GridPreviewWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.highlightIndex != widget.highlightIndex) {
      if (widget.highlightIndex != null) {
        _pulseController.repeat(reverse: true);
      } else {
        _pulseController.stop();
        _pulseController.reset();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = SettingsService.instance.currentSettings;

    final borderColor = widget.borderColor ??
        (widget.showBorders ? settings.borderColor : Colors.transparent);
    final borderWidth =
        widget.borderWidth ?? (widget.showBorders ? settings.borderWidth : 0.0);

    // 修正：アスペクト比を考慮したサイズ計算
    final aspectRatio = widget.gridStyle.columns / widget.gridStyle.rows;
    double containerWidth = widget.size;
    double containerHeight = widget.size;

    if (aspectRatio > 1.0) {
      // 横長の場合（3×2など）
      containerHeight = widget.size / aspectRatio;
    } else if (aspectRatio < 1.0) {
      // 縦長の場合（2×3など）
      containerWidth = widget.size * aspectRatio;
    }

    return Container(
      width: containerWidth,
      height: containerHeight,
      decoration: BoxDecoration(
        border: Border.all(color: theme.dividerColor, width: 1),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: widget.gridStyle.columns,
                childAspectRatio: 1.0,
                crossAxisSpacing: borderWidth,
                mainAxisSpacing: borderWidth,
              ),
              itemCount: widget.gridStyle.totalCells,
              itemBuilder: (context, index) {
                final isHighlighted = widget.highlightIndex == index;
                final position = widget.gridStyle.getPosition(index);

                Widget cell = Container(
                  decoration: BoxDecoration(
                    color: isHighlighted
                        ? theme.primaryColor.withOpacity(0.3)
                        : theme.cardColor,
                    border: borderWidth > 0
                        ? Border.all(color: borderColor, width: borderWidth)
                        : null,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _getCellIcon(index),
                          size: _getIconSize(),
                          color: isHighlighted
                              ? theme.primaryColor
                              : theme.iconTheme.color?.withOpacity(0.6),
                        ),
                        if (widget.size > 80) ...[
                          const SizedBox(height: 2),
                          Text(
                            position.displayString,
                            style: TextStyle(
                              fontSize: _getTextSize(),
                              fontWeight: FontWeight.bold,
                              color: isHighlighted
                                  ? theme.primaryColor
                                  : theme.textTheme.bodySmall?.color,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );

                // ハイライト表示がある場合はアニメーション付きにする
                if (isHighlighted) {
                  cell = Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: theme.primaryColor.withOpacity(0.3),
                            blurRadius: 8 * _pulseAnimation.value,
                            spreadRadius: 2 * _pulseAnimation.value,
                          ),
                        ],
                      ),
                      child: cell,
                    ),
                  );
                }

                return cell;
              },
            );
          },
        ),
      ),
    );
  }

  double _getIconSize() {
    // 固定サイズに基づいてアイコンサイズを計算
    final cellSize = widget.size /
        (widget.gridStyle.columns > widget.gridStyle.rows
            ? widget.gridStyle.columns
            : widget.gridStyle.rows);
    final baseSize = cellSize / 3;
    return baseSize.clamp(12.0, 24.0);
  }

  double _getTextSize() {
    // 固定サイズに基づいてテキストサイズを計算
    final cellSize = widget.size /
        (widget.gridStyle.columns > widget.gridStyle.rows
            ? widget.gridStyle.columns
            : widget.gridStyle.rows);
    return (cellSize / 8).clamp(8.0, 12.0);
  }

  IconData _getCellIcon(int index) {
    // セルの位置に基づいてアイコンを決定
    switch (index % 6) {
      case 0:
        return Icons.photo_camera;
      case 1:
        return Icons.image;
      case 2:
        return Icons.crop_square;
      case 3:
        return Icons.grid_view;
      case 4:
        return Icons.photo;
      case 5:
        return Icons.camera_alt;
      default:
        return Icons.crop_square;
    }
  }
}

// グリッドオーバーレイ（カメラ画面で使用）- サムネイル表示対応版
class GridOverlay extends StatelessWidget {
  final GridStyle gridStyle;
  final Size size;
  final int? currentIndex;
  final Color borderColor;
  final double borderWidth;
  final bool showCellNumbers;
  final ShootingMode? shootingMode;
  final List<CapturedImage?> capturedImages;
  final double thumbnailOpacity;

  const GridOverlay({
    super.key,
    required this.gridStyle,
    required this.size,
    this.currentIndex,
    this.borderColor = Colors.white,
    this.borderWidth = 2.0,
    this.showCellNumbers = true,
    this.shootingMode,
    this.capturedImages = const [],
    this.thumbnailOpacity = 0.4,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size.width,
      height: size.height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // サムネイル表示
          ..._buildThumbnails(),
          // グリッド線レイヤー
          CustomPaint(
            size: size,
            painter: GridPainter(
              gridStyle: gridStyle,
              currentIndex: currentIndex,
              borderColor: borderColor,
              borderWidth: borderWidth,
              showCellNumbers: showCellNumbers,
              textColor: Colors.white,
              shootingMode: shootingMode,
              screenSize: size,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildThumbnails() {
    final cellWidth = size.width / gridStyle.columns;
    final cellHeight = size.height / gridStyle.rows;

    return List.generate(gridStyle.totalCells, (index) {
      if (index < capturedImages.length && capturedImages[index] != null) {
        final position = gridStyle.getPosition(index);
        final capturedImage = capturedImages[index]!;

        return Positioned(
          left: position.col * cellWidth,
          top: position.row * cellHeight,
          width: cellWidth,
          height: cellHeight,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ★ 修正：Opacityで画像全体を半透明に
              Opacity(
                opacity: thumbnailOpacity,
                child: Container(
                  color: Colors.black.withOpacity(0.3), // 薄い背景
                  child: _buildThumbnail(capturedImage.filePath, position),
                ),
              ),
              // 撮影済みマーク
              Align(
                alignment: Alignment.topRight,
                child: Opacity(
                  opacity: thumbnailOpacity, // マークも同じ透過度
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }
      return const SizedBox.shrink();
    });
  }

  /// ★ 完全修正：グリッド合成の正しい部分表示（アスペクト比対応版）
  Widget _buildThumbnail(String imagePath, GridPosition position) {
    if (shootingMode == ShootingMode.impossible) {
      // ★ グリッド合成モード：OverflowBoxを使った確実な部分表示
      final totalWidth = size.width;
      final totalHeight = size.height;
      final cellWidth = totalWidth / gridStyle.columns;
      final cellHeight = totalHeight / gridStyle.rows;

      debugPrint(
        '★ グリッド合成 - セル${position.displayString}(${position.col},${position.row})',
      );
      debugPrint('  totalSize: ${totalWidth}x${totalHeight}');
      debugPrint('  cellSize: ${cellWidth}x${cellHeight}');

      return ClipRect(
        child: OverflowBox(
          minWidth: totalWidth,
          maxWidth: totalWidth,
          minHeight: totalHeight,
          maxHeight: totalHeight,
          alignment: Alignment(
            // -1.0(左) から 1.0(右)
            gridStyle.columns == 1
                ? 0.0
                : -1.0 + (2.0 * position.col / (gridStyle.columns - 1)),
            // -1.0(上) から 1.0(下)
            gridStyle.rows == 1
                ? 0.0
                : -1.0 + (2.0 * position.row / (gridStyle.rows - 1)),
          ),
          child: Image.file(
            File(imagePath),
            width: totalWidth,
            height: totalHeight,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              debugPrint('★ 画像読み込みエラー: $error');
              return _buildErrorWidget();
            },
          ),
        ),
      );
    } else {
      // ★ ならべ撮りモード：画像全体を表示
      return ClipRect(
        child: Image.file(
          File(imagePath),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            debugPrint('★ 画像読み込みエラー: $error');
            return _buildErrorWidget();
          },
        ),
      );
    }
  }

  Widget _buildErrorWidget() {
    return Container(
      color: Colors.red.withOpacity(0.3),
      child: const Center(
        child: Icon(
          Icons.broken_image,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  final GridStyle gridStyle;
  final int? currentIndex;
  final Color borderColor;
  final double borderWidth;
  final bool showCellNumbers;
  final Color textColor;
  final ShootingMode? shootingMode;
  final Size screenSize; // 追加：画面サイズ

  GridPainter({
    required this.gridStyle,
    this.currentIndex,
    required this.borderColor,
    required this.borderWidth,
    required this.showCellNumbers,
    required this.textColor,
    this.shootingMode,
    required this.screenSize, // 追加
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (borderWidth <= 0) return;

    final paint = Paint()
      ..color = borderColor
      ..strokeWidth = borderWidth
      ..style = PaintingStyle.stroke;

    final highlightPaint = Paint()
      ..color = borderColor.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    // 横画面・縦画面に関わらず適切なセルサイズを計算
    final cellWidth = size.width / gridStyle.columns;
    final cellHeight = size.height / gridStyle.rows;

    // モードに応じた描画処理
    if (shootingMode == ShootingMode.impossible) {
      _drawImpossibleModeGrid(
        canvas,
        size,
        paint,
        highlightPaint,
        cellWidth,
        cellHeight,
      );
    } else {
      _drawCatalogModeGrid(
        canvas,
        size,
        paint,
        highlightPaint,
        cellWidth,
        cellHeight,
      );
    }
  }

  void _drawCatalogModeGrid(
    Canvas canvas,
    Size size,
    Paint paint,
    Paint highlightPaint,
    double cellWidth,
    double cellHeight,
  ) {
    // カタログモード：通常のグリッド表示

    // グリッド線を描画
    for (int i = 1; i < gridStyle.columns; i++) {
      final x = i * cellWidth;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (int i = 1; i < gridStyle.rows; i++) {
      final y = i * cellHeight;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // 外枠を描画
    final outerRect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(outerRect, paint);

    // 現在のセルをハイライト
    if (currentIndex != null) {
      final position = gridStyle.getPosition(currentIndex!);
      final rect = Rect.fromLTWH(
        position.col * cellWidth,
        position.row * cellHeight,
        cellWidth,
        cellHeight,
      );
      canvas.drawRect(rect, highlightPaint);

      // 現在のセルの境界線を太くする
      final thickPaint = Paint()
        ..color = borderColor
        ..strokeWidth = borderWidth * 2
        ..style = PaintingStyle.stroke;
      canvas.drawRect(rect, thickPaint);
    }

    // セル番号を描画
    if (showCellNumbers) {
      _drawCellNumbers(canvas, cellWidth, cellHeight, 'カタログ');
    }
  }

  void _drawImpossibleModeGrid(
    Canvas canvas,
    Size size,
    Paint paint,
    Paint highlightPaint,
    double cellWidth,
    double cellHeight,
  ) {
    // 不可能合成モード：現在撮影中のセルのみを強調表示

    // 全体のグリッド線を薄く描画
    final dimPaint = Paint()
      ..color = borderColor.withOpacity(0.3)
      ..strokeWidth = borderWidth * 0.5
      ..style = PaintingStyle.stroke;

    // グリッド線を描画（薄く）
    for (int i = 1; i < gridStyle.columns; i++) {
      final x = i * cellWidth;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), dimPaint);
    }

    for (int i = 1; i < gridStyle.rows; i++) {
      final y = i * cellHeight;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), dimPaint);
    }

    // 外枠を描画（薄く）
    final outerRect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(outerRect, dimPaint);

    // 現在のセルのみを強調表示
    if (currentIndex != null) {
      final position = gridStyle.getPosition(currentIndex!);
      final rect = Rect.fromLTWH(
        position.col * cellWidth,
        position.row * cellHeight,
        cellWidth,
        cellHeight,
      );

      // ハイライト背景
      canvas.drawRect(rect, highlightPaint);

      // 現在のセルの境界線を太く明るく描画
      final currentCellPaint = Paint()
        ..color = borderColor
        ..strokeWidth = borderWidth * 3
        ..style = PaintingStyle.stroke;
      canvas.drawRect(rect, currentCellPaint);
    }

    // セル番号を描画（現在のセルのみ強調）
    if (showCellNumbers) {
      _drawCellNumbers(canvas, cellWidth, cellHeight, '不可能合成');
    }
  }

  void _drawCellNumbers(
    Canvas canvas,
    double cellWidth,
    double cellHeight,
    String mode,
  ) {
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    // 画面サイズに応じて適切なフォントサイズを計算
    final fontSize = _calculateFontSize(cellWidth, cellHeight);

    for (int i = 0; i < gridStyle.totalCells; i++) {
      final position = gridStyle.getPosition(i);
      final centerX = (position.col + 0.5) * cellWidth;
      final centerY = (position.row + 0.5) * cellHeight;
      final isCurrentCell = currentIndex == i;

      // 不可能合成モードでは現在のセル以外は薄く表示
      final opacity = (mode == '不可能合成' && !isCurrentCell) ? 0.4 : 1.0;

      textPainter.text = TextSpan(
        text: position.displayString,
        style: TextStyle(
          color: textColor.withOpacity(opacity),
          fontSize: fontSize,
          fontWeight: isCurrentCell ? FontWeight.bold : FontWeight.w600,
          shadows: [
            Shadow(
              offset: const Offset(1, 1),
              blurRadius: 3,
              color: Colors.black.withOpacity(0.8),
            ),
            Shadow(
              offset: const Offset(-1, -1),
              blurRadius: 3,
              color: Colors.black.withOpacity(0.8),
            ),
          ],
        ),
      );

      textPainter.layout();

      // 現在のセルの場合は背景を追加
      if (isCurrentCell) {
        final textRect = Rect.fromCenter(
          center: Offset(centerX, centerY),
          width: textPainter.width + 12,
          height: textPainter.height + 8,
        );
        final bgPaint = Paint()
          ..color = borderColor.withOpacity(0.4)
          ..style = PaintingStyle.fill;
        canvas.drawRRect(
          RRect.fromRectAndRadius(textRect, const Radius.circular(6)),
          bgPaint,
        );
      }

      textPainter.paint(
        canvas,
        Offset(
          centerX - textPainter.width / 2,
          centerY - textPainter.height / 2,
        ),
      );
    }
  }

  // 画面サイズに応じたフォントサイズを計算
  double _calculateFontSize(double cellWidth, double cellHeight) {
    final baseSize = (cellWidth + cellHeight) / 12;

    // 横画面の場合、セルが小さくなる可能性があるので調整
    if (screenSize.width > screenSize.height) {
      return baseSize.clamp(10.0, 18.0);
    } else {
      return baseSize.clamp(12.0, 20.0);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is! GridPainter ||
        oldDelegate.currentIndex != currentIndex ||
        oldDelegate.gridStyle != gridStyle ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.borderWidth != borderWidth ||
        oldDelegate.shootingMode != shootingMode ||
        oldDelegate.screenSize != screenSize; // 追加
  }
}

// グリッドスタイル表示用のコンパクトウィジェット
class GridStyleIndicator extends StatelessWidget {
  final GridStyle gridStyle;
  final double size;
  final Color? color;
  final bool isSelected;

  const GridStyleIndicator({
    super.key,
    required this.gridStyle,
    this.size = 32,
    this.color,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final indicatorColor = color ??
        (isSelected ? theme.colorScheme.primary : theme.iconTheme.color);

    return Container(
      width: size,
      height: size,
      child: CustomPaint(
        painter: GridStylePainter(
          gridStyle: gridStyle,
          color: indicatorColor ?? Colors.grey,
        ),
      ),
    );
  }
}

class GridStylePainter extends CustomPainter {
  final GridStyle gridStyle;
  final Color color;

  GridStylePainter({required this.gridStyle, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final cellWidth = size.width / gridStyle.columns;
    final cellHeight = size.height / gridStyle.rows;

    // 垂直線を描画
    for (int i = 0; i <= gridStyle.columns; i++) {
      final x = i * cellWidth;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // 水平線を描画
    for (int i = 0; i <= gridStyle.rows; i++) {
      final y = i * cellHeight;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is! GridStylePainter ||
        oldDelegate.gridStyle != gridStyle ||
        oldDelegate.color != color;
  }
}
