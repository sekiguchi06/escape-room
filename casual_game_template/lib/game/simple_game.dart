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
import 'framework_integration/simple_game_states.dart';
import 'framework_integration/simple_game_configuration.dart';

class SimpleGame extends ConfigurableGame<GameState, SimpleGameConfig> with TapDetector {
  late final SimpleGameStateProvider _stateProvider;
  late final SimpleGameConfiguration _configuration;
  late final TimerManager _timerManager;
  late final ThemeManager _themeManager;
  
  late TextComponent _statusText;
  late TextComponent _configText;
  int _sessionCount = 0;

  @override
  GameStateProvider<GameState> get stateProvider => _stateProvider;
  
  @override
  GameConfiguration<GameState, SimpleGameConfig> get configuration => _configuration;
  
  @override
  TimerManager get timerManager => _timerManager;
  
  @override
  ThemeManager get themeManager => _themeManager;

  @override
  Future<void> onLoad() async {
    _stateProvider = SimpleGameStateProvider();
    _configuration = SimpleGameConfiguration.defaultConfig;
    _timerManager = TimerManager();
    _themeManager = ThemeManager();
    
    _themeManager.initializeDefaultThemes();
    
    _statusText = TextComponent(
      text: 'TAP TO START',
      position: Vector2(size.x / 2, size.y / 2),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: TextStyle(
          fontSize: 24,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    add(_statusText);
    
    _configText = TextComponent(
      text: 'Config: Default',
      position: Vector2(20, 20),
      textRenderer: TextPaint(
        style: TextStyle(
          fontSize: 14,
          color: Colors.yellow,
        ),
      ),
    );
    add(_configText);
    
    _stateProvider.addListener(_onStateChanged);
    
    await super.onLoad();
  }

  @override
  void update(double dt) {
    final mainTimer = _timerManager.getTimer('main');
    if (mainTimer != null && mainTimer.isRunning) {
      mainTimer.update(dt);
      
      if (_stateProvider.currentState is SimpleGamePlayingState) {
        final remaining = mainTimer.current.inMilliseconds / 1000.0;
        _stateProvider.updateTimer(remaining);
      }
    }
    
    super.update(dt);
  }

  @override
  bool onTapDown(TapDownInfo info) {
    final state = _stateProvider.currentState;
    
    if (state is SimpleGameStartState) {
      _startGame();
    } else if (state is SimpleGameOverState) {
      _restartGame();
    }
    
    return true;
  }

  void switchConfig() {
    final configs = ['default', 'easy', 'hard'];
    final currentIndex = configs.indexOf(_configuration.currentPreset);
    final nextIndex = (currentIndex + 1) % configs.length;
    final nextConfig = configs[nextIndex];
    
    _configuration = SimpleGameConfigPresets.getConfigurationPreset(nextConfig);
    _configText.text = 'Config: $nextConfig';
    
    _timerManager.removeTimer('main');
  }

  void _startGame() {
    switchConfig();
    
    final config = _configuration.config;
    _stateProvider.startGame(config.gameDuration.inMilliseconds / 1000.0);
    
    _timerManager.addTimer('main', TimerConfiguration(
      duration: config.gameDuration,
      type: TimerType.countdown,
      onComplete: () => _endGame(),
    ));
    
    _timerManager.getTimer('main')?.start();
    _sessionCount++;
  }

  void _restartGame() {
    _stateProvider.restart(_configuration.config.gameDuration.inMilliseconds / 1000.0);
    _timerManager.getTimer('main')?.reset();
    _timerManager.getTimer('main')?.start();
    _sessionCount++;
  }

  void _endGame() {
    final finalTime = _timerManager.getTimer('main')?.current.inMilliseconds ?? 0;
    _stateProvider.updateTimer(finalTime / 1000.0);
  }

  void _onStateChanged() {
    final state = _stateProvider.currentState;
    final config = _configuration.config;
    
    if (state is SimpleGameStartState) {
      _statusText.text = config.getStateText('start');
      _statusText.textRenderer = TextPaint(
        style: TextStyle(
          fontSize: config.getFontSize('start'),
          color: config.getStateColor('start'),
          fontWeight: config.getFontWeight('start'),
        ),
      );
    } else if (state is SimpleGamePlayingState) {
      final dynamicText = config.getStateText('playing', timeRemaining: state.timeRemaining);
      _statusText.text = dynamicText;
      _statusText.textRenderer = TextPaint(
        style: TextStyle(
          fontSize: config.getFontSize('playing'),
          color: config.getDynamicColor('playing', timeRemaining: state.timeRemaining),
          fontWeight: config.getFontWeight('playing'),
        ),
      );
    } else if (state is SimpleGameOverState) {
      _statusText.text = '${config.getStateText('gameOver')}\nSession: $_sessionCount';
      _statusText.textRenderer = TextPaint(
        style: TextStyle(
          fontSize: config.getFontSize('gameOver'),
          color: config.getStateColor('gameOver'),
          fontWeight: config.getFontWeight('gameOver'),
        ),
      );
    }
  }
}