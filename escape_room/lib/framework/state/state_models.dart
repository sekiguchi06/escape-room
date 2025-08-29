import 'game_state_base.dart';

/// 状態遷移記録
class StateTransitionRecord<T extends GameState> {
  final T fromState;
  final T toState;
  final DateTime timestamp;
  final String? metadata;

  const StateTransitionRecord({
    required this.fromState,
    required this.toState,
    required this.timestamp,
    this.metadata,
  });

  /// 遷移にかかった時間を計算する際の基準時刻
  Duration getDurationSince(DateTime baseTime) {
    return timestamp.difference(baseTime);
  }

  Map<String, dynamic> toJson() {
    return {
      'from': fromState.name,
      'to': toState.name,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
    };
  }
}

/// 状態統計
class StateStatistics {
  final Map<String, int> _stateVisitCounts = {};
  final Map<String, Duration> _stateDurations = {};
  final Map<String, DateTime> _stateEntryTimes = {};
  int _totalStateChanges = 0;

  void recordStateEntry(GameState state) {
    final stateName = state.name;
    _stateVisitCounts[stateName] = (_stateVisitCounts[stateName] ?? 0) + 1;
    _stateEntryTimes[stateName] = DateTime.now();
    _totalStateChanges++;
  }

  void recordStateExit(GameState state) {
    final stateName = state.name;
    final entryTime = _stateEntryTimes[stateName];
    if (entryTime != null) {
      final duration = DateTime.now().difference(entryTime);
      _stateDurations[stateName] =
          (_stateDurations[stateName] ?? Duration.zero) + duration;
    }
  }

  int getVisitCount(String stateName) => _stateVisitCounts[stateName] ?? 0;
  Duration getTotalDuration(String stateName) =>
      _stateDurations[stateName] ?? Duration.zero;

  /// 総状態変更回数（下位互換のため）
  int get totalStateChanges => _totalStateChanges;

  /// セッション数（下位互換のため）
  int get sessionCount =>
      _stateVisitCounts.values.fold(0, (sum, count) => sum + count);

  /// セッション継続時間（下位互換のため）
  Duration get sessionDuration => _stateDurations.values.fold(
    Duration.zero,
    (sum, duration) => sum + duration,
  );

  /// 最も訪問された状態（下位互換のため）
  String get mostVisitedState {
    if (_stateVisitCounts.isEmpty) return '';
    return _stateVisitCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  /// セッション平均遷移数（下位互換のため）
  double get averageStateTransitionsPerSession {
    if (sessionCount == 0) return 0.0;
    return totalStateChanges / sessionCount;
  }

  Map<String, dynamic> toJson() {
    return {
      'visitCounts': _stateVisitCounts,
      'totalDurations': _stateDurations.map(
        (k, v) => MapEntry(k, v.inMilliseconds),
      ),
      'totalStateChanges': _totalStateChanges,
      'sessionCount': sessionCount,
      'sessionDuration': sessionDuration.inMilliseconds,
      'mostVisitedState': mostVisitedState,
    };
  }
}