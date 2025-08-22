// 広告関連のモデルクラス

/// 広告の種類
enum AdType {
  banner, // バナー広告
  interstitial, // インタースティシャル広告
  rewarded, // リワード広告
  native, // ネイティブ広告
  appOpen, // アプリ起動広告
}

/// 広告表示結果
enum AdResult {
  loaded, // 広告読み込み成功
  shown, // 広告表示成功
  clicked, // 広告クリック
  closed, // 広告閉じた
  rewarded, // リワード獲得
  failed, // 広告失敗
  notReady, // 広告準備未完了
  noFill, // 広告配信なし
}

/// 広告イベントデータ
class AdEventData {
  final AdType adType;
  final AdResult result;
  final String? adId;
  final String? errorMessage;
  final Map<String, dynamic> additionalData;
  final DateTime timestamp;

  const AdEventData({
    required this.adType,
    required this.result,
    this.adId,
    this.errorMessage,
    this.additionalData = const {},
    required this.timestamp,
  });

  @override
  String toString() {
    return 'AdEventData(type: $adType, result: $result, id: $adId, error: $errorMessage)';
  }
}
