// タイマー関連のモデルクラス

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