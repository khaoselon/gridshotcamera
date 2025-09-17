import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static final PermissionService _instance = PermissionService._internal();
  static PermissionService get instance => _instance;

  PermissionService._internal();

  Map<Permission, PermissionStatus> _permissionStatus = {};

  /// カメラ権限をチェック・要求（ネイティブポップアップ優先）
  Future<PermissionResult> requestCameraPermission() async {
    try {
      debugPrint('カメラ権限を確認中...');

      final status = await Permission.camera.status;
      _permissionStatus[Permission.camera] = status;

      if (status.isGranted) {
        debugPrint('カメラ権限は既に許可されています');
        return PermissionResult(granted: true, message: 'カメラ権限が許可されています');
      }

      // 初回または拒否された場合は直接OS権限ダイアログを表示
      if (status.isDenied || status.isRestricted) {
        debugPrint('カメラ権限をOSダイアログで要求します');

        // OSネイティブのポップアップを表示
        final requestStatus = await Permission.camera.request();
        _permissionStatus[Permission.camera] = requestStatus;

        if (requestStatus.isGranted) {
          debugPrint('カメラ権限が許可されました');
          return PermissionResult(granted: true, message: 'カメラ権限が許可されました');
        } else if (requestStatus.isDenied) {
          debugPrint('カメラ権限が拒否されました');
          return PermissionResult(
            granted: false,
            message: 'カメラ権限が必要です',
            shouldShowRationale: true,
            shouldOpenSettings: false,
          );
        } else if (requestStatus.isPermanentlyDenied) {
          debugPrint('カメラ権限が永続的に拒否されました');
          return PermissionResult(
            granted: false,
            message: 'カメラ権限が拒否されました。設定から許可してください。',
            shouldShowRationale: false,
            shouldOpenSettings: true,
          );
        }
      }

      if (status.isPermanentlyDenied) {
        debugPrint('カメラ権限が永続的に拒否されています');
        return PermissionResult(
          granted: false,
          message: 'カメラ権限が拒否されています。設定から許可してください。',
          shouldShowRationale: false,
          shouldOpenSettings: true,
        );
      }

      return PermissionResult(
        granted: false,
        message: 'カメラ権限の取得に失敗しました',
        shouldShowRationale: true,
      );
    } catch (e) {
      debugPrint('カメラ権限の確認中にエラー: $e');
      return PermissionResult(
        granted: false,
        message: 'カメラ権限の確認中にエラーが発生しました',
        shouldShowRationale: true,
      );
    }
  }

  /// ストレージ権限をチェック・要求（ネイティブポップアップ優先）
  Future<PermissionResult> requestStoragePermission() async {
    try {
      debugPrint('ストレージ権限を確認中...');

      Permission permission;
      if (Platform.isAndroid) {
        // Android 13 (API 33) 以降では READ_MEDIA_IMAGES を使用
        final androidInfo = await _getAndroidVersion();
        if (androidInfo >= 33) {
          permission = Permission.photos;
        } else {
          permission = Permission.storage;
        }
      } else {
        // iOSでは写真ライブラリアクセス権限
        permission = Permission.photos;
      }

      final status = await permission.status;
      _permissionStatus[permission] = status;

      if (status.isGranted) {
        debugPrint('ストレージ権限は既に許可されています');
        return PermissionResult(granted: true, message: 'ストレージ権限が許可されています');
      }

      // 初回または拒否された場合は直接OS権限ダイアログを表示
      if (status.isDenied || status.isRestricted) {
        debugPrint('ストレージ権限をOSダイアログで要求します');

        // OSネイティブのポップアップを表示
        final requestStatus = await permission.request();
        _permissionStatus[permission] = requestStatus;

        if (requestStatus.isGranted) {
          debugPrint('ストレージ権限が許可されました');
          return PermissionResult(granted: true, message: 'ストレージ権限が許可されました');
        } else if (requestStatus.isDenied) {
          debugPrint('ストレージ権限が拒否されました');
          return PermissionResult(
            granted: false,
            message: 'ストレージ権限が必要です',
            shouldShowRationale: true,
            shouldOpenSettings: false,
          );
        } else if (requestStatus.isPermanentlyDenied) {
          debugPrint('ストレージ権限が永続的に拒否されました');
          return PermissionResult(
            granted: false,
            message: 'ストレージ権限が拒否されました。設定から許可してください。',
            shouldShowRationale: false,
            shouldOpenSettings: true,
          );
        }
      }

      if (status.isPermanentlyDenied) {
        debugPrint('ストレージ権限が永続的に拒否されています');
        return PermissionResult(
          granted: false,
          message: 'ストレージ権限が拒否されています。設定から許可してください。',
          shouldShowRationale: false,
          shouldOpenSettings: true,
        );
      }

      return PermissionResult(
        granted: false,
        message: 'ストレージ権限の取得に失敗しました',
        shouldShowRationale: true,
      );
    } catch (e) {
      debugPrint('ストレージ権限の確認中にエラー: $e');
      return PermissionResult(
        granted: false,
        message: 'ストレージ権限の確認中にエラーが発生しました',
        shouldShowRationale: true,
      );
    }
  }

  /// マイク権限をチェック・要求（カメラ使用時に必要な場合）
  Future<PermissionResult> requestMicrophonePermission() async {
    try {
      debugPrint('マイク権限を確認中...');

      final status = await Permission.microphone.status;
      _permissionStatus[Permission.microphone] = status;

      if (status.isGranted) {
        debugPrint('マイク権限は既に許可されています');
        return PermissionResult(granted: true, message: 'マイク権限が許可されています');
      }

      // 初回または拒否された場合は直接OS権限ダイアログを表示
      if (status.isDenied || status.isRestricted) {
        debugPrint('マイク権限をOSダイアログで要求します');

        // OSネイティブのポップアップを表示
        final requestStatus = await Permission.microphone.request();
        _permissionStatus[Permission.microphone] = requestStatus;

        if (requestStatus.isGranted) {
          debugPrint('マイク権限が許可されました');
          return PermissionResult(granted: true, message: 'マイク権限が許可されました');
        } else {
          debugPrint('マイク権限が拒否されました');
          return PermissionResult(
            granted: false,
            message: 'マイク権限が必要です',
            shouldShowRationale: requestStatus.isDenied,
            shouldOpenSettings: requestStatus.isPermanentlyDenied,
          );
        }
      }

      if (status.isPermanentlyDenied) {
        debugPrint('マイク権限が永続的に拒否されています');
        return PermissionResult(
          granted: false,
          message: 'マイク権限が拒否されています。設定から許可してください。',
          shouldShowRationale: false,
          shouldOpenSettings: true,
        );
      }

      return PermissionResult(
        granted: false,
        message: 'マイク権限の取得に失敗しました',
        shouldShowRationale: true,
      );
    } catch (e) {
      debugPrint('マイク権限の確認中にエラー: $e');
      return PermissionResult(
        granted: false,
        message: 'マイク権限の確認中にエラーが発生しました',
        shouldShowRationale: true,
      );
    }
  }

  /// アプリに必要な全ての権限を一括要求
  Future<AllPermissionsResult> requestAllPermissions() async {
    debugPrint('全ての必要な権限を確認中...');

    final results = <String, PermissionResult>{};
    bool allGranted = true;

    // カメラ権限（必須）
    final cameraResult = await requestCameraPermission();
    results['camera'] = cameraResult;
    if (!cameraResult.granted) allGranted = false;

    // ストレージ権限（必須）
    final storageResult = await requestStoragePermission();
    results['storage'] = storageResult;
    if (!storageResult.granted) allGranted = false;

    // マイク権限（iOSでは推奨、Androidでは必要に応じて）
    if (Platform.isIOS) {
      final micResult = await requestMicrophonePermission();
      results['microphone'] = micResult;
      // マイク権限は必須ではないので、allGrantedには影響させない
    }

    return AllPermissionsResult(allGranted: allGranted, results: results);
  }

  /// 単純なカメラ権限確認（OSネイティブポップアップのみ）
  Future<bool> checkAndRequestCameraPermissionSimple() async {
    try {
      // まず現在のステータスを確認
      final status = await Permission.camera.status;

      if (status.isGranted) {
        return true;
      }

      if (status.isPermanentlyDenied) {
        // 永続的に拒否されている場合は false を返す
        return false;
      }

      // 権限要求（OSネイティブポップアップ）
      final result = await Permission.camera.request();
      return result.isGranted;
    } catch (e) {
      debugPrint('カメラ権限確認エラー: $e');
      return false;
    }
  }

  /// 権限の現在の状態を取得
  Future<PermissionStatus> getPermissionStatus(Permission permission) async {
    return await permission.status;
  }

  /// 複数の権限の状態を一括取得
  Future<Map<Permission, PermissionStatus>> getMultiplePermissionStatus(
    List<Permission> permissions,
  ) async {
    Map<Permission, PermissionStatus> results = {};
    for (final permission in permissions) {
      results[permission] = await permission.status;
    }
    return results;
  }

  /// 設定画面を開く
  Future<bool> openAppSettings() async {
    try {
      return await openAppSettings();
    } catch (e) {
      debugPrint('設定画面を開く際にエラー: $e');
      return false;
    }
  }

  /// 権限が永続的に拒否されているかチェック
  Future<bool> isPermissionPermanentlyDenied(Permission permission) async {
    final status = await permission.status;
    return status.isPermanentlyDenied;
  }

  /// 権限の説明が必要かチェック
  Future<bool> shouldShowRequestRationale(Permission permission) async {
    if (Platform.isAndroid) {
      // Android固有の実装
      return !(await permission.status).isPermanentlyDenied;
    }
    return true;
  }

  /// Androidのバージョンを取得（権限管理用）
  Future<int> _getAndroidVersion() async {
    if (!Platform.isAndroid) return 0;

    try {
      // Android APIレベルを取得する簡易実装
      // 実際のプロダクションでは device_info_plus などを使用
      return 33; // デフォルトで新しいバージョンを想定
    } catch (e) {
      debugPrint('Androidバージョン取得エラー: $e');
      return 33;
    }
  }

  /// デバッグ用：全権限の状態を出力
  Future<void> debugPrintAllPermissions() async {
    debugPrint('=== 権限状態 ===');

    final permissions = [
      Permission.camera,
      Permission.storage,
      Permission.photos,
      Permission.microphone,
    ];

    for (final permission in permissions) {
      final status = await permission.status;
      debugPrint('${permission.toString()}: ${status.toString()}');
    }

    debugPrint('================');
  }

  /// 権限状態のキャッシュをクリア
  void clearPermissionCache() {
    _permissionStatus.clear();
  }
}

