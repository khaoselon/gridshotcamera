import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';

// ad_service.dart 先頭付近
const bool kDisableAds =
    bool.fromEnvironment('DISABLE_ADS', defaultValue: true);
// 例: DISABLE_ADS=true なら広告は完全ダミーになる

class AdService {
  static final AdService _instance = AdService._internal();
  static AdService get instance => _instance;

  AdService._internal();

  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;

  bool _isInitialized = false;
  bool _isTrackingAuthorized = false;
  int _interstitialShowCount = 0;
  DateTime? _lastInterstitialShow;

  // 広告ロード状態管理
  bool _isBannerLoading = false;
  bool _isInterstitialLoading = false;
  bool _isRewardedLoading = false;

  // ★ 修正：メインスレッド負荷制御（FrameEvents対策）
  bool _isBackgroundMode = false;
  bool _isHeavyProcessingActive = false; // 重い処理中（合成中など）
  DateTime? _lastAdDisplayTime; // 前回広告表示時刻

  // インタースティシャル広告の表示間隔（分）
  static const int _interstitialCooldownMinutes = 3;
  static const int _interstitialShowThreshold = 2;

  // ★ 修正：FrameEvents対策のタイミング制御定数
  static const Duration _minAdDisplayInterval = Duration(
    seconds: 2,
  ); // 最小広告表示間隔
  static const Duration _heavyProcessingDelay = Duration(
    milliseconds: 500,
  ); // 重い処理後の遅延

  // テスト広告ID（常にHTTPSベース）
  static const String _testBannerAdUnitId =
      'ca-app-pub-3940256099942544/6300978111';
  static const String _testInterstitialAdUnitId =
      'ca-app-pub-3940256099942544/1033173712';
  static const String _testRewardedAdUnitId =
      'ca-app-pub-3940256099942544/5224354917';

  // 本番広告ID
  static const String _prodBannerAdUnitId =
      'ca-app-pub-3940256099942544/6300978111';
  static const String _prodInterstitialAdUnitId =
      'ca-app-pub-3940256099942544/1033173712';
  static const String _prodRewardedAdUnitId =
      'ca-app-pub-3940256099942544/5224354917';

  /// 広告サービスを初期化（メインスレッド負荷軽減版）
  void initialize() {
    if (_isInitialized) return;
    try {
      if (kDisableAds) {
        _isInitialized = true;
        debugPrint('★ [DummyAds] AdService 初期化（広告は無効化されています）');
        return; // ここで終了（SDKもATTも呼ばない）
      }
      // ↓ ここから先は元の処理（iOS/Android初期化など）
      debugPrint('★ AdService初期化開始（FrameEvents対策版）');
      if (Platform.isIOS)
        _initializeIOS();
      else if (Platform.isAndroid) _initializeAndroid();
      _isInitialized = true;
      debugPrint('★ AdService初期化完了');
    } catch (e) {
      debugPrint('★ AdService初期化エラー: $e');
      _isInitialized = false;
    }
  }

  /// iOS固有の初期化
  void _initializeIOS() {
    debugPrint('★ iOS向けAdService設定を適用');
  }

  /// Android固有の初期化
  void _initializeAndroid() {
    debugPrint('★ Android向けAdService設定を適用');
  }

  /// ★ 新規追加：重い処理状態の管理（FrameEvents対策）
  void setHeavyProcessingActive(bool active) {
    _isHeavyProcessingActive = active;
    debugPrint('★ 重い処理状態変更: $active (FrameEvents対策)');
  }

  /// ★ 修正：表示タイミング制御付きのチェック
  bool _canDisplayAd() {
    // バックグラウンドモード中は表示しない
    if (_isBackgroundMode) {
      debugPrint('★ 広告表示スキップ: バックグラウンドモード中');
      return false;
    }

    // 重い処理中は表示しない（FrameEvents回避）
    if (_isHeavyProcessingActive) {
      debugPrint('★ 広告表示スキップ: 重い処理中（FrameEvents対策）');
      return false;
    }

    // 最小表示間隔チェック（PlatformView attach負荷分散）
    if (_lastAdDisplayTime != null) {
      final timeSinceLastDisplay = DateTime.now().difference(
        _lastAdDisplayTime!,
      );
      if (timeSinceLastDisplay < _minAdDisplayInterval) {
        debugPrint(
          '★ 広告表示スキップ: 最小間隔未満 (${timeSinceLastDisplay.inMilliseconds}ms)',
        );
        return false;
      }
    }

    return true;
  }

  /// ★ 修正：表示タイミング記録
  void _recordAdDisplayTime() {
    _lastAdDisplayTime = DateTime.now();
  }

