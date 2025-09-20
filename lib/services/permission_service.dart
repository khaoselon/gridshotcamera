import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:isolate';
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

/// ★ 新規追加：Isolateで画像処理を実行するためのメッセージクラス
class CompositeRequest {
  final List<String> imagePaths;
  final GridStyle gridStyle;
  final ShootingMode mode;
  final AppSettings settings;
  final String outputPath;
  final SendPort responsePort;

  CompositeRequest({
    required this.imagePaths,
    required this.gridStyle,
    required this.mode,
    required this.settings,
    required this.outputPath,
    required this.responsePort,
  });
}

/// ★ 新規追加：進捗報告用のメッセージ
class CompositeProgress {
  final int current;
  final int total;
  final String message;

  CompositeProgress({
    required this.current,
    required this.total,
    required this.message,
  });
}

/// ★ 新規追加：結果返却用のメッセージ
class CompositeResponse {
  final bool success;
  final String? filePath;
  final String message;

  CompositeResponse({
    required this.success,
    this.filePath,
    required this.message,
  });
}

class ImageComposerService {
  static final ImageComposerService _instance =
      ImageComposerService._internal();
  static ImageComposerService get instance => _instance;

  ImageComposerService._internal();

  /// ★ 修正：メインスレッドを阻害しないIsolate化された画像合成
  Future<CompositeResult> composeGridImage({
    required ShootingSession session,
    AppSettings? settings,
    Function(int current, int total, String message)? onProgress,
  }) async {
    try {
      final appSettings = settings ?? SettingsService.instance.currentSettings;
      final images = session.getCompletedImages();

      if (images.length != session.gridStyle.totalCells) {
        throw Exception('撮影が完了していない画像があります');
      }

      debugPrint(
        '★ Isolate画像合成を開始: ${images.length}枚の画像 (${session.mode.name}モード)',
      );

      // ★ 出力ファイルパスを事前に決定
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now();
      final fileName =
          'gridshot_${session.mode.name}_${session.gridStyle.displayName}_${timestamp.millisecondsSinceEpoch}.jpg';
      final outputPath = path.join(directory.path, fileName);

      // ★ Isolateでの処理用にファイルパスのリストを作成
      final imagePaths = images.map((img) => img.filePath).toList();

      // ★ Isolateを使用して画像合成を実行（メインスレッドをブロックしない）
      final result = await _composeInIsolate(
        imagePaths: imagePaths,
        gridStyle: session.gridStyle,
        mode: session.mode,
        settings: appSettings,
        outputPath: outputPath,
        onProgress: onProgress,
      );

      if (result.success && result.filePath != null) {
        debugPrint('★ Isolate画像合成完了: ${result.filePath}');

        // ★ 一時ファイルのクリーンアップ（バックグラウンドで実行）
        _cleanupTemporaryFilesAsync(session);

        return CompositeResult(
          success: true,
          filePath: result.filePath,
          message: '画像の合成が完了しました',
        );
      } else {
        return CompositeResult(success: false, message: result.message);
      }
    } catch (e) {
      debugPrint('★ Isolate画像合成エラー: $e');
      return CompositeResult(success: false, message: '画像の合成に失敗しました: $e');
    }
  }