// 権限要求結果クラス
class PermissionResult {
  final bool granted;
  final String message;
  final bool shouldShowRationale;
  final bool shouldOpenSettings;

  PermissionResult({
    required this.granted,
    required this.message,
    this.shouldShowRationale = false,
    this.shouldOpenSettings = false,
  });

  @override
  String toString() {
    return 'PermissionResult(granted: $granted, message: $message, shouldShowRationale: $shouldShowRationale, shouldOpenSettings: $shouldOpenSettings)';
  }
}

// 全権限の要求結果クラス
class AllPermissionsResult {
  final bool allGranted;
  final Map<String, PermissionResult> results;

  AllPermissionsResult({required this.allGranted, required this.results});

  bool isPermissionGranted(String permissionName) {
    return results[permissionName]?.granted ?? false;
  }

  List<String> get deniedPermissions {
    return results.entries
        .where((entry) => !entry.value.granted)
        .map((entry) => entry.key)
        .toList();
  }

  List<String> get grantedPermissions {
    return results.entries
        .where((entry) => entry.value.granted)
        .map((entry) => entry.key)
        .toList();
  }

  @override
  String toString() {
    return 'AllPermissionsResult(allGranted: $allGranted, granted: ${grantedPermissions.join(", ")}, denied: ${deniedPermissions.join(", ")})';
  }
}
