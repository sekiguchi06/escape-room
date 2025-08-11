import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import '../../core/configurable_game.dart';
import '../../state/game_state_system.dart';
import '../../timer/flame_timer_system.dart';

/// 脱出ゲーム設定
class EscapeRoomConfig {
  final Duration timeLimit;
  final int maxInventoryItems;
  final List<String> requiredItems;
  final String roomTheme;
  final int difficultyLevel;
  
  const EscapeRoomConfig({
    this.timeLimit = const Duration(minutes: 10),
    this.maxInventoryItems = 8,
    this.requiredItems = const ['key', 'code', 'tool'],
    this.roomTheme = 'office',
    this.difficultyLevel = 1,
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

/// 5分で作成可能な脱出ゲームテンプレート
abstract class QuickEscapeRoomTemplate extends ConfigurableGame<EscapeRoomState, EscapeRoomConfig> 
    with TapCallbacks {
  // ゲームシステム
  late InventoryManager _inventory;
  late InteractionManager _interactionManager;
  final Map<String, HotspotComponent> _hotspots = {};
  final Map<String, GameItem> _items = {};
  
  // ゲーム状態
  double _timeRemaining = 0;
  int _puzzlesSolved = 0;
  bool _gameActive = false;
  String? _selectedItem;
  
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
  
  /// 背景セットアップ
  Future<void> _setupBackground() async {
    // レスポンシブデザイン: 画面比率ベースの領域計算
    final safeAreaMargin = Vector2(size.x * 0.05, size.y * 0.12); // 画面の5%,12%をマージン
    final gameAreaSize = Vector2(size.x * 0.9, size.y * 0.73); // 画面の90%,73%をゲーム領域
    
    // シンプルな部屋背景（ゲームエリア内）
    final background = RectangleComponent(
      size: gameAreaSize,
      position: safeAreaMargin,
      paint: Paint()..color = Colors.brown.shade200,
    );
    add(background);
    
    // 床（ゲームエリア内）
    final floorHeight = size.y * 0.05; // 画面の5%を床の高さに
    final floor = RectangleComponent(
      size: Vector2(gameAreaSize.x, floorHeight),
      position: Vector2(safeAreaMargin.x, safeAreaMargin.y + gameAreaSize.y - floorHeight),
      paint: Paint()..color = Colors.brown.shade400,
    );
    add(floor);
    
    // 壁の装飾
    _addWallDecorations();
  }
  
  /// 壁の装飾追加
  void _addWallDecorations() {
    final safeAreaMargin = Vector2(size.x * 0.05, size.y * 0.12);
    final gameAreaSize = Vector2(size.x * 0.9, size.y * 0.73);
    
    // ドア（ゲームエリア内右下）- レスポンシブサイズ
    final doorSize = Vector2(size.x * 0.08, size.y * 0.12);
    final door = RectangleComponent(
      size: doorSize,
      position: Vector2(safeAreaMargin.x + gameAreaSize.x - doorSize.x - size.x * 0.02, 
                       safeAreaMargin.y + gameAreaSize.y - doorSize.y - size.y * 0.08),
      paint: Paint()..color = Colors.brown.shade600,
    );
    add(door);
    
    // 窓（ゲームエリア内左上）- レスポンシブサイズ
    final windowSize = Vector2(size.x * 0.12, size.y * 0.08);
    final window = RectangleComponent(
      size: windowSize,
      position: Vector2(safeAreaMargin.x + size.x * 0.03, safeAreaMargin.y + size.y * 0.03),
      paint: Paint()..color = Colors.lightBlue.shade200,
    );
    add(window);
  }
  
  /// ホットスポット配置
  Future<void> _setupHotspots() async {
    final safeAreaMargin = Vector2(size.x * 0.05, size.y * 0.12);
    final gameAreaSize = Vector2(size.x * 0.9, size.y * 0.73);
    
    // ドアのホットスポット（脱出口）- レスポンシブ配置
    final doorHotspotSize = Vector2(size.x * 0.1, size.y * 0.14);
    _addHotspot('door', 
                Vector2(safeAreaMargin.x + gameAreaSize.x - doorHotspotSize.x - size.x * 0.01, 
                       safeAreaMargin.y + gameAreaSize.y - doorHotspotSize.y - size.y * 0.07), 
                doorHotspotSize, 'ドア', 'ここから脱出できそうだ...');
    
    // 机のホットスポット - レスポンシブ配置
    final deskHotspotSize = Vector2(size.x * 0.14, size.y * 0.1);
    _addHotspot('desk', 
                Vector2(safeAreaMargin.x + gameAreaSize.x * 0.4, 
                       safeAreaMargin.y + gameAreaSize.y - deskHotspotSize.y - size.y * 0.05), 
                deskHotspotSize, '机', '何かが隠されているかも');
    
    // 本棚のホットスポット - レスポンシブ配置
    final bookshelfHotspotSize = Vector2(size.x * 0.1, size.y * 0.17);
    _addHotspot('bookshelf', 
                Vector2(safeAreaMargin.x + size.x * 0.03, 
                       safeAreaMargin.y + gameAreaSize.y - bookshelfHotspotSize.y - size.y * 0.03), 
                bookshelfHotspotSize, '本棚', '本の間に何かが挟まっている');
    
    // 金庫のホットスポット - レスポンシブ配置
    final safeHotspotSize = Vector2(size.x * 0.08, size.y * 0.08);
    _addHotspot('safe', 
                Vector2(safeAreaMargin.x + gameAreaSize.x - safeHotspotSize.x - size.x * 0.05, 
                       safeAreaMargin.y + size.y * 0.05), 
                safeHotspotSize, '金庫', '数字の組み合わせが必要');
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
    startGame();
  }
  
  /// ゲームUI初期化
  void _setupGameUI() {
    // タイマー表示
    final timerComponent = TextComponent(
      text: formatTime(_timeRemaining),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              color: Colors.black,
              offset: Offset(2, 2),
              blurRadius: 4,
            ),
          ],
        ),
      ),
      position: Vector2(size.x - 120, 20),
    );
    timerComponent.priority = 1000;
    add(timerComponent);
    
