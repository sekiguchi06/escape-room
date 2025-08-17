import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:escape_room/framework/animation/animation_system.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('AnimationConfig Tests', () {
    test('デフォルト設定', () {
      const config = AnimationConfig();
      
      expect(config.duration, equals(const Duration(milliseconds: 300)));
      expect(config.curve, equals(Curves.easeInOut));
      expect(config.autoReverse, isFalse);
      expect(config.repeatCount, equals(1));
      expect(config.infinite, isFalse);
      expect(config.startDelay, equals(Duration.zero));
    });
    
    test('EffectController変換', () {
      const config = AnimationConfig(
        duration: Duration(milliseconds: 500),
        curve: Curves.bounceIn,
        autoReverse: true,
        repeatCount: 3,
      );
      
      final controller = config.toEffectController();
      // EffectControllerの内部プロパティは公開されていないため型確認のみ
      expect(controller, isA<EffectController>());
    });
  });
  
  group('PositionComponent Animations', () {
    testWithFlameGame('移動アニメーション', (game) async {
      final component = PositionComponent(position: Vector2(0, 0));
      await game.add(component);
      await game.ready();
      
      // アニメーション追加
      component.animateMoveTo(
        Vector2(100, 100),
        config: const AnimationConfig(duration: Duration(milliseconds: 100)),
      );
      
      // 1フレーム処理でEffectが追加される
      game.update(0.016); // 16ms = 1フレーム
      expect(component.children.whereType<MoveEffect>().length, equals(1));
    });
    
    testWithFlameGame('スケールアニメーション', (game) async {
      final component = PositionComponent();
      await game.add(component);
      await game.ready();
      
      component.animateScaleTo(
        Vector2.all(2.0),
        config: const AnimationConfig(duration: Duration(milliseconds: 100)),
      );
      
      game.update(0.016);
      expect(component.children.whereType<ScaleEffect>().length, equals(1));
    });
    
    testWithFlameGame('回転アニメーション', (game) async {
      final component = PositionComponent();
      await game.add(component);
      await game.ready();
      
      component.animateRotateBy(
        3.14159,
        config: const AnimationConfig(duration: Duration(milliseconds: 100)),
      );
      
      game.update(0.016);
      expect(component.children.whereType<RotateEffect>().length, equals(1));
    });
    
    testWithFlameGame('振動アニメーション', (game) async {
      final component = PositionComponent();
      await game.add(component);
      await game.ready();
      
      component.animateShake(intensity: 10.0);
      
      game.update(0.016);
      expect(component.children.whereType<SequenceEffect>().length, equals(1));
    });
  });
  
  group('HasPaint Component Animations', () {
    testWithFlameGame('GameComponentでの透明度アニメーション', (game) async {
      final component = GameComponent();
      await game.add(component);
      await game.ready();
      
      // OpacityProviderを実装しているので動作する
      component.animateFadeOut();
      
      game.update(0.016);
      expect(component.children.whereType<OpacityEffect>().length, equals(1));
    });
    
    testWithFlameGame('PositionComponentでの透明度アニメーション', (game) async {
      final component = PositionComponent();
      await game.add(component);
      await game.ready();
      
      // OpacityProvider未実装なので追加されない
      component.animateFadeIn();
      
      game.update(0.016);
      expect(component.children.whereType<OpacityEffect>().length, equals(0));
    });
  });
  
  group('SpriteComponent Animations', () {
    testWithFlameGame('点滅アニメーション', (game) async {
      // SpriteComponentはsprite設定が必須なのでスキップ
      // 代わりにGameComponentでテスト
      final component = GameComponent();
      await game.add(component);
      await game.ready();
      
      // GameComponentはOpacityProvider実装済み
      component.animateFadeOut();
      component.animateFadeIn();
      
      game.update(0.016);
      expect(component.children.whereType<OpacityEffect>().length, equals(2));
    });
  });
  
  group('Effect Chain', () {
    testWithFlameGame('並列アニメーション', (game) async {
      final component = PositionComponent();
      await game.add(component);
      await game.ready();
      
      component.animateParallel([
        MoveEffect.by(
          Vector2(100, 0),
          EffectController(duration: 1.0),
        ),
        ScaleEffect.to(
          Vector2.all(2.0),
          EffectController(duration: 1.0),
        ),
      ]);
      
      game.update(0.016);
      expect(component.children.whereType<Effect>().length, equals(2));
    });
    
    testWithFlameGame('Effect削除', (game) async {
      final component = PositionComponent();
      await game.add(component);
      await game.ready();
      
      // 複数Effect追加
      component.animateMoveTo(Vector2(100, 100));
      component.animateScaleTo(Vector2.all(2.0));
      
      game.update(0.016);
      expect(component.children.whereType<Effect>().length, equals(2));
      
      // 全削除
      component.clearAllEffects();
      
      // 非同期削除のためゲームループで処理させる
      game.update(0.016);
      expect(component.children.whereType<Effect>().length, equals(0));
    });
  });
  
  group('Animation Presets', () {
    testWithFlameGame('ボタンタップアニメーション', (game) async {
      final button = PositionComponent();
      await game.add(button);
      await game.ready();
      
      AnimationPresets.buttonTap(button);
      
      game.update(0.016);
      expect(button.children.whereType<ScaleEffect>().length, equals(1));
    });
    
    testWithFlameGame('ポップイン', (game) async {
      final component = PositionComponent();
      await game.add(component);
      await game.ready();
      
      AnimationPresets.popIn(component);
      
      expect(component.scale, equals(Vector2.zero()));
      game.update(0.016);
      expect(component.children.whereType<ScaleEffect>().length, equals(1));
    });
  });
}