  /// ★ 新規追加：Isolateを使った画像合成の実行
  Future<CompositeResponse> _composeInIsolate({
    required List<String> imagePaths,
    required GridStyle gridStyle,
    required ShootingMode mode,
    required AppSettings settings,
    required String outputPath,
    Function(int current, int total, String message)? onProgress,
  }) async {
    final receivePort = ReceivePort();
    final completer = Completer<CompositeResponse>();

    try {
      // ★ Isolateを生成して画像処理を実行
      await Isolate.spawn(
        _compositeIsolateEntryPoint,
        CompositeRequest(
          imagePaths: imagePaths,
          gridStyle: gridStyle,
          mode: mode,
          settings: settings,
          outputPath: outputPath,
          responsePort: receivePort.sendPort,
        ),
      );

      // ★ Isolateからの進捗とレスポンスを処理
      receivePort.listen((message) {
        if (message is CompositeProgress) {
          // 進捗報告をUIに伝達（頻度制限付き）
          onProgress?.call(message.current, message.total, message.message);
        } else if (message is CompositeResponse) {
          // 最終結果を取得
          if (!completer.isCompleted) {
            completer.complete(message);
          }
          receivePort.close();
        }
      });

      // ★ タイムアウト付きで結果を待機
      return await completer.future.timeout(
        const Duration(minutes: 5), // 最大5分待機
        onTimeout: () {
          receivePort.close();
          return CompositeResponse(success: false, message: '画像合成がタイムアウトしました');
        },
      );
    } catch (e) {
      receivePort.close();
      return CompositeResponse(success: false, message: 'Isolate実行エラー: $e');
    }
  }

  /// ★ 新規追加：Isolateのエントリーポイント（画像合成を実行）
  static void _compositeIsolateEntryPoint(CompositeRequest request) async {
    try {
      debugPrint('★ Isolate内での画像合成開始');

      // 進捗報告：画像読み込み開始
      request.responsePort.send(
        CompositeProgress(
          current: 0,
          total: request.imagePaths.length,
          message: '画像を読み込み中...',
        ),
      );

      // ★ 各画像をIsolate内で読み込み
      List<img.Image> loadedImages = [];
      for (int i = 0; i < request.imagePaths.length; i++) {
        final imagePath = request.imagePaths[i];
        final file = File(imagePath);

        if (!await file.exists()) {
          throw Exception('画像ファイルが見つかりません: $imagePath');
        }

        final bytes = await file.readAsBytes();
        final image = img.decodeImage(bytes);
        if (image == null) {
          throw Exception('画像のデコードに失敗しました: $imagePath');
        }
        loadedImages.add(image);

        // 進捗報告（読み込み進捗）
        request.responsePort.send(
          CompositeProgress(
            current: i + 1,
            total: request.imagePaths.length,
            message: '画像 ${i + 1}/${request.imagePaths.length} を読み込み中...',
          ),
        );
      }

      // 進捗報告：合成開始
      request.responsePort.send(
        CompositeProgress(
          current: request.imagePaths.length,
          total: request.imagePaths.length + 1,
          message: '画像を合成中...',
        ),
      );

      // ★ モードに応じた合成処理をIsolate内で実行
      img.Image compositeImage;
      if (request.mode == ShootingMode.catalog) {
        compositeImage = _createCatalogCompositeInIsolate(
          images: loadedImages,
          gridStyle: request.gridStyle,
          settings: request.settings,
        );
      } else {
        compositeImage = _createImpossibleCompositeInIsolate(
          images: loadedImages,
          gridStyle: request.gridStyle,
          settings: request.settings,
        );
      }

      // 進捗報告：保存開始
      request.responsePort.send(
        CompositeProgress(
          current: request.imagePaths.length + 1,
          total: request.imagePaths.length + 2,
          message: '画像を保存中...',
        ),
      );

      // ★ 合成画像をIsolate内で保存
      await _saveCompositeImageInIsolate(
        compositeImage,
        request.outputPath,
        request.settings,
      );

      debugPrint('★ Isolate内での画像合成完了: ${request.outputPath}');

      // ★ 成功結果をメインIsolateに送信
      request.responsePort.send(
        CompositeResponse(
          success: true,
          filePath: request.outputPath,
          message: '画像の合成が完了しました',
        ),
      );
    } catch (e) {
      debugPrint('★ Isolate内画像合成エラー: $e');
      request.responsePort.send(
        CompositeResponse(success: false, message: 'Isolate内エラー: $e'),
      );
    }
  }

