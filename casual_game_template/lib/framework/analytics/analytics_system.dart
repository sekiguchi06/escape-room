import 'package:flutter/foundation.dart';
import 'dart:convert';

/// 分析イベントの重要度
enum EventPriority {
  critical,   // 課金、エラー等
  high,       // レベルクリア、ゲームオーバー等
  medium,     // ゲーム開始、アイテム使用等
  low,        // UI操作、画面表示等
}

/// 分析イベントデータ
class AnalyticsEvent {
  final String name;
  final Map<String, dynamic> parameters;
  final EventPriority priority;
  final DateTime timestamp;
  final String? userId;
  final String? sessionId;
  
  const AnalyticsEvent({
    required this.name,
    this.parameters = const {},
    this.priority = EventPriority.medium,
    required this.timestamp,
    this.userId,
    this.sessionId,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'parameters': parameters,
      'priority': priority.name,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'user_id': userId,
      'session_id': sessionId,
    };
  }
  
  @override
  String toString() {
    return 'AnalyticsEvent(name: $name, priority: $priority, params: ${parameters.length})';
  }
}

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
      personalDataCollectionEnabled: personalDataCollectionEnabled ?? this.personalDataCollectionEnabled,
      debugMode: debugMode ?? this.debugMode,
      offlineEventsEnabled: offlineEventsEnabled ?? this.offlineEventsEnabled,
      maxOfflineEvents: maxOfflineEvents ?? this.maxOfflineEvents,
      trackedEvents: trackedEvents ?? this.trackedEvents,
      excludedParameters: excludedParameters ?? this.excludedParameters,
      customDimensions: customDimensions ?? this.customDimensions,
    );
  }
}

/// 分析プロバイダーの抽象インターフェース
abstract class AnalyticsProvider {
  /// 初期化
  Future<bool> initialize(AnalyticsConfiguration config);
  
  /// イベント送信
  Future<bool> trackEvent(AnalyticsEvent event);
  
  /// バッチイベント送信
  Future<bool> trackEventBatch(List<AnalyticsEvent> events);
  
  /// ユーザープロパティ設定
  Future<bool> setUserProperty(String name, String value);
  
  /// ユーザーID設定
  Future<bool> setUserId(String userId);
  
  /// セッション開始
  Future<bool> startSession(String sessionId);
  
  /// セッション終了
  Future<bool> endSession(String sessionId);
  
  /// 画面表示追跡
  Future<bool> trackScreenView(String screenName);
  
  /// エラー追跡
  Future<bool> trackError(String error, String? stackTrace);
  
  /// カスタムメトリクス送信
  Future<bool> trackMetric(String name, double value);
  
  /// 設定更新
  Future<bool> updateConfiguration(AnalyticsConfiguration config);
  
  /// リソース解放
  Future<void> dispose();
}

/// コンソール分析プロバイダー（デバッグ用）
class ConsoleAnalyticsProvider implements AnalyticsProvider {
  AnalyticsConfiguration? _config;
  String? _currentUserId;
  String? _currentSessionId;
  int _eventCount = 0;
  
  @override
  Future<bool> initialize(AnalyticsConfiguration config) async {
    _config = config;
    
    if (config.debugMode) {
      debugPrint('ConsoleAnalyticsProvider initialized');
      debugPrint('  - Auto tracking: ${config.autoTrackingEnabled}');
      debugPrint('  - Batch size: ${config.batchSize}');
      debugPrint('  - Batch interval: ${config.batchInterval}s');
    }
    
    return true;
  }
  
