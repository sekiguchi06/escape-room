import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../monetization_system.dart';
import '../core/google_ad_provider_core.dart';
import '../utils/google_ad_utils.dart';

/// バナー広告ハンドラー
class BannerAdHandler {
  final GoogleAdProviderCore _core;
  final GoogleAdUtils _utils;
  BannerAd? _bannerAd;

  BannerAdHandler(this._core, this._utils);

  /// バナー広告読み込み
  Future<AdResult> loadBannerAd(String? adId) async {
    final adUnitId = _utils.getAdUnitId(AdType.banner, adId);

    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          _core.loadedAds[AdType.banner] = ad;
          _core.notifyListeners(
            AdEventData(
              adType: AdType.banner,
              result: AdResult.loaded,
              adId: adId,
              timestamp: DateTime.now(),
            ),
          );
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _core.notifyListeners(
            AdEventData(
              adType: AdType.banner,
              result: AdResult.failed,
              adId: adId,
              errorMessage: error.message,
              timestamp: DateTime.now(),
            ),
          );
        },
        onAdClicked: (ad) {
          _core.notifyListeners(
            AdEventData(
              adType: AdType.banner,
              result: AdResult.clicked,
              adId: adId,
              timestamp: DateTime.now(),
            ),
          );
        },
      ),
    );

    await _bannerAd!.load();
    return AdResult.loaded;
  }

  /// バナー広告表示
  AdResult showBannerAd(String? adId) {
    // バナー広告はUI側で表示される想定
    _core.lastShownTime[AdType.banner] = DateTime.now();
    return AdResult.shown;
  }

  /// バナー広告非表示
  AdResult hideBannerAd(String? adId) {
    _bannerAd?.dispose();
    _bannerAd = null;
    _core.loadedAds.remove(AdType.banner);

    if (_core.config?.debugMode == true) {
      debugPrint('Google banner ad hidden (id: $adId)');
    }

    return AdResult.closed;
  }

  /// リソース解放
  void dispose() {
    _bannerAd?.dispose();
    _bannerAd = null;
  }
}
