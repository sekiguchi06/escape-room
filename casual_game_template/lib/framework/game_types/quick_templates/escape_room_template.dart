import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import '../../core/configurable_game.dart';
import '../../state/game_state_system.dart';
import '../../timer/flame_timer_system.dart';

/// エリア設定
class AreaConfig {
  final String id;
  final String name;
  final String description;
  final Map<String, String> connections; // 方向: 接続先エリアID
  final List<String> items;
  
  const AreaConfig({
    required this.id,
    required this.name,
    required this.description,
    this.connections = const {},
    this.items = const [],
  });
}

/// 脱出ゲーム設定
class EscapeRoomConfig {
  final Duration timeLimit;
  final int maxInventoryItems;
  final List<String> requiredItems;
  final String roomTheme;
  final int difficultyLevel;
  final List<AreaConfig> areas; // 複数エリア対応
  
  const EscapeRoomConfig({
    this.timeLimit = const Duration(minutes: 10),
    this.maxInventoryItems = 8,
    this.requiredItems = const ['key', 'code', 'tool'],
    this.roomTheme = 'office',
    this.difficultyLevel = 1,
    this.areas = const [], // デフォルトは空リスト
  });
}

/// 脱出ゲーム状態
enum EscapeRoomState implements GameState {
  exploring,
  inventory,
  puzzle,
  escaped,
  timeUp;
  
  @override
  String get name => toString().split('.').last;
  
  @override
  String get description => switch(this) {
    EscapeRoomState.exploring => '部屋を探索中',
    EscapeRoomState.inventory => 'インベントリ確認中',
    EscapeRoomState.puzzle => 'パズル解答中',
    EscapeRoomState.escaped => '脱出成功！',
    EscapeRoomState.timeUp => '時間切れ',
  };
  
  @override
  Map<String, dynamic> toJson() => {'name': name, 'description': description};
}

/// アイテム情報
class GameItem {
  final String id;
  final String name;
  final String description;
  final bool canUse;
  final bool canCombine;
  
  const GameItem({
    required this.id,
    required this.name,
    required this.description,
    this.canUse = true,
    this.canCombine = false,
  });
}

/// モーダル表示タイプ
enum ModalType {
  item,      // アイテム詳細表示
  puzzle,    // パズル解答
  inspection // オブジェクト詳細調査
}

/// モーダル設定
class ModalConfig {
  final ModalType type;
  final String title;
  final String content;
  final Map<String, dynamic> data;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  
  const ModalConfig({
    required this.type,
    required this.title,
    required this.content,
    this.data = const {},
    this.onConfirm,
    this.onCancel,
  });
}

