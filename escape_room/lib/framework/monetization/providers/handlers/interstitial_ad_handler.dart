import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../monetization_system.dart';
import '../core/google_ad_provider_core.dart';
import '../utils/google_ad_utils.dart';

/// インタースティシャル広告ハンドラー
class InterstitialAdHandler {
  final GoogleAdProviderCore _core;
  final GoogleAdUtils _utils;
  InterstitialAd? _interstitialAd;

  InterstitialAdHandler(this._core, this._utils);

  /// インタースティシャル広告読み込み
  Future<AdResult> loadInterstitialAd(String? adId) async {
    final adUnitId = _utils.getAdUnitId(AdType.interstitial, adId);

    await InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _core.loadedAds[AdType.interstitial] = ad;

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) {
              _core.notifyListeners(
                AdEventData(
                  adType: AdType.interstitial,
                  result: AdResult.shown,
                  adId: adId,
                  timestamp: DateTime.now(),
                ),
              );
            },
            onAdDismissedFullScreenContent: (ad) {
              _core.notifyListeners(
                AdEventData(
                  adType: AdType.interstitial,
                  result: AdResult.closed,
                  adId: adId,
                  timestamp: DateTime.now(),
                ),
              );
              ad.dispose();
              _core.loadedAds.remove(AdType.interstitial);
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              _core.notifyListeners(
                AdEventData(
                  adType: AdType.interstitial,
                  result: AdResult.failed,
                  adId: adId,
                  errorMessage: error.message,
                  timestamp: DateTime.now(),
                ),
              );
              ad.dispose();
              _core.loadedAds.remove(AdType.interstitial);
            },
            onAdClicked: (ad) {
              _core.notifyListeners(
                AdEventData(
                  adType: AdType.interstitial,
                  result: AdResult.clicked,
                  adId: adId,
                  timestamp: DateTime.now(),
                ),
              );
            },
          );

          _core.notifyListeners(
            AdEventData(
              adType: AdType.interstitial,
              result: AdResult.loaded,
              adId: adId,
              timestamp: DateTime.now(),
            ),
          );
        },
        onAdFailedToLoad: (error) {
          _core.notifyListeners(
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
  }

  /// インタースティシャル広告表示
  Future<AdResult> showInterstitialAd(String? adId) async {
    final ad = _interstitialAd;
    if (ad == null) return AdResult.notReady;

    await ad.show();
    _core.lastShownTime[AdType.interstitial] = DateTime.now();
    return AdResult.shown;
  }

  /// インタースティシャル広告非表示
  AdResult hideInterstitialAd(String? adId) {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _core.loadedAds.remove(AdType.interstitial);

    if (_core.config?.debugMode == true) {
      debugPrint('Google interstitial ad hidden (id: $adId)');
    }

    return AdResult.closed;
  }

  /// リソース解放
  void dispose() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
  }
}
