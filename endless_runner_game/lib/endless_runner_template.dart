import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

import '../../core/configurable_game.dart';
import '../../state/game_state_system.dart';
import '../../effects/particle_system.dart';

import '../../timer/flame_timer_system.dart';

/// エンドレスランナー設定
class RunnerConfig {
  final double gameSpeed;
  final double jumpHeight;
  final double gravity;
  final double obstacleSpawnRate;
  final int maxObstacles;
  final String difficultyLevel;
  
  const RunnerConfig({
    this.gameSpeed = 200.0,
    this.jumpHeight = 300.0,
    this.gravity = 980.0,
    this.obstacleSpawnRate = 2.0, // 秒間隔
    this.maxObstacles = 10,
    this.difficultyLevel = 'normal',
  });
}

/// エンドレスランナー状態
enum RunnerState implements GameState {
  menu,
  playing,
  paused,
  gameOver;
  
  @override
  String get name => toString().split('.').last;
  
  @override
  String get description => switch(this) {
    RunnerState.menu => 'メニュー画面',
    RunnerState.playing => 'プレイ中',
    RunnerState.paused => '一時停止中',
    RunnerState.gameOver => 'ゲームオーバー',
  };
  
  @override
  Map<String, dynamic> toJson() => {'name': name, 'description': description};
}

