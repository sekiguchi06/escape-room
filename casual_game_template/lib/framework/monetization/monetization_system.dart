import 'package:flutter/foundation.dart';

/// 広告の種類
enum AdType {
  banner,         // バナー広告
  interstitial,   // インタースティシャル広告
  rewarded,       // リワード広告  
  native,         // ネイティブ広告
  appOpen,        // アプリ起動広告
}

/// 広告表示結果
enum AdResult {
  loaded,         // 広告読み込み成功
  shown,          // 広告表示成功
  clicked,        // 広告クリック
  closed,         // 広告閉じた
  rewarded,       // リワード獲得
  failed,         // 広告失敗
  notReady,       // 広告準備未完了
  noFill,         // 広告配信なし
}

/// 広告イベントデータ
class AdEventData {
  final AdType adType;
  final AdResult result;
  final String? adId;
  final String? errorMessage;
  final Map<String, dynamic> additionalData;
  final DateTime timestamp;
  
  const AdEventData({
    required this.adType,
    required this.result,
    this.adId,
    this.errorMessage,
    this.additionalData = const {},
    required this.timestamp,
  });
  
  @override
  String toString() {
    return 'AdEventData(type: $adType, result: $result, id: $adId, error: $errorMessage)';
  }
}

/// 収益化設定の基底クラス
abstract class MonetizationConfiguration {
  /// インタースティシャル広告の表示間隔（秒）
  int get interstitialInterval;
  
  /// リワード広告のボーナス倍率
  double get rewardMultiplier;
  
  /// バナー広告の表示位置
  String get bannerPosition;
  
  /// 広告テスト用フラグ
  bool get testMode;
  
  /// 広告無効フラグ（デバッグ用）
  bool get adsDisabled;
  
  /// 各広告タイプの有効フラグ
  Map<AdType, bool> get enabledAdTypes;
  
  /// 広告表示最小間隔（秒）
  int get minAdInterval;
  
  /// デバッグモード
  bool get debugMode;
  
  /// 広告ID設定
  Map<AdType, String> get adUnitIds;
}

/// デフォルト収益化設定
class DefaultMonetizationConfiguration implements MonetizationConfiguration {
  @override
  final int interstitialInterval;
  
  @override
  final double rewardMultiplier;
  
  @override
  final String bannerPosition;
  
  @override
  final bool testMode;
  
  @override
  final bool adsDisabled;
  
  @override
  final Map<AdType, bool> enabledAdTypes;
  
  @override
  final int minAdInterval;
  
  @override
  final bool debugMode;
  
  @override
  final Map<AdType, String> adUnitIds;
  
  const DefaultMonetizationConfiguration({
    this.interstitialInterval = 60,
    this.rewardMultiplier = 2.0,
    this.bannerPosition = 'bottom',
    this.testMode = true,
    this.adsDisabled = false,
    this.enabledAdTypes = const {
      AdType.banner: true,
      AdType.interstitial: true,
      AdType.rewarded: true,
      AdType.native: false,
      AdType.appOpen: false,
    },
    this.minAdInterval = 30,
    this.debugMode = false,
    this.adUnitIds = const {
      AdType.banner: 'test_banner_id',
      AdType.interstitial: 'test_interstitial_id',
      AdType.rewarded: 'test_rewarded_id',
    },
  });
  
  DefaultMonetizationConfiguration copyWith({
    int? interstitialInterval,
    double? rewardMultiplier,
    String? bannerPosition,
    bool? testMode,
    bool? adsDisabled,
    Map<AdType, bool>? enabledAdTypes,
    int? minAdInterval,
    bool? debugMode,
    Map<AdType, String>? adUnitIds,
  }) {
    return DefaultMonetizationConfiguration(
      interstitialInterval: interstitialInterval ?? this.interstitialInterval,
      rewardMultiplier: rewardMultiplier ?? this.rewardMultiplier,
      bannerPosition: bannerPosition ?? this.bannerPosition,
      testMode: testMode ?? this.testMode,
      adsDisabled: adsDisabled ?? this.adsDisabled,
      enabledAdTypes: enabledAdTypes ?? this.enabledAdTypes,
      minAdInterval: minAdInterval ?? this.minAdInterval,
      debugMode: debugMode ?? this.debugMode,
      adUnitIds: adUnitIds ?? this.adUnitIds,
    );
  }
}