    // インベントリ表示エリア
    _updateInventoryUI();
  }
  
  /// ゲームUI更新
  void _updateGameUI() {
    // タイマー更新（安全な方法）
    for (final component in children) {
      if (component is TextComponent && 
          component.position.x > size.x - 150 && 
          component.position.y < 50) {
        component.text = formatTime(_timeRemaining);
      }
    }
    
    // インベントリ更新は選択時のみ実行（タイマー更新では実行しない）
    // _updateInventoryUI(); // コメントアウト：タイマー更新時の不要な再描画を防止
  }
  
  /// インベントリUI更新
  void _updateInventoryUI() {
    // 既存のインベントリUIを削除（安全な方法）
    final componentsToRemove = <Component>[];
    
    for (final component in children) {
      if ((component is RectangleComponent && component.position.y > size.y - 80) ||
          (component is TextComponent && component.position.y > size.y - 100) ||
          (component is ClickableInventoryItem)) {
        componentsToRemove.add(component);
      }
    }
    
    for (final component in componentsToRemove) {
      component.removeFromParent();
    }
    
    // インベントリ背景（画面下部の独立したUI領域）
    final inventoryBg = RectangleComponent(
      size: Vector2(size.x - 40, 50),
      position: Vector2(20, size.y - 80),
      paint: Paint()..color = Colors.black.withValues(alpha: 0.8),
    );
    inventoryBg.priority = 999;
    add(inventoryBg);
    
    // インベントリタイトル
    final titleComponent = TextComponent(
      text: 'インベントリ:',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.yellow,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      position: Vector2(25, size.y - 75),
    );
    titleComponent.priority = 1000;
    add(titleComponent);
    
    // アイテム表示（アイコン形式）
    if (_inventory.items.isNotEmpty) {
      for (int i = 0; i < _inventory.items.length; i++) {
        final item = _inventory.items[i];
        final isSelected = _selectedItem == item;
        final itemName = _items[item]?.name ?? item;
        
        // アイテムアイコン（正方形）
        final iconSize = 40.0;
        final iconPosition = Vector2(120 + i * 60, size.y - 80);
        
        // アイコン背景
        final iconBg = RectangleComponent(
          size: Vector2(iconSize, iconSize),
          position: iconPosition,
          paint: Paint()..color = _getItemColor(item),
        );
        iconBg.priority = 999;
        add(iconBg);
        
        // アイコン内のアイテム識別子（1文字）
        final iconText = TextComponent(
          text: _getItemIcon(item),
          textRenderer: TextPaint(
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          position: Vector2(iconPosition.x + 15, iconPosition.y + 12),
        );
        iconText.priority = 1001;
        add(iconText);
        
        // 選択フレーム（選択時のみ）
        if (isSelected) {
          final selectionFrame = RectangleComponent(
            size: Vector2(iconSize + 6, iconSize + 6),
            position: Vector2(iconPosition.x - 3, iconPosition.y - 3),
            paint: Paint()
              ..color = Colors.transparent
              ..style = PaintingStyle.stroke
              ..strokeWidth = 3.0
              ..color = Colors.yellow,
          );
          selectionFrame.priority = 1002;
          add(selectionFrame);
          
          // 選択時のアイテム名表示
          final nameDisplay = TextComponent(
            text: itemName,
            textRenderer: TextPaint(
              style: const TextStyle(
                color: Colors.yellow,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    color: Colors.black,
                    offset: Offset(1, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
            ),
            position: Vector2(iconPosition.x - 10, iconPosition.y - 20),
          );
          nameDisplay.priority = 1003;
          add(nameDisplay);
        }
        
        // クリック可能エリア（最上位に配置）
        final clickableItem = ClickableInventoryItem(
          itemId: item,
          onTapped: (itemId) => _onItemSelected(itemId),
          size: Vector2(iconSize, iconSize),
          position: iconPosition,
        );
        clickableItem.priority = 1004; // 最上位でタップを確実に捕捉
        add(clickableItem);
      }
    } else {
      final emptyComponent = TextComponent(
        text: '(空)',
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
        position: Vector2(120, size.y - 70),
      );
      emptyComponent.priority = 1000;
      add(emptyComponent);
    }
  }
  
  /// ゲーム開始
  @override
  void startGame() {
    _gameActive = true;
    
    // タイマー開始
    timerManager.getTimer('gameTimer')?.start();
    
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
        
      case 'desk':
        if (_inventory.hasItem('code')) {
          _showMessage('すでに調べました');
        } else {
          _inventory.addItem('code');
          _showMessage('メモを発見！');
          _updateInventoryUI();
        }
        break;
        
      case 'bookshelf':
        if (_inventory.hasItem('tool')) {
          _showMessage('すでに調べました');
        } else {
          _inventory.addItem('tool');
          _showMessage('ドライバーを発見！');
          _updateInventoryUI();
        }
        break;
        
      case 'safe':
        if (_inventory.hasItem('code')) {
          _solvePuzzle('safe');
        } else {
          _showMessage('数字の組み合わせが必要');
        }
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
        
        // パズル解決効果音
        audioManager.playSfx('puzzle_solved');
        
        onPuzzleSolved(puzzleId);
        break;
    }
  }
  
  /// アイテム選択処理
  void _onItemSelected(String itemId) {
    // アイテム選択ログ（プロダクション版では削除済み）
    
    // 単一選択を保証 - 他のアイテムが選択されていたら解除
    if (_selectedItem != null && _selectedItem != itemId) {
      // 前の選択を解除
    }
    
    // トグル選択 or 新規選択
    _selectedItem = _selectedItem == itemId ? null : itemId;
    // 最終選択完了
    
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
  }
  
  /// 時間切れ
  void _onTimeUp() {
    stateProvider.changeState(EscapeRoomState.timeUp);
    _gameActive = false;
    
    onTimeUp(_puzzlesSolved);
  }
  
  /// メッセージ表示
  void _showMessage(String message) {
    // カスタムメッセージ表示
    onMessageShow(message);
    
    // ゲーム内メッセージ表示（UI）
    _displayGameMessage(message);
  }
  
  /// ゲーム内メッセージ表示
  void _displayGameMessage(String message) {
    // 既存のメッセージテキストを削除（安全な方法）
    final messagesToRemove = <TextComponent>[];
    for (final component in children) {
      if (component is TextComponent && component.position.y < 100) {
        messagesToRemove.add(component);
      }
    }
    for (final component in messagesToRemove) {
      component.removeFromParent();
    }
    
    // UTF-8文字化け対策：文字列をUTF-8で強制エンコード
    final utf8Message = String.fromCharCodes(message.runes);
    // UTF-8処理後メッセージ表示
    
    // レスポンシブメッセージ背景
    final messageBgSize = Vector2(size.x * 0.8, size.y * 0.08);
    final messageBg = RectangleComponent(
      size: messageBgSize,
      position: Vector2(size.x * 0.1, size.y * 0.02),
      paint: Paint()..color = Colors.black.withValues(alpha: 0.8),
    );
    messageBg.priority = 998;
    add(messageBg);
    
    // UTF-8対応メッセージ表示（レスポンシブ）
    final messageComponent = TextComponent(
      text: utf8Message,
      textRenderer: TextPaint(
        style: TextStyle(
          color: Colors.white,
          fontSize: size.y * 0.025, // レスポンシブフォントサイズ
          fontWeight: FontWeight.bold,
          fontFamily: 'Noto Sans JP', // 日本語対応フォント使用
          shadows: const [
            Shadow(
              color: Colors.black,
              offset: Offset(2, 2),
              blurRadius: 4,
            ),
          ],
        ),
      ),
      position: Vector2(size.x * 0.12, size.y * 0.04),
    );
    messageComponent.priority = 999;
    add(messageComponent);
    
    // 3秒後に消去
    Future.delayed(const Duration(seconds: 3), () {
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
  
  @override
  void resetGame() {
    stateProvider.changeState(EscapeRoomState.exploring);
    _gameActive = false;
    _puzzlesSolved = 0;
    _selectedItem = null;
    _inventory.clear();
    
    timerManager.stopAllTimers();
    setupGame();
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
  
  HotspotComponent({
    required this.id,
    required this.name,
    required this.description,
    required this.onTapped,
  });
  
  @override
  Future<void> onLoad() async {
    // ホットスポット名前ラベルのみ表示（枠線なし）
    final textComponent = TextComponent(
      text: name,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
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