import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../gameobjects/interactable_game_object.dart';
import '../gameobjects/bookshelf_object.dart';
import '../gameobjects/safe_object.dart';
import '../gameobjects/box_object.dart';
import '../../components/inventory_manager.dart';
import '../../state/game_state_system.dart';
import '../../ui/mobile_portrait_layout.dart';
import '../../ui/escape_room_modal_system.dart';
import '../../ui/modal_config.dart';
import '../../ui/japanese_message_system.dart';
import '../ui/portrait_ui_builder.dart';
import 'escape_room_game_controller.dart';
import 'escape_room_ui_manager.dart';

/// Escape Room Game - 新アーキテクチャ版
/// レイヤー分離原則に基づく設計
class EscapeRoomGame extends FlameGame {
  late EscapeRoomGameController _controller;
  late EscapeRoomUIManager _uiManager;
  late InventoryManager _inventoryManager;
  late EscapeRoomStateProvider _stateProvider;
  late PortraitLayoutComponent _layoutComponent;
  bool _isInitialized = false;
  
  // Controllers for layer separation
  EscapeRoomGameController get controller => _controller;
  EscapeRoomUIManager get uiManager => _uiManager;
  PortraitLayoutComponent get layoutComponent => _layoutComponent;
  
  @override
  Color backgroundColor() => const Color(0x00000000); // 背景を透明にして外部画像を表示

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await _initializeControllers();
    await _createPortraitLayout();
    await _createUI();
    await _spawnGameObjects();
  }
  
  /// コントローラーとマネージャーを初期化
  Future<void> _initializeControllers() async {
    // 状態管理プロバイダーを初期化
    _stateProvider = EscapeRoomStateProvider();
    
    // インベントリマネージャーを初期化
    _inventoryManager = InventoryManager(
      maxItems: 5,
      onItemSelected: (itemId) {
        debugPrint('🎒 Selected item: $itemId');
      },
    );
    
    // ゲームコントローラーを初期化
    _controller = EscapeRoomGameController(
      inventoryManager: _inventoryManager,
    );
    
    // UIマネージャーを初期化
    _uiManager = EscapeRoomUIManager(
      inventoryManager: _inventoryManager,
      gameComponent: this,
    );
    
    // インベントリUIを初期化（外部レイアウトで管理するため無効化）
    // await _uiManager.initializeInventoryUI(size);
    
    // 状態遷移テスト実行（開発用のため無効化）
    // _testStateTransitions();
    
    _isInitialized = true;
  }
  
  /// 状態遷移テスト実行（ブラウザ確認用）
  void _testStateTransitions() {
    debugPrint('🚪 EscapeRoomState Test Starting...');
    
    // テスト1: exploring → inventory → exploring
    _stateProvider.showInventory();
    _stateProvider.hideInventory();
    
    // テスト2: exploring → puzzle → exploring
    _stateProvider.startPuzzle('browser_test_puzzle');
    _stateProvider.completePuzzle();
    
    // テスト3: exploring → escaped
    _stateProvider.escapeSuccess();
    
    debugPrint('🚪 EscapeRoomState Test Completed!');
  }
  
  Future<void> _spawnGameObjects() async {
    // ホットスポットを一時的に非表示にする
    // TODO: 新しい部屋別ホットスポットシステムに置き換え
    debugPrint('EscapeRoomGame: ホットスポット非表示中（新システム準備中）');
    
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
    
    debugPrint('EscapeRoomGame: 新しいホットスポットシステム準備完了');
  }
  
  /// Strategy Patternによるインタラクション設定
  void _setupObjectStrategies(BookshelfObject bookshelf, SafeObject safe, BoxObject box) {
    // Strategy Patternの正しい実装は各ObjectクラスのconstrucorまたはsetInteractionStrategyで行う
    // ここでは一時的に直接設定（本来は各Objectクラス内で初期化すべき）
    debugPrint('Setting up object strategies for ${_controller.gameObjects.length} objects');
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
    
    final modal = ModalComponent(
      config: modalConfig,
      size: size,
    );
    
    add(modal);
    modal.show();
    debugPrint('📱 Modal displayed for $objectId: $message');
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
}