/// 5分で作成可能な脱出ゲームテンプレート
abstract class QuickEscapeRoomTemplate extends ConfigurableGame<EscapeRoomState, EscapeRoomConfig> 
    with TapCallbacks {
  // ゲームシステム
  late InventoryManager _inventory;
  late InteractionManager _interactionManager;
  final Map<String, HotspotComponent> _hotspots = {};
  final Map<String, GameItem> _items = {};
  
  // 複数エリア管理
  final Map<String, Map<String, HotspotComponent>> _areaHotspots = {};
  final Map<String, Map<String, GameItem>> _areaItems = {};
  String _currentAreaId = 'main'; // 現在のエリアID
  
  // ゲーム状態
  double _timeRemaining = 0;
  int _puzzlesSolved = 0;
  bool _gameActive = false;
  String? _selectedItem;
  
  // ホットスポット状態管理（アイテム取得・ギミック完了状態）
  final Map<String, bool> _hotspotStates = {}; // true = アイテム取得済み・クリア済み
  
  // 画面状態管理
  bool _showStartScreen = true;
  bool _showClearScreen = false;
  
  // モーダル管理
  ModalComponent? _activeModal;
  bool _modalVisible = false;
  
  // スマートフォン縦型レイアウト用変数
  late Vector2 _containerSize;
  late Vector2 _containerOffset;
  late Vector2 _gameAreaPosition;
  late Vector2 _gameAreaSize;
  late Vector2 _inventoryPosition;
  late Vector2 _inventorySize;
  late Vector2 _bannerAdPosition;
  late Vector2 _bannerAdSize;
  
  // 公開プロパティ
  double get timeRemaining => _timeRemaining;
  int get puzzlesSolved => _puzzlesSolved;
  bool get gameActive => _gameActive;
  List<String> get inventoryItems => _inventory.items;
  
  /// ゲーム固有設定（サブクラスで実装）
  EscapeRoomConfig get gameConfig;
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // インベントリマネージャー初期化
    _inventory = InventoryManager(
      maxItems: gameConfig.maxInventoryItems,
      onItemSelected: (itemId) => _onItemSelected(itemId),
    );
    
    // インタラクションマネージャー初期化
    _interactionManager = InteractionManager(
      onInteraction: (hotspotId, itemId) => _onHotspotInteraction(hotspotId, itemId),
    );
    
    // 初期状態設定
    stateProvider.changeState(EscapeRoomState.exploring);
    
    await setupRoom();
    await setupGame();
  }
  
  /// 部屋のセットアップ
  Future<void> setupRoom() async {
    // 背景設定
    await _setupBackground();
    
    // ホットスポット配置
    await _setupHotspots();
    
    // アイテム配置
    await _setupItems();
  }
  
  /// 背景セットアップ（スマートフォン縦型レイアウト対応）
  Future<void> _setupBackground() async {
    // スマートフォン縦型レイアウト: iPhone15アスペクト比 393×852
    final phoneAspectRatio = 393.0 / 852.0;
    final currentAspectRatio = size.x / size.y;
    
    // コンテナサイズ計算（iPhone15比率維持）
    Vector2 containerSize;
    Vector2 containerOffset;
    
    if (currentAspectRatio > phoneAspectRatio) {
      // 画面が横に広い場合：高さ基準でコンテナサイズ決定
      containerSize = Vector2(size.y * phoneAspectRatio, size.y);
      containerOffset = Vector2((size.x - containerSize.x) / 2, 0);
    } else {
      // 画面が縦に長い場合：幅基準でコンテナサイズ決定
      containerSize = Vector2(size.x, size.x / phoneAspectRatio);
      containerOffset = Vector2(0, (size.y - containerSize.y) / 2);
    }
    
    // 縦型レイアウトゾーン定義
    final topMenuHeight = containerSize.y * 0.1;    // 10%: メニューバー
    final gameAreaHeight = containerSize.y * 0.6;   // 60%: ゲーム領域  
    final inventoryHeight = containerSize.y * 0.2;  // 20%: インベントリ
    final bannerAdHeight = containerSize.y * 0.1;   // 10%: 広告エリア
    
    // レスポンシブデザインで各ゾーンの位置計算
    final topMenuArea = Vector2(containerOffset.x, containerOffset.y);
    final gameAreaPosition = Vector2(containerOffset.x, containerOffset.y + topMenuHeight);
    final inventoryPosition = Vector2(containerOffset.x, containerOffset.y + topMenuHeight + gameAreaHeight);
    final bannerAdPosition = Vector2(containerOffset.x, containerOffset.y + topMenuHeight + gameAreaHeight + inventoryHeight);
    
    // レイアウト変数を保存（他のメソッドで使用）
    _containerSize = containerSize;
    _containerOffset = containerOffset;
    _gameAreaPosition = gameAreaPosition;
    _gameAreaSize = Vector2(containerSize.x, gameAreaHeight);
    _inventoryPosition = inventoryPosition;
    _inventorySize = Vector2(containerSize.x, inventoryHeight);
    _bannerAdPosition = bannerAdPosition;
    _bannerAdSize = Vector2(containerSize.x, bannerAdHeight);
    
    // コンテナ全体背景（枠表示用）
    final containerBg = RectangleComponent(
      size: containerSize,
      position: containerOffset,
      paint: Paint()..color = Colors.grey.shade800,
    );
    add(containerBg);
    
    // ゲーム領域背景（エリアごとに色を変更）
    final areaColor = _getAreaColor(_currentAreaId);
    final gameAreaBg = RectangleComponent(
      size: Vector2(containerSize.x, gameAreaHeight),
      position: gameAreaPosition,
      paint: Paint()..color = areaColor,
    );
    add(gameAreaBg);
    
    // ゲーム領域内の床
    final floorHeight = gameAreaHeight * 0.1;
    final floor = RectangleComponent(
      size: Vector2(containerSize.x, floorHeight),
      position: Vector2(gameAreaPosition.x, gameAreaPosition.y + gameAreaHeight - floorHeight),
      paint: Paint()..color = Colors.brown.shade400,
    );
    add(floor);
    
    // 壁の装飾（ゲーム領域内でのレスポンシブ配置）
    _addWallDecorations(gameAreaPosition, Vector2(containerSize.x, gameAreaHeight));
  }
  
  /// 壁の装飾追加（スマートフォン縦型レイアウト対応）
  void _addWallDecorations(Vector2 gameAreaPosition, Vector2 gameAreaSize) {
    // ドア（ゲーム領域内右下）- レスポンシブサイズ
    final doorSize = Vector2(gameAreaSize.x * 0.15, gameAreaSize.y * 0.2);
    final door = RectangleComponent(
      size: doorSize,
      position: Vector2(gameAreaPosition.x + gameAreaSize.x - doorSize.x - gameAreaSize.x * 0.05, 
                       gameAreaPosition.y + gameAreaSize.y - doorSize.y - gameAreaSize.y * 0.15),
      paint: Paint()..color = Colors.brown.shade600,
    );
    add(door);
    
    // 窓（ゲーム領域内左上）- レスポンシブサイズ
    final windowSize = Vector2(gameAreaSize.x * 0.25, gameAreaSize.y * 0.15);
    final window = RectangleComponent(
      size: windowSize,
      position: Vector2(gameAreaPosition.x + gameAreaSize.x * 0.05, 
                       gameAreaPosition.y + gameAreaSize.y * 0.05),
      paint: Paint()..color = Colors.lightBlue.shade200,
    );
    add(window);
  }
  
  /// ホットスポット配置（スマートフォン縦型レイアウト対応）
  Future<void> _setupHotspots() async {
    // エリアごとに異なるホットスポットを配置
    switch (_currentAreaId) {
      case 'main':
        _setupMainRoomHotspots();
        break;
      case 'storage':
        _setupStorageRoomHotspots();
        break;
      case 'office':
        _setupOfficeRoomHotspots();
        break;
      default:
        _setupDefaultHotspots();
        break;
    }
  }
  
  /// メインルームのホットスポット
  void _setupMainRoomHotspots() {
    // ドアのホットスポット（脱出口）
    final doorHotspotSize = Vector2(_gameAreaSize.x * 0.2, _gameAreaSize.y * 0.25);
    _addHotspot('door', 
                Vector2(_gameAreaPosition.x + _gameAreaSize.x - doorHotspotSize.x - _gameAreaSize.x * 0.03, 
                       _gameAreaPosition.y + _gameAreaSize.y - doorHotspotSize.y - _gameAreaSize.y * 0.1), 
                doorHotspotSize, 'ドア', 'ここから脱出できそうだ...');
    
    // 本棚のホットスポット
    final bookshelfHotspotSize = Vector2(_gameAreaSize.x * 0.25, _gameAreaSize.y * 0.3);
    _addHotspot('bookshelf', 
                Vector2(_gameAreaPosition.x + _gameAreaSize.x * 0.05, 
                       _gameAreaPosition.y + _gameAreaSize.y - bookshelfHotspotSize.y - _gameAreaSize.y * 0.05), 
                bookshelfHotspotSize, '本棚', '本の間に何かが挟まっている');
  }
  
  /// 物置部屋のホットスポット
  void _setupStorageRoomHotspots() {
    // 古い箱のホットスポット
    final boxHotspotSize = Vector2(_gameAreaSize.x * 0.3, _gameAreaSize.y * 0.2);
    _addHotspot('old_box', 
                Vector2(_gameAreaPosition.x + _gameAreaSize.x * 0.1, 
                       _gameAreaPosition.y + _gameAreaSize.y - boxHotspotSize.y - _gameAreaSize.y * 0.05), 
                boxHotspotSize, '古い箱', 'ホコリをかぶった箱がある');
    
    // 棚のホットスポット
    final shelfHotspotSize = Vector2(_gameAreaSize.x * 0.35, _gameAreaSize.y * 0.25);
    _addHotspot('shelf', 
                Vector2(_gameAreaPosition.x + _gameAreaSize.x * 0.6, 
                       _gameAreaPosition.y + _gameAreaSize.y * 0.2), 
                shelfHotspotSize, '棚', '色々なものが置かれている');
  }
  
  /// オフィスのホットスポット
  void _setupOfficeRoomHotspots() {
    // 机のホットスポット
    final deskHotspotSize = Vector2(_gameAreaSize.x * 0.3, _gameAreaSize.y * 0.2);
    _addHotspot('desk', 
                Vector2(_gameAreaPosition.x + _gameAreaSize.x * 0.35, 
                       _gameAreaPosition.y + _gameAreaSize.y - deskHotspotSize.y - _gameAreaSize.y * 0.05), 
                deskHotspotSize, '机', '引き出しがある');
    
    // 金庫のホットスポット
    final safeHotspotSize = Vector2(_gameAreaSize.x * 0.2, _gameAreaSize.y * 0.15);
    _addHotspot('safe', 
                Vector2(_gameAreaPosition.x + _gameAreaSize.x - safeHotspotSize.x - _gameAreaSize.x * 0.05, 
                       _gameAreaPosition.y + _gameAreaSize.y * 0.1), 
                safeHotspotSize, '金庫', '数字の組み合わせが必要');
  }
  
  /// デフォルトのホットスポット
  void _setupDefaultHotspots() {
    // デフォルトの場合は基本的なホットスポットのみ
    final doorHotspotSize = Vector2(_gameAreaSize.x * 0.2, _gameAreaSize.y * 0.25);
    _addHotspot('door', 
                Vector2(_gameAreaPosition.x + _gameAreaSize.x - doorHotspotSize.x - _gameAreaSize.x * 0.03, 
                       _gameAreaPosition.y + _gameAreaSize.y - doorHotspotSize.y - _gameAreaSize.y * 0.1), 
                doorHotspotSize, 'ドア', 'ここから脱出できそうだ...');
  }
  
  /// ホットスポット追加
  void _addHotspot(String id, Vector2 position, Vector2 size, String name, String description) {
    final hotspot = HotspotComponent(
      id: id,
      name: name,
      description: description,
      onTapped: (hotspotId) => _onHotspotTapped(hotspotId),
    );
    hotspot.position = position;
    hotspot.size = size;
    
    _hotspots[id] = hotspot;
    add(hotspot);
  }
  
  /// アイテム配置
  Future<void> _setupItems() async {
    // アイテム定義
    _items['key'] = const GameItem(
      id: 'key',
      name: '鍵',
      description: 'ドアを開けるのに必要な鍵',
    );
    
    _items['code'] = const GameItem(
      id: 'code', 
      name: 'メモ',
      description: '4桁の数字が書かれている: 1234',
    );
    
    _items['tool'] = const GameItem(
      id: 'tool',
      name: 'ドライバー', 
      description: '何かを分解するのに使えそう',
    );
  }
  
  /// ゲームセットアップ
  Future<void> setupGame() async {
    _timeRemaining = gameConfig.timeLimit.inSeconds.toDouble();
    
    // タイマー設定
    timerManager.addTimer('gameTimer', TimerConfiguration(
      duration: gameConfig.timeLimit,
      type: TimerType.countdown,
      onComplete: () => _onTimeUp(),
      onUpdate: (remaining) {
        _timeRemaining = remaining.inSeconds.toDouble();
        _updateGameUI();
      },
    ));
    
    // UI初期化
    _setupGameUI();
    
    // 開始画面を表示
    if (_showStartScreen) {
      _showStartScreenUI();
    } else {
      startGame();
    }
  }
  
  /// ゲームUI初期化（スマートフォン縦型レイアウト対応）
  void _setupGameUI() {
    // 上部メニューバー実装
    _setupTopMenuBar();
    
    // インベントリ表示エリア（ゲーム開始時のみ）
    if (_gameActive && !_showStartScreen) {
      _updateInventoryUI();
    }
    
    // バナー広告エリア実装
    _setupBannerAdArea();
  }
  
  /// 上部メニューバー実装
  void _setupTopMenuBar() {
    final topMenuHeight = _containerSize.y * 0.1;
    
    // メニューバー背景
    final menuBarBg = RectangleComponent(
      size: Vector2(_containerSize.x, topMenuHeight),
      position: _containerOffset,
      paint: Paint()..color = Colors.black.withValues(alpha: 0.8),
    );
    menuBarBg.priority = 1100;
    add(menuBarBg);
    
    // ボタンサイズとスペーシング計算（3ボタン配置）
    final buttonWidth = _containerSize.x * 0.25;
    final buttonHeight = topMenuHeight * 0.7;
    final buttonSpacing = (_containerSize.x - (buttonWidth * 3)) / 4;
    
    // ホームボタン
    _addMenuButton(
      'ホーム',
      Vector2(_containerOffset.x + buttonSpacing, _containerOffset.y + (topMenuHeight - buttonHeight) / 2),
      Vector2(buttonWidth, buttonHeight),
      Colors.blue.shade600,
      () => _onHomeButtonPressed(),
    );
    
    // リトライボタン
    _addMenuButton(
      'リトライ',
      Vector2(_containerOffset.x + buttonSpacing * 2 + buttonWidth, _containerOffset.y + (topMenuHeight - buttonHeight) / 2),
      Vector2(buttonWidth, buttonHeight),
      Colors.green.shade600,
      () => _onRetryButtonPressed(),
    );
    
    // ヒントボタン
    _addMenuButton(
      'ヒント',
      Vector2(_containerOffset.x + buttonSpacing * 3 + buttonWidth * 2, _containerOffset.y + (topMenuHeight - buttonHeight) / 2),
      Vector2(buttonWidth, buttonHeight),
      Colors.orange.shade600,
      () => _onHintButtonPressed(),
    );
    
    // タイマー表示（右上角）
    final timerComponent = TextComponent(
      text: formatTime(_timeRemaining),
      textRenderer: TextPaint(
        style: TextStyle(
          color: Colors.white,
          fontSize: _containerSize.y * 0.025,
          fontWeight: FontWeight.bold,
          fontFamily: 'Noto Sans JP',
          shadows: const [
            Shadow(
              color: Colors.black,
              offset: Offset(2, 2),
              blurRadius: 4,
            ),
          ],
        ),
      ),
      position: Vector2(_containerOffset.x + _containerSize.x - _containerSize.x * 0.02, 
                       _containerOffset.y + topMenuHeight * 0.15),
      anchor: Anchor.topRight,
    );
    timerComponent.priority = 1101;
    add(timerComponent);
  }
  
  /// メニューボタン追加ヘルパー
  void _addMenuButton(String text, Vector2 position, Vector2 size, Color color, VoidCallback onPressed) {
    // ボタン背景
    final buttonBg = RectangleComponent(
      size: size,
      position: position,
      paint: Paint()..color = color,
    );
    buttonBg.priority = 1102;
    add(buttonBg);
    
    // ボタンテキスト
    final buttonText = TextComponent(
      text: text,
      textRenderer: TextPaint(
        style: TextStyle(
          color: Colors.white,
          fontSize: _containerSize.y * 0.02,
          fontWeight: FontWeight.bold,
          fontFamily: 'Noto Sans JP',
        ),
      ),
      position: Vector2(position.x + size.x / 2, position.y + size.y / 2),
      anchor: Anchor.center,
    );
    buttonText.priority = 1103;
    add(buttonText);
    
    // ボタンクリック領域
    final clickArea = StartButtonComponent(
      size: size,
      position: position,
      onPressed: onPressed,
    );
    clickArea.priority = 1104;
    add(clickArea);
  }
  
  /// メニューボタンイベントハンドラー
  void _onHomeButtonPressed() {
    _showMessage('ホームボタンが押されました');
    // ホーム画面に戻る処理
    _onBackToTitlePressed();
  }
  
  void _onRetryButtonPressed() {
    _showMessage('リトライしています...');
    // ゲームリスタート処理
    resetGame();
  }
  
  void _onHintButtonPressed() {
    _showMessage('ヒント: アイテムを集めてパズルを解こう！');
    // ヒント表示処理（カスタマイズ可能）
  }
  
  /// 矢印ボタン追加ヘルパー
  void _addArrowButton(String text, Vector2 position, Vector2 size, Color color, VoidCallback onPressed) {
    // ボタン背景
    final buttonBg = RectangleComponent(
      size: size,
      position: position,
      paint: Paint()..color = color,
    );
    buttonBg.priority = 1022;
    add(buttonBg);
    
    // ボタンテキスト（矢印）
    final buttonText = TextComponent(
      text: text,
      textRenderer: TextPaint(
        style: TextStyle(
          color: Colors.white,
          fontSize: size.y * 0.4,
          fontWeight: FontWeight.bold,
        ),
      ),
      position: Vector2(position.x + size.x / 2, position.y + size.y / 2),
      anchor: Anchor.center,
    );
    buttonText.priority = 1023;
    add(buttonText);
    
    // ボタンクリック領域
    final clickArea = StartButtonComponent(
      size: size,
      position: position,
      onPressed: onPressed,
    );
    clickArea.priority = 1024;
    add(clickArea);
  }
  
  /// 矢印ボタンイベントハンドラー
  void _onLeftArrowPressed() {
    // エリア移動処理
    _moveToArea('west');
  }
  
  void _onRightArrowPressed() {
    // エリア移動処理
    _moveToArea('east');
  }
  
  /// エリア移動処理
  void _moveToArea(String direction) {
    // 現在のエリア設定を取得
    final currentArea = gameConfig.areas.firstWhere(
      (area) => area.id == _currentAreaId,
      orElse: () => const AreaConfig(id: 'main', name: 'メインルーム', description: ''),
    );
    
    // 移動先エリアIDを取得
    final targetAreaId = currentArea.connections[direction];
    if (targetAreaId == null) {
      _showMessage('その方向には進めません');
      return;
    }
    
    // 移動先エリアが存在するか確認
    final targetArea = gameConfig.areas.firstWhere(
      (area) => area.id == targetAreaId,
      orElse: () => const AreaConfig(id: '', name: '', description: ''),
    );
    
    if (targetArea.id.isEmpty) {
      _showMessage('エリアが見つかりません');
      return;
    }
    
    // エリア切り替え
    _switchToArea(targetAreaId, targetArea);
  }
  
  /// エリア切り替え処理
  void _switchToArea(String areaId, AreaConfig area) {
    _currentAreaId = areaId;
    
    // 現在のホットスポットを保存
    _areaHotspots[_currentAreaId] = Map.from(_hotspots);
    _areaItems[_currentAreaId] = Map.from(_items);
    
    // ホットスポットをクリア
    _hotspots.clear();
    _items.clear();
    
    // 新しいエリアのホットスポットを読み込み
    if (_areaHotspots.containsKey(areaId)) {
      _hotspots.addAll(_areaHotspots[areaId]!);
      _items.addAll(_areaItems[areaId]!);
    }
    
    // 画面を再描画
    removeAll(children);
    setupRoom().then((_) {
      _setupGameUI();
      _showMessage('${area.name}に移動しました');
    });
  }
  
  /// バナー広告エリア実装
  void _setupBannerAdArea() {
    // バナー広告エリア背景
    final bannerAdBg = RectangleComponent(
      size: _bannerAdSize,
      position: _bannerAdPosition,
      paint: Paint()..color = Colors.grey.shade300,
    );
    bannerAdBg.priority = 1050;
    add(bannerAdBg);
    
    // プレースホルダーテキスト
    final placeholderText = TextComponent(
      text: 'バナー広告エリア',
      textRenderer: TextPaint(
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: _containerSize.y * 0.02,
          fontWeight: FontWeight.bold,
          fontFamily: 'Noto Sans JP',
        ),
      ),
      position: Vector2(_bannerAdPosition.x + _bannerAdSize.x / 2, 
                       _bannerAdPosition.y + _bannerAdSize.y / 2),
      anchor: Anchor.center,
    );
    placeholderText.priority = 1051;
    add(placeholderText);
  }
  

  
  /// ゲームUI更新（スマートフォン縦型レイアウト対応）
  void _updateGameUI() {
    // タイマー更新（右上角のタイマーを更新）
    for (final component in children) {
      if (component is TextComponent && 
          component.anchor == Anchor.topRight &&
          component.position.x > _containerOffset.x + _containerSize.x - _containerSize.x * 0.1) {
        component.text = formatTime(_timeRemaining);
      }
    }
    
    // インベントリ更新は選択時のみ実行（タイマー更新では実行しない）
    // _updateInventoryUI(); // コメントアウト：タイマー更新時の不要な再描画を防止
  }
  
  /// インベントリUI更新（スマートフォン縦型レイアウト対応）
  void _updateInventoryUI() {
    // 既存のインベントリUIを削除（安全な方法）
    final componentsToRemove = <Component>[];
    
    for (final component in children) {
      if (component.priority >= 1020 && component.priority <= 1040) {
        // インベントリ専用プライオリティ範囲で削除
        componentsToRemove.add(component);
      }
    }
    
    for (final component in componentsToRemove) {
      component.removeFromParent();
    }
    
    // インベントリ背景（下部ゾーンに配置）
    final inventoryBg = RectangleComponent(
      size: _inventorySize,
      position: _inventoryPosition,
      paint: Paint()..color = Colors.black.withValues(alpha: 0.9),
    );
    inventoryBg.priority = 1020;
    add(inventoryBg);
    
    // 左右矢印ボタン配置 + 中央インベントリエリア
    final buttonWidth = _inventorySize.x * 0.15; // 15%ずつ左右に配置
    final inventoryCenterWidth = _inventorySize.x * 0.7; // 70%を中央インベントリに使用
    
    // 現在のエリアの接続情報を取得
    final currentArea = gameConfig.areas.firstWhere(
      (area) => area.id == _currentAreaId,
      orElse: () => const AreaConfig(id: 'main', name: 'メインルーム', description: ''),
    );

    // 左矢印ボタン（西への接続がある場合のみ表示）
    if (currentArea.connections.containsKey('west')) {
      _addArrowButton(
        '◀',
        Vector2(_inventoryPosition.x + _inventorySize.x * 0.02, 
                _inventoryPosition.y + _inventorySize.y * 0.25),
        Vector2(buttonWidth, _inventorySize.y * 0.5),
        Colors.grey.shade600,
        () => _onLeftArrowPressed(),
      );
    }
    
    // 右矢印ボタン（東への接続がある場合のみ表示）
    if (currentArea.connections.containsKey('east')) {
      _addArrowButton(
        '▶',
        Vector2(_inventoryPosition.x + _inventorySize.x - buttonWidth - _inventorySize.x * 0.02, 
                _inventoryPosition.y + _inventorySize.y * 0.25),
        Vector2(buttonWidth, _inventorySize.y * 0.5),
        Colors.grey.shade600,
        () => _onRightArrowPressed(),
      );
    }
    
    // 中央インベントリタイトル
    final titleComponent = TextComponent(
      text: 'インベントリ',
      textRenderer: TextPaint(
        style: TextStyle(
          color: Colors.yellow,
          fontSize: _containerSize.y * 0.025,
          fontWeight: FontWeight.bold,
          fontFamily: 'Noto Sans JP',
        ),
      ),
      position: Vector2(_inventoryPosition.x + _inventorySize.x / 2, 
                       _inventoryPosition.y + _inventorySize.y * 0.15),
      anchor: Anchor.center,
    );
    titleComponent.priority = 1021;
    add(titleComponent);
    
    // 中央インベントリエリア（アイテム表示）
    final inventoryCenterPosition = Vector2(_inventoryPosition.x + buttonWidth + _inventorySize.x * 0.05, 
                                           _inventoryPosition.y);
    final inventoryCenterSize = Vector2(inventoryCenterWidth, _inventorySize.y);
    
    // アイテム表示（中央エリアに横並び配置）
    if (_inventory.items.isNotEmpty) {
      final itemAreaWidth = inventoryCenterWidth * 0.9;
      final itemAreaHeight = inventoryCenterSize.y * 0.6;
      final itemStartX = inventoryCenterPosition.x + inventoryCenterWidth * 0.05;
      final itemStartY = inventoryCenterPosition.y + inventoryCenterSize.y * 0.3;
      
      // アイテムサイズ計算（中央エリア内で横並び最適化）
      final maxItemsPerRow = 4; // 中央エリアで表示可能な最大アイテム数
      final itemSize = (itemAreaWidth / maxItemsPerRow) * 0.85; // 余白を考慮
      final itemSpacing = (itemAreaWidth - (itemSize * maxItemsPerRow)) / (maxItemsPerRow + 1);
      
      for (int i = 0; i < _inventory.items.length; i++) {
        final item = _inventory.items[i];
        final isSelected = _selectedItem == item;
        final itemName = _items[item]?.name ?? item;
        
        // アイテム位置計算（中央エリア内で横並び）
        final itemX = itemStartX + itemSpacing + (i % maxItemsPerRow) * (itemSize + itemSpacing);
        final itemY = itemStartY + (i ~/ maxItemsPerRow) * (itemSize + itemSpacing * 0.5);
        final itemPosition = Vector2(itemX, itemY);
        
        // アイコン背景
        final iconBg = RectangleComponent(
          size: Vector2(itemSize, itemSize),
          position: itemPosition,
          paint: Paint()..color = _getItemColor(item),
        );
        iconBg.priority = 1022;
        add(iconBg);
        
        // アイコン内のアイテム識別子（絵文字）
        final iconText = TextComponent(
          text: _getItemIcon(item),
          textRenderer: TextPaint(
            style: TextStyle(
              color: Colors.white,
              fontSize: itemSize * 0.4,
              fontWeight: FontWeight.bold,
            ),
          ),
          position: Vector2(itemPosition.x + itemSize / 2, itemPosition.y + itemSize / 2),
          anchor: Anchor.center,
        );
        iconText.priority = 1023;
        add(iconText);
        
        // 選択フレーム（選択時のみ）
        if (isSelected) {
          final selectionFrame = RectangleComponent(
            size: Vector2(itemSize + 4, itemSize + 4),
            position: Vector2(itemPosition.x - 2, itemPosition.y - 2),
            paint: Paint()
              ..color = Colors.transparent
              ..style = PaintingStyle.stroke
              ..strokeWidth = 3.0
              ..color = Colors.yellow,
          );
          selectionFrame.priority = 1024;
          add(selectionFrame);
          
          // 選択時のアイテム名表示（下部に表示）
          final utf8ItemName = String.fromCharCodes(itemName.runes);
          final nameDisplay = TextComponent(
            text: utf8ItemName,
            textRenderer: TextPaint(
              style: TextStyle(
                color: Colors.yellow,
                fontSize: _containerSize.y * 0.02,
                fontWeight: FontWeight.bold,
                fontFamily: 'Noto Sans JP',
                shadows: const [
                  Shadow(
                    color: Colors.black,
                    offset: Offset(1, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
            ),
            position: Vector2(_inventoryPosition.x + _inventorySize.x / 2, 
                             _inventoryPosition.y + _inventorySize.y * 0.85),
            anchor: Anchor.center,
          );
          nameDisplay.priority = 1025;
          add(nameDisplay);
        }
        
        // クリック可能エリア（最上位に配置）
        final clickableItem = ClickableInventoryItem(
          itemId: item,
          onTapped: (itemId) => _onItemSelected(itemId),
          size: Vector2(itemSize, itemSize),
          position: itemPosition,
        );
        clickableItem.priority = 1030; // 最上位でタップを確実に捕捉
        add(clickableItem);
      }
    } else {
      final emptyComponent = TextComponent(
        text: '(空)',
        textRenderer: TextPaint(
          style: TextStyle(
            color: Colors.grey,
            fontSize: _containerSize.y * 0.025,
            fontFamily: 'Noto Sans JP',
          ),
        ),
        position: Vector2(_inventoryPosition.x + _inventorySize.x / 2, 
                         _inventoryPosition.y + _inventorySize.y / 2),
        anchor: Anchor.center,
      );
      emptyComponent.priority = 1021;
      add(emptyComponent);
    }
  }
  
  /// 開始画面表示
  void _showStartScreenUI() {
    // 既存UIをクリア
    removeAll(children);
    
    // 背景
    add(RectangleComponent(
      size: size,
      paint: Paint()..color = Colors.black.withValues(alpha: 0.85),
    ));
    
    // タイトル
    final titleComponent = TextComponent(
      text: '脱出ゲーム',
      textRenderer: TextPaint(
        style: TextStyle(
          color: Colors.white,
          fontSize: size.y * 0.08,
          fontWeight: FontWeight.bold,
          fontFamily: 'Noto Sans JP',
          shadows: const [
            Shadow(
              color: Colors.blue,
              offset: Offset(3, 3),
              blurRadius: 10,
            ),
          ],
        ),
      ),
      position: Vector2(size.x / 2, size.y * 0.3),
      anchor: Anchor.center,
    );
    add(titleComponent);
    
    // サブタイトル
    final subtitleComponent = TextComponent(
      text: '〜謎の部屋からの脱出〜',
      textRenderer: TextPaint(
        style: TextStyle(
          color: Colors.white70,
          fontSize: size.y * 0.03,
          fontFamily: 'Noto Sans JP',
        ),
      ),
      position: Vector2(size.x / 2, size.y * 0.4),
      anchor: Anchor.center,
    );
    add(subtitleComponent);
    
    // スタートボタン
    final buttonSize = Vector2(size.x * 0.4, size.y * 0.08);
    final buttonPosition = Vector2(size.x / 2 - buttonSize.x / 2, size.y * 0.55);
    
    // ボタン背景
    final buttonBg = RectangleComponent(
      size: buttonSize,
      position: buttonPosition,
      paint: Paint()..color = Colors.green.shade600,
    );
    add(buttonBg);
    
    // ボタンテキスト
    final buttonText = TextComponent(
      text: 'ゲーム開始',
      textRenderer: TextPaint(
        style: TextStyle(
          color: Colors.white,
          fontSize: size.y * 0.04,
          fontWeight: FontWeight.bold,
          fontFamily: 'Noto Sans JP',
        ),
      ),
      position: Vector2(size.x / 2, buttonPosition.y + buttonSize.y / 2),
      anchor: Anchor.center,
    );
    add(buttonText);
    
    // ボタンクリック領域
    final startButton = StartButtonComponent(
      size: buttonSize,
      position: buttonPosition,
      onPressed: () {
        _showStartScreen = false;
        _onStartButtonPressed();
      },
    );
    add(startButton);
    
    // 説明文
    final instructionComponent = TextComponent(
      text: '制限時間内に謎を解いて部屋から脱出しよう！',
      textRenderer: TextPaint(
        style: TextStyle(
          color: Colors.white60,
          fontSize: size.y * 0.025,
          fontFamily: 'Noto Sans JP',
        ),
      ),
      position: Vector2(size.x / 2, size.y * 0.75),
      anchor: Anchor.center,
    );
    add(instructionComponent);
  }
  
  /// スタートボタン押下処理
  void _onStartButtonPressed() {
    // 画面をクリアして部屋を再セットアップ
    removeAll(children);
    setupRoom().then((_) {
      _setupGameUI();
      startGame();
    });
  }
  
  /// ゲーム開始
  @override
  void startGame() {
    _gameActive = true;
    _showStartScreen = false;
    _showClearScreen = false;
    
    // タイマー開始
    timerManager.getTimer('gameTimer')?.start();
    
    // インベントリUI表示
    _updateInventoryUI();
    
    // startUIを非表示にする
    overlays.remove('startUI');
    overlays.add('gameUI');
  }
  
  /// ホットスポットタップ処理
  void _onHotspotTapped(String hotspotId) {
    if (!_gameActive) return;
    
    final hotspot = _hotspots[hotspotId];
    if (hotspot == null) return;
    
    // インタラクション実行
    _interactionManager.interact(hotspotId, _selectedItem);
    
    // 音効果
    audioManager.playSfx('interaction');
    
    // カスタムインタラクション
    onHotspotTapped(hotspotId, _selectedItem);
  }
  
  /// ホットスポットインタラクション処理
  void _onHotspotInteraction(String hotspotId, String? itemId) {
    // エリアごとに異なるインタラクション処理
    switch (_currentAreaId) {
      case 'main':
        _handleMainRoomInteraction(hotspotId, itemId);
        break;
      case 'storage':
        _handleStorageRoomInteraction(hotspotId, itemId);
        break;
      case 'office':
        _handleOfficeRoomInteraction(hotspotId, itemId);
        break;
      default:
        _handleDefaultInteraction(hotspotId, itemId);
        break;
    }
  }
  
  /// メインルームのインタラクション処理
  void _handleMainRoomInteraction(String hotspotId, String? itemId) {
    switch (hotspotId) {
      case 'door':
        if (itemId == 'key') {
          _showMessage('鍵を使って脱出成功！');
          _escapeSuccessful();
        } else if (itemId == null) {
          _showMessage('まず鍵を選択してからドアをクリック');
        } else {
          final itemName = _items[itemId]?.name ?? itemId;
          _showMessage('${itemName}では開きません。鍵が必要です。');
        }
        break;
        
      case 'bookshelf':
        if (_inventory.hasItem('tool')) {
          // 調査モーダル表示（すでに調査済み）
          showModal(ModalConfig(
            type: ModalType.inspection,
            title: '本棚',
            content: '本の間を詳しく調べましたが、他に使えそうなものは見つかりませんでした。',
          ));
        } else {
          // 調査モーダル表示（アイテム発見）
          showModal(ModalConfig(
            type: ModalType.inspection,
            title: '本棚',
            content: '本の間に何かが挟まっています...ドライバーを発見しました！',
            onConfirm: () {
              _inventory.addItem('tool');
              _showMessage('ドライバーを発見！');
              _updateInventoryUI();
              _updateHotspotState('bookshelf', true); // 本棚状態更新
              hideModal();
            },
          ));
        }
        break;
    }
  }
  
  /// 物置部屋のインタラクション処理
  void _handleStorageRoomInteraction(String hotspotId, String? itemId) {
    switch (hotspotId) {
      case 'old_box':
        if (_inventory.hasItem('code')) {
          _showMessage('すでに調べました');
        } else if (_selectedItem == 'tool') {
          _inventory.addItem('code');
          _showMessage('ドライバーで箱をこじ開けてメモを発見！');
          _updateInventoryUI();
          _updateHotspotState('old_box', true); // 箱状態更新
        } else {
          _showMessage('しっかり閉まっている。何かで開ける必要がある');
        }
        break;
        
      case 'shelf':
        _showMessage('色々なガラクタがあるが、使えそうなものはない');
        break;
    }
  }
  
  /// オフィスのインタラクション処理
  void _handleOfficeRoomInteraction(String hotspotId, String? itemId) {
    switch (hotspotId) {
      case 'desk':
        _showMessage('引き出しは固く閉まっている');
        break;
        
      case 'safe':
        if (_inventory.hasItem('code') && _inventory.hasItem('tool')) {
          // 数字パズルモーダルを表示
          showModal(ModalConfig(
            type: ModalType.puzzle,
            title: '金庫の暗証番号',
            content: 'メモに書かれた4桁の数字を入力してください\\n（ヒント: 1234）',
            data: {
              'puzzleType': 'number',
              'answer': '1234',
              'puzzleId': 'safe',
            },
            onConfirm: () {
              _solvePuzzle('safe');
              hideModal();
            },
          ));
        } else if (!_inventory.hasItem('code')) {
          _showMessage('数字の組み合わせが必要');
        } else if (!_inventory.hasItem('tool')) {
          _showMessage('ドライバーで金庫のネジを外す必要がある');
        }
        break;
    }
  }
  
  /// デフォルトのインタラクション処理
  void _handleDefaultInteraction(String hotspotId, String? itemId) {
    switch (hotspotId) {
      case 'door':
        if (itemId == 'key') {
          _showMessage('鍵を使って脱出成功！');
          _escapeSuccessful();
        } else {
          _showMessage('鍵が必要です');
        }
        break;
        
      default:
        _showMessage('何も起こらなかった');
        break;
    }
  }
  
  /// パズル解決
  void _solvePuzzle(String puzzleId) {
    switch (puzzleId) {
      case 'safe':
        _puzzlesSolved++;
        _inventory.addItem('key');
        _showMessage('金庫が開いた！鍵を入手！');
        _updateInventoryUI();
        _updateHotspotState('safe', true); // 金庫状態更新
        
        // パズル解決効果音
        audioManager.playSfx('puzzle_solved');
        
        onPuzzleSolved(puzzleId);
        break;
    }
  }
  
  /// アイテム選択処理
  void _onItemSelected(String itemId) {
    // 既に選択されているアイテムの場合：モーダル表示
    if (_selectedItem == itemId) {
      final item = _items[itemId];
      if (item != null) {
        showModal(ModalConfig(
          type: ModalType.item,
          title: item.name,
          content: item.description,
          data: {'itemId': itemId},
        ));
      }
      return;
    }
    
    // 選択されていないアイテムの場合：選択処理
    // 新しいアイテムを選択（前の選択は自動解除）
    _selectedItem = itemId;
    
    // 選択状態に応じたメッセージ表示
    if (_selectedItem != null) {
      final itemName = _items[_selectedItem]?.name ?? _selectedItem;
      _showMessage('$itemName を選択しました');
    } else {
      _showMessage('選択を解除しました');
    }
    
    onItemSelected(_selectedItem);
    
    // UI更新を遅延実行（タップシーケンス完了後に実行）
    Future.delayed(const Duration(milliseconds: 100), () {
      _updateInventoryUI();
    });
  }
  
  /// 脱出成功
  void _escapeSuccessful() {
    stateProvider.changeState(EscapeRoomState.escaped);
    _gameActive = false;
    
    // 全タイマー停止
    timerManager.stopAllTimers();
    
    // 成功効果音
    audioManager.playSfx('victory');
    
    onEscapeSuccessful(_puzzlesSolved, _timeRemaining);
    
    // クリア画面を表示
    _showClearScreen = true;
    _showClearScreenUI();
  }
  
  /// クリア画面表示（スマートフォン縦型レイアウト対応）
  void _showClearScreenUI() {
    // インベントリエリアのみクリア（メニューバーは残す）
    final componentsToRemove = <Component>[];
    
    for (final component in children) {
      // インベントリエリア（priority 1020-1040）とゲームエリアのみクリア
      if ((component.priority >= 1020 && component.priority <= 1040) ||
          (component.priority < 1100 && component.priority > 0)) {
        componentsToRemove.add(component);
      }
    }
    
    for (final component in componentsToRemove) {
      component.removeFromParent();
    }
    
    // クリア画面背景（ゲームエリア+インベントリエリアのみ）
    final clearAreaHeight = _gameAreaSize.y + _inventorySize.y;
    add(RectangleComponent(
      size: Vector2(_containerSize.x, clearAreaHeight),
      position: _gameAreaPosition,
      paint: Paint()..color = Colors.black.withValues(alpha: 0.9),
    ));
    
    // 成功メッセージ（コンテナ内に配置）
    final successMessage = TextComponent(
      text: '脱出成功！',
      textRenderer: TextPaint(
        style: TextStyle(
          color: Colors.yellow,
          fontSize: _containerSize.y * 0.08,
          fontWeight: FontWeight.bold,
          fontFamily: 'Noto Sans JP',
          shadows: const [
            Shadow(
              color: Colors.orange,
              offset: Offset(3, 3),
              blurRadius: 10,
            ),
          ],
        ),
      ),
      position: Vector2(_containerOffset.x + _containerSize.x / 2, 
                       _containerOffset.y + _containerSize.y * 0.25),
      anchor: Anchor.center,
    );
    add(successMessage);
    
    // クリアタイム表示（コンテナ内に配置）
    final clearTime = 240 - _timeRemaining;
    final minutes = (clearTime / 60).floor();
    final seconds = (clearTime % 60).floor();
    final timeText = '${minutes}分${seconds}秒でクリア！';
    
    final timeComponent = TextComponent(
      text: timeText,
      textRenderer: TextPaint(
        style: TextStyle(
          color: Colors.white,
          fontSize: _containerSize.y * 0.035,
          fontFamily: 'Noto Sans JP',
        ),
      ),
      position: Vector2(_containerOffset.x + _containerSize.x / 2, 
                       _containerOffset.y + _containerSize.y * 0.4),
      anchor: Anchor.center,
    );
    add(timeComponent);
    
    // パズル解決数表示（コンテナ内に配置）
    final puzzleComponent = TextComponent(
      text: '解いた謎: $_puzzlesSolved 個',
      textRenderer: TextPaint(
        style: TextStyle(
          color: Colors.white,
          fontSize: _containerSize.y * 0.03,
          fontFamily: 'Noto Sans JP',
        ),
      ),
      position: Vector2(_containerOffset.x + _containerSize.x / 2, 
                       _containerOffset.y + _containerSize.y * 0.48),
      anchor: Anchor.center,
    );
    add(puzzleComponent);
    
    // 評価メッセージ（コンテナ内に配置）
    String evaluation;
    if (clearTime < 60) {
      evaluation = '素晴らしい！プロの脱出マスターです！';
    } else if (clearTime < 120) {
      evaluation = '優秀！謎解きの才能があります！';
    } else if (clearTime < 180) {
      evaluation = '良い感じ！次はもっと早く脱出できるかも？';
    } else {
      evaluation = 'ギリギリ脱出成功！次回も頑張ろう！';
    }
    
    final evaluationComponent = TextComponent(
      text: evaluation,
      textRenderer: TextPaint(
        style: TextStyle(
          color: Colors.lightBlue,
          fontSize: _containerSize.y * 0.028,
          fontFamily: 'Noto Sans JP',
        ),
      ),
      position: Vector2(_containerOffset.x + _containerSize.x / 2, 
                       _containerOffset.y + _containerSize.y * 0.56),
      anchor: Anchor.center,
    );
    add(evaluationComponent);
    
    // ヒント：上部メニューのホームボタンで戻れることを表示
    final hintComponent = TextComponent(
      text: '上部の「ホーム」ボタンでタイトルに戻れます',
      textRenderer: TextPaint(
        style: TextStyle(
          color: Colors.grey.shade400,
          fontSize: _containerSize.y * 0.025,
          fontFamily: 'Noto Sans JP',
        ),
      ),
      position: Vector2(_containerOffset.x + _containerSize.x / 2, 
                       _containerOffset.y + _containerSize.y * 0.75),
      anchor: Anchor.center,
    );
    add(hintComponent);
  }
  
  /// タイトルに戻る処理
  void _onBackToTitlePressed() {
    // ゲーム状態リセット
    _showClearScreen = false;
    _showStartScreen = true;
    resetGame();
  }
  
  /// 時間切れ
  void _onTimeUp() {
    stateProvider.changeState(EscapeRoomState.timeUp);
    _gameActive = false;
    
    onTimeUp(_puzzlesSolved);
  }
  
  /// モーダル表示
  void showModal(ModalConfig config) {
    if (_modalVisible) return;
    
    _modalVisible = true;
    _activeModal = ModalComponent(
      config: config,
      containerSize: _containerSize,
      containerOffset: _containerOffset,
      onClose: () => hideModal(),
    );
    
    if (_activeModal != null) {
      add(_activeModal!);
    }
  }
  
  /// モーダル非表示
  void hideModal() {
    if (!_modalVisible || _activeModal == null) return;
    
    _modalVisible = false;
    _activeModal!.removeFromParent();
    _activeModal = null;
  }

  /// メッセージ表示
  void _showMessage(String message) {
    // カスタムメッセージ表示
    onMessageShow(message);
    
    // ゲーム内メッセージ表示（UI）
    _displayGameMessage(message);
  }
  
  /// ゲーム内メッセージ表示（テキストオーバーフロー対策）
  void _displayGameMessage(String message) {
    // 既存のメッセージテキストを削除（安全な方法）
    final messagesToRemove = <Component>[];
    for (final component in children) {
      if (component.priority >= 2000 && component.priority <= 2010) {
        // メッセージ専用プライオリティ範囲で削除
        messagesToRemove.add(component);
      }
    }
    for (final component in messagesToRemove) {
      component.removeFromParent();
    }
    
    // UTF-8文字化け対策：文字列をUTF-8で強制エンコード
    final utf8Message = String.fromCharCodes(message.runes);
    
    // メッセージ表示エリア（ゲーム領域内の上部に表示）
    final messageWidth = _gameAreaSize.x * 0.9;
    final messageHeight = _gameAreaSize.y * 0.15;
    final messagePosition = Vector2(_gameAreaPosition.x + _gameAreaSize.x * 0.05, 
                                   _gameAreaPosition.y + _gameAreaSize.y * 0.02);
    
    // メッセージ背景
    final messageBg = RectangleComponent(
      size: Vector2(messageWidth, messageHeight),
      position: messagePosition,
      paint: Paint()..color = Colors.black.withValues(alpha: 0.85),
    );
    messageBg.priority = 2000;
    add(messageBg);
    
    // テキストサイズ計算（オーバーフロー防止）
    final maxTextWidth = messageWidth * 0.9;
    var fontSize = _containerSize.y * 0.025;
    
    // 長いメッセージの場合、フォントサイズを調整
    if (utf8Message.length > 20) {
      fontSize = _containerSize.y * 0.02;
    }
    if (utf8Message.length > 30) {
      fontSize = _containerSize.y * 0.018;
    }
    
    // UTF-8対応メッセージ表示（コンテナ内制限）
    final messageComponent = TextComponent(
      text: utf8Message,
      textRenderer: TextPaint(
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          fontFamily: 'Noto Sans JP',
          shadows: const [
            Shadow(
              color: Colors.black,
              offset: Offset(2, 2),
              blurRadius: 4,
            ),
          ],
        ),
      ),
      position: Vector2(messagePosition.x + messageWidth / 2, 
                       messagePosition.y + messageHeight / 2),
      anchor: Anchor.center,
    );
    messageComponent.priority = 2001;
    add(messageComponent);
    
    // 1.5秒後に消去
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (messageComponent.isMounted) {
        messageComponent.removeFromParent();
      }
      if (messageBg.isMounted) {
        messageBg.removeFromParent();
      }
    });
  }
  
  // ゲームイベント（オーバーライド可能）
  void onHotspotTapped(String hotspotId, String? selectedItem) {
    // ホットスポットタップ時の処理（カスタマイズ可能）
  }
  
  void onItemSelected(String? itemId) {
    // アイテム選択時の処理（カスタマイズ可能）
  }
  
  void onPuzzleSolved(String puzzleId) {
    // パズル解決時の処理（カスタマイズ可能）
  }
  
  void onEscapeSuccessful(int puzzlesSolved, double timeRemaining) {
    // 脱出成功時の処理（カスタマイズ可能）
  }
  
  void onTimeUp(int puzzlesSolved) {
    // 時間切れ時の処理（カスタマイズ可能）
  }
  
  void onMessageShow(String message) {
    // メッセージ表示時の処理（カスタマイズ可能）
  }
  
  // 公開メソッド（UI用）
  void showInventory() {
    stateProvider.changeState(EscapeRoomState.inventory);
  }
  
  void hideInventory() {
    stateProvider.changeState(EscapeRoomState.exploring);
  }
  
  /// ホットスポット状態を更新（画像差し替え）
  Future<void> _updateHotspotState(String hotspotId, bool cleared) async {
    _hotspotStates[hotspotId] = cleared;
    
    final hotspot = _hotspots[hotspotId];
    if (hotspot != null) {
      final imagePath = _getStateImagePath(hotspotId, cleared);
      await hotspot.updateImage(imagePath);
    }
  }
  
  /// 状態に応じた画像パス取得（後で実際の画像ファイルパスに差し替え）
  String _getStateImagePath(String hotspotId, bool cleared) {
    if (cleared) {
      switch (hotspotId) {
        case 'bookshelf':
          return 'hotspots/bookshelf_empty.png'; // 本棚（アイテム取得後）
        case 'old_box':
          return 'hotspots/box_opened.png'; // 箱（開封後）
        case 'safe':
          return 'hotspots/safe_opened.png'; // 金庫（開錠後）
        default:
          return 'hotspots/${hotspotId}_cleared.png';
      }
    } else {
      switch (hotspotId) {
        case 'bookshelf':
          return 'hotspots/bookshelf_full.png'; // 本棚（初期状態）
        case 'old_box':
          return 'hotspots/box_closed.png'; // 箱（閉じた状態）
        case 'safe':
          return 'hotspots/safe_closed.png'; // 金庫（施錠状態）
        default:
          return 'hotspots/${hotspotId}_initial.png';
      }
    }
  }
  
  @override
  void resetGame() {
    stateProvider.changeState(EscapeRoomState.exploring);
    _gameActive = false;
    _puzzlesSolved = 0;
    _selectedItem = null;
    _inventory.clear();
    _timeRemaining = gameConfig.timeLimit.inSeconds.toDouble();
    
    timerManager.stopAllTimers();
    
    // 画面状態リセット
    _showStartScreen = true;
    _showClearScreen = false;
    
    // UIクリアして再セットアップ
    removeAll(children);
    setupRoom().then((_) {
      setupGame();
    });
  }
  
  /// 時間フォーマット（UI表示用）
  String formatTime(double seconds) {
    final minutes = (seconds / 60).floor();
    final remainingSeconds = (seconds % 60).floor();
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
  
  /// アイテムの色を取得
  Color _getItemColor(String itemId) {
    switch (itemId) {
      case 'key':
        return Colors.amber.shade600; // 金色
      case 'code':
        return Colors.blue.shade600; // 青色
      case 'tool':
        return Colors.red.shade600; // 赤色
      default:
        return Colors.grey.shade600; // デフォルト灰色
    }
  }
  
  /// アイテムのアイコン文字を取得
  String _getItemIcon(String itemId) {
    switch (itemId) {
      case 'key':
        return '🔑'; // 鍵
      case 'code':
        return '📝'; // メモ
      case 'tool':
        return '🔧'; // ツール
      default:
        return '?'; // 不明
    }
  }
  
  /// エリアごとの背景色を取得
  Color _getAreaColor(String areaId) {
    switch (areaId) {
      case 'main':
        return Colors.brown.shade200; // メインルーム: 茶色
      case 'storage':
        return Colors.blueGrey.shade300; // 物置部屋: 青灰色
      case 'office':
        return Colors.green.shade200; // オフィス: 緑色
      default:
        return Colors.brown.shade200; // デフォルト: 茶色
    }
  }
}

/// インベントリマネージャー
class InventoryManager {
  final int maxItems;
  final Function(String) onItemSelected;
  final List<String> _items = [];
  
  InventoryManager({
    required this.maxItems,
    required this.onItemSelected,
  });
  
  List<String> get items => List.unmodifiable(_items);
  
  bool hasItem(String itemId) => _items.contains(itemId);
  
  bool addItem(String itemId) {
    if (_items.length >= maxItems || _items.contains(itemId)) {
      return false;
    }
    
    _items.add(itemId);
    return true;
  }
  
  bool removeItem(String itemId) {
    return _items.remove(itemId);
  }
  
  void clear() {
    _items.clear();
  }
  
  void selectItem(String itemId) {
    if (hasItem(itemId)) {
      onItemSelected(itemId);
    }
  }
}

/// インタラクションマネージャー
class InteractionManager {
  final Function(String, String?) onInteraction;
  
  InteractionManager({
    required this.onInteraction,
  });
  
  void interact(String hotspotId, String? itemId) {
    onInteraction(hotspotId, itemId);
  }
}

/// ホットスポットコンポーネント
class HotspotComponent extends PositionComponent with TapCallbacks {
  final String id;
  final String name;
  final String description;
  final Function(String) onTapped;
  SpriteComponent? _imageComponent;
  String? _currentImagePath;
  
  HotspotComponent({
    required this.id,
    required this.name,
    required this.description,
    required this.onTapped,
  });
  
  @override
  Future<void> onLoad() async {
    // ホットスポット名前ラベルのみ表示（枠線なし）
    final utf8Name = String.fromCharCodes(name.runes);
    final textComponent = TextComponent(
      text: utf8Name,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          fontFamily: 'Noto Sans JP',
          shadows: [
            Shadow(
              color: Colors.black,
              offset: Offset(2, 2),
              blurRadius: 4,
            ),
          ],
        ),
      ),
      position: Vector2(5, 5),
    );
    add(textComponent);
    
    // 背景色（わずかに見える程度）
    add(RectangleComponent(
      size: size,
      paint: Paint()..color = Colors.white.withValues(alpha: 0.1),
      position: Vector2.zero(),
    ));
  }
  
  @override
  void onTapUp(TapUpEvent event) {
    onTapped(id);
  }
  
  /// ホットスポット画像を更新（状態変更時）
  Future<void> updateImage(String imagePath) async {
    if (_currentImagePath == imagePath) return;
    
    // 既存の画像コンポーネントを削除
    if (_imageComponent != null) {
      _imageComponent!.removeFromParent();
    }
    
    try {
      // 新しい画像を読み込み（エラー時はスキップ）
      final sprite = await Sprite.load(imagePath);
      _imageComponent = SpriteComponent(
        sprite: sprite,
        size: size,
        position: Vector2.zero(),
      );
      _imageComponent!.priority = -1; // テキストより背景に表示
      add(_imageComponent!);
      _currentImagePath = imagePath;
    } catch (e) {
      // 画像読み込み失敗時はプレースホルダー色で表示
      final placeholder = RectangleComponent(
        size: size,
        position: Vector2.zero(),
        paint: Paint()..color = _getStateColor(),
      );
      placeholder.priority = -1;
      add(placeholder);
    }
  }
  
  /// 状態に応じたプレースホルダー色取得
  Color _getStateColor() {
    switch (id) {
      case 'bookshelf':
        return Colors.brown.shade400; // 本棚: 茶色
      case 'old_box':
        return Colors.grey.shade600; // 箱: 灰色
      case 'safe':
        return Colors.blueGrey.shade700; // 金庫: 青灰色
      default:
        return Colors.grey.shade400;
    }
  }
}

