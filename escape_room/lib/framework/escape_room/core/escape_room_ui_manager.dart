import 'package:flame/components.dart';
import '../../ui/inventory_ui_component.dart';
import '../../components/inventory_manager.dart';

/// Escape Room UI Manager - UI制御専任
/// レイヤー分離原則に基づく設計
class EscapeRoomUIManager {
  InventoryUIComponent? _inventoryUI;
  final InventoryManager inventoryManager;
  final Component gameComponent;

  EscapeRoomUIManager({
    required this.inventoryManager,
    required this.gameComponent,
  });

  /// インベントリUIを初期化
  Future<void> initializeInventoryUI(Vector2 screenSize) async {
    _inventoryUI = InventoryUIComponent(
      manager: inventoryManager,
      screenSize: screenSize,
    );

    gameComponent.add(_inventoryUI!);
  }

  /// インベントリUIを更新
  void refreshInventoryUI() {
    _inventoryUI?.refreshUI();
  }

  /// 画面サイズ変更時の処理
  void onScreenResize(Vector2 newSize) {
    if (_inventoryUI != null &&
        gameComponent.children.contains(_inventoryUI!)) {
      _inventoryUI!.removeFromParent();
      _inventoryUI = InventoryUIComponent(
        manager: inventoryManager,
        screenSize: newSize,
      );
      gameComponent.add(_inventoryUI!);
    }
  }

  /// UIコンポーネントのクリーンアップ
  void dispose() {
    if (_inventoryUI != null &&
        gameComponent.children.contains(_inventoryUI!)) {
      _inventoryUI!.removeFromParent();
    }
    _inventoryUI = null;
  }

  /// インベントリUI取得（読み取り専用）
  InventoryUIComponent? get inventoryUI => _inventoryUI;
}
