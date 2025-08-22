import '../../monetization_system.dart';
import '../../../../config/env_config.dart';
import '../core/google_ad_provider_core.dart';

/// Google広告ユーティリティクラス
class GoogleAdUtils {
  final GoogleAdProviderCore _core;

  GoogleAdUtils(this._core);

  /// 広告ID取得
  String getAdUnitId(AdType adType, String? customId) {
    if (customId != null) return customId;

    // テストモード時はテストIDを使用
    if (_core.config?.testMode == true) {
      switch (adType) {
        case AdType.banner:
          return GoogleAdProviderCore.testBannerId;
        case AdType.interstitial:
          return GoogleAdProviderCore.testInterstitialId;
        case AdType.rewarded:
          return GoogleAdProviderCore.testRewardedId;
        case AdType.native:
        case AdType.appOpen:
          return GoogleAdProviderCore.testBannerId; // フォールバック
      }
    }

    // 環境変数からIDを取得（プラットフォーム別）
    switch (adType) {
      case AdType.banner:
        return EnvConfig.getBannerAdUnitId();
      case AdType.interstitial:
        return EnvConfig.getInterstitialAdUnitId();
      case AdType.rewarded:
        // リワード広告は現在未実装なのでバナーを返す
        return EnvConfig.getBannerAdUnitId();
      case AdType.native:
      case AdType.appOpen:
        return EnvConfig.getBannerAdUnitId(); // フォールバック
    }
  }

  /// 広告が有効かチェック
  bool isAdEnabled(AdType adType) {
    return _core.config?.adsDisabled != true &&
        _core.config?.enabledAdTypes[adType] == true;
  }

  /// エラーイベント作成
  AdEventData createErrorEvent(
    AdType adType,
    String? adId,
    String errorMessage,
  ) {
    return AdEventData(
      adType: adType,
      result: AdResult.failed,
      adId: adId,
      errorMessage: errorMessage,
      timestamp: DateTime.now(),
    );
  }
}
