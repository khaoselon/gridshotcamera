// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'GridShot Camera';

  @override
  String get homeTitle => '选择拍摄模式';

  @override
  String get catalogMode => '目录拍摄';

  @override
  String get catalogModeDescription => '在每个网格单元中拍摄不同主题进行编目';

  @override
  String get impossibleMode => '网格融合';

  @override
  String get impossibleModeDescription => '按网格顺序拍摄相同场景以创造不可能的构图';

  @override
  String get gridStyle => '网格样式';

  @override
  String get grid2x2 => '2×2';

  @override
  String get grid2x3 => '2×3';

  @override
  String get grid3x2 => '3×2';

  @override
  String get grid3x3 => '3×3';

  @override
  String get startShooting => '开始拍摄';

  @override
  String get settings => '设置';

  @override
  String get cameraTitle => '拍摄中';

  @override
  String currentPosition(String position) {
    return '当前：$position';
  }

  @override
  String get tapToShoot => '点击拍摄';

  @override
  String get retake => '重拍';

  @override
  String get next => '下一步';

  @override
  String get complete => '完成';

  @override
  String get previewTitle => '预览';

  @override
  String get save => '保存';

  @override
  String get share => '分享';

  @override
  String get cancel => '取消';

  @override
  String get settingsTitle => '设置';

  @override
  String get language => '语言';

  @override
  String get japanese => '日本語';

  @override
  String get english => 'English';

  @override
  String get gridBorder => '网格边框';

  @override
  String get borderColor => '边框颜色';

  @override
  String get borderWidth => '边框宽度';

  @override
  String get imageQuality => '图像质量';

  @override
  String get high => '高';

  @override
  String get medium => '中';

  @override
  String get low => '低';

  @override
  String get adSettings => '广告设置';

  @override
  String get showAds => '显示广告';

  @override
  String get cameraPermission => '相机权限';

  @override
  String get cameraPermissionMessage => '需要相机访问权限才能拍照。请在设置中允许相机访问。';

  @override
  String get storagePermission => '存储权限';

  @override
  String get storagePermissionMessage => '需要存储访问权限才能保存照片。';

  @override
  String get openSettings => '打开设置';

  @override
  String get error => '错误';

  @override
  String get saveSuccess => '图像已成功保存';

  @override
  String get saveFailed => '保存图像失败';

  @override
  String get shareSuccess => '图像已成功分享';

  @override
  String get loading => '加载中...';

  @override
  String get processing => '处理中...';

  @override
  String get compositing => '合成中...';

  @override
  String get trackingPermissionTitle => '应用程序跟踪权限';

  @override
  String get trackingPermissionMessage => '允许跨应用程序跟踪以个性化广告。';

  @override
  String get allow => '允许';

  @override
  String get dontAllow => '不允许';

  @override
  String get selectPhotoStyle => '选择您想要的照片风格';

  @override
  String get shootingMode => '拍摄模式';

  @override
  String selectedGrid(String gridStyle) {
    return '已选择：$gridStyle';
  }

  @override
  String get checkingPermissions => '检查权限中...';

  @override
  String get confirmation => '确认';

  @override
  String get retakePhotos => '您要重新拍摄照片吗？';

  @override
  String get takeNewPhoto => '拍摄新照片';

  @override
  String get shootingInfo => '拍摄信息';

  @override
  String get mode => '模式';

  @override
  String get gridStyleInfo => '网格样式';

  @override
  String get photoCount => '照片数量';

  @override
  String get shootingDate => '拍摄日期';

  @override
  String get saving => '保存中...';

  @override
  String get sharing => '分享中...';

  @override
  String get catalogModeDisplay => '目录拍摄';

  @override
  String get impossibleModeDisplay => '网格融合';

  @override
  String get resetSettings => '重置设置';

  @override
  String get appInfo => '应用程序信息';

  @override
  String get version => '版本';

  @override
  String get developer => '开发者';

  @override
  String get aboutAds => '关于广告';

  @override
  String get selectBorderColor => '选择边框颜色';

  @override
  String get resetConfirmation => '将所有设置重置为默认值？此操作无法撤销。';

  @override
  String get reset => '重置';

  @override
  String get settingsReset => '设置已重置';

  @override
  String get retry => '重试';

  @override
  String get preparingCamera => '准备相机中...';

  @override
  String get cameraError => '相机错误';

  @override
  String get initializationFailed => '初始化失败';

  @override
  String get unsupportedDevice => '不支持的设备';

  @override
  String get permissionDenied => '权限被拒绝';

  @override
  String get unknownError => '发生未知错误';

  @override
  String get tryAgain => '再试一次';

  @override
  String get goBack => '返回';

  @override
  String photosCount(int count) {
    return '$count 张照片';
  }

  @override
  String compositingProgress(int current, int total) {
    return '正在合成第 $current 张，共 $total 张图像...';
  }

  @override
  String get pleaseWait => '请稍候...';

  @override
  String get imageInfo => '图像信息';

  @override
  String get fileSize => '文件大小';

  @override
  String get dimensions => '尺寸';

  @override
  String get format => '格式';

  @override
  String get quality => '质量';

  @override
  String get highQuality => '高质量 (95%) - 文件较大';

  @override
  String get mediumQuality => '中质量 (75%) - 平衡';

  @override
  String get lowQuality => '低质量 (50%) - 文件较小';

  @override
  String get gridBorderDescription => '拍摄时显示网格线';

  @override
  String currentColor(String colorName) {
    return '当前颜色：$colorName';
  }

  @override
  String borderWidthValue(String width) {
    return '${width}px';
  }

  @override
  String get appDescription => '此应用程序通过广告收益运营';

  @override
  String get teamName => 'GridShot Camera 团队';

  @override
  String get white => '白色';

  @override
  String get black => '黑色';

  @override
  String get red => '红色';

  @override
  String get blue => '蓝色';

  @override
  String get green => '绿色';

  @override
  String get yellow => '黄色';

  @override
  String get orange => '橙色';

  @override
  String get purple => '紫色';

  @override
  String get pink => '粉红色';

  @override
  String get cyan => '青色';

  @override
  String get gray => '灰色';

  @override
  String get magenta => '洋红色';

  @override
  String get custom => '自定义';

  @override
  String get lightColor => '浅色';

  @override
  String get darkColor => '深色';

  @override
  String get redTone => '红色调';

  @override
  String get greenTone => '绿色调';

  @override
  String get blueTone => '蓝色调';

  @override
  String get systemDefault => '系统默认';
}