/// クリック可能なインベントリアイテム
class ClickableInventoryItem extends RectangleComponent with TapCallbacks {
  final String itemId;
  final Function(String) onTapped;
  
  ClickableInventoryItem({
    required this.itemId,
    required this.onTapped,
    super.size,
    super.position,
  }) : super(
    paint: Paint()..color = Colors.transparent, // 透明だがクリック可能
  );
  
  @override
  void onTapDown(TapDownEvent event) {
    // インベントリアイテムタップダウン
  }
  
  @override
  void onTapUp(TapUpEvent event) {
    // インベントリアイテムクリック
    onTapped(itemId);
  }
  
  @override
  void onTapCancel(TapCancelEvent event) {
    // インベントリアイテムタップキャンセル
  }
}

/// モーダルコンポーネント
class ModalComponent extends PositionComponent with TapCallbacks {
  final ModalConfig config;
  final Vector2 containerSize;
  final Vector2 containerOffset;
  final VoidCallback onClose;
  late Vector2 modalSize;
  late Vector2 modalPosition;
  
  ModalComponent({
    required this.config,
    required this.containerSize,
    required this.containerOffset,
    required this.onClose,
  });
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // モーダルサイズ計算（画面の70%、正方形）
    final side = containerSize.x * 0.7;
    modalSize = Vector2(side, side);
    modalPosition = Vector2(
      containerOffset.x + (containerSize.x - modalSize.x) / 2,
      containerOffset.y + (containerSize.y - modalSize.y) / 2,
    );
    
