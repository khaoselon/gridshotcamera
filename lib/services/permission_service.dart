import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:gridshot_camera/services/settings_service.dart';

/// 権限管理サービス
class PermissionService {
  static final PermissionService _instance = PermissionService._internal();
  static PermissionService get instance => _instance;

  PermissionService._internal();

  /// カメラ権限をチェック・要求
  Future<PermissionResult> requestCameraPermission() async {
    try {
      debugPrint('カメラ権限をチェック中...');

      final status = await Permission.camera.status;
      debugPrint('カメラ権限の現在のステータス: $status');

      if (status.isGranted) {
        await SettingsService.instance.updateCameraRequested(true);
        return PermissionResult(
          isGranted: true,
          shouldShowRationale: false,
          message: 'カメラ権限が許可されています',
        );
      }

      if (status.isDenied) {
        debugPrint('カメラ権限を要求します...');
        final result = await Permission.camera.request();
        debugPrint('カメラ権限要求結果: $result');

        await SettingsService.instance.updateCameraRequested(true);

        if (result.isGranted) {
          return PermissionResult(
            isGranted: true,
            shouldShowRationale: false,
            message: 'カメラ権限が許可されました',
          );
        } else if (result.isPermanentlyDenied) {
          return PermissionResult(
            isGranted: false,
            shouldShowRationale: false,
            shouldOpenSettings: true,
            message: 'カメラ権限が永続的に拒否されています。設定から手動で許可してください。',
          );
        } else {
          return PermissionResult(
            isGranted: false,
            shouldShowRationale: true,
            message: 'カメラ権限が拒否されました。写真を撮影するために必要です。',
          );
        }
      }

      if (status.isPermanentlyDenied) {
        return PermissionResult(
          isGranted: false,
          shouldShowRationale: false,
          shouldOpenSettings: true,
          message: 'カメラ権限が永続的に拒否されています。設定から手動で許可してください。',
        );
      }

      return PermissionResult(
        isGranted: false,
        shouldShowRationale: true,
        message: 'カメラ権限が必要です',
      );
    } catch (e) {
      debugPrint('カメラ権限チェックエラー: $e');
      return PermissionResult(
        isGranted: false,
        shouldShowRationale: false,
        message: 'カメラ権限のチェックに失敗しました: $e',
      );
    }
  }

  /// ストレージ権限をチェック・要求（Android用）
  Future<PermissionResult> requestStoragePermission() async {
    try {
      debugPrint('ストレージ権限をチェック中...');

      // iOSではストレージ権限は不要
      if (Platform.isIOS) {
        return PermissionResult(
          isGranted: true,
          shouldShowRationale: false,
          message: 'iOSではストレージ権限は不要です',
        );
      }

      Permission storagePermission;

      // Android 13以降は別の権限を使用
      if (Platform.isAndroid) {
        // Android 13以降では写真権限を使用
        storagePermission = Permission.photos;
      } else {
        storagePermission = Permission.storage;
      }

      final status = await storagePermission.status;
      debugPrint('ストレージ権限の現在のステータス: $status');

      if (status.isGranted) {
        await SettingsService.instance.updateStorageRequested(true);
        return PermissionResult(
          isGranted: true,
          shouldShowRationale: false,
          message: 'ストレージ権限が許可されています',
        );
      }

      if (status.isDenied) {
        debugPrint('ストレージ権限を要求します...');
        final result = await storagePermission.request();
        debugPrint('ストレージ権限要求結果: $result');

        await SettingsService.instance.updateStorageRequested(true);

        if (result.isGranted) {
          return PermissionResult(
            isGranted: true,
            shouldShowRationale: false,
            message: 'ストレージ権限が許可されました',
          );
        } else if (result.isPermanentlyDenied) {
          return PermissionResult(
            isGranted: false,
            shouldShowRationale: false,
            shouldOpenSettings: true,
            message: 'ストレージ権限が永続的に拒否されています。設定から手動で許可してください。',
          );
        } else {
          return PermissionResult(
            isGranted: false,
            shouldShowRationale: true,
            message: 'ストレージ権限が拒否されました。写真を保存するために必要です。',
          );
        }
      }

      if (status.isPermanentlyDenied) {
        return PermissionResult(
          isGranted: false,
          shouldShowRationale: false,
          shouldOpenSettings: true,
          message: 'ストレージ権限が永続的に拒否されています。設定から手動で許可してください。',
        );
      }

      return PermissionResult(
        isGranted: false,
        shouldShowRationale: true,
        message: 'ストレージ権限が必要です',
      );
    } catch (e) {
      debugPrint('ストレージ権限チェックエラー: $e');
      return PermissionResult(
        isGranted: false,
        shouldShowRationale: false,
        message: 'ストレージ権限のチェックに失敗しました: $e',
      );
    }
  }

