import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:escape_room/framework/effects/particle_system.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('ParticleEffectManager Tests', () {
    testWithFlameGame('パーティクルエフェクト初期化', (game) async {
      final manager = ParticleEffectManager();
      await game.add(manager);
      await game.ready();

      expect(manager.isMounted, isTrue);
      expect(manager.activeEffectCount, equals(0));
    });

    testWithFlameGame('爆発エフェクト再生', (game) async {
      final manager = ParticleEffectManager();
      await game.add(manager);
      await game.ready();

      manager.playEffect('explosion', Vector2(100, 100));
      await game.ready();

      expect(manager.activeEffectCount, equals(1));
    });

    testWithFlameGame('キラキラエフェクト再生', (game) async {
      final manager = ParticleEffectManager();
      await game.add(manager);
      await game.ready();

      manager.playEffect('sparkle', Vector2(200, 200));
      await game.ready();

      expect(manager.activeEffectCount, equals(1));
    });

    testWithFlameGame('軌跡エフェクト再生', (game) async {
      final manager = ParticleEffectManager();
      await game.add(manager);
      await game.ready();

      manager.playEffect('trail', Vector2(150, 150));
      await game.ready();

      expect(manager.activeEffectCount, equals(1));
    });

    testWithFlameGame('複数エフェクト同時再生', (game) async {
      final manager = ParticleEffectManager();
      await game.add(manager);
      await game.ready();

      manager.playEffect('explosion', Vector2(100, 100));
      manager.playEffect('sparkle', Vector2(200, 200));
      manager.playEffect('trail', Vector2(150, 150));
      await game.ready();

      expect(manager.activeEffectCount, equals(3));
    });

    testWithFlameGame('カスタムエフェクト登録', (game) async {
      final manager = ParticleEffectManager();
      await game.add(manager);
      await game.ready();

      final customConfig = ParticleConfiguration(
        particleCount: 50,
        lifespan: 3.0,
        startColor: Colors.purple,
        endColor: Colors.pink,
      );

      manager.registerEffect('custom', customConfig);
      manager.playEffect('custom', Vector2(100, 100));
      await game.ready();

      expect(manager.activeEffectCount, equals(1));
    });

    testWithFlameGame('存在しないエフェクト再生', (game) async {
      final manager = ParticleEffectManager();
      await game.add(manager);
      await game.ready();

      manager.playEffect('nonexistent', Vector2(100, 100));
      await game.ready();

      expect(manager.activeEffectCount, equals(0));
    });

    testWithFlameGame('全エフェクト停止', (game) async {
      final manager = ParticleEffectManager();
      await game.add(manager);
      await game.ready();

      // 複数エフェクト再生
      manager.playEffect('explosion', Vector2(100, 100));
      manager.playEffect('sparkle', Vector2(200, 200));
      await game.ready();

      expect(manager.activeEffectCount, equals(2));

      // 全停止
      manager.stopAllEffects();
      await game.ready();

      expect(manager.activeEffectCount, equals(0));
    });

    testWithFlameGame('エフェクト自動削除', (game) async {
      final manager = ParticleEffectManager();
      await game.add(manager);
      await game.ready();

      // 短時間エフェクト
      final shortConfig = ParticleConfiguration(lifespan: 0.1);
      manager.registerEffect('short', shortConfig);
      manager.playEffect('short', Vector2(100, 100));
      await game.ready();

      expect(manager.activeEffectCount, equals(1));

      // 少し待機（自動削除のため）
      await Future.delayed(const Duration(milliseconds: 200));

      expect(manager.activeEffectCount, equals(0));
    });
  });
}
