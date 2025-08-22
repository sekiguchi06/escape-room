import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../monetization_system.dart';
import '../core/google_ad_provider_core.dart';
import '../utils/google_ad_utils.dart';

/// リワード広告ハンドラー
class RewardedAdHandler {
  final GoogleAdProviderCore _core;
  final GoogleAdUtils _utils;
  RewardedAd? _rewardedAd;

  RewardedAdHandler(this._core, this._utils);

  /// リワード広告読み込み
  Future<AdResult> loadRewardedAd(String? adId) async {
    final adUnitId = _utils.getAdUnitId(AdType.rewarded, adId);

    await RewardedAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _core.loadedAds[AdType.rewarded] = ad;

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) {
              _core.notifyListeners(
                AdEventData(
                  adType: AdType.rewarded,
                  result: AdResult.shown,
                  adId: adId,
                  timestamp: DateTime.now(),
                ),
              );
            },
            onAdDismissedFullScreenContent: (ad) {
              _core.notifyListeners(
                AdEventData(
                  adType: AdType.rewarded,
                  result: AdResult.closed,
                  adId: adId,
                  timestamp: DateTime.now(),
                ),
              );
              ad.dispose();
              _core.loadedAds.remove(AdType.rewarded);
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              _core.notifyListeners(
                AdEventData(
                  adType: AdType.rewarded,
                  result: AdResult.failed,
                  adId: adId,
                  errorMessage: error.message,
                  timestamp: DateTime.now(),
                ),
              );
              ad.dispose();
              _core.loadedAds.remove(AdType.rewarded);
            },
            onAdClicked: (ad) {
              _core.notifyListeners(
                AdEventData(
                  adType: AdType.rewarded,
                  result: AdResult.clicked,
                  adId: adId,
                  timestamp: DateTime.now(),
                ),
              );
            },
          );

          _core.notifyListeners(
            AdEventData(
              adType: AdType.rewarded,
              result: AdResult.loaded,
              adId: adId,
              timestamp: DateTime.now(),
            ),
          );
        },
        onAdFailedToLoad: (error) {
          _core.notifyListeners(
            AdEventData(
              adType: AdType.rewarded,
              result: AdResult.failed,
              adId: adId,
              errorMessage: error.message,
              timestamp: DateTime.now(),
            ),
          );
        },
      ),
    );

    return AdResult.loaded;
  }

  /// リワード広告表示
  Future<AdResult> showRewardedAd(String? adId) async {
    final ad = _rewardedAd;
    if (ad == null) return AdResult.notReady;

    await ad.show(
      onUserEarnedReward: (ad, reward) {
        _core.notifyListeners(
          AdEventData(
            adType: AdType.rewarded,
            result: AdResult.rewarded,
            adId: adId,
            additionalData: {
              'reward_type': reward.type,
              'reward_amount': reward.amount,
              'reward_multiplier': _core.config?.rewardMultiplier ?? 1.0,
            },
            timestamp: DateTime.now(),
          ),
        );
      },
    );

    _core.lastShownTime[AdType.rewarded] = DateTime.now();
    return AdResult.shown;
  }

  /// リワード広告非表示
  AdResult hideRewardedAd(String? adId) {
    _rewardedAd?.dispose();
    _rewardedAd = null;
    _core.loadedAds.remove(AdType.rewarded);

    if (_core.config?.debugMode == true) {
      debugPrint('Google rewarded ad hidden (id: $adId)');
    }

    return AdResult.closed;
  }

  /// リソース解放
  void dispose() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
  }
}
