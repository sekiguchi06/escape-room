import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../monetization_system.dart';

/// バナー広告の管理を担当するクラス
class BannerAdHandler {
  static const String _testBannerId = 'ca-app-pub-3940256099942544/6300978111';

  BannerAd? _bannerAd;
  final MonetizationConfiguration config;
  final Function(AdEventData) onAdEvent;

  BannerAdHandler({
    required this.config,
    required this.onAdEvent,
  });

  Future<AdResult> loadAd(String? adId) async {
    if (config.adsDisabled || config.enabledAdTypes[AdType.banner] != true) {
      return AdResult.failed;
    }

    try {
      final adUnitId = _getAdUnitId(adId);

      _bannerAd = BannerAd(
        adUnitId: adUnitId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            onAdEvent(
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
            onAdEvent(
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
            onAdEvent(
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
    } catch (e) {
      onAdEvent(
        AdEventData(
          adType: AdType.banner,
          result: AdResult.failed,
          adId: adId,
          errorMessage: e.toString(),
          timestamp: DateTime.now(),
        ),
      );
      return AdResult.failed;
    }
  }

  AdResult showAd(String? adId) {
    onAdEvent(
      AdEventData(
        adType: AdType.banner,
        result: AdResult.shown,
        adId: adId,
        timestamp: DateTime.now(),
      ),
    );
    return AdResult.shown;
  }

  AdResult hideAd(String? adId) {
    _bannerAd?.dispose();
    _bannerAd = null;

    if (config.debugMode) {
      debugPrint('Banner ad hidden (id: $adId)');
    }

    return AdResult.closed;
  }

  bool isAdReady() {
    return _bannerAd != null;
  }

  BannerAd? get bannerAd => _bannerAd;

  String _getAdUnitId(String? customId) {
    if (customId != null) return customId;

    if (config.testMode) {
      return _testBannerId;
    }

    return config.bannerAdUnitId ?? _testBannerId;
  }

  void dispose() {
    _bannerAd?.dispose();
    _bannerAd = null;
  }
}