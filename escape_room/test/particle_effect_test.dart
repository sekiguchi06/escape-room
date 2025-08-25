import 'package:flutter_test/flutter_test.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:escape_room/framework/effects/particle_system.dart';

void main() {
  group('ParticleEffectManager Tests', () {
    test('パーティクルエフェクトマネージャー初期化', () {
      final manager = ParticleEffectManager();
      expect(manager.activeEffectCount, equals(0));
    });

    test('エフェクト設定登録', () {
      final manager = ParticleEffectManager();

      final config = ParticleConfiguration(
        particleCount: 10,
        lifespan: 1.0,
        startColor: Colors.red,
        endColor: Colors.blue,
      );

      manager.registerEffect('test_effect', config);

      // 設定が登録されたことを間接的に確認
      // （playEffectで例外が発生しなければ設定は登録されている）
      expect(
        () => manager.playEffect('test_effect', Vector2.zero()),
        returnsNormally,
      );
    });

    test('デフォルトエフェクト存在確認', () async {
      final manager = ParticleEffectManager();
      await manager.onLoad();

      // デフォルトエフェクトが登録されているかテスト
      expect(
        () => manager.playEffect('explosion', Vector2.zero()),
        returnsNormally,
      );
      expect(
        () => manager.playEffect('sparkle', Vector2.zero()),
        returnsNormally,
      );
      expect(
        () => manager.playEffect('trail', Vector2.zero()),
        returnsNormally,
      );
    });

    test('全エフェクト停止', () {
      final manager = ParticleEffectManager();

      // エフェクト停止は例外を発生させないことを確認
      expect(() => manager.stopAllEffects(), returnsNormally);
    });
  });
}
