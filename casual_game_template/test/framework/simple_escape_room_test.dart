import 'package:flutter_test/flutter_test.dart';
import 'package:flame/components.dart';

import '../../lib/framework/game_types/quick_templates/escape_room_template.dart';
import '../../lib/game/example_games/simple_escape_room.dart';

/// シンプル脱出ゲーム機能の基本ユニットテスト
/// flame_testを使わずFlutter標準テストフレームワークで実装
void main() {
  group('脱出ゲーム基本機能テスト', () {
    
    test('1. UTF-8文字列処理: 基本漢字テスト', () {
      // 日本語文字化け対策のUTF-8処理をテスト
      const testMessage = '鍵を選択しました';
      final utf8Message = String.fromCharCodes(testMessage.runes);
      
      // 検証: UTF-8処理後も文字列が保持される
      expect(utf8Message, equals(testMessage));
      expect(utf8Message.contains('鍵'), isTrue);
      expect(utf8Message.contains('選択'), isTrue);
      expect(utf8Message.length, equals(8)); // 具体的文字数検証
    });

    test('2. UTF-8文字列処理: 複合文字テスト', () {
      // 複雑な日本語メッセージの処理
      const testMessage = 'ここから脱出できそうだ';
      final utf8Message = String.fromCharCodes(testMessage.runes);
      
      expect(utf8Message, equals(testMessage));
      expect(utf8Message.contains('ここから'), isTrue);
      expect(utf8Message.contains('脱出'), isTrue);
      expect(utf8Message.length, equals(11)); // 具体的文字数検証
    });

    test('3. UTF-8文字列処理: 特殊文字・記号テスト', () {
      // 記号や特殊文字を含むメッセージ
      const testMessage = '数字の組み合わせが必要...!';
      final utf8Message = String.fromCharCodes(testMessage.runes);
      
      expect(utf8Message, equals(testMessage));
      expect(utf8Message.contains('数字'), isTrue);
      expect(utf8Message.contains('...!'), isTrue);
      expect(utf8Message.length, equals(15)); // 具体的文字数検証
    });

    test('4. レスポンシブデザイン計算: 標準画面サイズ（1920x1080）', () {
      // 画面比率ベースの領域計算をテスト
      final screenSize = Vector2(1920, 1080);
      
      // セーフエリアマージン（画面の5%、12%）
      final safeAreaMargin = Vector2(screenSize.x * 0.05, screenSize.y * 0.12);
      expect(safeAreaMargin.x, closeTo(96.0, 0.1));
      expect(safeAreaMargin.y, closeTo(129.6, 0.1));
      
      // ゲーム領域サイズ（画面の90%、73%）
      final gameAreaSize = Vector2(screenSize.x * 0.9, screenSize.y * 0.73);
      expect(gameAreaSize.x, closeTo(1728.0, 0.1));
      expect(gameAreaSize.y, closeTo(788.4, 0.1));
      
      // 比率が正しく計算されることを確認
      expect(gameAreaSize.x / screenSize.x, closeTo(0.9, 0.001));
      expect(gameAreaSize.y / screenSize.y, closeTo(0.73, 0.001));
    });

    test('5. レスポンシブデザイン計算: モバイル画面サイズ（375x667）', () {
      // モバイル画面での比率計算
      final screenSize = Vector2(375, 667);
      
      final safeAreaMargin = Vector2(screenSize.x * 0.05, screenSize.y * 0.12);
      expect(safeAreaMargin.x, closeTo(18.75, 0.1));
      expect(safeAreaMargin.y, closeTo(80.04, 0.1));
      
      final gameAreaSize = Vector2(screenSize.x * 0.9, screenSize.y * 0.73);
      expect(gameAreaSize.x, closeTo(337.5, 0.1));
      expect(gameAreaSize.y, closeTo(486.91, 0.1));
    });

    test('6. コンポーネントサイズ計算: ドアとホットスポット', () {
      // レスポンシブコンポーネントサイズ計算
      final screenSize = Vector2(1920, 1080);
      
      // ドアサイズ（画面の8%、12%）
      final doorSize = Vector2(screenSize.x * 0.08, screenSize.y * 0.12);
      expect(doorSize.x, closeTo(153.6, 0.1));
      expect(doorSize.y, closeTo(129.6, 0.1));
      
      // ホットスポットサイズ（画面の10%、14%）
      final hotspotSize = Vector2(screenSize.x * 0.1, screenSize.y * 0.14);
      expect(hotspotSize.x, closeTo(192.0, 0.1));
      expect(hotspotSize.y, closeTo(151.2, 0.1));
    });

    test('7. ゲーム状態enum: EscapeRoomState検証', () {
      // EscapeRoomState列挙型の基本テスト
      final states = EscapeRoomState.values;
      expect(states.length, equals(5));
      
      // 各状態の名前とdescriptionを確認
      expect(EscapeRoomState.exploring.name, equals('exploring'));
      expect(EscapeRoomState.exploring.description, equals('部屋を探索中'));
      
      expect(EscapeRoomState.escaped.name, equals('escaped'));
      expect(EscapeRoomState.escaped.description, equals('脱出成功！'));
      
      expect(EscapeRoomState.timeUp.name, equals('timeUp'));
      expect(EscapeRoomState.timeUp.description, equals('時間切れ'));
    });

    test('8. ゲーム設定クラス: EscapeRoomConfig検証', () {
      // デフォルト設定のテスト
      const defaultConfig = EscapeRoomConfig();
      expect(defaultConfig.timeLimit.inMinutes, equals(10));
      expect(defaultConfig.maxInventoryItems, equals(8));
      expect(defaultConfig.requiredItems.length, equals(3));
      expect(defaultConfig.requiredItems, contains('key'));
      expect(defaultConfig.requiredItems, contains('code'));
      expect(defaultConfig.requiredItems, contains('tool'));
      expect(defaultConfig.roomTheme, equals('office'));
      expect(defaultConfig.difficultyLevel, equals(1));
      
      // カスタム設定のテスト
      const customConfig = EscapeRoomConfig(
        timeLimit: Duration(minutes: 5),
        maxInventoryItems: 4,
        requiredItems: ['key', 'code'],
        roomTheme: 'vault',
        difficultyLevel: 3,
      );
      expect(customConfig.timeLimit.inMinutes, equals(5));
      expect(customConfig.maxInventoryItems, equals(4));
      expect(customConfig.requiredItems.length, equals(2));
      expect(customConfig.roomTheme, equals('vault'));
      expect(customConfig.difficultyLevel, equals(3));
    });

    test('9. GameItemクラス: アイテム定義検証', () {
      // ゲームアイテムの基本テスト
      const keyItem = GameItem(
        id: 'key',
        name: '鍵',
        description: 'ドアを開けるのに必要な鍵',
        canUse: true,
        canCombine: false,
      );
      
      expect(keyItem.id, equals('key'));
      expect(keyItem.name, equals('鍵'));
      expect(keyItem.description, equals('ドアを開けるのに必要な鍵'));
      expect(keyItem.canUse, isTrue);
      expect(keyItem.canCombine, isFalse);
      
      // デフォルト値のテスト
      const simpleItem = GameItem(
        id: 'tool',
        name: 'ドライバー',
        description: '何かを分解するのに使えそう',
      );
      expect(simpleItem.canUse, isTrue); // デフォルト値
      expect(simpleItem.canCombine, isFalse); // デフォルト値
    });

    test('10. InventoryManagerクラス: インベントリ基本操作', () {
      // インベントリマネージャーの基本テスト
      var selectedItem = '';
      final inventory = InventoryManager(
        maxItems: 3,
        onItemSelected: (itemId) => selectedItem = itemId,
      );
      
      // 初期状態
      expect(inventory.items.isEmpty, isTrue);
      expect(inventory.hasItem('key'), isFalse);
      
      // アイテム追加
      final addResult1 = inventory.addItem('key');
      expect(addResult1, isTrue);
      expect(inventory.items.length, equals(1));
      expect(inventory.hasItem('key'), isTrue);
      
      // 同じアイテムの重複追加（失敗）
      final addResult2 = inventory.addItem('key');
      expect(addResult2, isFalse);
      expect(inventory.items.length, equals(1));
      
      // 最大容量テスト
      inventory.addItem('code');
      inventory.addItem('tool');
      expect(inventory.items.length, equals(3));
      
      // 容量超過（失敗）
      final addResult3 = inventory.addItem('map');
      expect(addResult3, isFalse);
      expect(inventory.items.length, equals(3));
      
      // アイテム削除
      final removeResult = inventory.removeItem('code');
      expect(removeResult, isTrue);
      expect(inventory.items.length, equals(2));
      expect(inventory.hasItem('code'), isFalse);
      
      // アイテム選択
      inventory.selectItem('key');
      expect(selectedItem, equals('key'));
      
      // 全消去
      inventory.clear();
      expect(inventory.items.isEmpty, isTrue);
    });

    test('11. 境界値テスト: 最小・最大画面サイズでの計算', () {
      // 最小画面サイズ（iPhone SE相当）
      final minScreenSize = Vector2(320, 568);
      final minSafeArea = Vector2(minScreenSize.x * 0.05, minScreenSize.y * 0.12);
      final minGameArea = Vector2(minScreenSize.x * 0.9, minScreenSize.y * 0.73);
      
      expect(minSafeArea.x, greaterThan(0));
      expect(minSafeArea.y, greaterThan(0));
      expect(minGameArea.x, lessThan(minScreenSize.x));
      expect(minGameArea.y, lessThan(minScreenSize.y));
      
      // 最大画面サイズ（4K相当）
      final maxScreenSize = Vector2(3840, 2160);
      final maxSafeArea = Vector2(maxScreenSize.x * 0.05, maxScreenSize.y * 0.12);
      final maxGameArea = Vector2(maxScreenSize.x * 0.9, maxScreenSize.y * 0.73);
      
      expect(maxSafeArea.x, closeTo(192.0, 0.1));
      expect(maxSafeArea.y, closeTo(259.2, 0.1));
      expect(maxGameArea.x, closeTo(3456.0, 0.1));
      expect(maxGameArea.y, closeTo(1576.8, 0.1));
    });

    test('12. エラーハンドリング: 空文字列・null安全性', () {
      // 空文字列のUTF-8処理
      const emptyString = '';
      final utf8Empty = String.fromCharCodes(emptyString.runes);
      expect(utf8Empty, equals(''));
      expect(utf8Empty.isEmpty, isTrue);
      
      // ゼロベクトル計算
      final zeroSize = Vector2.zero();
      final zeroMargin = Vector2(zeroSize.x * 0.05, zeroSize.y * 0.12);
      expect(zeroMargin.x, equals(0.0));
      expect(zeroMargin.y, equals(0.0));
    });
  });
}