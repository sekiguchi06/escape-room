import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../monetization_system.dart';

/// リワード広告の管理を担当するクラス
class RewardedAdHandler {
  static const String _testRewardedId = 'ca-app-pub-3940256099942544/5224354917';

  RewardedAd? _rewardedAd;
  final MonetizationConfiguration config;
  final Function(AdEventData) onAdEvent;

  RewardedAdHandler({
    required this.config,
    required this.onAdEvent,
  });

  Future<AdResult> loadAd(String? adId) async {
    if (config.adsDisabled || config.enabledAdTypes[AdType.rewarded] != true) {
      return AdResult.failed;
    }

    try {
      final adUnitId = _getAdUnitId(adId);

      await RewardedAd.load(
        adUnitId: adUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            _rewardedAd = ad;

            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdShowedFullScreenContent: (ad) {
                onAdEvent(
                  AdEventData(
                    adType: AdType.rewarded,
                    result: AdResult.shown,
                    adId: adId,
                    timestamp: DateTime.now(),
                  ),
                );
              },
              onAdDismissedFullScreenContent: (ad) {
                onAdEvent(
                  AdEventData(
                    adType: AdType.rewarded,
                    result: AdResult.closed,
                    adId: adId,
                    timestamp: DateTime.now(),
                  ),
                );
                ad.dispose();
                _rewardedAd = null;
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                onAdEvent(
                  AdEventData(
                    adType: AdType.rewarded,
                    result: AdResult.failed,
                    adId: adId,
                    errorMessage: error.message,
                    timestamp: DateTime.now(),
                  ),
                );
                ad.dispose();
                _rewardedAd = null;
              },
              onAdClicked: (ad) {
                onAdEvent(
                  AdEventData(
                    adType: AdType.rewarded,
                    result: AdResult.clicked,
                    adId: adId,
                    timestamp: DateTime.now(),
                  ),
                );
              },
            );

            onAdEvent(
              AdEventData(
                adType: AdType.rewarded,
                result: AdResult.loaded,
                adId: adId,
                timestamp: DateTime.now(),
              ),
            );
          },
          onAdFailedToLoad: (error) {
            onAdEvent(
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
    } catch (e) {
      onAdEvent(
        AdEventData(
          adType: AdType.rewarded,
          result: AdResult.failed,
          adId: adId,
          errorMessage: e.toString(),
          timestamp: DateTime.now(),
        ),
      );
      return AdResult.failed;
    }
  }

  Future<AdResult> showAd(String? adId) async {
    final ad = _rewardedAd;
    if (ad == null) return AdResult.notReady;

    await ad.show(
      onUserEarnedReward: (ad, reward) {
        onAdEvent(
          AdEventData(
            adType: AdType.rewarded,
            result: AdResult.rewarded,
            adId: adId,
            additionalData: {
              'reward_type': reward.type,
              'reward_amount': reward.amount,
              'reward_multiplier': config.rewardMultiplier,
            },
            timestamp: DateTime.now(),
          ),
        );
      },
    );

    return AdResult.shown;
  }

  AdResult hideAd(String? adId) {
    _rewardedAd?.dispose();
    _rewardedAd = null;

    if (config.debugMode) {
      debugPrint('Rewarded ad hidden (id: $adId)');
    }

    return AdResult.closed;
  }

  bool isAdReady() {
    return _rewardedAd != null;
  }

  String _getAdUnitId(String? customId) {
    if (customId != null) return customId;

    if (config.testMode) {
      return _testRewardedId;
    }

    return config.rewardedAdUnitId ?? _testRewardedId;
  }

  void dispose() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
  }
}