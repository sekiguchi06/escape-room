import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import '../state/game_state_system.dart';
import '../config/game_configuration.dart';
import '../ui/flame_ui_builder.dart';
import '../ui/screen_factory.dart';
import '../core/configurable_game.dart';

/// 量産フレームワーク使用例
/// 
/// このファイルは新しいゲームを作成する際のテンプレートとして使用。
/// 3つのファイルをコピー・編集するだけで新しいゲームが完成。
/// 
/// 使用方法:
/// 1. このファイルをコピーして game_name.dart にリネーム
/// 2. クラス名・状態・設定を変更
/// 3. 画面固有のUIを調整

/// STEP 1: ゲーム固有の状態を定義
enum SampleGameState implements GameState {
  menu,
  playing, 
  paused,
  gameOver;
  
  @override
  String get name => toString().split('.').last;
  
  String get stateName => name;
  
  @override
  String get description => switch(this) {
    SampleGameState.menu => 'メニュー画面',
    SampleGameState.playing => 'プレイ中',
    SampleGameState.paused => '一時停止中',
    SampleGameState.gameOver => 'ゲームオーバー',
  };
  
  @override
  Map<String, dynamic> toJson() => {'name': name, 'description': description};
}

/// STEP 2: ゲーム固有の設定を定義
class SampleGameConfig {
  final Duration gameDuration;
  final int targetScore;
  final String title;
  final String difficulty;
  
  const SampleGameConfig({
    this.gameDuration = const Duration(minutes: 3),
    this.targetScore = 1000,
    this.title = 'Sample Casual Game',
    this.difficulty = 'normal',
  });
  
  SampleGameConfig copyWith({
    Duration? gameDuration,
    int? targetScore,
    String? title,
    String? difficulty,
  }) {
    return SampleGameConfig(
      gameDuration: gameDuration ?? this.gameDuration,
      targetScore: targetScore ?? this.targetScore,
      title: title ?? this.title,
      difficulty: difficulty ?? this.difficulty,
    );
  }
  
  Map<String, dynamic> toJson() => {
    'gameDuration': gameDuration.inSeconds,
    'targetScore': targetScore,
    'title': title,
  };
}

/// STEP 3: GameConfiguration実装
class SampleGameConfiguration extends GameConfiguration<SampleGameState, SampleGameConfig> {
  SampleGameConfiguration([SampleGameConfig? config]) : super(
    config: config ?? const SampleGameConfig(),
  );
  
  @override
  bool isValid() => config.targetScore > 0 && config.gameDuration.inSeconds > 0;
  
  @override
  bool isValidConfig(SampleGameConfig config) => 
    config.targetScore > 0 && config.gameDuration.inSeconds > 0;
  
  @override
  SampleGameConfig copyWith(Map<String, dynamic> overrides) {
    return config.copyWith(
      gameDuration: overrides['gameDuration'] != null 
        ? Duration(seconds: overrides['gameDuration'] as int)
        : null,
      targetScore: overrides['targetScore'] as int?,
      title: overrides['title'] as String?,
    );
  }
  
  @override
  Map<String, dynamic> toJson() => config.toJson();
}

/// STEP 4: GameStateProvider実装
class SampleGameStateProvider extends GameStateProvider<SampleGameState> {
  SampleGameStateProvider() : super(SampleGameState.menu);
  
  @override
  bool canTransitionTo(SampleGameState newState) {
    return switch ((currentState, newState)) {
      (SampleGameState.menu, SampleGameState.playing) => true,
      (SampleGameState.playing, SampleGameState.paused) => true,
      (SampleGameState.paused, SampleGameState.playing) => true,
      (SampleGameState.playing, SampleGameState.gameOver) => true,
      (SampleGameState.gameOver, SampleGameState.menu) => true,
      _ => false,
    };
  }
}

/// STEP 5: メインゲームクラス実装（CasualGameTemplateを継承）
class SampleCasualGame extends ConfigurableGameBase<SampleGameState, SampleGameConfig> {
  int currentScore = 0;
  int timeRemaining = 0;
  
  SampleCasualGame({SampleGameConfig? config}) : super(
    configuration: SampleGameConfiguration(config ?? const SampleGameConfig()),
  );
  
  @override
  GameStateProvider<SampleGameState> createStateProvider() => SampleGameStateProvider();
  
  @override
  Future<void> initializeGame() async {
    // ゲーム固有の初期化処理
    currentScore = 0;
    timeRemaining = 3; // 3秒カウントダウンゲーム
    
    debugPrint('ゲーム初期化: スコア=$currentScore, 時間=$timeRemaining秒');
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    
    // ゲーム状態が「playing」の時のみタイマー更新
    if (managers.stateProvider.currentState == SampleGameState.playing && timeRemaining > 0) {
      // 実際のタイマーロジックはPlayingScreen側で実行
      // ここは表示用の更新のみ
    }
  }
  
  // Removed Router functionality - use simple state management instead
  
  List<Component> createGameUI() {
    // 時間を分:秒形式で表示（シンプル実装）
    final minutes = timeRemaining ~/ 60;
    final seconds = timeRemaining % 60;
    final timeString = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    
    return [
      FlameUIBuilder.scoreText(
        text: 'Score: $currentScore',
        screenSize: size,
      ),
      FlameUIBuilder.timerText(
        text: 'Time: $timeString',
        screenSize: size,
      ),
    ];
  }
}

/// STEP 6: 画面実装（フレームワークのScreenFactory活用）

/// メニュー画面
class MenuScreen extends PositionComponent with HasGameReference, TapCallbacks {
  late RectangleComponent startButton;
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Flame公式：親ゲームのサイズを使用
    final gameSize = game.size;
    size = gameSize;
    
