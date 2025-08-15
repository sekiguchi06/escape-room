import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// ゲームアイテム情報（画像表示対応）
class GameItem {
  final String id;
  final String name;
  final String description;
  final String imagePath;
  final bool canUse;
  final bool canCombine;
  
  const GameItem({
    required this.id,
    required this.name,
    required this.description,
    this.imagePath = '',
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
/// Observer Patternでの状態変更通知対応
class InventoryManager extends ChangeNotifier {
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
  
  /// アイテム追加（例外処理+ログ出力準拠）
  bool addItem(String itemId) {
    try {
      if (_items.length >= maxItems || _items.contains(itemId)) {
        debugPrint('🎒 Cannot add item: $itemId (max: $maxItems, current: ${_items.length})');
        return false;
      }
      
      _items.add(itemId);
      debugPrint('🎒 Item added: $itemId');
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('🎒 Error adding item $itemId: $e');
      return false;
    }
  }
  
  /// アイテム削除（例外処理+ログ出力準拠）
  bool removeItem(String itemId) {
    try {
      final removed = _items.remove(itemId);
      if (removed) {
        debugPrint('🎒 Item removed: $itemId');
        notifyListeners();
      }
      return removed;
    } catch (e) {
      debugPrint('🎒 Error removing item $itemId: $e');
      return false;
    }
  }
  
  /// インベントリクリア（例外処理+ログ出力準拠）
  void clear() {
    try {
      _items.clear();
      debugPrint('🎒 Inventory cleared');
      notifyListeners();
    } catch (e) {
      debugPrint('🎒 Error clearing inventory: $e');
    }
  }
  
  /// アイテム選択（例外処理+ログ出力準拠）
  void selectItem(String itemId) {
    try {
      if (hasItem(itemId)) {
        onItemSelected(itemId);
        debugPrint('🎒 Item selected: $itemId');
      } else {
        debugPrint('🎒 Item not found for selection: $itemId');
      }
    } catch (e) {
      debugPrint('🎒 Error selecting item $itemId: $e');
    }
  }
  
  /// インベントリ使用率
  double get usageRate => _items.length / maxItems;
  
  /// インベントリが満杯かチェック
  bool get isFull => _items.length >= maxItems;
  
  /// インベントリが空かチェック
  bool get isEmpty => _items.isEmpty;
}

