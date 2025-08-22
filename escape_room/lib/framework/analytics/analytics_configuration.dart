/// 分析設定の基底クラス
abstract class AnalyticsConfiguration {
  /// イベント送信間隔（秒）
  int get batchInterval;

  /// バッチサイズ（イベント数）
  int get batchSize;

  /// 自動追跡有効フラグ
  bool get autoTrackingEnabled;

  /// 個人情報収集許可フラグ
  bool get personalDataCollectionEnabled;

  /// デバッグモード
  bool get debugMode;

  /// オフライン時のイベント保存有効フラグ
  bool get offlineEventsEnabled;

  /// イベント保存最大数（オフライン時）
  int get maxOfflineEvents;

  /// 追跡対象イベント一覧
  Set<String> get trackedEvents;

  /// 除外対象パラメータ（プライバシー保護）
  Set<String> get excludedParameters;

  /// カスタムディメンション
  Map<String, String> get customDimensions;
}

/// デフォルト分析設定
class DefaultAnalyticsConfiguration implements AnalyticsConfiguration {
  @override
  final int batchInterval;

  @override
  final int batchSize;

  @override
  final bool autoTrackingEnabled;

  @override
  final bool personalDataCollectionEnabled;

  @override
  final bool debugMode;

  @override
  final bool offlineEventsEnabled;

  @override
  final int maxOfflineEvents;

  @override
  final Set<String> trackedEvents;

  @override
  final Set<String> excludedParameters;

  @override
  final Map<String, String> customDimensions;

  const DefaultAnalyticsConfiguration({
    this.batchInterval = 30,
    this.batchSize = 20,
    this.autoTrackingEnabled = true,
    this.personalDataCollectionEnabled = true,
    this.debugMode = false,
    this.offlineEventsEnabled = true,
    this.maxOfflineEvents = 1000,
    this.trackedEvents = const {
      'game_start',
      'game_end',
      'level_start',
      'level_complete',
      'level_fail',
      'ad_shown',
      'purchase',
      'error',
    },
    this.excludedParameters = const {
      'password',
      'email',
      'phone',
      'credit_card',
    },
    this.customDimensions = const {},
  });

  DefaultAnalyticsConfiguration copyWith({
    int? batchInterval,
    int? batchSize,
    bool? autoTrackingEnabled,
    bool? personalDataCollectionEnabled,
    bool? debugMode,
    bool? offlineEventsEnabled,
    int? maxOfflineEvents,
    Set<String>? trackedEvents,
    Set<String>? excludedParameters,
    Map<String, String>? customDimensions,
  }) {
    return DefaultAnalyticsConfiguration(
      batchInterval: batchInterval ?? this.batchInterval,
      batchSize: batchSize ?? this.batchSize,
      autoTrackingEnabled: autoTrackingEnabled ?? this.autoTrackingEnabled,
      personalDataCollectionEnabled:
          personalDataCollectionEnabled ?? this.personalDataCollectionEnabled,
      debugMode: debugMode ?? this.debugMode,
      offlineEventsEnabled: offlineEventsEnabled ?? this.offlineEventsEnabled,
      maxOfflineEvents: maxOfflineEvents ?? this.maxOfflineEvents,
      trackedEvents: trackedEvents ?? this.trackedEvents,
      excludedParameters: excludedParameters ?? this.excludedParameters,
      customDimensions: customDimensions ?? this.customDimensions,
    );
  }
}
