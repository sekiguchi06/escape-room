import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../gameobjects/interactable_game_object.dart';
import '../../components/inventory_manager.dart';
import '../../ui/mobile_portrait_layout.dart';
import '../../ui/escape_room_modal_system.dart';
import '../../ui/modal_config.dart';
import '../../ui/japanese_message_system.dart';
import '../state/escape_room_state_riverpod.dart';
import 'escape_room_game_controller.dart';
import 'escape_room_ui_manager.dart';
import 'clear_condition_manager.dart';
import 'item_combination_manager.dart';
import '../../effects/particle_system.dart';
import '../../../game/components/inventory_system.dart';
import '../../../game/components/room_hotspot_system.dart';

/// Escape Room Game - 新アーキテクチャ版
/// レイヤー分離原則に基づく設計
class EscapeRoomGame extends FlameGame with TapCallbacks {
  late EscapeRoomGameController _controller;
  late EscapeRoomUIManager _uiManager;
  late InventoryManager _inventoryManager;
  late EscapeRoomStateNotifier _stateNotifier;
  late PortraitLayoutComponent _layoutComponent;
  late ProviderContainer _container;
  late ParticleEffectManager _particleEffectManager;
  late ClearConditionManager _clearConditionManager;
  late ItemCombinationManager _itemCombinationManager;
  bool _isInitialized = false;

  // Controllers for layer separation
  EscapeRoomGameController get controller => _controller;
  EscapeRoomUIManager get uiManager => _uiManager;
  PortraitLayoutComponent get layoutComponent => _layoutComponent;
  EscapeRoomStateNotifier get stateNotifier => _stateNotifier;
  ParticleEffectManager get particleEffectManager => _particleEffectManager;
  ClearConditionManager get clearConditionManager => _clearConditionManager;
  ItemCombinationManager get itemCombinationManager => _itemCombinationManager;

  /// Riverpod用のProviderContainerを設定
  void setProviderContainer(ProviderContainer container) {
    _container = container;
  }

  @override
  Color backgroundColor() => const Color(0x00000000); // 背景を透明にして外部画像を表示

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // ProviderContainerを初期化
    _container = ProviderContainer();

    // パーティクルエフェクトマネージャーを初期化・追加
    _particleEffectManager = ParticleEffectManager();
    add(_particleEffectManager);

