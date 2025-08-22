// UI System Integration File - Re-exports for backward compatibility
// This file maintains backward compatibility while providing modular UI components

// Core UI System Exports
export 'ui_layer_priority.dart';
export 'ui_layout_manager.dart';
export 'ui_component_base.dart';

// UI Component Exports
export 'text_ui_component.dart';
export 'button_ui_component.dart';
export 'settings_menu_component.dart';
export 'progress_bar_component.dart';

// Legacy support - Inventory UI Layer Priority for backward compatibility
import 'ui_layer_priority.dart';

/// インベントリUI階層の優先度定義
class InventoryUILayerPriority extends UILayerPriority {
  static const int inventoryBackground = UILayerPriority.ui + 10; // 210
  static const int inventoryItems = UILayerPriority.ui + 20; // 220
  static const int selectedItem = UILayerPriority.ui + 30; // 230
  static const int itemTooltip = UILayerPriority.tooltip; // 500
}
