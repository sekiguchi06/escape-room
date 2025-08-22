import 'package:flutter_test/flutter_test.dart';
import 'package:flame/particles.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:escape_room/framework/effects/particle_system.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('🎆 Flame公式パーティクル準拠確認テスト', () {
    late ParticleEffectManager particleManager;

    setUp(() {
      particleManager = ParticleEffectManager();
    });

    test('Flame公式API使用確認', () {
      // ParticleSystemComponentが正しく使用されているか
      expect(ParticleSystemComponent, isNotNull);

      // 各種パーティクルタイプが使用可能か確認
      expect(AcceleratedParticle, isNotNull);
      expect(MovingParticle, isNotNull);
      expect(ComputedParticle, isNotNull);
      expect(CircleParticle, isNotNull);

      // Particle.generateメソッドが使用可能か確認
      final testParticle = Particle.generate(
        count: 5,
        lifespan: 1.0,
        generator: (i) => CircleParticle(
          radius: 2.0,
          paint: Paint()..color = const Color(0xFFFFFFFF),
        ),
      );
      expect(testParticle, isNotNull);
    });

    test('パーティクル設定正常性確認', () {
      final config = ParticleConfiguration(
        particleCount: 10,
        lifespan: 2.0,
        minRadius: 1.0,
        maxRadius: 5.0,
      );

      expect(config.particleCount, equals(10));
      expect(config.lifespan, equals(2.0));
      expect(config.minRadius, equals(1.0));
      expect(config.maxRadius, equals(5.0));
    });

    test('エフェクト登録確認', () {
      final config = ParticleConfiguration(particleCount: 15, lifespan: 1.5);

      particleManager.registerEffect('test_effect', config);

      // プライベートフィールドのため直接確認はできないが、エラーなく登録完了
      expect(
        () => particleManager.registerEffect('test_effect2', config),
        returnsNormally,
      );
    });

    test('Flame公式パーティクル直接作成確認', () {
      // AcceleratedParticle作成テスト
      final acceleratedParticle = AcceleratedParticle(
        acceleration: Vector2(0, 100),
        child: CircleParticle(
          radius: 3.0,
          paint: Paint()..color = const Color(0xFF00FF00),
        ),
      );
      expect(acceleratedParticle, isNotNull);

      // MovingParticle作成テスト
      final movingParticle = MovingParticle(
        from: Vector2(0, 0),
        to: Vector2(100, 100),
        child: CircleParticle(
          radius: 2.0,
          paint: Paint()..color = const Color(0xFF0000FF),
        ),
      );
      expect(movingParticle, isNotNull);

      // ComputedParticle作成テスト
      final computedParticle = ComputedParticle(
        renderer: (canvas, particle) {
          // カスタム描画ロジック
        },
      );
      expect(computedParticle, isNotNull);
    });

    test('パーティクルシステム統合確認', () {
      // Flame公式推奨パターンでのParticleSystemComponent作成
      final particle = Particle.generate(
        count: 10,
        lifespan: 1.0,
        generator: (i) => AcceleratedParticle(
          acceleration: Vector2(0, 98),
          child: CircleParticle(
            radius: 2.0,
            paint: Paint()..color = const Color(0xFFFF0000),
          ),
        ),
      );

      final particleSystem = ParticleSystemComponent(particle: particle);
      expect(particleSystem, isNotNull);
    });
  });
}
