import 'package:flutter/material.dart';

/// インベントリのアイテム管理機能
class InventoryItemManager {
  final List<String?> _inventory;
  final Set<String> _acquiredItems;
  final VoidCallback _notifyListeners;

  InventoryItemManager(
    this._inventory,
    this._acquiredItems,
    this._notifyListeners,
  );

  /// アイテムをインベントリに追加（左詰めで配置）
  bool addItem(String itemId) {
    final emptyIndex = _inventory.indexWhere((item) => item == null);
    if (emptyIndex != -1) {
      _inventory[emptyIndex] = itemId;
      _notifyListeners();
      debugPrint('🎒 Added item: $itemId to slot $emptyIndex');
      return true;
    } else {
      debugPrint('🎒 Inventory full, cannot add: $itemId');
      return false;
    }
  }

  /// ホットスポットからアイテムを取得（重複取得防止付き）
  bool acquireItemFromHotspot(String hotspotId, String itemId) {
    final acquisitionKey = '${hotspotId}_$itemId';

    // 既に取得済みかチェック
    if (_acquiredItems.contains(acquisitionKey)) {
      debugPrint('🚫 Already acquired: $itemId from $hotspotId');
      return false;
    }

    // インベントリに追加を試行
    final success = addItem(itemId);
    if (success) {
      // 取得成功時は取得済みとしてマーク
      _acquiredItems.add(acquisitionKey);
      debugPrint('✅ First-time acquisition: $itemId from $hotspotId');
    }

    return success;
  }

  /// 特定のホットスポットからのアイテムが取得済みかチェック
  bool isItemAcquiredFromHotspot(String hotspotId, String itemId) {
    final acquisitionKey = '${hotspotId}_$itemId';
    return _acquiredItems.contains(acquisitionKey);
  }

  /// 指定スロットのアイテムを取得
  String? getItem(int index) {
    if (index >= 0 && index < _inventory.length) {
      return _inventory[index];
    }
    return null;
  }

  /// アイテムを削除（インデックス指定）
  bool removeItem(int index) {
    if (index >= 0 && index < _inventory.length && _inventory[index] != null) {
      final removedItem = _inventory[index];
      _inventory[index] = null;
      _notifyListeners();
      debugPrint('🗑️ Removed item: $removedItem from slot $index');
      return true;
    }
    return false;
  }

  /// アイテムを削除（アイテムID指定）
  bool removeItemById(String itemId) {
    final index = _inventory.indexOf(itemId);
    if (index != -1) {
      return removeItem(index);
    }
    return false;
  }
}