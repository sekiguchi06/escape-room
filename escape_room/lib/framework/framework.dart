// Core exports (存在するもののみ)
export 'core/configurable_game.dart';

// State management (存在するもののみ)
export 'state/game_state_system.dart';

// Timer system (存在するもののみ)
export 'timer/flame_timer_system.dart';

// Game types quick templates (存在するもののみ)
// match3_template.dart moved to match3_game project

// Components (存在するもののみ)
export 'components/inventory_manager.dart';
export 'components/interaction_manager.dart';

// Escape Room新アーキテクチャ
export 'escape_room/core/escape_room_game.dart';
export 'escape_room/gameobjects/interactable_game_object.dart';
export 'escape_room/gameobjects/bookshelf_object.dart';
export 'escape_room/gameobjects/safe_object.dart';
export 'escape_room/gameobjects/box_object.dart';

// UI System (新規インベントリシステム + モーダルシステム)
export 'ui/ui_system.dart';
export 'ui/mobile_layout_system.dart';
export 'ui/escape_room_modal_system.dart';
export 'ui/modal_config.dart';
export 'ui/modal_display_strategy.dart';
// export 'ui/modal_ui_builder.dart'; // ModalUIElements重複のため無効化
export 'ui/modal_manager.dart';
export 'ui/number_puzzle_input_component.dart';
export 'ui/inventory_ui_component.dart';
export 'ui/inventory_item_component.dart';
export 'ui/inventory_state_notifier.dart';
export 'ui/responsive_layout_calculator.dart';
export 'ui/mobile_portrait_layout.dart';
export 'ui/japanese_message_system.dart';
// Commented out due to ModalType conflict
// export 'ui/escape_room_ui_components.dart';

// Performance Optimization (パフォーマンス最適化)
export 'ui/navigation_utils.dart';
export 'ui/key_optimization.dart';
export 'ui/state_optimization.dart';
export 'ui/const_optimization.dart';