  @override
  Future<bool> trackEvent(AnalyticsEvent event) async {
    if (_config == null) return false;
    
    // イベントフィルタリング
    if (!_config!.trackedEvents.contains(event.name)) {
      if (_config!.debugMode) {
        debugPrint('Event filtered out: ${event.name}');
      }
      return true;  // フィルタリングされたイベントも成功扱い
    }
    
    // パラメータのサニタイズ
    final sanitizedParams = _sanitizeParameters(event.parameters);
    
    // カスタムディメンション追加
    final enrichedParams = <String, dynamic>{
      ...sanitizedParams,
      ..._config!.customDimensions,
      if (_currentUserId != null) 'user_id': _currentUserId,
      if (_currentSessionId != null) 'session_id': _currentSessionId,
    };
    
    final enrichedEvent = AnalyticsEvent(
      name: event.name,
      parameters: enrichedParams,
      priority: event.priority,
      timestamp: event.timestamp,
      userId: _currentUserId,
      sessionId: _currentSessionId,
    );
    
    _eventCount++;
    
    // コンソール出力
    debugPrint('📊 Analytics Event #$_eventCount: ${enrichedEvent.name}');
    if (_config!.debugMode) {
      debugPrint('   Priority: ${enrichedEvent.priority.name}');
      debugPrint('   Timestamp: ${enrichedEvent.timestamp.toIso8601String()}');
      if (enrichedParams.isNotEmpty) {
        debugPrint('   Parameters:');
        enrichedParams.forEach((key, value) {
          debugPrint('     $key: $value');
        });
      }
    }
    
    return true;
  }
  
  @override
  Future<bool> trackEventBatch(List<AnalyticsEvent> events) async {
    if (_config?.debugMode == true) {
      debugPrint('📊 Batch tracking ${events.length} events...');
    }
    
    for (final event in events) {
      await trackEvent(event);
    }
    
    if (_config?.debugMode == true) {
      debugPrint('📊 Batch tracking completed');
    }
    
    return true;
  }
  
  @override
  Future<bool> setUserProperty(String name, String value) async {
    if (_config?.debugMode == true) {
      debugPrint('👤 User Property: $name = $value');
    }
    return true;
  }
  
  @override
  Future<bool> setUserId(String userId) async {
    _currentUserId = userId;
    if (_config?.debugMode == true) {
      debugPrint('👤 User ID: $userId');
    }
    return true;
  }
  
  @override
  Future<bool> startSession(String sessionId) async {
    _currentSessionId = sessionId;
    if (_config?.debugMode == true) {
      debugPrint('🎮 Session Start: $sessionId');
    }
    return true;
  }
  
  @override
  Future<bool> endSession(String sessionId) async {
    if (_config?.debugMode == true) {
      debugPrint('🎮 Session End: $sessionId');
    }
    _currentSessionId = null;
    return true;
  }
  
  @override
  Future<bool> trackScreenView(String screenName) async {
    return await trackEvent(AnalyticsEvent(
      name: 'screen_view',
      parameters: {'screen_name': screenName},
      priority: EventPriority.low,
      timestamp: DateTime.now(),
    ));
  }
  
  @override
  Future<bool> trackError(String error, String? stackTrace) async {
    return await trackEvent(AnalyticsEvent(
      name: 'error',
      parameters: {
        'error_message': error,
        if (stackTrace != null) 'stack_trace': stackTrace,
      },
      priority: EventPriority.critical,
      timestamp: DateTime.now(),
    ));
  }
  
  @override
  Future<bool> trackMetric(String name, double value) async {
    return await trackEvent(AnalyticsEvent(
      name: 'custom_metric',
      parameters: {
        'metric_name': name,
        'metric_value': value,
      },
      priority: EventPriority.medium,
      timestamp: DateTime.now(),
    ));
  }
  
  Map<String, dynamic> _sanitizeParameters(Map<String, dynamic> parameters) {
    if (!_config!.personalDataCollectionEnabled) {
      return parameters.map((key, value) {
        if (_config!.excludedParameters.contains(key.toLowerCase())) {
          return MapEntry(key, '[REDACTED]');
        }
        return MapEntry(key, value);
      });
    }
    return parameters;
  }
  
  @override
  Future<bool> updateConfiguration(AnalyticsConfiguration config) async {
    _config = config;
    return true;
  }
  
