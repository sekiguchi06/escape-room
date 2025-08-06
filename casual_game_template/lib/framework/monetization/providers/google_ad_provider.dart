import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../monetization_system.dart';

/// Google Mobile Ads SDKを使用したAdProviderの実装
class GoogleAdProvider implements AdProvider {
  // Google Mobile Ads テストID
  static const String _testBannerId = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testInterstitialId = 'ca-app-pub-3940256099942544/1033173712';
  static const String _testRewardedId = 'ca-app-pub-3940256099942544/5224354917';
  
  MonetizationConfiguration? _config;
  final List<void Function(AdEventData)> _listeners = [];
  final Map<AdType, dynamic> _loadedAds = {};
  final Map<AdType, DateTime> _lastShownTime = {};
  
  // 各広告タイプのインスタンス
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  
  @override
  Future<bool> initialize(MonetizationConfiguration config) async {
    _config = config;
    
    try {
      // Google Mobile Ads SDKの初期化
      final mobileAds = MobileAds.instance;
      await mobileAds.initialize();
      
      if (config.debugMode) {
        debugPrint('GoogleAdProvider initialized (testMode: ${config.testMode})');
      }
      
      return true;
    } catch (e) {
      debugPrint('GoogleAdProvider initialization failed: $e');
      return false;
    }
  }
  
  @override
  Future<AdResult> loadAd(AdType adType, {String? adId}) async {
    if (_config?.adsDisabled == true || _config?.enabledAdTypes[adType] != true) {
      return AdResult.failed;
    }
    
    try {
      switch (adType) {
        case AdType.banner:
          return await _loadBannerAd(adId);
        case AdType.interstitial:
          return await _loadInterstitialAd(adId);
        case AdType.rewarded:
          return await _loadRewardedAd(adId);
        case AdType.native:
        case AdType.appOpen:
          // 未実装の広告タイプ
          return AdResult.failed;
      }
    } catch (e) {
      _notifyListeners(AdEventData(
        adType: adType,
        result: AdResult.failed,
        adId: adId,
        errorMessage: e.toString(),
        timestamp: DateTime.now(),
      ));
      return AdResult.failed;
    }
  }
  
