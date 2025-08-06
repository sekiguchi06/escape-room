import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../framework/state/game_state_system.dart';
import '../framework/config/game_configuration.dart';
import '../framework/timer/flame_timer_system.dart';
import '../framework/ui/ui_system.dart';
import '../framework/core/configurable_game.dart';
import '../framework/animation/animation_system.dart';
import '../framework/audio/audio_system.dart';
import '../framework/audio/game_audio_helper.dart';
import '../framework/monetization/monetization_system.dart';
import '../framework/analytics/analytics_system.dart';
import '../framework/audio/providers/audioplayers_provider.dart';
import '../framework/monetization/providers/google_ad_provider.dart';
import '../framework/analytics/providers/firebase_analytics_provider.dart';
import 'package:flutter/foundation.dart';
import '../framework/effects/particle_system.dart';
import 'framework_integration/simple_game_states.dart';
import 'framework_integration/simple_game_configuration.dart';

// RouterComponent関連インポート
import 'package:flame/src/components/router/router_component.dart';
import 'screens/start_screen_component.dart';
import 'screens/playing_screen_component.dart';
import 'screens/game_over_screen_component.dart';
import 'widgets/settings_menu_widget.dart';

class SimpleGame extends ConfigurableGame<GameState, SimpleGameConfig> {
  // RouterComponent関連
  late final RouterComponent router;
  late PlayingScreenComponent? _playingScreen;
  
  // 既存フィールド（一部削除）
  late TextUIComponent _statusText;
  late GameComponent _testCircle;
  late ParticleEffectManager _particleEffectManager;
  late ButtonUIComponent _settingsButton;
  int _sessionCount = 0;
  bool _hasPlayingAnimationRun = false;
  bool _bgmStarted = false;
  
  SimpleGame() : super(
    configuration: SimpleGameConfiguration.defaultConfig,
    debugMode: false,
  ) {
    // プリセットの初期化
    SimpleGameConfigPresets.initialize();
  }
  
  @override
  GameStateProvider<GameState> createStateProvider() {
    return SimpleGameStateProvider();
  }

  @override
  AudioProvider createAudioProvider() {
    return AudioPlayersProvider();
  }

  @override
  AdProvider createAdProvider() {
    // Web環境ではMockプロバイダーを使用
    if (kIsWeb) {
      return MockAdProvider();
    }
    return GoogleAdProvider();
  }

  @override
  AnalyticsProvider createAnalyticsProvider() {
    // Web環境ではConsoleプロバイダーを使用
    if (kIsWeb) {
      return ConsoleAnalyticsProvider();
    }
    return FirebaseAnalyticsProvider();
  }

  @override
  Future<void> initializeGame() async {
    // 音声システムの初期化
    await _initializeAudio();
    
    // UIテーマ初期化
    themeManager.initializeDefaultThemes();
    themeManager.setTheme('game');
    
    // 状態変更リスナーを追加
    stateProvider.addListener(_onStateChanged);
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // RouterComponent初期化
    router = RouterComponent(
      routes: _createRoutes(),
      initialRoute: 'start',
    );
    add(router);
    
    // パーティクルエフェクトマネージャーの初期化と追加
    _particleEffectManager = ParticleEffectManager();
    _particleEffectManager.priority = UILayerPriority.gameContent;
    add(_particleEffectManager);
    
    // テスト用ゲームオブジェクト作成（使用しない）
    _testCircle = GameComponent(
      position: Vector2(size.x / 2, size.y / 2 + 100),
      size: Vector2(80, 80),
      anchor: Anchor.center,
    );
    _testCircle.paint.color = Colors.blue;
    _testCircle.paint.style = PaintingStyle.fill;
  }

  @override
  void onMount() {
    super.onMount();
    
    // RouterComponentが初期化済みなので、onMountでの画面作成は不要
    // RouterComponentが自動的に初期ルートを表示
  }
  
  /// ルート作成メソッド
  Map<String, Route> _createRoutes() {
    return {
      'start': Route(() => StartScreenComponent()),
      'playing': Route(() {
        _playingScreen = PlayingScreenComponent();
        return _playingScreen!;
      }),
      'gameOver': Route(() => GameOverScreenComponent(sessionCount: _sessionCount)),
      'settings': OverlayRoute(_buildSettingsDialog),
    };
  }
  
