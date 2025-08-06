import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:casual_game_template/framework/animation/animation_system.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('Animation Extension Methods Integration Tests - 実動作確認', () {
    testWithFlameGame('移動アニメーション - Extension Methods実動作確認', (game) async {
      final target = PositionComponent(position: Vector2(0, 0));
      await game.add(target);
      await game.ready();
      
      // 初期位置確認
      expect(target.position.x, equals(0));
      expect(target.position.y, equals(0));
      
      // 正しいExtension Methods使用のアニメーション実行
      target.animateMoveTo(
        Vector2(100, 50),
        config: const AnimationConfig(duration: Duration(milliseconds: 100)),
      );
      
      // Effectが追加されることを確認
      game.update(0.016);
      expect(target.children.whereType<MoveEffect>().length, equals(1));
    });
    
    testWithFlameGame('スケールアニメーション - Extension Methods実動作確認', (game) async {
      final target = PositionComponent();
      await game.add(target);
      await game.ready();
      
      // 初期スケール確認
      expect(target.scale.x, equals(1.0));
      expect(target.scale.y, equals(1.0));
      
      // 正しいExtension Methods使用のスケールアニメーション実行
      target.animateScaleTo(
        Vector2.all(2.5),
        config: const AnimationConfig(duration: Duration(milliseconds: 100)),
      );
      
      // Effectが追加されることを確認
      game.update(0.016);
      expect(target.children.whereType<ScaleEffect>().length, equals(1));
    });
    
    testWithFlameGame('回転アニメーション - Extension Methods実動作確認', (game) async {
      final target = PositionComponent();
      await game.add(target);
      await game.ready();
      
      // 初期角度確認
      expect(target.angle, equals(0.0));
      
      // 正しいExtension Methods使用の回転アニメーション実行
      target.animateRotateTo(
        1.5708, // π/2 (90度)
        config: const AnimationConfig(duration: Duration(milliseconds: 100)),
      );
      
      // Effectが追加されることを確認
      game.update(0.016);
      expect(target.children.whereType<RotateEffect>().length, equals(1));
    });
    
    testWithFlameGame('透明度アニメーション - HasPaint対応確認', (game) async {
      final target = RectangleComponent(
        size: Vector2(50, 50),
        paint: Paint()..color = Colors.blue,
      );
      await game.add(target);
      await game.ready();
      
      // 初期透明度確認
      expect(target.paint.color.opacity, equals(1.0));
      
      // 正しいExtension Methods使用の透明度アニメーション実行
      target.animateFadeOut(
        config: const AnimationConfig(duration: Duration(milliseconds: 100)),
      );
      
      // Effectが追加されることを確認
      game.update(0.016);
      expect(target.children.whereType<OpacityEffect>().length, equals(1));
    });
    
    testWithFlameGame('AnimationPresets - PopIn動作確認', (game) async {
      final target = PositionComponent();
      await game.add(target);
      await game.ready();
      
      // AnimationPresets使用
      AnimationPresets.popIn(target);
      
      // 初期スケールが0に設定されることを確認
      expect(target.scale.x, equals(0.0));
      expect(target.scale.y, equals(0.0));
      
      // Effectが追加されることを確認
      game.update(0.016);
      expect(target.children.whereType<ScaleEffect>().length, equals(1));
    });
    
    testWithFlameGame('AnimationPresets - ButtonTap動作確認', (game) async {
      final target = PositionComponent();
      await game.add(target);
      await game.ready();
      
      // 初期スケール確認
      expect(target.scale.x, equals(1.0));
      
      // ButtonTapアニメーション実行
      AnimationPresets.buttonTap(target);
      
      // Effectが追加されることを確認
      game.update(0.016);
      expect(target.children.whereType<ScaleEffect>().length, equals(1));
    });
    
    testWithFlameGame('AnimationPresets - SlideInFromLeft動作確認', (game) async {
      final target = PositionComponent(position: Vector2(100, 100));
      await game.add(target);
      await game.ready();
      
      final originalPosition = target.position.clone();
      
      // SlideInFromLeftアニメーション実行（画面幅を指定）
      AnimationPresets.slideInFromLeft(target, 800.0);
      
      // Effectが追加されることを確認
      game.update(0.016);
      expect(target.children.whereType<MoveEffect>().length, equals(1));
    });
    
    testWithFlameGame('複数アニメーション同時実行 - Extension Methods', (game) async {
      final target = PositionComponent(position: Vector2(0, 0));
      await game.add(target);
      await game.ready();
      
      // 複数のアニメーションを同時実行
      target.animateMoveTo(
        Vector2(100, 100), 
        config: const AnimationConfig(duration: Duration(milliseconds: 200)),
      );
      target.animateScaleTo(
        Vector2.all(2.0), 
        config: const AnimationConfig(duration: Duration(milliseconds: 200)),
      );
      target.animateRotateTo(
        1.57, 
        config: const AnimationConfig(duration: Duration(milliseconds: 200)),
      );
      
      // 全てのEffectが追加されることを確認
      game.update(0.016);
      expect(target.children.whereType<MoveEffect>().length, equals(1));
      expect(target.children.whereType<ScaleEffect>().length, equals(1));
      expect(target.children.whereType<RotateEffect>().length, equals(1));
    });
    
    testWithFlameGame('Extension Methods - エラー処理確認', (game) async {
      final target = PositionComponent();
      await game.add(target);
      await game.ready();
      
      // Extension Methodsが正常に実行されることを確認
      expect(() => target.animateMoveTo(Vector2(50, 50)), returnsNormally);
      expect(() => target.animateScaleTo(Vector2.all(2.0)), returnsNormally);
      expect(() => target.animateRotateTo(1.57), returnsNormally);
    });
  });
}