/// The translations for Chinese, using the Han script (`zh_Hant`).
class AppLocalizationsZhHant extends AppLocalizationsZh {
  AppLocalizationsZhHant(): super('zh_Hant');

  @override
  String get appTitle => 'GridShot Camera';

  @override
  String get homeTitle => '選擇拍攝模式';

  @override
  String get catalogMode => '目錄拍攝';

  @override
  String get catalogModeDescription => '在每個網格單元中拍攝不同主題進行編目';

  @override
  String get impossibleMode => '網格融合';

  @override
  String get impossibleModeDescription => '按網格順序拍攝相同場景以創造不可能的構圖';

  @override
  String get gridStyle => '網格樣式';

  @override
  String get grid2x2 => '2×2';

  @override
  String get grid2x3 => '2×3';

  @override
  String get grid3x2 => '3×2';

  @override
  String get grid3x3 => '3×3';

  @override
  String get startShooting => '開始拍攝';

  @override
  String get settings => '設定';

  @override
  String get cameraTitle => '拍攝中';

  @override
  String currentPosition(String position) {
    return '目前：$position';
  }

  @override
  String get tapToShoot => '點擊拍攝';

  @override
  String get retake => '重拍';

  @override
  String get next => '下一步';

  @override
  String get complete => '完成';

  @override
  String get previewTitle => '預覽';

  @override
  String get save => '儲存';

  @override
  String get share => '分享';

  @override
  String get cancel => '取消';

  @override
  String get settingsTitle => '設定';

  @override
  String get language => '語言';

  @override
  String get japanese => '日本語';

  @override
  String get english => 'English';

  @override
  String get gridBorder => '網格邊框';

  @override
  String get borderColor => '邊框顏色';

  @override
  String get borderWidth => '邊框寬度';

  @override
  String get imageQuality => '影像品質';

  @override
  String get high => '高';

  @override
  String get medium => '中';

  @override
  String get low => '低';

  @override
  String get adSettings => '廣告設定';

  @override
  String get showAds => '顯示廣告';

  @override
  String get cameraPermission => '相機權限';

  @override
  String get cameraPermissionMessage => '需要相機存取權限才能拍照。請在設定中允許相機存取。';

  @override
  String get storagePermission => '儲存權限';

  @override
  String get storagePermissionMessage => '需要儲存存取權限才能儲存照片。';

  @override
  String get openSettings => '開啟設定';