    // オーバーレイ背景（全画面・タップ可能）
    final overlay = ModalOverlay(
      size: containerSize,
      position: containerOffset,
      onTapped: onClose,
    );
    overlay.priority = 3000;
    add(overlay);
    
    // モーダル背景
    final modalBg = RectangleComponent(
      size: modalSize,
      position: modalPosition,
      paint: Paint()..color = Colors.white,
    );
    modalBg.priority = 3001;
    add(modalBg);
    
    // モーダル枠線
    final modalBorder = RectangleComponent(
      size: modalSize,
      position: modalPosition,
      paint: Paint()
        ..color = Colors.grey.shade800
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0,
    );
    modalBorder.priority = 3002;
    add(modalBorder);
    
    // タイトル
    final utf8Title = String.fromCharCodes(config.title.runes);
    final titleComponent = TextComponent(
      text: utf8Title,
      textRenderer: TextPaint(
        style: TextStyle(
          color: Colors.black,
          fontSize: modalSize.y * 0.06,
          fontWeight: FontWeight.bold,
          fontFamily: 'Noto Sans JP',
        ),
      ),
      position: Vector2(modalPosition.x + modalSize.x / 2, modalPosition.y + modalSize.y * 0.1),
      anchor: Anchor.center,
    );
    titleComponent.priority = 3003;
    add(titleComponent);
    
