// 🎮 SimpleGameベース 量産ゲームテンプレート
// 
// 使用方法:
// 1. [GAME_NAME] を実際のゲーム名に置換（例: BubblePop）
// 2. [SPECIFIC_PARAM] をゲーム固有パラメータに置換（例: bubbleSpeed）  
// 3. _handleTap メソッドにゲーム固有ロジックを実装
// 4. 必要に応じてコンポーネントを追加

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import '../../framework/state/game_state_system.dart';
import '../../framework/config/game_configuration.dart';
import '../../framework/core/configurable_game.dart';
import '../../framework/audio/audio_system.dart';
import '../../framework/audio/providers/flame_audio_provider.dart';
import '../../framework/effects/particle_system.dart';
import '../framework_integration/simple_game_states.dart';

/// ゲーム設定クラス - 型安全実装
class GameTemplateConfig {
  final int gameDuration; // seconds
  final double specificParam; // ゲーム固有パラメータ
  final String difficulty;

  const GameTemplateConfig({
    this.gameDuration = 30,
    this.specificParam = 1.0,
    this.difficulty = 'normal',
  });

  GameTemplateConfig copyWith({
    int? gameDuration,
    double? specificParam,
    String? difficulty,
  }) {
    return GameTemplateConfig(
      gameDuration: gameDuration ?? this.gameDuration,
      specificParam: specificParam ?? this.specificParam,
      difficulty: difficulty ?? this.difficulty,
    );
  }

  Map<String, dynamic> toJson() => {
    'gameDuration': gameDuration,
    'specificParam': specificParam,
    'difficulty': difficulty,
  };

  factory GameTemplateConfig.fromJson(Map<String, dynamic> json) => GameTemplateConfig(
    gameDuration: json['gameDuration'] ?? 30,
    specificParam: json['specificParam']?.toDouble() ?? 1.0,
    difficulty: json['difficulty'] ?? 'normal',
  );

  @override
  String toString() => 'GameTemplateConfig(duration: ${gameDuration}s, param: $specificParam)';
}

/// 設定プリセット - 3難易度対応
class GameTemplateConfigPresets {
  static const GameTemplateConfig easy = GameTemplateConfig(
    gameDuration: 45,
    specificParam: 0.8,
    difficulty: 'easy',
  );

  static const GameTemplateConfig normal = GameTemplateConfig(
    gameDuration: 30,
    specificParam: 1.0,
    difficulty: 'normal',
  );

  static const GameTemplateConfig hard = GameTemplateConfig(
    gameDuration: 20,
    specificParam: 1.5,
    difficulty: 'hard',
  );

  static GameTemplateConfig getPreset(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy': return easy;
      case 'hard': return hard;
      default: return normal;
    }
  }
}

/// GameConfiguration実装 - 継承関係修正済み
class GameTemplateConfiguration extends GameConfiguration<GameState, GameTemplateConfig> {
  GameTemplateConfiguration(GameTemplateConfig config) : super(config: config);

  static final GameTemplateConfiguration defaultConfig = 
    GameTemplateConfiguration(GameTemplateConfigPresets.normal);

  @override
  bool isValid() => 
    config.gameDuration > 0 && 
    config.specificParam > 0;

  @override
  bool isValidConfig(GameTemplateConfig config) => 
    config.gameDuration > 0 && 
    config.specificParam > 0;