/// 広告プロバイダーの抽象インターフェース
abstract class AdProvider {
  /// 初期化
  Future<bool> initialize(MonetizationConfiguration config);
  
  /// 広告読み込み
  Future<AdResult> loadAd(AdType adType, {String? adId});
  
  /// 広告表示
  Future<AdResult> showAd(AdType adType, {String? adId});
  
  /// 広告非表示
  Future<AdResult> hideAd(AdType adType, {String? adId});
  
  /// 広告準備状態チェック
  Future<bool> isAdReady(AdType adType, {String? adId});
  
  /// 広告イベントリスナー登録
  void addAdEventListener(void Function(AdEventData event) listener);
  
  /// 広告イベントリスナー削除
  void removeAdEventListener(void Function(AdEventData event) listener);
  
  /// リソース解放
  Future<void> dispose();
}

/// モック広告プロバイダー（テスト・開発用）
class MockAdProvider implements AdProvider {
  MonetizationConfiguration? _config;
  final List<void Function(AdEventData)> _listeners = [];
  final Map<AdType, bool> _loadedAds = {};
  final Map<AdType, DateTime> _lastShownTime = {};
  
  @override
  Future<bool> initialize(MonetizationConfiguration config) async {
    _config = config;
    
    // 初期化シミュレート
    await Future.delayed(const Duration(milliseconds: 100));
    
    if (config.debugMode) {
      debugPrint('MockAdProvider initialized (testMode: ${config.testMode})');
    }
    
    return true;
  }
  
  @override
  Future<AdResult> loadAd(AdType adType, {String? adId}) async {
    if (_config?.adsDisabled == true || _config?.enabledAdTypes[adType] != true) {
      return AdResult.failed;
    }
    
    // 読み込みシミュレート
    await Future.delayed(Duration(milliseconds: 200 + (adType.index * 100)));
    
    // 90%の確率で成功
    if (DateTime.now().millisecond % 10 == 0) {
      _notifyListeners(AdEventData(
        adType: adType,
        result: AdResult.noFill,
        adId: adId,
        timestamp: DateTime.now(),
      ));
      return AdResult.noFill;
    }
    
    _loadedAds[adType] = true;
    
    _notifyListeners(AdEventData(
      adType: adType,
      result: AdResult.loaded,
      adId: adId,
      timestamp: DateTime.now(),
    ));
    
    if (_config?.debugMode == true) {
      debugPrint('Mock ad loaded: $adType (id: $adId)');
    }
    
    return AdResult.loaded;
  }
  
