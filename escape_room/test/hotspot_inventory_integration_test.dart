import 'package:flutter_test/flutter_test.dart';
import 'package:flame/components.dart';
import 'package:escape_room/framework/components/responsive_hotspot_component.dart';
import 'package:escape_room/framework/components/inventory_manager.dart';
import 'package:escape_room/game/components/room_hotspot_definitions.dart';

/// ResponsiveHotspotComponentとInventoryManagerの統合テスト
/// ホットスポットタップ→アイテム取得の流れを検証
void main() {
  group('Hotspot-Inventory Integration Tests', () {
    late InventoryManager inventory;
    late List<ResponsiveHotspotComponent> hotspots;
    late List<String> tappedHotspots;

    setUp(() {
      tappedHotspots = [];
      
      // インベントリマネージャー初期化（最大5個制限）
      inventory = InventoryManager(
        maxItems: 5,
        onItemSelected: (itemId) {
          // アイテム選択時のコールバック
        },
      );

      // room_leftのホットスポットを生成
      hotspots = RoomHotspotDefinitions.createHotspotsForRoom(
        'room_left',
        (hotspotId) {
          tappedHotspots.add(hotspotId);
          
          // ホットスポットIDに基づいてアイテムを追加
          final itemId = _mapHotspotToItem(hotspotId);
          if (itemId.isNotEmpty) {
            inventory.addItem(itemId);
          }
        },
      );
    });

    test('ホットスポットタップでアイテムが正常に追加される', () {
      // 初期状態確認
      expect(inventory.items.length, equals(0));
      expect(tappedHotspots.length, equals(0));

      // 石柱ホットスポットをタップ
      hotspots[0].onTap('left_stone_pillar');
      
      // タップ処理とアイテム追加を確認
      expect(tappedHotspots.length, equals(1));
      expect(tappedHotspots[0], equals('left_stone_pillar'));
      expect(inventory.items.length, equals(1));
      expect(inventory.hasItem('ancient_stone'), isTrue);
    });

    test('複数ホットスポットタップで複数アイテムが追加される', () {
      // 4つのホットスポットを順次タップ
      for (int i = 0; i < hotspots.length; i++) {
        hotspots[i].onTap(hotspots[i].id);
      }

      // 全てのタップが記録されることを確認
      expect(tappedHotspots.length, equals(5));
      expect(tappedHotspots, containsAll([
        'left_stone_pillar',
        'center_floor_item',
        'right_wall_switch',
        'back_light_source',
      ]));

      // 対応する4つのアイテムが追加されることを確認
      expect(inventory.items.length, equals(4));
      expect(inventory.hasItem('ancient_stone'), isTrue);
      expect(inventory.hasItem('floor_artifact'), isTrue);
      expect(inventory.hasItem('wall_mechanism'), isTrue);
      expect(inventory.hasItem('light_crystal'), isTrue);
    });

    test('インベントリ上限（5個）を超えたタップは無視される', () {
      // まず5個のアイテムを追加
      inventory.addItem('item1');
      inventory.addItem('item2');
      inventory.addItem('item3');
      inventory.addItem('item4');
      inventory.addItem('item5');
      
      expect(inventory.items.length, equals(5));

      // 上限状態でホットスポットをタップ
      hotspots[0].onTap('left_stone_pillar');

      // タップは記録されるが、アイテムは追加されない
      expect(tappedHotspots.length, equals(1));
      expect(inventory.items.length, equals(5));
      expect(inventory.hasItem('ancient_stone'), isFalse);
    });

    test('重複ホットスポットタップは無視される', () {
      // 同じホットスポットを2回タップ
      hotspots[0].onTap('left_stone_pillar');
      hotspots[0].onTap('left_stone_pillar');

      // タップは2回記録されるが、アイテムは1回のみ追加
      expect(tappedHotspots.length, equals(2));
      expect(inventory.items.length, equals(1));
      expect(inventory.hasItem('ancient_stone'), isTrue);
    });

    test('アイテム削除後の再取得テスト', () {
      // アイテム取得
      hotspots[0].onTap('left_stone_pillar');
      expect(inventory.hasItem('ancient_stone'), isTrue);

      // アイテム使用（削除）
      inventory.removeItem('ancient_stone');
      expect(inventory.hasItem('ancient_stone'), isFalse);

      // 同じホットスポットを再タップ
      hotspots[0].onTap('left_stone_pillar');
      expect(inventory.hasItem('ancient_stone'), isTrue);
    });

    test('各部屋のホットスポット座標精度テスト', () {
      final screenSize = Vector2(375, 667); // iPhone SE
      final backgroundSize = Vector2(375, 562.5); // アスペクト比維持

      for (final hotspot in hotspots) {
        hotspot.updateForScreenSize(screenSize, backgroundSize);
        
        // ホットスポットが画面内に収まることを確認
        expect(hotspot.position.x, greaterThanOrEqualTo(0));
        expect(hotspot.position.y, greaterThanOrEqualTo(0));
        expect(hotspot.position.x + hotspot.size.x, lessThanOrEqualTo(screenSize.x));
        expect(hotspot.position.y + hotspot.size.y, lessThanOrEqualTo(screenSize.y));
        
        // サイズが適切であることを確認
        expect(hotspot.size.x, greaterThan(20)); // 最小タップサイズ
        expect(hotspot.size.y, greaterThan(20));
      }
    });
  });

  group('Multi-Room Hotspot Integration Tests', () {
    test('異なる部屋のホットスポットが正しく生成される', () {
      final rooms = ['room_left', 'room_right', 'room_leftmost', 'room_rightmost'];
      final expectedCounts = [5, 4, 4, 4]; // 各部屋のホットスポット数

      for (int i = 0; i < rooms.length; i++) {
        final roomHotspots = RoomHotspotDefinitions.createHotspotsForRoom(
          rooms[i],
          (id) {}, // ダミーコールバック
        );
        
        expect(roomHotspots.length, equals(expectedCounts[i]),
            reason: '${rooms[i]} should have ${expectedCounts[i]} hotspots');
        
        // 各ホットスポットがResponsiveHotspotComponentであることを確認
        for (final hotspot in roomHotspots) {
          expect(hotspot, isA<ResponsiveHotspotComponent>());
          expect(hotspot.isInvisible, isTrue); // デフォルトで透明
        }
      }
    });

    test('全部屋のホットスポット総数確認', () {
      const totalExpectedHotspots = 4 + 3 + 3 + 3; // 13個
      int actualTotal = 0;
      
      final rooms = ['room_left', 'room_right', 'room_leftmost', 'room_rightmost'];
      for (final room in rooms) {
        final hotspots = RoomHotspotDefinitions.getHotspotsForRoom(room);
        actualTotal += hotspots.length;
      }
      
      expect(actualTotal, equals(totalExpectedHotspots));
    });
  });
}

/// ホットスポットIDをアイテムIDにマッピング
String _mapHotspotToItem(String hotspotId) {
  const mapping = {
    'left_stone_pillar': 'ancient_stone',
    'center_floor_item': 'floor_artifact', 
    'right_wall_switch': 'wall_mechanism',
    'back_light_source': 'light_crystal',
    'left_herb_shelf': 'healing_herbs',
    'center_main_shelf': 'alchemy_tools',
    'right_tool_shelf': 'magic_equipment',
    'left_wall_secret': 'secret_key',
    'passage_center_trap': 'trap_mechanism',
    'exit_light_clue': 'escape_hint',
    'table_left_vase': 'decorative_vase',
    'table_right_treasure': 'treasure_box',
    'wall_crest': 'family_crest',
  };
  
  return mapping[hotspotId] ?? '';
}