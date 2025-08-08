import 'package:flame/events.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../framework/core/configurable_game.dart';
import '../../framework/state/game_state_system.dart';
import '../../framework/timer/flame_timer_system.dart';
import '../../framework/ui/ui_system.dart';
import 'simple_game_states.dart';
import 'simple_game_configuration.dart';

/// SimpleGame のフレームワーク統合版
/// 汎用フレームワークを使用して従来のSimpleGameを再実装
class SimpleGameFramework extends ConfigurableGame<GameState, SimpleGameConfig> with TapCallbacks {
  
  // UI コンポーネント
  late TextUIComponent _statusText;
  late ProgressBarUIComponent _timerProgress;
  bool _isUIInitialized = false;
  
  // ゲーム状態
  int _currentSessionNumber = 0;
  
  // ビルダーパターン用の保留テーマ
  String? _pendingTheme;
  
  SimpleGameFramework({
    SimpleGameConfiguration? configuration,
    super.debugMode = false,
  }) : super(
    configuration: configuration ?? SimpleGameConfiguration.defaultConfig,
  );
  
  @override
  Future<void> initializeGame() async {
    // タイマーの初期化（size不要）
    await _setupTimers();
    
    // 状態変更リスナーの設定
    _setupStateListeners();
    
    debugPrint('SimpleGameFramework initialized');
  }
  
  @override
  void onMount() {
    super.onMount();
    
    // 保留中のテーマを適用
    if (_pendingTheme != null) {
      themeManager.setTheme(_pendingTheme!);
      _pendingTheme = null;
    }
    
    // UIコンポーネントの初期化（sizeが利用可能になってから）
    if (hasLayout) {
      _setupUI();
    }
  }
  
  @override
  GameStateProvider<GameState> createStateProvider() {
    return SimpleGameStateProvider();
  }
  
  /// UI コンポーネントのセットアップ
  Future<void> _setupUI() async {
    // ステータステキスト
    _statusText = TextUIComponent(
      text: config.getStateText('start'),
      styleId: 'large',
      position: size / 2,
      themeId: 'game',
    );
    _statusText.anchor = Anchor.center;
    add(_statusText);
    
    // タイマープログレスバー
    _timerProgress = ProgressBarUIComponent(
      progress: 1.0,
      position: Vector2(size.x / 2 - 100, size.y / 2 + 50),
      size: Vector2(200, 20),
    );
    add(_timerProgress);
    
    // 初期状態では非表示
    // _timerProgress.opacity = 0.0; // ProgressBarUIComponentにopacityプロパティが未実装
    
    // UI初期化完了フラグを設定
    _isUIInitialized = true;
  }
  
  /// タイマーのセットアップ
  Future<void> _setupTimers() async {
    timerManager.addTimer('main', TimerConfiguration(
      duration: config.gameDuration,
      type: TimerType.countdown,
      onUpdate: _onTimerUpdate,
      onComplete: _onTimerComplete,
    ));
  }
  
  /// 状態変更リスナーのセットアップ  
  void _setupStateListeners() {
    stateProvider.addListener(_onStateChanged);
  }
  
  /// 状態変更時のハンドラ
  void _onStateChanged() {
    final state = stateProvider.currentState;
    debugPrint('State changed to: ${state.name}');
    
    // UI更新
    _updateUI(state);
  }
  
  /// UI更新
  void _updateUI(GameState state) {
    // UI コンポーネントが初期化されていない場合はスキップ
    if (!_isUIInitialized) return;
    
    switch (state) {
      case SimpleGameStartState _:
        _statusText.setText(config.getStateText('start'));
        _statusText.setTextColor(config.getStateColor('start'));
        // _timerProgress.opacity = 0.0; // opacityプロパティ未実装
        
      case SimpleGamePlayingState playingState:
        final timeText = config.getStateText('playing', timeRemaining: playingState.timeRemaining);
        _statusText.setText(timeText);
        _statusText.setTextColor(config.getDynamicColor('playing', timeRemaining: playingState.timeRemaining));
        // _timerProgress.opacity = 1.0; // opacityプロパティ未実装
        
        // プログレスバー更新
        final progress = playingState.timeRemaining / config.gameDuration.inMilliseconds * 1000;
        _timerProgress.setProgress(progress);
        
      case SimpleGameOverState gameOverState:
        _statusText.setText(config.getStateText('gameOver'));
        _statusText.setTextColor(config.getStateColor('gameOver'));
        // _timerProgress.opacity = 0.0; // opacityプロパティ未実装
        
        // セッション統計を記録
        trackGameSession();
        debugPrint('Game Over - Session ${gameOverState.sessionNumber} completed');
    }
  }
  
