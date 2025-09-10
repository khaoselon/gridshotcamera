import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:gal/gal.dart';
import 'package:gridshot_camera/models/grid_style.dart';
import 'package:gridshot_camera/models/shooting_mode.dart';
import 'package:gridshot_camera/models/app_settings.dart';
import 'package:gridshot_camera/services/settings_service.dart';

class ImageComposerService {
  static final ImageComposerService _instance =
      ImageComposerService._internal();
  static ImageComposerService get instance => _instance;

  ImageComposerService._internal();

  /// 複数の画像を1つのグリッド画像に合成
  Future<CompositeResult> composeGridImage({
    required ShootingSession session,
    AppSettings? settings,
  }) async {
    try {
      final appSettings = settings ?? SettingsService.instance.currentSettings;
      final images = session.getCompletedImages();

      if (images.length != session.gridStyle.totalCells) {
        throw Exception('撮影が完了していない画像があります');
      }

      debugPrint('画像合成を開始: ${images.length}枚の画像 (${session.mode.name}モード)');

      // 各画像を読み込み
      List<img.Image> loadedImages = [];
      for (final capturedImage in images) {
        final file = File(capturedImage.filePath);
        if (!await file.exists()) {
          throw Exception('画像ファイルが見つかりません: ${capturedImage.filePath}');
        }

        final bytes = await file.readAsBytes();
        final image = img.decodeImage(bytes);
        if (image == null) {
          throw Exception('画像のデコードに失敗しました: ${capturedImage.filePath}');
        }
        loadedImages.add(image);
      }

      // モードに応じて異なる合成処理を実行
      final compositeImage = session.mode.isCatalogMode
          ? _createCatalogComposite(
              images: loadedImages,
              gridStyle: session.gridStyle,
              settings: appSettings,
            )
          : _createImpossibleComposite(
              images: loadedImages,
              gridStyle: session.gridStyle,
              settings: appSettings,
            );

      // 合成画像を保存
      final savedPath = await _saveCompositeImage(
        compositeImage,
        session,
        appSettings,
      );

      debugPrint('画像合成完了: $savedPath');

      return CompositeResult(
        success: true,
        filePath: savedPath,
        message: '画像の合成が完了しました',
      );
    } catch (e) {
      debugPrint('画像合成エラー: $e');
      return CompositeResult(success: false, message: '画像の合成に失敗しました: $e');
    }
  }

  /// カタログモード用の合成処理（端末のカメラサイズそのまま配置）
  img.Image _createCatalogComposite({
    required List<img.Image> images,
    required GridStyle gridStyle,
    required AppSettings settings,
  }) {
    if (images.isEmpty) {
      throw Exception('合成する画像がありません');
    }

    // 最初の画像のサイズを基準として使用（端末のカメラサイズそのまま）
    final referenceImage = images.first;
    final originalWidth = referenceImage.width;
    final originalHeight = referenceImage.height;

    final borderWidth = settings.showGridBorder
        ? settings.borderWidth.toInt()
        : 0;

    // 合成画像のサイズを計算（各セルが元画像のサイズそのまま）
    final compositeWidth =
        (originalWidth * gridStyle.columns) +
        (borderWidth * (gridStyle.columns - 1));
    final compositeHeight =
        (originalHeight * gridStyle.rows) +
        (borderWidth * (gridStyle.rows - 1));

    debugPrint(
      'カタログ合成: 元画像サイズ=${originalWidth}x${originalHeight}, 合成サイズ=${compositeWidth}x${compositeHeight}',
    );

    // 合成画像を作成
    final composite = img.Image(
      width: compositeWidth,
      height: compositeHeight,
      format: img.Format.uint8,
      numChannels: 3,
    );

    // 背景色で埋める
    if (settings.showGridBorder && borderWidth > 0) {
      final borderColor = _convertFlutterColorToImageColor(
        settings.borderColor,
      );
      img.fill(composite, color: borderColor);
    } else {
      img.fill(composite, color: img.ColorRgb8(248, 248, 248)); // 薄いグレー背景
    }

    // 各画像を元のサイズで適切な位置に配置
    for (int i = 0; i < images.length && i < gridStyle.totalCells; i++) {
      final position = gridStyle.getPosition(i);
      final cellX =
          (position.col * originalWidth) + (position.col * borderWidth);
      final cellY =
          (position.row * originalHeight) + (position.row * borderWidth);

      // 画像のサイズを統一（基準画像のサイズに合わせる）
      img.Image processedImage;
      if (images[i].width != originalWidth ||
          images[i].height != originalHeight) {
        // サイズが異なる場合はリサイズ
        processedImage = img.copyResize(
          images[i],
          width: originalWidth,
          height: originalHeight,
          interpolation: img.Interpolation.linear,
        );
      } else {
        processedImage = images[i];
      }

      img.compositeImage(composite, processedImage, dstX: cellX, dstY: cellY);
    }

    return composite;
  }

