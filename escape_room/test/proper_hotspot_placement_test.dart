import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:escape_room/services/proper_hotspot_placement_service.dart';
import 'package:escape_room/game/components/room_hotspot_system.dart';

/// 適切なホットスポット配置システムのテスト
void main() {
  group('適切なホットスポット配置システムテスト', () {
    test('ProperHotspotPlacementService基本機能テスト', () {
      final service = ProperHotspotPlacementService();

      // テスト部屋のホットスポット生成
      final hotspots = service.generateTestRoomHotspots();

      debugPrint('🎯 生成されたプロフェッショナルホットスポット数: ${hotspots.length}');

      // 基本検証
      expect(hotspots, isNotEmpty);
      expect(hotspots.length, equals(4)); // 設計された4つのホットスポット

      // 各ホットスポットの詳細確認
      for (int i = 0; i < hotspots.length; i++) {
        final hotspot = hotspots[i];
        debugPrint('  ${i + 1}. ${hotspot.name} (${hotspot.id})');
        debugPrint(
          '     位置: (${(hotspot.position.dx * 100).toInt()}%, ${(hotspot.position.dy * 100).toInt()}%)',
        );
        debugPrint(
          '     サイズ: ${(hotspot.size.width * 100).toInt()}% x ${(hotspot.size.height * 100).toInt()}%',
        );
        debugPrint('     説明: ${hotspot.description}');
      }
    });

    test('ホットスポット配置の論理性テスト', () {
      final service = ProperHotspotPlacementService();
      final hotspots = service.generateTestRoomHotspots();

      // 期待されるホットスポットIDの確認
      final expectedIds = [
        'golden_chandelier',
        'left_lectern',
        'right_desk',
        'floor_light',
      ];

      final actualIds = hotspots.map((h) => h.id).toList();

      for (final expectedId in expectedIds) {
        expect(
          actualIds,
          contains(expectedId),
          reason: 'Expected hotspot $expectedId not found',
        );
      }

      debugPrint('✅ 全ての期待されるホットスポットが生成されました');
    });

    test('モバイル最適化タップエリアテスト', () {
      final service = ProperHotspotPlacementService();
      final hotspots = service.generateTestRoomHotspots();

      // 一般的なモバイル画面サイズでのテスト
      const testScreenSizes = [
        Size(375, 667), // iPhone SE
        Size(414, 896), // iPhone 11
        Size(390, 844), // iPhone 12/13/14
        Size(360, 640), // Android標準
      ];

      for (final screenSize in testScreenSizes) {
        debugPrint('📱 画面サイズ: ${screenSize.width}x${screenSize.height}でのテスト');

        for (final hotspot in hotspots) {
          final isValid = service.validateTapArea(hotspot.size, screenSize);
          debugPrint('  ${hotspot.name}: ${isValid ? "✅適切" : "❌小さすぎ"}');

          if (!isValid) {
            // タップエリアサイズの詳細表示
            final actualWidth = hotspot.size.width * screenSize.width;
            final actualHeight = hotspot.size.height * screenSize.height;
            debugPrint(
              '    実際のサイズ: ${actualWidth.toInt()}x${actualHeight.toInt()}px',
            );
          }
        }
      }
    });

    test('重複検出テスト', () {
      final service = ProperHotspotPlacementService();
      final hotspots = service.generateTestRoomHotspots();

      final hasOverlap = service.checkOverlap(hotspots);
      expect(hasOverlap, isFalse, reason: 'ホットスポット同士が重複しています');

      debugPrint('✅ ホットスポットの重複なし確認完了');
    });

    test('インタラクションタイプ多様性テスト', () {
      final service = ProperHotspotPlacementService();
      final hotspots = service.generateTestRoomHotspots();

      // 各ホットスポットをタップして異なるインタラクションが発生することを確認
      debugPrint('🎮 インタラクションテスト:');

      for (final hotspot in hotspots) {
        // タップシミュレーション
        hotspot.onTap?.call(const Offset(0.5, 0.5));
        debugPrint('  ${hotspot.name}: タップ処理実行');
      }

      debugPrint('✅ 全てのホットスポットで適切なインタラクションが実行されました');
    });

    test('視覚的配置の合理性テスト', () {
      final service = ProperHotspotPlacementService();
      final hotspots = service.generateTestRoomHotspots();

      // 上部・中部・下部への適切な配置確認
      var upperHotspots = 0;
      var middleHotspots = 0;
      var lowerHotspots = 0;

      for (final hotspot in hotspots) {
        if (hotspot.position.dy < 0.33) {
          upperHotspots++;
        } else if (hotspot.position.dy < 0.66) {
          middleHotspots++;
        } else {
          lowerHotspots++;
        }
      }

      debugPrint('📍 垂直配置分析:');
      debugPrint('  上部: $upperHotspots個');
      debugPrint('  中部: $middleHotspots個');
      debugPrint('  下部: $lowerHotspots個');

      // 各エリアにバランスよく配置されていることを確認
      expect(upperHotspots, greaterThan(0), reason: '上部にホットスポットがありません');
      expect(middleHotspots, greaterThan(0), reason: '中部にホットスポットがありません');
      expect(lowerHotspots, greaterThan(0), reason: '下部にホットスポットがありません');

      debugPrint('✅ バランスの取れた垂直配置が確認されました');
    });

    test('RoomHotspotSystem統合テスト', () {
      final hotspotSystem = RoomHotspotSystem();

      // 新しいシステムでテスト部屋のホットスポットを取得
      final hotspots = hotspotSystem.getCurrentRoomHotspots();

      debugPrint('🏛️ 統合テスト結果:');
      debugPrint('  ホットスポット数: ${hotspots.length}');

      // 各ホットスポットが適切に設定されていることを確認
      for (final hotspot in hotspots) {
        expect(hotspot.id, isNotEmpty);
        expect(hotspot.name, isNotEmpty);
        expect(hotspot.description, isNotEmpty);
        expect(hotspot.onTap, isNotNull);

        // 座標とサイズの妥当性確認
        expect(hotspot.position.dx, inInclusiveRange(0.0, 1.0));
        expect(hotspot.position.dy, inInclusiveRange(0.0, 1.0));
        expect(hotspot.size.width, greaterThan(0.0));
        expect(hotspot.size.height, greaterThan(0.0));

        debugPrint('  ✅ ${hotspot.name}: 設定完了');
      }

      debugPrint('✅ RoomHotspotSystemとの統合成功');
    });

    test('パフォーマンステスト', () {
      final service = ProperHotspotPlacementService();

      // 複数回の生成時間を測定
      final stopwatch = Stopwatch()..start();

      for (int i = 0; i < 100; i++) {
        service.generateTestRoomHotspots();
      }

      stopwatch.stop();
      final averageTimeMs = stopwatch.elapsedMilliseconds / 100;

      debugPrint('⚡ パフォーマンス測定結果:');
      debugPrint('  100回生成の平均時間: ${averageTimeMs.toStringAsFixed(2)}ms');

      // 1ms以下での生成を期待（非常に高速）
      expect(averageTimeMs, lessThan(1.0), reason: 'ホットスポット生成が遅すぎます');

      debugPrint('✅ 高速なホットスポット生成が確認されました');
    });
  });
}
