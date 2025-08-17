import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import '../framework/state/game_state_system.dart';
import '../framework/core/configurable_game.dart';
import '../framework/audio/audio_system.dart';
import '../framework/audio/providers/flame_audio_provider.dart';
import '../framework/effects/particle_system.dart';
import 'framework_integration/simple_game_states.dart';
import 'config/tap_fire_config.dart';

/// SimpleGameベースのTapFireGame - シンプル実装
/// 
/// 設計方針:
/// - SimpleGameの成功パターンを流用
/// - 300行以下の実装
/// - 設定駆動による難易度調整
/// - 複雑なフレームワークは使用せず
class TapFireGame extends ConfigurableGameBase<GameState, TapFireConfig> {
  // ゲーム状態
  final List<FireballComponent> _fireballs = [];
  late ParticleEffectManager _particleManager;
  
  // ゲーム統計
  int _score = 0;
  int _fireballsDestroyed = 0;
  double _gameTimeRemaining = 0;
  double _nextFireballSpawn = 0;
  bool _gameActive = false;
  // 公開プロパティ（main.dartのオーバーレイから参照）
  int get score => _score;
  double get gameTimeRemaining => _gameTimeRemaining;
  bool get gameActive => _gameActive;

  // 時間フォーマット用公開メソッド
  String formatTime(double timeInSeconds) {
    final minutes = timeInSeconds ~/ 60;
    final seconds = (timeInSeconds % 60).round();
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // 公開メソッド（main.dartのオーバーレイから呼び出し）
  @override
  void resetGame() {
    _resetGame();
    _showGameUI();
  }

  void restartFromGameOver() {
    _resetGame();
    _showGameUI();
  }

  // ポーズ機能（Flame公式パターン）
  @override
  void pauseGame() {
    if (_gameActive) {
      pauseEngine();
      _gameActive = false;
      debugPrint('🔥 Game paused');
    }
  }

  @override
  void resumeGame() {
    if (!_gameActive) {
      resumeEngine();
      _gameActive = true;
      debugPrint('🔥 Game resumed');
    }
  }

  // オーバーレイ管理メソッド
  void _showStartUI() {
    overlays.remove('gameUI');
    overlays.remove('gameOverUI');
    overlays.remove('settingsUI');
    overlays.add('startUI');
  }

  void _showGameUI() {
    overlays.remove('gameOverUI');
    overlays.remove('startUI');
    overlays.remove('settingsUI');
    overlays.add('gameUI');
  }

  void _showGameOverUI() {
    overlays.remove('gameUI');
    overlays.remove('startUI');
    overlays.remove('settingsUI');
    overlays.add('gameOverUI');
  }

  void showSettingsUI() {
    overlays.add('settingsUI');
  }

  void hideSettingsUI() {
    overlays.remove('settingsUI');
  }

  void _updateUI() {
    if (overlays.isActive('gameUI')) {
      overlays.remove('gameUI');
      overlays.add('gameUI');
    }
  }

  TapFireGame() : super(
    configuration: TapFireGameConfiguration.defaultConfig,
    debugMode: false,
  );

  @override
  GameStateProvider<GameState> createStateProvider() {
    return SimpleGameStateProvider();
  }

  AudioProvider createAudioProvider() {
    return FlameAudioProvider();
  }

  @override
  Future<void> onLoad() async {
    debugPrint('🔥 TapFireGame.onLoad() starting');
    await super.onLoad();
    debugPrint('🔥 TapFireGame.onLoad() completed');
  }

  @override
  Future<void> initializeGame() async {
    debugPrint('🔥 TapFire Game initializing...');
    debugPrint('🔥 TapFire: managers.audioManager available');
    
    // 音声システムの初期化を追加
    try {
      await _initializeAudio();
    } catch (e) {
      debugPrint('❌ TapFire initializeGame: Audio init failed: $e');
    }
    
    // パーティクルシステム初期化
    _particleManager = ParticleEffectManager();
    add(_particleManager);
    
    // ゲーム状態リセット
    _resetGame();
    
    // スタートUIオーバーレイを表示
    _showStartUI();
    
    debugPrint('🔥 TapFire Game initialized - Duration: ${config.gameDuration}s');
  }

  // 音声システムの初期化（SimpleGameから移植）
  Future<void> _initializeAudio() async {
    try {
      debugPrint('🎵 TapFire: Starting audio initialization...');
      debugPrint('🎵 TapFire: AudioManager available');
      
      // DefaultAudioConfigurationを直接作成（FlameAudioは自動でassets/を付加）
      final audioConfig = DefaultAudioConfiguration(
        bgmAssets: {
          'menu_bgm': 'audio/menu.mp3',
        },
        sfxAssets: {
          'tap': 'tap.wav',
          'success': 'success.wav', 
          'error': 'error.wav',
        },
        masterVolume: 1.0,
        bgmVolume: 0.6,
        sfxVolume: 0.8,
        bgmEnabled: true,
        sfxEnabled: true,
        preloadAssets: ['tap', 'success', 'error'],
        loopSettings: {
          'menu_bgm': true,
          'tap': false,
          'success': false,
          'error': false,
        },
        debugMode: true,
      );
      
      await managers.audioManager.updateConfiguration(audioConfig);
      
      debugPrint('🎵 TapFire: Audio system initialized');
      debugPrint('🎵 TapFire: SFX assets configured: tap.wav, success.wav, error.wav');
      debugPrint('🎵 TapFire: Audio provider type: ${managers.audioManager.provider.runtimeType}');
    } catch (e) {
      debugPrint('❌ TapFire: Audio initialization failed: $e');
      debugPrint('❌ TapFire: Stack trace: ${StackTrace.current}');
    }
  }

  void _resetGame() {
    _score = 0;
    _fireballsDestroyed = 0;
    _gameTimeRemaining = config.gameDuration.toDouble();
    _nextFireballSpawn = config.fireballSpawnInterval;
    _gameActive = true;
    
    // 既存のファイヤーボールをクリア
    for (final fireball in _fireballs) {
      fireball.removeFromParent();
    }
    _fireballs.clear();
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    if (!_gameActive) return;

    // タイマー更新
    _gameTimeRemaining -= dt;
    _nextFireballSpawn -= dt;

    // ファイヤーボール生成
    if (_nextFireballSpawn <= 0) {
      _spawnFireball();
      _nextFireballSpawn = config.fireballSpawnInterval;
    }

    // ファイヤーボール移動と画面外チェック
    _updateFireballs(dt);

    // ゲーム終了チェック
    if (_gameTimeRemaining <= 0) {
      _endGame();
    }

    // UI更新（定期的にオーバーレイを更新）
    _updateUI();
  }

  void _spawnFireball() {
    final random = Random();
    final x = random.nextDouble() * (size.x - 60) + 30;
    
    final fireball = FireballComponent(
      position: Vector2(x, -30),
      speed: config.fireballSpeed,
      size: config.fireballSize,
    );
    
    _fireballs.add(fireball);
    add(fireball);
  }

  void _updateFireballs(double dt) {
    _fireballs.removeWhere((fireball) {
      if (fireball.position.y > size.y + 50) {
        fireball.removeFromParent();
        return true;
      }
      return false;
    });
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (!_gameActive) {
      // ゲーム終了時はリスタート
      _resetGame();
      return;
    }

    final tapPosition = event.localPosition;
    
    // タップされたファイヤーボールを検索
    for (final fireball in List.from(_fireballs)) {
      if (fireball.containsPoint(tapPosition)) {
        _destroyFireball(fireball, tapPosition);
        break;
      }
    }
  }

  void _destroyFireball(FireballComponent fireball, Vector2 position) {
    // スコア追加
    _score += config.baseScore;
    _fireballsDestroyed++;
    
    // パーティクルエフェクト  
    _particleManager.playEffect('explosion', position);
    
    // 効果音
    managers.audioManager.playSfx('tap');
    
    // ファイヤーボール削除
    fireball.removeFromParent();
    _fireballs.remove(fireball);
    
    debugPrint('🔥 Fireball destroyed! Score: $_score');
  }

  void _endGame() {
    _gameActive = false;
    
    // 分析イベント
    managers.analyticsManager.trackEvent('tapfire_game_completed', parameters: {
      'score': _score,
      'fireballs_destroyed': _fireballsDestroyed,
      'duration': config.gameDuration,
    });
    
    // ゲームオーバーUIを表示（公式パターン）
    _showGameOverUI();
    
    debugPrint('🔥 Game Over! Final Score: $_score, Destroyed: $_fireballsDestroyed');
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    // 背景のみ描画 - UIはFlutterオーバーレイで完全処理
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      Paint()..color = Colors.black.withValues(alpha: 0.8),
    );
  }




}

/// ファイヤーボールコンポーネント
class FireballComponent extends CircleComponent {
  final double speed;
  
  FireballComponent({
    required Vector2 position,
    required this.speed,
    required double size,
  }) : super(
    position: position,
    radius: size / 2,
    paint: Paint()..color = Colors.red,
    anchor: Anchor.center,
  );
  
  @override
  void update(double dt) {
    super.update(dt);
    position.y += speed * dt;
  }
  
  @override
  bool containsPoint(Vector2 point) {
    final distance = position.distanceTo(point);
    return distance <= radius;
  }
}