import 'package:flutter/foundation.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import '../analytics_system.dart';

/// ユーザーおよびセッション管理を担当するクラス
class UserSessionHandler {
  final AnalyticsConfiguration config;
  final FirebaseAnalytics? analytics;

  String? _currentUserId;
  String? _currentSessionId;

  UserSessionHandler({
    required this.config,
    required this.analytics,
  });

  Future<bool> setUserProperty(String name, String value) async {
    if (analytics == null) {
      if (config.debugMode) {
        debugPrint('📊 [MOCK] User Property: $name = $value');
      }
      return true;
    }

    try {
      final sanitizedName = _sanitizePropertyName(name);
      await analytics!.setUserProperty(
        name: sanitizedName,
        value: value.length > 36 ? value.substring(0, 36) : value,
      );

      if (config.debugMode) {
        debugPrint('📊 Firebase Analytics User Property: $name = $value');
      }

      return true;
    } catch (e) {
      debugPrint('Firebase Analytics user property setting failed: $e');
      return false;
    }
  }

  Future<bool> setUserId(String userId) async {
    if (analytics == null) {
      if (config.debugMode) {
        debugPrint('📊 [MOCK] User ID: $userId');
      }
      _currentUserId = userId;
      return true;
    }

    try {
      await analytics!.setUserId(id: userId);
      _currentUserId = userId;

      if (config.debugMode) {
        debugPrint('📊 Firebase Analytics User ID set: $userId');
      }

      return true;
    } catch (e) {
      debugPrint('Firebase Analytics user ID setting failed: $e');
      return false;
    }
  }

  Future<bool> startSession(String sessionId) async {
    if (analytics == null) {
      if (config.debugMode) {
        debugPrint('📊 [MOCK] Session started: $sessionId');
      }
      _currentSessionId = sessionId;
      return true;
    }

    try {
      _currentSessionId = sessionId;

      await analytics!.logEvent(
        name: 'session_start',
        parameters: {
          'session_id': sessionId,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          if (_currentUserId != null) 'user_id': _currentUserId!,
        },
      );

      if (config.debugMode) {
        debugPrint('📊 Firebase Analytics Session started: $sessionId');
      }

      return true;
    } catch (e) {
      debugPrint('Firebase Analytics session start failed: $e');
      return false;
    }
  }

  Future<bool> endSession(String sessionId) async {
    if (analytics == null) {
      if (config.debugMode) {
        debugPrint('📊 [MOCK] Session ended: $sessionId');
      }
      if (_currentSessionId == sessionId) {
        _currentSessionId = null;
      }
      return true;
    }

    try {
      await analytics!.logEvent(
        name: 'session_end',
        parameters: {
          'session_id': sessionId,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          if (_currentUserId != null) 'user_id': _currentUserId!,
        },
      );

      if (_currentSessionId == sessionId) {
        _currentSessionId = null;
      }

      if (config.debugMode) {
        debugPrint('📊 Firebase Analytics Session ended: $sessionId');
      }

      return true;
    } catch (e) {
      debugPrint('Firebase Analytics session end failed: $e');
      return false;
    }
  }

  String? get currentUserId => _currentUserId;
  String? get currentSessionId => _currentSessionId;

  String _sanitizePropertyName(String name) {
    final sanitized = name
        .replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_')
        .toLowerCase();
    return sanitized.length > 24 ? sanitized.substring(0, 24) : sanitized;
  }
}