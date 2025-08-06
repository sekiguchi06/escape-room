import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';

/// Flame公式Timer準拠のタイマーシステム
/// 既存のTimerSystemと互換性を保ちつつ、内部でFlame公式Timerを使用

/// タイマーの種類
enum TimerType {
  countdown,  // カウントダウン
  countup,    // カウントアップ
  interval,   // インターバル（繰り返し）
}

/// タイマー設定（既存API互換）
class TimerConfiguration {
  final Duration duration;
  final TimerType type;
  final bool autoStart;
  final void Function()? onComplete;
  final void Function(Duration remaining)? onUpdate;
  final void Function()? onStart;
  final void Function()? onPause;
  final void Function()? onResume;
  final bool resetOnComplete;
  
  const TimerConfiguration({
    required this.duration,
    this.type = TimerType.countdown,
    this.autoStart = false,
    this.onComplete,
    this.onUpdate,
    this.onStart,
    this.onPause,
    this.onResume,
    this.resetOnComplete = false,
  });
  
  TimerConfiguration copyWith({
    Duration? duration,
    TimerType? type,
    bool? autoStart,
    void Function()? onComplete,
    void Function(Duration remaining)? onUpdate,
    void Function()? onStart,
    void Function()? onPause,
    void Function()? onResume,
    bool? resetOnComplete,
  }) {
    return TimerConfiguration(
      duration: duration ?? this.duration,
      type: type ?? this.type,
      autoStart: autoStart ?? this.autoStart,
      onComplete: onComplete ?? this.onComplete,
      onUpdate: onUpdate ?? this.onUpdate,
      onStart: onStart ?? this.onStart,
      onPause: onPause ?? this.onPause,
      onResume: onResume ?? this.onResume,
      resetOnComplete: resetOnComplete ?? this.resetOnComplete,
    );
  }
}

/// Flame公式Timer準拠のゲームタイマー
class FlameGameTimer extends Component {
  Duration _current = Duration.zero;
  Duration _duration = Duration.zero;
  TimerType _type = TimerType.countdown;
  bool _isRunning = false;
  bool _isPaused = false;
  
  TimerConfiguration _config;
  Timer? _flameTimer;
  
  FlameGameTimer(String timerId, this._config) {
    _duration = _config.duration;
    _type = _config.type;
    _resetCurrentTime();
    
    if (_config.autoStart) {
      start();
    }
  }
  
  void _resetCurrentTime() {
    switch (_type) {
      case TimerType.countdown:
        _current = _duration;
        break;
      case TimerType.countup:
      case TimerType.interval:
        _current = Duration.zero;
        break;
    }
  }
  
  void _createFlameTimer() {
    _flameTimer?.stop();
    
    switch (_type) {
      case TimerType.countdown:
        // カウントダウン：残り時間経過後に完了
        final remainingSeconds = _current.inMilliseconds / 1000.0;
        _flameTimer = Timer(remainingSeconds, onTick: () {
          _current = Duration.zero;
          _config.onComplete?.call();
          if (_config.resetOnComplete) {
            reset();
            if (_config.autoStart) {
              start();
            }
          } else {
            _isRunning = false;
          }
        });
        break;
        
      case TimerType.countup:
        // カウントアップ：残り時間経過後に完了
        final remainingSeconds = (_duration - _current).inMilliseconds / 1000.0;
        _flameTimer = Timer(remainingSeconds, onTick: () {
          _current = _duration;
          _config.onComplete?.call();
          if (_config.resetOnComplete) {
            reset();
            if (_config.autoStart) {
              start();
            }
          } else {
            _isRunning = false;
          }
        });
        break;
        
      case TimerType.interval:
        // インターバル：繰り返し実行（残り時間から開始）
        void createIntervalTimer() {
          final remainingSeconds = (_duration - _current).inMilliseconds / 1000.0;
          _flameTimer = Timer(remainingSeconds, onTick: () {
            _current = Duration.zero;
            _config.onComplete?.call();
            if (_isRunning && !_isPaused) {
              createIntervalTimer(); // 次のタイマーを作成
              _flameTimer?.start();
            }
          });
        }
        createIntervalTimer();
        break;
    }
  }
  
  /// 現在の時間を取得
  Duration get current => _current;
  
  /// 設定時間を取得
  Duration get duration => _duration;
  
  /// タイマータイプを取得
  TimerType get type => _type;
  
  /// 実行中かどうか
  bool get isRunning => _isRunning && !_isPaused;
  
  /// 一時停止中かどうか
  bool get isPaused => _isPaused;
  
  /// 完了したかどうか
  bool get isCompleted {
    switch (_type) {
      case TimerType.countdown:
        return _current <= Duration.zero;
      case TimerType.countup:
        return _current >= _duration;
      case TimerType.interval:
        return false; // インターバルタイマーは完了しない
    }
  }
  
  /// 残り時間（カウントダウンの場合）
  Duration get remaining {
    switch (_type) {
      case TimerType.countdown:
        return _current;
      case TimerType.countup:
        return _duration - _current;
      case TimerType.interval:
        return _duration - _current;
    }
  }
  
  /// 進捗率（0.0 - 1.0）
  double get progress {
    if (_duration == Duration.zero) return 0.0;
    
    switch (_type) {
      case TimerType.countdown:
        return (_duration.inMicroseconds - _current.inMicroseconds) / _duration.inMicroseconds;
      case TimerType.countup:
        return _current.inMicroseconds / _duration.inMicroseconds;
      case TimerType.interval:
        return _current.inMicroseconds / _duration.inMicroseconds;
    }
  }
  
