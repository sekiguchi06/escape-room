/// 環境設定クラス
/// 広告ユニットIDなどの環境固有の設定を管理
class EnvConfig {
  /// バナー広告ユニットIDを取得
  static String getBannerAdUnitId() {
    // テスト用広告ユニットID
    return 'ca-app-pub-3940256099942544/6300978111';
  }

  /// インタースティシャル広告ユニットIDを取得
  static String getInterstitialAdUnitId() {
    // テスト用広告ユニットID
    return 'ca-app-pub-3940256099942544/1033173712';
  }

  /// リワード広告ユニットIDを取得
  static String getRewardedAdUnitId() {
    // テスト用広告ユニットID
    return 'ca-app-pub-3940256099942544/5224354917';
  }
}