  /// タイマー更新ハンドラ
  void _onTimerUpdate(Duration remaining) {
    if (stateProvider.currentState is SimpleGamePlayingState) {
      final simpleStateProvider = stateProvider as SimpleGameStateProvider;
      simpleStateProvider.updateTimer(remaining.inMilliseconds / 1000.0);
    }
  }
  
  /// タイマー完了ハンドラ
  void _onTimerComplete() {
    if (stateProvider.currentState is SimpleGamePlayingState) {
      final simpleStateProvider = stateProvider as SimpleGameStateProvider;
      final currentState = simpleStateProvider.currentState as SimpleGamePlayingState;
      
      final gameOverState = SimpleGameStateFactory.createGameOverState(
        finalTime: 0.0,
        sessionNumber: currentState.sessionNumber,
      );
      
      simpleStateProvider.transitionTo(gameOverState);
    }
  }
  
  @override
  void onTapDown(TapDownEvent event) {
    if (!isInitialized) return;
    
    final state = stateProvider.currentState;
    // final simpleStateProvider = this.stateProvider as SimpleGameStateProvider;
    
    switch (state) {
      case SimpleGameStartState _:
        _startGame();
        
      case SimpleGamePlayingState _:
        // ゲーム中はタップ無効
        debugPrint('Game in progress - tap ignored');
        
      case SimpleGameOverState _:
        _restartGame();
    }
  }
  
  /// ゲーム開始
  void _startGame() {
    final simpleStateProvider = stateProvider as SimpleGameStateProvider;
    final initialTime = config.gameDuration.inMilliseconds / 1000.0;
    
    if (simpleStateProvider.startGame(initialTime)) {
      // タイマー開始
      timerManager.resetTimer('main');
      timerManager.startTimer('main');
      
      debugPrint('Game started - Session ${_currentSessionNumber + 1}');
    }
  }
  
  /// ゲーム再開
  void _restartGame() {
    final simpleStateProvider = stateProvider as SimpleGameStateProvider;
    final initialTime = config.gameDuration.inMilliseconds / 1000.0;
    
    if (simpleStateProvider.restart(initialTime)) {
      // タイマー再開
      timerManager.resetTimer('main');
      timerManager.startTimer('main');
      
      _currentSessionNumber++;
      debugPrint('Game restarted - Session $_currentSessionNumber');
    }
  }
  
  @override
  void onConfigurationChanged(SimpleGameConfig oldConfig, SimpleGameConfig newConfig) {
    super.onConfigurationChanged(oldConfig, newConfig);
    
    // タイマー設定の更新
    timerManager.updateTimerConfig('main', TimerConfiguration(
      duration: newConfig.gameDuration,
      type: TimerType.countdown,
      onUpdate: _onTimerUpdate,
      onComplete: _onTimerComplete,
    ));
    
    // UI設定の更新
    _updateUI(stateProvider.currentState);
    
    debugPrint('Configuration updated: ${oldConfig.gameDuration} -> ${newConfig.gameDuration}');
  }
  
  @override
  void onGameStart() {
    super.onGameStart();
    trackEvent('game_start', {
      'session_number': _currentSessionNumber,
      'config_duration': config.gameDuration.inSeconds,
    });
  }
  
  @override
  void onGamePause() {
    super.onGamePause();
    trackEvent('game_pause', {
      'session_number': _currentSessionNumber,
      'current_state': stateProvider.currentState.name,
    });
  }
  
  @override
  void onGameResume() {
    super.onGameResume();
    trackEvent('game_resume', {
      'session_number': _currentSessionNumber,
      'current_state': stateProvider.currentState.name,
    });
  }
  
