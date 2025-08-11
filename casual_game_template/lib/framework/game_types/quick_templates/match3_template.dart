import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import '../../core/configurable_game.dart';
import '../../state/game_state_system.dart';
import '../../effects/particle_system.dart';
import '../../audio/audio_system.dart';
import '../../score/score_system.dart';
import '../../timer/flame_timer_system.dart';

/// マッチ3パズル設定
class Match3Config {
  final Size gridSize;
  final List<String> pieceTypes;
  final int targetScore;
  final Duration gameTime;
  final int minMatchCount;
  
  const Match3Config({
    this.gridSize = const Size(8, 8),
    this.pieceTypes = const ['red', 'blue', 'green', 'yellow', 'purple'],
    this.targetScore = 1000,
    this.gameTime = const Duration(minutes: 2),
    this.minMatchCount = 3,
  });
}

/// マッチ3ゲーム状態
enum Match3State implements GameState {
  menu,
  playing,
  paused,
  gameOver;
  
  @override
  String get name => toString().split('.').last;
  
  @override
  String get description => switch(this) {
    Match3State.menu => 'メニュー画面',
    Match3State.playing => 'プレイ中',
    Match3State.paused => '一時停止中',
    Match3State.gameOver => 'ゲームオーバー',
  };
  
  @override
  Map<String, dynamic> toJson() => {'name': name, 'description': description};
}

/// 5分で作成可能なマッチ3パズルテンプレート
abstract class QuickMatch3Template extends ConfigurableGame<Match3State, Match3Config> {
  // グリッドシステム
  late GridManager _gridManager;
  late ParticleEffectManager _particleManager;
  
  // ゲーム状態
  int _score = 0;
  int _matchesFound = 0;
  double _gameTimeRemaining = 0;
  bool _gameActive = false;
  
  // 選択状態
  GridCell? _selectedCell;
  
  // 公開プロパティ
  int get score => _score;
  double get gameTimeRemaining => _gameTimeRemaining;
  bool get gameActive => _gameActive;
  
  /// ゲーム固有設定（サブクラスで実装）
  Match3Config get gameConfig;
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // グリッドマネージャー初期化
    _gridManager = GridManager(
      gridSize: gameConfig.gridSize,
      cellSize: Vector2.all(40),
      pieceTypes: gameConfig.pieceTypes,
      onMatchFound: (matches) => _onMatchFound(matches),
    );
    add(_gridManager);
    
    // パーティクルマネージャー初期化
    _particleManager = ParticleEffectManager();
    add(_particleManager);
    
    // 初期状態設定
    stateProvider.changeState(Match3State.menu);
    
