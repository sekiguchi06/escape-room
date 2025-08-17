import 'package:flutter/material.dart';
import '../state/game_state_system.dart';
import '../timer/flame_timer_system.dart';
import '../ui/flutter_theme_system.dart';
import '../audio/audio_system.dart';
import '../input/flame_input_system.dart';
import '../persistence/persistence_system.dart';
import '../monetization/monetization_system.dart';
import '../analytics/analytics_system.dart';
import '../providers/provider_factory.dart';
import 'game_managers.dart';

/// フレームワーク初期化ロジック
/// 各種システムの初期化を担当するミックスイン
mixin FrameworkInitializer<TState extends GameState, TConfig> {
  /// マネージャーコレクション
  GameManagers<TState> get managers;
  
  /// プロバイダーファクトリー
  ProviderFactory get providerFactory;
  
  /// デバッグモード
  bool get debugMode;
  
  /// フレームワークシステムの初期化
  /// Flutter公式準拠: ProviderFactoryによる統一初期化
  Future<void> initializeFramework() async {
    // プロバイダーバンドル作成
    managers.providerBundle = managers.providerFactory.createProviderBundle();
    
    if (debugMode) {
      debugPrint('🔧 Provider bundle created: ${managers.providerBundle.profile.name}');
    }
    
    // タイマーマネージャーの初期化（Flame公式Timer準拠）
    managers.timerManager = FlameTimerManager();
    
    // テーママネージャーの初期化（Flutter公式ThemeData準拠）
    managers.themeManager = FlutterThemeManager();
    managers.themeManager.initializeDefaultThemes();
    
    // 状態プロバイダーの初期化（サブクラスで設定）
    managers.stateProvider = createStateProvider();
    
    // プロバイダー一括初期化（依存関係順序保証）
    final initResults = await managers.providerBundle.initializeAll();
    
    // 初期化結果の確認
    for (final entry in initResults.entries) {
      if (!entry.value && debugMode) {
        debugPrint('⚠️ Provider initialization warning: ${entry.key} failed');
      }
    }
    
    // システムマネージャーの初期化（プロバイダー使用）
    managers.audioManager = AudioManager(
      provider: managers.providerBundle.audioProvider,
      configuration: managers.providerBundle.audioConfiguration,
    );
    
    final flameInputManager = FlameInputManager(
      processor: managers.providerBundle.inputProcessor,
      configuration: managers.providerBundle.inputConfiguration,
    );
    managers.inputManager = flameInputManager;
    managers.inputManager.initialize();
    
    managers.dataManager = DataManager(
      provider: managers.providerBundle.storageProvider,
      configuration: managers.providerBundle.persistenceConfiguration,
    );
    await managers.dataManager.initialize();
    
    managers.monetizationManager = MonetizationManager(
      provider: managers.providerBundle.adProvider,
      configuration: managers.providerBundle.monetizationConfiguration,
    );
    
    managers.analyticsManager = AnalyticsManager(
      provider: managers.providerBundle.analyticsProvider,
      configuration: managers.providerBundle.analyticsConfiguration,
    );
    
    managers.gameServicesManager = managers.providerBundle.gameServicesManager;
    
    // 入力イベントリスナー設定
    managers.inputManager.addInputListener(onInputEvent);
    
    // デバッグモードの設定
    if (debugMode) {
      debugPrint('🎮 Framework initialized in debug mode');
      debugPrint('🔊 Audio provider: ${managers.providerBundle.audioProvider.runtimeType}');
      debugPrint('🎯 Input provider: ${managers.providerBundle.inputProcessor.runtimeType}');
      debugPrint('💾 Storage provider: ${managers.providerBundle.storageProvider.runtimeType}');
      debugPrint('💰 Ad provider: ${managers.providerBundle.adProvider.runtimeType}');
      debugPrint('📊 Analytics provider: ${managers.providerBundle.analyticsProvider.runtimeType}');
    }
  }
  
  /// 状態プロバイダーの作成（サブクラスで実装）
  GameStateProvider<TState> createStateProvider();
  
  /// 入力イベントハンドラー（サブクラスで実装）
  void onInputEvent(InputEventData event);
  
  /// リソース解放
  Future<void> disposeFramework() async {
    await managers.dispose();
  }
}