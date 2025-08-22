import 'package:envied/envied.dart';

part 'env_config.g.dart';

/// 環境変数設定クラス
///
/// ENViedパッケージを使用してコンパイル時に環境変数を注入し、
/// セキュアな設定管理を実現します。
///
/// 使用方法:
/// - 開発環境: .env または .env.dev
/// - 本番環境: .env.prod
@Envied(path: '.env')
abstract class EnvConfig {
  @EnviedField(varName: 'API_ENDPOINT')
  static const String apiEndpoint = _EnvConfig.apiEndpoint;

  @EnviedField(varName: 'LOG_LEVEL', defaultValue: 1)
  static const int logLevel = _EnvConfig.logLevel;

  @EnviedField(varName: 'ENABLE_DEBUG_MENU', defaultValue: false)
  static const bool enableDebugMenu = _EnvConfig.enableDebugMenu;

  @EnviedField(varName: 'APP_NAME', defaultValue: 'Escape Master')
  static const String appName = _EnvConfig.appName;

  @EnviedField(varName: 'FIREBASE_PROJECT_ID')
  static const String firebaseProjectId = _EnvConfig.firebaseProjectId;

  // Google Mobile Ads設定
  @EnviedField(varName: 'GOOGLE_AD_APP_ID_ANDROID')
  static const String googleAdAppIdAndroid = _EnvConfig.googleAdAppIdAndroid;

  @EnviedField(varName: 'GOOGLE_AD_APP_ID_IOS')
  static const String googleAdAppIdIos = _EnvConfig.googleAdAppIdIos;

  @EnviedField(varName: 'BANNER_AD_UNIT_ID_ANDROID')
  static const String bannerAdUnitIdAndroid = _EnvConfig.bannerAdUnitIdAndroid;

  @EnviedField(varName: 'BANNER_AD_UNIT_ID_IOS')
  static const String bannerAdUnitIdIos = _EnvConfig.bannerAdUnitIdIos;

  @EnviedField(varName: 'INTERSTITIAL_AD_UNIT_ID_ANDROID')
  static const String interstitialAdUnitIdAndroid =
      _EnvConfig.interstitialAdUnitIdAndroid;

  @EnviedField(varName: 'INTERSTITIAL_AD_UNIT_ID_IOS')
  static const String interstitialAdUnitIdIos =
      _EnvConfig.interstitialAdUnitIdIos;

  /// プラットフォーム別Google Mobile Ads アプリIDを取得
  static String getGoogleAdAppId() {
    // プラットフォーム判定はdart:ioを使用してコンパイル時に解決
    const bool isAndroid = bool.fromEnvironment('dart.library.android');
    const bool isIos = bool.fromEnvironment('dart.library.ios');

    if (isAndroid) {
      return googleAdAppIdAndroid;
    } else if (isIos) {
      return googleAdAppIdIos;
    } else {
      // Web or desktop - デフォルトでAndroid IDを返す
      return googleAdAppIdAndroid;
    }
  }

  /// プラットフォーム別バナー広告ユニットIDを取得
  static String getBannerAdUnitId() {
    const bool isAndroid = bool.fromEnvironment('dart.library.android');
    const bool isIos = bool.fromEnvironment('dart.library.ios');

    if (isAndroid) {
      return bannerAdUnitIdAndroid;
    } else if (isIos) {
      return bannerAdUnitIdIos;
    } else {
      return bannerAdUnitIdAndroid;
    }
  }

  /// プラットフォーム別インタースティシャル広告ユニットIDを取得
  static String getInterstitialAdUnitId() {
    const bool isAndroid = bool.fromEnvironment('dart.library.android');
    const bool isIos = bool.fromEnvironment('dart.library.ios');

    if (isAndroid) {
      return interstitialAdUnitIdAndroid;
    } else if (isIos) {
      return interstitialAdUnitIdIos;
    } else {
      return interstitialAdUnitIdAndroid;
    }
  }

  /// 開発環境かどうかを判定
  static bool get isDevelopment {
    return enableDebugMenu && logLevel <= 2;
  }

  /// 本番環境かどうかを判定
  static bool get isProduction {
    return !enableDebugMenu && logLevel >= 3;
  }

  /// 設定情報をマップ形式で取得（デバッグ用）
  static Map<String, dynamic> toMap() {
    return {
      'apiEndpoint': apiEndpoint,
      'logLevel': logLevel,
      'enableDebugMenu': enableDebugMenu,
      'appName': appName,
      'firebaseProjectId': firebaseProjectId,
      'isDevelopment': isDevelopment,
      'isProduction': isProduction,
    };
  }
}
