import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import '../config/game_configuration.dart';
import '../state/game_state_system.dart';
import '../timer/flame_timer_system.dart';
import '../ui/flutter_theme_system.dart';
import '../audio/audio_system.dart';
import '../input/flame_input_system.dart';
import '../persistence/persistence_system.dart';
import '../monetization/monetization_system.dart';
import '../analytics/analytics_system.dart';
import '../providers/provider_factory.dart';
import '../game_services/flutter_official_game_services.dart';

/// 設定可能なゲームの基底クラス
/// フレームワークの全システムを統合し、設定駆動でゲームを構築
abstract class ConfigurableGame<TState extends GameState, TConfig> extends FlameGame 
    with TapCallbacks {
  /// 設定管理
  late GameConfiguration<TState, TConfig> configuration;
  
  /// 状態管理
  late GameStateProvider<TState> stateProvider;
  
  /// タイマー管理
  late FlameTimerManager timerManager;
  
  /// テーマ管理（Flutter公式ThemeData準拠）
  late FlutterThemeManager themeManager;
  
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
  
  /// ゲームサービス管理
  late FlutterGameServicesManager gameServicesManager;
  
  /// プロバイダーファクトリー
  late ProviderFactory providerFactory;
  
  /// プロバイダーバンドル
  late ProviderBundle providerBundle;
  
  /// 初期化完了フラグ
  bool _isInitialized = false;
  
  /// デバッグモード
  bool _debugMode = false;
  
  ConfigurableGame({
    GameConfiguration<TState, TConfig>? configuration,
    bool debugMode = false,
    ProviderFactory? providerFactory,
  }) {
    _debugMode = debugMode;
    
    if (configuration != null) {
      this.configuration = configuration;
    }
    
    // プロバイダーファクトリーの初期化
    this.providerFactory = providerFactory ?? ProviderFactoryHelper.createAuto(
      debugMode: debugMode,
    );
  }
  
  /// 初期化完了かどうか
  bool get isInitialized => _isInitialized;
  
  /// デバッグモードかどうか
  @override
  bool get debugMode => _debugMode;
  
  /// 現在のゲーム状態
  TState get currentState => stateProvider.currentState;
  
  /// 現在のゲーム設定
  TConfig get config => configuration.config;
  
  @override
  Future<void> onLoad() async {
    debugPrint('⚙️ ConfigurableGame.onLoad() starting for $runtimeType');
    
    // フレームワークの初期化を先に行う
    debugPrint('⚙️ About to call initializeFramework()');
    await initializeFramework();
    debugPrint('⚙️ initializeFramework() completed - audioManager available');
    
    // 親クラスのonLoadを呼び出す
    await super.onLoad();
    
    // ゲーム固有の初期化
    debugPrint('⚙️ About to call initializeGame()');
    await initializeGame();
    debugPrint('⚙️ initializeGame() completed');
    
    // 設定の適用
    await applyConfiguration(configuration.config);
    
    _isInitialized = true;
    
    debugPrint('ConfigurableGame initialized: $runtimeType');
  }
  
  /// フレームワークシステムの初期化
  /// Flutter公式準拠: ProviderFactoryによる統一初期化
  Future<void> initializeFramework() async {
    // プロバイダーバンドル作成
    providerBundle = providerFactory.createProviderBundle();
    
    if (_debugMode) {
      debugPrint('🔧 Provider bundle created: ${providerBundle.profile.name}');
    }
    
    // タイマーマネージャーの初期化（Flame公式Timer準拠）
    timerManager = FlameTimerManager();
    add(timerManager);
    
    // テーママネージャーの初期化（Flutter公式ThemeData準拠）
    themeManager = FlutterThemeManager();
    themeManager.initializeDefaultThemes();
    
    // 状態プロバイダーの初期化（サブクラスで設定）
    stateProvider = createStateProvider();
    
    // プロバイダー一括初期化（依存関係順序保証）
    final initResults = await providerBundle.initializeAll();
    
    // 初期化結果の確認
    for (final entry in initResults.entries) {
      if (!entry.value && _debugMode) {
        debugPrint('⚠️ Provider initialization warning: ${entry.key} failed');
      }
    }
    
    // システムマネージャーの初期化（プロバイダー使用）
    audioManager = AudioManager(
      provider: providerBundle.audioProvider,
      configuration: providerBundle.audioConfiguration,
    );
    
    final flameInputManager = FlameInputManager(
      processor: providerBundle.inputProcessor,
      configuration: providerBundle.inputConfiguration,
    );
    inputManager = flameInputManager;
    inputManager.initialize();
    
    // テスト用：inputManagerからのタップイベントをゲームのonTapDownに接続
    flameInputManager.addInputListener((event) {
      // タップダウンイベント（シングルタップとダブルタップ両方を処理）
      if ((event.type == InputEventType.tap || event.type == InputEventType.doubleTap) && 
          event.position != null) {
        debugPrint('InputManager: ${event.type} event received at ${event.position}');
        final tapDetails = TapDownDetails(
          globalPosition: Offset(event.position!.x, event.position!.y),
        );
        final tapEvent = TapDownEvent(1, this, tapDetails);
        onTapDown(tapEvent);
      }
    });
    
    dataManager = DataManager(
      provider: providerBundle.storageProvider,
      configuration: providerBundle.persistenceConfiguration,
    );
    await dataManager.initialize();
    
    monetizationManager = MonetizationManager(
      provider: providerBundle.adProvider,
      configuration: providerBundle.monetizationConfiguration,
    );
    
    analyticsManager = AnalyticsManager(
      provider: providerBundle.analyticsProvider,
      configuration: providerBundle.analyticsConfiguration,
    );
    
    gameServicesManager = providerBundle.gameServicesManager;
    
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
      'theme_manager': themeManager.getDebugInfo(),
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
    // リソースのクリーンアップ（初期化済みの場合のみ）
    if (_isInitialized) {
      timerManager.removeFromParent();
      audioManager.dispose();
      dataManager.dispose();
      monetizationManager.dispose();
      analyticsManager.dispose();
      providerBundle.disposeAll();
    }
    super.onRemove();
  }
}

/// FPS表示コンポーネント
class FpsTextComponent extends TextComponent {
  late double _fps = 0.0;
  int _frameCount = 0;
  double _timeAccumulator = 0.0;
  
  FpsTextComponent({super.position}) : super(
    text: 'FPS: 0',
    textRenderer: TextPaint(
      style: const TextStyle(
        color: Color(0xFFFFFFFF),
        fontSize: 12,
      ),
    ),
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
  final double _updateInterval = 0.5; // 0.5秒ごとに更新
  double _timeAccumulator = 0.0;
  
  DebugInfoComponent({
    required this.game,
    super.position,
  }) : super(
    text: 'Debug Info',
    textRenderer: TextPaint(
      style: const TextStyle(
        color: Color(0xFFFFFFFF),
        fontSize: 10,
      ),
    ),
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