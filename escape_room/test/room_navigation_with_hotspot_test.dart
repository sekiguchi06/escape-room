import 'package:flutter_test/flutter_test.dart';
import 'package:escape_room/game/components/room_navigation_system.dart';
import 'package:escape_room/game/components/room_hotspot_system.dart';

/// ルーム遷移とホットスポット統合テスト
/// Issue #4: テスト部屋への遷移とホットスポット機能の検証
void main() {
  group('ルーム遷移とテスト部屋統合テスト', () {
    late RoomNavigationSystem navigationSystem;
    late RoomHotspotSystem hotspotSystem;

    setUp(() {
      navigationSystem = RoomNavigationSystem();
      hotspotSystem = RoomHotspotSystem();
      // 初期状態に戻す
      navigationSystem.resetToInitialRoom();
    });

    test('基本的なルーム遷移テスト', () {
      // 初期位置は中央
      expect(navigationSystem.currentRoom, equals(RoomType.center));
      expect(navigationSystem.currentRoomIndex, equals(0));

      // 右に移動（center → right）
      expect(navigationSystem.canMoveRight, isTrue);
      navigationSystem.moveRight();
      expect(navigationSystem.currentRoom, equals(RoomType.right));
      expect(navigationSystem.currentRoomIndex, equals(1));

      // さらに右に移動（right → rightmost）
      expect(navigationSystem.canMoveRight, isTrue);
      navigationSystem.moveRight();
      expect(navigationSystem.currentRoom, equals(RoomType.rightmost));
      expect(navigationSystem.currentRoomIndex, equals(2));

      // さらに右に移動（rightmost → testRoom）※新機能
      expect(navigationSystem.canMoveRight, isTrue);
      navigationSystem.moveRight();
      expect(navigationSystem.currentRoom, equals(RoomType.testRoom));
      expect(navigationSystem.currentRoomIndex, equals(3));

      // テスト部屋が最右端なので、これ以上右には進めない
      expect(navigationSystem.canMoveRight, isFalse);
    });

    test('テスト部屋から左への戻りテスト', () {
      // テスト部屋まで移動
      navigationSystem.moveRight(); // center → right
      navigationSystem.moveRight(); // right → rightmost
      navigationSystem.moveRight(); // rightmost → testRoom
      expect(navigationSystem.currentRoom, equals(RoomType.testRoom));

      // 左に戻る（testRoom → rightmost）
      expect(navigationSystem.canMoveLeft, isTrue);
      navigationSystem.moveLeft();
      expect(navigationSystem.currentRoom, equals(RoomType.rightmost));
      expect(navigationSystem.currentRoomIndex, equals(2));

      // さらに左に戻る（rightmost → right）
      navigationSystem.moveLeft();
      expect(navigationSystem.currentRoom, equals(RoomType.right));
      expect(navigationSystem.currentRoomIndex, equals(1));
    });

    test('テスト部屋のホットスポット取得テスト', () {
      // テスト部屋に移動
      navigationSystem.moveRight(); // center → right
      navigationSystem.moveRight(); // right → rightmost
      navigationSystem.moveRight(); // rightmost → testRoom

      // テスト部屋のホットスポットを取得
      final hotspots = hotspotSystem.getCurrentRoomHotspots();

      // 4つのテスト用ホットスポットが存在することを確認
      expect(hotspots.length, equals(4));

      // 各ホットスポットのIDを確認（新生成画像解析ベース）
      final hotspotIds = hotspots.map((h) => h.id).toList();
      expect(hotspotIds, contains('test_reading_stand'));
      expect(hotspotIds, contains('test_chandelier'));
      expect(hotspotIds, contains('test_desk_chair'));
      expect(hotspotIds, contains('test_floor_light'));
    });

    test('テスト部屋ホットスポット座標精度テスト（新生成画像解析ベース）', () {
      // テスト部屋に移動
      navigationSystem.moveRight();
      navigationSystem.moveRight();
      navigationSystem.moveRight();

      final hotspots = hotspotSystem.getCurrentRoomHotspots();

      // 左側読書台座標確認（画像認識版: 実際のオブジェクト位置）
      final readingStand = hotspots.firstWhere(
        (h) => h.id == 'test_reading_stand',
      );
      expect(readingStand.position.dx, closeTo(0.05, 0.01)); // 実際の読書台位置
      expect(readingStand.position.dy, closeTo(0.5, 0.01)); // 実際の読書台位置
      expect(readingStand.size.width, closeTo(0.25, 0.01)); // 適度なタップエリア
      expect(readingStand.size.height, closeTo(0.25, 0.01)); // 適度なタップエリア

      // 中央上部シャンデリア座標確認（画像認識版: 実際のオブジェクト位置）
      final chandelier = hotspots.firstWhere((h) => h.id == 'test_chandelier');
      expect(chandelier.position.dx, closeTo(0.4, 0.01)); // 実際のシャンデリア位置
      expect(chandelier.position.dy, closeTo(0.08, 0.01)); // 実際のシャンデリア位置

      // 右側机椅子座標確認（画像認識版: 実際のオブジェクト位置）
      final deskChair = hotspots.firstWhere((h) => h.id == 'test_desk_chair');
      expect(deskChair.position.dx, closeTo(0.75, 0.01)); // 実際の机位置
      expect(deskChair.position.dy, closeTo(0.55, 0.01)); // 実際の机位置

      // 床面光る部分座標確認（画像認識版: 実際のオブジェクト位置）
      final floorLight = hotspots.firstWhere((h) => h.id == 'test_floor_light');
      expect(floorLight.position.dx, closeTo(0.4, 0.01)); // 実際の光の位置
      expect(floorLight.position.dy, closeTo(0.82, 0.01)); // 実際の光の位置
    });

    test('他の部屋でのホットスポット正常性確認', () {
      // 中央部屋（初期位置）
      expect(navigationSystem.currentRoom, equals(RoomType.center));
      var hotspots = hotspotSystem.getCurrentRoomHotspots();
      expect(hotspots.isNotEmpty, isTrue);
      expect(hotspots.any((h) => h.id.startsWith('test_')), isFalse); // テスト用でない

      // 右の部屋
      navigationSystem.moveRight();
      expect(navigationSystem.currentRoom, equals(RoomType.right));
      hotspots = hotspotSystem.getCurrentRoomHotspots();
      expect(hotspots.isNotEmpty, isTrue);
      expect(hotspots.any((h) => h.id.startsWith('test_')), isFalse); // テスト用でない

      // 最右端の部屋
      navigationSystem.moveRight();
      expect(navigationSystem.currentRoom, equals(RoomType.rightmost));
      hotspots = hotspotSystem.getCurrentRoomHotspots();
      expect(hotspots.isNotEmpty, isTrue);
      expect(hotspots.any((h) => h.id.startsWith('test_')), isFalse); // テスト用でない

      // テスト部屋
      navigationSystem.moveRight();
      expect(navigationSystem.currentRoom, equals(RoomType.testRoom));
      hotspots = hotspotSystem.getCurrentRoomHotspots();
      expect(hotspots.length, equals(4));
      expect(hotspots.every((h) => h.id.startsWith('test_')), isTrue); // 全てテスト用
    });

    test('ルーム遷移の境界値テスト', () {
      // 最左端まで移動
      navigationSystem.moveLeft(); // center → left
      navigationSystem.moveLeft(); // left → leftmost
      expect(navigationSystem.currentRoom, equals(RoomType.leftmost));
      expect(navigationSystem.canMoveLeft, isFalse);

      // 最右端（テスト部屋）まで移動
      navigationSystem.resetToInitialRoom();
      navigationSystem.moveRight(); // center → right
      navigationSystem.moveRight(); // right → rightmost
      navigationSystem.moveRight(); // rightmost → testRoom
      expect(navigationSystem.currentRoom, equals(RoomType.testRoom));
      expect(navigationSystem.canMoveRight, isFalse);
    });

    test('ゲームリスタート機能テスト', () {
      // テスト部屋まで移動
      navigationSystem.moveRight();
      navigationSystem.moveRight();
      navigationSystem.moveRight();
      expect(navigationSystem.currentRoom, equals(RoomType.testRoom));

      // リスタートで中央に戻る
      navigationSystem.resetToInitialRoom();
      expect(navigationSystem.currentRoom, equals(RoomType.center));
      expect(navigationSystem.currentRoomIndex, equals(0));
    });
  });

  group('テスト部屋ホットスポット詳細テスト', () {
    test('テスト用ホットスポットの名前と説明テスト', () {
      final navigationSystem = RoomNavigationSystem();
      final hotspotSystem = RoomHotspotSystem();

      // テスト部屋に移動
      navigationSystem.resetToInitialRoom();
      navigationSystem.moveRight();
      navigationSystem.moveRight();
      navigationSystem.moveRight();

      final hotspots = hotspotSystem.getCurrentRoomHotspots();

      // 各ホットスポットの名前と説明をチェック（新生成画像解析ベース）
      final readingStand = hotspots.firstWhere(
        (h) => h.id == 'test_reading_stand',
      );
      expect(readingStand.name, equals('古の読書台'));
      expect(readingStand.description, contains('羊皮紙'));

      final chandelier = hotspots.firstWhere((h) => h.id == 'test_chandelier');
      expect(chandelier.name, equals('黄金のシャンデリア'));
      expect(chandelier.description, contains('豪華な黄金'));

      final deskChair = hotspots.firstWhere((h) => h.id == 'test_desk_chair');
      expect(deskChair.name, equals('学者の机'));
      expect(deskChair.description, contains('古い書物'));

      final floorLight = hotspots.firstWhere((h) => h.id == 'test_floor_light');
      expect(floorLight.name, equals('神秘の光'));
      expect(floorLight.description, contains('神秘的な光'));
    });

    test('テスト用ホットスポットのコールバック存在確認', () {
      final navigationSystem = RoomNavigationSystem();
      final hotspotSystem = RoomHotspotSystem();

      navigationSystem.resetToInitialRoom();
      navigationSystem.moveRight();
      navigationSystem.moveRight();
      navigationSystem.moveRight();

      final hotspots = hotspotSystem.getCurrentRoomHotspots();

      // 全てのテスト用ホットスポットにタップコールバックが設定されていることを確認
      for (final hotspot in hotspots) {
        expect(hotspot.onTap, isNotNull);
        expect(hotspot.id, startsWith('test_'));
      }
    });
  });
}
