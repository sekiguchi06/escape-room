import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/game_error_models.dart';
import '../strategies/error_recovery_strategies.dart';

/// Flutter公式準拠エラーハンドラー
class FlutterGameErrorHandler {
  static FlutterGameErrorHandler? _instance;
  final List<GameError> _errorHistory = [];
  final Map<GameErrorType, int> _errorCounts = {};
  final List<ErrorRecoveryStrategy> _recoveryStrategies = [];
  final List<void Function(GameError)> _errorListeners = [];
  final int maxHistorySize;
  final bool debugMode;

  /// Flutter公式推奨: シングルトンパターン
  factory FlutterGameErrorHandler({
    int maxHistorySize = 100,
    bool debugMode = false,
  }) {
    _instance ??= FlutterGameErrorHandler._internal(
      maxHistorySize: maxHistorySize,
      debugMode: debugMode,
    );
    return _instance!;
  }

  FlutterGameErrorHandler._internal({
    required this.maxHistorySize,
    required this.debugMode,
  });

  /// エラーハンドラー初期化
  void initialize() {
    // Flutter公式エラーハンドラー登録
    FlutterError.onError = (FlutterErrorDetails details) {
      // FlutterエラーをGameErrorに変換
      final gameError = GameError(
        type: _classifyFlutterError(details),
        message: details.exception.toString(),
        details: details.summary.toString(),
        originalError: details.exception,
        stackTrace: details.stack,
        timestamp: DateTime.now(),
      );

      handleError(gameError);

      // デバッグモードでは詳細を出力
      if (debugMode) {
        FlutterError.presentError(details);
      }
    };

    // デフォルトリカバリー戦略追加
    addRecoveryStrategy(NetworkErrorRecoveryStrategy());

    if (debugMode) {
      debugPrint('🛡️ FlutterGameErrorHandler initialized');
    }
  }

  /// エラータイプ分類
  GameErrorType _classifyFlutterError(FlutterErrorDetails details) {
    final exception = details.exception;
    final message = exception.toString().toLowerCase();

    if (exception is NetworkImageLoadException ||
        message.contains('network') ||
        message.contains('connection')) {
      return GameErrorType.network;
    } else if (exception is PlatformException) {
      if (message.contains('permission')) {
        return GameErrorType.permission;
      } else if (message.contains('audio') || message.contains('sound')) {
        return GameErrorType.audioPlayback;
      }
    } else if (message.contains('asset') || message.contains('resource')) {
      return GameErrorType.resourceLoad;
    } else if (message.contains('config')) {
      return GameErrorType.configuration;
    }

    return GameErrorType.unknown;
  }

  /// エラー処理メイン関数
  Future<void> handleError(GameError error) async {
    // エラー履歴に追加
    _errorHistory.add(error);
    if (_errorHistory.length > maxHistorySize) {
      _errorHistory.removeAt(0);
    }

    // エラーカウント更新
    _errorCounts[error.type] = (_errorCounts[error.type] ?? 0) + 1;

    // デバッグ出力
    if (debugMode) {
      debugPrint('❌ ${error.type.name}: ${error.message}');
      if (error.details != null) {
        debugPrint('   Details: ${error.details}');
      }
    }

    // リカバリー戦略実行
    bool recovered = false;
    for (final strategy in _recoveryStrategies) {
      if (strategy.canHandle(error)) {
        recovered = await strategy.attemptRecovery(error);
        if (recovered) break;
      }
    }

    // リスナー通知
    for (final listener in _errorListeners) {
      listener(error);
    }

    // リカバリー失敗時の処理
    if (!recovered && debugMode) {
      debugPrint('⚠️ Error recovery failed for ${error.type.name}');
    }
  }

  /// リカバリー戦略追加
  void addRecoveryStrategy(ErrorRecoveryStrategy strategy) {
    _recoveryStrategies.add(strategy);
  }

  /// エラーリスナー追加
  void addErrorListener(void Function(GameError) listener) {
    _errorListeners.add(listener);
  }

  /// エラーリスナー削除
  void removeErrorListener(void Function(GameError) listener) {
    _errorListeners.remove(listener);
  }

  /// エラー統計取得
  Map<String, dynamic> getErrorStatistics() {
    return {
      'totalErrors': _errorHistory.length,
      'errorCounts': Map<String, int>.from(
        _errorCounts.map((key, value) => MapEntry(key.name, value)),
      ),
      'recentErrors': _errorHistory.reversed
          .take(10)
          .map(
            (e) => {
              'type': e.type.name,
              'message': e.message,
              'timestamp': e.timestamp.toIso8601String(),
            },
          )
          .toList(),
    };
  }

  /// エラー履歴クリア
  void clearErrorHistory() {
    _errorHistory.clear();
    _errorCounts.clear();
  }

  /// デバッグ情報取得
  Map<String, dynamic> getDebugInfo() {
    return {
      'flutter_official_compliant': true,
      'initialized': true,
      'debug_mode': debugMode,
      'error_history_size': _errorHistory.length,
      'max_history_size': maxHistorySize,
      'recovery_strategies': _recoveryStrategies.length,
      'error_listeners': _errorListeners.length,
      'statistics': getErrorStatistics(),
    };
  }

  /// リソース解放
  void dispose() {
    _errorHistory.clear();
    _errorCounts.clear();
    _recoveryStrategies.clear();
    _errorListeners.clear();

    // FlutterError.onErrorをデフォルトに戻す
    FlutterError.onError = FlutterError.presentError;
  }
}
