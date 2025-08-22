import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../monetization_system.dart';

/// Google広告プロバイダーのコア機能
class GoogleAdProviderCore {
  // Google Mobile Ads テストID
  static const String testBannerId = 'ca-app-pub-3940256099942544/6300978111';
  static const String testInterstitialId =
      'ca-app-pub-3940256099942544/1033173712';
  static const String testRewardedId = 'ca-app-pub-3940256099942544/5224354917';

  MonetizationConfiguration? _config;
  final List<void Function(AdEventData)> _listeners = [];
  final Map<AdType, dynamic> _loadedAds = {};
  final Map<AdType, DateTime> _lastShownTime = {};

  // Getters
  MonetizationConfiguration? get config => _config;
  List<void Function(AdEventData)> get listeners => _listeners;
  Map<AdType, dynamic> get loadedAds => _loadedAds;
  Map<AdType, DateTime> get lastShownTime => _lastShownTime;

  /// 初期化
  Future<bool> initialize(MonetizationConfiguration config) async {
    _config = config;

    try {
      // Google Mobile Ads SDKの初期化
      final mobileAds = MobileAds.instance;
      await mobileAds.initialize();

      if (config.debugMode) {
        debugPrint(
          'GoogleAdProvider initialized (testMode: ${config.testMode})',
        );
      }

      return true;
    } catch (e) {
      debugPrint('GoogleAdProvider initialization failed: $e');
      return false;
    }
  }

  /// 最小間隔チェック
  bool checkMinInterval(AdType adType) {
    final lastShown = _lastShownTime[adType];
    if (lastShown != null) {
      final elapsed = DateTime.now().difference(lastShown).inSeconds;
      if (elapsed < _config!.minAdInterval) {
        return false;
      }
    }
    return true;
  }

  /// 広告が准備済みかチェック
  bool isAdReady(AdType adType) {
    return _loadedAds[adType] != null;
  }

  /// リスナー通知
  void notifyListeners(AdEventData event) {
    for (final listener in _listeners) {
      try {
        listener(event);
      } catch (e) {
        debugPrint('Ad event listener error: $e');
      }
    }
  }

  /// リスナー追加
  void addAdEventListener(void Function(AdEventData event) listener) {
    _listeners.add(listener);
  }

  /// リスナー削除
  void removeAdEventListener(void Function(AdEventData event) listener) {
    _listeners.remove(listener);
  }

  /// リソース解放
  void dispose() {
    _listeners.clear();
    _loadedAds.clear();
    _lastShownTime.clear();

    debugPrint('GoogleAdProviderCore disposed');
  }
}
