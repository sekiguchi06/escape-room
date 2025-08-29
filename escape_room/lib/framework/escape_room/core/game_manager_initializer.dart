import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../components/inventory_manager.dart';
import '../state/escape_room_state_riverpod.dart';
import 'escape_room_game_controller.dart';
import 'escape_room_ui_manager.dart';
import 'clear_condition_manager.dart';
import 'item_combination_manager.dart';
import '../../effects/particle_system.dart';

/// EscapeRoomGameの各種マネージャー初期化責務分離クラス
class GameManagerInitializer {
  late ProviderContainer _container;
  late EscapeRoomStateNotifier _stateNotifier;
  late InventoryManager _inventoryManager;
  late EscapeRoomGameController _controller;
  late EscapeRoomUIManager _uiManager;
  late ClearConditionManager _clearConditionManager;
  late ItemCombinationManager _itemCombinationManager;
  late ParticleEffectManager _particleEffectManager;

  // Getters
  ProviderContainer get container => _container;
  EscapeRoomStateNotifier get stateNotifier => _stateNotifier;
  InventoryManager get inventoryManager => _inventoryManager;
  EscapeRoomGameController get controller => _controller;
  EscapeRoomUIManager get uiManager => _uiManager;
  ClearConditionManager get clearConditionManager => _clearConditionManager;
  ItemCombinationManager get itemCombinationManager => _itemCombinationManager;
  ParticleEffectManager get particleEffectManager => _particleEffectManager;

  /// 全マネージャーを初期化
  Future<void> initializeAllManagers({
    required FlameGame gameComponent,
    ProviderContainer? providerContainer,
  }) async {
    // ProviderContainerを初期化
    _container = providerContainer ?? ProviderContainer();

    // パーティクルエフェクトマネージャーを初期化
    _particleEffectManager = ParticleEffectManager();
    gameComponent.add(_particleEffectManager);

    await _initializeStateManagement();
    await _initializeInventoryManager();
    await _initializeGameController();
    await _initializeUIManager(gameComponent);
    await _initializeClearConditionManager();
    await _initializeItemCombinationManager();
    
    _setupManagerConnections();
  }

  /// Riverpod状態管理初期化
  Future<void> _initializeStateManagement() async {
    _stateNotifier = _container.read(escapeRoomStateProvider.notifier);
    debugPrint('✅ State management initialized');
  }

  /// インベントリマネージャー初期化
  Future<void> _initializeInventoryManager() async {
    _inventoryManager = InventoryManager(
      maxItems: 5,
      onItemSelected: (itemId) {
        _stateNotifier.selectItem(itemId);
        debugPrint('🎒 Selected item: $itemId');
      },
    );
    debugPrint('✅ Inventory manager initialized');
  }

  /// ゲームコントローラー初期化
  Future<void> _initializeGameController() async {
    _controller = EscapeRoomGameController(inventoryManager: _inventoryManager);
    debugPrint('✅ Game controller initialized');
  }

  /// UIマネージャー初期化
  Future<void> _initializeUIManager(FlameGame gameComponent) async {
    _uiManager = EscapeRoomUIManager(
      inventoryManager: _inventoryManager,
      gameComponent: gameComponent,
    );
    debugPrint('✅ UI manager initialized');
  }

  /// クリア条件管理システム初期化
  Future<void> _initializeClearConditionManager() async {
    _clearConditionManager = ClearConditionManager();
    _setupDefaultClearConditions();
    debugPrint('✅ Clear condition manager initialized');
  }

  /// アイテム組み合わせ管理システム初期化
  Future<void> _initializeItemCombinationManager() async {
    _itemCombinationManager = ItemCombinationManager();
    _setupDefaultCombinationRules();
    debugPrint('✅ Item combination manager initialized');
  }

  /// マネージャー間の連携設定
  void _setupManagerConnections() {
    // TODO: マネージャー間の連携設定は後で実装
    // 現在のAPIでは直接的な連携設定はサポートされていない
    
    debugPrint('✅ Manager connections setup skipped (API limitations)');
  }

  /// デフォルトクリア条件設定
  void _setupDefaultClearConditions() {
    // TODO: クリア条件の設定はAPIの整合性が取れ次第実装
    debugPrint('✅ Clear conditions setup skipped (API compatibility)');
  }

  /// デフォルト組み合わせルール設定
  void _setupDefaultCombinationRules() {
    // TODO: 組み合わせルールの設定はAPIの整合性が取れ次第実装
    debugPrint('✅ Combination rules setup skipped (API compatibility)');
  }

  /// リソース解放
  void dispose() {
    _container.dispose();
    debugPrint('🗑️ Game managers disposed');
  }
}