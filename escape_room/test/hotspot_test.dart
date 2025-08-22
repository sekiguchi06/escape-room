import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import 'package:escape_room/framework/components/hotspot_component.dart';

/// ホットスポットコンポーネントのテスト
/// Issue #4: 透明ホットスポット機能の検証  
void main() {
  group('HotspotComponent Tests', () {
    late HotspotComponent hotspot;

    setUp(() {
      hotspot = HotspotComponent(
        id: 'test_hotspot',
        onTap: (id) {
          // タップイベント処理テスト
        },
        position: Vector2(100, 100),
        size: Vector2(50, 50),
      );
    });

    test('ホットスポット基本機能テスト', () {
      expect(hotspot.id, equals('test_hotspot'));
      expect(hotspot.position, equals(Vector2(100, 100)));
      expect(hotspot.size, equals(Vector2(50, 50)));
      expect(hotspot.isInvisible, isFalse);
      expect(hotspot.debugMode, isFalse);
    });

    test('透明モード設定テスト', () {
      // 初期状態では可視
      expect(hotspot.isInvisible, isFalse);

      // 透明モードに変更
      hotspot.setInvisible(true);
      expect(hotspot.isInvisible, isTrue);

      // 可視モードに戻す
      hotspot.setInvisible(false);
      expect(hotspot.isInvisible, isFalse);
    });

    test('デバッグモード設定テスト', () {
      // 初期状態ではデバッグモードOFF
      expect(hotspot.debugMode, isFalse);

      // デバッグモードON
      hotspot.setDebugMode(true);
      expect(hotspot.debugMode, isTrue);

      // デバッグモードOFF
      hotspot.setDebugMode(false);
      expect(hotspot.debugMode, isFalse);
    });

    test('透明ホットスポット初期化テスト', () {
      final invisibleHotspot = HotspotComponent(
        id: 'invisible_test',
        onTap: (id) {},
        position: Vector2(200, 200),
        size: Vector2(100, 100),
        invisible: true,
      );

      expect(invisibleHotspot.isInvisible, isTrue);
      expect(invisibleHotspot.debugMode, isFalse);
    });

    test('デバッグモード付きホットスポット初期化テスト', () {
      final debugHotspot = HotspotComponent(
        id: 'debug_test',
        onTap: (id) {},
        position: Vector2(300, 300),
        size: Vector2(75, 75),
        invisible: true,
        debugMode: true,
      );

      expect(debugHotspot.isInvisible, isTrue);
      expect(debugHotspot.debugMode, isTrue);
    });

    test('複数ホットスポット座標テスト', () {
      final hotspots = <HotspotComponent>[];

      // Issue #4要求の座標パターンをテスト
      final testPositions = [
        {'id': 'left_pillar', 'pos': Vector2(40, 240)}, // 10%, 40%
        {'id': 'ceiling_decoration', 'pos': Vector2(160, 60)}, // 40%, 10%
        {'id': 'wall_decoration', 'pos': Vector2(300, 180)}, // 75%, 30%
        {'id': 'floor_object', 'pos': Vector2(140, 420)}, // 35%, 70%
      ];

      for (var testData in testPositions) {
        final hotspot = HotspotComponent(
          id: testData['id'] as String,
          onTap: (id) {},
          position: testData['pos'] as Vector2,
          size: Vector2(60, 80), // 15%, 20%相当
          invisible: true,
        );
        hotspots.add(hotspot);
      }

      expect(hotspots.length, equals(4));
      expect(hotspots[0].id, equals('left_pillar'));
      expect(hotspots[1].position, equals(Vector2(160, 60)));
      expect(hotspots[2].isInvisible, isTrue);
      expect(hotspots[3].size, equals(Vector2(60, 80)));
    });

    test('ホットスポット状態変更テスト', () {
      // 初期状態: 可視・デバッグOFF
      expect(hotspot.isInvisible, isFalse);
      expect(hotspot.debugMode, isFalse);

      // 透明化
      hotspot.setInvisible(true);
      expect(hotspot.isInvisible, isTrue);
      expect(hotspot.debugMode, isFalse);

      // デバッグモードON（透明状態を維持）
      hotspot.setDebugMode(true);
      expect(hotspot.isInvisible, isTrue);
      expect(hotspot.debugMode, isTrue);

      // 可視化（デバッグモードは維持）
      hotspot.setInvisible(false);
      expect(hotspot.isInvisible, isFalse);
      expect(hotspot.debugMode, isTrue);
    });
  });

  group('ホットスポット座標変換テスト', () {
    test('相対座標から絶対座標への変換テスト', () {
      const gameSize = Size(400, 600); // Issue #4統一サイズ

      // テストケース: 相対座標 → 期待される絶対座標
      final testCases = [
        {'relative': Offset(0.1, 0.4), 'absolute': Offset(40, 240)},
        {'relative': Offset(0.4, 0.1), 'absolute': Offset(160, 60)},
        {'relative': Offset(0.75, 0.3), 'absolute': Offset(300, 180)},
        {'relative': Offset(0.35, 0.7), 'absolute': Offset(140, 420)},
      ];

      for (var testCase in testCases) {
        final relative = testCase['relative'] as Offset;
        final expected = testCase['absolute'] as Offset;

        final absolute = Offset(
          relative.dx * gameSize.width,
          relative.dy * gameSize.height,
        );

        expect(absolute.dx, closeTo(expected.dx, 0.1));
        expect(absolute.dy, closeTo(expected.dy, 0.1));
      }
    });

    test('相対サイズから絶対サイズへの変換テスト', () {
      const gameSize = Size(400, 600);

      final testCases = [
        {'relative': Size(0.15, 0.2), 'absolute': Size(60, 120)},
        {'relative': Size(0.2, 0.15), 'absolute': Size(80, 90)},
        {'relative': Size(0.3, 0.2), 'absolute': Size(120, 120)},
      ];

      for (var testCase in testCases) {
        final relative = testCase['relative'] as Size;
        final expected = testCase['absolute'] as Size;

        final absolute = Size(
          relative.width * gameSize.width,
          relative.height * gameSize.height,
        );

        expect(absolute.width, closeTo(expected.width, 0.1));
        expect(absolute.height, closeTo(expected.height, 0.1));
      }
    });
  });
}
