import '../components/inventory_manager.dart';
import 'inventory_state_notifier.dart';

/// インベントリイベント処理専用クラス
/// イベント処理専任での責任分離
class InventoryEventHandler {
  final InventoryManager manager;
  final InventoryStateNotifier stateNotifier;
  final Function() onUIRefresh;

  InventoryEventHandler({
    required this.manager,
    required this.stateNotifier,
    required this.onUIRefresh,
  });

  /// アイテムタップ処理
  void onItemTapped(String itemId) {
    stateNotifier.selectItem(itemId);
    _updateItemStates();
  }

  /// 左矢印ボタン押下
  void onLeftArrowPressed() {
    // TODO: エリアナビゲーション機能で実装
  }

  /// 右矢印ボタン押下
  void onRightArrowPressed() {
    // TODO: エリアナビゲーション機能で実装
  }

  /// アイテム選択処理
  void selectItem(String itemId) {
    stateNotifier.selectItem(itemId);
    _updateItemStates();
  }

  /// アイテム追加処理
  bool addItem(String itemId) {
    final added = stateNotifier.addItem(itemId);
    if (added) {
      onUIRefresh();
    }
    return added;
  }

  /// アイテム削除処理
  bool removeItem(String itemId) {
    final removed = stateNotifier.removeItem(itemId);
    if (removed) {
      onUIRefresh();
    }
    return removed;
  }

  /// アイテム状態更新処理
  void _updateItemStates() {
    // UI更新は親コンポーネントで実行
    onUIRefresh();
  }

  /// 選択中のアイテムID取得
  String? get selectedItemId => stateNotifier.selectedItemId;
}