    await _initializeControllers();
    await _createPortraitLayout();
    await _createUI();
    await _spawnGameObjects();
  }

  /// コントローラーとマネージャーを初期化
  Future<void> _initializeControllers() async {
    // Riverpod状態管理を初期化
    _stateNotifier = _container.read(escapeRoomStateProvider.notifier);

    // インベントリマネージャーを初期化
    _inventoryManager = InventoryManager(
      maxItems: 5,
      onItemSelected: (itemId) {
        _stateNotifier.selectItem(itemId);
        debugPrint('🎒 Selected item: $itemId');
      },
    );

    // ゲームコントローラーを初期化
    _controller = EscapeRoomGameController(inventoryManager: _inventoryManager);

    // UIマネージャーを初期化
    _uiManager = EscapeRoomUIManager(
      inventoryManager: _inventoryManager,
      gameComponent: this,
    );

    // クリア条件管理システムを初期化
    _clearConditionManager = ClearConditionManager();
    _setupDefaultClearConditions();

    // アイテム組み合わせ管理システムを初期化
    _itemCombinationManager = ItemCombinationManager();
    _setupDefaultCombinationRules();

    // インベントリとクリア条件の連携設定
    _inventoryManager.addListener(_checkClearConditions);

    // InventorySystemとRoomHotspotSystemの変更を監視
    _setupGameSystemListeners();

    // インベントリUIを初期化（外部レイアウトで管理するため無効化）
    // await _uiManager.initializeInventoryUI(size);

    // 状態遷移テスト実行（開発用のため無効化）
    // _testStateTransitions();

    _isInitialized = true;
  }

  /// デフォルトクリア条件の設定
  void _setupDefaultClearConditions() {
    // アイテム収集条件（現在のゲームの実際のアイテム）
    _clearConditionManager.addCondition(
      ClearCondition(
        id: 'collect_basic_items',
        type: ClearConditionType.collectItems,
        description: '基本アイテムを収集する',
        data: {
          'requiredItems': ['coin', 'key'], // 実際に取得可能なアイテム
        },
      ),
    );

    // ホットスポット探索条件
    _clearConditionManager.addCondition(
      ClearCondition(
        id: 'explore_key_hotspots',
        type: ClearConditionType.interactObjects,
        description: '重要なホットスポットを探索する',
        data: {
          'requiredObjects': [
            'prison_bucket', // coin取得
            'library_chair', // key取得
            'treasure_chest', // 最終ギミック
            'entrance_door', // 脱出口
          ],
        },
      ),
    );

    debugPrint('🎯 Escape room clear conditions setup completed');
  }

  /// デフォルト組み合わせルールの設定
  void _setupDefaultCombinationRules() {
    // アイテム組み合わせルール（現在のゲームに基づく）
    _itemCombinationManager.addCombinationRules([
      CombinationRule(
        id: 'coin_key_combination',
        requiredItems: ['coin', 'key'],
        resultItem: 'master_key',
        description: 'コインと鍵を組み合わせて特別な鍵を作成',
        consumeItems: true,
      ),
    ]);

    // ギミック解除ルール（現在のホットスポットに基づく）
    _itemCombinationManager.addGimmickRules([
      GimmickRule(
        id: 'treasure_chest_unlock',
        targetObjectId: 'treasure_chest',
        requiredItems: ['master_key'],
        description: '特別な鍵で宝箱を開ける',
        successMessage: '宝箱が開いた！最終的な脱出の鍵を発見！',
        failureMessage: 'この宝箱には特別な鍵が必要だ',
        consumeItems: false,
      ),
      GimmickRule(
        id: 'entrance_door_unlock',
        targetObjectId: 'entrance_door',
        requiredItems: ['escape_key'],
        description: '脱出の鍵で扉を開ける',
        successMessage: '重厚な扉が開いた！脱出成功！',
        failureMessage: '扉は固く閉ざされている。特別な鍵が必要だ',
        consumeItems: true,
      ),
    ]);

    debugPrint('🔧 Escape room combination rules setup completed');
  }

  /// ゲームシステムの変更監視を設定
  void _setupGameSystemListeners() {
    // InventorySystemの変更を監視
    InventorySystem().addListener(_onGameSystemChanged);

    // RoomHotspotSystemの変更を監視
    RoomHotspotSystem().addListener(_onGameSystemChanged);

    debugPrint('🔧 Game system listeners setup completed');
  }

  /// ゲームシステムの変更時処理
  void _onGameSystemChanged() {
    if (!_isInitialized) return;

    debugPrint('🔄 Game system changed, checking clear conditions...');
    _checkClearConditionsWithGameSystems();
  }

  /// クリア条件チェック
  void _checkClearConditions() {
    final inventoryItems = _inventoryManager.items;
    final interactedObjects = _controller.getInteractedObjects();

    // アイテム収集条件をチェック
    _clearConditionManager.updateItemCollectionProgress(
      'collect_basic_items',
      inventoryItems,
    );

    // オブジェクト操作条件をチェック
    _clearConditionManager.updateObjectInteractionProgress(
      'explore_key_hotspots',
      interactedObjects,
    );

    // ゲームクリア判定
    if (_clearConditionManager.isGameCleared) {
      _triggerGameClear();
    }
  }

  /// ゲームシステムと連携したクリア条件チェック
  void _checkClearConditionsWithGameSystems() {
    // InventorySystemのアイテムを取得
    final inventoryItems = InventorySystem().inventory
        .where((item) => item != null)
        .cast<String>()
        .toList();

    // RoomHotspotSystemの操作履歴を取得
    final interactedHotspots = RoomHotspotSystem().getInteractedHotspots();

    // アイテム収集条件をチェック
    _clearConditionManager.updateItemCollectionProgress(
      'collect_basic_items',
      inventoryItems,
    );

    // ホットスポット探索条件をチェック
    _clearConditionManager.updateObjectInteractionProgress(
      'explore_key_hotspots',
      interactedHotspots,
    );

    // ゲームクリア判定
    if (_clearConditionManager.isGameCleared) {
      _triggerGameClear();
    }

    // デバッグ情報出力
    debugPrint(
      '📊 Clear Progress: ${(_clearConditionManager.clearProgress * 100).toStringAsFixed(1)}%',
    );
    debugPrint('🎒 Items: $inventoryItems');
    debugPrint('🔧 Hotspots: $interactedHotspots');
  }

  /// ゲームクリア処理
  void _triggerGameClear() {
    debugPrint('🎉 Game clear triggered!');

    // クリア画面を表示（overlayは外部から管理）
    overlays.add('gameClearUI');

    // 状態をescapedに変更
    _stateNotifier.escapeSuccess();
  }

  /// 状態遷移テスト実行（ブラウザ確認用）
  void testStateTransitions() {
    debugPrint('🚪 EscapeRoomState Test Starting...');

    // テスト1: exploring → inventory → exploring
    _stateNotifier.showInventory();
    _stateNotifier.hideInventory();

    // テスト2: exploring → puzzle → exploring
    _stateNotifier.startPuzzle('browser_test_puzzle');
    _stateNotifier.completePuzzle();

    // テスト3: exploring → escaped
    _stateNotifier.escapeSuccess();

    debugPrint('🚪 EscapeRoomState Test Completed!');
  }

  Future<void> _spawnGameObjects() async {
    // 新しい部屋別ホットスポットシステムが有効
    // ホットスポット表示は HotspotDisplay ウィジェットが担当

    // Issue #12 対応: パズル機能は entrance_emblem ホットスポットに統合済み
    // CodePadObjectは不要になったため削除

    debugPrint('🎮 Puzzle integrated into hotspot system (entrance_emblem)');

    /* 既存のホットスポットを一時的にコメントアウト
    final bookshelf = BookshelfObject(
      position: Vector2(50, 300),
      size: Vector2(100, 150),
    );
    
    final safe = SafeObject(
      position: Vector2(300, 200),
      size: Vector2(80, 100),
    );
    
    final box = BoxObject(
      position: Vector2(200, 400),
      size: Vector2(120, 80),
    );
    
    // Strategy Patternによるインタラクション設定
    _setupObjectStrategies(bookshelf, safe, box);
    
    // コントローラーに追加
    _controller.addGameObject(bookshelf);
    _controller.addGameObject(safe);
    _controller.addGameObject(box);
    
    // Flameコンポーネントツリーに追加
    add(bookshelf);
    add(safe);
    add(box);
    */
  }

  /// インタラクション結果のモーダル表示
  void showInteractionModal(String objectId, String message) {
    final modalConfig = ModalConfig(
      type: ModalType.item,
      title: JapaneseMessageSystem.getMessage('item_discovery_modal_title'),
      content: message,
      onConfirm: () {
        debugPrint('✅ Modal confirmed for $objectId');
      },
    );

    final modal = ModalComponent(config: modalConfig, size: size);

    add(modal);
    modal.show();
    debugPrint('📱 Modal displayed for $objectId: $message');
  }

  /// 成功メッセージモーダル表示
  void showSuccessModal(String message) {
    final modalConfig = ModalConfig.item(
      title: '🎉 パズル完了!',
      content: message,
      onConfirm: () {
        debugPrint('🎮 Success message acknowledged');
      },
    );

    final modal = ModalComponent(config: modalConfig, size: size);

    add(modal);
    modal.show();
  }

  /// GameObject検索（型による） - コントローラーに委譲
  T? findGameObject<T extends InteractableGameObject>() {
    return _controller.findGameObject<T>();
  }

  /// GameObject検索（複数） - コントローラーに委譲
  List<T> findGameObjects<T extends InteractableGameObject>() {
    return _controller.findGameObjects<T>();
  }

  /// 全オブジェクト状態取得（デバッグ用） - コントローラーに委譲
  Map<String, dynamic> getAllObjectStates() {
    return _controller.getAllObjectStates();
  }

  /// アイテムをインベントリに追加 - コントローラーに委譲
  bool addItemToInventory(String itemId) {
    return _controller.addItemToInventory(itemId);
  }

  /// アイテムをインベントリから削除 - コントローラーに委譲
  bool removeItemFromInventory(String itemId) {
    return _controller.removeItemFromInventory(itemId);
  }

  /// インベントリ内のアイテム確認 - コントローラーに委譲
  bool hasItemInInventory(String itemId) {
    return _controller.hasItemInInventory(itemId);
  }

  /// アイテム組み合わせを試行
  CombinationResult tryItemCombination(String ruleId) {
    final availableItems = _inventoryManager.items;
    final result = _itemCombinationManager.attemptCombination(
      ruleId,
      availableItems,
    );

    if (result.success) {
      // 成功時の処理
      for (final itemId in result.consumedItems) {
        _controller.removeItemFromInventory(itemId);
      }

      if (result.newItemId != null) {
        _controller.addItemToInventory(result.newItemId!);
      }

      // UI更新
      _uiManager.refreshInventoryUI();

      // モーダル表示
      if (result.message.isNotEmpty) {
        showInteractionModal('combination_$ruleId', result.message);
      }
    }

    return result;
  }

  /// ギミック解除を試行
  CombinationResult tryGimmickActivation(String ruleId) {
    final availableItems = _inventoryManager.items;
    final result = _itemCombinationManager.attemptGimmickActivation(
      ruleId,
      availableItems,
    );

    if (result.success) {
      // 成功時の処理
      for (final itemId in result.consumedItems) {
        _controller.removeItemFromInventory(itemId);
      }

      // ギミック解除を記録
      final targetObjectId = result.metadata['targetObjectId'] as String?;
      if (targetObjectId != null) {
        _controller.recordObjectInteraction(targetObjectId);
      }

      // UI更新
      _uiManager.refreshInventoryUI();

      // モーダル表示
      if (result.message.isNotEmpty) {
        showInteractionModal('gimmick_$ruleId', result.message);
      }
    } else {
      // 失敗時もメッセージを表示
      if (result.message.isNotEmpty) {
        showInteractionModal('gimmick_fail_$ruleId', result.message);
      }
    }

    return result;
  }

  /// 利用可能な組み合わせを取得
  List<CombinationRule> getAvailableCombinations() {
    return _itemCombinationManager.getAvailableCombinations(
      _inventoryManager.items,
    );
  }

  /// 利用可能なギミックを取得
  List<GimmickRule> getAvailableGimmicks() {
    return _itemCombinationManager.getAvailableGimmicks(
      _inventoryManager.items,
    );
  }

  /// 縦画面レイアウト作成（外部レイアウトで管理するため無効化）
  Future<void> _createPortraitLayout() async {
    // 外部レイアウトで管理するため、ゲーム内レイアウトは無効化
    // _layoutComponent = PortraitLayoutComponent();
    // add(_layoutComponent);
    //
    // final layout = _layoutComponent.calculateLayout(size);
    // debugPrint('📱 Portrait layout created: ${layout?.screenSize}');
  }

  /// UI作成
  Future<void> _createUI() async {
    // UI表示は外部レイアウトで管理するため無効化
    // final uiComponents = await PortraitUIBuilder.buildPortraitUI(size);
    // for (final component in uiComponents) {
    //   add(component);
    // }
  }

  /// 画面サイズ変更時の処理 - UIマネージャーに委譲
  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (_isInitialized) {
      _uiManager.onScreenResize(size);
    }
  }

  /// タップイベント処理 - パーティクルエフェクトを追加
  @override
  bool onTapDown(TapDownEvent event) {
    final tapPosition = event.localPosition;

    debugPrint('🖱️ EscapeRoom onTapDown called at position: $tapPosition');
    debugPrint(
      '🖱️ ParticleEffectManager isMounted: ${_particleEffectManager.isMounted}',
    );

    // どこをタップしてもパーティクルエフェクトを表示
    try {
      _particleEffectManager.playEffect('sparkle', tapPosition);
      debugPrint('✨ Sparkle effect triggered at $tapPosition');
    } catch (e) {
      debugPrint('❌ Failed to play sparkle effect: $e');
    }

    return true; // イベントを処理した
  }
}