  Future<AdResult> _loadBannerAd(String? adId) async {
    final adUnitId = _getAdUnitId(AdType.banner, adId);
    
    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          _loadedAds[AdType.banner] = ad;
          _notifyListeners(AdEventData(
            adType: AdType.banner,
            result: AdResult.loaded,
            adId: adId,
            timestamp: DateTime.now(),
          ));
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _notifyListeners(AdEventData(
            adType: AdType.banner,
            result: AdResult.failed,
            adId: adId,
            errorMessage: error.message,
            timestamp: DateTime.now(),
          ));
        },
        onAdClicked: (ad) {
          _notifyListeners(AdEventData(
            adType: AdType.banner,
            result: AdResult.clicked,
            adId: adId,
            timestamp: DateTime.now(),
          ));
        },
      ),
    );
    
    await _bannerAd!.load();
    return AdResult.loaded;
  }
  
  Future<AdResult> _loadInterstitialAd(String? adId) async {
    final adUnitId = _getAdUnitId(AdType.interstitial, adId);
    
    await InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _loadedAds[AdType.interstitial] = ad;
          
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) {
              _notifyListeners(AdEventData(
                adType: AdType.interstitial,
                result: AdResult.shown,
                adId: adId,
                timestamp: DateTime.now(),
              ));
            },
            onAdDismissedFullScreenContent: (ad) {
              _notifyListeners(AdEventData(
                adType: AdType.interstitial,
                result: AdResult.closed,
                adId: adId,
                timestamp: DateTime.now(),
              ));
              ad.dispose();
              _loadedAds.remove(AdType.interstitial);
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              _notifyListeners(AdEventData(
                adType: AdType.interstitial,
                result: AdResult.failed,
                adId: adId,
                errorMessage: error.message,
                timestamp: DateTime.now(),
              ));
              ad.dispose();
              _loadedAds.remove(AdType.interstitial);
            },
            onAdClicked: (ad) {
              _notifyListeners(AdEventData(
                adType: AdType.interstitial,
                result: AdResult.clicked,
                adId: adId,
                timestamp: DateTime.now(),
              ));
            },
          );
          
          _notifyListeners(AdEventData(
            adType: AdType.interstitial,
            result: AdResult.loaded,
            adId: adId,
            timestamp: DateTime.now(),
          ));
        },
        onAdFailedToLoad: (error) {
          _notifyListeners(AdEventData(
            adType: AdType.interstitial,
            result: AdResult.failed,
            adId: adId,
            errorMessage: error.message,
            timestamp: DateTime.now(),
          ));
        },
      ),
    );
    
    return AdResult.loaded;
  }
  
  Future<AdResult> _loadRewardedAd(String? adId) async {
    final adUnitId = _getAdUnitId(AdType.rewarded, adId);
    
    await RewardedAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _loadedAds[AdType.rewarded] = ad;
          
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) {
              _notifyListeners(AdEventData(
                adType: AdType.rewarded,
                result: AdResult.shown,
                adId: adId,
                timestamp: DateTime.now(),
              ));
            },
            onAdDismissedFullScreenContent: (ad) {
              _notifyListeners(AdEventData(
                adType: AdType.rewarded,
                result: AdResult.closed,
                adId: adId,
                timestamp: DateTime.now(),
              ));
              ad.dispose();
              _loadedAds.remove(AdType.rewarded);
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              _notifyListeners(AdEventData(
                adType: AdType.rewarded,
                result: AdResult.failed,
                adId: adId,
                errorMessage: error.message,
                timestamp: DateTime.now(),
              ));
              ad.dispose();
              _loadedAds.remove(AdType.rewarded);
            },
            onAdClicked: (ad) {
              _notifyListeners(AdEventData(
                adType: AdType.rewarded,
                result: AdResult.clicked,
                adId: adId,
                timestamp: DateTime.now(),
              ));
            },
          );
          
          _notifyListeners(AdEventData(
            adType: AdType.rewarded,
            result: AdResult.loaded,
            adId: adId,
            timestamp: DateTime.now(),
          ));
        },
        onAdFailedToLoad: (error) {
          _notifyListeners(AdEventData(
            adType: AdType.rewarded,
            result: AdResult.failed,
            adId: adId,
            errorMessage: error.message,
            timestamp: DateTime.now(),
          ));
        },
      ),
    );
    
    return AdResult.loaded;
  }
  
  @override
  Future<AdResult> showAd(AdType adType, {String? adId}) async {
    if (_config?.adsDisabled == true || _config?.enabledAdTypes[adType] != true) {
      return AdResult.failed;
    }
    
    // 準備チェック
    if (!await isAdReady(adType, adId: adId)) {
      return AdResult.notReady;
    }
    
    // 最小間隔チェック
    final lastShown = _lastShownTime[adType];
    if (lastShown != null) {
      final elapsed = DateTime.now().difference(lastShown).inSeconds;
      if (elapsed < _config!.minAdInterval) {
        return AdResult.failed;
      }
    }
    
    try {
      switch (adType) {
        case AdType.banner:
          return _showBannerAd(adId);
        case AdType.interstitial:
          return await _showInterstitialAd(adId);
        case AdType.rewarded:
          return await _showRewardedAd(adId);
        case AdType.native:
        case AdType.appOpen:
          return AdResult.failed;
      }
    } catch (e) {
      _notifyListeners(AdEventData(
        adType: adType,
        result: AdResult.failed,
        adId: adId,
        errorMessage: e.toString(),
        timestamp: DateTime.now(),
      ));
      return AdResult.failed;
    }
  }
  
  AdResult _showBannerAd(String? adId) {
    // バナー広告はUI側で表示される想定
    _lastShownTime[AdType.banner] = DateTime.now();
    return AdResult.shown;
  }
  
  Future<AdResult> _showInterstitialAd(String? adId) async {
    final ad = _interstitialAd;
    if (ad == null) return AdResult.notReady;
    
    await ad.show();
    _lastShownTime[AdType.interstitial] = DateTime.now();
    return AdResult.shown;
  }
  
  Future<AdResult> _showRewardedAd(String? adId) async {
    final ad = _rewardedAd;
    if (ad == null) return AdResult.notReady;
    
    await ad.show(onUserEarnedReward: (ad, reward) {
      _notifyListeners(AdEventData(
        adType: AdType.rewarded,
        result: AdResult.rewarded,
        adId: adId,
        additionalData: {
          'reward_type': reward.type,
          'reward_amount': reward.amount,
          'reward_multiplier': _config?.rewardMultiplier ?? 1.0,
        },
        timestamp: DateTime.now(),
      ));
    });
    
    _lastShownTime[AdType.rewarded] = DateTime.now();
    return AdResult.shown;
  }
  
  @override
  Future<AdResult> hideAd(AdType adType, {String? adId}) async {
    switch (adType) {
      case AdType.banner:
        _bannerAd?.dispose();
        _bannerAd = null;
        _loadedAds.remove(AdType.banner);
        break;
      case AdType.interstitial:
        _interstitialAd?.dispose();
        _interstitialAd = null;
        _loadedAds.remove(AdType.interstitial);
        break;
      case AdType.rewarded:
        _rewardedAd?.dispose();
        _rewardedAd = null;
        _loadedAds.remove(AdType.rewarded);
        break;
      case AdType.native:
      case AdType.appOpen:
        break;
    }
    
    if (_config?.debugMode == true) {
      debugPrint('Google ad hidden: $adType (id: $adId)');
    }
    
    return AdResult.closed;
  }
  
  @override
  Future<bool> isAdReady(AdType adType, {String? adId}) async {
    return _loadedAds[adType] != null;
  }
  
  String _getAdUnitId(AdType adType, String? customId) {
    if (customId != null) return customId;
    
    // テストモード時はテストIDを使用
    if (_config?.testMode == true) {
      switch (adType) {
        case AdType.banner:
          return _testBannerId;
        case AdType.interstitial:
          return _testInterstitialId;
        case AdType.rewarded:
          return _testRewardedId;
        case AdType.native:
        case AdType.appOpen:
          return _testBannerId; // フォールバック
      }
    }
    
    // 設定からIDを取得
    return _config?.adUnitIds[adType] ?? _testBannerId;
  }
  
  void _notifyListeners(AdEventData event) {
    for (final listener in _listeners) {
      try {
        listener(event);
      } catch (e) {
        debugPrint('Ad event listener error: $e');
      }
    }
  }
  
  @override
  void addAdEventListener(void Function(AdEventData event) listener) {
    _listeners.add(listener);
  }
  
  @override
  void removeAdEventListener(void Function(AdEventData event) listener) {
    _listeners.remove(listener);
  }
  
  @override
  Future<void> dispose() async {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    
    _listeners.clear();
    _loadedAds.clear();
    _lastShownTime.clear();
    
    debugPrint('GoogleAdProvider disposed');
  }
}