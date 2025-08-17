import 'package:flutter/material.dart';

/// インベントリシステムの状態管理
class InventorySystem extends ChangeNotifier {
  static final InventorySystem _instance = InventorySystem._internal();
  factory InventorySystem() => _instance;
  InventorySystem._internal();

  // インベントリ状態（5個のスロット、null = 空）
  final List<String?> _inventory = List.filled(5, null);
  int? _selectedSlotIndex; // 選択中のスロット（null = 未選択）
  
  // 取得済みアイテムのID管理（ホットスポットID + アイテムIDの組み合わせ）
  final Set<String> _acquiredItems = {};

  /// インベントリの状態取得
  List<String?> get inventory => List.from(_inventory);
  int? get selectedSlotIndex => _selectedSlotIndex;

  /// アイテムをインベントリに追加（左詰めで配置）
  bool addItem(String itemId) {
    final emptyIndex = _inventory.indexWhere((item) => item == null);
    if (emptyIndex != -1) {
      _inventory[emptyIndex] = itemId;
      notifyListeners();
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

  /// スロットを選択
  void selectSlot(int? index) {
    _selectedSlotIndex = index;
    notifyListeners();
    debugPrint('🎯 Selected slot: $index (item: ${getItem(index ?? -1)})');
  }

  /// アイテムを削除（インデックス指定）
  bool removeItem(int index) {
    if (index >= 0 && index < _inventory.length && _inventory[index] != null) {
      final removedItem = _inventory[index];
      _inventory[index] = null;
      // 選択中のスロットがクリアされた場合は選択を解除
      if (_selectedSlotIndex == index) {
        _selectedSlotIndex = null;
      }
      notifyListeners();
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

  /// ゲームリスタート時：インベントリを完全にクリア
  void resetToInitialState() {
    _inventory.fillRange(0, _inventory.length, null);
    _selectedSlotIndex = null;
    _acquiredItems.clear(); // 取得済みアイテムもクリア
    notifyListeners();
    debugPrint('🔄 ゲームリスタート: インベントリと取得履歴をクリア');
  }

  /// ゲーム開始時の初期化（空の状態で開始）
  void initializeEmpty() {
    // 既存のアイテムをクリア
    resetToInitialState();
    debugPrint('🎮 ゲーム開始: インベントリは空の状態でスタート');
  }

  /// アイテム組み合わせ関連機能

  /// 現在選択中のアイテムIDを取得
  String? get selectedItemId {
    if (_selectedSlotIndex == null) return null;
    return _inventory[_selectedSlotIndex!];
  }

  /// 組み合わせ可能なアイテムかチェック
  bool canCombineItems(String item1, String item2) {
    // coin + key = master_key の組み合わせのみ対応
    final items = {item1, item2};
    return items.contains('coin') && items.contains('key');
  }

  /// 2つのアイテムが組み合わせ可能かチェック
  bool canCombineSelectedItems() {
    final selectedItem = selectedItemId;
    if (selectedItem == null) return false;
    
    // 他のアイテムと組み合わせ可能かチェック
    for (final item in _inventory) {
      if (item != null && item != selectedItem) {
        if (canCombineItems(selectedItem, item)) {
          return true;
        }
      }
    }
    return false;
  }

  /// 指定したアイテムが現在選択中のアイテムと組み合わせ可能かチェック
  bool canCombineWithSelected(String itemId) {
    final selectedItem = selectedItemId;
    if (selectedItem == null || selectedItem == itemId) return false;
    return canCombineItems(selectedItem, itemId);
  }

  /// アイテム組み合わせ実行
  bool combineItemWithSelected(String targetItemId) {
    final selectedItem = selectedItemId;
    if (selectedItem == null) return false;
    
    if (!canCombineItems(selectedItem, targetItemId)) {
      return false;
    }
    
    // coin + key → master_key
    if ((selectedItem == 'coin' && targetItemId == 'key') || 
        (selectedItem == 'key' && targetItemId == 'coin')) {
      
      // 元のアイテムを削除
      removeItemById(selectedItem);
      removeItemById(targetItemId);
      
      // 新しいアイテムを追加
      addItem('master_key');
      
      // 選択を解除
      _selectedSlotIndex = null;
      
      debugPrint('🔧 Item combination: $selectedItem + $targetItemId → master_key');
      return true;
    }
    
    return false;
  }
}