  /// トラッキング許可状況を更新
  void updateTrackingStatus(TrackingStatus status) {
    _isTrackingAuthorized = status == TrackingStatus.authorized;
    debugPrint('★ トラッキング許可状況: $_isTrackingAuthorized');

    _updateAdRequestConfiguration();
  }

  /// 広告リクエスト設定を更新
  void _updateAdRequestConfiguration() {
    try {
      if (!_isTrackingAuthorized) {
        debugPrint('★ 非パーソナライズド広告モードに設定');
      }
    } catch (e) {
      debugPrint('★ 広告設定更新エラー: $e');
    }
  }

  /// 広告IDを取得
  String get _bannerAdUnitId {
    if (kDebugMode) return _testBannerAdUnitId;
    if (Platform.isAndroid) return _prodBannerAdUnitId;
    if (Platform.isIOS) return _prodBannerAdUnitId;
    return _testBannerAdUnitId;
  }

  String get _interstitialAdUnitId {
    if (kDebugMode) return _testInterstitialAdUnitId;
    if (Platform.isAndroid) return _prodInterstitialAdUnitId;
    if (Platform.isIOS) return _prodInterstitialAdUnitId;
    return _testInterstitialAdUnitId;
  }

  String get _rewardedAdUnitId {
    if (kDebugMode) return _testRewardedAdUnitId;
    if (Platform.isAndroid) return _prodRewardedAdUnitId;
    if (Platform.isIOS) return _prodRewardedAdUnitId;
    return _testRewardedAdUnitId;
  }

  /// ★ 修正：FrameEvents対策バナー広告作成（段階的ロード）
  Future<BannerAd?> createBannerAd({
    AdSize adSize = AdSize.banner,
    required Function(Ad ad) onAdLoaded,
    required Function(Ad ad, LoadAdError error) onAdFailedToLoad,
  }) async {
    // ★ ここを追加：ダミー時は即スキップ
    if (kDisableAds) {
      debugPrint('★ [DummyAds] createBannerAd: スキップ');
      return null;
    }

    if (!_isInitialized || _isBannerLoading) {
      debugPrint('★ AdServiceが初期化されていないか、既にロード中です');
      return null;
    }

    if (!_canDisplayAd()) {
      debugPrint('★ バナー広告作成をスキップ（FrameEvents対策）');
      return null;
    }

    _isBannerLoading = true;

    try {
      _bannerAd?.dispose();
      await Future.delayed(const Duration(milliseconds: 200));

      _bannerAd = BannerAd(
        adUnitId: _bannerAdUnitId,
        size: adSize,
        request: _createSecureAdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            _isBannerLoading = false;
            _recordAdDisplayTime();
            debugPrint('★ バナー広告の読み込み完了 (FrameEvents対策版)');
            onAdLoaded(ad);
          },
          onAdFailedToLoad: (ad, error) {
            _isBannerLoading = false;
            debugPrint('★ バナー広告の読み込み失敗: $error');
            ad.dispose();
            onAdFailedToLoad(ad, error);
          },
          onAdOpened: (ad) => debugPrint('★ バナー広告がタップされました'),
          onAdClosed: (ad) => debugPrint('★ バナー広告が閉じられました'),
          onAdImpression: (ad) => debugPrint('★ バナー広告インプレッション'),
        ),
      );

