import 'package:flutter/foundation.dart';
import 'analytics_models.dart';
import 'analytics_configuration.dart';

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