import 'package:flutter/material.dart';
import 'inventory_item_manager.dart';

/// インベントリのアイテム組み合わせ機能
class InventoryCombinationSystem {
  final List<String?> _inventory;
  final InventoryItemManager _itemManager;

  InventoryCombinationSystem(this._inventory, this._itemManager);

  /// 組み合わせ可能なアイテムかチェック
  bool canCombineItems(String item1, String item2) {
    final items = {item1, item2};
    
    // 既存の組み合わせ
    if (items.contains('coin') && items.contains('key')) {
      return true;
    }
    
    // 地下3個アイテム組み合わせ（2個ずつのチェック）
    final undergroundItems = {'dark_crystal', 'ritual_stone', 'pure_water'};
    if (undergroundItems.contains(item1) && undergroundItems.contains(item2)) {
      return true;
    }
    
    return false;
  }

  /// 2つのアイテムが組み合わせ可能かチェック
  bool canCombineSelectedItems(String? selectedItemId) {
    if (selectedItemId == null) return false;

    // 他のアイテムと組み合わせ可能かチェック
    for (final item in _inventory) {
      if (item != null && item != selectedItemId) {
        if (canCombineItems(selectedItemId, item)) {
          return true;
        }
      }
    }
    return false;
  }

  /// 指定したアイテムが現在選択中のアイテムと組み合わせ可能かチェック
  bool canCombineWithSelected(String? selectedItemId, String itemId) {
    if (selectedItemId == null || selectedItemId == itemId) return false;
    return canCombineItems(selectedItemId, itemId);
  }

  /// アイテム組み合わせ実行
  bool combineItemWithSelected(String? selectedItem, String targetItemId) {
    if (selectedItem == null) return false;

    if (!canCombineItems(selectedItem, targetItemId)) {
      return false;
    }

    // coin + key → master_key
    if ((selectedItem == 'coin' && targetItemId == 'key') ||
        (selectedItem == 'key' && targetItemId == 'coin')) {
      // 元のアイテムを削除
      _itemManager.removeItemById(selectedItem);
      _itemManager.removeItemById(targetItemId);

      // 新しいアイテムを追加
      _itemManager.addItem('master_key');

      debugPrint(
        '🔧 Item combination: $selectedItem + $targetItemId → master_key',
      );
      return true;
    }

    // 地下3個アイテム組み合わせチェック
    final undergroundItems = {'dark_crystal', 'ritual_stone', 'pure_water'};
    if (undergroundItems.contains(selectedItem) && undergroundItems.contains(targetItemId)) {
      // 3個すべて持っているかチェック
      if (hasAllUndergroundMasterKeyItems()) {
        // 元の3個のアイテムを削除
        _itemManager.removeItemById('dark_crystal');
        _itemManager.removeItemById('ritual_stone'); 
        _itemManager.removeItemById('pure_water');

        // 結果アイテムを追加
        _itemManager.addItem('underground_master_key');

        debugPrint('🔧 Underground combination: dark_crystal + ritual_stone + pure_water → underground_master_key');

        return true;
      } else {
        debugPrint('⚠️ 地下マスターキー作成には3つすべてのアイテムが必要です');
        return false;
      }
    }

    return false;
  }
  
  /// 地下マスターキー作成に必要な3個のアイテムをすべて持っているかチェック
  bool hasAllUndergroundMasterKeyItems() {
    return _inventory.contains('dark_crystal') &&
           _inventory.contains('ritual_stone') &&
           _inventory.contains('pure_water');
  }
}