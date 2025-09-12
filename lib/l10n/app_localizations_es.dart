// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'GridShot Camera';

  @override
  String get homeTitle => 'Seleccionar Modo de Disparo';

  @override
  String get catalogMode => 'Disparo Catálogo';

  @override
  String get catalogModeDescription =>
      'Captura diferentes sujetos en cada celda de la cuadrícula para catalogar';

  @override
  String get impossibleMode => 'Fusión de Cuadrícula';

  @override
  String get impossibleModeDescription =>
      'Dispara la misma escena en orden de cuadrícula para crear composiciones imposibles';

  @override
  String get gridStyle => 'Estilo de Cuadrícula';

  @override
  String get grid2x2 => '2×2';

  @override
  String get grid2x3 => '2×3';

  @override
  String get grid3x2 => '3×2';

  @override
  String get grid3x3 => '3×3';

  @override
  String get startShooting => 'Comenzar Disparo';

  @override
  String get settings => 'Configuración';

  @override
  String get cameraTitle => 'Disparando';

  @override
  String currentPosition(String position) {
    return 'Actual: $position';
  }

  @override
  String get tapToShoot => 'Toca para Disparar';

  @override
  String get retake => 'Volver a Tomar';

  @override
  String get next => 'Siguiente';

  @override
  String get complete => 'Completar';

  @override
  String get previewTitle => 'Vista Previa';

  @override
  String get save => 'Guardar';

  @override
  String get share => 'Compartir';

  @override
  String get cancel => 'Cancelar';

  @override
  String get settingsTitle => 'Configuración';

  @override
  String get language => 'Idioma';

  @override
  String get japanese => '日本語';

  @override
  String get english => 'English';

  @override
  String get gridBorder => 'Borde de Cuadrícula';

  @override
  String get borderColor => 'Color del Borde';

  @override
  String get borderWidth => 'Grosor del Borde';

  @override
  String get imageQuality => 'Calidad de Imagen';

  @override
  String get high => 'Alta';

  @override
  String get medium => 'Media';

  @override
  String get low => 'Baja';

  @override
  String get adSettings => 'Configuración de Anuncios';

  @override
  String get showAds => 'Mostrar Anuncios';

  @override
  String get cameraPermission => 'Permiso de Cámara';

  @override
  String get cameraPermissionMessage =>
      'Se requiere acceso a la cámara para tomar fotos. Por favor, permite el acceso a la cámara en configuración.';

  @override
  String get storagePermission => 'Permiso de Almacenamiento';

  @override
  String get storagePermissionMessage =>
      'Se requiere acceso al almacenamiento para guardar fotos.';

  @override
  String get openSettings => 'Abrir Configuración';

  @override
  String get error => 'Error';

  @override
  String get saveSuccess => 'Imagen guardada exitosamente';

  @override
  String get saveFailed => 'Falló al guardar la imagen';

  @override
  String get shareSuccess => 'Imagen compartida exitosamente';

  @override
  String get loading => 'Cargando...';

  @override
  String get processing => 'Procesando...';

  @override
  String get compositing => 'Componiendo...';

  @override
  String get trackingPermissionTitle => 'Permiso de Seguimiento de App';

  @override
  String get trackingPermissionMessage =>
      'Permitir el seguimiento de la app a través de otras apps para personalizar anuncios.';

  @override
  String get allow => 'Permitir';

  @override
  String get dontAllow => 'No Permitir';

  @override
  String get selectPhotoStyle => 'Selecciona tu estilo de foto deseado';

  @override
  String get shootingMode => 'Modo de Disparo';

  @override
  String selectedGrid(String gridStyle) {
    return 'Seleccionado: $gridStyle';
  }

  @override
  String get checkingPermissions => 'Comprobando permisos...';

  @override
  String get confirmation => 'Confirmación';

  @override
  String get retakePhotos => '¿Quieres volver a tomar las fotos?';

  @override
  String get takeNewPhoto => 'Tomar Nueva Foto';

  @override
  String get shootingInfo => 'Información de Disparo';

  @override
  String get mode => 'Modo';

  @override
  String get gridStyleInfo => 'Estilo de Cuadrícula';

  @override
  String get photoCount => 'Cantidad de Fotos';

  @override
  String get shootingDate => 'Fecha de Disparo';

  @override
  String get saving => 'Guardando...';

  @override
  String get sharing => 'Compartiendo...';

  @override
  String get catalogModeDisplay => 'Disparo Catálogo';

  @override
  String get impossibleModeDisplay => 'Fusión de Cuadrícula';

  @override
  String get resetSettings => 'Restablecer Configuración';

  @override
  String get appInfo => 'Información de la App';

  @override
  String get version => 'Versión';

  @override
  String get developer => 'Desarrollador';

  @override
  String get aboutAds => 'Acerca de los Anuncios';

  @override
  String get selectBorderColor => 'Seleccionar Color del Borde';

  @override
  String get resetConfirmation =>
      '¿Restablecer todas las configuraciones a los valores predeterminados? Esta acción no se puede deshacer.';

  @override
  String get reset => 'Restablecer';

  @override
  String get settingsReset => 'La configuración ha sido restablecida';

  @override
  String get retry => 'Reintentar';

  @override
  String get preparingCamera => 'Preparando cámara...';

  @override
  String get cameraError => 'Error de Cámara';

  @override
  String get initializationFailed => 'La inicialización falló';

  @override
  String get unsupportedDevice => 'Dispositivo no soportado';

  @override
  String get permissionDenied => 'Permiso denegado';

  @override
  String get unknownError => 'Ocurrió un error desconocido';

  @override
  String get tryAgain => 'Intentar Nuevamente';

  @override
  String get goBack => 'Volver';

  @override
  String photosCount(int count) {
    return '$count fotos';
  }

  @override
  String compositingProgress(int current, int total) {
    return 'Componiendo $current de $total imágenes...';
  }

  @override
  String get pleaseWait => 'Por favor espere...';

  @override
  String get imageInfo => 'Información de Imagen';

  @override
  String get fileSize => 'Tamaño de Archivo';

  @override
  String get dimensions => 'Dimensiones';

  @override
  String get format => 'Formato';

  @override
  String get quality => 'Calidad';

  @override
  String get highQuality => 'Alta Calidad (95%) - Archivo grande';

  @override
  String get mediumQuality => 'Calidad Media (75%) - Equilibrado';

  @override
  String get lowQuality => 'Baja Calidad (50%) - Archivo pequeño';

  @override
  String get gridBorderDescription =>
      'Mostrar líneas de cuadrícula durante el disparo';

  @override
  String currentColor(String colorName) {
    return 'Color actual: $colorName';
  }

  @override
  String borderWidthValue(String width) {
    return '${width}px';
  }

  @override
  String get appDescription =>
      'Esta app es operada a través de ingresos publicitarios';

  @override
  String get teamName => 'Equipo GridShot Camera';

  @override
  String get white => 'Blanco';

  @override
  String get black => 'Negro';

  @override
  String get red => 'Rojo';

  @override
  String get blue => 'Azul';

  @override
  String get green => 'Verde';

  @override
  String get yellow => 'Amarillo';

  @override
  String get orange => 'Naranja';

  @override
  String get purple => 'Púrpura';

  @override
  String get pink => 'Rosa';

  @override
  String get cyan => 'Cian';

  @override
  String get gray => 'Gris';

  @override
  String get magenta => 'Magenta';

  @override
  String get custom => 'Personalizado';

  @override
  String get lightColor => 'Color Claro';

  @override
  String get darkColor => 'Color Oscuro';

  @override
  String get redTone => 'Tono Rojo';

  @override
  String get greenTone => 'Tono Verde';

  @override
  String get blueTone => 'Tono Azul';
}
