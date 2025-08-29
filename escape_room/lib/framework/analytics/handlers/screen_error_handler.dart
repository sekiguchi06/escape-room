import 'package:flutter/foundation.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import '../analytics_system.dart';

/// スクリーンビューとエラー追跡を担当するクラス
class ScreenErrorHandler {
  final AnalyticsConfiguration config;
  final FirebaseAnalytics? analytics;
  final String? Function() getCurrentUserId;
  final String? Function() getCurrentSessionId;

  ScreenErrorHandler({
    required this.config,
    required this.analytics,
    required this.getCurrentUserId,
    required this.getCurrentSessionId,
  });

  Future<bool> trackScreenView(String screenName) async {
    if (analytics == null) {
      if (config.debugMode) {
        debugPrint('📊 [MOCK] Screen View: $screenName');
      }
      return true;
    }

    try {
      await analytics!.logEvent(
        name: 'screen_view',
        parameters: {
          'screen_name': screenName,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          if (getCurrentUserId() != null) 'user_id': getCurrentUserId()!,
          if (getCurrentSessionId() != null) 'session_id': getCurrentSessionId()!,
        },
      );

      if (config.debugMode) {
        debugPrint('📊 Firebase Analytics Screen View: $screenName');
      }

      return true;
    } catch (e) {
      debugPrint('Firebase Analytics screen view tracking failed: $e');
      return false;
    }
  }

  Future<bool> trackError(String error, String? stackTrace) async {
    if (analytics == null) {
      if (config.debugMode) {
        debugPrint('📊 [MOCK] Error: $error');
        if (stackTrace != null) {
          debugPrint('📊 [MOCK] Stack Trace: ${stackTrace.substring(0, 200)}...');
        }
      }
      return true;
    }

    try {
      final parameters = <String, dynamic>{
        'error_message': error.length > 100 ? error.substring(0, 100) : error,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        if (getCurrentUserId() != null) 'user_id': getCurrentUserId()!,
        if (getCurrentSessionId() != null) 'session_id': getCurrentSessionId()!,
      };

      if (stackTrace != null) {
        parameters['stack_trace'] = stackTrace.length > 1000 
            ? stackTrace.substring(0, 1000) 
            : stackTrace;
      }

      await analytics!.logEvent(
        name: 'error_occurred',
        parameters: parameters.cast<String, Object>(),
      );

      if (config.debugMode) {
        debugPrint('📊 Firebase Analytics Error: $error');
      }

      return true;
    } catch (e) {
      debugPrint('Firebase Analytics error tracking failed: $e');
      return false;
    }
  }

  Future<bool> trackCrashlytics(String error, String? stackTrace) async {
    // Crashlytics連携は将来の拡張用
    if (config.debugMode) {
      debugPrint('📊 Crashlytics tracking (future enhancement): $error');
    }
    return true;
  }
}