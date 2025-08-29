import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../monetization_system.dart';

/// インタースティシャル広告の管理を担当するクラス
class InterstitialAdHandler {
  static const String _testInterstitialId = 'ca-app-pub-3940256099942544/1033173712';

  InterstitialAd? _interstitialAd;
  final MonetizationConfiguration config;
  final Function(AdEventData) onAdEvent;

  InterstitialAdHandler({
    required this.config,
    required this.onAdEvent,
  });

  Future<AdResult> loadAd(String? adId) async {
    if (config.adsDisabled || config.enabledAdTypes[AdType.interstitial] != true) {
      return AdResult.failed;
    }

    try {
      final adUnitId = _getAdUnitId(adId);

      await InterstitialAd.load(
        adUnitId: adUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _interstitialAd = ad;

            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdShowedFullScreenContent: (ad) {
                onAdEvent(
                  AdEventData(
                    adType: AdType.interstitial,
                    result: AdResult.shown,
                    adId: adId,
                    timestamp: DateTime.now(),
                  ),
                );
              },
              onAdDismissedFullScreenContent: (ad) {
                onAdEvent(
                  AdEventData(
                    adType: AdType.interstitial,
                    result: AdResult.closed,
                    adId: adId,
                    timestamp: DateTime.now(),
                  ),
                );
                ad.dispose();
                _interstitialAd = null;
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                onAdEvent(
                  AdEventData(
                    adType: AdType.interstitial,
                    result: AdResult.failed,
                    adId: adId,
                    errorMessage: error.message,
                    timestamp: DateTime.now(),
                  ),
                );
                ad.dispose();
                _interstitialAd = null;
              },
              onAdClicked: (ad) {
                onAdEvent(
                  AdEventData(
                    adType: AdType.interstitial,
                    result: AdResult.clicked,
                    adId: adId,
                    timestamp: DateTime.now(),
                  ),
                );
              },
            );

            onAdEvent(
              AdEventData(
                adType: AdType.interstitial,
                result: AdResult.loaded,
                adId: adId,
                timestamp: DateTime.now(),
              ),
            );
          },
          onAdFailedToLoad: (error) {
            onAdEvent(
              AdEventData(
                adType: AdType.interstitial,
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
          adType: AdType.interstitial,
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
    final ad = _interstitialAd;
    if (ad == null) return AdResult.notReady;

    await ad.show();
    return AdResult.shown;
  }

  AdResult hideAd(String? adId) {
    _interstitialAd?.dispose();
    _interstitialAd = null;

    if (config.debugMode) {
      debugPrint('Interstitial ad hidden (id: $adId)');
    }

    return AdResult.closed;
  }

  bool isAdReady() {
    return _interstitialAd != null;
  }

  String _getAdUnitId(String? customId) {
    if (customId != null) return customId;

    if (config.testMode) {
      return _testInterstitialId;
    }

    return config.interstitialAdUnitId ?? _testInterstitialId;
  }

  void dispose() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
  }
}