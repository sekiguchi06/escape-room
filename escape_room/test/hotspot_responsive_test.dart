import 'package:flutter_test/flutter_test.dart';
import 'package:flame/components.dart';
import 'package:escape_room/framework/components/responsive_hotspot_component.dart';
import 'package:escape_room/game/components/room_hotspot_definitions.dart';

/// ResponsiveHotspotComponentのテスト
/// ホットスポット座標配置・スケーリング機能の検証
void main() {
  group('ResponsiveHotspotComponent Tests', () {
    late ResponsiveHotspotComponent hotspot;

    setUp(() {
      hotspot = ResponsiveHotspotComponent(
        id: 'test_hotspot',
        onTap: (id) {
          // テスト用タップハンドラ
        },
        relativePosition: Vector2(0.5, 0.5),  // 中央
        relativeSize: Vector2(0.2, 0.1),      // 20% x 10%
      );
    });

    test('基本プロパティの初期化確認', () {
      expect(hotspot.id, equals('test_hotspot'));
      expect(hotspot.relativePosition, equals(Vector2(0.5, 0.5)));
      expect(hotspot.relativeSize, equals(Vector2(0.2, 0.1)));
      expect(hotspot.isInvisible, isTrue); // デフォルトで透明
    });

    test('400x600背景での座標計算テスト', () {
      // 400x600背景が400x600で表示される場合（等倍）
      final screenSize = Vector2(400, 600);
      final backgroundSize = Vector2(400, 600);
      
      hotspot.updateForScreenSize(screenSize, backgroundSize);
      
      // 中央位置: 400*0.5=200, 600*0.5=300
      expect(hotspot.position.x, closeTo(200, 0.1));
      expect(hotspot.position.y, closeTo(300, 0.1));
      
      // サイズ: 400*0.2=80, 600*0.1=60
      expect(hotspot.size.x, closeTo(80, 0.1));
      expect(hotspot.size.y, closeTo(60, 0.1));
    });

    test('画面サイズ変更時のスケーリングテスト', () {
      // 400x600背景が800x1200で表示される場合（2倍拡大）
      final screenSize = Vector2(800, 1200);
      final backgroundSize = Vector2(800, 1200);
      
      hotspot.updateForScreenSize(screenSize, backgroundSize);
      
      // 2倍スケール: 位置(400, 600), サイズ(160, 120)
      expect(hotspot.position.x, closeTo(400, 0.1));
      expect(hotspot.position.y, closeTo(600, 0.1));
      expect(hotspot.size.x, closeTo(160, 0.1));
      expect(hotspot.size.y, closeTo(120, 0.1));
    });

    test('デバッグ情報取得テスト', () {
      hotspot.updateForScreenSize(Vector2(400, 600), Vector2(400, 600));
      
      final debugInfo = hotspot.getDebugInfo();
      
      expect(debugInfo['id'], equals('test_hotspot'));
      expect(debugInfo['relativePosition'], contains('0.50'));
      expect(debugInfo['actualPosition'], contains('200.0'));
      expect(debugInfo['invisible'], isTrue);
    });
  });

  group('RoomHotspotDefinitions Tests', () {
    test('room_left ホットスポット定義確認', () {
      final hotspots = RoomHotspotDefinitions.roomLeftHotspots;
      
      expect(hotspots.length, equals(4));
      expect(hotspots[0]['id'], equals('left_stone_pillar'));
      expect(hotspots[1]['id'], equals('center_floor_item'));
      expect(hotspots[2]['id'], equals('right_wall_switch'));
      expect(hotspots[3]['id'], equals('back_light_source'));
    });

    test('room_right ホットスポット定義確認', () {
      final hotspots = RoomHotspotDefinitions.roomRightHotspots;
      
      expect(hotspots.length, equals(3));
      expect(hotspots[0]['id'], equals('left_herb_shelf'));
      expect(hotspots[1]['id'], equals('center_main_shelf'));
      expect(hotspots[2]['id'], equals('right_tool_shelf'));
    });

    test('存在しない部屋タイプの処理確認', () {
      final hotspots = RoomHotspotDefinitions.getHotspotsForRoom('nonexistent_room');
      expect(hotspots, isEmpty);
    });

    test('ResponsiveHotspotComponent生成テスト', () {
      var tappedId = '';
      final components = RoomHotspotDefinitions.createHotspotsForRoom(
        'room_left',
        (id) => tappedId = id,
      );
      
      expect(components.length, equals(4));
      expect(components[0].id, equals('left_stone_pillar'));
      expect(components[0].isInvisible, isTrue);
      
      // タップテスト
      components[0].onTap('test_id');
      expect(tappedId, equals('test_id'));
    });
  });

  group('座標配置精度テスト', () {
    test('各部屋の座標範囲確認', () {
      final allRooms = [
        'room_left',
        'room_right',
        'room_leftmost', 
        'room_rightmost'
      ];
      
      for (final roomType in allRooms) {
        final hotspots = RoomHotspotDefinitions.getHotspotsForRoom(roomType);
        
        for (final hotspot in hotspots) {
          final pos = hotspot['relativePosition'] as Vector2;
          final size = hotspot['relativeSize'] as Vector2;
          
          // 相対座標が0.0-1.0の範囲内であることを確認
          expect(pos.x, greaterThanOrEqualTo(0.0));
          expect(pos.x, lessThanOrEqualTo(1.0));
          expect(pos.y, greaterThanOrEqualTo(0.0));
          expect(pos.y, lessThanOrEqualTo(1.0));
          
          // 相対サイズが適切な範囲内であることを確認
          expect(size.x, greaterThan(0.0));
          expect(size.x, lessThanOrEqualTo(0.5)); // 最大50%
          expect(size.y, greaterThan(0.0));
          expect(size.y, lessThanOrEqualTo(0.3)); // 最大30%
          
          // ホットスポットが画面外に出ないことを確認
          expect(pos.x + size.x, lessThanOrEqualTo(1.0));
          expect(pos.y + size.y, lessThanOrEqualTo(1.0));
        }
      }
    });

    test('iPhone SE (375x667) での座標精度テスト', () {
      final component = ResponsiveHotspotComponent(
        id: 'test',
        onTap: (id) {},
        relativePosition: Vector2(0.1, 0.4), // 10%, 40%
        relativeSize: Vector2(0.15, 0.2),    // 15%, 20%
      );
      
      // iPhone SEサイズでの背景表示サイズを想定
      final backgroundDisplaySize = Vector2(375, 562.5); // アスペクト比維持
      
      component.updateForScreenSize(Vector2(375, 667), backgroundDisplaySize);
      
      // 期待される座標: (40/400*375, 240/600*562.5)
      expect(component.position.x, closeTo(37.5, 1.0));
      expect(component.position.y, closeTo(225.0, 1.0));
    });
  });
}