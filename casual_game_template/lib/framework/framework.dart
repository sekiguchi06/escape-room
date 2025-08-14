/// Framework root export file
library framework;

// Core exports (存在するもののみ)
export 'core/configurable_game.dart';

// State management (存在するもののみ)
export 'state/game_state_system.dart';

// Timer system (存在するもののみ)
export 'timer/flame_timer_system.dart';

// Game types quick templates (存在するもののみ)
export 'game_types/quick_templates/match3_template.dart';
export 'game_types/quick_templates/endless_runner_template.dart';
export 'game_types/quick_templates/tap_shooter_template.dart';

// Components (存在するもののみ)
export 'components/inventory_manager.dart';
export 'components/interaction_manager.dart';
export 'components/interactive_hotspot.dart';

// Escape Room新アーキテクチャ
export 'escape_room/core/escape_room_game.dart';
export 'escape_room/gameobjects/interactable_game_object.dart';
export 'escape_room/gameobjects/bookshelf_object.dart';
export 'escape_room/gameobjects/safe_object.dart';
export 'escape_room/gameobjects/box_object.dart';