  @override
  Future<void> dispose() async {
    if (_config?.debugMode == true) {
      debugPrint('ConsoleAnalyticsProvider disposed (tracked $_eventCount events)');
    }
  }
}

/// 分析マネージャー
class AnalyticsManager {
  AnalyticsProvider _provider;
  AnalyticsConfiguration _configuration;
  final List<AnalyticsEvent> _eventQueue = [];
  DateTime _lastBatchSend = DateTime.now();
  String? _currentSessionId;
  int _sessionEventCount = 0;
  final Map<String, int> _eventCounts = {};
  
  AnalyticsManager({
    required AnalyticsProvider provider,
    required AnalyticsConfiguration configuration,
  }) : _provider = provider, _configuration = configuration;
  
  /// 現在のプロバイダー
  AnalyticsProvider get provider => _provider;
  
  /// 現在の設定
  AnalyticsConfiguration get configuration => _configuration;
  
  /// 現在のセッションID
  String? get currentSessionId => _currentSessionId;
  
  /// 初期化
  Future<bool> initialize() async {
    final success = await _provider.initialize(_configuration);
    
    if (success && _configuration.autoTrackingEnabled) {
      // 自動セッション開始
      await startSession();
    }
    
    return success;
  }
  
  /// プロバイダー変更
  Future<void> setProvider(AnalyticsProvider newProvider) async {
    // 残りのイベントを送信
    await flushEvents();
    
    await _provider.dispose();
    _provider = newProvider;
    await _provider.initialize(_configuration);
  }
  
  /// 設定更新
  Future<void> updateConfiguration(AnalyticsConfiguration newConfiguration) async {
    _configuration = newConfiguration;
    await _provider.updateConfiguration(_configuration);
  }
  
  /// イベント追跡
  Future<bool> trackEvent(String eventName, {
    Map<String, dynamic> parameters = const {},
    EventPriority priority = EventPriority.medium,
  }) async {
    final event = AnalyticsEvent(
      name: eventName,
      parameters: parameters,
      priority: priority,
      timestamp: DateTime.now(),
      userId: null,  // プロバイダーで設定
      sessionId: _currentSessionId,
    );
    
    return await _trackEvent(event);
  }
  
  Future<bool> _trackEvent(AnalyticsEvent event) async {
    // 統計更新
    _eventCounts[event.name] = (_eventCounts[event.name] ?? 0) + 1;
    _sessionEventCount++;
    
    // キューに追加
    _eventQueue.add(event);
    
    // バッチ送信チェック
    await _checkBatchSend();
    
    return true;
  }
  
  /// バッチ送信チェック
  Future<void> _checkBatchSend() async {
    final now = DateTime.now();
    final elapsed = now.difference(_lastBatchSend).inSeconds;
    
    if (_eventQueue.length >= _configuration.batchSize || 
        elapsed >= _configuration.batchInterval) {
      await flushEvents();
    }
  }
  
  /// イベント即座送信
  Future<bool> flushEvents() async {
    if (_eventQueue.isEmpty) return true;
    
    final eventsToSend = List<AnalyticsEvent>.from(_eventQueue);
    _eventQueue.clear();
    
    final success = await _provider.trackEventBatch(eventsToSend);
    
    if (success) {
      _lastBatchSend = DateTime.now();
    } else {
      // 失敗時はキューに戻す（オフライン対応）
      if (_configuration.offlineEventsEnabled) {
        _eventQueue.insertAll(0, eventsToSend);
        
        // 最大イベント数チェック
        if (_eventQueue.length > _configuration.maxOfflineEvents) {
          _eventQueue.removeRange(0, _eventQueue.length - _configuration.maxOfflineEvents);
        }
      }
    }
    
    return success;
  }
  
  /// セッション開始
  Future<bool> startSession() async {
    _currentSessionId = 'session_${DateTime.now().millisecondsSinceEpoch}';
    _sessionEventCount = 0;
    
    final success = await _provider.startSession(_currentSessionId!);
    
    if (success && _configuration.autoTrackingEnabled) {
      await trackEvent('session_start', parameters: {
        'session_id': _currentSessionId!,
      });
    }
    
    return success;
  }
  
