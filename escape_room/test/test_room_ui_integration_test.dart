import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:escape_room/game/components/test_room_with_hotspots.dart';

/// テスト部屋UI統合テスト
/// Issue #4: 透明ホットスポット機能のUI統合確認
void main() {
  group('TestRoomWithHotspots UI統合テスト', () {
    testWidgets('テスト部屋ウィジェットの基本表示テスト', (WidgetTester tester) async {
      // TestRoomWithHotspotsウィジェットをビルド
      await tester.pumpWidget(
        const MaterialApp(
          home: TestRoomWithHotspots(
            roomImagePath: 'assets/images/room_left.png',
            gameSize: Size(400, 600),
          ),
        ),
      );

      // ウィジェットが正常に表示されることを確認
      expect(find.byType(TestRoomWithHotspots), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);

      // AppBarの存在とタイトル確認
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('ホットスポットテスト'), findsOneWidget);

      // 可視性切り替えボタンの存在確認
      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });

    testWidgets('デバッグ情報の表示テスト', (WidgetTester tester) async {
      const gameSize = Size(400, 600);

      await tester.pumpWidget(
        const MaterialApp(
          home: TestRoomWithHotspots(
            roomImagePath: 'assets/images/room_left.png',
            gameSize: gameSize,
          ),
        ),
      );

      // デバッグ情報の表示確認
      expect(find.textContaining('ゲームサイズ: 400x600'), findsOneWidget);
      expect(find.textContaining('ホットスポット数: 4'), findsOneWidget);
      expect(find.textContaining('可視化:'), findsOneWidget);
    });

    testWidgets('ホットスポットタップシミュレーションテスト', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TestRoomWithHotspots(
            roomImagePath: 'assets/images/room_left.png',
            gameSize: Size(400, 600),
          ),
        ),
      );

      // ホットスポット領域を探す（可視化状態）
      expect(find.byType(GestureDetector), findsAtLeastNWidgets(4));

      // 最初のホットスポットをタップしてみる
      final firstHotspot = find.byType(GestureDetector).first;
      await tester.tap(firstHotspot);
      await tester.pumpAndSettle();

      // ダイアログが表示されることを確認
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.textContaining('🔍'), findsOneWidget); // ダイアログタイトル確認

      // ダイアログを閉じる
      await tester.tap(find.text('閉じる'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('可視性切り替え機能テスト', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TestRoomWithHotspots(
            roomImagePath: 'assets/images/room_left.png',
            gameSize: Size(400, 600),
          ),
        ),
      );

      // 初期状態で可視化されている
      expect(find.textContaining('可視化: ON'), findsOneWidget);

      // 可視性切り替えボタンをタップ
      await tester.tap(find.byIcon(Icons.visibility));
      await tester.pumpAndSettle();

      // 可視化がOFFになっていることを確認
      expect(find.textContaining('可視化: OFF'), findsOneWidget);

      // もう一度タップして戻す
      await tester.tap(find.byIcon(Icons.visibility));
      await tester.pumpAndSettle();

      // 再び可視化されていることを確認
      expect(find.textContaining('可視化: ON'), findsOneWidget);
    });

    testWidgets('レスポンシブレイアウトテスト', (WidgetTester tester) async {
      // 異なる画面サイズでのテスト
      await tester.binding.setSurfaceSize(const Size(800, 1200));

      await tester.pumpWidget(
        const MaterialApp(
          home: TestRoomWithHotspots(
            roomImagePath: 'assets/images/room_left.png',
            gameSize: Size(400, 600),
          ),
        ),
      );

      // ウィジェットが正常に表示されることを確認
      expect(find.byType(TestRoomWithHotspots), findsOneWidget);

      // ゲームサイズの表示が変わらないことを確認
      expect(find.textContaining('ゲームサイズ: 400x600'), findsOneWidget);

      // サイズを戻す
      await tester.binding.setSurfaceSize(null);
    });
  });

  group('TestHotspot データクラステスト', () {
    test('TestHotspot基本機能テスト', () {
      final hotspot = TestHotspot(
        id: 'test_hotspot',
        position: const Offset(0.1, 0.2),
        size: const Size(0.15, 0.25),
        description: 'テスト用ホットスポット',
        isVisible: true,
      );

      expect(hotspot.id, equals('test_hotspot'));
      expect(hotspot.position, equals(const Offset(0.1, 0.2)));
      expect(hotspot.size, equals(const Size(0.15, 0.25)));
      expect(hotspot.description, equals('テスト用ホットスポット'));
      expect(hotspot.isVisible, isTrue);
    });

    test('TestHotspot可視性変更テスト', () {
      var hotspot = TestHotspot(
        id: 'test_hotspot',
        position: const Offset(0.1, 0.2),
        size: const Size(0.15, 0.25),
        description: 'テスト用ホットスポット',
        isVisible: false,
      );

      expect(hotspot.isVisible, isFalse);

      // 可視性を変更（新しいインスタンス作成）
      hotspot = TestHotspot(
        id: hotspot.id,
        position: hotspot.position,
        size: hotspot.size,
        description: hotspot.description,
        isVisible: true,
      );

      expect(hotspot.isVisible, isTrue);
    });
  });
}
