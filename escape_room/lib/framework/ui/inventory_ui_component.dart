import 'package:flame/components.dart';
import '../components/inventory_manager.dart';
import 'responsive_layout_calculator.dart';
import 'inventory_item_component.dart';
import 'clickable_inventory_item.dart';
import 'inventory_state_notifier.dart';
import 'japanese_message_system.dart';
import 'inventory_renderer.dart';
import 'inventory_event_handler.dart';

/// インベントリUIコンポーネント（メインUI）
/// レイヤー分離原則に基づく設計
class InventoryUIComponent extends PositionComponent with HasVisibility {
  final InventoryManager manager;
  final Vector2 screenSize;
  late ResponsiveLayoutCalculator _layoutCalculator;
  late InventoryStateNotifier _stateNotifier;
  late InventoryRenderer _renderer;
  late InventoryEventHandler _eventHandler;
  final List<dynamic> _itemComponents = [];
  final Map<String, GameItem> _gameItems = {};

  InventoryUIComponent({required this.manager, required this.screenSize})
    : super(
        position: Vector2(0, screenSize.y * 0.7),
        size: Vector2(screenSize.x, screenSize.y * 0.2),
      );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _initializeComponents();
    _initializeGameItems();
    _setupInventoryLayout();
    _setupItemComponents();
  }

  /// コンポーネントを初期化
  void _initializeComponents() {
    _layoutCalculator = ResponsiveLayoutCalculator(
      screenSize: screenSize,
      maxItems: manager.maxItems,
    );

    _stateNotifier = InventoryStateNotifier(manager: manager);

    _renderer = InventoryRenderer(
      layoutCalculator: _layoutCalculator,
      screenSize: screenSize,
    );

    _eventHandler = InventoryEventHandler(
      manager: manager,
      stateNotifier: _stateNotifier,
      onUIRefresh: () => _updateItemStates(),
    );
  }

  /// レイアウト計算機を取得（初期化チェック付き）
  ResponsiveLayoutCalculator get layoutCalculator {
    return _layoutCalculator;
  }

  /// 状態通知機を取得（初期化チェック付き）
  InventoryStateNotifier get stateNotifier {
    return _stateNotifier;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _updateItemStates();
  }

  /// インベントリレイアウトをセットアップ
  void _setupInventoryLayout() {
    // レンダラーを使用してUI要素を作成
    final background = _renderer.createInventoryBackground();
    add(background);

    final title = _renderer.createInventoryTitle();
    add(title);

    final navigationComponents = _renderer.createNavigationArrows(
      () => _eventHandler.onLeftArrowPressed(),
      () => _eventHandler.onRightArrowPressed(),
    );
    for (final component in navigationComponents) {
      add(component);
    }
  }

  /// ゲームアイテムを初期化（最大6個・画像表示対応）
  void _initializeGameItems() {
    // 6個のアイテムを定義（既存画像アセット使用）
    _gameItems['key'] = GameItem(
      id: 'key',
      name: JapaneseMessageSystem.getMessage('item_key'),
      description: JapaneseMessageSystem.getMessage('key_description'),
      imagePath: 'images/hotspots/safe_opened.png',
    );
    _gameItems['tool'] = GameItem(
      id: 'tool',
      name: JapaneseMessageSystem.getMessage('item_tool'),
      description: JapaneseMessageSystem.getMessage('tool_description'),
      imagePath: 'images/hotspots/box_opened.png',
    );
    _gameItems['code'] = GameItem(
      id: 'code',
      name: JapaneseMessageSystem.getMessage('item_code'),
      description: JapaneseMessageSystem.getMessage('code_description'),
      imagePath: 'images/hotspots/safe_closed.png',
    );
    _gameItems['book'] = GameItem(
      id: 'book',
      name: JapaneseMessageSystem.getMessage('item_book'),
      description: JapaneseMessageSystem.getMessage('book_description'),
      imagePath: 'images/hotspots/prison_bucket.png',
    );
    _gameItems['box'] = GameItem(
      id: 'box',
      name: JapaneseMessageSystem.getMessage('item_box'),
      description: JapaneseMessageSystem.getMessage('box_description'),
      imagePath: 'images/hotspots/box_closed.png',
    );
    _gameItems['empty_shelf'] = GameItem(
      id: 'empty_shelf',
      name: JapaneseMessageSystem.getMessage('item_empty_shelf'),
      description: JapaneseMessageSystem.getMessage('empty_shelf_description'),
      imagePath: 'images/hotspots/bookshelf_empty.png',
    );
  }

  /// アイテムコンポーネントをセットアップ
  void _setupItemComponents() {
    // 既存のアイテムコンポーネントをクリア
    _clearItemComponents();

    final items = manager.items;
    if (items.isEmpty) {
      _showEmptyMessage();
      return;
    }

    final positions = _layoutCalculator.calculateItemPositions(items.length);
    final itemSize = _layoutCalculator.calculateItemSize(items.length);

    for (int i = 0; i < items.length; i++) {
      final itemId = items[i];
      final gameItem = _gameItems[itemId];

      if (gameItem != null) {
        final itemComponent = InventoryItemComponent(
          itemId: itemId,
          item: gameItem,
          onItemTapped: _onItemTapped,
          position: positions[i],
          size: itemSize,
        );

        _itemComponents.add(itemComponent);
        add(itemComponent);
      }
    }
  }

  /// アイテムコンポーネントをクリア
  void _clearItemComponents() {
    for (final component in _itemComponents) {
      component.removeFromParent();
    }
    _itemComponents.clear();
  }

  /// アイテム状態を更新
  void _updateItemStates() {
    // アイテムコンポーネントを再構築（アイテム追加/削除時）
    _setupItemComponents();

    // 選択状態を更新
    for (final component in _itemComponents) {
      if (component is InventoryItemComponent) {
        final isSelected = component.itemId == _stateNotifier.selectedItemId;
        component.updateSelectionState(isSelected);
      } else if (component is ClickableInventoryItem) {
        final isSelected = component.itemId == _stateNotifier.selectedItemId;
        component.updateSelectionState(isSelected);
      }
    }
  }

  /// アイテムタップ処理
  void _onItemTapped(String itemId) {
    _eventHandler.onItemTapped(itemId);
  }

  /// UIを更新
  void refreshUI() {
    _setupItemComponents();
  }

  /// アイテム選択
  void selectItem(String itemId) {
    _eventHandler.selectItem(itemId);
  }

  /// アイテム追加（外部から呼び出し用）
  bool addItem(String itemId) {
    return _eventHandler.addItem(itemId);
  }

  /// アイテム削除（外部から呼び出し用）
  bool removeItem(String itemId) {
    return _eventHandler.removeItem(itemId);
  }

  /// 選択中のアイテムID取得
  String? get selectedItemId => _eventHandler.selectedItemId;

  /// 空のインベントリメッセージを表示
  void _showEmptyMessage() {
    final emptyComponent = _renderer.createEmptyMessage();
    add(emptyComponent);
  }
}
