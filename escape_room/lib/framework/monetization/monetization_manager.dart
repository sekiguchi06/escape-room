import 'package:flutter/foundation.dart';
import 'ad_models.dart';
import 'monetization_configuration.dart';
import 'ad_providers.dart';

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
  }) : _provider = provider,
       _configuration = configuration;

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
  Future<void> updateConfiguration(
    MonetizationConfiguration newConfiguration,
  ) async {
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
        debugPrint(
          'Interstitial too soon: ${elapsed}s < ${_configuration.interstitialInterval}s',
        );
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

      _estimatedRevenue[event.adType] =
          (_estimatedRevenue[event.adType] ?? 0.0) + revenue;
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
      'average_revenue_per_show': totalShows > 0
          ? (totalRevenue / totalShows).toStringAsFixed(4)
          : '0.0000',
      'revenue_by_type': _estimatedRevenue.map(
        (key, value) => MapEntry(key.name, value.toStringAsFixed(3)),
      ),
      'shows_by_type': _adShowCounts.map(
        (key, value) => MapEntry(key.name, value),
      ),
    };
  }

  /// デバッグ情報
  Map<String, dynamic> getDebugInfo() {
    return {
      'manager': runtimeType.toString(),
      'provider': _provider.runtimeType.toString(),
      'interstitial_interval': _configuration.interstitialInterval,
      'last_interstitial_elapsed': DateTime.now()
          .difference(_lastInterstitialShow)
          .inSeconds,
      'should_show_interstitial': shouldShowInterstitial(),
      'enabled_ad_types': _configuration.enabledAdTypes.map(
        (key, value) => MapEntry(key.name, value),
      ),
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
