import 'package:flutter/foundation.dart';
import 'item_combination_manager.dart';
import '../../components/inventory_manager.dart';
import '../../../services/proper_hotspot_placement_service.dart';

/// ゲーム相互作用サービス
/// プレイヤーとゲームオブジェクトの相互作用を管理
class GameInteractionService {
  final InventoryManager _inventoryManager;
  final ItemCombinationManager _itemCombinationManager;

  GameInteractionService({
    required InventoryManager inventoryManager,
    required ItemCombinationManager itemCombinationManager,
  }) : _inventoryManager = inventoryManager,
       _itemCombinationManager = itemCombinationManager;

  /// 相互作用モーダルを表示
  void showInteractionModal({
    required String title,
    required String description,
    required InteractionType type,
    required String objectId,
  }) {
    // TODO: Modal system integration needed
    debugPrint('🔍 Showing interaction modal for: $objectId - $description');
  }

  /// 成功モーダルを表示
  void showSuccessModal({
    required String title,
    required String message,
    String? itemId,
    String? itemName,
  }) {
    // TODO: Modal system integration needed
    debugPrint('🎉 Showing success modal: $title - $message');
    if (itemId != null) {
      debugPrint('   Item: $itemName ($itemId)');
    }
  }

  /// アイテムをインベントリに追加
  bool addItemToInventory(String itemId, {String? itemName}) {
    final success = _inventoryManager.addItem(itemId);

    if (success) {
      debugPrint('📦 Item added to inventory: $itemId');

      // アイテム取得成功モーダルを表示
      showSuccessModal(
        title: 'アイテムを取得しました！',
        message: '${itemName ?? itemId}を手に入れました。',
        itemId: itemId,
        itemName: itemName,
      );
    } else {
      debugPrint('❌ Failed to add item to inventory: $itemId');
    }

    return success;
  }

  /// アイテムをインベントリから削除
  bool removeItemFromInventory(String itemId) {
    final success = _inventoryManager.removeItem(itemId);

    if (success) {
      debugPrint('🗑️ Item removed from inventory: $itemId');
    } else {
      debugPrint('❌ Failed to remove item from inventory: $itemId');
    }

    return success;
  }

  /// インベントリにアイテムがあるかチェック
  bool hasItemInInventory(String itemId) {
    return _inventoryManager.hasItem(itemId);
  }

  /// アイテム組み合わせを試行
  CombinationResult? tryItemCombination({
    required List<String> itemIds,
    required String ruleId,
  }) {
    debugPrint('🔄 Trying item combination: $itemIds for rule $ruleId');

    final result = _itemCombinationManager.attemptCombination(ruleId, itemIds);

    if (result.success) {
      debugPrint('✅ Combination successful: $ruleId');

      // 組み合わせが成功した場合、アイテムを消費
      for (final itemId in result.consumedItems) {
        removeItemFromInventory(itemId);
      }

      // 結果アイテムがある場合は追加
      if (result.newItemId != null) {
        addItemToInventory(result.newItemId!, itemName: result.message);
      }

      // 成功メッセージを表示
      showSuccessModal(
        title: '組み合わせ成功！',
        message: result.message,
        itemId: result.newItemId,
      );
    } else {
      debugPrint('❌ Combination failed or not available');
    }

    return result;
  }

  /// ギミック発動を試行
  bool tryGimmickActivation({
    required String ruleId,
    required List<String> availableItems,
  }) {
    debugPrint('⚙️ Trying gimmick activation: $ruleId with $availableItems');

    final result = _itemCombinationManager.attemptGimmickActivation(
      ruleId,
      availableItems,
    );

    return result.success;
  }

  /// 利用可能な組み合わせを取得
  List<CombinationRule> getAvailableCombinations({
    required List<String> availableItems,
  }) {
    return _itemCombinationManager.getAvailableCombinations(availableItems);
  }

  /// 利用可能なギミックを取得
  List<GimmickRule> getAvailableGimmicks({
    required List<String> availableItems,
  }) {
    return _itemCombinationManager.getAvailableGimmicks(availableItems);
  }

  /// 現在のインベントリ状態を取得
  List<String> get currentInventory => _inventoryManager.items;

  /// インベントリの残り容量を取得
  int get remainingInventorySpace =>
      _inventoryManager.maxItems - _inventoryManager.items.length;
}
