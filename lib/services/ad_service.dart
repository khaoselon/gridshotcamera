import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';

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

  // ★ 新規追加：広告ロード状態管理
  bool _isBannerLoading = false;
  bool _isInterstitialLoading = false;
  bool _isRewardedLoading = false;

  // ★ 新規追加：メインスレッド負荷制御
  bool _isBackgroundMode = false;

  // インタースティシャル広告の表示間隔（分）
  static const int _interstitialCooldownMinutes = 3;
  static const int _interstitialShowThreshold = 2;

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
      debugPrint('★ AdService初期化開始（負荷軽減版）');

      if (Platform.isIOS) {
        _initializeIOS();
      } else if (Platform.isAndroid) {
        _initializeAndroid();
      }

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

  /// ★ 修正：バナー広告を作成（メインスレッド負荷軽減）
  Future<BannerAd?> createBannerAd({
    AdSize adSize = AdSize.banner,
    required Function(Ad ad) onAdLoaded,
    required Function(Ad ad, LoadAdError error) onAdFailedToLoad,
  }) async {
    if (!_isInitialized || _isBannerLoading) {
      debugPrint('★ AdServiceが初期化されていないか、既にロード中です');
      return null;
    }

    // ★ メインスレッド負荷軽減のため、バックグラウンドモード中は延期
    if (_isBackgroundMode) {
      debugPrint('★ バックグラウンドモード中のため、バナー広告ロードを延期');
      return null;
    }

    _isBannerLoading = true;

    try {
      _bannerAd?.dispose();

      // ★ 修正：バナー広告作成を非同期で実行（メインスレッド負荷軽減）
      await Future.delayed(const Duration(milliseconds: 100)); // UI更新を優先

      _bannerAd = BannerAd(
        adUnitId: _bannerAdUnitId,
        size: adSize,
        request: _createSecureAdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            _isBannerLoading = false;
            debugPrint('★ バナー広告の読み込み完了 (負荷軽減版)');
            onAdLoaded(ad);
          },
          onAdFailedToLoad: (ad, error) {
            _isBannerLoading = false;
            debugPrint('★ バナー広告の読み込み失敗: $error');
            ad.dispose();
            onAdFailedToLoad(ad, error);
          },
          onAdOpened: (ad) {
            debugPrint('★ バナー広告がタップされました');
          },
          onAdClosed: (ad) {
            debugPrint('★ バナー広告が閉じられました');
          },
          onAdImpression: (ad) {
            debugPrint('★ バナー広告インプレッション');
          },
        ),
      );

      // ★ 修正：バナー広告ロードをバックグラウンドで実行
      _loadBannerInBackground();
      return _bannerAd;
    } catch (e) {
      _isBannerLoading = false;
      debugPrint('★ バナー広告作成エラー: $e');
      return null;
    }
  }

  /// ★ 新規追加：バナー広告のバックグラウンドロード
  Future<void> _loadBannerInBackground() async {
    try {
      // メインスレッドの負荷を軽減するため、微小な遅延を挟む
      await Future.delayed(const Duration(milliseconds: 50));
      await _bannerAd!.load();
    } catch (e) {
      _isBannerLoading = false;
      debugPrint('★ バナー広告バックグラウンドロードエラー: $e');
    }
  }

  /// ★ 修正：インタースティシャル広告を読み込み（負荷軽減版）
  Future<void> loadInterstitialAd({
    Function? onAdLoaded,
    Function(LoadAdError)? onAdFailedToLoad,
  }) async {
    if (!_isInitialized || _isInterstitialLoading) return;

    // ★ バックグラウンドモード中は延期
    if (_isBackgroundMode) {
      debugPrint('★ バックグラウンドモード中のため、インタースティシャル広告ロードを延期');
      return;
    }

    _isInterstitialLoading = true;

    try {
      // ★ 修正：メインスレッド負荷軽減のための遅延実行
      await Future.delayed(const Duration(milliseconds: 200));

      await InterstitialAd.load(
        adUnitId: _interstitialAdUnitId,
        request: _createSecureAdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _isInterstitialLoading = false;
            _interstitialAd = ad;
            debugPrint('★ インタースティシャル広告の読み込み完了 (負荷軽減版)');
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

  /// ★ 修正：インタースティシャル広告を表示（BufferQueue問題回避）
  Future<void> showInterstitialAd({bool forceShow = false}) async {
    if (_interstitialAd == null) {
      debugPrint('★ インタースティシャル広告が準備されていません');
      // ★ 修正：次回に備えて非同期で読み込み開始（メインスレッド負荷軽減）
      _loadInterstitialAdInBackground();
      return;
    }

    if (!forceShow && !_shouldShowInterstitial()) {
      debugPrint('★ インタースティシャル広告の表示をスキップ（頻度制御）');
      return;
    }

    try {
      // ★ 修正：広告表示前に短時間待機（BufferQueue安定化）
      await Future.delayed(const Duration(milliseconds: 100));

      await _interstitialAd!.show();
      _lastInterstitialShow = DateTime.now();
      _interstitialShowCount = 0;
    } catch (e) {
      debugPrint('★ インタースティシャル広告の表示エラー: $e');
    }
  }

  /// ★ 新規追加：インタースティシャル広告の非同期ロード
  Future<void> _loadInterstitialAdInBackground() async {
    // バックグラウンドで次の広告を準備
    Future.delayed(const Duration(seconds: 1), () {
      if (!_isInterstitialLoading) {
        loadInterstitialAd();
      }
    });
  }

  /// ★ 修正：リワード広告を読み込み（負荷軽減版）
  Future<void> loadRewardedAd({
    Function? onAdLoaded,
    Function(LoadAdError)? onAdFailedToLoad,
  }) async {
    if (!_isInitialized || _isRewardedLoading) return;

    if (_isBackgroundMode) {
      debugPrint('★ バックグラウンドモード中のため、リワード広告ロードを延期');
      return;
    }

    _isRewardedLoading = true;

    try {
      // ★ 修正：メインスレッド負荷軽減のための遅延実行
      await Future.delayed(const Duration(milliseconds: 300));

      await RewardedAd.load(
        adUnitId: _rewardedAdUnitId,
        request: _createSecureAdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            _isRewardedLoading = false;
            _rewardedAd = ad;
            debugPrint('★ リワード広告の読み込み完了 (負荷軽減版)');
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

    try {
      // ★ 修正：広告表示前に短時間待機（BufferQueue安定化）
      await Future.delayed(const Duration(milliseconds: 100));

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

  /// インタースティシャル広告のコールバックを設定
  void _setInterstitialCallbacks() {
    _interstitialAd?.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        debugPrint('★ インタースティシャル広告が表示されました');
      },
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('★ インタースティシャル広告が閉じられました');
        ad.dispose();
        _interstitialAd = null;

        // ★ 修正：次の広告を非同期で事前読み込み（メインスレッド負荷軽減）
        _loadInterstitialAdInBackground();
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

  /// リワード広告のコールバックを設定
  void _setRewardedCallbacks() {
    _rewardedAd?.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        debugPrint('★ リワード広告が表示されました');
      },
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('★ リワード広告が閉じられました');
        ad.dispose();
        _rewardedAd = null;

        // ★ 修正：次の広告を非同期で事前読み込み
        Future.delayed(const Duration(seconds: 2), () {
          if (!_isRewardedLoading) {
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

  /// ★ 修正：アプリ再開時の処理（負荷軽減）
  void resumeAds() {
    debugPrint('★ 広告の再開処理（負荷軽減版）');
    _isBackgroundMode = false;

    // ★ バックグラウンドモードから復帰した際の広告再ロード（遅延実行）
    Future.delayed(const Duration(seconds: 2), () {
      if (_interstitialAd == null && !_isInterstitialLoading) {
        _loadInterstitialAdInBackground();
      }
    });
  }

  /// ★ 修正：アプリ一時停止時の処理（リソース節約）
  void pauseAds() {
    debugPrint('★ 広告の一時停止処理');
    _isBackgroundMode = true;

    // ★ バックグラウンド時はロード中の広告処理を停止
    // 実際の広告は破棄せず、ロード状態のみ管理
  }

  /// ★ 修正：リソースの解放（完全版）
  void dispose() {
    try {
      debugPrint('★ AdServiceのリソース解放開始');

      // ★ ロード状態をリセット
      _isBannerLoading = false;
      _isInterstitialLoading = false;
      _isRewardedLoading = false;

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
    debugPrint('=== AdService Status (負荷軽減版) ===');
    debugPrint('初期化状態: $_isInitialized');
    debugPrint('トラッキング許可: $_isTrackingAuthorized');
    debugPrint('バックグラウンドモード: $_isBackgroundMode');
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
