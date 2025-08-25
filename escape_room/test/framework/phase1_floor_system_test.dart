import 'package:flutter_test/flutter_test.dart';
import 'package:escape_room/framework/escape_room/core/room_types.dart';
import 'package:escape_room/framework/escape_room/core/floor_transition_service.dart';
import 'package:escape_room/framework/ui/multi_floor_navigation_system.dart';
import 'package:escape_room/game/items/underground_items.dart';
import 'package:escape_room/game/components/rooms/underground_rooms.dart';

void main() {
  group('Phase 1: Floor System Tests', () {
    setUp(() {
      // テスト前に状態をリセット
      FloorTransitionService().resetToInitialState();
      MultiFloorNavigationSystem().resetToInitialState();
    });
    
    group('RoomTypes and FloorTypes', () {
      test('Floor1 rooms should return correct floor type', () {
        expect(RoomUtils.getFloorFromRoom(RoomType.leftmost), FloorType.floor1);
        expect(RoomUtils.getFloorFromRoom(RoomType.left), FloorType.floor1);
        expect(RoomUtils.getFloorFromRoom(RoomType.center), FloorType.floor1);
        expect(RoomUtils.getFloorFromRoom(RoomType.right), FloorType.floor1);
        expect(RoomUtils.getFloorFromRoom(RoomType.rightmost), FloorType.floor1);
      });
      
      test('Underground rooms should return correct floor type', () {
        expect(RoomUtils.getFloorFromRoom(RoomType.undergroundLeftmost), FloorType.underground);
        expect(RoomUtils.getFloorFromRoom(RoomType.undergroundLeft), FloorType.underground);
        expect(RoomUtils.getFloorFromRoom(RoomType.undergroundCenter), FloorType.underground);
        expect(RoomUtils.getFloorFromRoom(RoomType.undergroundRight), FloorType.underground);
        expect(RoomUtils.getFloorFromRoom(RoomType.undergroundRightmost), FloorType.underground);
      });
      
      test('Room indices should be correct', () {
        expect(RoomUtils.getRoomIndex(RoomType.leftmost), -2);
        expect(RoomUtils.getRoomIndex(RoomType.left), -1);
        expect(RoomUtils.getRoomIndex(RoomType.center), 0);
        expect(RoomUtils.getRoomIndex(RoomType.right), 1);
        expect(RoomUtils.getRoomIndex(RoomType.rightmost), 2);
        
        expect(RoomUtils.getRoomIndex(RoomType.undergroundLeftmost), -2);
        expect(RoomUtils.getRoomIndex(RoomType.undergroundLeft), -1);
        expect(RoomUtils.getRoomIndex(RoomType.undergroundCenter), 0);
        expect(RoomUtils.getRoomIndex(RoomType.undergroundRight), 1);
        expect(RoomUtils.getRoomIndex(RoomType.undergroundRightmost), 2);
      });
      
      test('Room lists should be correct', () {
        final floor1Rooms = RoomUtils.getFloor1Rooms();
        expect(floor1Rooms.length, 5);
        expect(floor1Rooms, contains(RoomType.leftmost));
        expect(floor1Rooms, contains(RoomType.rightmost));
        
        final undergroundRooms = RoomUtils.getUndergroundRooms();
        expect(undergroundRooms.length, 5);
        expect(undergroundRooms, contains(RoomType.undergroundLeftmost));
        expect(undergroundRooms, contains(RoomType.undergroundRightmost));
      });
    });
    
    group('FloorTransitionService', () {
      late FloorTransitionService service;
      
      setUp(() {
        service = FloorTransitionService();
        service.resetToInitialState();
      });
      
      test('Initial state should be correct', () {
        expect(service.currentFloor, FloorType.floor1);
        expect(service.currentRoom, RoomType.center);
        expect(service.isUndergroundUnlocked, false);
        expect(service.canTransitionToUnderground(), false);
      });
      
      test('Underground unlock should work correctly', () {
        expect(service.isUndergroundUnlocked, false);
        service.unlockUnderground();
        expect(service.isUndergroundUnlocked, true);
      });
      
      test('Underground unlock condition should work correctly', () {
        expect(service.checkUndergroundUnlockCondition(['key', 'coin']), false);
        expect(service.checkUndergroundUnlockCondition(['main_escape_key']), true);
        expect(service.checkUndergroundUnlockCondition(['key', 'main_escape_key', 'coin']), true);
      });
      
      test('Floor transition conditions should work correctly', () async {
        // 初期状態では地下移動不可
        expect(service.canTransitionToUnderground(), false);
        
        // 地下解放して最右端に移動すれば地下移動可能
        service.unlockUnderground();
        service.moveToRoom(RoomType.rightmost);
        expect(service.canTransitionToUnderground(), true);
        
        // 地下に移動
        await service.transitionToFloor(FloorType.underground);
        expect(service.currentFloor, FloorType.underground);
        expect(service.currentRoom, RoomType.undergroundCenter);
        
        // 地下中央にいれば1階移動可能
        expect(service.canTransitionToFloor1(), true);
      });
      
      test('Room navigation within floor should work correctly', () async {
        // 1階でのナビゲーション
        service.moveToRoom(RoomType.center);
        expect(service.canMoveLeft(), true);
        expect(service.canMoveRight(), true);
        
        service.moveLeft();
        expect(service.currentRoom, RoomType.left);
        
        service.moveRight();
        expect(service.currentRoom, RoomType.center);
        
        // 地下でのナビゲーション
        service.unlockUnderground();
        service.moveToRoom(RoomType.rightmost);
        await service.transitionToFloor(FloorType.underground);
        
        expect(service.canMoveLeft(), true);
        expect(service.canMoveRight(), true);
        
        service.moveLeft();
        expect(service.currentRoom, RoomType.undergroundLeft);
        
        service.moveRight();
        expect(service.currentRoom, RoomType.undergroundCenter);
      });
    });
    
    group('MultiFloorNavigationSystem', () {
      late MultiFloorNavigationSystem navigation;
      
      setUp(() {
        navigation = MultiFloorNavigationSystem();
        navigation.resetToInitialState();
      });
      
      test('Initial state should match FloorTransitionService', () {
        expect(navigation.currentFloor, FloorType.floor1);
        expect(navigation.currentRoom, RoomType.center);
        expect(navigation.isUndergroundUnlocked, false);
      });
      
      test('Navigation methods should work correctly', () {
        expect(navigation.canMoveLeft, true);
        expect(navigation.canMoveRight, true);
        expect(navigation.canMoveToUnderground, false);
        
        navigation.moveLeft();
        expect(navigation.currentRoom, RoomType.left);
        
        navigation.moveRight();
        expect(navigation.currentRoom, RoomType.center);
      });
      
      test('Underground unlock and access should work correctly', () async {
        expect(navigation.canMoveToUnderground, false);
        
        navigation.unlockUnderground();
        navigation.moveToRoom(RoomType.rightmost);
        expect(navigation.canMoveToUnderground, true);
        
        await navigation.moveToUnderground();
        expect(navigation.currentFloor, FloorType.underground);
        expect(navigation.currentRoom, RoomType.undergroundCenter);
      });
      
      test('Auto unlock should work with inventory check', () {
        expect(navigation.isUndergroundUnlocked, false);
        
        navigation.checkAndUnlockUnderground(['key', 'coin']);
        expect(navigation.isUndergroundUnlocked, false);
        
        navigation.checkAndUnlockUnderground(['main_escape_key']);
        expect(navigation.isUndergroundUnlocked, true);
      });
    });
    
    group('UndergroundItems', () {
      test('Item definitions should be correct', () {
        expect(UndergroundItems.items.length, 5);
        expect(UndergroundItems.items.containsKey('dark_crystal'), true);
        expect(UndergroundItems.items.containsKey('ritual_stone'), true);
        expect(UndergroundItems.items.containsKey('pure_water'), true);
        expect(UndergroundItems.items.containsKey('ancient_rune'), true);
        expect(UndergroundItems.items.containsKey('underground_key'), true);
      });
      
      test('Item room assignments should be correct', () {
        final darkCrystal = UndergroundItems.items['dark_crystal']!;
        expect(darkCrystal.roomType, RoomType.undergroundLeftmost);
        
        final ritualStone = UndergroundItems.items['ritual_stone']!;
        expect(ritualStone.roomType, RoomType.undergroundLeft);
        
        final pureWater = UndergroundItems.items['pure_water']!;
        expect(pureWater.roomType, RoomType.undergroundCenter);
        
        final ancientRune = UndergroundItems.items['ancient_rune']!;
        expect(ancientRune.roomType, RoomType.undergroundRight);
        
        final undergroundKey = UndergroundItems.items['underground_key']!;
        expect(undergroundKey.roomType, RoomType.undergroundRightmost);
      });
      
      test('Combination rules should be correct', () {
        expect(UndergroundItems.combinations.length, 1);
        
        final combination = UndergroundItems.combinations.first;
        expect(combination.inputs.length, 3);
        expect(combination.inputs, contains('dark_crystal'));
        expect(combination.inputs, contains('ritual_stone'));
        expect(combination.inputs, contains('pure_water'));
        expect(combination.output, 'underground_master_key');
      });
      
      test('Master key combination check should work correctly', () {
        expect(UndergroundItems.hasAllMasterKeyIngredients([]), false);
        expect(UndergroundItems.hasAllMasterKeyIngredients(['dark_crystal']), false);
        expect(UndergroundItems.hasAllMasterKeyIngredients(['dark_crystal', 'ritual_stone']), false);
        expect(UndergroundItems.hasAllMasterKeyIngredients(['dark_crystal', 'ritual_stone', 'pure_water']), true);
        expect(UndergroundItems.hasAllMasterKeyIngredients(['dark_crystal', 'ritual_stone', 'pure_water', 'extra_item']), true);
      });
      
      test('Item utility methods should work correctly', () {
        final itemIds = UndergroundItems.getItemIds();
        expect(itemIds.length, 5);
        
        final leftmostItems = UndergroundItems.getItemsForRoom(RoomType.undergroundLeftmost);
        expect(leftmostItems, contains('dark_crystal'));
        
        expect(UndergroundItems.isUndergroundItem('dark_crystal'), true);
        expect(UndergroundItems.isUndergroundItem('regular_key'), false);
      });
    });
    
    group('UndergroundRoomConfig', () {
      test('Background paths should be defined for all underground rooms', () {
        expect(UndergroundRoomConfig.backgroundPaths.length, 5);
        expect(UndergroundRoomConfig.backgroundPaths.containsKey(RoomType.undergroundLeftmost), true);
        expect(UndergroundRoomConfig.backgroundPaths.containsKey(RoomType.undergroundLeft), true);
        expect(UndergroundRoomConfig.backgroundPaths.containsKey(RoomType.undergroundCenter), true);
        expect(UndergroundRoomConfig.backgroundPaths.containsKey(RoomType.undergroundRight), true);
        expect(UndergroundRoomConfig.backgroundPaths.containsKey(RoomType.undergroundRightmost), true);
      });
      
      test('Hotspot definitions should exist for all underground rooms', () {
        final hotspots = UndergroundRoomConfig.getUndergroundHotspots(onItemDiscovered: null);
        expect(hotspots.length, 5);
        
        // 各部屋に3個ずつホットスポットがあることを確認（計15個）
        expect(hotspots[RoomType.undergroundLeftmost]?.length, 3);
        expect(hotspots[RoomType.undergroundLeft]?.length, 3);
        expect(hotspots[RoomType.undergroundCenter]?.length, 3);
        expect(hotspots[RoomType.undergroundRight]?.length, 3);
        expect(hotspots[RoomType.undergroundRightmost]?.length, 3);
        
        // 総ホットスポット数が15個であることを確認
        final totalHotspots = hotspots.values.fold(0, (sum, list) => sum + list.length);
        expect(totalHotspots, 15);
      });
    });
  });
}