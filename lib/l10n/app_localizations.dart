import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'GridShot Camera'**
  String get appTitle;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Shooting Mode'**
  String get homeTitle;

  /// No description provided for @catalogMode.
  ///
  /// In en, this message translates to:
  /// **'Catalog Mode'**
  String get catalogMode;

  /// No description provided for @catalogModeDescription.
  ///
  /// In en, this message translates to:
  /// **'Capture different subjects in each grid cell for cataloging'**
  String get catalogModeDescription;

  /// No description provided for @impossibleMode.
  ///
  /// In en, this message translates to:
  /// **'Impossible Composite Mode'**
  String get impossibleMode;

  /// No description provided for @impossibleModeDescription.
  ///
  /// In en, this message translates to:
  /// **'Shoot the same scene in grid order to create impossible compositions'**
  String get impossibleModeDescription;

  /// No description provided for @gridStyle.
  ///
  /// In en, this message translates to:
  /// **'Grid Style'**
  String get gridStyle;

  /// No description provided for @grid2x2.
  ///
  /// In en, this message translates to:
  /// **'2×2'**
  String get grid2x2;

  /// No description provided for @grid2x3.
  ///
  /// In en, this message translates to:
  /// **'2×3'**
  String get grid2x3;

  /// No description provided for @grid3x2.
  ///
  /// In en, this message translates to:
  /// **'3×2'**
  String get grid3x2;

  /// No description provided for @grid3x3.
  ///
  /// In en, this message translates to:
  /// **'3×3'**
  String get grid3x3;

  /// No description provided for @startShooting.
  ///
  /// In en, this message translates to:
  /// **'Start Shooting'**
  String get startShooting;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @cameraTitle.
  ///
  /// In en, this message translates to:
  /// **'Shooting'**
  String get cameraTitle;

  /// No description provided for @currentPosition.
  ///
  /// In en, this message translates to:
  /// **'Current: {position}'**
  String currentPosition(String position);

  /// No description provided for @tapToShoot.
  ///
  /// In en, this message translates to:
  /// **'Tap to Shoot'**
  String get tapToShoot;

  /// No description provided for @retake.
  ///
  /// In en, this message translates to:
  /// **'Retake'**
  String get retake;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @complete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get complete;

  /// No description provided for @previewTitle.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get previewTitle;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @japanese.
  ///
  /// In en, this message translates to:
  /// **'日本語'**
  String get japanese;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @gridBorder.
  ///
  /// In en, this message translates to:
  /// **'Grid Border'**
  String get gridBorder;

  /// No description provided for @borderColor.
  ///
  /// In en, this message translates to:
  /// **'Border Color'**
  String get borderColor;

  /// No description provided for @borderWidth.
  ///
  /// In en, this message translates to:
  /// **'Border Width'**
  String get borderWidth;

  /// No description provided for @imageQuality.
  ///
  /// In en, this message translates to:
  /// **'Image Quality'**
  String get imageQuality;

  /// No description provided for @high.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get high;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// No description provided for @low.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get low;

  /// No description provided for @adSettings.
  ///
  /// In en, this message translates to:
  /// **'Ad Settings'**
  String get adSettings;

  /// No description provided for @showAds.
  ///
  /// In en, this message translates to:
  /// **'Show Ads'**
  String get showAds;

  /// No description provided for @cameraPermission.
  ///
  /// In en, this message translates to:
  /// **'Camera Permission'**
  String get cameraPermission;

  /// No description provided for @cameraPermissionMessage.
  ///
  /// In en, this message translates to:
  /// **'Camera access is required to take photos. Please allow camera access in settings.'**
  String get cameraPermissionMessage;

  /// No description provided for @storagePermission.
  ///
  /// In en, this message translates to:
  /// **'Storage Permission'**
  String get storagePermission;

  /// No description provided for @storagePermissionMessage.
  ///
  /// In en, this message translates to:
  /// **'Storage access is required to save photos.'**
  String get storagePermissionMessage;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @saveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Image saved successfully'**
  String get saveSuccess;

  /// No description provided for @saveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save image'**
  String get saveFailed;

  /// No description provided for @shareSuccess.
  ///
  /// In en, this message translates to:
  /// **'Image shared successfully'**
  String get shareSuccess;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @processing.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get processing;

  /// No description provided for @compositing.
  ///
  /// In en, this message translates to:
  /// **'Compositing...'**
  String get compositing;

  /// No description provided for @trackingPermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'App Tracking Permission'**
  String get trackingPermissionTitle;

  /// No description provided for @trackingPermissionMessage.
  ///
  /// In en, this message translates to:
  /// **'Allow app tracking across other apps to personalize ads.'**
  String get trackingPermissionMessage;

  /// No description provided for @allow.
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get allow;

  /// No description provided for @dontAllow.
  ///
  /// In en, this message translates to:
  /// **'Don\'t Allow'**
  String get dontAllow;

  /// No description provided for @selectPhotoStyle.
  ///
  /// In en, this message translates to:
  /// **'Select your desired photo style'**
  String get selectPhotoStyle;

  /// No description provided for @shootingMode.
  ///
  /// In en, this message translates to:
  /// **'Shooting Mode'**
  String get shootingMode;

  /// No description provided for @selectedGrid.
  ///
  /// In en, this message translates to:
  /// **'Selected: {gridStyle}'**
  String selectedGrid(String gridStyle);

  /// No description provided for @checkingPermissions.
  ///
  /// In en, this message translates to:
  /// **'Checking permissions...'**
  String get checkingPermissions;

  /// No description provided for @confirmation.
  ///
  /// In en, this message translates to:
  /// **'Confirmation'**
  String get confirmation;

  /// No description provided for @retakePhotos.
  ///
  /// In en, this message translates to:
  /// **'Do you want to retake the photos?'**
  String get retakePhotos;

  /// No description provided for @takeNewPhoto.
  ///
  /// In en, this message translates to:
  /// **'Take New Photo'**
  String get takeNewPhoto;

  /// No description provided for @shootingInfo.
  ///
  /// In en, this message translates to:
  /// **'Shooting Information'**
  String get shootingInfo;

  /// No description provided for @mode.
  ///
  /// In en, this message translates to:
  /// **'Mode'**
  String get mode;

  /// No description provided for @gridStyleInfo.
  ///
  /// In en, this message translates to:
  /// **'Grid Style'**
  String get gridStyleInfo;

  /// No description provided for @photoCount.
  ///
  /// In en, this message translates to:
  /// **'Photo Count'**
  String get photoCount;

  /// No description provided for @shootingDate.
  ///
  /// In en, this message translates to:
  /// **'Shooting Date'**
  String get shootingDate;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get saving;

  /// No description provided for @sharing.
  ///
  /// In en, this message translates to:
  /// **'Sharing...'**
  String get sharing;

  /// No description provided for @catalogModeDisplay.
  ///
  /// In en, this message translates to:
  /// **'Catalog Mode'**
  String get catalogModeDisplay;

  /// No description provided for @impossibleModeDisplay.
  ///
  /// In en, this message translates to:
  /// **'Impossible Composite Mode'**
  String get impossibleModeDisplay;

  /// No description provided for @resetSettings.
  ///
  /// In en, this message translates to:
  /// **'Reset Settings'**
  String get resetSettings;

  /// No description provided for @appInfo.
  ///
  /// In en, this message translates to:
  /// **'App Information'**
  String get appInfo;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @developer.
  ///
  /// In en, this message translates to:
  /// **'Developer'**
  String get developer;

  /// No description provided for @aboutAds.
  ///
  /// In en, this message translates to:
  /// **'About Ads'**
  String get aboutAds;

  /// No description provided for @selectBorderColor.
  ///
  /// In en, this message translates to:
  /// **'Select Border Color'**
  String get selectBorderColor;

  /// No description provided for @resetConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Reset all settings to default values? This action cannot be undone.'**
  String get resetConfirmation;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @settingsReset.
  ///
  /// In en, this message translates to:
  /// **'Settings have been reset'**
  String get settingsReset;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @preparingCamera.
  ///
  /// In en, this message translates to:
  /// **'Preparing camera...'**
  String get preparingCamera;

  /// No description provided for @cameraError.
  ///
  /// In en, this message translates to:
  /// **'Camera Error'**
  String get cameraError;

  /// No description provided for @initializationFailed.
  ///
  /// In en, this message translates to:
  /// **'Initialization failed'**
  String get initializationFailed;

  /// No description provided for @unsupportedDevice.
  ///
  /// In en, this message translates to:
  /// **'Unsupported device'**
  String get unsupportedDevice;

  /// No description provided for @permissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Permission denied'**
  String get permissionDenied;

  /// No description provided for @unknownError.
  ///
  /// In en, this message translates to:
  /// **'Unknown error occurred'**
  String get unknownError;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @goBack.
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get goBack;

  /// No description provided for @photosCount.
  ///
  /// In en, this message translates to:
  /// **'{count} photos'**
  String photosCount(int count);

  /// No description provided for @compositingProgress.
  ///
  /// In en, this message translates to:
  /// **'Compositing {current} of {total} images...'**
  String compositingProgress(int current, int total);

  /// No description provided for @pleaseWait.
  ///
  /// In en, this message translates to:
  /// **'Please wait...'**
  String get pleaseWait;

  /// No description provided for @imageInfo.
  ///
  /// In en, this message translates to:
  /// **'Image Information'**
  String get imageInfo;

  /// No description provided for @fileSize.
  ///
  /// In en, this message translates to:
  /// **'File Size'**
  String get fileSize;

  /// No description provided for @dimensions.
  ///
  /// In en, this message translates to:
  /// **'Dimensions'**
  String get dimensions;

  /// No description provided for @format.
  ///
  /// In en, this message translates to:
  /// **'Format'**
  String get format;

  /// No description provided for @quality.
  ///
  /// In en, this message translates to:
  /// **'Quality'**
  String get quality;

  /// No description provided for @highQuality.
  ///
  /// In en, this message translates to:
  /// **'High Quality (95%) - Large file size'**
  String get highQuality;

  /// No description provided for @mediumQuality.
  ///
  /// In en, this message translates to:
  /// **'Medium Quality (75%) - Balanced'**
  String get mediumQuality;

  /// No description provided for @lowQuality.
  ///
  /// In en, this message translates to:
  /// **'Low Quality (50%) - Small file size'**
  String get lowQuality;

  /// No description provided for @gridBorderDescription.
  ///
  /// In en, this message translates to:
  /// **'Display grid lines during shooting'**
  String get gridBorderDescription;

  /// No description provided for @currentColor.
  ///
  /// In en, this message translates to:
  /// **'Current color: {colorName}'**
  String currentColor(String colorName);

  /// No description provided for @borderWidthValue.
  ///
  /// In en, this message translates to:
  /// **'{width}px'**
  String borderWidthValue(String width);

  /// No description provided for @appDescription.
  ///
  /// In en, this message translates to:
  /// **'This app is operated through advertising revenue'**
  String get appDescription;

  /// No description provided for @teamName.
  ///
  /// In en, this message translates to:
  /// **'GridShot Camera Team'**
  String get teamName;

  /// No description provided for @white.
  ///
  /// In en, this message translates to:
  /// **'White'**
  String get white;

  /// No description provided for @black.
  ///
  /// In en, this message translates to:
  /// **'Black'**
  String get black;

  /// No description provided for @red.
  ///
  /// In en, this message translates to:
  /// **'Red'**
  String get red;

  /// No description provided for @blue.
  ///
  /// In en, this message translates to:
  /// **'Blue'**
  String get blue;

  /// No description provided for @green.
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get green;

  /// No description provided for @yellow.
  ///
  /// In en, this message translates to:
  /// **'Yellow'**
  String get yellow;

  /// No description provided for @orange.
  ///
  /// In en, this message translates to:
  /// **'Orange'**
  String get orange;

  /// No description provided for @purple.
  ///
  /// In en, this message translates to:
  /// **'Purple'**
  String get purple;

  /// No description provided for @pink.
  ///
  /// In en, this message translates to:
  /// **'Pink'**
  String get pink;

  /// No description provided for @cyan.
  ///
  /// In en, this message translates to:
  /// **'Cyan'**
  String get cyan;

  /// No description provided for @gray.
  ///
  /// In en, this message translates to:
  /// **'Gray'**
  String get gray;

  /// No description provided for @magenta.
  ///
  /// In en, this message translates to:
  /// **'Magenta'**
  String get magenta;

  /// No description provided for @custom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get custom;

  /// No description provided for @lightColor.
  ///
  /// In en, this message translates to:
  /// **'Light Color'**
  String get lightColor;

  /// No description provided for @darkColor.
  ///
  /// In en, this message translates to:
  /// **'Dark Color'**
  String get darkColor;

  /// No description provided for @redTone.
  ///
  /// In en, this message translates to:
  /// **'Red Tone'**
  String get redTone;

  /// No description provided for @greenTone.
  ///
  /// In en, this message translates to:
  /// **'Green Tone'**
  String get greenTone;

  /// No description provided for @blueTone.
  ///
  /// In en, this message translates to:
  /// **'Blue Tone'**
  String get blueTone;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
