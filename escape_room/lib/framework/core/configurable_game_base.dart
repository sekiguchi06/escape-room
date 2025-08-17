import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import '../config/game_configuration.dart';
import '../state/game_state_system.dart';
import '../input/flame_input_system.dart';
import '../timer/timer_manager.dart';
import '../providers/provider_factory.dart';
import 'game_managers.dart';
import 'framework_initializer.dart';
import 'game_lifecycle.dart';
import 'analytics_tracking.dart';
import 'performance_monitor.dart';
import 'debug_components.dart';

/// 設定可能なゲームの基底クラス
/// フレームワークの全システムを統合し、設定駆動でゲームを構築
abstract class ConfigurableGameBase<TState extends GameState, TConfig> extends FlameGame 
    with TapCallbacks, 
         FrameworkInitializer<TState, TConfig>,
         GameLifecycle<TState, TConfig>,
         AnalyticsTracking<TState>,
         PerformanceMonitor {
  
  /// 設定管理
  @override
  late GameConfiguration<TState, TConfig> configuration;
  
  /// マネージャーコレクション
  late GameManagers<TState> _managers;
  
  /// プロバイダーファクトリー
  @override
  late ProviderFactory providerFactory;
  
  /// 初期化完了フラグ
  bool _isInitialized = false;
  
  /// デバッグモード
  bool _debugMode = false;
  
  ConfigurableGameBase({
    GameConfiguration<TState, TConfig>? configuration,
    bool debugMode = false,
    ProviderFactory? providerFactory,
  }) {
    _debugMode = debugMode;
    _managers = GameManagers<TState>();
    
    if (configuration != null) {
      this.configuration = configuration;
    }
    
    // プロバイダーファクトリーの初期化
    this.providerFactory = providerFactory ?? ProviderFactoryHelper.createAuto(
      debugMode: debugMode,
    );
  }
  
  @override
  GameManagers<TState> get managers => _managers;
  
  @override
  bool get isInitialized => _isInitialized;
  
  @override
  bool get debugMode => _debugMode;
  
  /// 現在のゲーム状態
  TState get currentState => managers.stateProvider.currentState;
  
  /// 現在のゲーム設定
  TConfig get config => configuration.config;
  
  /// タイマーマネージャー（後方互換性）
  @override
  FlameTimerManager get timerManager => managers.timerManager;
  
  @override
  Future<void> onLoad() async {
    debugPrint('⚙️ ConfigurableGameBase.onLoad() starting for $runtimeType');
    
    // フレームワークの初期化を先に行う
    debugPrint('⚙️ About to call initializeFramework()');
    await initializeFramework();
    debugPrint('⚙️ initializeFramework() completed');
    
    // タイマーマネージャーをゲームに追加
    add(managers.timerManager);
    
    // 親クラスのonLoadを呼び出す
    await super.onLoad();
    
    // ゲーム固有の初期化
    debugPrint('⚙️ About to call initializeGame()');
    await initializeGame();
    debugPrint('⚙️ initializeGame() completed');
    
    // 設定の適用
    await applyConfiguration(configuration.config);
    
    // デバッグ機能の設定
    if (_debugMode) {
      DebugUtils.setupDebugging(this, _debugMode);
    }
    
    _isInitialized = true;
    
    debugPrint('ConfigurableGameBase initialized: $runtimeType');
  }
  
  /// ゲーム固有の初期化（サブクラスで実装）
  Future<void> initializeGame();
  
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
  @override
  void onInputEvent(InputEventData event) {
    // 分析追跡
    trackInputEvent(event);
  }
  
  /// Flame イベントハンドラー
  @override
  void onTapDown(TapDownEvent event) {
    managers.inputManager.handleTapDown(event.localPosition);
  }
  
  @override
  void onTapUp(TapUpEvent event) {
    managers.inputManager.handleTapUp(event.localPosition);
  }
  
  @override
  void onTapCancel(TapCancelEvent event) {
    managers.inputManager.handleTapCancel();
  }
  
  @override
  void update(double dt) {
    // タイマー更新
    for (final timerId in managers.timerManager.getTimerIds()) {
      final timer = managers.timerManager.getTimer(timerId);
      timer?.update(dt);
    }
    
    // 入力システム更新
    managers.inputManager.update(dt);
    
    // データ自動保存チェック
    managers.dataManager.checkAutoSave();
    
    // 分析システム更新
    managers.analyticsManager.update();
    
    super.update(dt);
  }
  
  /// デバッグ情報の取得
  Map<String, dynamic> getDebugInfo() {
    return {
      'game_type': runtimeType.toString(),
      'initialized': _isInitialized,
      'debug_mode': _debugMode,
      'current_state': currentState.name,
      'configuration': configuration.getDebugInfo(),
      'state_provider': managers.stateProvider.getDebugInfo(),
      'timer_manager': managers.timerManager.getDebugInfo(),
      'theme_manager': managers.themeManager.getDebugInfo(),
      'audio_manager': managers.audioManager.getDebugInfo(),
      'input_manager': managers.inputManager.getDebugInfo(),
      'data_manager': managers.dataManager.getDebugInfo(),
      'monetization_manager': managers.monetizationManager.getDebugInfo(),
      'analytics_manager': managers.analyticsManager.getDebugInfo(),
      'performance': getPerformanceMetrics(),
    };
  }
  
  /// エンジンの一時停止
  @override
  void pauseEngine() {
    super.pauseEngine();
  }
  
  /// エンジンの再開
  @override
  void resumeEngine() {
    super.resumeEngine();
  }
  
  @override
  void onRemove() {
    // リソースのクリーンアップ（初期化済みの場合のみ）
    if (_isInitialized) {
      managers.dispose();
    }
    super.onRemove();
  }
}