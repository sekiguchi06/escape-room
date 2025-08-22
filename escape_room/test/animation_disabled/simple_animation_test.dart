import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:escape_room/framework/animation/animation_system.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Simple Animation Extension Methods Tests', () {
    testWithFlameGame('基本移動アニメーション - Extension Methods', (game) async {
      final target = PositionComponent(position: Vector2(0, 0));
      await game.add(target);
      await game.ready();

      // 正しいExtension Methods使用
      target.animateMoveTo(Vector2(100, 50));

      // Effectが追加されることを確認
      game.update(0.016);
      expect(target.children.whereType<MoveEffect>().length, equals(1));
    });

    testWithFlameGame('基本スケールアニメーション - Extension Methods', (game) async {
      final target = PositionComponent();
      await game.add(target);
      await game.ready();

      target.animateScaleTo(Vector2.all(2.0));

      // Effectが追加されることを確認
      game.update(0.016);
      expect(target.children.whereType<ScaleEffect>().length, equals(1));
    });

    testWithFlameGame('基本回転アニメーション - Extension Methods', (game) async {
      final target = PositionComponent();
      await game.add(target);
      await game.ready();

      target.animateRotateTo(1.57); // 90度

      // Effectが追加されることを確認
      game.update(0.016);
      expect(target.children.whereType<RotateEffect>().length, equals(1));
    });

    test('AnimationPresets - 静的メソッド存在確認', () {
      // AnimationPresetsの静的メソッドが存在することを確認
      expect(AnimationPresets.popIn, isNotNull);
      expect(AnimationPresets.buttonTap, isNotNull);
      expect(AnimationPresets.slideInFromLeft, isNotNull);
    });

    test('Extension Methods API存在確認', () {
      final component = PositionComponent();

      // Extension Methodsが正しく認識されることを確認
      expect(() => component.animateMoveTo(Vector2(10, 10)), returnsNormally);
      expect(() => component.animateScaleTo(Vector2.all(1.5)), returnsNormally);
      expect(() => component.animateRotateTo(0.5), returnsNormally);
    });
  });
}