  /// 通知権限をチェック・要求
  Future<PermissionResult> requestNotificationPermission() async {
    try {
      debugPrint('通知権限をチェック中...');

      final status = await Permission.notification.status;
      debugPrint('通知権限の現在のステータス: $status');

      if (status.isGranted) {
        return PermissionResult(
          isGranted: true,
          shouldShowRationale: false,
          message: '通知権限が許可されています',
        );
      }

      if (status.isDenied) {
        debugPrint('通知権限を要求します...');
        final result = await Permission.notification.request();
        debugPrint('通知権限要求結果: $result');

        if (result.isGranted) {
          return PermissionResult(
            isGranted: true,
            shouldShowRationale: false,
            message: '通知権限が許可されました',
          );
        } else {
          return PermissionResult(
            isGranted: false,
            shouldShowRationale: true,
            message: '通知権限が拒否されました',
          );
        }
      }

      return PermissionResult(
        isGranted: false,
        shouldShowRationale: true,
        message: '通知権限が必要です',
      );
    } catch (e) {
      debugPrint('通知権限チェックエラー: $e');
      return PermissionResult(
        isGranted: false,
        shouldShowRationale: false,
        message: '通知権限のチェックに失敗しました: $e',
      );
    }
  }

  /// 必要な権限をすべてチェック
  Future<Map<String, PermissionResult>> checkAllRequiredPermissions() async {
    final results = <String, PermissionResult>{};

    try {
      // カメラ権限をチェック
      results['camera'] = await requestCameraPermission();

      // ストレージ権限をチェック（Androidのみ）
      if (Platform.isAndroid) {
        results['storage'] = await requestStoragePermission();
      }

      debugPrint('すべての権限チェック完了: $results');
    } catch (e) {
      debugPrint('権限チェック中にエラー: $e');
    }

    return results;
  }

  /// 権限が必要か判定
  bool needsPermissionRequest(String permissionType) {
    final settings = SettingsService.instance.currentSettings;

    switch (permissionType) {
      case 'camera':
        return !settings.hasRequestedCamera;
      case 'storage':
        return !settings.hasRequestedStorage;
      case 'tracking':
        return !settings.hasRequestedTracking;
      default:
        return false;
    }
  }

  /// アプリの設定画面を開く
  Future<bool> openAppSettings() async {
    try {
      return await openAppSettings();
    } catch (e) {
      debugPrint('設定画面を開くのに失敗: $e');
      return false;
    }
  }

  /// 権限の現在のステータスを取得
  Future<Map<String, PermissionStatus>> getCurrentPermissionStatuses() async {
    final statuses = <String, PermissionStatus>{};

    try {
      statuses['camera'] = await Permission.camera.status;

      if (Platform.isAndroid) {
        statuses['storage'] = await Permission.photos.status;
      }

      statuses['notification'] = await Permission.notification.status;
    } catch (e) {
      debugPrint('権限ステータス取得エラー: $e');
    }

    return statuses;
  }

  /// デバッグ用：権限状況を出力
  Future<void> debugPrintPermissionStatuses() async {
    debugPrint('=== 権限状況 ===');
    final statuses = await getCurrentPermissionStatuses();

    for (final entry in statuses.entries) {
      debugPrint('${entry.key}: ${entry.value}');
    }

    final settings = SettingsService.instance.currentSettings;
    debugPrint('カメラ権限要求済み: ${settings.hasRequestedCamera}');
    debugPrint('ストレージ権限要求済み: ${settings.hasRequestedStorage}');
    debugPrint('トラッキング許可要求済み: ${settings.hasRequestedTracking}');
    debugPrint('===============');
  }
}

/// 権限要求の結果
class PermissionResult {
  final bool isGranted;
  final bool shouldShowRationale;
  final bool shouldOpenSettings;
  final String message;

  PermissionResult({
    required this.isGranted,
    required this.shouldShowRationale,
    this.shouldOpenSettings = false,
    required this.message,
  });

  @override
  String toString() {
    return 'PermissionResult(isGranted: $isGranted, shouldShowRationale: $shouldShowRationale, shouldOpenSettings: $shouldOpenSettings, message: $message)';
  }
}
