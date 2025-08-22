import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../framework/ui/ui_system.dart';
import '../../framework/animation/animation_system.dart';
import '../simple_game.dart';

class PlayingScreenComponent extends PositionComponent {
  late TextUIComponent _timerText;
  late GameComponent _testCircle;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final game = findGame()! as SimpleGame;

    // 背景
    final background = RectangleComponent(
      position: Vector2.zero(),
      size: game.size,
      paint: Paint()..color = Colors.indigo.withValues(alpha: 0.3),
    );
    background.priority = UILayerPriority.background;
    add(background);

    // タイマー背景
    final timerBg = RectangleComponent(
      position: Vector2(game.size.x / 2 - 100, 25),
      size: Vector2(200, 50),
      paint: Paint()..color = Colors.black.withValues(alpha: 0.8),
    );
    add(timerBg);

    // タイマーテキスト
    _timerText = TextUIComponent(
      text: 'TIME: 5.0',
      styleId: 'xlarge',
      position: Vector2(game.size.x / 2, 50),
    );
    _timerText.anchor = Anchor.center;
    _timerText.setTextColor(Colors.white);
    add(_timerText);

    // ゲームオブジェクト
    _testCircle = GameComponent(
      position: Vector2(game.size.x / 2, game.size.y / 2 + 100),
      size: Vector2(80, 80),
      anchor: Anchor.center,
    );
    _testCircle.paint.color = Colors.blue;
    _testCircle.paint.style = PaintingStyle.fill;
    add(_testCircle);

    // 説明テキスト
    final instructionText = TextUIComponent(
      text: 'TAP THE BLUE CIRCLE',
      styleId: 'medium',
      position: Vector2(game.size.x / 2, game.size.y / 2 - 50),
    );
    instructionText.anchor = Anchor.center;
    instructionText.setTextColor(Colors.white);
    add(instructionText);
  }

  /// タイマー表示更新（外部から呼び出し）
  void updateTimer(double timeRemaining) {
    if (_timerText.isMounted) {
      _timerText.setText('TIME: ${timeRemaining.toStringAsFixed(1)}');
      _timerText.setTextColor(Colors.white);
    }
  }

  /// サークルタップ処理
  bool handleCircleTap(Vector2 tapPosition) {
    final distance = (tapPosition - _testCircle.position).length;

    if (distance <= _testCircle.size.x / 2) {
      AnimationPresets.buttonTap(_testCircle);
      // TODO: Implement audio manager access
      debugPrint('🔊 Play tap sound effect');
      return true;
    }
    return false;
  }
}
