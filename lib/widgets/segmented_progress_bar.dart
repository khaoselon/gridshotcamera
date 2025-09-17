import 'package:flutter/material.dart';
import 'package:gridshot_camera/models/grid_style.dart';

/// グリッドスタイルに合わせてセグメント化されたプログレスバー
class SegmentedProgressBar extends StatefulWidget {
  final GridStyle gridStyle;
  final int completedCount;
  final int currentIndex;
  final double width;
  final double height;
  final Color backgroundColor;
  final Color completedColor;
  final Color currentColor;
  final Color incompleteColor;
  final double borderRadius;
  final double spacing;

  const SegmentedProgressBar({
    super.key,
    required this.gridStyle,
    required this.completedCount,
    required this.currentIndex,
    this.width = 120,
    this.height = 4,
    this.backgroundColor = const Color(0x4DFFFFFF),
    this.completedColor = Colors.blue,
    this.currentColor = Colors.white,
    this.incompleteColor = const Color(0x4DFFFFFF),
    this.borderRadius = 2,
    this.spacing = 2,
  });

  @override
  State<SegmentedProgressBar> createState() => _SegmentedProgressBarState();
}

class _SegmentedProgressBarState extends State<SegmentedProgressBar>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _animationController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(SegmentedProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.completedCount != widget.completedCount ||
        oldWidget.currentIndex != widget.currentIndex) {
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalCells = widget.gridStyle.totalCells;
    final segmentWidth =
        (widget.width - (widget.spacing * (totalCells - 1))) / totalCells;

    return Container(
      width: widget.width,
      height: widget.height,
      child: AnimatedBuilder(
        animation: Listenable.merge([_animation, _pulseAnimation]),
        builder: (context, child) {
          return Row(
            children: List.generate(totalCells, (index) {
              return _buildSegment(index, segmentWidth);
            }),
          );
        },
      ),
    );
  }

  Widget _buildSegment(int index, double segmentWidth) {
    Color segmentColor;
    double opacity = _animation.value;

    if (index < widget.completedCount) {
      // 完了済みセグメント
      segmentColor = widget.completedColor;
    } else if (index == widget.currentIndex) {
      // 現在撮影中のセグメント
      segmentColor = widget.currentColor;
      // 現在のセグメントは点滅効果
      opacity = _pulseAnimation.value;
    } else {
      // 未完了セグメント
      segmentColor = widget.incompleteColor;
    }

    return Container(
      width: segmentWidth,
      height: widget.height,
      margin: EdgeInsets.only(
        right: index < widget.gridStyle.totalCells - 1 ? widget.spacing : 0,
      ),
      decoration: BoxDecoration(
        color: segmentColor.withOpacity(opacity),
        borderRadius: BorderRadius.circular(widget.borderRadius),
        boxShadow: index == widget.currentIndex
            ? [
                BoxShadow(
                  color: widget.currentColor.withOpacity(
                    0.4 * _pulseAnimation.value,
                  ),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
    );
  }
}

/// 拡張版：グリッドの位置情報も表示するプログレスバー
class DetailedSegmentedProgressBar extends StatelessWidget {
  final GridStyle gridStyle;
  final int completedCount;
  final int currentIndex;
  final double width;
  final double height;
  final bool showLabels;

  const DetailedSegmentedProgressBar({
    super.key,
    required this.gridStyle,
    required this.completedCount,
    required this.currentIndex,
    this.width = 160,
    this.height = 8,
    this.showLabels = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SegmentedProgressBar(
          gridStyle: gridStyle,
          completedCount: completedCount,
          currentIndex: currentIndex,
          width: width,
          height: height,
          spacing: 3,
        ),
        if (showLabels) ...[const SizedBox(height: 6), _buildProgressLabel()],
      ],
    );
  }

  Widget _buildProgressLabel() {
    final totalCells = gridStyle.totalCells;
    final currentPosition = gridStyle.getPosition(currentIndex);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${completedCount}/${totalCells}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            currentPosition.displayString,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
