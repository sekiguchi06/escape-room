/// ゲーム時間計測システム
/// アプリ起動からクリアまでの時間を計測
class GameTimer {
  static final GameTimer _instance = GameTimer._internal();
  factory GameTimer() => _instance;
  GameTimer._internal();

  DateTime? _startTime;
  DateTime? _endTime;

  /// ゲーム開始時間を記録
  void start() {
    _startTime = DateTime.now();
    _endTime = null;
  }

  /// ゲーム終了時間を記録
  void stop() {
    if (_startTime != null) {
      _endTime = DateTime.now();
    }
  }

  /// ゲーム時間を取得
  Duration? get gameTime {
    if (_startTime == null) return null;

    final endTime = _endTime ?? DateTime.now();
    return endTime.difference(_startTime!);
  }

  /// ゲーム中かどうか
  bool get isRunning => _startTime != null && _endTime == null;

  /// リセット
  void reset() {
    _startTime = null;
    _endTime = null;
  }
}
