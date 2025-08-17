import 'package:flutter/foundation.dart';
import 'ad_models.dart';
import 'monetization_configuration.dart';

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
    
    // テスト環境では即座に完了（タイマー残存問題回避）
    if (config.testMode) {
      if (config.debugMode) {
        debugPrint('MockAdProvider initialized in test mode (immediate)');
      }
    } else {
      // 実環境でのみ初期化シミュレート
      await Future.delayed(const Duration(milliseconds: 100));
      if (config.debugMode) {
        debugPrint('MockAdProvider initialized (testMode: ${config.testMode})');
      }
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