  @override
  void onGameStop() {
    super.onGameStop();
    trackEvent('game_stop', {
      'session_number': _currentSessionNumber,
      'final_state': stateProvider.currentState.name,
    });
  }
  
  @override
  void onGameReset() {
    super.onGameReset();
    _currentSessionNumber = 0;
    trackEvent('game_reset', {
      'total_sessions': _currentSessionNumber,
    });
  }
  
  /// ゲーム統計情報を取得
  Map<String, dynamic> getGameStatistics() {
    final simpleStateProvider = stateProvider as SimpleGameStateProvider;
    final gameInfo = simpleStateProvider.getCurrentGameInfo();
    
    return {
      ...gameInfo,
      'total_sessions': _currentSessionNumber,
      'framework_stats': simpleStateProvider.getStatistics().toJson(),
      'timer_status': timerManager.getDebugInfo(),
    };
  }
  
  /// プリセット設定の適用
  void applyPreset(String presetName) {
    final preset = SimpleGameConfigPresets.getPreset(presetName);
    if (preset != null) {
      applyConfiguration(preset);
      
      debugPrint('Preset applied: $presetName');
    } else {
      debugPrint('Unknown preset: $presetName');
    }
  }
  
  /// A/Bテスト設定の適用
  void applyABTestConfig(String variantId) {
    applyABTestVariant('game_config', variantId);
  }
}

/// SimpleGameFramework のビルダー
class SimpleGameFrameworkBuilder {
  SimpleGameConfiguration? _configuration;
  bool _debugMode = false;
  String? _preset;
  String? _theme;
  
  /// 設定を指定
  SimpleGameFrameworkBuilder withConfiguration(SimpleGameConfiguration configuration) {
    _configuration = configuration;
    return this;
  }
  
  /// プリセットを指定  
  SimpleGameFrameworkBuilder withPreset(String presetName) {
    _preset = presetName;
    return this;
  }
  
  /// テーマを指定
  SimpleGameFrameworkBuilder withTheme(String themeName) {
    _theme = themeName;
    return this;
  }
  
  /// デバッグモードを有効化
  SimpleGameFrameworkBuilder withDebugMode(bool enabled) {
    _debugMode = enabled;
    return this;
  }
  
  /// ゲームを構築
  SimpleGameFramework build() {
    // プリセット設定の適用
    if (_preset != null && _configuration == null) {
      _configuration = SimpleGameConfigPresets.getConfigurationPreset(_preset!);
    }
    
    final game = SimpleGameFramework(
      configuration: _configuration,
      debugMode: _debugMode,
    );
    
    // テーマの設定は初期化後に行う
    if (_theme != null) {
      game._pendingTheme = _theme;
    }
    
    return game;
  }
}

/// SimpleGameFramework のファクトリー
class SimpleGameFrameworkFactory {
  /// デフォルト設定でゲームを作成
  static SimpleGameFramework createDefault() {
    return SimpleGameFrameworkBuilder().build();
  }
  
  /// イージーモードでゲームを作成
  static SimpleGameFramework createEasyMode() {
    return SimpleGameFrameworkBuilder()
        .withPreset('easy')
        .withTheme('game')
        .build();
  }
  
  /// ハードモードでゲームを作成
  static SimpleGameFramework createHardMode() {
    return SimpleGameFrameworkBuilder()
        .withPreset('hard')
        .withTheme('game')
        .build();
  }
  
  /// デバッグモードでゲームを作成
  static SimpleGameFramework createDebugMode() {
    return SimpleGameFrameworkBuilder()
        .withDebugMode(true)
        .withTheme('game')
        .build();
  }
  
  /// カスタム設定でゲームを作成
  static SimpleGameFramework createCustom({
    SimpleGameConfiguration? configuration,
    String? preset,
    String? theme,
    bool debugMode = false,
  }) {
    final builder = SimpleGameFrameworkBuilder()
        .withDebugMode(debugMode);
    
    if (configuration != null) {
      builder.withConfiguration(configuration);
    }
    
    if (preset != null) {
      builder.withPreset(preset);
    }
    
    if (theme != null) {
      builder.withTheme(theme);
    }
    
    return builder.build();
  }
}