/// 5分で作成可能なエンドレスランナーテンプレート
abstract class QuickEndlessRunnerTemplate extends ConfigurableGame<RunnerState, RunnerConfig> 
    with KeyboardHandler, TapCallbacks, HasCollisionDetection {
  // ゲーム要素
  late PlayerComponent _player;
  late ParticleEffectManager _particleManager;
  final List<ObstacleComponent> _obstacles = [];
  
  // ゲーム状態
  int _score = 0;
  double _distanceTraveled = 0;
  int _obstaclesAvoided = 0;
  bool _gameActive = false;
  
  // 物理設定
  late double _currentGameSpeed;
  
  // 公開プロパティ
  int get score => _score;
  double get distanceTraveled => _distanceTraveled;
  bool get gameActive => _gameActive;
  
  /// ゲーム固有設定（サブクラスで実装）
  RunnerConfig get gameConfig;
  
  /// 状態プロバイダー作成（ConfigurableGameの抽象メソッド実装）
  @override
  GameStateProvider<RunnerState> createStateProvider() {
    return GameStateProvider<RunnerState>(RunnerState.menu);
  }
  
  /// ゲーム初期化（ConfigurableGameの抽象メソッド実装）
  @override
  Future<void> initializeGame() async {
    // エンドレスランナーゲーム固有の初期化処理
    debugPrint('🏃 EndlessRunner game initialization completed');
  }
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    _currentGameSpeed = gameConfig.gameSpeed;
    
    // パララックス背景
    await _setupParallaxBackground();
    
    // プレイヤー初期化
    _player = PlayerComponent(
      jumpHeight: gameConfig.jumpHeight,
      gravity: gameConfig.gravity,
      onPlayerCollision: () => onPlayerCollision(),
    );
    add(_player);
    
    // パーティクルマネージャー初期化
    _particleManager = ParticleEffectManager();
    add(_particleManager);
    
    // 初期状態設定
    stateProvider.changeState(RunnerState.menu);
    
    await setupGame();
  }
  
  /// パララックス背景セットアップ
  Future<void> _setupParallaxBackground() async {
    // シンプルなグラデーション背景
    final bgComponent = RectangleComponent(
      size: size,
      paint: Paint()..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.lightBlue.shade200, Colors.lightBlue.shade400],
      ).createShader(Rect.fromLTWH(0, 0, size.x, size.y)),
    );
    add(bgComponent);
    
    // 雲のパターン（簡易実装）
    for (int i = 0; i < 5; i++) {
      final cloud = CloudComponent(
        position: Vector2(Random().nextDouble() * size.x, Random().nextDouble() * size.y * 0.3),
        speed: gameConfig.gameSpeed * 0.3,
      );
      add(cloud);
    }
  }
  
  /// ゲームセットアップ
  Future<void> setupGame() async {
    // スコアタイマー（距離に基づくスコア）
    timerManager.addTimer('scoreTimer', TimerConfiguration(
      duration: const Duration(milliseconds: 100),
      type: TimerType.interval,
      resetOnComplete: true,
      onComplete: () => _updateScore(),
    ));
    
    // 障害物生成タイマー
    timerManager.addTimer('obstacleSpawner', TimerConfiguration(
      duration: Duration(seconds: gameConfig.obstacleSpawnRate.toInt()),
      type: TimerType.interval,
      resetOnComplete: true,
      onComplete: () => _spawnObstacle(),
    ));
  }
  
  /// ゲーム開始
  @override
  void startGame() {
    stateProvider.changeState(RunnerState.playing);
    _gameActive = true;
    _score = 0;
    _distanceTraveled = 0;
    _obstaclesAvoided = 0;
    
    // 全タイマー開始
    timerManager.startAllTimers();
    
    // プレイヤー開始
    _player.startRunning();
  }
  
  /// スコア更新
  void _updateScore() {
    if (!_gameActive) return;
    
    _distanceTraveled += _currentGameSpeed * 0.1;
    _score = (_distanceTraveled / 10).round();
    
    // 速度徐々に上昇
    _currentGameSpeed += 0.5;
    
    onScoreUpdated(_score);
  }
  
  /// 障害物生成
  void _spawnObstacle() {
    if (!_gameActive) return;
    if (_obstacles.length >= gameConfig.maxObstacles) return;
    
    final obstacle = ObstacleComponent(
      position: Vector2(size.x + 50, size.y - 100 - Random().nextDouble() * 50),
      speed: _currentGameSpeed,
      onPassed: () => _onObstaclePassed(),
    );
    
    _obstacles.add(obstacle);
    add(obstacle);
  }
  
  /// 障害物通過
  void _onObstaclePassed() {
    _obstaclesAvoided++;
    onObstaclePassed(_obstaclesAvoided);
  }
  
  /// プレイヤー衝突
  void onPlayerCollision() {
    if (!_gameActive) return;
    
    // パーティクルエフェクト
    _particleManager.playEffect('explosion', _player.position);
    
    // 効果音再生
    audioManager.playSfx('player_hit');
    
    // ゲーム終了
    _endGame();
  }
  
  /// ゲーム終了
  void _endGame() {
    stateProvider.changeState(RunnerState.gameOver);
    _gameActive = false;
    
    // 全タイマー停止
    timerManager.stopAllTimers();
    
    // プレイヤー停止
    _player.stopRunning();
    
    // 全障害物削除
    for (final obstacle in _obstacles) {
      obstacle.removeFromParent();
    }
    _obstacles.clear();
    
    // 最終結果
    onGameCompleted(_score, _distanceTraveled.round(), _obstaclesAvoided);
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    
    if (!_gameActive) return;
    
    // 障害物の画面外チェック
    _obstacles.removeWhere((obstacle) {
      if (obstacle.position.x < -100) {
        obstacle.removeFromParent();
        return true;
      }
      return false;
    });
    
    // 衝突チェック
    _checkCollisions();
  }
  
  /// 衝突チェック（Flame公式HasCollisionDetectionを使用）
  void _checkCollisions() {
    // Flame公式のHasCollisionDetectionミックスインにより
    // 自動的に衝突検出が行われ、CollisionCallbacksで処理される
    // 手動チェックは不要
  }
  
  // 入力処理
  @override
  void onTapUp(TapUpEvent event) {
    if (_gameActive) {
      _player.jump();
    }
  }
  
  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (_gameActive && keysPressed.contains(LogicalKeyboardKey.space)) {
      _player.jump();
      return true;
    }
    return false;
  }
  
  // ゲームイベント（オーバーライド可能）
  void onScoreUpdated(int newScore) {
    // スコア更新時の処理（カスタマイズ可能）
  }
  
  void onObstaclePassed(int totalPassed) {
    // 障害物通過時の処理（カスタマイズ可能）
  }
  
  void onGameCompleted(int finalScore, int distance, int obstaclesPassed) {
    // ゲーム完了時の処理（カスタマイズ可能）
  }
  
  // 公開メソッド（UI用）
  @override
  void pauseGame() {
    if (_gameActive) {
      pauseEngine();
      timerManager.pauseAllTimers();
      stateProvider.changeState(RunnerState.paused);
      _gameActive = false;
    }
  }
  
  @override
  void resumeGame() {
    if (stateProvider.currentState == RunnerState.paused) {
      resumeEngine();
      timerManager.resumeAllTimers();
      stateProvider.changeState(RunnerState.playing);
      _gameActive = true;
    }
  }
  
  @override
  void resetGame() {
    _endGame();
    setupGame();
    stateProvider.changeState(RunnerState.menu);
    _currentGameSpeed = gameConfig.gameSpeed;
  }
}

