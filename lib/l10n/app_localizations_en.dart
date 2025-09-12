// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'GridShot Camera';

  @override
  String get homeTitle => 'Select Shooting Mode';

  @override
  String get catalogMode => 'Catalog Shot';

  @override
  String get catalogModeDescription =>
      'Capture different subjects in each grid cell for cataloging';

  @override
  String get impossibleMode => 'Grid Fusion';

  @override
  String get impossibleModeDescription =>
      'Shoot the same scene in grid order to create impossible compositions';

  @override
  String get gridStyle => 'Grid Style';

  @override
  String get grid2x2 => '2×2';

  @override
  String get grid2x3 => '2×3';

  @override
  String get grid3x2 => '3×2';

  @override
  String get grid3x3 => '3×3';

  @override
  String get startShooting => 'Start Shooting';

  @override
  String get settings => 'Settings';

  @override
  String get cameraTitle => 'Shooting';

  @override
  String currentPosition(String position) {
    return 'Current: $position';
  }

  @override
  String get tapToShoot => 'Tap to Shoot';

  @override
  String get retake => 'Retake';

  @override
  String get next => 'Next';

  @override
  String get complete => 'Complete';

  @override
  String get previewTitle => 'Preview';

  @override
  String get save => 'Save';

  @override
  String get share => 'Share';

  @override
  String get cancel => 'Cancel';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get japanese => '日本語';

  @override
  String get english => 'English';

  @override
  String get gridBorder => 'Grid Border';

  @override
  String get borderColor => 'Border Color';

  @override
  String get borderWidth => 'Border Width';

  @override
  String get imageQuality => 'Image Quality';

  @override
  String get high => 'High';

  @override
  String get medium => 'Medium';

  @override
  String get low => 'Low';

  @override
  String get adSettings => 'Ad Settings';

  @override
  String get showAds => 'Show Ads';

  @override
  String get cameraPermission => 'Camera Permission';

  @override
  String get cameraPermissionMessage =>
      'Camera access is required to take photos. Please allow camera access in settings.';

  @override
  String get storagePermission => 'Storage Permission';

  @override
  String get storagePermissionMessage =>
      'Storage access is required to save photos.';

  @override
  String get openSettings => 'Open Settings';

  @override
  String get error => 'Error';

  @override
  String get saveSuccess => 'Image saved successfully';

  @override
  String get saveFailed => 'Failed to save image';

  @override
  String get shareSuccess => 'Image shared successfully';

  @override
  String get loading => 'Loading...';

  @override
  String get processing => 'Processing...';

  @override
  String get compositing => 'Compositing...';

  @override
  String get trackingPermissionTitle => 'App Tracking Permission';

  @override
  String get trackingPermissionMessage =>
      'Allow app tracking across other apps to personalize ads.';

  @override
  String get allow => 'Allow';

  @override
  String get dontAllow => 'Don\'t Allow';

  @override
  String get selectPhotoStyle => 'Select your desired photo style';

  @override
  String get shootingMode => 'Shooting Mode';

  @override
  String selectedGrid(String gridStyle) {
    return 'Selected: $gridStyle';
  }

  @override
  String get checkingPermissions => 'Checking permissions...';

  @override
  String get confirmation => 'Confirmation';

  @override
  String get retakePhotos => 'Do you want to retake the photos?';

  @override
  String get takeNewPhoto => 'Take New Photo';

  @override
  String get shootingInfo => 'Shooting Information';

  @override
  String get mode => 'Mode';

  @override
  String get gridStyleInfo => 'Grid Style';

  @override
  String get photoCount => 'Photo Count';

  @override
  String get shootingDate => 'Shooting Date';

  @override
  String get saving => 'Saving...';

  @override
  String get sharing => 'Sharing...';

  @override
  String get catalogModeDisplay => 'Catalog Shot';

  @override
  String get impossibleModeDisplay => 'Grid Fusion';

  @override
  String get resetSettings => 'Reset Settings';

  @override
  String get appInfo => 'App Information';

  @override
  String get version => 'Version';

  @override
  String get developer => 'Developer';

  @override
  String get aboutAds => 'About Ads';

  @override
  String get selectBorderColor => 'Select Border Color';

  @override
  String get resetConfirmation =>
      'Reset all settings to default values? This action cannot be undone.';

  @override
  String get reset => 'Reset';

  @override
  String get settingsReset => 'Settings have been reset';

  @override
  String get retry => 'Retry';

  @override
  String get preparingCamera => 'Preparing camera...';

  @override
  String get cameraError => 'Camera Error';

  @override
  String get initializationFailed => 'Initialization failed';

  @override
  String get unsupportedDevice => 'Unsupported device';

  @override
  String get permissionDenied => 'Permission denied';

  @override
  String get unknownError => 'Unknown error occurred';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get goBack => 'Go Back';

  @override
  String photosCount(int count) {
    return '$count photos';
  }

  @override
  String compositingProgress(int current, int total) {
    return 'Compositing $current of $total images...';
  }

  @override
  String get pleaseWait => 'Please wait...';

  @override
  String get imageInfo => 'Image Information';

  @override
  String get fileSize => 'File Size';

  @override
  String get dimensions => 'Dimensions';

  @override
  String get format => 'Format';

  @override
  String get quality => 'Quality';

  @override
  String get highQuality => 'High Quality (95%) - Large file size';

  @override
  String get mediumQuality => 'Medium Quality (75%) - Balanced';

  @override
  String get lowQuality => 'Low Quality (50%) - Small file size';

  @override
  String get gridBorderDescription => 'Display grid lines during shooting';

  @override
  String currentColor(String colorName) {
    return 'Current color: $colorName';
  }

  @override
  String borderWidthValue(String width) {
    return '${width}px';
  }

  @override
  String get appDescription =>
      'This app is operated through advertising revenue';

  @override
  String get teamName => 'GridShot Camera Team';

  @override
  String get white => 'White';

  @override
  String get black => 'Black';

  @override
  String get red => 'Red';

  @override
  String get blue => 'Blue';

  @override
  String get green => 'Green';

  @override
  String get yellow => 'Yellow';

  @override
  String get orange => 'Orange';

  @override
  String get purple => 'Purple';

  @override
  String get pink => 'Pink';

  @override
  String get cyan => 'Cyan';

  @override
  String get gray => 'Gray';

  @override
  String get magenta => 'Magenta';

  @override
  String get custom => 'Custom';

  @override
  String get lightColor => 'Light Color';

  @override
  String get darkColor => 'Dark Color';

  @override
  String get redTone => 'Red Tone';

  @override
  String get greenTone => 'Green Tone';

  @override
  String get blueTone => 'Blue Tone';
}