  /// Settings ダイアログビルダー
  Widget _buildSettingsDialog(BuildContext context, Game game) {
    return Container(
      color: Colors.black.withOpacity(0.8), // 背景マスク
      child: Center(
        child: SettingsMenuWidget(
          onDifficultyChanged: (difficulty) {
            _applyConfiguration(difficulty);
            router.pop();
          },
          onClosePressed: () => router.pop(),
        ),
      ),
    );
  }

  @override
  void onTapDown(TapDownEvent event) {
    final state = stateProvider.currentState;
    final tapPosition = event.canvasPosition;
    
    if (state is SimpleGamePlayingState) {
      // PlayingScreenComponentのサークルタップ処理
      if (_playingScreen != null && _playingScreen!.isMounted) {
        _playingScreen!.handleCircleTap(tapPosition);
      }
    }
    // 他の画面のタップ処理はRouterComponentが管理
  }

  @override
  void update(double dt) {
    final mainTimer = timerManager.getTimer('main');
    if (mainTimer != null && mainTimer.isRunning) {
      mainTimer.update(dt);
      
      if (stateProvider.currentState is SimpleGamePlayingState) {
        final remaining = mainTimer.current.inMilliseconds / 1000.0;
        (stateProvider as SimpleGameStateProvider).updateTimer(remaining);
        
        // PlayingScreenComponentのタイマー更新
        if (_playingScreen != null && _playingScreen!.isMounted) {
          _playingScreen!.updateTimer(remaining);
        }
        
        // タイマーが終了した場合、ゲームオーバー処理を実行
        if (remaining <= 0) {
          _endGame();
        }
      }
    }
    
    super.update(dt);
  }

  
  // BGM開始処理（ユーザーインタラクション後に実行）
  void _startBgm() {
    try {
      audioManager.playBgm('menu_bgm');
      print('🎵 BGM started after user interaction');
    } catch (e) {
      print('❌ BGM start failed: $e');
    }
  }
  
  // スタート画面作成
  void _createStartScreen() {
    // 既存の画面と背景をクリア
    if (_currentScreen != null) {
      _currentScreen!.removeFromParent();
    }
    if (_currentBackground != null) {
      _currentBackground!.removeFromParent();
    }
    
    // スタート画面背景（ゲーム直下に追加）
    _currentBackground = RectangleComponent(
      position: Vector2.zero(),
      size: size,
      paint: Paint()..color = Colors.indigo.withOpacity(0.3),
    );
    _currentBackground!.priority = UILayerPriority.background;
    add(_currentBackground!);
    
    _currentScreen = Component();
    _currentScreen!.priority = UILayerPriority.ui;
    
    // タイトルテキスト
    _statusText = TextUIComponent(
      text: 'Simple Game',
      styleId: 'xlarge',
      position: Vector2(size.x / 2, size.y / 2 - 50),
    );
    _statusText.anchor = Anchor.center;
    _currentScreen!.add(_statusText);
    
    // スタートボタン
    final startButton = ButtonUIComponent(
      text: 'START GAME',
      colorId: 'primary',
      position: Vector2(size.x / 2 - 100, size.y / 2 + 20),
      size: Vector2(200, 50),
      onPressed: () => _startGame(),
    );
    startButton.anchor = Anchor.topLeft;
    _currentScreen!.add(startButton);
    
    // 設定ボタン（右上配置）
    _settingsButton = ButtonUIComponent(
      text: 'Settings',
      colorId: 'secondary',
      position: UILayoutManager.topRight(size, Vector2(120, 40), 20),
      size: Vector2(120, 40),
      onPressed: () => _showConfigMenu(),
    );
    _settingsButton.anchor = Anchor.topLeft;
    _settingsButton.priority = UILayerPriority.ui; // UIボタンは背景より高い優先度
    _currentScreen!.add(_settingsButton);
    
    add(_currentScreen!);
  }
  
