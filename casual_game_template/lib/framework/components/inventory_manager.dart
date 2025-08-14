import 'package:flutter/foundation.dart';

/// ゲームアイテム情報
class GameItem {
  final String id;
  final String name;
  final String description;
  final bool canUse;
  final bool canCombine;
  
  const GameItem({
    required this.id,
    required this.name,
    required this.description,
    this.canUse = true,
    this.canCombine = false,
  });
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GameItem && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
}

/// インベントリマネージャー
/// 他のゲームテンプレートと同様のパターンで実装
class InventoryManager {
  final int maxItems;
  final Function(String) onItemSelected;
  final List<String> _items = [];
  
  InventoryManager({
    required this.maxItems,
    required this.onItemSelected,
  });
  
  /// 現在のアイテムリスト（読み取り専用）
  List<String> get items => List.unmodifiable(_items);
  
  /// アイテム所持チェック
  bool hasItem(String itemId) => _items.contains(itemId);
  
  /// アイテム追加
  bool addItem(String itemId) {
    if (_items.length >= maxItems || _items.contains(itemId)) {
      debugPrint('🎒 Cannot add item: $itemId (max: $maxItems, current: ${_items.length})');
      return false;
    }
    
    _items.add(itemId);
    debugPrint('🎒 Item added: $itemId');
    return true;
  }
  
  /// アイテム削除
  bool removeItem(String itemId) {
    final removed = _items.remove(itemId);
    if (removed) {
      debugPrint('🎒 Item removed: $itemId');
    }
    return removed;
  }
  
  /// インベントリクリア
  void clear() {
    _items.clear();
    debugPrint('🎒 Inventory cleared');
  }
  
  /// アイテム選択
  void selectItem(String itemId) {
    if (hasItem(itemId)) {
      onItemSelected(itemId);
      debugPrint('🎒 Item selected: $itemId');
    }
  }
  
  /// インベントリ使用率
  double get usageRate => _items.length / maxItems;
  
  /// インベントリが満杯かチェック
  bool get isFull => _items.length >= maxItems;
  
  /// インベントリが空かチェック
  bool get isEmpty => _items.isEmpty;
}