  @override
  Future<AdResult> showAd(AdType adType, {String? adId}) async {
    if (_config?.adsDisabled == true || _config?.enabledAdTypes[adType] != true) {
      return AdResult.failed;
    }
    
    // 準備チェック
    if (_loadedAds[adType] != true) {
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
    
    // 表示シミュレート
    await Future.delayed(Duration(milliseconds: 300 + (adType.index * 200)));
    
    _loadedAds[adType] = false;  // 表示後は再読み込み必要
    _lastShownTime[adType] = DateTime.now();
    
    _notifyListeners(AdEventData(
      adType: adType,
      result: AdResult.shown,
      adId: adId,
      timestamp: DateTime.now(),
    ));
    
    // リワード広告の場合、報酬イベントを発火
    if (adType == AdType.rewarded) {
      await Future.delayed(const Duration(milliseconds: 500));
      
      _notifyListeners(AdEventData(
        adType: adType,
        result: AdResult.rewarded,
        adId: adId,
        additionalData: {'reward_multiplier': _config!.rewardMultiplier},
        timestamp: DateTime.now(),
      ));
    }
    
    // クリックシミュレート（30%の確率）
    if (DateTime.now().millisecond % 10 < 3) {
      await Future.delayed(const Duration(milliseconds: 200));
      
      _notifyListeners(AdEventData(
        adType: adType,
        result: AdResult.clicked,
        adId: adId,
        timestamp: DateTime.now(),
      ));
    }
    
    // 閉じるイベント
    await Future.delayed(Duration(milliseconds: 1000 + (adType.index * 500)));
    
    _notifyListeners(AdEventData(
      adType: adType,
      result: AdResult.closed,
      adId: adId,
      timestamp: DateTime.now(),
    ));
    
    if (_config?.debugMode == true) {
      debugPrint('Mock ad shown: $adType (id: $adId)');
    }
    
    return AdResult.shown;
  }
  
  @override
  Future<AdResult> hideAd(AdType adType, {String? adId}) async {
    _loadedAds[adType] = false;
    
    if (_config?.debugMode == true) {
      debugPrint('Mock ad hidden: $adType (id: $adId)');
    }
    
    return AdResult.closed;
  }
  
  @override
  Future<bool> isAdReady(AdType adType, {String? adId}) async {
    return _loadedAds[adType] == true;
  }
  
  void _notifyListeners(AdEventData event) {
    for (final listener in _listeners) {
      listener(event);
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
    _listeners.clear();
    _loadedAds.clear();
    _lastShownTime.clear();
    debugPrint('MockAdProvider disposed');
  }
}

/// 収益化マネージャー
class MonetizationManager {
  AdProvider _provider;
  MonetizationConfiguration _configuration;
  DateTime _lastInterstitialShow = DateTime.now();
  final Map<AdType, int> _adShowCounts = {};
  final Map<AdType, double> _estimatedRevenue = {};
  
  MonetizationManager({
    required AdProvider provider,
    required MonetizationConfiguration configuration,
  }) : _provider = provider, _configuration = configuration;
  
  /// 現在のプロバイダー
  AdProvider get provider => _provider;
  
  /// 現在の設定
  MonetizationConfiguration get configuration => _configuration;
  
  /// 初期化
  Future<bool> initialize() async {
    final success = await _provider.initialize(_configuration);
    
    if (success) {
      _provider.addAdEventListener(_onAdEvent);
      
      // 初期読み込み
      await _preloadAds();
    }
    
    return success;
  }
  
  /// プロバイダー変更
  Future<void> setProvider(AdProvider newProvider) async {
    await _provider.dispose();
    _provider = newProvider;
    await _provider.initialize(_configuration);
    _provider.addAdEventListener(_onAdEvent);
  }
  
  /// 設定更新
  Future<void> updateConfiguration(MonetizationConfiguration newConfiguration) async {
    _configuration = newConfiguration;
    await _provider.initialize(_configuration);
  }
  
  /// 広告事前読み込み
  Future<void> _preloadAds() async {
    for (final entry in _configuration.enabledAdTypes.entries) {
      if (entry.value) {
        await _provider.loadAd(entry.key);
      }
    }
  }
  
  /// インタースティシャル広告表示
  Future<AdResult> showInterstitial({String? adId}) async {
    if (!_configuration.enabledAdTypes[AdType.interstitial]!) {
      return AdResult.failed;
    }
    
    // 間隔チェック
    final elapsed = DateTime.now().difference(_lastInterstitialShow).inSeconds;
    if (elapsed < _configuration.interstitialInterval) {
      if (_configuration.debugMode) {
        debugPrint('Interstitial too soon: ${elapsed}s < ${_configuration.interstitialInterval}s');
      }
      return AdResult.failed;
    }
    
    // 準備チェック
    if (!await _provider.isAdReady(AdType.interstitial, adId: adId)) {
      // 準備できていない場合は読み込み
      await _provider.loadAd(AdType.interstitial, adId: adId);
      
      // 再チェック
      if (!await _provider.isAdReady(AdType.interstitial, adId: adId)) {
        return AdResult.notReady;
      }
    }
    
    final result = await _provider.showAd(AdType.interstitial, adId: adId);
    
    if (result == AdResult.shown) {
      _lastInterstitialShow = DateTime.now();
    }
    
    return result;
  }
  
  /// リワード広告表示
  Future<AdResult> showRewarded({String? adId}) async {
    if (!_configuration.enabledAdTypes[AdType.rewarded]!) {
      return AdResult.failed;
    }
    
    // 準備チェック
    if (!await _provider.isAdReady(AdType.rewarded, adId: adId)) {
      await _provider.loadAd(AdType.rewarded, adId: adId);
      
      if (!await _provider.isAdReady(AdType.rewarded, adId: adId)) {
        return AdResult.notReady;
      }
    }
    
    return await _provider.showAd(AdType.rewarded, adId: adId);
  }
  
  /// バナー広告表示
  Future<AdResult> showBanner({String? adId}) async {
    if (!_configuration.enabledAdTypes[AdType.banner]!) {
      return AdResult.failed;
    }
    
    return await _provider.showAd(AdType.banner, adId: adId);
  }
  
  /// バナー広告非表示
  Future<AdResult> hideBanner({String? adId}) async {
    return await _provider.hideAd(AdType.banner, adId: adId);
  }
  
  /// 広告準備状態確認
  Future<bool> isAdReady(AdType adType, {String? adId}) async {
    return await _provider.isAdReady(adType, adId: adId);
  }
  
  /// 広告読み込み
  Future<AdResult> loadAd(AdType adType, {String? adId}) async {
    return await _provider.loadAd(adType, adId: adId);
  }
  
  /// インタースティシャル表示判定
  bool shouldShowInterstitial() {
    if (!_configuration.enabledAdTypes[AdType.interstitial]!) {
      return false;
    }
    
    final elapsed = DateTime.now().difference(_lastInterstitialShow).inSeconds;
    return elapsed >= _configuration.interstitialInterval;
  }
  
  /// 広告イベントリスナー登録
  void addAdEventListener(void Function(AdEventData event) listener) {
    _provider.addAdEventListener(listener);
  }
  
  /// 広告イベントリスナー削除
  void removeAdEventListener(void Function(AdEventData event) listener) {
    _provider.removeAdEventListener(listener);
  }
  
  void _onAdEvent(AdEventData event) {
    // 統計更新
    if (event.result == AdResult.shown) {
      _adShowCounts[event.adType] = (_adShowCounts[event.adType] ?? 0) + 1;
      
      // 推定収益更新（仮の値）
      double revenue = 0.0;
      switch (event.adType) {
        case AdType.banner:
          revenue = 0.01;
          break;
        case AdType.interstitial:
          revenue = 0.05;
          break;
        case AdType.rewarded:
          revenue = 0.10;
          break;
        case AdType.native:
          revenue = 0.03;
          break;
        case AdType.appOpen:
          revenue = 0.02;
          break;
      }
      
      _estimatedRevenue[event.adType] = (_estimatedRevenue[event.adType] ?? 0.0) + revenue;
    }
    
    // 表示後の再読み込み
    if (event.result == AdResult.closed) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _provider.loadAd(event.adType, adId: event.adId);
      });
    }
    
