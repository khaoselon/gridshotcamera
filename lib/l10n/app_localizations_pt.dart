// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'GridShot Camera';

  @override
  String get homeTitle => 'Selecionar Modo de Captura';

  @override
  String get catalogMode => 'Captura Catálogo';

  @override
  String get catalogModeDescription => 'Capture diferentes assuntos em cada célula da grade para catalogar';

  @override
  String get impossibleMode => 'Fusão de Grade';

  @override
  String get impossibleModeDescription => 'Fotografe a mesma cena em ordem de grade para criar composições impossíveis';

  @override
  String get gridStyle => 'Estilo de Grade';

  @override
  String get grid2x2 => '2×2';

  @override
  String get grid2x3 => '2×3';

  @override
  String get grid3x2 => '3×2';

  @override
  String get grid3x3 => '3×3';

  @override
  String get startShooting => 'Iniciar Captura';

  @override
  String get settings => 'Configurações';

  @override
  String get cameraTitle => 'Capturando';

  @override
  String currentPosition(String position) {
    return 'Atual: $position';
  }

  @override
  String get tapToShoot => 'Toque para Fotografar';

  @override
  String get retake => 'Refazer';

  @override
  String get next => 'Próximo';

  @override
  String get complete => 'Concluir';

  @override
  String get previewTitle => 'Visualizar';

  @override
  String get save => 'Salvar';

  @override
  String get share => 'Compartilhar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get settingsTitle => 'Configurações';

  @override
  String get language => 'Idioma';

  @override
  String get japanese => '日本語';

  @override
  String get english => 'English';

  @override
  String get gridBorder => 'Borda da Grade';

  @override
  String get borderColor => 'Cor da Borda';

  @override
  String get borderWidth => 'Espessura da Borda';

  @override
  String get imageQuality => 'Qualidade da Imagem';

  @override
  String get high => 'Alta';

  @override
  String get medium => 'Média';

  @override
  String get low => 'Baixa';

  @override
  String get adSettings => 'Configurações de Anúncios';

  @override
  String get showAds => 'Mostrar Anúncios';

  @override
  String get cameraPermission => 'Permissão da Câmera';

  @override
  String get cameraPermissionMessage => 'Acesso à câmera é necessário para tirar fotos. Por favor, permita o acesso à câmera nas configurações.';

  @override
  String get storagePermission => 'Permissão de Armazenamento';

  @override
  String get storagePermissionMessage => 'Acesso ao armazenamento é necessário para salvar fotos.';

  @override
  String get openSettings => 'Abrir Configurações';

  @override
  String get error => 'Erro';

  @override
  String get saveSuccess => 'Imagem salva com sucesso';

  @override
  String get saveFailed => 'Falha ao salvar a imagem';

  @override
  String get shareSuccess => 'Imagem compartilhada com sucesso';

  @override
  String get loading => 'Carregando...';

  @override
  String get processing => 'Processando...';

  @override
  String get compositing => 'Compondo...';

  @override
  String get trackingPermissionTitle => 'Permissão de Rastreamento de App';

  @override
  String get trackingPermissionMessage => 'Permitir rastreamento do app através de outros apps para personalizar anúncios.';

  @override
  String get allow => 'Permitir';

  @override
  String get dontAllow => 'Não Permitir';

  @override
  String get selectPhotoStyle => 'Selecione o estilo de foto desejado';

  @override
  String get shootingMode => 'Modo de Captura';

  @override
  String selectedGrid(String gridStyle) {
    return 'Selecionado: $gridStyle';
  }

  @override
  String get checkingPermissions => 'Verificando permissões...';

  @override
  String get confirmation => 'Confirmação';

  @override
  String get retakePhotos => 'Deseja refazer as fotos?';

  @override
  String get takeNewPhoto => 'Tirar Nova Foto';

  @override
  String get shootingInfo => 'Informações de Captura';

  @override
  String get mode => 'Modo';

  @override
  String get gridStyleInfo => 'Estilo de Grade';

  @override
  String get photoCount => 'Quantidade de Fotos';

  @override
  String get shootingDate => 'Data de Captura';

  @override
  String get saving => 'Salvando...';

  @override
  String get sharing => 'Compartilhando...';

  @override
  String get catalogModeDisplay => 'Captura Catálogo';

  @override
  String get impossibleModeDisplay => 'Fusão de Grade';

  @override
  String get resetSettings => 'Redefinir Configurações';

  @override
  String get appInfo => 'Informações do App';

  @override
  String get version => 'Versão';

  @override
  String get developer => 'Desenvolvedor';

  @override
  String get aboutAds => 'Sobre Anúncios';

  @override
  String get selectBorderColor => 'Selecionar Cor da Borda';

  @override
  String get resetConfirmation => 'Redefinir todas as configurações para os valores padrão? Esta ação não pode ser desfeita.';

  @override
  String get reset => 'Redefinir';

  @override
  String get settingsReset => 'Configurações foram redefinidas';

  @override
  String get retry => 'Tentar Novamente';

  @override
  String get preparingCamera => 'Preparando câmera...';

  @override
  String get cameraError => 'Erro da Câmera';

  @override
  String get initializationFailed => 'Inicialização falhou';

  @override
  String get unsupportedDevice => 'Dispositivo não suportado';

  @override
  String get permissionDenied => 'Permissão negada';

  @override
  String get unknownError => 'Ocorreu um erro desconhecido';

  @override
  String get tryAgain => 'Tentar Novamente';

  @override
  String get goBack => 'Voltar';

  @override
  String photosCount(int count) {
    return '$count fotos';
  }

  @override
  String compositingProgress(int current, int total) {
    return 'Compondo $current de $total imagens...';
  }

  @override
  String get pleaseWait => 'Por favor aguarde...';

  @override
  String get imageInfo => 'Informações da Imagem';

  @override
  String get fileSize => 'Tamanho do Arquivo';

  @override
  String get dimensions => 'Dimensões';

  @override
  String get format => 'Formato';

  @override
  String get quality => 'Qualidade';

  @override
  String get highQuality => 'Alta Qualidade (95%) - Arquivo grande';

  @override
  String get mediumQuality => 'Qualidade Média (75%) - Equilibrado';

  @override
  String get lowQuality => 'Baixa Qualidade (50%) - Arquivo pequeno';

  @override
  String get gridBorderDescription => 'Exibir linhas da grade durante a captura';

  @override
  String currentColor(String colorName) {
    return 'Cor atual: $colorName';
  }

  @override
  String borderWidthValue(String width) {
    return '${width}px';
  }

  @override
  String get appDescription => 'Este app é operado através de receitas publicitárias';

  @override
  String get teamName => 'Equipe GridShot Camera';

  @override
  String get white => 'Branco';

  @override
  String get black => 'Preto';

  @override
  String get red => 'Vermelho';

  @override
  String get blue => 'Azul';

  @override
  String get green => 'Verde';

  @override
  String get yellow => 'Amarelo';

  @override
  String get orange => 'Laranja';

  @override
  String get purple => 'Roxo';

  @override
  String get pink => 'Rosa';

  @override
  String get cyan => 'Ciano';

  @override
  String get gray => 'Cinza';

  @override
  String get magenta => 'Magenta';

  @override
  String get custom => 'Personalizado';

  @override
  String get lightColor => 'Cor Clara';

  @override
  String get darkColor => 'Cor Escura';

  @override
  String get redTone => 'Tom Vermelho';

  @override
  String get greenTone => 'Tom Verde';

  @override
  String get blueTone => 'Tom Azul';

  @override
  String get systemDefault => 'Padrão do Sistema';
}
