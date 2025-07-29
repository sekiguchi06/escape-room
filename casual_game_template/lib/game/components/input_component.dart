import 'package:flame/components.dart';
import 'package:flame/events.dart';

/// 入力処理を管理するコンポーネント
/// タップイベントの処理と状態に応じた動作を担当
class InputComponent extends PositionComponent with TapCallbacks {
  // タップイベントのコールバック
  void Function(TapDownEvent event)? onTapDownCallback;
  void Function(TapUpEvent event)? onTapUpCallback;
  void Function(TapCancelEvent event)? onTapCancelCallback;
  
  // 入力の有効/無効状態
  bool _isEnabled = true;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // 画面全体をカバーする透明な矩形として設定
    // サイズは親（FlameGame）から取得
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    // 画面全体をカバーするように設定
    this.size = size;
    position = Vector2.zero();
    
    print('InputComponent サイズ設定: ${this.size}');
  }

  /// 入力処理を有効にする
  void enable() {
    _isEnabled = true;
  }

  /// 入力処理を無効にする
  void disable() {
    _isEnabled = false;
  }

  /// 入力が有効かどうかを取得
  bool get isEnabled => _isEnabled;

  @override
  bool onTapDown(TapDownEvent event) {
    if (!_isEnabled) return false;
    
    print('InputComponent: タップダウン検出 位置:${event.localPosition}');
    onTapDownCallback?.call(event);
    return true;
  }

  @override
  bool onTapUp(TapUpEvent event) {
    if (!_isEnabled) return false;
    
    onTapUpCallback?.call(event);
    return true;
  }

  @override
  bool onTapCancel(TapCancelEvent event) {
    if (!_isEnabled) return false;
    
    onTapCancelCallback?.call(event);
    return true;
  }

  /// デバッグ用：タップ位置をログ出力
  void logTapPosition(TapDownEvent event) {
    final position = event.localPosition;
    print('タップ位置: (${position.x.toStringAsFixed(1)}, ${position.y.toStringAsFixed(1)})');
  }
}