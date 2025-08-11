import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import '../../core/configurable_game.dart';
import '../../state/game_state_system.dart';
import '../../audio/audio_system.dart';
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
    // シンプルな部屋背景
    final background = RectangleComponent(
      size: size,
      paint: Paint()..color = Colors.brown.shade200,
    );
    add(background);
    
    // 床
    final floor = RectangleComponent(
      size: Vector2(size.x, 50),
      position: Vector2(0, size.y - 50),
      paint: Paint()..color = Colors.brown.shade400,
    );
    add(floor);
    
    // 壁の装飾
    _addWallDecorations();
  }
  
  /// 壁の装飾追加
  void _addWallDecorations() {
    // ドア
    final door = RectangleComponent(
      size: Vector2(80, 120),
      position: Vector2(size.x - 100, size.y - 170),
      paint: Paint()..color = Colors.brown.shade600,
    );
    add(door);
    
    // 窓
    final window = RectangleComponent(
      size: Vector2(100, 80),
      position: Vector2(50, 50),
      paint: Paint()..color = Colors.lightBlue.shade200,
    );
    add(window);
  }
  
  /// ホットスポット配置
  Future<void> _setupHotspots() async {
    // ドアのホットスポット（脱出口）
    _addHotspot('door', Vector2(size.x - 100, size.y - 170), Vector2(80, 120), 
                'ドア', 'ここから脱出できそうだが、何かが必要だ...');
    
    // 机のホットスポット
    _addHotspot('desk', Vector2(200, size.y - 150), Vector2(120, 80), 
                '机', '何かが隠されているかもしれない');
    
    // 本棚のホットスポット
    _addHotspot('bookshelf', Vector2(50, size.y - 200), Vector2(80, 150), 
                '本棚', '本の間に何かが挟まっている');
    
    // 金庫のホットスポット
    _addHotspot('safe', Vector2(size.x - 200, 100), Vector2(60, 60), 
                '金庫', '数字の組み合わせが必要だ');
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
      },
    ));
    
    startGame();
  }
  
  /// ゲーム開始
  void startGame() {
    _gameActive = true;
    
    // タイマー開始
    timerManager.getTimer('gameTimer')?.start();
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
          _escapeSuccessful();
        } else {
          _showMessage('鍵が必要だ');
        }
        break;
        
      case 'desk':
        if (_inventory.hasItem('code')) {
          _showMessage('もう調べた');
        } else {
          _inventory.addItem('code');
          _showMessage('メモを見つけた！');
        }
        break;
        
      case 'bookshelf':
        if (_inventory.hasItem('tool')) {
          _showMessage('もう調べた');
        } else {
          _inventory.addItem('tool');
          _showMessage('ドライバーを見つけた！');
        }
        break;
        
      case 'safe':
        if (itemId == 'code') {
          _solvePuzzle('safe');
        } else if (_inventory.hasItem('code')) {
          _solvePuzzle('safe');
        } else {
          _showMessage('数字の組み合わせが分からない');
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
        _showMessage('金庫が開いた！鍵を手に入れた！');
        
        // パズル解決効果音
        audioManager.playSfx('puzzle_solved');
        
        onPuzzleSolved(puzzleId);
        break;
    }
  }
  
  /// アイテム選択処理
  void _onItemSelected(String itemId) {
    _selectedItem = _selectedItem == itemId ? null : itemId;
    onItemSelected(_selectedItem);
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
  
  void resetGame() {
    stateProvider.changeState(EscapeRoomState.exploring);
    _gameActive = false;
    _puzzlesSolved = 0;
    _selectedItem = null;
    _inventory.clear();
    
    timerManager.stopAllTimers();
    setupGame();
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
    // ホットスポットの見た目（透明な領域）
    add(RectangleComponent(
      size: size,
      paint: Paint()..color = Colors.yellow.withOpacity(0.3),
      position: Vector2.zero(),
    ));
  }
  
  @override
  void onTapUp(TapUpEvent event) {
    onTapped(id);
  }
}