    // クローズボタン（右上角）
    final closeButtonSize = Vector2(modalSize.x * 0.1, modalSize.x * 0.1);
    final closeButton = CloseButtonComponent(
      size: closeButtonSize,
      position: Vector2(modalPosition.x + modalSize.x - closeButtonSize.x - modalSize.x * 0.02,
                       modalPosition.y + modalSize.y * 0.02),
      onPressed: onClose,
    );
    closeButton.priority = 3004;
    add(closeButton);
    
    // モーダル種類別コンテンツ
    await _addModalContent();
  }
  
  Future<void> _addModalContent() async {
    final contentArea = Vector2(modalSize.x * 0.9, modalSize.y * 0.65);
    final contentPosition = Vector2(modalPosition.x + modalSize.x * 0.05,
                                   modalPosition.y + modalSize.y * 0.2);
    
    switch (config.type) {
      case ModalType.item:
        await _addItemContent(contentPosition, contentArea);
        break;
      case ModalType.puzzle:
        await _addPuzzleContent(contentPosition, contentArea);
        break;
      case ModalType.inspection:
        await _addInspectionContent(contentPosition, contentArea);
        break;
    }
  }
  
  Future<void> _addItemContent(Vector2 position, Vector2 size) async {
    // アイテムアイコン（大きく中央表示）
    final itemId = config.data['itemId'] as String? ?? '';
    final itemIcon = _getItemIcon(itemId);
    
    final iconComponent = TextComponent(
      text: itemIcon,
      textRenderer: TextPaint(
        style: TextStyle(
          fontSize: size.y * 0.4, // アイコンを大きく表示
        ),
      ),
      position: Vector2(position.x + size.x / 2, position.y + size.y / 2), // 中央配置
      anchor: Anchor.center,
    );
    iconComponent.priority = 3005;
    add(iconComponent);
  }
  
  Future<void> _addPuzzleContent(Vector2 position, Vector2 size) async {
    // パズル説明削除 - 数字入力パッドのみ表示
    
    // パズル操作UI（例：数字入力）
    if (config.data['puzzleType'] == 'number') {
      await _addNumberPuzzleUI(position, size);
    }
  }
  
  Future<void> _addNumberPuzzleUI(Vector2 position, Vector2 size) async {
    // 入力表示エリア
    final inputDisplayBg = RectangleComponent(
      size: Vector2(size.x * 0.6, size.y * 0.1),
      position: Vector2(position.x + size.x * 0.2, position.y + size.y * 0.35),
      paint: Paint()..color = Colors.grey.shade200,
    );
    inputDisplayBg.priority = 3005;
    add(inputDisplayBg);
    
    // 入力テキスト表示
    final inputDisplay = TextComponent(
      text: '____',
      textRenderer: TextPaint(
        style: TextStyle(
          color: Colors.black,
          fontSize: size.y * 0.06,
          fontWeight: FontWeight.bold,
          fontFamily: 'monospace',
        ),
      ),
      position: Vector2(position.x + size.x * 0.5, position.y + size.y * 0.4),
      anchor: Anchor.center,
    );
    inputDisplay.priority = 3006;
    add(inputDisplay);
    
    // 数字入力ボタングリッド（3x3 + 0）
    final buttonSize = size.x * 0.15;
    final spacing = size.x * 0.05;
    final gridStartX = position.x + (size.x - (buttonSize * 3 + spacing * 2)) / 2;
    final gridStartY = position.y + size.y * 0.5;
    
    for (int i = 1; i <= 9; i++) {
      final row = (i - 1) ~/ 3;
      final col = (i - 1) % 3;
      final buttonPos = Vector2(
        gridStartX + col * (buttonSize + spacing),
        gridStartY + row * (buttonSize + spacing),
      );
      
      final numberButton = NumberButton(
        number: i,
        size: Vector2(buttonSize, buttonSize),
        position: buttonPos,
        onPressed: (number) => _onNumberPressed(number),
      );
      numberButton.priority = 3006;
      add(numberButton);
    }
    
    // 0ボタン
    final zeroButton = NumberButton(
      number: 0,
      size: Vector2(buttonSize, buttonSize),
      position: Vector2(gridStartX + buttonSize + spacing, gridStartY + 3 * (buttonSize + spacing)),
      onPressed: (number) => _onNumberPressed(number),
    );
    zeroButton.priority = 3006;
    add(zeroButton);
  }
  
  Future<void> _addInspectionContent(Vector2 position, Vector2 size) async {
    // 調査対象の詳細説明削除・確認ボタン削除 - タイトルとクローズボタンのみ表示
  }
  
  String _getItemIcon(String itemId) {
    switch (itemId) {
      case 'key':
        return '🔑';
      case 'code':
        return '📝';
      case 'tool':
        return '🔧';
      default:
        return '📦';
    }
  }
  
  String _currentInput = '';
  
  void _onNumberPressed(int number) {
    // 数字ボタン押下処理（パズル用）
    if (_currentInput.length < 4) {
      _currentInput += number.toString();
      _updateInputDisplay();
      
      // 4桁入力完了時に自動チェック
      if (_currentInput.length == 4) {
        _checkAnswer();
      }
    }
  }
  
  void _updateInputDisplay() {
    // 入力表示を更新（既存の数字表示コンポーネントを更新）
    final displayText = _currentInput.padRight(4, '_');
    
    // 入力表示テキストコンポーネントを更新
    for (final child in children) {
      if (child is TextComponent && child.priority == 3006 && child.anchor == Anchor.center) {
        child.text = displayText;
        break;
      }
    }
    
    print('Current input: $_currentInput');
  }
  
  void _checkAnswer() {
    final correctAnswer = config.data['answer'] as String? ?? '';
    
    if (_currentInput == correctAnswer) {
      // 正解
      print('Puzzle solved!');
      if (config.onConfirm != null) {
        config.onConfirm!();
      }
    } else {
      // 不正解
      _currentInput = '';
      _updateInputDisplay();
      print('Wrong answer. Try again.');
    }
  }
  
  @override
  void onTapUp(TapUpEvent event) {
    // オーバーレイ部分をタップした場合はモーダルを閉じる
    final tapPosition = event.localPosition;
    if (!modalSize.toRect().translate(modalPosition.x, modalPosition.y).contains(tapPosition.toOffset())) {
      onClose();
    }
  }
}

