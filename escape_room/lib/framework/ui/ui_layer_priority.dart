/// UI階層の優先度定義
class UILayerPriority {
  static const int background = 0;
  static const int gameContent = 100;
  static const int ui = 200;
  static const int modal = 300;
  static const int overlay = 400;
  static const int tooltip = 500;
}

/// インベントリUI階層の優先度定義
class InventoryUILayerPriority extends UILayerPriority {
  static const int inventoryBackground = UILayerPriority.ui + 10; // 210
  static const int inventoryItems = UILayerPriority.ui + 20; // 220
  static const int selectedItem = UILayerPriority.ui + 30; // 230
  static const int itemTooltip = UILayerPriority.tooltip; // 500
}

/// ゲームUI階層の優先度定義
class GameUILayerPriority extends UILayerPriority {
  static const int hud = UILayerPriority.ui + 5; // 205
  static const int menu = UILayerPriority.ui + 15; // 215
  static const int dialog = UILayerPriority.modal + 10; // 310
  static const int notification = UILayerPriority.overlay + 10; // 410
}

/// エスケープルームUI階層の優先度定義
class EscapeRoomUILayerPriority extends UILayerPriority {
  static const int roomBackground = UILayerPriority.background + 10; // 10
  static const int roomObjects = UILayerPriority.gameContent + 10; // 110
  static const int interactableHighlight = UILayerPriority.ui + 5; // 205
  static const int puzzleOverlay = UILayerPriority.modal + 5; // 305
  static const int hintTooltip = UILayerPriority.tooltip + 10; // 510
}
