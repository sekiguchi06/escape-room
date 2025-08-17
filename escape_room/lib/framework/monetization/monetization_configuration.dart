import 'ad_models.dart';

/// 収益化設定の基底クラス
abstract class MonetizationConfiguration {
  /// インタースティシャル広告の表示間隔（秒）
  int get interstitialInterval;
  
  /// リワード広告のボーナス倍率
  double get rewardMultiplier;
  
  /// バナー広告の表示位置
  String get bannerPosition;
  
  /// 広告テスト用フラグ
  bool get testMode;
  
  /// 広告無効フラグ（デバッグ用）
  bool get adsDisabled;
  
  /// 各広告タイプの有効フラグ
  Map<AdType, bool> get enabledAdTypes;
  
  /// 広告表示最小間隔（秒）
  int get minAdInterval;
  
  /// デバッグモード
  bool get debugMode;
  
  /// 広告ID設定
  Map<AdType, String> get adUnitIds;
}

/// デフォルト収益化設定
class DefaultMonetizationConfiguration implements MonetizationConfiguration {
  @override
  final int interstitialInterval;
  
  @override
  final double rewardMultiplier;
  
  @override
  final String bannerPosition;
  
  @override
  final bool testMode;
  
  @override
  final bool adsDisabled;
  
  @override
  final Map<AdType, bool> enabledAdTypes;
  
  @override
  final int minAdInterval;
  
  @override
  final bool debugMode;
  
  @override
  final Map<AdType, String> adUnitIds;
  
  const DefaultMonetizationConfiguration({
    this.interstitialInterval = 60,
    this.rewardMultiplier = 2.0,
    this.bannerPosition = 'bottom',
    this.testMode = true,
    this.adsDisabled = false,
    this.enabledAdTypes = const {
      AdType.banner: true,
      AdType.interstitial: true,
      AdType.rewarded: true,
      AdType.native: false,
      AdType.appOpen: false,
    },
    this.minAdInterval = 30,
    this.debugMode = false,
    this.adUnitIds = const {
      AdType.banner: 'test_banner_id',
      AdType.interstitial: 'test_interstitial_id',
      AdType.rewarded: 'test_rewarded_id',
    },
  });
  
  DefaultMonetizationConfiguration copyWith({
    int? interstitialInterval,
    double? rewardMultiplier,
    String? bannerPosition,
    bool? testMode,
    bool? adsDisabled,
    Map<AdType, bool>? enabledAdTypes,
    int? minAdInterval,
    bool? debugMode,
    Map<AdType, String>? adUnitIds,
  }) {
    return DefaultMonetizationConfiguration(
      interstitialInterval: interstitialInterval ?? this.interstitialInterval,
      rewardMultiplier: rewardMultiplier ?? this.rewardMultiplier,
      bannerPosition: bannerPosition ?? this.bannerPosition,
      testMode: testMode ?? this.testMode,
      adsDisabled: adsDisabled ?? this.adsDisabled,
      enabledAdTypes: enabledAdTypes ?? this.enabledAdTypes,
      minAdInterval: minAdInterval ?? this.minAdInterval,
      debugMode: debugMode ?? this.debugMode,
      adUnitIds: adUnitIds ?? this.adUnitIds,
    );
  }
}