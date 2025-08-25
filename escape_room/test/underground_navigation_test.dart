import 'package:flutter_test/flutter_test.dart';
import 'package:escape_room/framework/escape_room/core/room_types.dart';
import 'package:escape_room/framework/escape_room/core/floor_transition_service.dart';
import 'package:escape_room/framework/ui/multi_floor_navigation_system.dart';
import 'package:escape_room/game/components/inventory_system.dart';
import 'package:escape_room/game/components/rooms/underground_rooms.dart';

void main() {
  group('地下移動システムテスト', () {
    late FloorTransitionService floorService;
    late MultiFloorNavigationSystem navigationSystem;
    
    setUp(() {
      floorService = FloorTransitionService();
      navigationSystem = MultiFloorNavigationSystem();
      // インベントリシステムを初期化
      InventorySystem().initializeEmpty();
    });

    test('地下解放条件テスト', () {
      // 初期状態では地下は解放されていない
      expect(floorService.isUndergroundUnlocked, false);
      
      // 必要なアイテムを取得
      final testItems = ['library_key', 'combination_item1', 'combination_item2'];
      
      // 地下解放条件をチェック
      final shouldUnlock = floorService.checkUndergroundUnlockCondition(testItems);
      expect(shouldUnlock, true);
      
      // 地下を解放
      floorService.unlockUnderground();
      expect(floorService.isUndergroundUnlocked, true);
    });

    test('1階から地下への移動テスト', () async {
      // 地下を解放
      floorService.unlockUnderground();
      
      // rightmost（最右端）の部屋に移動
      floorService.moveToRoom(RoomType.rightmost);
      expect(floorService.currentRoom, RoomType.rightmost);
      expect(floorService.currentFloor, FloorType.floor1);
      
      // 地下移動可能かチェック
      expect(floorService.canTransitionToUnderground(), true);
      
      // 地下に移動
      await floorService.transitionToFloor(FloorType.underground);
      
      // 地下中央に到着することを確認
      expect(floorService.currentFloor, FloorType.underground);
      expect(floorService.currentRoom, RoomType.undergroundCenter);
    });

    test('地下から1階への移動テスト', () async {
      // 地下を解放して地下に移動
      floorService.unlockUnderground();
      floorService.moveToRoom(RoomType.rightmost);
      await floorService.transitionToFloor(FloorType.underground);
      
      // 地下中央にいることを確認
      expect(floorService.currentRoom, RoomType.undergroundCenter);
      
      // 1階移動可能かチェック
      expect(floorService.canTransitionToFloor1(), true);
      
      // 1階に移動
      await floorService.transitionToFloor(FloorType.floor1);
      
      // 1階rightmostに戻ることを確認
      expect(floorService.currentFloor, FloorType.floor1);
      expect(floorService.currentRoom, RoomType.rightmost);
    });

    test('地下部屋間の移動テスト', () async {
      // 地下に移動して設定
      floorService.unlockUnderground();
      floorService.moveToRoom(RoomType.rightmost);
      await floorService.transitionToFloor(FloorType.underground);
      
      // 地下中央にいることを確認
      expect(floorService.currentRoom, RoomType.undergroundCenter);
      
      // 地下内での左右移動をテスト
      expect(floorService.canMoveLeft(), true);
      expect(floorService.canMoveRight(), true);
      
      // 左に移動
      floorService.moveLeft();
      expect(floorService.currentRoom, RoomType.undergroundLeft);
      
      // 右に移動
      floorService.moveRight();
      expect(floorService.currentRoom, RoomType.undergroundCenter);
      
      // さらに右に移動
      floorService.moveRight();
      expect(floorService.currentRoom, RoomType.undergroundRight);
    });

    test('地下ホットスポット取得テスト', () {
      // 地下ホットスポットが正しく取得できることをテスト
      final hotspots = UndergroundRoomConfig.getUndergroundHotspots(
        onItemDiscovered: ({required String itemId, required String itemName, required String description, required itemAsset}) {
          // ダミーコールバック
        },
      );
      
      // 5つの地下部屋すべてにホットスポットが定義されていることを確認
      expect(hotspots.containsKey(RoomType.undergroundLeftmost), true);
      expect(hotspots.containsKey(RoomType.undergroundLeft), true);
      expect(hotspots.containsKey(RoomType.undergroundCenter), true);
      expect(hotspots.containsKey(RoomType.undergroundRight), true);
      expect(hotspots.containsKey(RoomType.undergroundRightmost), true);
      
      // 各部屋に3つのホットスポットがあることを確認
      expect(hotspots[RoomType.undergroundLeftmost]?.length, 3);
      expect(hotspots[RoomType.undergroundLeft]?.length, 3);
      expect(hotspots[RoomType.undergroundCenter]?.length, 3);
      expect(hotspots[RoomType.undergroundRight]?.length, 3);
      expect(hotspots[RoomType.undergroundRightmost]?.length, 3);
    });

    test('MultiFloorNavigationSystemインテグレーションテスト', () async {
      // 地下解放
      navigationSystem.unlockUnderground();
      
      // rightmostに移動
      navigationSystem.moveToRoom(RoomType.rightmost);
      expect(navigationSystem.currentRoom, RoomType.rightmost);
      expect(navigationSystem.currentFloor, FloorType.floor1);
      
      // 地下に移動
      await navigationSystem.moveToUnderground();
      expect(navigationSystem.currentFloor, FloorType.underground);
      expect(navigationSystem.currentRoom, RoomType.undergroundCenter);
      
      // 地下内移動
      navigationSystem.moveLeft();
      expect(navigationSystem.currentRoom, RoomType.undergroundLeft);
      
      // 1階に戻る
      await navigationSystem.moveToFloor1();
      expect(navigationSystem.currentFloor, FloorType.floor1);
      expect(navigationSystem.currentRoom, RoomType.rightmost);
    });

    test('エラーケーステスト', () async {
      // 地下が解放されていない状態での移動試行
      expect(floorService.canTransitionToUnderground(), false);
      
      // 間違った部屋からの地下移動試行
      floorService.unlockUnderground();
      floorService.moveToRoom(RoomType.center);
      expect(floorService.canTransitionToUnderground(), false);
      
      // 地下にいない状態での1階移動試行
      floorService.moveToRoom(RoomType.rightmost);
      expect(floorService.canTransitionToFloor1(), false);
    });
  });
}