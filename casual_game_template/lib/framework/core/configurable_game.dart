import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../config/game_configuration.dart';
import '../state/game_state_system.dart';
import '../timer/timer_system.dart';
import '../ui/ui_system.dart';
import '../audio/audio_system.dart';
import '../input/input_system.dart';
import '../persistence/persistence_system.dart';
import '../monetization/monetization_system.dart';
import '../analytics/analytics_system.dart';

/// 設定可能なゲームの基底クラス
/// フレームワークの全システムを統合し、設定駆動でゲームを構築
abstract class ConfigurableGame<TState extends GameState, TConfig> extends FlameGame 
    with TapCallbacks {
  /// 設定管理
  late GameConfiguration<TState, TConfig> configuration;
  
  /// 状態管理
  late GameStateProvider<TState> stateProvider;
  
  /// タイマー管理
  late TimerManager timerManager;
  
  /// テーマ管理
  late ThemeManager themeManager;
  
  /// 音響管理
  late AudioManager audioManager;
  
  /// 入力管理
  late InputManager inputManager;
  
  /// データ管理
  late DataManager dataManager;
  
  /// 収益化管理
  late MonetizationManager monetizationManager;
  
  /// 分析管理
  late AnalyticsManager analyticsManager;
  
  /// 初期化完了フラグ
  bool _isInitialized = false;
  
  /// デバッグモード
  bool _debugMode = false;
  
  ConfigurableGame({
    GameConfiguration<TState, TConfig>? configuration,
    bool debugMode = false,
  }) {
    _debugMode = debugMode;
    
    if (configuration != null) {
      this.configuration = configuration;
    }
  }
  
  /// 初期化完了かどうか
  bool get isInitialized => _isInitialized;
  
  /// デバッグモードかどうか
  bool get debugMode => _debugMode;
  
  /// 現在のゲーム状態
  TState get currentState => stateProvider.currentState;
  
  /// 現在のゲーム設定
  TConfig get config => configuration.config;
  
  @override
  Future<void> onLoad() async {
    // フレームワークの初期化を先に行う
    await initializeFramework();
    
    // 親クラスのonLoadを呼び出す
    await super.onLoad();
    
    // ゲーム固有の初期化
    await initializeGame();
    
    // 設定の適用
    await applyConfiguration(configuration.config);
    
    _isInitialized = true;
    
    debugPrint('ConfigurableGame initialized: ${runtimeType}');
  }
  
  /// フレームワークシステムの初期化
  Future<void> initializeFramework() async {
    // タイマーマネージャーの初期化
    timerManager = TimerManager();
    add(timerManager);
    
    // テーママネージャーの初期化
    themeManager = ThemeManager();
    themeManager.initializeDefaultThemes();
    
    // 状態プロバイダーの初期化（サブクラスで設定）
    stateProvider = createStateProvider();
    
    // 音響システムの初期化
    audioManager = AudioManager(
      provider: createAudioProvider(),
      configuration: createAudioConfiguration(),
    );
    await audioManager.initialize();
    
    // 入力システムの初期化
    inputManager = InputManager(
      processor: createInputProcessor(),
      configuration: createInputConfiguration(),
    );
    inputManager.initialize();
    
    // データ永続化システムの初期化
    dataManager = DataManager(
      provider: createStorageProvider(),
      configuration: createPersistenceConfiguration(),
    );
    await dataManager.initialize();
    
    // 収益化システムの初期化
    monetizationManager = MonetizationManager(
      provider: createAdProvider(),
      configuration: createMonetizationConfiguration(),
    );
    await monetizationManager.initialize();
    
    // 分析システムの初期化
    analyticsManager = AnalyticsManager(
      provider: createAnalyticsProvider(),
      configuration: createAnalyticsConfiguration(),
    );
    await analyticsManager.initialize();
    
    // 入力イベントリスナー設定
    inputManager.addInputListener(_onInputEvent);
    
    // デバッグモードの設定
    if (_debugMode) {
      await setupDebugging();
    }
  }
  
  /// ゲーム固有の初期化（サブクラスで実装）
  Future<void> initializeGame();
  
  /// 状態プロバイダーの作成（サブクラスで実装）
  GameStateProvider<TState> createStateProvider();
  
  /// 音響プロバイダーの作成（サブクラスでオーバーライド可能）
  AudioProvider createAudioProvider() => SilentAudioProvider();
  
  /// 音響設定の作成（サブクラスでオーバーライド可能）
  AudioConfiguration createAudioConfiguration() => const DefaultAudioConfiguration();
  
  /// 入力プロセッサーの作成（サブクラスでオーバーライド可能）
  InputProcessor createInputProcessor() => BasicInputProcessor();
  
  /// 入力設定の作成（サブクラスでオーバーライド可能）
  InputConfiguration createInputConfiguration() => const DefaultInputConfiguration();
  
  /// ストレージプロバイダーの作成（サブクラスでオーバーライド可能）
  StorageProvider createStorageProvider() => LocalStorageProvider();
  
  /// 永続化設定の作成（サブクラスでオーバーライド可能）
  PersistenceConfiguration createPersistenceConfiguration() => const DefaultPersistenceConfiguration();
  
  /// 広告プロバイダーの作成（サブクラスでオーバーライド可能）
  AdProvider createAdProvider() => MockAdProvider();
  
  /// 収益化設定の作成（サブクラスでオーバーライド可能）
  MonetizationConfiguration createMonetizationConfiguration() => const DefaultMonetizationConfiguration();
  
  /// 分析プロバイダーの作成（サブクラスでオーバーライド可能）
  AnalyticsProvider createAnalyticsProvider() => ConsoleAnalyticsProvider();
  
  /// 分析設定の作成（サブクラスでオーバーライド可能）
  AnalyticsConfiguration createAnalyticsConfiguration() => const DefaultAnalyticsConfiguration();
  
  /// 設定の適用
  Future<void> applyConfiguration(TConfig config) async {
    configuration.updateConfig(config);
    
    // 設定変更の通知
    onConfigurationChanged(this.config, config);
    
    // UI テーマの更新
    await updateTheme();
    
    // タイマーの更新
    await updateTimers();
    
    // 状態の更新
    await updateStates();
  }
  
  /// 設定変更時のコールバック（サブクラスで実装）
  void onConfigurationChanged(TConfig oldConfig, TConfig newConfig) {
    debugPrint('Configuration changed: $oldConfig -> $newConfig');
  }
  
  /// テーマの更新
  Future<void> updateTheme() async {
    // サブクラスでオーバーライド可能
  }
  
  /// タイマーの更新
  Future<void> updateTimers() async {
    // サブクラスでオーバーライド可能
  }
  
  /// 状態の更新
  Future<void> updateStates() async {
    // サブクラスでオーバーライド可能
  }
  
  /// ゲーム開始
  void startGame() {
    if (!_isInitialized) {
      debugPrint('Warning: Game not initialized yet');
      return;
    }
    
    onGameStart();
  }
  
  /// ゲーム一時停止
  void pauseGame() {
    pauseEngine();
    timerManager.pauseAllTimers();
    onGamePause();
  }
  
  /// ゲーム再開
  void resumeGame() {
    resumeEngine();
    timerManager.resumeAllTimers();
    onGameResume();
  }
  
  /// ゲーム停止
  void stopGame() {
    timerManager.stopAllTimers();
    onGameStop();
  }
  
  /// ゲーム リセット
  void resetGame() {
    timerManager.stopAllTimers();
    stateProvider = createStateProvider();
    onGameReset();
  }
  
  /// ゲーム開始時のコールバック（サブクラスで実装）
  void onGameStart() {}
  
  /// ゲーム一時停止時のコールバック（サブクラスで実装） 
  void onGamePause() {}
  
  /// ゲーム再開時のコールバック（サブクラスで実装）
  void onGameResume() {}
  
  /// ゲーム停止時のコールバック（サブクラスで実装）
  void onGameStop() {}
  
  /// ゲームリセット時のコールバック（サブクラスで実装）
  void onGameReset() {}
  
  /// デバッグ機能の設定
  Future<void> setupDebugging() async {
    // デバッグ情報の表示
    if (_debugMode) {
      add(FpsTextComponent(
        position: Vector2(10, 10),
      ));
      
      // 追加のデバッグコンポーネント
      add(DebugInfoComponent(
        game: this,
        position: Vector2(10, 40),
      ));
    }
  }
  
  /// A/Bテスト用の設定を適用
  void applyABTestVariant(String experimentId, String variantId) {
    final variantConfig = configuration.getConfigForVariant(variantId);
    applyConfiguration(variantConfig);
    
    debugPrint('A/B Test applied: $experimentId = $variantId');
  }
  
  /// リモート設定との同期
  Future<void> syncRemoteConfiguration() async {
    await configuration.syncWithRemoteConfig();
    await applyConfiguration(configuration.config);
  }
  
  /// 入力イベント処理
  void _onInputEvent(InputEventData event) {
    onInputEvent(event);
    
    // 分析追跡
    analyticsManager.trackEvent('input_event', parameters: {
      'input_type': event.type.name,
      'position_x': event.position?.x,
      'position_y': event.position?.y,
    });
  }
  
  /// 入力イベントコールバック（サブクラスでオーバーライド可能）
  void onInputEvent(InputEventData event) {}
  
  /// Flame 1.30.1 イベントハンドラー
  @override
  void onTapDown(TapDownEvent event) {
    inputManager.handleTapDown(event.localPosition);
  }
  
  @override
  void onTapUp(TapUpEvent event) {
    inputManager.handleTapUp(event.localPosition);
  }
  
  @override
  void onTapCancel(TapCancelEvent event) {
    inputManager.handleTapCancel();
  }
  
  @override
  void update(double dt) {
    // タイマー更新
    for (final timerId in timerManager.getTimerIds()) {
      final timer = timerManager.getTimer(timerId);
      timer?.update(dt);
    }
    
    // 入力システム更新
    inputManager.update(dt);
    
    // データ自動保存チェック
    dataManager.checkAutoSave();
    
    // 分析システム更新
    analyticsManager.update();
    
    super.update(dt);
  }
  
  /// アナリティクスイベントの送信
  void trackEvent(String eventName, Map<String, dynamic> parameters) {
    // Firebase Analytics等への送信
    debugPrint('Analytics Event: $eventName - $parameters');
  }
  
  /// 状態遷移の追跡
  void trackStateTransition(TState from, TState to) {
    trackEvent('state_transition', {
      'from_state': from.name,
      'to_state': to.name,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }
  
  /// ゲームセッションの追跡
  void trackGameSession() {
    final statistics = stateProvider.getStatistics();
    
    trackEvent('game_session', {
      'session_count': statistics.sessionCount,
      'total_state_changes': statistics.totalStateChanges,
      'session_duration_seconds': statistics.sessionDuration.inSeconds,
      'most_visited_state': statistics.mostVisitedState,
    });
  }
  
  /// パフォーマンスメトリクスの取得
  Map<String, dynamic> getPerformanceMetrics() {
    return {
      'fps': 60.0, // 仮の値 - 実際のFPSは別途取得が必要
      'component_count': children.length,
      'timer_count': timerManager.getTimerIds().length,
      'running_timers': timerManager.getRunningTimerIds().length,
      'memory_usage': _getMemoryUsage(),
    };
  }
  
  double _getMemoryUsage() {
    // メモリ使用量の取得（概算）
    return children.length * 0.001; // 簡易計算
  }
  
  /// デバッグ情報の取得
  Map<String, dynamic> getDebugInfo() {
    return {
      'game_type': runtimeType.toString(),
      'initialized': _isInitialized,
      'debug_mode': _debugMode,
      'current_state': currentState.name,
      'configuration': configuration.getDebugInfo(),
      'state_provider': stateProvider.getDebugInfo(),
      'timer_manager': timerManager.getDebugInfo(),
      'audio_manager': audioManager.getDebugInfo(),
      'input_manager': inputManager.getDebugInfo(),
      'data_manager': dataManager.getDebugInfo(),
      'monetization_manager': monetizationManager.getDebugInfo(),
      'analytics_manager': analyticsManager.getDebugInfo(),
      'performance': getPerformanceMetrics(),
    };
  }
  
  @override
  void onRemove() {
    // リソースのクリーンアップ
    timerManager.removeFromParent();
    audioManager.dispose();
    dataManager.dispose();
    monetizationManager.dispose();
    analyticsManager.dispose();
    super.onRemove();
  }
}

/// FPS表示コンポーネント
class FpsTextComponent extends TextComponent {
  late double _fps = 0.0;
  int _frameCount = 0;
  double _timeAccumulator = 0.0;
  
  FpsTextComponent({Vector2? position}) : super(
    text: 'FPS: 0',
    textRenderer: TextPaint(
      style: const TextStyle(
        color: Color(0xFFFFFFFF),
        fontSize: 12,
      ),
    ),
    position: position,
  );
  
  @override
  void update(double dt) {
    super.update(dt);
    
    _frameCount++;
    _timeAccumulator += dt;
    
    if (_timeAccumulator >= 1.0) {
      _fps = _frameCount / _timeAccumulator;
      text = 'FPS: ${_fps.toStringAsFixed(1)}';
      
      _frameCount = 0;
      _timeAccumulator = 0.0;
    }
  }
}

/// デバッグ情報表示コンポーネント
class DebugInfoComponent extends TextComponent {
  final ConfigurableGame game;
  double _updateInterval = 0.5; // 0.5秒ごとに更新
  double _timeAccumulator = 0.0;
  
  DebugInfoComponent({
    required this.game,
    Vector2? position,
  }) : super(
    text: 'Debug Info',
    textRenderer: TextPaint(
      style: const TextStyle(
        color: Color(0xFFFFFFFF),
        fontSize: 10,
      ),
    ),
    position: position,
  );
  
  @override
  void update(double dt) {
    super.update(dt);
    
    _timeAccumulator += dt;
    
    if (_timeAccumulator >= _updateInterval) {
      _updateDebugInfo();
      _timeAccumulator = 0.0;
    }
  }
  
  void _updateDebugInfo() {
    final debugInfo = game.getDebugInfo();
    final performance = debugInfo['performance'] as Map<String, dynamic>;
    
    text = [
      'State: ${debugInfo['current_state']}',
      'Components: ${performance['component_count']}',
      'Timers: ${performance['timer_count']}',
      'Memory: ${(performance['memory_usage'] as double).toStringAsFixed(2)}MB',
    ].join('\n');
  }
}

/// 設定可能なゲームのビルダー
class ConfigurableGameBuilder<TState extends GameState, TConfig> {
  GameConfiguration<TState, TConfig>? _configuration;
  bool _debugMode = false;
  
  /// 設定を指定
  ConfigurableGameBuilder<TState, TConfig> withConfiguration(
    GameConfiguration<TState, TConfig> configuration
  ) {
    _configuration = configuration;
    return this;
  }
  
  /// デバッグモードを有効化
  ConfigurableGameBuilder<TState, TConfig> withDebugMode(bool enabled) {
    _debugMode = enabled;
    return this;
  }
  
  /// ゲームを構築
  T build<T extends ConfigurableGame<TState, TConfig>>(
    T Function(GameConfiguration<TState, TConfig>?, bool) constructor
  ) {
    return constructor(_configuration, _debugMode);
  }
}