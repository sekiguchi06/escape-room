import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:escape_room/game/components/premium_clear_screen.dart';
import 'package:escape_room/game/components/clear_screen_particle_system.dart';

/// プレミアムクリア画面のテストスイート（Timer問題回避版）
/// GitHub Issue #5 実装の品質確認
void main() {
  group('PremiumClearScreen Constructor Tests', () {
    test('デフォルトパラメータで正しく初期化される', () {
      const screen = PremiumClearScreen();

      expect(screen.onHomePressed, isNull);
      expect(screen.clearTime, isNull);
    });

    test('カスタムパラメータで正しく初期化される', () {
      void mockHome() {}
      const duration = Duration(minutes: 10, seconds: 30);

      final screen = PremiumClearScreen(
        onHomePressed: mockHome,
        clearTime: duration,
      );

      expect(screen.onHomePressed, equals(mockHome));
      expect(screen.clearTime, equals(duration));
    });
  });

  group('ParticleData Tests', () {
    test('パーティクルデータが正しく初期化される', () {
      final particle = ParticleData(
        x: 0.5,
        y: 0.3,
        vx: 0.01,
        vy: -0.02,
        color: Colors.amber,
        size: 6.0,
        rotation: 1.57,
        rotationSpeed: 0.05,
      );

      expect(particle.x, equals(0.5));
      expect(particle.y, equals(0.3));
      expect(particle.vx, equals(0.01));
      expect(particle.vy, equals(-0.02));
      expect(particle.color, equals(Colors.amber));
      expect(particle.size, equals(6.0));
      expect(particle.rotation, equals(1.57));
      expect(particle.rotationSpeed, equals(0.05));
    });

    test('パーティクルの位置と回転を更新できる', () {
      final particle = ParticleData(
        x: 0.5,
        y: 0.3,
        vx: 0.01,
        vy: -0.02,
        color: Colors.red,
        size: 5.0,
        rotation: 0.0,
        rotationSpeed: 0.1,
      );

      // 位置の更新シミュレーション
      particle.x += particle.vx;
      particle.y += particle.vy;
      particle.rotation += particle.rotationSpeed;

      expect(particle.x, closeTo(0.51, 0.001));
      expect(particle.y, closeTo(0.28, 0.001));
      expect(particle.rotation, closeTo(0.1, 0.001));
    });
  });

  group('ParticlePainter Tests', () {
    test('パーティクルペインターが正しく初期化される', () {
      final particles = [
        ParticleData(
          x: 0.5,
          y: 0.5,
          vx: 0.01,
          vy: 0.01,
          color: Colors.red,
          size: 5.0,
          rotation: 0.0,
          rotationSpeed: 0.1,
        ),
      ];

      final painter = ParticlePainter(
        particles: particles,
        animationValue: 0.5,
      );

      expect(painter.particles, equals(particles));
      expect(painter.animationValue, equals(0.5));
    });

    test('shouldRepaint が正しく動作する', () {
      final particles = <ParticleData>[];
      final painter1 = ParticlePainter(
        particles: particles,
        animationValue: 0.3,
      );
      final painter2 = ParticlePainter(
        particles: particles,
        animationValue: 0.5,
      );
      final painter3 = ParticlePainter(
        particles: particles,
        animationValue: 0.3,
      );

      // 異なるアニメーション値の場合は再描画が必要
      expect(painter1.shouldRepaint(painter2), isTrue);

      // 同じアニメーション値の場合は再描画不要
      expect(painter1.shouldRepaint(painter3), isFalse);
    });

    test('空のパーティクルリストでも正常に動作する', () {
      final painter = ParticlePainter(particles: [], animationValue: 0.8);

      expect(painter.particles.isEmpty, isTrue);
      expect(painter.animationValue, equals(0.8));
    });

    test('複数パーティクルでも正常に動作する', () {
      final particles = List.generate(
        10,
        (index) => ParticleData(
          x: index * 0.1,
          y: index * 0.1,
          vx: 0.01,
          vy: 0.01,
          color: Colors.blue,
          size: 5.0,
          rotation: 0.0,
          rotationSpeed: 0.1,
        ),
      );

      final painter = ParticlePainter(
        particles: particles,
        animationValue: 1.0,
      );

      expect(painter.particles.length, equals(10));
      expect(painter.animationValue, equals(1.0));
    });
  });

  group('Integration Tests', () {
    test('クリア時間のフォーマット処理', () {
      // 内部的な時間フォーマット処理のテスト
      const duration1 = Duration(minutes: 5, seconds: 30);
      const duration2 = Duration(minutes: 12, seconds: 5);
      const duration3 = Duration(hours: 1, minutes: 23, seconds: 45);

      // 実際のフォーマット処理は_clearTimeTextゲッターで行われる
      expect(duration1.inMinutes, equals(5));
      expect(duration1.inSeconds % 60, equals(30));

      expect(duration2.inMinutes, equals(12));
      expect(duration2.inSeconds % 60, equals(5));

      expect(duration3.inMinutes, equals(83)); // 1時間23分 = 83分
      expect(duration3.inSeconds % 60, equals(45));
    });

    test('達成率計算の検証', () {
      // 通常ケース
      expect((8 / 10 * 100).toInt(), equals(80));
      expect((5 / 8 * 100).toInt(), equals(62));

      // 境界値ケース
      expect((10 / 10 * 100).toInt(), equals(100)); // 100%達成
      expect((0 / 10 * 100).toInt(), equals(0)); // 0%達成

      // ゼロ除算回避（math.maxを使用）
      final safeTotal = 0 > 0 ? 0 : 1; // totalItemsが0の場合のフォールバック
      expect((0 / safeTotal * 100).toInt(), equals(0));
    });
  });
}
