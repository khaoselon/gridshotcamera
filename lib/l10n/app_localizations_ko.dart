// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => 'GridShot Camera';

  @override
  String get homeTitle => '촬영 모드 선택';

  @override
  String get catalogMode => '카탈로그 촬영';

  @override
  String get catalogModeDescription => '각 격자 셀에 다른 피사체를 담아 카탈로그화';

  @override
  String get impossibleMode => '그리드 합성';

  @override
  String get impossibleModeDescription => '같은 장면을 격자 순서로 촬영하여 불가능한 합성 창조';

  @override
  String get gridStyle => '그리드 스타일';

  @override
  String get grid2x2 => '2×2';

  @override
  String get grid2x3 => '2×3';

  @override
  String get grid3x2 => '3×2';

  @override
  String get grid3x3 => '3×3';

  @override
  String get startShooting => '촬영 시작';

  @override
  String get settings => '설정';

  @override
  String get cameraTitle => '촬영 중';

  @override
  String currentPosition(String position) {
    return '현재: $position';
  }

  @override
  String get tapToShoot => '탭하여 촬영';

  @override
  String get retake => '재촬영';

  @override
  String get next => '다음';

  @override
  String get complete => '완료';

  @override
  String get previewTitle => '미리보기';

  @override
  String get save => '저장';

  @override
  String get share => '공유';

  @override
  String get cancel => '취소';

  @override
  String get settingsTitle => '설정';

  @override
  String get language => '언어';

  @override
  String get japanese => '日本語';

  @override
  String get english => 'English';

  @override
  String get gridBorder => '그리드 테두리';

  @override
  String get borderColor => '테두리 색상';

  @override
  String get borderWidth => '테두리 두께';

  @override
  String get imageQuality => '이미지 품질';

  @override
  String get high => '높음';

  @override
  String get medium => '중간';

  @override
  String get low => '낮음';

  @override
  String get adSettings => '광고 설정';

  @override
  String get showAds => '광고 표시';

  @override
  String get cameraPermission => '카메라 권한';

  @override
  String get cameraPermissionMessage =>
      '사진을 촬영하려면 카메라 접근이 필요합니다. 설정에서 카메라 접근을 허용해 주세요.';

  @override
  String get storagePermission => '저장소 권한';

  @override
  String get storagePermissionMessage => '사진을 저장하려면 저장소 접근이 필요합니다.';

  @override
  String get openSettings => '설정 열기';

  @override
  String get error => '오류';

  @override
  String get saveSuccess => '이미지가 성공적으로 저장되었습니다';

  @override
  String get saveFailed => '이미지 저장에 실패했습니다';

  @override
  String get shareSuccess => '이미지가 성공적으로 공유되었습니다';

  @override
  String get loading => '로딩 중...';

  @override
  String get processing => '처리 중...';

  @override
  String get compositing => '합성 중...';

  @override
  String get trackingPermissionTitle => '앱 추적 권한';

  @override
  String get trackingPermissionMessage => '광고 개인화를 위해 다른 앱에서의 앱 추적을 허용합니다.';

  @override
  String get allow => '허용';

  @override
  String get dontAllow => '허용 안 함';

  @override
  String get selectPhotoStyle => '원하는 사진 스타일을 선택하세요';

  @override
  String get shootingMode => '촬영 모드';

  @override
  String selectedGrid(String gridStyle) {
    return '선택됨: $gridStyle';
  }

  @override
  String get checkingPermissions => '권한 확인 중...';

  @override
  String get confirmation => '확인';

  @override
  String get retakePhotos => '사진을 다시 촬영하시겠습니까?';

  @override
  String get takeNewPhoto => '새 사진 촬영';

  @override
  String get shootingInfo => '촬영 정보';

  @override
  String get mode => '모드';

  @override
  String get gridStyleInfo => '그리드 스타일';

  @override
  String get photoCount => '사진 수';

  @override
  String get shootingDate => '촬영 날짜';

  @override
  String get saving => '저장 중...';

  @override
  String get sharing => '공유 중...';

  @override
  String get catalogModeDisplay => '카탈로그 촬영';

  @override
  String get impossibleModeDisplay => '그리드 합성';

  @override
  String get resetSettings => '설정 재설정';

  @override
  String get appInfo => '앱 정보';

  @override
  String get version => '버전';

  @override
  String get developer => '개발자';

  @override
  String get aboutAds => '광고 정보';

  @override
  String get selectBorderColor => '테두리 색상 선택';

  @override
  String get resetConfirmation => '모든 설정을 기본값으로 재설정하시겠습니까? 이 작업은 취소할 수 없습니다.';

  @override
  String get reset => '재설정';

  @override
  String get settingsReset => '설정이 재설정되었습니다';

  @override
  String get retry => '재시도';

  @override
  String get preparingCamera => '카메라 준비 중...';

  @override
  String get cameraError => '카메라 오류';

  @override
  String get initializationFailed => '초기화 실패';

  @override
  String get unsupportedDevice => '지원되지 않는 기기';

  @override
  String get permissionDenied => '권한 거부됨';

  @override
  String get unknownError => '알 수 없는 오류가 발생했습니다';

  @override
  String get tryAgain => '다시 시도';

  @override
  String get goBack => '뒤로';

  @override
  String photosCount(int count) {
    return '${count}장의 사진';
  }

  @override
  String compositingProgress(int current, int total) {
    return '$total개 중 $current번째 이미지 합성 중...';
  }

  @override
  String get pleaseWait => '잠시만 기다려 주세요...';

  @override
  String get imageInfo => '이미지 정보';

  @override
  String get fileSize => '파일 크기';

  @override
  String get dimensions => '크기';

  @override
  String get format => '형식';

  @override
  String get quality => '품질';

  @override
  String get highQuality => '최고 품질 (95%) - 큰 파일 크기';

  @override
  String get mediumQuality => '중간 품질 (75%) - 균형';

  @override
  String get lowQuality => '낮은 품질 (50%) - 작은 파일 크기';

  @override
  String get gridBorderDescription => '촬영 중 그리드 선 표시';

  @override
  String currentColor(String colorName) {
    return '현재 색상: $colorName';
  }

  @override
  String borderWidthValue(String width) {
    return '${width}px';
  }

  @override
  String get appDescription => '이 앱은 광고 수익을 통해 운영됩니다';

  @override
  String get teamName => 'GridShot Camera 팀';

  @override
  String get white => '흰색';

  @override
  String get black => '검은색';

  @override
  String get red => '빨간색';

  @override
  String get blue => '파란색';

  @override
  String get green => '초록색';

  @override
  String get yellow => '노란색';

  @override
  String get orange => '주황색';

  @override
  String get purple => '보라색';

  @override
  String get pink => '분홍색';

  @override
  String get cyan => '청록색';

  @override
  String get gray => '회색';

  @override
  String get magenta => '자홍색';

  @override
  String get custom => '사용자 정의';

  @override
  String get lightColor => '밝은 색상';

  @override
  String get darkColor => '어두운 색상';

  @override
  String get redTone => '빨간 계열';

  @override
  String get greenTone => '초록 계열';

  @override
  String get blueTone => '파란 계열';
}
