import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';
import '../lib/game/components/inventory_system.dart';

void main() {
  group('アイテム組み合わせシステムテスト', () {
    late InventorySystem inventorySystem;

    setUp(() {
      inventorySystem = InventorySystem();
      inventorySystem.resetToInitialState();
    });

    test('基本的なアイテム組み合わせテスト', () {
      // アイテムを追加
      expect(inventorySystem.addItem('coin'), true);
      expect(inventorySystem.addItem('key'), true);

      // coinを選択
      inventorySystem.selectSlot(0);
      expect(inventorySystem.selectedItemId, 'coin');

      // 組み合わせ可能性をチェック
      expect(inventorySystem.canCombineSelectedItems(), true);
      expect(inventorySystem.canCombineWithSelected('key'), true);

      // 組み合わせ実行
      expect(inventorySystem.combineItemWithSelected('key'), true);

      // 結果確認
      expect(inventorySystem.inventory[0], 'master_key');
      expect(inventorySystem.inventory[1], null); // keyは削除された
      expect(inventorySystem.selectedItemId, null); // 選択解除

      debugPrint('✅ 基本的な組み合わせテスト成功: coin + key → master_key');
    });

    test('組み合わせ不可能なアイテムテスト', () {
      // アイテムを追加
      expect(inventorySystem.addItem('gem'), true);
      expect(inventorySystem.addItem('book'), true);

      // gemを選択
      inventorySystem.selectSlot(0);
      expect(inventorySystem.selectedItemId, 'gem');

      // 組み合わせ可能性をチェック
      expect(inventorySystem.canCombineSelectedItems(), false);
      expect(inventorySystem.canCombineWithSelected('book'), false);

      // 組み合わせ試行（失敗するはず）
      expect(inventorySystem.combineItemWithSelected('book'), false);

      // アイテムは変更されていない
      expect(inventorySystem.inventory[0], 'gem');
      expect(inventorySystem.inventory[1], 'book');

      debugPrint('✅ 組み合わせ不可能テスト成功: gem + book は組み合わせ不可');
    });

    test('選択なしでの組み合わせテスト', () {
      // アイテム追加、選択なし
      expect(inventorySystem.addItem('coin'), true);
      expect(inventorySystem.addItem('key'), true);

      // 何も選択していない状態
      expect(inventorySystem.selectedItemId, null);
      expect(inventorySystem.canCombineSelectedItems(), false);

      debugPrint('✅ 選択なしテスト成功: 何も選択していない時は組み合わせ不可');
    });

    test('同一アイテム組み合わせテスト', () {
      // 同じアイテムを追加
      expect(inventorySystem.addItem('coin'), true);
      expect(inventorySystem.addItem('coin'), true);

      inventorySystem.selectSlot(0);
      expect(inventorySystem.canCombineWithSelected('coin'), false);

      debugPrint('✅ 同一アイテムテスト成功: 同じアイテム同士は組み合わせ不可');
    });
  });
}
