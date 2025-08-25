import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../components/inventory_manager.dart';
import '../state/escape_room_state_riverpod.dart';
import 'escape_room_game_controller.dart';
import 'escape_room_ui_manager.dart';
import 'clear_condition_manager.dart';
import 'item_combination_manager.dart';
import '../../effects/particle_system.dart';

/// ゲーム初期化サービス
/// EscapeRoomGameの初期化ロジックを担当
class GameInitializationService {
  bool _isInitialized = false;

  /// 初期化状態確認
  bool get isInitialized => _isInitialized;

  /// コントローラーとマネージャーを初期化
  Future<GameInitializationResult> initializeControllers({
    required ProviderContainer container,
    required dynamic gameComponent,
  }) async {
    try {
      // Riverpod状態管理を初期化
      final stateNotifier = container.read(escapeRoomStateProvider.notifier);

      // インベントリマネージャーを初期化
      final inventoryManager = InventoryManager(
        maxItems: 5,
        onItemSelected: (itemId) {
          stateNotifier.selectItem(itemId);
          debugPrint('🎒 Selected item: $itemId');
        },
      );

      // ゲームコントローラーを初期化
      final controller = EscapeRoomGameController(
        inventoryManager: inventoryManager,
      );

      // UIマネージャーを初期化
      final uiManager = EscapeRoomUIManager(
        inventoryManager: inventoryManager,
        gameComponent: gameComponent,
      );

      // クリア条件管理システムを初期化
      final clearConditionManager = ClearConditionManager();
      _setupDefaultClearConditions(clearConditionManager);

      // アイテム組み合わせ管理システムを初期化
      final itemCombinationManager = ItemCombinationManager();
      _setupDefaultCombinationRules(itemCombinationManager);

      // パーティクルエフェクトマネージャーを初期化
      final particleEffectManager = ParticleEffectManager();

      _isInitialized = true;

      return GameInitializationResult.success(
        stateNotifier: stateNotifier,
        inventoryManager: inventoryManager,
        controller: controller,
        uiManager: uiManager,
        clearConditionManager: clearConditionManager,
        itemCombinationManager: itemCombinationManager,
        particleEffectManager: particleEffectManager,
      );
    } catch (e) {
      debugPrint('❌ Game initialization failed: $e');
      return GameInitializationResult.failure(error: e.toString());
    }
  }

  /// デフォルトクリア条件の設定
  void _setupDefaultClearConditions(ClearConditionManager manager) {
    // アイテム収集条件（現在のゲームの実際のアイテム）
    manager.addCondition(
      const ClearCondition(
        id: 'collect_basic_items',
        type: ClearConditionType.collectItems,
        description: '基本アイテムを収集する',
        data: {
          'requiredItems': ['coin', 'key'], // 実際に取得可能なアイテム
        },
      ),
    );

    // ホットスポット探索条件
    manager.addCondition(
      const ClearCondition(
        id: 'explore_key_hotspots',
        type: ClearConditionType.interactObjects,
        description: '重要なホットスポットを探索する',
        data: {
          'requiredInteractions': ['treasure_chest', 'entrance_door'],
        },
      ),
    );

    // アイテム組み合わせ条件
    manager.addCondition(
      const ClearCondition(
        id: 'use_master_key',
        type: ClearConditionType.useItemCombination,
        description: 'マスターキーを使用する',
        data: {
          'requiredCombinations': ['master_key_treasure_chest'],
        },
      ),
    );
  }

  /// デフォルト組み合わせルールの設定
  void _setupDefaultCombinationRules(ItemCombinationManager manager) {
    // マスターキー + 宝箱 = 脱出の鍵
    manager.addCombinationRule(
      const CombinationRule(
        id: 'master_key_treasure_chest',
        requiredItems: ['master_key'],
        resultItem: 'escape_key',
        description: 'マスターキーで宝箱を開けて脱出の鍵を取得',
        consumeItems: true,
      ),
    );

    // 脱出の鍵 + 入り口の扉 = ゲームクリア
    manager.addGimmickRule(
      const GimmickRule(
        id: 'escape_key_entrance_door',
        targetObjectId: 'entrance_door',
        requiredItems: ['escape_key'],
        description: '脱出の鍵で扉を開けてゲームクリア',
        successMessage: 'おめでとうございます！脱出成功です！',
        failureMessage: '扉が開きません。必要なアイテムがありません。',
        consumeItems: true,
      ),
    );
  }
}

/// 初期化結果クラス
class GameInitializationResult {
  final bool success;
  final String? error;
  final EscapeRoomStateNotifier? stateNotifier;
  final InventoryManager? inventoryManager;
  final EscapeRoomGameController? controller;
  final EscapeRoomUIManager? uiManager;
  final ClearConditionManager? clearConditionManager;
  final ItemCombinationManager? itemCombinationManager;
  final ParticleEffectManager? particleEffectManager;

  GameInitializationResult.success({
    required this.stateNotifier,
    required this.inventoryManager,
    required this.controller,
    required this.uiManager,
    required this.clearConditionManager,
    required this.itemCombinationManager,
    required this.particleEffectManager,
  }) : success = true,
       error = null;

  GameInitializationResult.failure({required this.error})
    : success = false,
      stateNotifier = null,
      inventoryManager = null,
      controller = null,
      uiManager = null,
      clearConditionManager = null,
      itemCombinationManager = null,
      particleEffectManager = null;
}