/// クローズボタンコンポーネント
class CloseButtonComponent extends PositionComponent with TapCallbacks {
  final VoidCallback onPressed;
  
  CloseButtonComponent({
    required this.onPressed,
    super.size,
    super.position,
  });
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // ボタン背景
    add(RectangleComponent(
      size: size,
      paint: Paint()..color = Colors.red.shade600,
    ));
    
    // Xマーク
    add(TextComponent(
      text: '✕',
      textRenderer: TextPaint(
        style: TextStyle(
          color: Colors.white,
          fontSize: size.y * 0.6,
          fontWeight: FontWeight.bold,
        ),
      ),
      position: size / 2,
      anchor: Anchor.center,
    ));
  }
  
  @override
  void onTapUp(TapUpEvent event) {
    onPressed();
  }
}

/// 確認ボタンコンポーネント
class ConfirmButton extends PositionComponent with TapCallbacks {
  final String text;
  final VoidCallback onPressed;
  
  ConfirmButton({
    required this.text,
    required this.onPressed,
    super.size,
    super.position,
  });
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // ボタン背景
    add(RectangleComponent(
      size: size,
      paint: Paint()..color = Colors.green.shade600,
    ));
    
    // ボタンテキスト
    add(TextComponent(
      text: text,
      textRenderer: TextPaint(
        style: TextStyle(
          color: Colors.white,
          fontSize: size.y * 0.4,
          fontWeight: FontWeight.bold,
          fontFamily: 'Noto Sans JP',
        ),
      ),
      position: size / 2,
      anchor: Anchor.center,
    ));
  }
  
  @override
  void onTapUp(TapUpEvent event) {
    onPressed();
  }
}