  @override
  GameTemplateConfig copyWith(Map<String, dynamic> overrides) {
    return config.copyWith(
      gameDuration: overrides['gameDuration'] as int?,
      specificParam: overrides['specificParam'] as double?,
      difficulty: overrides['difficulty'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => config.toJson();
}

/// メインゲームクラス - エラー修正済み実装
class GameTemplate extends ConfigurableGame<GameState, GameTemplateConfig> {
  // ゲーム状態
  late ParticleEffectManager _particleManager;
  bool _gameActive = false;
  int _score = 0;
  double _gameTimeRemaining = 0;

  GameTemplate() : super(
    configuration: GameTemplateConfiguration.defaultConfig,
    debugMode: false,
  );

  /// 必須オーバーライド - 既存プロバイダー流用
  @override
  GameStateProvider<GameState> createStateProvider() {
    return SimpleGameStateProvider(); // ✅ 既存を流用
  }

  AudioProvider createAudioProvider() {
    return FlameAudioProvider(); // ✅ 既存を流用
  }

  /// ゲーム初期化 - パーティクル統合
  @override
  Future<void> initializeGame() async {
    debugPrint('🎮 GameTemplate initializing...');
    
    // パーティクルシステム初期化
    _particleManager = ParticleEffectManager();
    add(_particleManager);
    
    // ゲーム状態リセット
    _resetGame();
    
    debugPrint('🎮 GameTemplate initialized - Duration: ${config.gameDuration}s');
  }

  void _resetGame() {
    _score = 0;
    _gameTimeRemaining = config.gameDuration.toDouble();
    _gameActive = true;
  }

  /// メインゲームループ
  @override
  void update(double dt) {
    super.update(dt);
    
    if (!_gameActive) return;

    // タイマー更新
    _gameTimeRemaining -= dt;

    // ゲーム固有の更新処理
    _updateGameLogic(dt);

    // ゲーム終了チェック
    if (_gameTimeRemaining <= 0) {
      _endGame();
    }
  }

  void _updateGameLogic(double dt) {
    // ゲーム固有ロジックをここに実装
    // 例: エネミー移動、アイテム生成など
  }

  /// タップイベント処理 - 型安全実装
  @override
  void onTapDown(TapDownEvent event) { // ✅ 正しい型
    if (!_gameActive) {
      // ゲーム終了時はリスタート
      _resetGame();
      return;
    }

    final tapPosition = event.localPosition; // ✅ 正しいプロパティ
    
    // ゲーム固有のタップ処理
    _handleTap(tapPosition);
  }

  void _handleTap(Vector2 position) {
    // ゲーム固有のタップ処理を実装
    // 例: アイテムクリック、敵撃退など
    
    _score += 10;
    
    // パーティクルエフェクト（正しいメソッド名）
    _particleManager.playEffect('explosion', position); // ✅ 正しいメソッド
    
    // 効果音
    audioManager.playSfx('tap');
    
    debugPrint('🎮 Tap at $position, Score: $_score');
  }

  void _endGame() {
    _gameActive = false;
    
    // 分析イベント
    analyticsManager.trackEvent('game_template_completed', parameters: {
      'score': _score,
      'duration': config.gameDuration,
      'difficulty': config.difficulty,
    });
    
    debugPrint('🎮 Game Over! Final Score: $_score');
  }

  /// UI描画 - Canvas直接描画
  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    // 背景
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      Paint()..color = Colors.black.withValues(alpha: 0.8),
    );
    
    // UI描画
    _renderUI(canvas);
  }

  void _renderUI(Canvas canvas) {
    final textStyle = const TextStyle(
      color: Colors.white,
      fontSize: 24,
      fontWeight: FontWeight.bold,
    );

    // スコア表示
    final scoreSpan = TextSpan(text: 'Score: $_score', style: textStyle);
    final scorePainter = TextPainter(
      text: scoreSpan,
      textDirection: TextDirection.ltr,
    );
    scorePainter.layout();
    scorePainter.paint(canvas, const Offset(20, 50));

    // タイマー表示
    final minutes = _gameTimeRemaining ~/ 60;
    final seconds = (_gameTimeRemaining % 60).round();
    final timeString = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    
    final timeSpan = TextSpan(text: 'Time: $timeString', style: textStyle);
    final timePainter = TextPainter(
      text: timeSpan,
      textDirection: TextDirection.ltr,
    );
    timePainter.layout();
    timePainter.paint(canvas, Offset(size.x - 150, 50));

    // ゲーム終了メッセージ
    if (!_gameActive) {
      _renderGameOverMessage(canvas);
    }
  }

  void _renderGameOverMessage(Canvas canvas) {
    final gameOverStyle = const TextStyle(
      color: Colors.white,
      fontSize: 32,
      fontWeight: FontWeight.bold,
    );
    
    final gameOverSpan = TextSpan(
      text: 'Game Over!\nFinal Score: $_score\nTap to Restart', 
      style: gameOverStyle
    );
    
    final gameOverPainter = TextPainter(
      text: gameOverSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    
    gameOverPainter.layout();
    gameOverPainter.paint(canvas, Offset(
      (size.x - gameOverPainter.width) / 2,
      (size.y - gameOverPainter.height) / 2,
    ));
  }
}

/// ゲーム固有コンポーネントの例
/// 必要に応じて追加・修正してください
class GameObjectComponent extends CircleComponent {
  final double speed;
  
  GameObjectComponent({
    required Vector2 position,
    required this.speed,
    required double size,
    required Color color,
  }) : super(
    position: position,
    radius: size / 2,
    paint: Paint()..color = color,
    anchor: Anchor.center,
  );
  
  @override
  void update(double dt) {
    super.update(dt);
    
    // オブジェクト固有の動作
    position.y += speed * dt; // 例: 下方向移動
  }
  
  @override
  bool containsPoint(Vector2 point) {
    final distance = position.distanceTo(point);
    return distance <= radius;
  }
}