      await _loadBannerWithFrameControl();
      return _bannerAd;
    } catch (e) {
      _isBannerLoading = false;
      debugPrint('★ バナー広告作成エラー: $e');
      return null;
    }
  }

  /// ★ 新規追加：Frame制御付きバナーロード
  Future<void> _loadBannerWithFrameControl() async {
    try {
      // メインスレッドの負荷を軽減するため、フレーム間で実行
      await Future.delayed(const Duration(milliseconds: 100));

      debugPrint('★ バナー広告ロード開始（Frame制御付き）');
      await _bannerAd!.load();

      // ロード完了後の安定化待機
      await Future.delayed(const Duration(milliseconds: 50));
    } catch (e) {
      _isBannerLoading = false;
      debugPrint('★ Frame制御付きバナーロードエラー: $e');
    }
  }

  /// ★ 修正：FrameEvents対策インタースティシャル広告読み込み
  Future<void> loadInterstitialAd({
    Function? onAdLoaded,
    Function(LoadAdError)? onAdFailedToLoad,
  }) async {
    if (!_isInitialized || _isInterstitialLoading) return;

    // ★ 表示タイミングチェック
    if (!_canDisplayAd()) {
      debugPrint('★ インタースティシャル広告ロードをスキップ（FrameEvents対策）');
      return;
    }

    _isInterstitialLoading = true;

    try {
      // ★ 修正：重い処理後の場合は追加遅延
      if (_isHeavyProcessingActive) {
        await Future.delayed(_heavyProcessingDelay);
      } else {
        await Future.delayed(const Duration(milliseconds: 300));
      }

      await InterstitialAd.load(
        adUnitId: _interstitialAdUnitId,
        request: _createSecureAdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _isInterstitialLoading = false;
            _interstitialAd = ad;
            debugPrint('★ インタースティシャル広告の読み込み完了 (FrameEvents対策版)');
            onAdLoaded?.call();

            _setInterstitialCallbacks();
          },
          onAdFailedToLoad: (error) {
            _isInterstitialLoading = false;
            debugPrint('★ インタースティシャル広告の読み込み失敗: $error');
            _interstitialAd = null;
            onAdFailedToLoad?.call(error);
          },
        ),
      );
    } catch (e) {
      _isInterstitialLoading = false;
      debugPrint('★ インタースティシャル広告読み込みエラー: $e');
    }
  }

  /// ★ 修正：FrameEvents対策インタースティシャル広告表示
  Future<void> showInterstitialAd({bool forceShow = false}) async {
    if (_interstitialAd == null) {
      debugPrint('★ インタースティシャル広告が準備されていません');
      // 次回に備えて非同期で読み込み開始
      _loadInterstitialAdInBackground();
      return;
    }

    if (!forceShow && !_shouldShowInterstitial()) {
      debugPrint('★ インタースティシャル広告の表示をスキップ（頻度制御）');
      return;
    }

    // ★ 表示タイミングチェック（FrameEvents対策）
    if (!_canDisplayAd()) {
      debugPrint('★ インタースティシャル広告表示をスキップ（FrameEvents対策）');
      return;
    }

    try {
      // ★ 修正：広告表示前の安定化待機（BufferQueue + FrameEvents対策）
      await Future.delayed(const Duration(milliseconds: 200));

      _recordAdDisplayTime(); // ★ 表示時刻記録
      await _interstitialAd!.show();
      _lastInterstitialShow = DateTime.now();
      _interstitialShowCount = 0;
    } catch (e) {
      debugPrint('★ インタースティシャル広告の表示エラー: $e');
    }
  }

  /// インタースティシャル広告の非同期ロード
  Future<void> _loadInterstitialAdInBackground() async {
    // ★ 修正：FrameEvents対策で遅延を拡張
    Future.delayed(const Duration(seconds: 2), () {
      if (!_isInterstitialLoading && _canDisplayAd()) {
        loadInterstitialAd();
      }
    });
  }

  /// ★ 修正：FrameEvents対策リワード広告読み込み
  Future<void> loadRewardedAd({
    Function? onAdLoaded,
    Function(LoadAdError)? onAdFailedToLoad,
  }) async {
    if (!_isInitialized || _isRewardedLoading) return;

    if (!_canDisplayAd()) {
      debugPrint('★ リワード広告ロードをスキップ（FrameEvents対策）');
      return;
    }

    _isRewardedLoading = true;

    try {
      // ★ 修正：段階的遅延実行
      await Future.delayed(const Duration(milliseconds: 400));

      await RewardedAd.load(
        adUnitId: _rewardedAdUnitId,
        request: _createSecureAdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            _isRewardedLoading = false;
            _rewardedAd = ad;
            debugPrint('★ リワード広告の読み込み完了 (FrameEvents対策版)');
            onAdLoaded?.call();

            _setRewardedCallbacks();
          },
          onAdFailedToLoad: (error) {
            _isRewardedLoading = false;
            debugPrint('★ リワード広告の読み込み失敗: $error');
            _rewardedAd = null;
            onAdFailedToLoad?.call(error);
          },
        ),
      );
    } catch (e) {
      _isRewardedLoading = false;
      debugPrint('★ リワード広告読み込みエラー: $e');
    }
  }

  /// リワード広告を表示
  Future<void> showRewardedAd({
    required Function(RewardItem) onUserEarnedReward,
  }) async {
    if (_rewardedAd == null) {
      debugPrint('★ リワード広告が準備されていません');
      return;
    }

    // ★ 表示タイミングチェック
    if (!_canDisplayAd()) {
      debugPrint('★ リワード広告表示をスキップ（FrameEvents対策）');
      return;
    }

    try {
      // ★ 修正：広告表示前の安定化待機
      await Future.delayed(const Duration(milliseconds: 200));

      _recordAdDisplayTime(); // ★ 表示時刻記録
      await _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          debugPrint('★ リワード獲得: ${reward.amount} ${reward.type}');
          onUserEarnedReward(reward);
        },
      );
    } catch (e) {
      debugPrint('★ リワード広告の表示エラー: $e');
    }
  }

  /// インタースティシャル広告を表示すべきかチェック
  bool _shouldShowInterstitial() {
    _interstitialShowCount++;
    if (_interstitialShowCount < _interstitialShowThreshold) {
      return false;
    }

    if (_lastInterstitialShow != null) {
      final timeSinceLastShow = DateTime.now().difference(
        _lastInterstitialShow!,
      );
      if (timeSinceLastShow.inMinutes < _interstitialCooldownMinutes) {
        return false;
      }
    }

    return true;
  }

  /// ★ 修正：FrameEvents対策付きインタースティシャルコールバック
  void _setInterstitialCallbacks() {
    _interstitialAd?.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        debugPrint('★ インタースティシャル広告が表示されました');
      },
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('★ インタースティシャル広告が閉じられました');
        ad.dispose();
        _interstitialAd = null;

        // ★ 修正：広告終了後のFrame安定化待機
        Future.delayed(const Duration(milliseconds: 300), () {
          _loadInterstitialAdInBackground();
        });
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('★ インタースティシャル広告の表示に失敗: $error');
        ad.dispose();
        _interstitialAd = null;
      },
      onAdImpression: (ad) {
        debugPrint('★ インタースティシャル広告インプレッション');
      },
    );
  }

  /// ★ 修正：FrameEvents対策付きリワードコールバック
  void _setRewardedCallbacks() {
    _rewardedAd?.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        debugPrint('★ リワード広告が表示されました');
      },
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('★ リワード広告が閉じられました');
        ad.dispose();
        _rewardedAd = null;

        // ★ 修正：Frame安定化後に次の広告準備
        Future.delayed(const Duration(milliseconds: 400), () {
          if (!_isRewardedLoading && _canDisplayAd()) {
            loadRewardedAd();
          }
        });
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('★ リワード広告の表示に失敗: $error');
        ad.dispose();
        _rewardedAd = null;
      },
      onAdImpression: (ad) {
        debugPrint('★ リワード広告インプレッション');
      },
    );
  }

  /// セキュアな広告リクエストを作成
  AdRequest _createSecureAdRequest() {
    return AdRequest(
      keywords: ['camera', 'photo', 'photography', 'grid'],
      nonPersonalizedAds: !_isTrackingAuthorized,
    );
  }

  /// ★ 修正：FrameEvents対策アプリ再開処理
  void resumeAds() {
    debugPrint('★ 広告の再開処理（FrameEvents対策版）');
    _isBackgroundMode = false;

    // ★ バックグラウンド復帰時の段階的広告再ロード
    Future.delayed(const Duration(seconds: 3), () {
      if (_interstitialAd == null &&
          !_isInterstitialLoading &&
          _canDisplayAd()) {
        _loadInterstitialAdInBackground();
      }
    });
  }

  /// アプリ一時停止時の処理
  void pauseAds() {
    debugPrint('★ 広告の一時停止処理');
    _isBackgroundMode = true;

    // ★ 重い処理状態もリセット
    _isHeavyProcessingActive = false;
  }

  /// ★ 修正：完全リソース解放
  void dispose() {
    try {
      debugPrint('★ AdServiceのリソース解放開始（FrameEvents対策版）');

      // ロード状態をリセット
      _isBannerLoading = false;
      _isInterstitialLoading = false;
      _isRewardedLoading = false;
      _isHeavyProcessingActive = false;

      _bannerAd?.dispose();
      _interstitialAd?.dispose();
      _rewardedAd?.dispose();

      _bannerAd = null;
      _interstitialAd = null;
      _rewardedAd = null;

      debugPrint('★ AdServiceのリソースを解放しました');
    } catch (e) {
      debugPrint('★ AdServiceリソース解放エラー: $e');
    }
  }

  /// デバッグ情報を出力
  void debugPrintStatus() {
    debugPrint('=== AdService Status (FrameEvents対策版) ===');
    debugPrint('初期化状態: $_isInitialized');
    debugPrint('トラッキング許可: $_isTrackingAuthorized');
    debugPrint('バックグラウンドモード: $_isBackgroundMode');
    debugPrint('重い処理中: $_isHeavyProcessingActive');
    debugPrint('前回広告表示: $_lastAdDisplayTime');
    debugPrint(
      'バナー広告: ${_bannerAd != null ? '読み込み済み' : '未読み込み'} (ロード中: $_isBannerLoading)',
    );
    debugPrint(
      'インタースティシャル: ${_interstitialAd != null ? '読み込み済み' : '未読み込み'} (ロード中: $_isInterstitialLoading)',
    );
    debugPrint(
      'リワード広告: ${_rewardedAd != null ? '読み込み済み' : '未読み込み'} (ロード中: $_isRewardedLoading)',
    );
    debugPrint('===============================');
  }
}