    if (_configuration.debugMode) {
      debugPrint('Ad event: ${event.toString()}');
    }
  }
  
  /// 収益統計取得
  Map<String, dynamic> getRevenueStats() {
    double totalRevenue = 0.0;
    int totalShows = 0;
    
    for (final revenue in _estimatedRevenue.values) {
      totalRevenue += revenue;
    }
    
    for (final count in _adShowCounts.values) {
      totalShows += count;
    }
    
    return {
      'total_revenue': totalRevenue.toStringAsFixed(3),
      'total_shows': totalShows,
      'average_revenue_per_show': totalShows > 0 ? (totalRevenue / totalShows).toStringAsFixed(4) : '0.0000',
      'revenue_by_type': _estimatedRevenue.map((key, value) => MapEntry(key.name, value.toStringAsFixed(3))),
      'shows_by_type': _adShowCounts.map((key, value) => MapEntry(key.name, value)),
    };
  }
  
  /// デバッグ情報
  Map<String, dynamic> getDebugInfo() {
    return {
      'manager': runtimeType.toString(),
      'provider': _provider.runtimeType.toString(),
      'interstitial_interval': _configuration.interstitialInterval,
      'last_interstitial_elapsed': DateTime.now().difference(_lastInterstitialShow).inSeconds,
      'should_show_interstitial': shouldShowInterstitial(),
      'enabled_ad_types': _configuration.enabledAdTypes.map((key, value) => MapEntry(key.name, value)),
      'test_mode': _configuration.testMode,
      'ads_disabled': _configuration.adsDisabled,
      'revenue_stats': getRevenueStats(),
    };
  }
  
  /// リソース解放
  Future<void> dispose() async {
    await _provider.dispose();
  }
}