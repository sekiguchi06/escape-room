import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../framework/state/game_state_system.dart';
import '../framework/config/game_configuration.dart';
import '../framework/timer/timer_system.dart';
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
import '../framework/ui/ui_system.dart';
import 'framework_integration/simple_game_states.dart';
import 'framework_integration/simple_game_configuration.dart';

class SimpleGame extends ConfigurableGame<GameState, SimpleGameConfig> with TapCallbacks {
  late TextUIComponent _statusText;
  late GameComponent _testCircle;
  late ParticleEffectManager _particleEffectManager;
  late ButtonUIComponent _settingsButton;
  Component? _currentScreen;
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
    
    // パーティクルエフェクトマネージャーの初期化と追加
    _particleEffectManager = ParticleEffectManager();
    add(_particleEffectManager);
    
    // テスト用ゲームオブジェクト作成（画面に追加はしない）
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
    
    // ゲームがマウントされた後に初期画面作成と状態変更を実行
    _createStartScreen();
    _onStateChanged();
  }

  @override
  void update(double dt) {
    final mainTimer = timerManager.getTimer('main');
    if (mainTimer != null && mainTimer.isRunning) {
      mainTimer.update(dt);
      
      if (stateProvider.currentState is SimpleGamePlayingState) {
        final remaining = mainTimer.current.inMilliseconds / 1000.0;
        (stateProvider as SimpleGameStateProvider).updateTimer(remaining);
        
        // タイマー表示を直接更新
        if (_statusText.isMounted) {
          _statusText.setText('TIME: ${remaining.toStringAsFixed(1)}');
          _statusText.setTextColor(Colors.white);
          print('⏰ Timer updated: ${remaining.toStringAsFixed(1)}');
        }
        
        // タイマーが終了した場合、ゲームオーバー処理を実行
        if (remaining <= 0) {
          _endGame();
        }
      }
    }
    
    super.update(dt);
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    
    // 最初のタップでBGM開始
    if (!_bgmStarted) {
      _startBgm();
      _bgmStarted = true;
    }
    
    final state = stateProvider.currentState;
    final tapPosition = event.localPosition;
    
    // 状態に応じたタップ処理
    if (state is SimpleGameStartState) {
      _handleStartScreenTap(tapPosition);
    } else if (state is SimpleGamePlayingState) {
      _handlePlayingScreenTap(tapPosition);
    } else if (state is SimpleGameOverState) {
      _handleGameOverScreenTap(tapPosition);
    }
  }
  
  // スタート画面のタップ処理
  void _handleStartScreenTap(Vector2 tapPosition) {
    // 設定ボタンのタップ判定
    if (_isButtonTapped(_settingsButton, tapPosition)) {
      // ボタンが処理するため、背景処理はスキップ
      return;
    }
    
    // 設定ボタン以外の場所をタップした場合はゲーム開始
    _startGame();
  }
  
  // プレイ画面のタップ処理
  void _handlePlayingScreenTap(Vector2 tapPosition) {
    // テストサークルのタップ判定
    final circleCenter = _testCircle.position;
    final distance = (tapPosition - circleCenter).length;
    
    if (distance <= _testCircle.size.x / 2) {
      AnimationPresets.buttonTap(_testCircle);
      audioManager.playSfx('tap', volumeMultiplier: 0.7);
      // パーティクルエフェクトは一時的に無効化
      // if (_particleEffectManager.isMounted) {
      //   _particleEffectManager.playEffect('explosion', tapPosition);
      // }
    }
  }
  
  // ゲームオーバー画面のタップ処理
  void _handleGameOverScreenTap(Vector2 tapPosition) {
    // 設定ボタンチェック
    if (_isButtonTapped(_settingsButton, tapPosition)) {
      _showConfigMenu();
      return;
    }
    
    // その他の場所をタップした場合はリスタート
    _restartGame();
  }
  
  // ボタンタップ判定
  bool _isButtonTapped(ButtonUIComponent button, Vector2 tapPosition) {
    // ButtonUIComponentのアンカーを考慮した位置計算
    final buttonPos = button.position;
    final buttonSize = button.size;
    
    // anchor.topLeftの場合
    return tapPosition.x >= buttonPos.x &&
           tapPosition.x <= buttonPos.x + buttonSize.x &&
           tapPosition.y >= buttonPos.y &&
           tapPosition.y <= buttonPos.y + buttonSize.y;
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
    // 既存の画面をクリア
    if (_currentScreen != null) {
      _currentScreen!.removeFromParent();
    }
    
    _currentScreen = Component();
    
    // タイトルテキスト
    _statusText = TextUIComponent(
      text: 'TAP TO START',
      styleId: 'xlarge',
      position: Vector2(size.x / 2, size.y / 2),
    );
    _statusText.anchor = Anchor.center;
    _currentScreen!.add(_statusText);
    
    // 設定ボタン（右上配置）
    _settingsButton = ButtonUIComponent(
      text: 'Settings',
      colorId: 'secondary',
      position: UILayoutManager.topRight(size, Vector2(120, 40), 20),
      size: Vector2(120, 40),
      onPressed: () => _showConfigMenu(),
    );
    _settingsButton.anchor = Anchor.topLeft;
    _currentScreen!.add(_settingsButton);
    
    add(_currentScreen!);
  }
  
  // プレイ画面作成
  void _createPlayingScreen() {
    print('🎮 Creating playing screen...');
    
    if (_currentScreen != null) {
      _currentScreen!.removeFromParent();
    }
    
    _currentScreen = Component();
    
    // ゲーム背景（デバッグ用）
    final background = RectangleComponent(
      position: Vector2.zero(),
      size: size,
      paint: Paint()..color = Colors.indigo.withOpacity(0.3),
    );
    _currentScreen!.add(background);
    
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
    
    _currentScreen = Component();
    
    // ゲームオーバー背景
    final background = RectangleComponent(
      position: Vector2.zero(),
      size: size,
      paint: Paint()..color = Colors.red.withOpacity(0.2),
    );
    _currentScreen!.add(background);
    
    // ゲームオーバーテキスト
    _statusText = TextUIComponent(
      text: 'GAME OVER\nSession: $_sessionCount\nTAP TO RESTART',
      styleId: 'large',
      position: Vector2(size.x / 2, size.y / 2),
    );
    _statusText.anchor = Anchor.center;
    _statusText.setTextColor(Colors.white);
    _currentScreen!.add(_statusText);
    
    // 設定ボタン（右上配置）
    _settingsButton = ButtonUIComponent(
      text: 'Settings',
      colorId: 'secondary',
      position: UILayoutManager.topRight(size, Vector2(120, 40), 20),
      size: Vector2(120, 40),
      onPressed: () => _showConfigMenu(),
    );
    _settingsButton.anchor = Anchor.topLeft;
    _currentScreen!.add(_settingsButton);
    
    add(_currentScreen!);
    
    print('🎮 Game over screen created successfully');
  }

  // 設定メニュー表示
  void _showConfigMenu() {
    // オーバーレイ作成
    final overlay = RectangleComponent(
      position: Vector2.zero(),
      size: size,
      paint: Paint()..color = Colors.black.withOpacity(0.7),
    );
    overlay.priority = 1000;
    add(overlay);
    
    // メニューパネル
    final menuPanel = RectangleComponent(
      position: Vector2(size.x / 2, size.y / 2),
      size: Vector2(300, 250),
      anchor: Anchor.center,
      paint: Paint()..color = Colors.white,
    );
    overlay.add(menuPanel);
    
    // タイトル
    final titleText = TextUIComponent(
      text: 'Game Settings',
      styleId: 'large',
      position: Vector2(150, 40),
    );
    titleText.anchor = Anchor.center;
    titleText.setTextColor(Colors.black);
    menuPanel.add(titleText);
    
    // 設定ボタン群
    _createConfigButtons(menuPanel, overlay);
  }
  
  // 設定ボタン作成
  void _createConfigButtons(Component panel, Component overlay) {
    final configs = [
      {'name': 'Easy', 'key': 'easy'},
      {'name': 'Normal', 'key': 'default'},
      {'name': 'Hard', 'key': 'hard'},
    ];
    
    // 設定ボタン配置
    for (int i = 0; i < configs.length; i++) {
      final config = configs[i];
      final button = ButtonUIComponent(
        text: config['name'] as String,
        position: Vector2(60 + i * 80, 100),
        size: Vector2(70, 35),
        colorId: i == 0 ? 'success' : (i == 1 ? 'primary' : 'danger'),
        onPressed: () => _applyConfiguration(config['key'] as String, overlay),
      );
      button.anchor = Anchor.center;
      panel.add(button);
    }
    
    // 閉じるボタン
    final closeButton = ButtonUIComponent(
      text: 'Close',
      position: Vector2(150, 180),
      size: Vector2(100, 35),
      colorId: 'secondary',
      onPressed: () => overlay.removeFromParent(),
    );
    closeButton.anchor = Anchor.center;
    panel.add(closeButton);
  }
  
  // 設定適用
  void _applyConfiguration(String configKey, Component overlay) {
    final newConfig = SimpleGameConfigPresets.getPreset(configKey);
    if (newConfig != null) {
      configuration.updateConfig(newConfig);
      audioManager.playSfx('tap', volumeMultiplier: 0.5);
      print('🎮 Configuration applied: $configKey');
    }
    overlay.removeFromParent();
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