  @override
  String get error => '錯誤';

  @override
  String get saveSuccess => '影像已成功儲存';

  @override
  String get saveFailed => '儲存影像失敗';

  @override
  String get shareSuccess => '影像已成功分享';

  @override
  String get loading => '載入中...';

  @override
  String get processing => '處理中...';

  @override
  String get compositing => '合成中...';

  @override
  String get trackingPermissionTitle => '應用程式追蹤權限';

  @override
  String get trackingPermissionMessage => '允許跨應用程式追蹤以個人化廣告。';

  @override
  String get allow => '允許';

  @override
  String get dontAllow => '不允許';

  @override
  String get selectPhotoStyle => '選擇您想要的照片風格';

  @override
  String get shootingMode => '拍攝模式';

  @override
  String selectedGrid(String gridStyle) {
    return '已選擇：$gridStyle';
  }

  @override
  String get checkingPermissions => '檢查權限中...';

  @override
  String get confirmation => '確認';

  @override
  String get retakePhotos => '您要重新拍攝照片嗎？';

  @override
  String get takeNewPhoto => '拍攝新照片';

  @override
  String get shootingInfo => '拍攝資訊';

  @override
  String get mode => '模式';

  @override
  String get gridStyleInfo => '網格樣式';

  @override
  String get photoCount => '照片數量';

  @override
  String get shootingDate => '拍攝日期';

  @override
  String get saving => '儲存中...';

  @override
  String get sharing => '分享中...';

  @override
  String get catalogModeDisplay => '目錄拍攝';

  @override
  String get impossibleModeDisplay => '網格融合';

  @override
  String get resetSettings => '重設設定';

  @override
  String get appInfo => '應用程式資訊';

  @override
  String get version => '版本';

  @override
  String get developer => '開發者';

  @override
  String get aboutAds => '關於廣告';

  @override
  String get selectBorderColor => '選擇邊框顏色';

  @override
  String get resetConfirmation => '將所有設定重設為預設值？此動作無法復原。';

  @override
  String get reset => '重設';

  @override
  String get settingsReset => '設定已重設';

  @override
  String get retry => '重試';

  @override
  String get preparingCamera => '準備相機中...';

  @override
  String get cameraError => '相機錯誤';

  @override
  String get initializationFailed => '初始化失敗';

  @override
  String get unsupportedDevice => '不支援的裝置';

  @override
  String get permissionDenied => '權限被拒絕';

  @override
  String get unknownError => '發生未知錯誤';

  @override
  String get tryAgain => '再試一次';

  @override
  String get goBack => '返回';

  @override
  String photosCount(int count) {
    return '$count 張照片';
  }

  @override
  String compositingProgress(int current, int total) {
    return '正在合成第 $current 張，共 $total 張影像...';
  }

  @override
  String get pleaseWait => '請稍候...';

  @override
  String get imageInfo => '影像資訊';

  @override
  String get fileSize => '檔案大小';

  @override
  String get dimensions => '尺寸';

  @override
  String get format => '格式';

  @override
  String get quality => '品質';

  @override
  String get highQuality => '高品質 (95%) - 檔案較大';

  @override
  String get mediumQuality => '中品質 (75%) - 平衡';

  @override
  String get lowQuality => '低品質 (50%) - 檔案較小';

  @override
  String get gridBorderDescription => '拍攝時顯示網格線';

  @override
  String currentColor(String colorName) {
    return '目前顏色：$colorName';
  }

  @override
  String borderWidthValue(String width) {
    return '${width}px';
  }

  @override
  String get appDescription => '此應用程式透過廣告收益營運';

  @override
  String get teamName => 'GridShot Camera 團隊';

  @override
  String get white => '白色';

  @override
  String get black => '黑色';

  @override
  String get red => '紅色';

  @override
  String get blue => '藍色';

  @override
  String get green => '綠色';

  @override
  String get yellow => '黃色';

  @override
  String get orange => '橙色';

  @override
  String get purple => '紫色';

  @override
  String get pink => '粉紅色';

  @override
  String get cyan => '青色';

  @override
  String get gray => '灰色';

  @override
  String get magenta => '洋紅色';

  @override
  String get custom => '自訂';

  @override
  String get lightColor => '淺色';

  @override
  String get darkColor => '深色';

  @override
  String get redTone => '紅色調';

  @override
  String get greenTone => '綠色調';

  @override
  String get blueTone => '藍色調';

  @override
  String get systemDefault => '系統預設';
}
