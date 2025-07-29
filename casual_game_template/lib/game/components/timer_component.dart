import 'package:flame/components.dart';

/// ゲームタイマーを管理するコンポーネント
/// Flameのコンポーネント指向設計に準拠
class GameTimerComponent extends Component {
  double _timer;
  final double _initialTime;
  bool _isRunning = false;
  
  // タイマー終了時のコールバック
  void Function()? onTimerEnd;
  
  // タイマー更新時のコールバック（UI更新等に使用）
  void Function(double currentTime)? onTimerUpdate;

  GameTimerComponent({
    required double initialTime,
    this.onTimerEnd,
    this.onTimerUpdate,
  }) : _timer = initialTime, _initialTime = initialTime;

  /// タイマーを開始
  void start() {
    _isRunning = true;
    _timer = _initialTime;
    onTimerUpdate?.call(_timer);
  }

  /// タイマーを停止
  void stop() {
    _isRunning = false;
  }

  /// タイマーをリセット
  void reset() {
    _timer = _initialTime;
    _isRunning = false;
    onTimerUpdate?.call(_timer);
  }

  /// 現在のタイマー値を取得
  double get currentTime => _timer;

  /// タイマーが動作中かを取得
  bool get isRunning => _isRunning;

  /// タイマーが終了したかを判定
  bool get isFinished => _timer <= 0;

  @override
  void update(double dt) {
    super.update(dt);
    
    if (_isRunning && _timer > 0) {
      _timer -= dt;
      onTimerUpdate?.call(_timer);
      
      // タイマー終了チェック
      if (_timer <= 0) {
        _timer = 0;
        _isRunning = false;
        onTimerEnd?.call();
      }
    }
  }
}