/// プレイヤーコンポーネント
class PlayerComponent extends PositionComponent with CollisionCallbacks {
  final double jumpHeight;
  final double gravity;
  final Function() onPlayerCollision;
  
  double _velocityY = 0;
  double _groundY = 0;
  bool _isJumping = false;
  bool _isRunning = false;
  
  PlayerComponent({
    required this.jumpHeight,
    required this.gravity,
    required this.onPlayerCollision,
  }) : super(size: Vector2.all(40));
  
  @override
  Future<void> onLoad() async {
    _groundY = (parent as QuickEndlessRunnerTemplate).size.y - 100 - size.y;
    position = Vector2(100, _groundY);
    
    // プレイヤーの見た目（シンプルな正方形）
    add(RectangleComponent(
      size: size,
      paint: Paint()..color = Colors.blue,
      position: Vector2.zero(),
    ));
    
    // Flame公式の衝突判定ボックス追加
    add(RectangleHitbox());
  }
  
  void startRunning() {
    _isRunning = true;
  }
  
  void stopRunning() {
    _isRunning = false;
  }
  
  void jump() {
    if (!_isJumping && _isRunning) {
      _velocityY = -jumpHeight;
      _isJumping = true;
    }
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    
    if (!_isRunning) return;
    
    if (_isJumping) {
      _velocityY += gravity * dt;
      position.y += _velocityY * dt;
      
      // 着地チェック
      if (position.y >= _groundY) {
        position.y = _groundY;
        _velocityY = 0;
        _isJumping = false;
      }
    }
  }
}

/// 障害物コンポーネント
class ObstacleComponent extends PositionComponent with CollisionCallbacks {
  final double speed;
  final Function() onPassed;
  bool _hasPassed = false;
  
  ObstacleComponent({
    required super.position,
    required this.speed,
    required this.onPassed,
  }) : super(size: Vector2(30, 60));
  
  @override
  Future<void> onLoad() async {
    // 障害物の見た目（シンプルな長方形）
    add(RectangleComponent(
      size: size,
      paint: Paint()..color = Colors.red,
      position: Vector2.zero(),
    ));
    
    // Flame公式の衝突判定ボックス追加
    add(RectangleHitbox());
  }
  
  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    // Flame公式の衝突コールバック
    if (other is PlayerComponent) {
      // プレイヤーとの衝突時は親のゲームに衝突イベントを通知
      final game = parent as QuickEndlessRunnerTemplate;
      game.onPlayerCollision();
    }
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    position.x -= speed * dt;
    
    // プレイヤーを通過したかチェック
    if (!_hasPassed && position.x < 100) {
      _hasPassed = true;
      onPassed();
    }
  }
}

/// 雲コンポーネント（背景用）
class CloudComponent extends PositionComponent {
  final double speed;
  
  CloudComponent({
    required super.position,
    required this.speed,
  }) : super(size: Vector2(80, 40));
  
  @override
  Future<void> onLoad() async {
    // 雲の見た目（シンプルな楕円）
    add(RectangleComponent(
      size: size,
      paint: Paint()..color = Colors.white.withValues(alpha: 0.7),
      position: Vector2.zero(),
    ));
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    position.x -= speed * dt;
    
    // 画面外に出たらリセット
    if (position.x < -size.x) {
      final gameSize = (parent as QuickEndlessRunnerTemplate).size;
      position.x = gameSize.x + Random().nextDouble() * 100;
      position.y = Random().nextDouble() * gameSize.y * 0.3;
    }
  }
}