  /// セッション終了
  Future<bool> endSession() async {
    if (_currentSessionId == null) return true;
    
    if (_configuration.autoTrackingEnabled) {
      await trackEvent('session_end', parameters: {
        'session_id': _currentSessionId!,
        'session_event_count': _sessionEventCount,
        'session_duration_seconds': 0,  // 実際の実装では計算が必要
      });
    }
    
    await flushEvents();
    
    final success = await _provider.endSession(_currentSessionId!);
    _currentSessionId = null;
    
    return success;
  }
  
  /// ユーザーID設定
  Future<bool> setUserId(String userId) async {
    return await _provider.setUserId(userId);
  }
  
  /// ユーザープロパティ設定
  Future<bool> setUserProperty(String name, String value) async {
    return await _provider.setUserProperty(name, value);
  }
  
  /// 画面表示追跡
  Future<bool> trackScreenView(String screenName) async {
    return await _provider.trackScreenView(screenName);
  }
  
  /// エラー追跡
  Future<bool> trackError(String error, {String? stackTrace}) async {
    return await _provider.trackError(error, stackTrace);
  }
  
  /// カスタムメトリクス送信
  Future<bool> trackMetric(String name, double value) async {
    return await _provider.trackMetric(name, value);
  }
  
  /// ゲーム固有イベント
  Future<bool> trackGameStart({Map<String, dynamic> gameConfig = const {}}) async {
    return await trackEvent('game_start', 
      parameters: gameConfig,
      priority: EventPriority.high,
    );
  }
  
  Future<bool> trackGameEnd({
    required int score,
    required Duration duration,
    Map<String, dynamic> additionalData = const {},
  }) async {
    return await trackEvent('game_end', parameters: {
      'score': score,
      'duration_seconds': duration.inSeconds,
      ...additionalData,
    }, priority: EventPriority.high);
  }
  
  Future<bool> trackLevelComplete({
    required int level,
    required int score,
    required Duration duration,
  }) async {
    return await trackEvent('level_complete', parameters: {
      'level': level,
      'score': score,
      'duration_seconds': duration.inSeconds,
    }, priority: EventPriority.high);
  }
  
  Future<bool> trackAdShown({
    required String adType,
    required String adId,
  }) async {
    return await trackEvent('ad_shown', parameters: {
      'ad_type': adType,
      'ad_id': adId,
    }, priority: EventPriority.medium);
  }
  
  Future<bool> trackPurchase({
    required String itemId,
    required double price,
    required String currency,
  }) async {
    return await trackEvent('purchase', parameters: {
      'item_id': itemId,
      'price': price,
      'currency': currency,
    }, priority: EventPriority.critical);
  }
  
  /// フレーム更新での定期処理
  void update() {
    // 定期的なバッチ送信チェック
    _checkBatchSend();
  }
  
  /// 統計情報取得
  Map<String, dynamic> getStatistics() {
    return {
      'session_id': _currentSessionId,
      'session_event_count': _sessionEventCount,
      'queued_events': _eventQueue.length,
      'event_counts': _eventCounts,
      'last_batch_send': _lastBatchSend.toIso8601String(),
      'total_tracked_events': _eventCounts.values.fold(0, (sum, count) => sum + count),
    };
  }
  
  /// デバッグ情報
  Map<String, dynamic> getDebugInfo() {
    return {
      'manager': runtimeType.toString(),
      'provider': _provider.runtimeType.toString(),
      'configuration': _configuration.runtimeType.toString(),
      'auto_tracking_enabled': _configuration.autoTrackingEnabled,
      'batch_size': _configuration.batchSize,
      'batch_interval': _configuration.batchInterval,
      'statistics': getStatistics(),
    };
  }
  
  /// リソース解放
  Future<void> dispose() async {
    await endSession();
    await flushEvents();
    await _provider.dispose();
  }
}