// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'GridShot Camera';

  @override
  String get homeTitle => 'Seleziona Modalità di Scatto';

  @override
  String get catalogMode => 'Scatto Catalogo';

  @override
  String get catalogModeDescription => 'Cattura soggetti diversi in ogni cella della griglia per catalogare';

  @override
  String get impossibleMode => 'Fusione Griglia';

  @override
  String get impossibleModeDescription => 'Scatta la stessa scena in ordine di griglia per creare composizioni impossibili';

  @override
  String get gridStyle => 'Stile Griglia';

  @override
  String get grid2x2 => '2×2';

  @override
  String get grid2x3 => '2×3';

  @override
  String get grid3x2 => '3×2';

  @override
  String get grid3x3 => '3×3';

  @override
  String get startShooting => 'Inizia Scatto';

  @override
  String get settings => 'Impostazioni';

  @override
  String get cameraTitle => 'Scattando';

  @override
  String currentPosition(String position) {
    return 'Attuale: $position';
  }

  @override
  String get tapToShoot => 'Tocca per Scattare';

  @override
  String get retake => 'Riprendi';

  @override
  String get next => 'Avanti';

  @override
  String get complete => 'Completato';

  @override
  String get previewTitle => 'Anteprima';

  @override
  String get save => 'Salva';

  @override
  String get share => 'Condividi';

  @override
  String get cancel => 'Annulla';

  @override
  String get settingsTitle => 'Impostazioni';

  @override
  String get language => 'Lingua';

  @override
  String get japanese => '日本語';

  @override
  String get english => 'English';

  @override
  String get gridBorder => 'Bordo Griglia';

  @override
  String get borderColor => 'Colore Bordo';

  @override
  String get borderWidth => 'Spessore Bordo';

  @override
  String get imageQuality => 'Qualità Immagine';

  @override
  String get high => 'Alta';

  @override
  String get medium => 'Media';

  @override
  String get low => 'Bassa';

  @override
  String get adSettings => 'Impostazioni Pubblicità';

  @override
  String get showAds => 'Mostra Pubblicità';

  @override
  String get cameraPermission => 'Permesso Fotocamera';

  @override
  String get cameraPermissionMessage => 'È necessario l\'accesso alla fotocamera per scattare foto. Consenti l\'accesso alla fotocamera nelle impostazioni.';

  @override
  String get storagePermission => 'Permesso Archiviazione';

  @override
  String get storagePermissionMessage => 'È necessario l\'accesso all\'archiviazione per salvare le foto.';

  @override
  String get openSettings => 'Apri Impostazioni';

  @override
  String get error => 'Errore';

  @override
  String get saveSuccess => 'Immagine salvata con successo';

  @override
  String get saveFailed => 'Salvataggio immagine fallito';

  @override
  String get shareSuccess => 'Immagine condivisa con successo';

  @override
  String get loading => 'Caricamento...';

  @override
  String get processing => 'Elaborazione...';

  @override
  String get compositing => 'Composizione...';

  @override
  String get trackingPermissionTitle => 'Permesso Tracciamento App';

  @override
  String get trackingPermissionMessage => 'Consenti il tracciamento dell\'app attraverso altre app per personalizzare gli annunci.';

  @override
  String get allow => 'Consenti';

  @override
  String get dontAllow => 'Non Consentire';

  @override
  String get selectPhotoStyle => 'Seleziona lo stile di foto desiderato';

  @override
  String get shootingMode => 'Modalità di Scatto';

  @override
  String selectedGrid(String gridStyle) {
    return 'Selezionato: $gridStyle';
  }

  @override
  String get checkingPermissions => 'Controllo permessi...';

  @override
  String get confirmation => 'Conferma';

  @override
  String get retakePhotos => 'Vuoi rifare le foto?';

  @override
  String get takeNewPhoto => 'Scatta Nuova Foto';

  @override
  String get shootingInfo => 'Informazioni di Scatto';

  @override
  String get mode => 'Modalità';

  @override
  String get gridStyleInfo => 'Stile Griglia';

  @override
  String get photoCount => 'Numero Foto';

  @override
  String get shootingDate => 'Data di Scatto';

  @override
  String get saving => 'Salvando...';

  @override
  String get sharing => 'Condividendo...';

  @override
  String get catalogModeDisplay => 'Scatto Catalogo';

  @override
  String get impossibleModeDisplay => 'Fusione Griglia';

  @override
  String get resetSettings => 'Ripristina Impostazioni';

  @override
  String get appInfo => 'Informazioni App';

  @override
  String get version => 'Versione';

  @override
  String get developer => 'Sviluppatore';

  @override
  String get aboutAds => 'Informazioni su Pubblicità';

  @override
  String get selectBorderColor => 'Seleziona Colore Bordo';

  @override
  String get resetConfirmation => 'Ripristinare tutte le impostazioni ai valori predefiniti? Questa azione non può essere annullata.';

  @override
  String get reset => 'Ripristina';

  @override
  String get settingsReset => 'Le impostazioni sono state ripristinate';

  @override
  String get retry => 'Riprova';

  @override
  String get preparingCamera => 'Preparando fotocamera...';

  @override
  String get cameraError => 'Errore Fotocamera';

  @override
  String get initializationFailed => 'Inizializzazione fallita';

  @override
  String get unsupportedDevice => 'Dispositivo non supportato';

  @override
  String get permissionDenied => 'Permesso negato';

  @override
  String get unknownError => 'Si è verificato un errore sconosciuto';

  @override
  String get tryAgain => 'Riprova';

  @override
  String get goBack => 'Torna Indietro';

  @override
  String photosCount(int count) {
    return '$count foto';
  }

  @override
  String compositingProgress(int current, int total) {
    return 'Composizione $current di $total immagini...';
  }

  @override
  String get pleaseWait => 'Attendere prego...';

  @override
  String get imageInfo => 'Informazioni Immagine';

  @override
  String get fileSize => 'Dimensione File';

  @override
  String get dimensions => 'Dimensioni';

  @override
  String get format => 'Formato';

  @override
  String get quality => 'Qualità';

  @override
  String get highQuality => 'Alta Qualità (95%) - File di grandi dimensioni';

  @override
  String get mediumQuality => 'Qualità Media (75%) - Bilanciato';

  @override
  String get lowQuality => 'Bassa Qualità (50%) - File di piccole dimensioni';

  @override
  String get gridBorderDescription => 'Visualizza le linee della griglia durante lo scatto';

  @override
  String currentColor(String colorName) {
    return 'Colore attuale: $colorName';
  }

  @override
  String borderWidthValue(String width) {
    return '${width}px';
  }

  @override
  String get appDescription => 'Questa app è gestita tramite ricavi pubblicitari';

  @override
  String get teamName => 'Team GridShot Camera';

  @override
  String get white => 'Bianco';

  @override
  String get black => 'Nero';

  @override
  String get red => 'Rosso';

  @override
  String get blue => 'Blu';

  @override
  String get green => 'Verde';

  @override
  String get yellow => 'Giallo';

  @override
  String get orange => 'Arancione';

  @override
  String get purple => 'Viola';

  @override
  String get pink => 'Rosa';

  @override
  String get cyan => 'Ciano';

  @override
  String get gray => 'Grigio';

  @override
  String get magenta => 'Magenta';

  @override
  String get custom => 'Personalizzato';

  @override
  String get lightColor => 'Colore Chiaro';

  @override
  String get darkColor => 'Colore Scuro';

  @override
  String get redTone => 'Tonalità Rossa';

  @override
  String get greenTone => 'Tonalità Verde';

  @override
  String get blueTone => 'Tonalità Blu';

  @override
  String get systemDefault => 'Predefinito di Sistema';
}