  /// 不可能合成モード用の合成処理（完全な画像を作成）
  img.Image _createImpossibleComposite({
    required List<img.Image> images,
    required GridStyle gridStyle,
    required AppSettings settings,
  }) {
    if (images.isEmpty) {
      throw Exception('合成する画像がありません');
    }

    // 全画像のサイズを統一（最初の画像を基準）
    final referenceImage = images.first;
    final targetWidth = referenceImage.width;
    final targetHeight = referenceImage.height;

    debugPrint('不可能合成: 基準サイズ=${targetWidth}x${targetHeight}');

    // 各画像を同じサイズにリサイズ
    List<img.Image> resizedImages = [];
    for (final image in images) {
      final resized = img.copyResize(
        image,
        width: targetWidth,
        height: targetHeight,
        interpolation: img.Interpolation.linear,
      );
      resizedImages.add(resized);
    }

    // グリッドセルのサイズを計算
    final cellWidth = targetWidth ~/ gridStyle.columns;
    final cellHeight = targetHeight ~/ gridStyle.rows;
    final borderWidth = settings.showGridBorder
        ? settings.borderWidth.toInt()
        : 0;

    // 合成画像のサイズを計算（完全な画像として）
    final compositeWidth =
        (cellWidth * gridStyle.columns) +
        (borderWidth * (gridStyle.columns - 1));
    final compositeHeight =
        (cellHeight * gridStyle.rows) + (borderWidth * (gridStyle.rows - 1));

    debugPrint(
      '不可能合成: セルサイズ=${cellWidth}x${cellHeight}, 合成サイズ=${compositeWidth}x${compositeHeight}',
    );

    // 合成画像を作成
    final composite = img.Image(
      width: compositeWidth,
      height: compositeHeight,
      format: img.Format.uint8,
      numChannels: 3,
    );

    // 背景色（境界線の色）で埋める
    if (settings.showGridBorder && borderWidth > 0) {
      final borderColor = _convertFlutterColorToImageColor(
        settings.borderColor,
      );
      img.fill(composite, color: borderColor);
    }

    // 各画像から該当するグリッドセル部分を切り出して配置
    for (int i = 0; i < resizedImages.length && i < gridStyle.totalCells; i++) {
      final position = gridStyle.getPosition(i);

      // 元画像での切り出し位置を計算
      final srcX = position.col * cellWidth;
      final srcY = position.row * cellHeight;

      // 合成画像での配置位置を計算
      final dstX = (position.col * cellWidth) + (position.col * borderWidth);
      final dstY = (position.row * cellHeight) + (position.row * borderWidth);

      // 画像から該当部分を切り出し
      final croppedImage = img.copyCrop(
        resizedImages[i],
        x: srcX,
        y: srcY,
        width: cellWidth,
        height: cellHeight,
      );

      img.compositeImage(composite, croppedImage, dstX: dstX, dstY: dstY);
    }

    return composite;
  }

  /// Flutter ColorをImageライブラリのColorに変換
  img.Color _convertFlutterColorToImageColor(ui.Color flutterColor) {
    return img.ColorRgb8(
      flutterColor.red,
      flutterColor.green,
      flutterColor.blue,
    );
  }

