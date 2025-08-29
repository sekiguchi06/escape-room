import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import '../analytics_system.dart';

/// Firebase Analyticsを使用したAnalyticsProviderの実装
class FirebaseAnalyticsProvider implements AnalyticsProvider {
  AnalyticsConfiguration? _config;
  FirebaseAnalytics? _analytics;
  String? _currentUserId;
  String? _currentSessionId;
  int _eventCount = 0;

  @override
  Future<bool> initialize(AnalyticsConfiguration config) async {
    _config = config;

    try {
      // Firebase Core初期化確認
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }

      // Firebase Analytics初期化 - 設定ファイルが見つからない場合は警告のみ出力
      _analytics = FirebaseAnalytics.instance;

      // データ収集設定 - エラーが発生しても継続
      try {
        await _analytics!.setAnalyticsCollectionEnabled(
          config.personalDataCollectionEnabled,
        );
      } catch (e) {
        debugPrint(
          '⚠️ Firebase Analytics collection setting failed (continuing): $e',
        );
      }

      if (config.debugMode) {
        debugPrint(
          'FirebaseAnalyticsProvider initialized (may be in mock mode)',
        );
        debugPrint(
          '  - Data collection: ${config.personalDataCollectionEnabled}',
        );
        debugPrint('  - Auto tracking: ${config.autoTrackingEnabled}');
      }

      return true;
    } catch (e) {
      debugPrint(
        '⚠️ FirebaseAnalyticsProvider initialization failed, using mock mode: $e',
      );
      _analytics = null; // Mock mode - events will be logged but not sent
      return true; // Continue execution with mock analytics
    }
  }

  @override
  Future<bool> trackEvent(AnalyticsEvent event) async {
    if (_config == null) return false;

    // MockモードでもAnalyticsイベントをログ出力
    if (_analytics == null) {
      if (_config!.debugMode) {
        debugPrint('📊 [MOCK] Analytics Event: ${event.name}');
        debugPrint('   Priority: ${event.priority.name}');
        debugPrint('   Parameters: ${event.parameters.length} items');
      }
      return true; // Mock mode always succeeds
    }

    try {
      // イベントフィルタリング
      if (!_config!.trackedEvents.contains(event.name)) {
        if (_config!.debugMode) {
          debugPrint('Event filtered out: ${event.name}');
        }
        return true;
      }

      // パラメータのサニタイズ
      final sanitizedParams = _sanitizeParameters(event.parameters);

      // カスタムディメンション追加
      final enrichedParams = <String, dynamic>{
        ...sanitizedParams,
        ..._config!.customDimensions,
        'event_priority': event.priority.name,
        'event_timestamp': event.timestamp.millisecondsSinceEpoch,
        if (_currentUserId != null) 'user_id': _currentUserId,
        if (_currentSessionId != null) 'session_id': _currentSessionId,
      };

      // Firebase Analyticsイベント送信
      await _analytics!.logEvent(
        name: _sanitizeEventName(event.name),
        parameters: enrichedParams.cast<String, Object>(),
      );

      _eventCount++;

      if (_config!.debugMode) {
        debugPrint('📊 Firebase Analytics Event: ${event.name}');
        debugPrint('   Priority: ${event.priority.name}');
        debugPrint('   Parameters: ${enrichedParams.length} items');
      }

      return true;
    } catch (e) {
      debugPrint('Firebase Analytics event tracking failed: $e');
      return false;
    }
  }

  @override
  Future<bool> trackEventBatch(List<AnalyticsEvent> events) async {
    if (_analytics == null) {
      if (_config?.debugMode == true) {
        debugPrint(
          '📊 [MOCK] Analytics batch tracking ${events.length} events',
        );
      }
      return true; // Mock mode always succeeds
    }

    try {
      var successCount = 0;

      if (_config?.debugMode == true) {
        debugPrint(
          '📊 Firebase Analytics batch tracking ${events.length} events...',
        );
      }

      for (final event in events) {
        if (await trackEvent(event)) {
          successCount++;
        }
      }

      if (_config?.debugMode == true) {
        debugPrint(
          '📊 Firebase Analytics batch completed: $successCount/${events.length} events',
        );
      }

      return successCount == events.length;
    } catch (e) {
      debugPrint('Firebase Analytics batch tracking failed: $e');
      return false;
    }
  }

  @override
  Future<bool> setUserProperty(String name, String value) async {
    if (_analytics == null) {
      if (_config?.debugMode == true) {
        debugPrint('👤 [MOCK] Analytics User Property: $name = $value');
      }
      return true; // Mock mode always succeeds
    }

    try {
      await _analytics!.setUserProperty(
        name: _sanitizePropertyName(name),
        value: value,
      );

      if (_config?.debugMode == true) {
        debugPrint('👤 Firebase Analytics User Property: $name = $value');
      }

      return true;
    } catch (e) {
      debugPrint('Firebase Analytics user property failed: $e');
      return false;
    }
  }

  @override
  Future<bool> setUserId(String userId) async {
    if (_analytics == null) {
      if (_config?.debugMode == true) {
        debugPrint('👤 [MOCK] Analytics User ID: $userId');
      }
      _currentUserId = userId;
      return true; // Mock mode always succeeds
    }

    try {
      _currentUserId = userId;
      await _analytics!.setUserId(id: userId);

      if (_config?.debugMode == true) {
        debugPrint('👤 Firebase Analytics User ID: $userId');
      }

      return true;
    } catch (e) {
      debugPrint('Firebase Analytics user ID failed: $e');
      return false;
    }
  }

  @override
  Future<bool> startSession(String sessionId) async {
    if (_analytics == null) return false;

    try {
      _currentSessionId = sessionId;

      // セッション開始イベント送信
      await _analytics!.logEvent(
        name: 'session_start',
        parameters: {
          'session_id': sessionId,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          if (_currentUserId != null) 'user_id': _currentUserId!,
        },
      );

      if (_config?.debugMode == true) {
        debugPrint('🎮 Firebase Analytics Session Start: $sessionId');
      }

      return true;
    } catch (e) {
      debugPrint('Firebase Analytics session start failed: $e');
      return false;
    }
  }

  @override
  Future<bool> endSession(String sessionId) async {
    if (_analytics == null) return false;

    try {
      // セッション終了イベント送信
      await _analytics!.logEvent(
        name: 'session_end',
        parameters: {
          'session_id': sessionId,
          'duration_seconds': _currentSessionId == sessionId
              ? DateTime.now().millisecondsSinceEpoch
              : 0,
          'events_tracked': _eventCount,
          if (_currentUserId != null) 'user_id': _currentUserId!,
        },
      );

      if (sessionId == _currentSessionId) {
        _currentSessionId = null;
      }

      if (_config?.debugMode == true) {
        debugPrint('🎮 Firebase Analytics Session End: $sessionId');
      }

      return true;
    } catch (e) {
      debugPrint('Firebase Analytics session end failed: $e');
      return false;
    }
  }

  @override
  Future<bool> trackScreenView(String screenName) async {
    if (_analytics == null) return false;

    try {
      await _analytics!.logScreenView(
        screenName: screenName,
        screenClass: screenName,
      );

      if (_config?.debugMode == true) {
        debugPrint('📱 Firebase Analytics Screen View: $screenName');
      }

      return true;
    } catch (e) {
      debugPrint('Firebase Analytics screen view failed: $e');
      return false;
    }
  }

  @override
  Future<bool> trackError(String error, String? stackTrace) async {
    if (_analytics == null) return false;

    try {
      await _analytics!.logEvent(
        name: 'error',
        parameters: {
          'error_message': error,
          if (stackTrace != null)
            'stack_trace': stackTrace.substring(
              0,
              stackTrace.length > 1000 ? 1000 : stackTrace.length,
            ),
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          if (_currentSessionId != null) 'session_id': _currentSessionId!,
          if (_currentUserId != null) 'user_id': _currentUserId!,
        },
      );

      if (_config?.debugMode == true) {
        debugPrint('🚨 Firebase Analytics Error: $error');
      }

      return true;
    } catch (e) {
      debugPrint('Firebase Analytics error tracking failed: $e');
      return false;
    }
  }

  @override
  Future<bool> trackMetric(String name, double value) async {
    if (_analytics == null) return false;

    try {
      await _analytics!.logEvent(
        name: 'custom_metric',
        parameters: {
          'metric_name': name,
          'metric_value': value,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          if (_currentSessionId != null) 'session_id': _currentSessionId!,
          if (_currentUserId != null) 'user_id': _currentUserId!,
        },
      );

      if (_config?.debugMode == true) {
        debugPrint('📊 Firebase Analytics Metric: $name = $value');
      }

      return true;
    } catch (e) {
      debugPrint('Firebase Analytics metric tracking failed: $e');
      return false;
    }
  }

  @override
  Future<bool> updateConfiguration(AnalyticsConfiguration config) async {
    _config = config;

    if (_analytics != null) {
      try {
        await _analytics!.setAnalyticsCollectionEnabled(
          config.personalDataCollectionEnabled,
        );

        if (config.debugMode) {
          debugPrint('Firebase Analytics configuration updated');
        }

        return true;
      } catch (e) {
        debugPrint('Firebase Analytics configuration update failed: $e');
        return false;
      }
    }

    return false;
  }

  @override
  Future<void> dispose() async {
    if (_config?.debugMode == true) {
      debugPrint(
        'FirebaseAnalyticsProvider disposed (tracked $_eventCount events)',
      );
    }

    _analytics = null;
    _config = null;
    _currentUserId = null;
    _currentSessionId = null;
    _eventCount = 0;
  }

  /// パラメータのサニタイズ（Firebase制限に準拠）
  Map<String, dynamic> _sanitizeParameters(Map<String, dynamic> params) {
    final sanitized = <String, dynamic>{};

    for (final entry in params.entries) {
      // 除外対象パラメータのスキップ
      if (_config?.excludedParameters.contains(entry.key) == true) {
        continue;
      }

      final key = _sanitizeParameterName(entry.key);
      var value = entry.value;

      // Firebase Analyticsの制限に準拠
      if (value is String && value.length > 100) {
        value = value.substring(0, 100);
      }

      sanitized[key] = value;
    }

    return sanitized;
  }

  /// イベント名のサニタイズ（Firebase制限に準拠）
  String _sanitizeEventName(String name) {
    // Firebase Analyticsイベント名制限: 40文字以内、英数字・アンダースコアのみ
    return name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9_]'), '_')
        .substring(0, name.length > 40 ? 40 : name.length);
  }

  /// パラメータ名のサニタイズ（Firebase制限に準拠）
  String _sanitizeParameterName(String name) {
    // Firebase Analyticsパラメータ名制限: 40文字以内、英数字・アンダースコアのみ
    return name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9_]'), '_')
        .substring(0, name.length > 40 ? 40 : name.length);
  }

  /// プロパティ名のサニタイズ（Firebase制限に準拠）
  String _sanitizePropertyName(String name) {
    // Firebase Analyticsユーザープロパティ名制限: 24文字以内、英数字・アンダースコアのみ
    return name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9_]'), '_')
        .substring(0, name.length > 24 ? 24 : name.length);
  }
}
