import 'package:flutter_test/flutter_test.dart';
import 'package:escape_room/framework/escape_room/core/room_types.dart';
import 'package:escape_room/framework/escape_room/core/floor_transition_service.dart';

void main() {
  group('Navigation Boundary Tests', () {
    late FloorTransitionService service;

    setUp(() {
      service = FloorTransitionService();
    });

    test('1階では右端から先に進めない', () {
      // 1階中央から右端まで移動
      service.moveToRoom(RoomType.center);
      expect(service.canMoveRight(), true);
      
      service.moveRight(); // right
      expect(service.currentRoom, RoomType.right);
      expect(service.canMoveRight(), true);
      
      service.moveRight(); // rightmost
      expect(service.currentRoom, RoomType.rightmost);
      
      // 右端では右に移動できない
      expect(service.canMoveRight(), false);
    });

    test('1階では左端から先に進めない', () {
      // 1階中央から左端まで移動
      service.moveToRoom(RoomType.center);
      expect(service.canMoveLeft(), true);
      
      service.moveLeft(); // left
      expect(service.currentRoom, RoomType.left);
      expect(service.canMoveLeft(), true);
      
      service.moveLeft(); // leftmost
      expect(service.currentRoom, RoomType.leftmost);
      
      // 左端では左に移動できない
      expect(service.canMoveLeft(), false);
    });

    test('1階の部屋リストに隠し部屋が含まれない', () {
      final floor1Rooms = RoomUtils.getFloor1Rooms();
      expect(floor1Rooms, isNot(contains(RoomType.hiddenA)));
      expect(floor1Rooms, isNot(contains(RoomType.hiddenB)));
      
      // 通常の部屋のみ含まれる
      expect(floor1Rooms, contains(RoomType.leftmost));
      expect(floor1Rooms, contains(RoomType.left));
      expect(floor1Rooms, contains(RoomType.center));
      expect(floor1Rooms, contains(RoomType.right));
      expect(floor1Rooms, contains(RoomType.rightmost));
    });

    test('地下の部屋リストに隠し部屋が含まれない', () {
      final undergroundRooms = RoomUtils.getUndergroundRooms();
      expect(undergroundRooms, isNot(contains(RoomType.hiddenC)));
      expect(undergroundRooms, isNot(contains(RoomType.hiddenD)));
      
      // 通常の部屋のみ含まれる
      expect(undergroundRooms, contains(RoomType.undergroundLeftmost));
      expect(undergroundRooms, contains(RoomType.undergroundLeft));
      expect(undergroundRooms, contains(RoomType.undergroundCenter));
      expect(undergroundRooms, contains(RoomType.undergroundRight));
      expect(undergroundRooms, contains(RoomType.undergroundRightmost));
    });
  });
}