  // プレイ画面作成
  void _createPlayingScreen() {
    print('🎮 Creating playing screen...');
    
    if (_currentScreen != null) {
      _currentScreen!.removeFromParent();
    }
    if (_currentBackground != null) {
      _currentBackground!.removeFromParent();
    }
    
    // ゲーム背景（ゲーム直下に追加）
    _currentBackground = RectangleComponent(
      position: Vector2.zero(),
      size: size,
      paint: Paint()..color = Colors.indigo.withOpacity(0.3),
    );
    _currentBackground!.priority = UILayerPriority.background;
    add(_currentBackground!);
    
    _currentScreen = Component();
    _currentScreen!.priority = UILayerPriority.ui;
    
    // タイマー背景
    final timerBg = RectangleComponent(
      position: Vector2(size.x / 2 - 100, 25),
      size: Vector2(200, 50),
      paint: Paint()..color = Colors.black.withOpacity(0.8),
    );
    _currentScreen!.add(timerBg);
    
    // ゲームタイマー表示
    _statusText = TextUIComponent(
      text: 'TIME: 5.0',
      styleId: 'xlarge',
      position: Vector2(size.x / 2, 50),
    );
    _statusText.anchor = Anchor.center;
    _statusText.setTextColor(Colors.white);
    _currentScreen!.add(_statusText);
    
    // ゲームオブジェクトを安全に移動
    if (_testCircle.isMounted) {
      _testCircle.removeFromParent();
    }
    _testCircle.position = Vector2(size.x / 2, size.y / 2 + 100);
    _currentScreen!.add(_testCircle);
    
    // ゲーム説明テキスト
    final instructionText = TextUIComponent(
      text: 'TAP THE BLUE CIRCLE',
      styleId: 'medium',
      position: Vector2(size.x / 2, size.y / 2 - 50),
    );
    instructionText.anchor = Anchor.center;
    instructionText.setTextColor(Colors.white);
    _currentScreen!.add(instructionText);
    
    add(_currentScreen!);
    
    print('🎮 Playing screen created successfully');
  }
  
  // ゲームオーバー画面作成
  void _createGameOverScreen() {
    print('🎮 Creating game over screen...');
    
    if (_currentScreen != null) {
      _currentScreen!.removeFromParent();
    }
    if (_currentBackground != null) {
      _currentBackground!.removeFromParent();
    }
    
    // ゲームオーバー背景（ゲーム直下に追加）
    _currentBackground = RectangleComponent(
      position: Vector2.zero(),
      size: size,
      paint: Paint()..color = Colors.red.withOpacity(0.8),
    );
    _currentBackground!.priority = UILayerPriority.background;
    add(_currentBackground!);
    
    _currentScreen = Component();
    _currentScreen!.priority = UILayerPriority.ui;
    
    // ゲームオーバーテキスト
    _statusText = TextUIComponent(
      text: 'GAME OVER\nSession: $_sessionCount',
      styleId: 'large',
      position: Vector2(size.x / 2, size.y / 2 - 50),
    );
    _statusText.anchor = Anchor.center;
    _statusText.setTextColor(Colors.white);
    _currentScreen!.add(_statusText);
    
    // リスタートボタン
    final restartButton = ButtonUIComponent(
      text: 'RESTART',
      colorId: 'primary',
      position: Vector2(size.x / 2 - 100, size.y / 2 + 20),
      size: Vector2(200, 50),
      onPressed: () => _restartGame(),
    );
    restartButton.anchor = Anchor.topLeft;
    _currentScreen!.add(restartButton);
    
    // 設定ボタン（右上配置）
    _settingsButton = ButtonUIComponent(
      text: 'Settings',
      colorId: 'secondary',
      position: UILayoutManager.topRight(size, Vector2(120, 40), 20),
      size: Vector2(120, 40),
      onPressed: () => _showConfigMenu(),
    );
    _settingsButton.anchor = Anchor.topLeft;
    _settingsButton.priority = UILayerPriority.ui; // UIボタンは背景より高い優先度
    _currentScreen!.add(_settingsButton);
    
    add(_currentScreen!);
    
    print('🎮 Game over screen created successfully');
  }

  
  // 設定適用（簡素化）
  void _applyConfiguration(String configKey) {
    final newConfig = SimpleGameConfigPresets.getPreset(configKey);
    if (newConfig != null) {
      configuration.updateConfig(newConfig);
      audioManager.playSfx('tap', volumeMultiplier: 0.5);
      print('🎮 Configuration applied: $configKey');
    }
  }

