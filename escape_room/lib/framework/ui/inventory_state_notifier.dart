import 'package:flutter/foundation.dart';
import '../components/inventory_manager.dart';

/// インベントリ状態通知機
/// Flutter状態管理原則準拠のインベントリ状態管理
class InventoryStateNotifier extends ChangeNotifier {
  String? _selectedItemId;
  final InventoryManager _manager;

  InventoryStateNotifier({required InventoryManager manager})
    : _manager = manager;

  /// 現在選択中のアイテムID
  String? get selectedItemId => _selectedItemId;

  /// 現在のアイテムリスト
  List<String> get items => _manager.items;

  /// インベントリが満杯かどうか
  bool get isFull => _manager.isFull;

  /// インベントリが空かどうか
  bool get isEmpty => _manager.isEmpty;

  /// 使用率
  double get usageRate => _manager.usageRate;

  /// アイテム選択
  void selectItem(String itemId) {
    if (_manager.hasItem(itemId)) {
      _selectedItemId = itemId;
      _manager.selectItem(itemId);
      notifyListeners();
      debugPrint('🎒 Item selected via notifier: $itemId');
    }
  }

  /// アイテム追加
  bool addItem(String itemId) {
    final added = _manager.addItem(itemId);
    if (added) {
      notifyListeners();
      debugPrint('🎒 Item added via notifier: $itemId');
    }
    return added;
  }

  /// アイテム削除
  bool removeItem(String itemId) {
    final removed = _manager.removeItem(itemId);
    if (removed) {
      // 削除したアイテムが選択中だった場合は選択を解除
      if (_selectedItemId == itemId) {
        _selectedItemId = null;
      }
      notifyListeners();
      debugPrint('🎒 Item removed via notifier: $itemId');
    }
    return removed;
  }

  /// インベントリクリア
  void clearInventory() {
    _manager.clear();
    _selectedItemId = null;
    notifyListeners();
    debugPrint('🎒 Inventory cleared via notifier');
  }

  /// 選択解除
  void clearSelection() {
    _selectedItemId = null;
    notifyListeners();
    debugPrint('🎒 Selection cleared');
  }

  /// アイテム所持チェック
  bool hasItem(String itemId) => _manager.hasItem(itemId);

  /// 状態リセット
  void reset() {
    clearInventory();
    debugPrint('🎒 Inventory state reset');
  }
}
