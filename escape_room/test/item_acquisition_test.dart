import 'package:flutter_test/flutter_test.dart';
import '../lib/game/components/inventory_system.dart';
import '../lib/game/components/room_hotspot_system.dart';
import '../lib/game/components/room_navigation_system.dart';

void main() {
  group('アイテム取得システムテスト', () {
    late InventorySystem inventorySystem;
    late RoomHotspotSystem hotspotSystem;
    late RoomNavigationSystem navigationSystem;

    setUp(() {
      inventorySystem = InventorySystem();
      hotspotSystem = RoomHotspotSystem();
      navigationSystem = RoomNavigationSystem();
      
      // インベントリを初期化（空の状態）
      inventorySystem.initializeEmpty();
    });

    test('1. インベントリ初期状態確認', () {
      expect(inventorySystem.inventory, [null, null, null, null, null]);
      expect(inventorySystem.selectedSlotIndex, null);
      print('✅ インベントリ初期状態: 5つのスロットすべて空');
    });

    test('2. 牢獄の桶からコイン取得テスト', () {
      // 牢獄（leftmost room）に移動
      navigationSystem.resetToInitialRoom(); // center
      navigationSystem.moveLeft(); // left
      navigationSystem.moveLeft(); // leftmost (prison)
      
      // 牢獄のホットスポットを取得
      final hotspots = hotspotSystem.getCurrentRoomHotspots();
      print('🏛️ 牢獄のホットスポット数: ${hotspots.length}');
      
      // prison_bucket を見つける
      final bucketHotspot = hotspots.firstWhere(
        (hotspot) => hotspot.id == 'prison_bucket',
      );
      
      expect(bucketHotspot.name, '古い桶');
      print('🪣 桶ホットスポット発見: ${bucketHotspot.name}');
      
      // アイテム取得前の状態確認
      expect(inventorySystem.inventory[0], null);
      
      // 桶をタップしてアイテム取得
      bucketHotspot.onTap?.call(const Offset(0, 0));
      
      // コインが取得されているか確認
      expect(inventorySystem.inventory[0], 'coin');
      print('💰 コイン取得成功: スロット0に配置');
    });

    test('3. 図書館の椅子から鍵取得テスト', () {
      // 図書館（center room）に移動
      navigationSystem.resetToInitialRoom(); // center (library)
      
      // 図書館のホットスポットを取得
      final hotspots = hotspotSystem.getCurrentRoomHotspots();
      print('📚 図書館のホットスポット数: ${hotspots.length}');
      
      // library_chair を見つける
      final chairHotspot = hotspots.firstWhere(
        (hotspot) => hotspot.id == 'library_chair',
      );
      
      expect(chairHotspot.name, '革の椅子');
      print('🪑 椅子ホットスポット発見: ${chairHotspot.name}');
      
      // アイテム取得前の状態確認
      expect(inventorySystem.inventory[0], null);
      
      // 椅子をタップしてアイテム取得
      chairHotspot.onTap?.call(const Offset(0, 0));
      
      // 鍵が取得されているか確認
      expect(inventorySystem.inventory[0], 'key');
      print('🗝️ 鍵取得成功: スロット0に配置');
    });

    test('4. 複数アイテム取得テスト', () {
      // コインを取得
      navigationSystem.resetToInitialRoom();
      navigationSystem.moveLeft(); // left
      navigationSystem.moveLeft(); // leftmost (prison)
      
      final prisonHotspots = hotspotSystem.getCurrentRoomHotspots();
      final bucketHotspot = prisonHotspots.firstWhere(
        (hotspot) => hotspot.id == 'prison_bucket',
      );
      bucketHotspot.onTap?.call(const Offset(0, 0));
      
      expect(inventorySystem.inventory[0], 'coin');
      print('💰 1個目: コイン取得');
      
      // 鍵を取得
      navigationSystem.resetToInitialRoom(); // center (library)
      
      final libraryHotspots = hotspotSystem.getCurrentRoomHotspots();
      final chairHotspot = libraryHotspots.firstWhere(
        (hotspot) => hotspot.id == 'library_chair',
      );
      chairHotspot.onTap?.call(const Offset(0, 0));
      
      expect(inventorySystem.inventory[1], 'key');
      print('🗝️ 2個目: 鍵取得');
      
      // 最終確認
      expect(inventorySystem.inventory, ['coin', 'key', null, null, null]);
      print('✅ 複数アイテム取得テスト成功: [coin, key, null, null, null]');
    });

    test('5. インベントリフル状態テスト', () {
      // インベントリを満杯にする
      expect(inventorySystem.addItem('item1'), true);
      expect(inventorySystem.addItem('item2'), true);
      expect(inventorySystem.addItem('item3'), true);
      expect(inventorySystem.addItem('item4'), true);
      expect(inventorySystem.addItem('item5'), true);
      
      // 6個目を追加しようとする（失敗するはず）
      expect(inventorySystem.addItem('item6'), false);
      print('🎒 インベントリフル状態で取得失敗: 想定通り');
      
      // ホットスポットからの取得も失敗するか確認
      navigationSystem.resetToInitialRoom();
      navigationSystem.moveLeft();
      navigationSystem.moveLeft();
      
      final hotspots = hotspotSystem.getCurrentRoomHotspots();
      final bucketHotspot = hotspots.firstWhere(
        (hotspot) => hotspot.id == 'prison_bucket',
      );
      
      // フル状態でタップ
      bucketHotspot.onTap?.call(const Offset(0, 0));
      
      // インベントリに変化がないことを確認
      expect(inventorySystem.inventory, ['item1', 'item2', 'item3', 'item4', 'item5']);
      print('🎒 フル状態でのホットスポット取得も失敗: 想定通り');
    });

    test('6. ゲームリセット時のインベントリクリア', () {
      // アイテムを追加
      inventorySystem.addItem('coin');
      inventorySystem.addItem('key');
      inventorySystem.selectSlot(1);
      
      expect(inventorySystem.inventory[0], 'coin');
      expect(inventorySystem.inventory[1], 'key');
      expect(inventorySystem.selectedSlotIndex, 1);
      print('🎒 リセット前: アイテム2個、スロット1選択中');
      
      // インベントリを初期化
      inventorySystem.initializeEmpty();
      
      expect(inventorySystem.inventory, [null, null, null, null, null]);
      expect(inventorySystem.selectedSlotIndex, null);
      print('🔄 リセット後: インベントリクリア、選択解除');
    });

    test('7. 重複取得防止テスト', () {
      // 最初の取得
      navigationSystem.resetToInitialRoom();
      navigationSystem.moveLeft();
      navigationSystem.moveLeft();
      
      final hotspots = hotspotSystem.getCurrentRoomHotspots();
      final bucketHotspot = hotspots.firstWhere(
        (hotspot) => hotspot.id == 'prison_bucket',
      );
      
      // 1回目の取得
      bucketHotspot.onTap?.call(const Offset(0, 0));
      expect(inventorySystem.inventory[0], 'coin');
      print('💰 1回目: コイン取得成功');
      
      // 2回目の取得試行（失敗するはず）
      bucketHotspot.onTap?.call(const Offset(0, 0));
      expect(inventorySystem.inventory[1], null); // 2個目のスロットは空のまま
      print('🚫 2回目: 重複取得防止で取得失敗');
      
      // 取得済み状態の確認
      expect(inventorySystem.isItemAcquiredFromHotspot('prison_bucket', 'coin'), true);
      print('✅ 取得済み状態が正しく記録されている');
    });

    test('8. 異なるホットスポットからの同種アイテム取得テスト', () {
      // prison_bucketからコインを取得
      navigationSystem.resetToInitialRoom();
      navigationSystem.moveLeft();
      navigationSystem.moveLeft();
      
      final prisonHotspots = hotspotSystem.getCurrentRoomHotspots();
      final bucketHotspot = prisonHotspots.firstWhere(
        (hotspot) => hotspot.id == 'prison_bucket',
      );
      bucketHotspot.onTap?.call(const Offset(0, 0));
      
      expect(inventorySystem.inventory[0], 'coin');
      expect(inventorySystem.isItemAcquiredFromHotspot('prison_bucket', 'coin'), true);
      print('💰 prison_bucketからコイン取得');
      
      // 別のホットスポットが同じアイテム（coin）を持っていても取得可能であることを確認
      // （prison_bucketのコインは取得済みだが、他の場所のコインは取得可能）
      final canAcquireFromDifferentSpot = !inventorySystem.isItemAcquiredFromHotspot('different_hotspot', 'coin');
      expect(canAcquireFromDifferentSpot, true);
      print('✅ 異なるホットスポットからの同種アイテムは取得可能');
    });
  });
}