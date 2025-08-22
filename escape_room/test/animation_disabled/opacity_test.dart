import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:escape_room/framework/animation/animation_system.dart';

// HasPaintを使用した正しいコンポーネント
class OpacityComponent extends PositionComponent with HasPaint {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  TestWidgetsFlutterBinding.ensureInitialized();

  testWithFlameGame('HasPaint使用時の透明度アニメーション', (game) async {
    final target = OpacityComponent();
    await game.add(target);
    await game.ready();

    // 初期透明度
    expect(target.opacity, equals(1.0));

    // Extension Methodを使用した透明度アニメーション
    target.animateFadeOut(
      config: const AnimationConfig(duration: Duration(milliseconds: 100)),
    );

    game.update(0.016);
    expect(target.children.whereType<OpacityEffect>().length, equals(1));
  });
}