    // フレームワークのScreenFactory活用
    final menuContent = ScreenFactory.createScreen(
      type: 'menu',
      screenSize: gameSize,
      config: ScreenConfig(
        title: 'Sample Game',
        backgroundColor: Colors.blue.withValues(alpha: 0.8),
      ),
    );
    
    // Flame公式：中央配置
    menuContent.position = Vector2.zero();
    add(menuContent);
    
    // Flame公式: ScreenFactory作成のStartボタンエリアをカバー
    // ScreenFactoryのメニューボタン位置: screenSize.y / 2 + (-20.0)
    final buttonSize = Vector2(200, 50);
    final startButtonPos = Vector2(
      gameSize.x / 2 - 100,   // ScreenFactory customPositionと同じ
      gameSize.y / 2 - 20,    // ScreenFactory yPos = -20.0 と同じ
    );
    startButton = RectangleComponent(
      position: startButtonPos,
      size: buttonSize,
      paint: Paint()..color = Colors.transparent, // 透明なタップエリア
    );
    add(startButton);
    
    debugPrint('MenuScreen StartButton created at: $startButtonPos, size: $buttonSize');
    debugPrint('Expected tap area: X=${startButtonPos.x}-${startButtonPos.x + buttonSize.x}, Y=${startButtonPos.y}-${startButtonPos.y + buttonSize.y}');
  }
  
  @override
  void onTapDown(TapDownEvent event) {
    // 公式ドキュメント通り: TapCallbacks mixinによりタップ検出
    debugPrint('MenuScreen tap detected at: ${event.localPosition}');
    debugPrint('Start button bounds: ${startButton.position} - ${startButton.size}');
    
    // Flame公式: RectangleComponentの境界判定
    if (startButton.containsLocalPoint(event.localPosition)) {
      debugPrint('Start button tapped - ゲーム開始!');
      // Start game - transition to playing state
      if (game is SampleCasualGame) {
        (game as SampleCasualGame).managers.stateProvider.transitionTo(SampleGameState.playing);
      }
    } else {
      debugPrint('Tap outside start button area');
    }
  }
}

/// プレイ画面
class PlayingScreen extends PositionComponent with HasGameReference {
  late TextComponent gameTimerText;
  double gameTimeRemaining = 3.0; // 3秒カウントダウン
  bool gameRunning = true;
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Flame公式：親ゲームのサイズを使用
    final gameSize = game.size;
    size = gameSize;
    
    final playContent = ScreenFactory.createScreen(
      type: 'playing',
      screenSize: gameSize,
      config: ScreenConfig(
        backgroundColor: Colors.green.withValues(alpha: 0.6),
      ),
    );
    
    // Flame公式：中央配置
    playContent.position = Vector2.zero();
    add(playContent);
    
    // Flame公式: ゲームタイマー表示（中央に大きく）
    gameTimerText = TextComponent(
      text: gameTimeRemaining.toStringAsFixed(1),
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 80,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(gameSize.x / 2, gameSize.y / 2),
    );
    add(gameTimerText);
    
    debugPrint('ゲーム開始: 3秒カウントダウンスタート');
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    
    if (gameRunning && gameTimeRemaining > 0) {
      // Flame公式: updateメソッドでタイマー更新
      gameTimeRemaining -= dt;
      gameTimerText.text = gameTimeRemaining.toStringAsFixed(1);
      
      // タイマーが0になったらゲームオーバー
      if (gameTimeRemaining <= 0) {
        gameRunning = false;
        gameTimerText.text = '0.0';
        debugPrint('タイムアップ! ゲームオーバー画面へ遷移');
        
        // 1秒後にゲームオーバー画面へ遷移
        Future.delayed(const Duration(seconds: 1), () {
          if (game is SampleCasualGame) {
            (game as SampleCasualGame).managers.stateProvider.transitionTo(SampleGameState.gameOver);
          }
        });
      }
    }
  }
}

/// 一時停止画面
class PausedScreen extends PositionComponent with HasGameReference {
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Flame公式：親ゲームのサイズを使用
    final gameSize = game.size;
    size = gameSize;
    
    final pauseContent = ScreenFactory.createScreen(
      type: 'pause',
      screenSize: gameSize,
      config: ScreenConfig(
        title: 'Paused',
        customActions: {
          // Flame公式: ポーズ画面の標準ボタン
          'resume': () => debugPrint('Resume button pressed'),
          'menu': () => debugPrint('Back to menu pressed'),
        },
      ),
    );
    
    // Flame公式：中央配置
    pauseContent.position = Vector2.zero();
    add(pauseContent);
  }
}

/// ゲームオーバー画面
class GameOverScreen extends PositionComponent with HasGameReference {
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Flame公式：親ゲームのサイズを使用
    final gameSize = game.size;
    size = gameSize;
    
    final gameOverContent = ScreenFactory.createScreen(
      type: 'gameOver',
      screenSize: gameSize,
      config: ScreenConfig(
        title: 'Game Over',
        customActions: {
          // Flame公式: ゲームオーバー画面の標準ボタン
          'restart': () => debugPrint('Play Again button pressed'),
          'menu': () => debugPrint('Back to menu pressed'),
        },
      ),
    );
    
    // Flame公式：中央配置
    gameOverContent.position = Vector2.zero();
    add(gameOverContent);
  }
}

/// STEP 7: ゲームの初期化・実行例
/// 
/// ```dart
/// void main() {
///   runApp(GameWidget.controlled(gameFactory: SampleCasualGame.new));
/// }
/// ```