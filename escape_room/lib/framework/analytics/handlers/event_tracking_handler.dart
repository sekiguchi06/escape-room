import 'package:flutter/foundation.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import '../analytics_system.dart';

/// イベント追跡の処理を担当するクラス
class EventTrackingHandler {
  final AnalyticsConfiguration config;
  final FirebaseAnalytics? analytics;
  final String? Function() getCurrentUserId;
  final String? Function() getCurrentSessionId;

  int _eventCount = 0;

  EventTrackingHandler({
    required this.config,
    required this.analytics,
    required this.getCurrentUserId,
    required this.getCurrentSessionId,
  });

  Future<bool> trackEvent(AnalyticsEvent event) async {
    // MockモードでもAnalyticsイベントをログ出力
    if (analytics == null) {
      if (config.debugMode) {
        debugPrint('📊 [MOCK] Analytics Event: ${event.name}');
        debugPrint('   Priority: ${event.priority.name}');
        debugPrint('   Parameters: ${event.parameters.length} items');
      }
      return true; // Mock mode always succeeds
    }

    try {
      // イベントフィルタリング
      if (!config.trackedEvents.contains(event.name)) {
        if (config.debugMode) {
          debugPrint('Event filtered out: ${event.name}');
        }
        return true;
      }

      // パラメータのサニタイズ
      final sanitizedParams = _sanitizeParameters(event.parameters);

      // カスタムディメンション追加
      final enrichedParams = <String, dynamic>{
        ...sanitizedParams,
        ...config.customDimensions,
        'event_priority': event.priority.name,
        'event_timestamp': event.timestamp.millisecondsSinceEpoch,
        if (getCurrentUserId() != null) 'user_id': getCurrentUserId(),
        if (getCurrentSessionId() != null) 'session_id': getCurrentSessionId(),
      };

      // Firebase Analyticsイベント送信
      await analytics!.logEvent(
        name: _sanitizeEventName(event.name),
        parameters: enrichedParams.cast<String, Object>(),
      );

      _eventCount++;

      if (config.debugMode) {
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

  Future<bool> trackEventBatch(List<AnalyticsEvent> events) async {
    if (analytics == null) {
      if (config.debugMode) {
        debugPrint(
          '📊 [MOCK] Analytics batch tracking ${events.length} events',
        );
      }
      return true; // Mock mode always succeeds
    }

    try {
      var successCount = 0;

      if (config.debugMode) {
        debugPrint(
          '📊 Firebase Analytics batch tracking ${events.length} events...',
        );
      }

      for (final event in events) {
        if (await trackEvent(event)) {
          successCount++;
        }
      }

      if (config.debugMode) {
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

  Future<bool> trackMetric(String name, double value) async {
    if (analytics == null) {
      if (config.debugMode) {
        debugPrint('📊 [MOCK] Analytics Metric: $name = $value');
      }
      return true;
    }

    try {
      final sanitizedName = _sanitizeEventName(name);
      await analytics!.logEvent(
        name: 'metric_$sanitizedName',
        parameters: {
          'metric_name': sanitizedName,
          'metric_value': value,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        },
      );

      if (config.debugMode) {
        debugPrint('📊 Firebase Analytics Metric: $name = $value');
      }

      return true;
    } catch (e) {
      debugPrint('Firebase Analytics metric tracking failed: $e');
      return false;
    }
  }

  int get eventCount => _eventCount;

  Map<String, dynamic> _sanitizeParameters(Map<String, dynamic> params) {
    final sanitized = <String, dynamic>{};

    for (final entry in params.entries) {
      final key = _sanitizeParameterName(entry.key);
      dynamic value = entry.value;

      if (value is String && value.length > 100) {
        value = value.substring(0, 100);
      } else if (value is List) {
        value = value.take(10).toList();
      } else if (value is Map) {
        value = Map.fromEntries(value.entries.take(10));
      }

      if (value != null) {
        sanitized[key] = value;
      }
    }

    return sanitized;
  }

  String _sanitizeEventName(String name) {
    final sanitized = name
        .replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_')
        .toLowerCase();
    return sanitized.length > 40 ? sanitized.substring(0, 40) : sanitized;
  }

  String _sanitizeParameterName(String name) {
    final sanitized = name
        .replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_')
        .toLowerCase();
    return sanitized.length > 40 ? sanitized.substring(0, 40) : sanitized;
  }
}