    await setupGame();
  }
  
  /// ゲームセットアップ
  Future<void> setupGame() async {
    _gameTimeRemaining = gameConfig.gameTime.inSeconds.toDouble();
    
    // タイマー設定
    timerManager.addTimer('gameTimer', TimerConfiguration(
      duration: gameConfig.gameTime,
      type: TimerType.countdown,
      onComplete: () => _endGame(),
      onUpdate: (remaining) {
        _gameTimeRemaining = remaining.inSeconds.toDouble();
      },
    ));
    
    // グリッド初期化
    _gridManager.initializeGrid();
  }
  
  /// ゲーム開始
  void startGame() {
    stateProvider.changeState(Match3State.playing);
    _gameActive = true;
    _score = 0;
    _matchesFound = 0;
    
    // タイマー開始
    timerManager.getTimer('gameTimer')?.start();
  }
  
  /// マッチ発見時の処理
  void _onMatchFound(List<GridCell> matches) {
    if (matches.length < gameConfig.minMatchCount) return;
    
    // スコア計算
    final matchScore = matches.length * 100;
    _score += matchScore;
    _matchesFound++;
    
    // パーティクルエフェクト
    for (final cell in matches) {
      _particleManager.playEffect('match', cell.worldPosition);
    }
    
    // 効果音再生
    audioManager.playSfx('match_found');
    
    // マッチしたセルを削除
    _gridManager.removeMatches(matches);
    
    // スコア更新イベント
    onMatchFound(matches, matchScore);
  }
  
  /// セルタップ処理
  void onCellTapped(GridCell cell) {
    if (!_gameActive) return;
    
    if (_selectedCell == null) {
      // 最初のセル選択
      _selectedCell = cell;
      cell.setSelected(true);
    } else if (_selectedCell == cell) {
      // 同じセルを再タップ（選択解除）
      cell.setSelected(false);
      _selectedCell = null;
    } else {
      // 2つ目のセル選択（スワップ試行）
      _trySwap(_selectedCell!, cell);
      _selectedCell!.setSelected(false);
      _selectedCell = null;
    }
  }
  
  /// セルスワップ試行
  void _trySwap(GridCell cell1, GridCell cell2) {
    // 隣接チェック
    if (!_gridManager.areAdjacent(cell1, cell2)) return;
    
    // スワップ実行
    _gridManager.swapCells(cell1, cell2);
    
    // マッチチェック
    final matches = _gridManager.findMatches();
    if (matches.isEmpty) {
      // マッチなし（スワップを戻す）
      _gridManager.swapCells(cell1, cell2);
    } else {
      // マッチあり（連鎖処理）
      _processMatches(matches);
    }
  }
  
  /// マッチ処理と連鎖
  void _processMatches(List<List<GridCell>> allMatches) {
    for (final matches in allMatches) {
      _onMatchFound(matches);
    }
    
    // 重力適用
    _gridManager.applyGravity();
    
    // 新しいピース生成
    _gridManager.fillEmptyCells();
    
    // 連鎖チェック
    Future.delayed(const Duration(milliseconds: 300), () {
      final newMatches = _gridManager.findMatches();
      if (newMatches.isNotEmpty) {
        _processMatches(newMatches);
      }
    });
  }
  
  /// ゲーム終了
  void _endGame() {
    stateProvider.changeState(Match3State.gameOver);
    _gameActive = false;
    
    // 全タイマー停止
    timerManager.stopAllTimers();
    
    // 最終結果
    onGameCompleted(_score, _matchesFound);
  }
  
  // ゲームイベント（オーバーライド可能）
  void onMatchFound(List<GridCell> matches, int score) {
    // マッチ発見時の処理（カスタマイズ可能）
  }
  
  void onGameCompleted(int finalScore, int totalMatches) {
    // ゲーム完了時の処理（カスタマイズ可能）
  }
  
  // 公開メソッド（UI用）
  void pauseGame() {
    if (_gameActive) {
      pauseEngine();
      timerManager.pauseAllTimers();
      stateProvider.changeState(Match3State.paused);
      _gameActive = false;
    }
  }
  
  void resumeGame() {
    if (stateProvider.currentState == Match3State.paused) {
      resumeEngine();
      timerManager.resumeAllTimers();
      stateProvider.changeState(Match3State.playing);
      _gameActive = true;
    }
  }
  
  void resetGame() {
    _endGame();
    setupGame();
    stateProvider.changeState(Match3State.menu);
  }
}

/// グリッド管理クラス
class GridManager extends PositionComponent {
  final Size gridSize;
  final Vector2 cellSize;
  final List<String> pieceTypes;
  final Function(List<GridCell>) onMatchFound;
  
  late List<List<GridCell?>> _grid;
  
  GridManager({
    required this.gridSize,
    required this.cellSize,
    required this.pieceTypes,
    required this.onMatchFound,
  });
  
  @override
  Future<void> onLoad() async {
    size = Vector2(
      gridSize.width * cellSize.x,
      gridSize.height * cellSize.y,
    );
  }
  
  void initializeGrid() {
    _grid = List.generate(
      gridSize.height.toInt(),
      (row) => List.generate(
        gridSize.width.toInt(),
        (col) => _createCell(row, col),
      ),
    );
  }
  
  GridCell _createCell(int row, int col) {
    final cell = GridCell(
      gridPosition: Vector2(col.toDouble(), row.toDouble()),
      pieceType: pieceTypes[Random().nextInt(pieceTypes.length)],
      onTapped: (cell) => (parent as QuickMatch3Template).onCellTapped(cell),
    );
    
    cell.position = Vector2(col * cellSize.x, row * cellSize.y);
    add(cell);
    return cell;
  }
  
  bool areAdjacent(GridCell cell1, GridCell cell2) {
    final dx = (cell1.gridPosition.x - cell2.gridPosition.x).abs();
    final dy = (cell1.gridPosition.y - cell2.gridPosition.y).abs();
    return (dx == 1 && dy == 0) || (dx == 0 && dy == 1);
  }
  
