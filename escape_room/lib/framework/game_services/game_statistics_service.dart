import 'package:flutter/foundation.dart';
import 'game_services_configuration.dart';

/// ゲーム統計情報管理サービス
class GameStatisticsService {
  final GameServicesConfiguration _config;
  final Map<String, dynamic> _statistics = <String, dynamic>{};
  int _gameStartCount = 0;
  DateTime? _lastGameStart;
  DateTime? _sessionStart;

  GameStatisticsService(this._config);

  /// ゲーム開始回数をインクリメント
  void incrementGameStartCount() {
    _gameStartCount++;
    _lastGameStart = DateTime.now();
    _sessionStart = DateTime.now();

    if (_config.debugMode) {
      debugPrint('🎮 Game start count incremented to: $_gameStartCount');
    }
  }

  /// 統計情報を更新
  void updateStatistic(String key, dynamic value) {
    _statistics[key] = value;

    if (_config.debugMode) {
      debugPrint('📊 Statistic updated: $key = $value');
    }
  }

  /// 統計情報を取得
  dynamic getStatistic(String key) {
    return _statistics[key];
  }

  /// 現在のセッション時間を取得
  Duration? get currentSessionDuration {
    if (_sessionStart == null) return null;
    return DateTime.now().difference(_sessionStart!);
  }

  /// 統計情報の完全なレポートを取得
  Map<String, dynamic> getStatistics() {
    final sessionDuration = currentSessionDuration;

    return {
      'gameStartCount': _gameStartCount,
      'lastGameStart': _lastGameStart?.toIso8601String(),
      'sessionStart': _sessionStart?.toIso8601String(),
      'currentSessionDuration': sessionDuration?.inMinutes,
      'isInitialized': true,
      'customStatistics': Map<String, dynamic>.from(_statistics),
    };
  }

  /// デバッグ情報を取得
  Map<String, dynamic> getDebugInfo() {
    final sessionDuration = currentSessionDuration;

    return {
      'gameServicesManager': {
        'initialized': true,
        'configuration': {
          'debugMode': _config.debugMode,
          'autoSignInEnabled': _config.autoSignInEnabled,
          'leaderboardsEnabled': _config.leaderboardsEnabled,
          'achievementsEnabled': _config.achievementsEnabled,
          'highScoreLeaderboardId': _config.highScoreLeaderboardId,
        },
        'statistics': {
          'gameStartCount': _gameStartCount,
          'lastGameStart': _lastGameStart?.toIso8601String(),
          'sessionStart': _sessionStart?.toIso8601String(),
          'sessionDurationMinutes': sessionDuration?.inMinutes,
        },
        'customStats': _statistics,
      },
    };
  }

  /// セッション統計をリセット
  void resetSession() {
    _sessionStart = DateTime.now();

    if (_config.debugMode) {
      debugPrint('🔄 Session statistics reset');
    }
  }

  /// 全統計をクリア
  void clearAllStatistics() {
    _statistics.clear();
    _gameStartCount = 0;
    _lastGameStart = null;
    _sessionStart = null;

    if (_config.debugMode) {
      debugPrint('🗑️ All statistics cleared');
    }
  }

  /// ゲーム開始回数
  int get gameStartCount => _gameStartCount;

  /// 最後のゲーム開始時刻
  DateTime? get lastGameStart => _lastGameStart;

  /// セッション開始時刻
  DateTime? get sessionStart => _sessionStart;
}