/// 数字ボタンコンポーネント
class NumberButton extends PositionComponent with TapCallbacks {
  final int number;
  final Function(int) onPressed;
  
  NumberButton({
    required this.number,
    required this.onPressed,
    super.size,
    super.position,
  });
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // ボタン背景
    add(RectangleComponent(
      size: size,
      paint: Paint()..color = Colors.blue.shade600,
    ));
    
    // 数字
    add(TextComponent(
      text: number.toString(),
      textRenderer: TextPaint(
        style: TextStyle(
          color: Colors.white,
          fontSize: size.y * 0.5,
          fontWeight: FontWeight.bold,
        ),
      ),
      position: size / 2,
      anchor: Anchor.center,
    ));
  }
  
  @override
  void onTapUp(TapUpEvent event) {
    onPressed(number);
  }
}

/// スタートボタンコンポーネント
class StartButtonComponent extends RectangleComponent with TapCallbacks {
  final VoidCallback onPressed;
  
  StartButtonComponent({
    required this.onPressed,
    super.size,
    super.position,
  }) : super(
    paint: Paint()..color = Colors.transparent,
  );
  
  @override
  void onTapUp(TapUpEvent event) {
    onPressed();
  }
}

/// モーダルオーバーレイ（背景タップでモーダル閉じる）
class ModalOverlay extends RectangleComponent with TapCallbacks {
  final VoidCallback onTapped;
  
  ModalOverlay({
    required this.onTapped,
    super.size,
    super.position,
  }) : super(
    paint: Paint()..color = Colors.black.withValues(alpha: 0.7),
  );
  
  @override
  void onTapUp(TapUpEvent event) {
    onTapped();
  }
}