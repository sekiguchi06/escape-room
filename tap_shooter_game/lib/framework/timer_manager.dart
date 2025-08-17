import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';
import 'timer_models.dart';
import 'flame_game_timer.dart';

/// Flame公式Timer準拠のタイマー管理システム
class FlameTimerManager extends Component {
  final Map<String, FlameGameTimer> _timers = {};
  final Map<String, TimerConfiguration> _configurations = {};
  
  /// タイマーを追加
  void addTimer(String id, TimerConfiguration config) {
    // 既存のタイマーがあれば削除
    removeTimer(id);
    
    final timer = FlameGameTimer(id, config);
    _timers[id] = timer;
    _configurations[id] = config;
    
    add(timer);
    debugPrint('FlameTimerManager: Timer added: $id');
  }
  
  /// タイマーを削除
  void removeTimer(String id) {
    final timer = _timers[id];
    if (timer != null) {
      timer.removeFromParent();
      _timers.remove(id);
      _configurations.remove(id);
      debugPrint('FlameTimerManager: Timer removed: $id');
    }
  }
  
  /// タイマーを取得（既存API互換）
  FlameGameTimer? getTimer(String id) {
    return _timers[id];
  }
  
  /// タイマーを開始
  void startTimer(String id) {
    _timers[id]?.start();
  }
  
  /// タイマーを停止
  void stopTimer(String id) {
    _timers[id]?.stop();
  }
  
  /// タイマーを一時停止
  void pauseTimer(String id) {
    _timers[id]?.pause();
  }
  
  /// タイマーを再開
  void resumeTimer(String id) {
    _timers[id]?.resume();
  }
  
  /// タイマーをリセット
  void resetTimer(String id) {
    _timers[id]?.reset();
  }
  
  /// タイマー設定を更新
  void updateTimerConfig(String id, TimerConfiguration config) {
    final timer = _timers[id];
    if (timer != null) {
      timer.updateConfiguration(config);
      _configurations[id] = config;
    }
  }
  
  /// すべてのタイマーを開始
  void startAllTimers() {
    for (final timer in _timers.values) {
      timer.start();
    }
  }
  
  /// すべてのタイマーを停止
  void stopAllTimers() {
    for (final timer in _timers.values) {
      timer.stop();
    }
  }
  
  /// すべてのタイマーを一時停止
  void pauseAllTimers() {
    for (final timer in _timers.values) {
      timer.pause();
    }
  }
  
  /// すべてのタイマーを再開
  void resumeAllTimers() {
    for (final timer in _timers.values) {
      timer.resume();
    }
  }
  
  /// タイマー一覧を取得
  List<String> getTimerIds() {
    return _timers.keys.toList();
  }
  
  /// すべてのタイマーを更新
  @override
  void update(double dt) {
    for (final timer in _timers.values) {
      timer.update(dt);
    }
  }
  
  /// 実行中のタイマー一覧を取得
  List<String> getRunningTimerIds() {
    return _timers.entries
        .where((entry) => entry.value.isRunning)
        .map((entry) => entry.key)
        .toList();
  }
  
  /// 完了したタイマー一覧を取得
  List<String> getCompletedTimerIds() {
    return _timers.entries
        .where((entry) => entry.value.isCompleted)
        .map((entry) => entry.key)
        .toList();
  }
  
  /// すべてのタイマーの状態を取得
  Map<String, Duration> getTimerStates() {
    return _timers.map((id, timer) => MapEntry(id, timer.current));
  }
  
  /// すべてのタイマーの進捗を取得
  Map<String, double> getTimerProgress() {
    return _timers.map((id, timer) => MapEntry(id, timer.progress));
  }
  
  /// タイマーが存在するかチェック
  bool hasTimer(String id) {
    return _timers.containsKey(id);
  }
  
  /// タイマーが実行中かチェック
  bool isTimerRunning(String id) {
    return _timers[id]?.isRunning ?? false;
  }
  
  /// タイマーが完了したかチェック
  bool isTimerCompleted(String id) {
    return _timers[id]?.isCompleted ?? false;
  }
  
  /// デバッグ情報を取得
  Map<String, dynamic> getDebugInfo() {
    return {
      'timerCount': _timers.length,
      'runningTimers': getRunningTimerIds(),
      'completedTimers': getCompletedTimerIds(),
      'timers': _timers.map((id, timer) => MapEntry(id, timer.getDebugInfo())),
    };
  }
  
  @override
  void onRemove() {
    // すべてのタイマーを停止してクリア
    stopAllTimers();
    _timers.clear();
    _configurations.clear();
    super.onRemove();
  }
}