  void swapCells(GridCell cell1, GridCell cell2) {
    final pos1 = cell1.gridPosition.clone();
    final pos2 = cell2.gridPosition.clone();
    
    _grid[pos1.y.toInt()][pos1.x.toInt()] = cell2;
    _grid[pos2.y.toInt()][pos2.x.toInt()] = cell1;
    
    cell1.gridPosition = pos2;
    cell2.gridPosition = pos1;
    
    cell1.position = Vector2(pos2.x * cellSize.x, pos2.y * cellSize.y);
    cell2.position = Vector2(pos1.x * cellSize.x, pos1.y * cellSize.y);
  }
  
  List<List<GridCell>> findMatches() {
    // シンプルなマッチ検出（水平・垂直のみ）
    final matches = <List<GridCell>>[];
    
    // 水平マッチ
    for (int row = 0; row < gridSize.height; row++) {
      List<GridCell> currentMatch = [];
      String? currentType;
      
      for (int col = 0; col < gridSize.width; col++) {
        final cell = _grid[row][col];
        if (cell?.pieceType == currentType) {
          currentMatch.add(cell!);
        } else {
          if (currentMatch.length >= 3) {
            matches.add(currentMatch);
          }
          currentMatch = cell != null ? [cell] : [];
          currentType = cell?.pieceType;
        }
      }
      if (currentMatch.length >= 3) {
        matches.add(currentMatch);
      }
    }
    
    return matches;
  }
  
  void removeMatches(List<GridCell> matches) {
    for (final cell in matches) {
      final row = cell.gridPosition.y.toInt();
      final col = cell.gridPosition.x.toInt();
      _grid[row][col] = null;
      cell.removeFromParent();
    }
  }
  
  void applyGravity() {
    // 重力適用（シンプル実装）
    for (int col = 0; col < gridSize.width; col++) {
      final column = <GridCell?>[];
      for (int row = 0; row < gridSize.height; row++) {
        column.add(_grid[row][col]);
      }
      
      // null要素を除去して下に詰める
      final nonNullCells = column.where((cell) => cell != null).toList();
      final nullCount = column.length - nonNullCells.length;
      
      for (int i = 0; i < gridSize.height; i++) {
        if (i < nullCount) {
          _grid[i][col] = null;
        } else {
          final cell = nonNullCells[i - nullCount]!;
          _grid[i][col] = cell;
          cell.gridPosition = Vector2(col.toDouble(), i.toDouble());
          cell.position = Vector2(col * cellSize.x, i * cellSize.y);
        }
      }
    }
  }
  
  void fillEmptyCells() {
    for (int row = 0; row < gridSize.height; row++) {
      for (int col = 0; col < gridSize.width; col++) {
        if (_grid[row][col] == null) {
          _grid[row][col] = _createCell(row, col);
        }
      }
    }
  }
}

/// グリッドセルコンポーネント
class GridCell extends PositionComponent with TapCallbacks {
  Vector2 gridPosition;
  String pieceType;
  final Function(GridCell) onTapped;
  bool _selected = false;
  
  GridCell({
    required this.gridPosition,
    required this.pieceType,
    required this.onTapped,
  }) : super(size: Vector2.all(40));
  
  Vector2 get worldPosition => position + Vector2.all(20);
  
  @override
  Future<void> onLoad() async {
    // ピースの見た目
    final color = _getColorForType(pieceType);
    add(RectangleComponent(
      size: size,
      paint: Paint()..color = color,
      position: Vector2.zero(),
    ));
    
    // 選択枠
    add(RectangleComponent(
      size: size,
      paint: Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
      position: Vector2.zero(),
    )..opacity = _selected ? 1.0 : 0.0);
  }
  
  Color _getColorForType(String type) {
    return switch(type) {
      'red' => Colors.red,
      'blue' => Colors.blue,
      'green' => Colors.green,
      'yellow' => Colors.yellow,
      'purple' => Colors.purple,
      _ => Colors.grey,
    };
  }
  
  void setSelected(bool selected) {
    _selected = selected;
    // 選択枠の表示更新
    children.whereType<RectangleComponent>().skip(1).first.opacity = _selected ? 1.0 : 0.0;
  }
  
  @override
  void onTapUp(TapUpEvent event) {
    onTapped(this);
  }
}