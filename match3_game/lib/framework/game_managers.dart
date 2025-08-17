import '../state/game_state_system.dart';
import '../timer/flame_timer_system.dart';
import '../ui/flutter_theme_system.dart';
import '../audio/audio_system.dart';
import '../input/flame_input_system.dart';
import '../persistence/persistence_system.dart';
import '../monetization/monetization_system.dart';
import '../analytics/analytics_system.dart';
import '../game_services/flutter_official_game_services.dart';
import '../providers/provider_factory.dart';

/// ゲームマネージャーコレクション
/// 各種システムマネージャーを一元管理するクラス
class GameManagers<TState extends GameState> {
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
  
  /// 初期化フラグ
  bool _isInitialized = false;
  
  /// 初期化完了かどうか
  bool get isInitialized => _isInitialized;
  
  /// 初期化処理
  Future<void> initialize({
    required TState initialState,
    required ProviderFactory factory,
    bool debugMode = false,
  }) async {
    if (_isInitialized) return;
    
    providerFactory = factory;
    providerBundle = providerFactory.createProviderBundle();
    
    // システムマネージャーの初期化
    stateProvider = GameStateProvider<TState>(initialState);
    timerManager = FlameTimerManager();
    themeManager = FlutterThemeManager();
    audioManager = AudioManager(
      provider: providerBundle.audioProvider,
      configuration: providerBundle.audioConfiguration,
    );
    inputManager = InputManager(
      processor: providerBundle.inputProcessor,
      configuration: providerBundle.inputConfiguration,
    );
    dataManager = DataManager(
      provider: providerBundle.storageProvider,
      configuration: providerBundle.persistenceConfiguration,
    );
    monetizationManager = MonetizationManager(
      provider: providerBundle.adProvider,
      configuration: providerBundle.monetizationConfiguration,
    );
    analyticsManager = AnalyticsManager(
      provider: providerBundle.analyticsProvider,
      configuration: providerBundle.analyticsConfiguration,
    );
    gameServicesManager = providerBundle.gameServicesManager;
    
    _isInitialized = true;
  }
  
  /// リソース解放
  Future<void> dispose() async {
    await audioManager.dispose();
    await analyticsManager.dispose();
    await dataManager.dispose();
    await monetizationManager.dispose();
    await gameServicesManager.dispose();
    await providerBundle.disposeAll();
    
    _isInitialized = false;
  }
}