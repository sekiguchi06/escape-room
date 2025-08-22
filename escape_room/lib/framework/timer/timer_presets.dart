import 'timer_models.dart';

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
