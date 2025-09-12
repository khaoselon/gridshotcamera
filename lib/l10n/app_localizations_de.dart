// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'GridShot Camera';

  @override
  String get homeTitle => 'Aufnahmemodus Auswählen';

  @override
  String get catalogMode => 'Katalog-Aufnahme';

  @override
  String get catalogModeDescription =>
      'Erfassen Sie verschiedene Motive in jeder Rasterzelle zum Katalogisieren';

  @override
  String get impossibleMode => 'Raster-Fusion';

  @override
  String get impossibleModeDescription =>
      'Fotografieren Sie die gleiche Szene in Rasterreihenfolge, um unmögliche Kompositionen zu erstellen';

  @override
  String get gridStyle => 'Rasterstil';

  @override
  String get grid2x2 => '2×2';

  @override
  String get grid2x3 => '2×3';

  @override
  String get grid3x2 => '3×2';

  @override
  String get grid3x3 => '3×3';

  @override
  String get startShooting => 'Aufnahme Starten';

  @override
  String get settings => 'Einstellungen';

  @override
  String get cameraTitle => 'Aufnahme';

  @override
  String currentPosition(String position) {
    return 'Aktuell: $position';
  }

  @override
  String get tapToShoot => 'Tippen zum Fotografieren';

  @override
  String get retake => 'Wiederholen';

  @override
  String get next => 'Weiter';

  @override
  String get complete => 'Fertig';

  @override
  String get previewTitle => 'Vorschau';

  @override
  String get save => 'Speichern';

  @override
  String get share => 'Teilen';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get language => 'Sprache';

  @override
  String get japanese => '日本語';

  @override
  String get english => 'English';

  @override
  String get gridBorder => 'Rasterrahmen';

  @override
  String get borderColor => 'Rahmenfarbe';

  @override
  String get borderWidth => 'Rahmenbreite';

  @override
  String get imageQuality => 'Bildqualität';

  @override
  String get high => 'Hoch';

  @override
  String get medium => 'Mittel';

  @override
  String get low => 'Niedrig';

  @override
  String get adSettings => 'Werbeeinstellungen';

  @override
  String get showAds => 'Werbung Anzeigen';

  @override
  String get cameraPermission => 'Kamera-Berechtigung';

  @override
  String get cameraPermissionMessage =>
      'Kamerazugriff ist erforderlich, um Fotos zu machen. Bitte erlauben Sie den Kamerazugriff in den Einstellungen.';

  @override
  String get storagePermission => 'Speicher-Berechtigung';

  @override
  String get storagePermissionMessage =>
      'Speicherzugriff ist erforderlich, um Fotos zu speichern.';

  @override
  String get openSettings => 'Einstellungen Öffnen';

  @override
  String get error => 'Fehler';

  @override
  String get saveSuccess => 'Bild erfolgreich gespeichert';

  @override
  String get saveFailed => 'Speichern des Bildes fehlgeschlagen';

  @override
  String get shareSuccess => 'Bild erfolgreich geteilt';

  @override
  String get loading => 'Laden...';

  @override
  String get processing => 'Verarbeitung...';

  @override
  String get compositing => 'Komposition...';

  @override
  String get trackingPermissionTitle => 'App-Tracking-Berechtigung';

  @override
  String get trackingPermissionMessage =>
      'Erlauben Sie App-Tracking über andere Apps, um Anzeigen zu personalisieren.';

  @override
  String get allow => 'Erlauben';

  @override
  String get dontAllow => 'Nicht Erlauben';

  @override
  String get selectPhotoStyle => 'Wählen Sie Ihren gewünschten Fotostil';

  @override
  String get shootingMode => 'Aufnahmemodus';

  @override
  String selectedGrid(String gridStyle) {
    return 'Ausgewählt: $gridStyle';
  }

  @override
  String get checkingPermissions => 'Berechtigungen werden überprüft...';

  @override
  String get confirmation => 'Bestätigung';

  @override
  String get retakePhotos => 'Möchten Sie die Fotos erneut aufnehmen?';

  @override
  String get takeNewPhoto => 'Neues Foto Aufnehmen';

  @override
  String get shootingInfo => 'Aufnahme-Informationen';

  @override
  String get mode => 'Modus';

  @override
  String get gridStyleInfo => 'Rasterstil';

  @override
  String get photoCount => 'Fotoanzahl';

  @override
  String get shootingDate => 'Aufnahmedatum';

  @override
  String get saving => 'Speichern...';

  @override
  String get sharing => 'Teilen...';

  @override
  String get catalogModeDisplay => 'Katalog-Aufnahme';

  @override
  String get impossibleModeDisplay => 'Raster-Fusion';

  @override
  String get resetSettings => 'Einstellungen Zurücksetzen';

  @override
  String get appInfo => 'App-Informationen';

  @override
  String get version => 'Version';

  @override
  String get developer => 'Entwickler';

  @override
  String get aboutAds => 'Über Werbung';

  @override
  String get selectBorderColor => 'Rahmenfarbe Auswählen';

  @override
  String get resetConfirmation =>
      'Alle Einstellungen auf Standardwerte zurücksetzen? Diese Aktion kann nicht rückgängig gemacht werden.';

  @override
  String get reset => 'Zurücksetzen';

  @override
  String get settingsReset => 'Einstellungen wurden zurückgesetzt';

  @override
  String get retry => 'Wiederholen';

  @override
  String get preparingCamera => 'Kamera wird vorbereitet...';

  @override
  String get cameraError => 'Kamera-Fehler';

  @override
  String get initializationFailed => 'Initialisierung fehlgeschlagen';

  @override
  String get unsupportedDevice => 'Nicht unterstütztes Gerät';

  @override
  String get permissionDenied => 'Berechtigung verweigert';

  @override
  String get unknownError => 'Unbekannter Fehler aufgetreten';

  @override
  String get tryAgain => 'Erneut Versuchen';

  @override
  String get goBack => 'Zurück';

  @override
  String photosCount(int count) {
    return '$count Fotos';
  }

  @override
  String compositingProgress(int current, int total) {
    return 'Komposition $current von $total Bildern...';
  }

  @override
  String get pleaseWait => 'Bitte warten...';

  @override
  String get imageInfo => 'Bildinformationen';

  @override
  String get fileSize => 'Dateigröße';

  @override
  String get dimensions => 'Abmessungen';

  @override
  String get format => 'Format';

  @override
  String get quality => 'Qualität';

  @override
  String get highQuality => 'Hohe Qualität (95%) - Große Dateigröße';

  @override
  String get mediumQuality => 'Mittlere Qualität (75%) - Ausgewogen';

  @override
  String get lowQuality => 'Niedrige Qualität (50%) - Kleine Dateigröße';

  @override
  String get gridBorderDescription =>
      'Rasterlinien während der Aufnahme anzeigen';

  @override
  String currentColor(String colorName) {
    return 'Aktuelle Farbe: $colorName';
  }

  @override
  String borderWidthValue(String width) {
    return '${width}px';
  }

  @override
  String get appDescription => 'Diese App wird durch Werbeeinnahmen betrieben';

  @override
  String get teamName => 'GridShot Camera Team';

  @override
  String get white => 'Weiß';

  @override
  String get black => 'Schwarz';

  @override
  String get red => 'Rot';

  @override
  String get blue => 'Blau';

  @override
  String get green => 'Grün';

  @override
  String get yellow => 'Gelb';

  @override
  String get orange => 'Orange';

  @override
  String get purple => 'Lila';

  @override
  String get pink => 'Rosa';

  @override
  String get cyan => 'Cyan';

  @override
  String get gray => 'Grau';

  @override
  String get magenta => 'Magenta';

  @override
  String get custom => 'Benutzerdefiniert';

  @override
  String get lightColor => 'Helle Farbe';

  @override
  String get darkColor => 'Dunkle Farbe';

  @override
  String get redTone => 'Rotton';

  @override
  String get greenTone => 'Grünton';

  @override
  String get blueTone => 'Blauton';
}