  void _startGame() {
    // ゲーム開始音を再生
    audioManager.playSfx('success', volumeMultiplier: 1.0);
    
    final config = configuration.config;
    (stateProvider as SimpleGameStateProvider).startGame(config.gameDuration.inMilliseconds / 1000.0);
    
    timerManager.addTimer('main', TimerConfiguration(
      duration: config.gameDuration,
      type: TimerType.countdown,
      onComplete: () => _endGame(),
    ));
    
    timerManager.getTimer('main')?.start();
    _sessionCount++;
    
    // RouterComponentによる画面遷移
    router.pushNamed('playing');
  }

  void _restartGame() {
    // リスタート音を再生
    audioManager.playSfx('success', volumeMultiplier: 0.8);
    
    final config = configuration.config;
    (stateProvider as SimpleGameStateProvider).restart(config.gameDuration.inMilliseconds / 1000.0);
    
    // タイマーを再作成
    timerManager.addTimer('main', TimerConfiguration(
      duration: config.gameDuration,
      type: TimerType.countdown,
      onComplete: () => _endGame(),
    ));
    
    timerManager.getTimer('main')?.start();
    _sessionCount++;
  }

  void _endGame() {
    final finalTime = timerManager.getTimer('main')?.current.inMilliseconds ?? 0;
    
    // ゲームオーバー音を再生
    audioManager.playSfx('error', volumeMultiplier: 0.9);
    
    // タイマー終了時は残り時間を0にしてゲームオーバー状態にする
    (stateProvider as SimpleGameStateProvider).updateTimer(0.0);
    
    // ゲームオーバー画面遷移
    router.pushNamed('gameOver');
  }
  
  /// publicメソッドとしてrestartGameを公開（GameOverScreenComponentから呼び出し用）
  void restartGame() {
    _restartGame();
  }

  // 音声システムの初期化（GameAudioHelperを使用）
  Future<void> _initializeAudio() async {
    try {
      await GameAudioIntegration.setupAudio(
        audioManager: audioManager,
        bgmFiles: {
          'menu_bgm': 'menu.mp3',
        },
        sfxFiles: {
          'tap': 'tap.wav',
          'success': 'success.wav',
          'error': 'error.wav',
        },
        masterVolume: 1.0,
        bgmVolume: 0.6,
        sfxVolume: 0.8,
        debugMode: true,
      );
      
      print('🎵 Audio system initialized with GameAudioHelper');
      print('🎵 BGM will start on first user interaction');
    } catch (e) {
      print('❌ Audio initialization failed: $e');
    }
  }

  void _onStateChanged() {
    final state = stateProvider.currentState;
    final config = configuration.config;
    
    // 非同期でコンポーネント操作を実行し、マウント競合を回避
    Future.delayed(Duration(milliseconds: 50), () {
      if (!isMounted) return;
      
      try {
        if (state is SimpleGameStartState) {
          _createStartScreen();
          if (_statusText.isMounted) {
            _statusText.setText(config.getStateText('start'));
            // スタート時のエフェクト
            AnimationPresets.popIn(_statusText as PositionComponent);
          }
          _hasPlayingAnimationRun = false;
        } else if (state is SimpleGamePlayingState) {
          // プレイ画面は一度だけ作成
          if (!_hasPlayingAnimationRun) {
            _createPlayingScreen();
            _hasPlayingAnimationRun = true; // 作成後すぐにフラグを設定
          }
          // ここではテキスト更新は行わない（updateメソッドで実行）
          
          // プレイ開始時のアニメーション（一度だけ実行する場合）
          // _hasPlayingAnimationRunは画面作成時にtrueに設定済み
        } else if (state is SimpleGameOverState) {
          _createGameOverScreen();
          if (_statusText.isMounted) {
            _statusText.setText('${config.getStateText('gameOver')}\nSession: $_sessionCount\nTAP TO RESTART');
            _statusText.setTextColor(config.getStateColor('gameOver'));
          }
          
          // ゲームオーバーアニメーション
          if (_testCircle.isMounted) {
            _testCircle.animateShake(intensity: 20.0);
          }
        }
      } catch (e) {
        print('❌ State change error: $e');
      }
    });
  }
}