import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:casual_game_template/framework/animation/animation_system.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('Simple Animation Tests', () {
    test('AnimationConfig 基本機能', () {
      const config = AnimationConfig(
        duration: Duration(milliseconds: 500),
        curve: Curves.linear,
        autoReverse: true,
        repeatCount: 2,
      );
      
      expect(config.duration.inMilliseconds, equals(500));
      expect(config.autoReverse, isTrue);
      expect(config.repeatCount, equals(2));
    });
    
    testWithFlameGame('AnimationManager 作成と初期化', (game) async {
      final manager = AnimationManager();
      expect(manager, isNotNull);
      
      await game.add(manager);
      await game.ready();
      
      expect(manager.activeAnimationCount, equals(0));
    });
    
    testWithFlameGame('PositionComponent 基本操作確認', (game) async {
      final target = PositionComponent(position: Vector2(10, 20));
      await game.add(target);
      await game.ready();
      
      // 直接操作が可能か確認
      expect(target.position.x, equals(10));
      expect(target.position.y, equals(20));
      
      // 手動で変更可能か確認
      target.position = Vector2(30, 40);
      expect(target.position.x, equals(30));
      expect(target.position.y, equals(40));
      
      // スケール操作確認
      target.scale = Vector2.all(2.0);
      expect(target.scale.x, equals(2.0));
      expect(target.scale.y, equals(2.0));
      
      // 回転操作確認
      target.angle = 1.5708;
      expect(target.angle, closeTo(1.5708, 0.001));
    });
  });
}