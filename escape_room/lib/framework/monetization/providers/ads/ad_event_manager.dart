import 'package:flutter/foundation.dart';
import '../../monetization_system.dart';

/// 広告イベントの管理とリスナーの処理を担当するクラス
class AdEventManager {
  final List<void Function(AdEventData)> _listeners = [];
  final Map<AdType, DateTime> _lastShownTime = {};
  final MonetizationConfiguration config;

  AdEventManager({required this.config});

  void notifyListeners(AdEventData event) {
    for (final listener in _listeners) {
      try {
        listener(event);
      } catch (e) {
        debugPrint('Ad event listener error: $e');
      }
    }
  }

  void addAdEventListener(void Function(AdEventData event) listener) {
    _listeners.add(listener);
  }

  void removeAdEventListener(void Function(AdEventData event) listener) {
    _listeners.remove(listener);
  }

  bool canShowAd(AdType adType) {
    if (config.adsDisabled || config.enabledAdTypes[adType] != true) {
      return false;
    }

    final lastShown = _lastShownTime[adType];
    if (lastShown != null) {
      final elapsed = DateTime.now().difference(lastShown).inSeconds;
      if (elapsed < config.minAdInterval) {
        return false;
      }
    }

    return true;
  }

  void recordAdShown(AdType adType) {
    _lastShownTime[adType] = DateTime.now();
  }

  void clear() {
    _listeners.clear();
    _lastShownTime.clear();
  }
}