  /// タイマー開始
  void start() {
    if (!_isRunning) {
      _isRunning = true;
      _isPaused = false;
      _createFlameTimer();
      _flameTimer?.start();
      _config.onStart?.call();
      debugPrint('FlameGameTimer started: $_duration');
    }
  }
  
  /// タイマー停止
  void stop() {
    _flameTimer?.stop();
    _isRunning = false;
    _isPaused = false;
  }
  
  /// タイマー一時停止
  void pause() {
    if (_isRunning && !_isPaused) {
      _flameTimer?.stop();
      _isPaused = true;
      _config.onPause?.call();
      debugPrint('FlameGameTimer paused');
    }
  }
  
  /// タイマー再開
  void resume() {
    if (_isRunning && _isPaused) {
      // 残り時間でFlame Timerを再作成
      _createFlameTimer();
      _flameTimer?.start();
      _isPaused = false;
      _config.onResume?.call();
      debugPrint('FlameGameTimer resumed');
    }
  }
  
  /// タイマーリセット
  void reset() {
    _flameTimer?.stop();
    _resetCurrentTime();
    _isRunning = false;
    _isPaused = false;
  }
  
  /// 設定を更新
  void updateConfiguration(TimerConfiguration config) {
    final wasRunning = _isRunning;
    final wasPaused = _isPaused;
    
    _config = config;
    _duration = config.duration;
    _type = config.type;
    
    // 新設定でリセット
    _resetCurrentTime();
    
    // 実行状態を復元
    _isRunning = wasRunning;
    _isPaused = wasPaused;
    
    if (_isRunning) {
      _createFlameTimer();
      if (!_isPaused) {
        _flameTimer?.start();
      }
    }
  }
  
  /// 時間を直接設定
  void setTime(Duration time) {
    final clampedMicros = time.inMicroseconds.clamp(0, _duration.inMicroseconds);
    _current = Duration(microseconds: clampedMicros);
  }
  
  /// 時間を追加/減算
  void addTime(Duration delta) {
    final newTime = _current + delta;
    final clampedMicros = newTime.inMicroseconds.clamp(0, _duration.inMicroseconds * 2);
    _current = Duration(microseconds: clampedMicros);
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    
    if (!isRunning || _flameTimer == null) return;
    
    // Flame Timerを更新
    _flameTimer!.update(dt);
    
    // 現在時刻を計算（Flame Timerの進行に基づいて）
    final deltaTime = Duration(microseconds: (dt * 1000000).round());
    final oldCurrent = _current;
    
    switch (_type) {
      case TimerType.countdown:
        final clampedMicros = (_current - deltaTime).inMicroseconds.clamp(0, _duration.inMicroseconds);
        _current = Duration(microseconds: clampedMicros);
        break;
      case TimerType.countup:
        final clampedMicros = (_current + deltaTime).inMicroseconds.clamp(0, _duration.inMicroseconds);
        _current = Duration(microseconds: clampedMicros);
        break;
      case TimerType.interval:
        _current += deltaTime;
        if (_current >= _duration) {
          _current = Duration.zero;
        }
        break;
    }
    
    // 更新コールバック呼び出し
    if (_current != oldCurrent) {
      _config.onUpdate?.call(_current);
    }
  }
  
  /// デバッグ情報
  Map<String, dynamic> getDebugInfo() {
    return {
      'current': _current.inMilliseconds,
      'duration': _duration.inMilliseconds,
      'type': _type.name,
      'isRunning': _isRunning,
      'isPaused': _isPaused,
      'isCompleted': isCompleted,
      'progress': progress,
      'flameTimer': _flameTimer?.toString() ?? 'null',
    };
  }
  
  @override
  void onRemove() {
    _flameTimer?.stop();
    super.onRemove();
  }
}

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

/// タイマープリセット管理（既存API互換）
class TimerPresets {
  static const Map<String, TimerConfiguration> _presets = {
    'quickGame': TimerConfiguration(
      duration: Duration(seconds: 30),
      type: TimerType.countdown,
      autoStart: false,
    ),
    'standardGame': TimerConfiguration(
      duration: Duration(minutes: 2),
      type: TimerType.countdown,
      autoStart: false,
    ),
    'longGame': TimerConfiguration(
      duration: Duration(minutes: 5),
      type: TimerType.countdown,
      autoStart: false,
    ),
    'stopwatch': TimerConfiguration(
      duration: Duration(minutes: 10),
      type: TimerType.countup,
      autoStart: false,
    ),
    'interval30s': TimerConfiguration(
      duration: Duration(seconds: 30),
      type: TimerType.interval,
      autoStart: false,
      resetOnComplete: true,
    ),
  };
  
  /// プリセット設定を取得
  static TimerConfiguration? getPreset(String name) {
    return _presets[name];
  }
  
  /// 利用可能なプリセット一覧を取得
  static List<String> getAvailablePresets() {
    return _presets.keys.toList();
  }
  
  /// カスタムプリセットを作成
  static TimerConfiguration createCustomPreset({
    required Duration duration,
    TimerType type = TimerType.countdown,
    bool autoStart = false,
    void Function()? onComplete,
    void Function(Duration)? onUpdate,
  }) {
    return TimerConfiguration(
      duration: duration,
      type: type,
      autoStart: autoStart,
      onComplete: onComplete,
      onUpdate: onUpdate,
    );
  }
}