  /// 合成画像を保存
  Future<String> _saveCompositeImage(
    img.Image image,
    ShootingSession session,
    AppSettings settings,
  ) async {
    // 保存ディレクトリを取得
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now();
    final fileName =
        'gridshot_${session.mode.name}_${session.gridStyle.displayName}_${timestamp.millisecondsSinceEpoch}.jpg';
    final filePath = path.join(directory.path, fileName);

    // JPEG品質を設定
    final jpegBytes = img.encodeJpg(
      image,
      quality: settings.imageQuality.quality,
    );

    // ファイルに保存
    final file = File(filePath);
    await file.writeAsBytes(jpegBytes);

    // ギャラリーに保存（ユーザーが確認できるように）
    try {
      await Gal.putImage(filePath);
      debugPrint('ギャラリーへの保存完了');
    } catch (e) {
      debugPrint('ギャラリー保存エラー（続行）: $e');
    }

    return filePath;
  }

  /// 画像のメタデータを取得
  Future<ImageMetadata?> getImageMetadata(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return null;
      }

      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);
      if (image == null) {
        return null;
      }

      final stat = await file.stat();

      return ImageMetadata(
        width: image.width,
        height: image.height,
        fileSize: stat.size,
        format: path.extension(filePath).toLowerCase(),
        modificationTime: stat.modified,
      );
    } catch (e) {
      debugPrint('画像メタデータの取得に失敗: $e');
      return null;
    }
  }

  /// 一時ファイルを削除
  Future<void> cleanupTemporaryFiles(ShootingSession session) async {
    try {
      for (final capturedImage in session.getCompletedImages()) {
        final file = File(capturedImage.filePath);
        if (await file.exists()) {
          await file.delete();
          debugPrint('一時ファイルを削除: ${capturedImage.filePath}');
        }
      }
    } catch (e) {
      debugPrint('一時ファイル削除エラー: $e');
    }
  }

  /// プレビュー用の縮小画像を作成
  Future<String?> createPreviewImage(
    String originalPath, {
    int maxSize = 500,
  }) async {
    try {
      final file = File(originalPath);
      if (!await file.exists()) {
        return null;
      }

      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);
      if (image == null) {
        return null;
      }

      // プレビューサイズに縮小
      final preview = img.copyResize(
        image,
        width: image.width > image.height ? maxSize : null,
        height: image.height > image.width ? maxSize : null,
        interpolation: img.Interpolation.linear,
      );

      // プレビューファイルを保存
      final directory = await getTemporaryDirectory();
      final fileName = 'preview_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final previewPath = path.join(directory.path, fileName);

      final previewBytes = img.encodeJpg(preview, quality: 80);
      final previewFile = File(previewPath);
      await previewFile.writeAsBytes(previewBytes);

      return previewPath;
    } catch (e) {
      debugPrint('プレビュー画像作成エラー: $e');
      return null;
    }
  }

  /// サポートされている画像形式かチェック
  bool isSupportedImageFormat(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    return ['.jpg', '.jpeg', '.png', '.bmp', '.tiff'].contains(extension);
  }
}

// 結果クラス
class CompositeResult {
  final bool success;
  final String? filePath;
  final String message;

  CompositeResult({
    required this.success,
    this.filePath,
    required this.message,
  });
}

// 画像メタデータクラス
class ImageMetadata {
  final int width;
  final int height;
  final int fileSize;
  final String format;
  final DateTime modificationTime;

  ImageMetadata({
    required this.width,
    required this.height,
    required this.fileSize,
    required this.format,
    required this.modificationTime,
  });

  String get fileSizeFormatted {
    if (fileSize < 1024) {
      return '${fileSize}B';
    } else if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)}KB';
    } else {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
  }

  String get dimensionsFormatted => '${width}x${height}';
}

// 画像サイズクラス
class ImageSize {
  final int width;
  final int height;

  const ImageSize({required this.width, required this.height});

  double get aspectRatio => width / height;
  bool get isSquare => width == height;
  bool get isLandscape => width > height;
  bool get isPortrait => height > width;
}
