import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';

import 'dart:math';

import '../../core/configurable_game.dart';
import '../../state/game_state_system.dart';
import '../../effects/particle_system.dart';

import '../../timer/flame_timer_system.dart';

/// タップシューティング設定
class TapShooterConfig {
  final Duration gameDuration;
  final double enemySpeed;
  final int maxEnemies;
  final int targetScore;
  final String difficultyLevel;
  
  const TapShooterConfig({
    this.gameDuration = const Duration(seconds: 60),
    this.enemySpeed = 100.0,
    this.maxEnemies = 5,
    this.targetScore = 1000,
    this.difficultyLevel = 'normal',
  });
}

/// タップシューティング状態
enum TapShooterState implements GameState {
  menu,
  playing,
  paused,
  gameOver;
  
  @override
  String get name => toString().split('.').last;
  
  @override
  String get description => switch(this) {
    TapShooterState.menu => 'メニュー画面',
    TapShooterState.playing => 'プレイ中',
    TapShooterState.paused => '一時停止中',
    TapShooterState.gameOver => 'ゲームオーバー',
  };
  
  @override
  Map<String, dynamic> toJson() => {'name': name, 'description': description};
}

/// 5分で作成可能なタップシューティングテンプレート
abstract class QuickTapShooterTemplate extends ConfigurableGame<TapShooterState, TapShooterConfig> {
  // ゲーム要素
  final List<EnemyComponent> _enemies = [];
  late ParticleEffectManager _particleManager;
  
  // 統計情報
  int _score = 0;
  int _enemiesDestroyed = 0;
  double _gameTimeRemaining = 0;
  bool _gameActive = false;
  
  // 公開プロパティ（UI用）
  int get score => _score;
  double get gameTimeRemaining => _gameTimeRemaining;
  bool get gameActive => _gameActive;
  
  /// 時間フォーマット（UI用）
  String formatTime(double timeInSeconds) {
    final minutes = timeInSeconds ~/ 60;
    final seconds = timeInSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toInt().toString().padLeft(2, '0')}';
  }
  
  /// ゲーム固有設定（サブクラスで実装）
  TapShooterConfig get gameConfig;
  
  /// 状態プロバイダー作成（ConfigurableGameの抽象メソッド実装）
  @override
  GameStateProvider<TapShooterState> createStateProvider() {
    return GameStateProvider<TapShooterState>(TapShooterState.menu);
  }
  
  /// ゲーム初期化（ConfigurableGameの抽象メソッド実装）
  @override
  Future<void> initializeGame() async {
    // タップシューティングゲーム固有の初期化処理
    debugPrint('🎯 TapShooter game initialization completed');
  }
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // パーティクルマネージャー初期化
    _particleManager = ParticleEffectManager();
    add(_particleManager);
    
    // 初期状態設定
    stateProvider.changeState(TapShooterState.menu);
    
    await setupGame();
  }
  
  /// ゲームセットアップ
  Future<void> setupGame() async {
    _gameTimeRemaining = gameConfig.gameDuration.inSeconds.toDouble();
    
    // タイマー設定
    timerManager.addTimer('gameTimer', TimerConfiguration(
      duration: gameConfig.gameDuration,
      type: TimerType.countdown,
      onComplete: () => _endGame(),
      onUpdate: (remaining) {
        _gameTimeRemaining = remaining.inSeconds.toDouble();
      },
    ));
  }
  
  /// ゲーム開始
  @override
  void startGame() {
    stateProvider.changeState(TapShooterState.playing);
    _gameActive = true;
    _score = 0;
    _enemiesDestroyed = 0;
    
    // タイマー開始
    timerManager.getTimer('gameTimer')?.start();
    
    // 敵生成開始
    _startEnemySpawning();
  }
  
  /// 敵生成システム
  void _startEnemySpawning() {
    timerManager.addTimer('enemySpawner', TimerConfiguration(
      duration: const Duration(seconds: 2),
      type: TimerType.interval,
      resetOnComplete: true,
      onComplete: () => _spawnEnemy(),
    ));
    timerManager.getTimer('enemySpawner')?.start();
  }
  
  /// 敵生成
  void _spawnEnemy() {
    if (_enemies.length >= gameConfig.maxEnemies) return;
    
    final enemy = EnemyComponent(
      position: Vector2(Random().nextDouble() * size.x, -50),
      speed: gameConfig.enemySpeed,
      onTapped: (enemy) => _onEnemyTapped(enemy),
    );
    
    _enemies.add(enemy);
    add(enemy);
  }
  
  /// 敵タップ処理
  void _onEnemyTapped(EnemyComponent enemy) {
    // スコア加算
    _score += 100;
    _enemiesDestroyed++;
    
    // パーティクルエフェクト
    _particleManager.playEffect('explosion', enemy.position);
    
    // 敵削除
    _enemies.remove(enemy);
    enemy.removeFromParent();
    
    // 効果音再生
    audioManager.playSfx('enemy_destroyed');
    
    // スコア更新イベント
    onScoreUpdated(_score);
  }
  
  /// ゲーム終了
  void _endGame() {
    stateProvider.changeState(TapShooterState.gameOver);
    _gameActive = false;
    
    // 全タイマー停止
    timerManager.stopAllTimers();
    
    // 全敵削除
    for (final enemy in _enemies) {
      enemy.removeFromParent();
    }
    _enemies.clear();
    
    // 最終結果
    onGameCompleted(_score, _enemiesDestroyed);
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    
    if (!_gameActive) return;
    
    // 敵の画面外チェック
    _enemies.removeWhere((enemy) {
      if (enemy.position.y > size.y + 100) {
        enemy.removeFromParent();
        return true;
      }
      return false;
    });
  }
  
  // ゲームイベント（オーバーライド可能）
  void onScoreUpdated(int newScore) {
    // スコア更新時の処理（カスタマイズ可能）
  }
  
  void onGameCompleted(int finalScore, int enemiesDestroyed) {
    // ゲーム完了時の処理（カスタマイズ可能）
  }
  
  // 公開メソッド（UI用）
  @override
  void pauseGame() {
    if (_gameActive) {
      pauseEngine();
      timerManager.pauseAllTimers();
      stateProvider.changeState(TapShooterState.paused);
      _gameActive = false;
    }
  }
  
  @override
  void resumeGame() {
    if (stateProvider.currentState == TapShooterState.paused) {
      resumeEngine();
      timerManager.resumeAllTimers();
      stateProvider.changeState(TapShooterState.playing);
      _gameActive = true;
    }
  }
  
  @override
  void resetGame() {
    _endGame();
    setupGame();
    stateProvider.changeState(TapShooterState.menu);
  }
}

/// 敵コンポーネント
class EnemyComponent extends PositionComponent with TapCallbacks, CollisionCallbacks {
  final double speed;
  final Function(EnemyComponent) onTapped;
  
  EnemyComponent({
    required super.position,
    required this.speed,
    required this.onTapped,
  }) : super(size: Vector2.all(40));
  
  @override
  Future<void> onLoad() async {
    // 敵の見た目（シンプルな円）
    add(CircleComponent(
      radius: 20,
      paint: Paint()..color = Colors.red,
      position: Vector2.all(20),
      anchor: Anchor.center,
    ));
    
    // Flame公式の衝突判定ボックス追加
    add(CircleHitbox());
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    position.y += speed * dt;
  }
  
  @override
  void onTapUp(TapUpEvent event) {
    onTapped(this);
  }
}