  /// ★ 修正：Isolate内でのカタログモード合成処理
  static img.Image _createCatalogCompositeInIsolate({
    required List<img.Image> images,
    required GridStyle gridStyle,
    required AppSettings settings,
  }) {
    if (images.isEmpty) {
      throw Exception('合成する画像がありません');
    }

    final referenceImage = images.first;
    final originalWidth = referenceImage.width;
    final originalHeight = referenceImage.height;

    final borderWidth = settings.showGridBorder
        ? settings.borderWidth.toInt()
        : 0;

    final compositeWidth =
        (originalWidth * gridStyle.columns) +
        (borderWidth * (gridStyle.columns - 1));
    final compositeHeight =
        (originalHeight * gridStyle.rows) +
        (borderWidth * (gridStyle.rows - 1));

    debugPrint(
      '★ Isolateカタログ合成: 元画像サイズ=${originalWidth}x${originalHeight}, 合成サイズ=${compositeWidth}x${compositeHeight}',
    );

    final composite = img.Image(
      width: compositeWidth,
      height: compositeHeight,
      format: img.Format.uint8,
      numChannels: 3,
    );

    if (settings.showGridBorder && borderWidth > 0) {
      final borderColor = _convertFlutterColorToImageColorInIsolate(
        settings.borderColor,
      );
      img.fill(composite, color: borderColor);
    } else {
      img.fill(composite, color: img.ColorRgb8(248, 248, 248));
    }

    for (int i = 0; i < images.length && i < gridStyle.totalCells; i++) {
      final position = gridStyle.getPosition(i);
      final cellX =
          (position.col * originalWidth) + (position.col * borderWidth);
      final cellY =
          (position.row * originalHeight) + (position.row * borderWidth);

      img.Image processedImage;
      if (images[i].width != originalWidth ||
          images[i].height != originalHeight) {
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

  /// ★ 修正：Isolate内での不可能合成モード処理
  static img.Image _createImpossibleCompositeInIsolate({
    required List<img.Image> images,
    required GridStyle gridStyle,
    required AppSettings settings,
  }) {
    if (images.isEmpty) {
      throw Exception('合成する画像がありません');
    }

    final referenceImage = images.first;
    final targetWidth = referenceImage.width;
    final targetHeight = referenceImage.height;

    debugPrint('★ Isolate不可能合成: 基準サイズ=${targetWidth}x${targetHeight}');

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

    final cellWidth = targetWidth ~/ gridStyle.columns;
    final cellHeight = targetHeight ~/ gridStyle.rows;
    final borderWidth = settings.showGridBorder
        ? settings.borderWidth.toInt()
        : 0;

    final compositeWidth =
        (cellWidth * gridStyle.columns) +
        (borderWidth * (gridStyle.columns - 1));
    final compositeHeight =
        (cellHeight * gridStyle.rows) + (borderWidth * (gridStyle.rows - 1));

    debugPrint(
      '★ Isolate不可能合成: セルサイズ=${cellWidth}x${cellHeight}, 合成サイズ=${compositeWidth}x${compositeHeight}',
    );

    final composite = img.Image(
      width: compositeWidth,
      height: compositeHeight,
      format: img.Format.uint8,
      numChannels: 3,
    );

    if (settings.showGridBorder && borderWidth > 0) {
      final borderColor = _convertFlutterColorToImageColorInIsolate(
        settings.borderColor,
      );
      img.fill(composite, color: borderColor);
    }

    for (int i = 0; i < resizedImages.length && i < gridStyle.totalCells; i++) {
      final position = gridStyle.getPosition(i);

      final srcX = position.col * cellWidth;
      final srcY = position.row * cellHeight;

      final dstX = (position.col * cellWidth) + (position.col * borderWidth);
      final dstY = (position.row * cellHeight) + (position.row * borderWidth);

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

  /// ★ 新規追加：Isolate内でのFlutter Color変換
  static img.Color _convertFlutterColorToImageColorInIsolate(
    ui.Color flutterColor,
  ) {
    return img.ColorRgb8(
      flutterColor.red,
      flutterColor.green,
      flutterColor.blue,
    );
  }

  /// ★ 新規追加：Isolate内での画像保存処理
  static Future<void> _saveCompositeImageInIsolate(
    img.Image image,
    String outputPath,
    AppSettings settings,
  ) async {
    final jpegBytes = img.encodeJpg(
      image,
      quality: settings.imageQuality.quality,
    );

    final file = File(outputPath);
    await file.writeAsBytes(jpegBytes);

    // ★ 修正：ギャラリー保存をtry-catchで囲む（権限エラー対策）
    try {
      debugPrint('★ Isolate内ギャラリーへの保存を開始...');
      await Gal.putImage(outputPath);
      debugPrint('★ Isolate内ギャラリーへの保存完了');
    } catch (e) {
      debugPrint('★ Isolate内ギャラリー保存エラー: $e');
      // エラーが発生してもアプリ内のファイルは保存されているので、処理を続行
    }
  }

  /// ★ 修正：一時ファイルの非同期クリーンアップ（メインスレッドを阻害しない）
  Future<void> _cleanupTemporaryFilesAsync(ShootingSession session) async {
    // バックグラウンドで実行
    Future.delayed(const Duration(seconds: 2), () async {
      try {
        for (final capturedImage in session.getCompletedImages()) {
          final file = File(capturedImage.filePath);
          if (await file.exists()) {
            await file.delete();
            debugPrint('★ 一時ファイルを削除: ${capturedImage.filePath}');
          }
        }
      } catch (e) {
        debugPrint('★ 一時ファイル削除エラー: $e');
      }
    });
  }

  /// ★ 既存：画像のメタデータを取得（軽量化）
  Future<ImageMetadata?> getImageMetadata(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return null;
      }

      // ★ 修正：メタデータ取得を軽量化（ファイルサイズ情報のみ先に取得）
      final stat = await file.stat();

      // 画像サイズ情報は必要時のみ取得
      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);
      if (image == null) {
        return null;
      }

      return ImageMetadata(
        width: image.width,
        height: image.height,
        fileSize: stat.size,
        format: path.extension(filePath).toLowerCase(),
        modificationTime: stat.modified,
      );
    } catch (e) {
      debugPrint('★ 画像メタデータの取得に失敗: $e');
      return null;
    }
  }

  /// ★ 既存：一時ファイルを削除（同期版）
  Future<void> cleanupTemporaryFiles(ShootingSession session) async {
    await _cleanupTemporaryFilesAsync(session);
  }

  /// ★ 既存：プレビュー用の縮小画像を作成（軽量化）
  Future<String?> createPreviewImage(
    String originalPath, {
    int maxSize = 500,
  }) async {
    try {
      final file = File(originalPath);
      if (!await file.exists()) {
        return null;
      }

      // ★ 修正：プレビュー作成もIsolateで実行することを検討
      // しかし、プレビューは小さいサイズなので、現在はメインスレッドで実行
      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);
      if (image == null) {
        return null;
      }

      final preview = img.copyResize(
        image,
        width: image.width > image.height ? maxSize : null,
        height: image.height > image.width ? maxSize : null,
        interpolation: img.Interpolation.linear,
      );

      final directory = await getTemporaryDirectory();
      final fileName = 'preview_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final previewPath = path.join(directory.path, fileName);

      final previewBytes = img.encodeJpg(preview, quality: 80);
      final previewFile = File(previewPath);
      await previewFile.writeAsBytes(previewBytes);

      return previewPath;
    } catch (e) {
      debugPrint('★ プレビュー画像作成エラー: $e');
      return null;
    }
  }

  /// サポートされている画像形式かチェック
  bool isSupportedImageFormat(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    return ['.jpg', '.jpeg', '.png', '.bmp', '.tiff'].contains(extension);
  }
}

// 既存の結果クラス
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

// 既存の画像メタデータクラス
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

// 既存の画像サイズクラス
class ImageSize {
  final int width;
  final int height;

  const ImageSize({required this.width, required this.height});

  double get aspectRatio => width / height;
  bool get isSquare => width == height;
  bool get isLandscape => width > height;
  bool get isPortrait => height > width;
}
