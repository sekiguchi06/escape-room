import 'package:flutter/foundation.dart';
import '../state/game_state_system.dart';
import '../input/flame_input_system.dart';
import 'game_managers.dart';

/// アナリティクス追跡ミックスイン
/// ゲーム内でのアナリティクス追跡機能を提供
mixin AnalyticsTracking<TState extends GameState> {
  /// マネージャーコレクション
  GameManagers<TState> get managers;

  /// アナリティクスイベントの送信
  void trackEvent(String eventName, Map<String, dynamic> parameters) {
    managers.analyticsManager.trackEvent(eventName, parameters: parameters);
    debugPrint('Analytics Event: $eventName - $parameters');
  }

  /// 状態遷移の追跡
  void trackStateTransition(TState from, TState to) {
    trackEvent('state_transition', {
      'from_state': from.name,
      'to_state': to.name,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// ゲームセッションの追跡
  void trackGameSession() {
    final statistics = managers.stateProvider.getStatistics();

    trackEvent('game_session', {
      'session_count': statistics.sessionCount,
      'total_state_changes': statistics.totalStateChanges,
      'session_duration_seconds': statistics.sessionDuration.inSeconds,
      'most_visited_state': statistics.mostVisitedState,
    });
  }

  /// 入力イベントの追跡
  void trackInputEvent(InputEventData event) {
    managers.analyticsManager.trackEvent(
      'input_event',
      parameters: {
        'input_type': event.type.name,
        'position_x': event.position?.x,
        'position_y': event.position?.y,
      },
    );
  }

  /// ゲーム開始イベントの追跡
  void trackGameStart() {
    trackEvent('game_start', {
      'game_type': runtimeType.toString(),
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// ゲーム終了イベントの追跡
  void trackGameEnd() {
    trackEvent('game_end', {
      'game_type': runtimeType.toString(),
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// パフォーマンスメトリクスの追跡
  void trackPerformanceMetrics(Map<String, dynamic> metrics) {
    trackEvent('performance_metrics', metrics);
  }
}
