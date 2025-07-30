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
import '../framework/monetization/monetization_system.dart';
import '../framework/analytics/analytics_system.dart';
import '../framework/audio/providers/audioplayers_provider.dart';
import '../framework/monetization/providers/google_ad_provider.dart';
import '../framework/analytics/providers/firebase_analytics_provider.dart';
import 'framework_integration/simple_game_states.dart';
import 'framework_integration/simple_game_configuration.dart';

class SimpleGame extends ConfigurableGame<GameState, SimpleGameConfig> with TapCallbacks {
  late GameComponent _statusText;
  late GameComponent _configText;
  late GameComponent _testCircle;
  late GameComponent _buttonTestArea;
  int _sessionCount = 0;
  bool _hasPlayingAnimationRun = false;
  
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
    return GoogleAdProvider();
  }

  @override
  AnalyticsProvider createAnalyticsProvider() {
    return FirebaseAnalyticsProvider();
  }

  @override
  Future<void> initializeGame() async {
    // テキスト表示用GameComponent（透明度アニメーション対応）
    _statusText = GameComponent(
      position: Vector2(size.x / 2, size.y / 2),
      size: Vector2(200, 50),
      anchor: Anchor.center,
    );
    add(_statusText);
    
    // テキストコンポーネントをGameComponentの子として追加
    final statusTextChild = TextComponent(
      text: 'TAP TO START',
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: TextStyle(
          fontSize: 24,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    _statusText.add(statusTextChild);
    
    _configText = GameComponent(
      position: Vector2(20, 20),
      size: Vector2(150, 20),
    );
    add(_configText);
    
    final configTextChild = TextComponent(
      text: 'Config: Default',
      textRenderer: TextPaint(
        style: TextStyle(
          fontSize: 14,
          color: Colors.yellow,
        ),
      ),
    );
    _configText.add(configTextChild);
    
    // アニメーションテスト用の円 - タップボタンとして使用
    _testCircle = GameComponent(
      position: Vector2(size.x / 2, size.y / 2 + 100),
      size: Vector2(80, 80),
      anchor: Anchor.center,
    );
    _testCircle.paint.color = Colors.blue;
    add(_testCircle);
    
    // ボタンタップテスト用の領域を明示するための背景
    _buttonTestArea = GameComponent(
      position: Vector2(size.x / 2, size.y / 2 + 100),
      size: Vector2(120, 120),
      anchor: Anchor.center,
    );
    _buttonTestArea.paint.color = Colors.grey.withOpacity(0.3);
    add(_buttonTestArea);
    
    // 状態変更リスナーを追加
    stateProvider.addListener(_onStateChanged);
    
    // 初期状態でも_onStateChangedを呼び出し
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
    // フレームワークの入力処理を先に実行
    super.onTapDown(event);
    
    final state = stateProvider.currentState;
    
    // 青い円をタップした場合のButtonTapアニメーションテスト
    final tapPosition = event.localPosition;
    final circleCenter = _testCircle.position;
    final distance = (tapPosition - circleCenter).length;
    
    if (distance <= _testCircle.size.x / 2) {
      AnimationPresets.buttonTap(_testCircle);
    }
    
    if (state is SimpleGameStartState) {
      _startGame();
    } else if (state is SimpleGameOverState) {
      _restartGame();
    }
  }

  void switchConfig() {
    final configs = ['default', 'easy', 'hard'];
    // セッション数に基づいて設定を循環
    final configIndex = _sessionCount % configs.length;
    final nextConfig = configs[configIndex];
    
    final newConfig = SimpleGameConfigPresets.getPreset(nextConfig);
    if (newConfig != null) {
      configuration.updateConfig(newConfig);
      final configTextChild = _configText.children.whereType<TextComponent>().firstOrNull;
      if (configTextChild != null) {
        configTextChild.text = 'Config: $nextConfig';
      }
    }
    
    timerManager.removeTimer('main');
  }

  void _startGame() {
    switchConfig();
    
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
    switchConfig();
    
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
    // タイマー終了時は残り時間を0にしてゲームオーバー状態にする
    (stateProvider as SimpleGameStateProvider).updateTimer(0.0);
  }

  void _onStateChanged() {
    final state = stateProvider.currentState;
    final config = configuration.config;
    final statusTextChild = _statusText.children.whereType<TextComponent>().firstOrNull;
    
    if (statusTextChild != null) {
      if (state is SimpleGameStartState) {
        statusTextChild.text = config.getStateText('start');
        statusTextChild.textRenderer = TextPaint(
          style: TextStyle(
            fontSize: config.getFontSize('start'),
            color: config.getStateColor('start'),
            fontWeight: config.getFontWeight('start'),
          ),
        );
        // AnimationPresets使用 - PopInアニメーション
        AnimationPresets.popIn(_statusText);
        AnimationPresets.popIn(_testCircle);
        _hasPlayingAnimationRun = false;
      } else if (state is SimpleGamePlayingState) {
        final dynamicText = config.getStateText('playing', timeRemaining: state.timeRemaining);
        statusTextChild.text = dynamicText;
        statusTextChild.textRenderer = TextPaint(
          style: TextStyle(
            fontSize: config.getFontSize('playing'),
            color: config.getDynamicColor('playing', timeRemaining: state.timeRemaining),
            fontWeight: config.getFontWeight('playing'),
          ),
        );
        // AnimationPresets使用 - SlideInアニメーション（1回のみ実行）
        if (!_hasPlayingAnimationRun) {
          AnimationPresets.slideInFromLeft(_testCircle, size.x);
          _testCircle.animateRotateBy(
            6.28318, // 2π
            config: const AnimationConfig(duration: Duration(milliseconds: 2000)),
          );
          _hasPlayingAnimationRun = true;
        }
      } else if (state is SimpleGameOverState) {
        statusTextChild.text = '${config.getStateText('gameOver')}\nSession: $_sessionCount';
        statusTextChild.textRenderer = TextPaint(
          style: TextStyle(
            fontSize: config.getFontSize('gameOver'),
            color: config.getStateColor('gameOver'),
            fontWeight: config.getFontWeight('gameOver'),
          ),
        );
        // ゲームオーバーアニメーション
        _statusText.animateFadeOut(
          config: const AnimationConfig(duration: Duration(milliseconds: 200)),
        );
        _testCircle.animateShake(intensity: 20.0);
        _testCircle.animateFadeOut(
          config: const AnimationConfig(duration: Duration(milliseconds: 500)),
        );
      }
    }
  }
}