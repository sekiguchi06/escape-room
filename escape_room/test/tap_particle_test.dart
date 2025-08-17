import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import '../lib/game/components/tap_particle_system.dart';

void main() {
  group('タップパーティクルシステムテスト', () {
    late TapParticleSystem particleSystem;

    setUp(() {
      particleSystem = TapParticleSystem();
      particleSystem.clearAllParticles();
    });

    test('1. パーティクルシステム初期状態確認', () {
      expect(particleSystem.activeParticles, []);
    });

    test('2. 通常パーティクル発生テスト', () {
      final position = const Offset(100, 100);
      
      particleSystem.emitParticle(position, TapParticleType.normal);
      
      expect(particleSystem.activeParticles.length, 1);
      expect(particleSystem.activeParticles[0].position, position);
      expect(particleSystem.activeParticles[0].type, TapParticleType.normal);
    });

    test('3. 複数パーティクル同時発生テスト', () {
      particleSystem.emitParticle(const Offset(50, 50), TapParticleType.normal);
      particleSystem.emitParticle(const Offset(150, 150), TapParticleType.success);
      particleSystem.emitParticle(const Offset(200, 200), TapParticleType.failure);
      
      expect(particleSystem.activeParticles.length, 3);
      
      final types = particleSystem.activeParticles.map((p) => p.type).toList();
      expect(types.contains(TapParticleType.normal), true);
      expect(types.contains(TapParticleType.success), true);
      expect(types.contains(TapParticleType.failure), true);
      
    });

    test('4. 各パーティクルタイプ発生確認', () {
      final testCases = [
        (TapParticleType.normal, '通常'),
        (TapParticleType.success, '成功'),
        (TapParticleType.failure, '失敗'),
      ];
      
      for (final (type, name) in testCases) {
        particleSystem.clearAllParticles();
        particleSystem.emitParticle(const Offset(100, 100), type);
        
        expect(particleSystem.activeParticles.length, 1);
        expect(particleSystem.activeParticles[0].type, type);
      }
    });

    test('5. パーティクル自動削除テスト', () async {
      particleSystem.emitParticle(const Offset(100, 100), TapParticleType.normal);
      
      expect(particleSystem.activeParticles.length, 1);
      
      // 少し待機してパーティクルが自動削除されるかテスト
      await Future.delayed(const Duration(milliseconds: 900)); // normal type duration + margin
      
      expect(particleSystem.activeParticles.length, 0);
    });

    test('6. パーティクル手動クリアテスト', () {
      particleSystem.emitParticle(const Offset(50, 50), TapParticleType.normal);
      particleSystem.emitParticle(const Offset(100, 100), TapParticleType.success);
      particleSystem.emitParticle(const Offset(150, 150), TapParticleType.failure);
      
      expect(particleSystem.activeParticles.length, 3);
      
      particleSystem.clearAllParticles();
      
      expect(particleSystem.activeParticles.length, 0);
    });

    test('7. パーティクルタイムスタンプ確認', () {
      final beforeTime = DateTime.now();
      
      particleSystem.emitParticle(const Offset(100, 100), TapParticleType.normal);
      
      final afterTime = DateTime.now();
      final particle = particleSystem.activeParticles[0];
      
      expect(particle.timestamp.isAfter(beforeTime), true);
      expect(particle.timestamp.isBefore(afterTime), true);
    });

    test('8. 大量パーティクル負荷テスト', () {
      // 100個のパーティクルを同時発生
      for (int i = 0; i < 100; i++) {
        particleSystem.emitParticle(
          Offset(i * 5.0, i * 3.0), 
          TapParticleType.values[i % TapParticleType.values.length],
        );
      }
      
      expect(particleSystem.activeParticles.length, 100);
      
      // クリーンアップ
      particleSystem.clearAllParticles();
      expect(particleSystem.activeParticles.length, 0);
    });
  });
}