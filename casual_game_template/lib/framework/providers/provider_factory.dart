import 'package:flutter/foundation.dart';

import '../audio/audio_system.dart';
import '../audio/providers/flame_audio_provider.dart';
import '../audio/providers/audioplayers_provider.dart';
import '../input/flame_input_system.dart';
import '../persistence/persistence_system.dart';
import '../persistence/flutter_official_persistence_system.dart';
import '../monetization/monetization_system.dart';
import '../monetization/providers/google_ad_provider.dart';
import '../analytics/analytics_system.dart';
import '../analytics/providers/firebase_analytics_provider.dart';
import '../game_services/flutter_official_game_services.dart';

/// プロバイダー作成方針
enum ProviderProfile {
  /// 開発・デバッグ環境（Mock/テスト用プロバイダー）
  development,
  /// テスト環境（軽量実装 + 一部実プロバイダー）
  testing,
  /// プロダクション環境（実プロバイダー）
  production,
}

/// Flutter公式準拠プロバイダーファクトリー
/// 
/// 参考ドキュメント:
/// - https://flutter.dev/docs/development/data-and-backend/state-mgmt/provider
/// - https://pub.dev/packages/provider
/// 
/// 設計原則:
/// 1. 環境別プロバイダー選択の統一化
/// 2. 依存関係の明示的管理
/// 3. 初期化順序の保証
/// 4. 設定の一元化
class ProviderFactory {
  final ProviderProfile profile;
  final bool debugMode;
  final Map<String, dynamic> customSettings;
  
  /// Flutter公式推奨: ファクトリーコンストラクタで環境制御
  const ProviderFactory({
    required this.profile,
    this.debugMode = false,
    this.customSettings = const {},
  });
  
  /// 開発環境用ファクトリー
  factory ProviderFactory.development({bool debugMode = true}) {
    return ProviderFactory(
      profile: ProviderProfile.development,
      debugMode: debugMode,
    );
  }
  
  /// テスト環境用ファクトリー
  factory ProviderFactory.testing({bool debugMode = false}) {
    return ProviderFactory(
      profile: ProviderProfile.testing,
      debugMode: debugMode,
    );
  }
  
  /// プロダクション環境用ファクトリー
  factory ProviderFactory.production({bool debugMode = false}) {
    return ProviderFactory(
      profile: ProviderProfile.production,
      debugMode: debugMode,
    );
  }
  
  /// 音響プロバイダー作成
  /// Flutter公式パターン: 環境に応じた実装選択
  AudioProvider createAudioProvider() {
    switch (profile) {
      case ProviderProfile.development:
        // 開発: 軽量で即座に動作するFlameAudio
        return FlameAudioProvider();
        
      case ProviderProfile.testing:
        // テスト: SilentAudioProvider（音声なし高速実行）
        return SilentAudioProvider();
        
      case ProviderProfile.production:
        // プロダクション: 高機能なAudioPlayersProvider
        return AudioPlayersProvider();
    }
  }
  
  /// 音響設定作成
  AudioConfiguration createAudioConfiguration() {
    return DefaultAudioConfiguration(
      bgmEnabled: profile != ProviderProfile.testing,
      sfxEnabled: profile != ProviderProfile.testing,
      masterVolume: 1.0,
      bgmVolume: debugMode ? 0.3 : 0.6,
      sfxVolume: debugMode ? 0.5 : 0.8,
      debugMode: debugMode,
    );
  }
  
  /// 入力プロセッサー作成
  /// Flame公式events準拠のFlameInputProcessorを使用
  InputProcessor createInputProcessor() {
    return FlameInputProcessor();
  }
  
  /// 入力設定作成
  InputConfiguration createInputConfiguration() {
    return const DefaultInputConfiguration();
  }
  
  /// ストレージプロバイダー作成
  /// Flutter公式shared_preferences準拠
  StorageProvider createStorageProvider() {
    switch (profile) {
      case ProviderProfile.development:
      case ProviderProfile.testing:
        // 開発・テスト: メモリ内ストレージ（高速・リセット可能）
        return MemoryStorageProvider();
        
      case ProviderProfile.production:
        // プロダクション: ローカルストレージプロバイダー
        return LocalStorageProvider();
    }
  }
  
  /// 永続化設定作成
  PersistenceConfiguration createPersistenceConfiguration() {
    return DefaultPersistenceConfiguration(
      autoSaveInterval: profile == ProviderProfile.production ? 300 : 30,
      debugMode: debugMode,
    );
  }
  
  /// 広告プロバイダー作成
  AdProvider createAdProvider() {
    switch (profile) {
      case ProviderProfile.development:
        // 開発: 動作確認可能なMockプロバイダー
        return MockAdProvider();
        
      case ProviderProfile.testing:
        // テスト: 即座にレスポンスするMockプロバイダー
        return MockAdProvider();
        
      case ProviderProfile.production:
        // プロダクション: Google Mobile Ads実装
        return GoogleAdProvider();
    }
  }
  
  /// 収益化設定作成
  MonetizationConfiguration createMonetizationConfiguration() {
    switch (profile) {
      case ProviderProfile.development:
        return DefaultMonetizationConfiguration(
          testMode: true,
          debugMode: debugMode,
          adsDisabled: false,
          minAdInterval: 10, // 開発時は短縮
          interstitialInterval: 30, // 開発時は短縮
        );
        
      case ProviderProfile.testing:
        return DefaultMonetizationConfiguration(
          testMode: true,
          debugMode: debugMode,
          adsDisabled: true, // テスト時は広告無効
        );
        
      case ProviderProfile.production:
        return DefaultMonetizationConfiguration(
          testMode: false,
          debugMode: debugMode,
          adsDisabled: false,
          minAdInterval: 30,
          interstitialInterval: 60,
        );
    }
  }
  
  /// 分析プロバイダー作成
  AnalyticsProvider createAnalyticsProvider() {
    switch (profile) {
      case ProviderProfile.development:
        // 開発: コンソール出力プロバイダー（ログ確認用）
        return ConsoleAnalyticsProvider();
        
      case ProviderProfile.testing:
        // テスト: 無効化プロバイダー（高速実行）
        return ConsoleAnalyticsProvider();
        
      case ProviderProfile.production:
        // プロダクション: Firebase Analytics実装
        return FirebaseAnalyticsProvider();
    }
  }
  
  /// 分析設定作成
  AnalyticsConfiguration createAnalyticsConfiguration() {
    return DefaultAnalyticsConfiguration(
      batchInterval: profile == ProviderProfile.production ? 300 : 10,
      batchSize: profile == ProviderProfile.production ? 10 : 1,
      debugMode: debugMode,
    );
  }
  
  /// ゲームサービスマネージャー作成
  FlutterGameServicesManager createGameServicesManager() {
    return FlutterGameServicesManager(
      config: GameServicesConfiguration(
        debugMode: debugMode,
        autoSignInEnabled: profile == ProviderProfile.production,
        signInRetryCount: profile == ProviderProfile.production ? 3 : 1,
        networkTimeoutSeconds: profile == ProviderProfile.production ? 30 : 10,
      ),
    );
  }
  
  /// プロバイダー作成結果
  ProviderBundle createProviderBundle() {
    return ProviderBundle(
      profile: profile,
      audioProvider: createAudioProvider(),
      audioConfiguration: createAudioConfiguration(),
      inputProcessor: createInputProcessor(),
      inputConfiguration: createInputConfiguration(),
      storageProvider: createStorageProvider(),
      persistenceConfiguration: createPersistenceConfiguration(),
      adProvider: createAdProvider(),
      monetizationConfiguration: createMonetizationConfiguration(),
      analyticsProvider: createAnalyticsProvider(),
      analyticsConfiguration: createAnalyticsConfiguration(),
      gameServicesManager: createGameServicesManager(),
      debugMode: debugMode,
    );
  }
  
  /// プロバイダー初期化順序定義
  /// Flutter公式パターン: 依存関係に基づく初期化順序
  List<String> getInitializationOrder() {
    return [
      'storage',      // 1. 永続化（他システムが設定を読み込むため）
      'analytics',    // 2. 分析（初期化完了を追跡するため）
      'audio',        // 3. 音響（独立性が高い）
      'input',        // 4. 入力（独立性が高い）
      'monetization', // 5. 収益化（広告読み込み時間を考慮）
      'gameServices', // 6. ゲームサービス（ネットワーク依存）
    ];
  }
  
  /// デバッグ情報取得
  Map<String, dynamic> getDebugInfo() {
    return {
      'flutter_official_compliant': true,
      'profile': profile.name,
      'debug_mode': debugMode,
      'custom_settings': customSettings,
      'initialization_order': getInitializationOrder(),
      'provider_types': {
        'audio': createAudioProvider().runtimeType.toString(),
        'input': createInputProcessor().runtimeType.toString(),
        'storage': createStorageProvider().runtimeType.toString(),
        'ad': createAdProvider().runtimeType.toString(),
        'analytics': createAnalyticsProvider().runtimeType.toString(),
      },
    };
  }
}

/// プロバイダー一式
class ProviderBundle {
  final ProviderProfile profile;
  final AudioProvider audioProvider;
  final AudioConfiguration audioConfiguration;
  final InputProcessor inputProcessor;
  final InputConfiguration inputConfiguration;
  final StorageProvider storageProvider;
  final PersistenceConfiguration persistenceConfiguration;
  final AdProvider adProvider;
  final MonetizationConfiguration monetizationConfiguration;
  final AnalyticsProvider analyticsProvider;
  final AnalyticsConfiguration analyticsConfiguration;
  final FlutterGameServicesManager gameServicesManager;
  final bool debugMode;
  
  const ProviderBundle({
    required this.profile,
    required this.audioProvider,
    required this.audioConfiguration,
    required this.inputProcessor,
    required this.inputConfiguration,
    required this.storageProvider,
    required this.persistenceConfiguration,
    required this.adProvider,
    required this.monetizationConfiguration,
    required this.analyticsProvider,
    required this.analyticsConfiguration,
    required this.gameServicesManager,
    required this.debugMode,
  });
  
  /// 一括初期化
  /// Flutter公式パターン: 依存関係順序での初期化
  Future<Map<String, bool>> initializeAll() async {
    final results = <String, bool>{};
    final factory = ProviderFactory(profile: profile, debugMode: debugMode);
    
    // 初期化順序に従って実行
    for (final systemName in factory.getInitializationOrder()) {
      try {
        bool success = false;
        
        switch (systemName) {
          case 'storage':
            // ストレージは設定不要（自動初期化）
            success = true;
            break;
          case 'analytics':
            success = await analyticsProvider.initialize(analyticsConfiguration);
            break;
          case 'audio':
            await audioProvider.initialize(audioConfiguration);
            success = true;
            break;
          case 'input':
            inputProcessor.initialize(inputConfiguration);
            success = true;
            break;
          case 'monetization':
            success = await adProvider.initialize(monetizationConfiguration);
            break;
          case 'gameServices':
            final result = await gameServicesManager.initialize();
            success = result == GameServiceResult.success || 
                     result == GameServiceResult.notSupported;
            break;
        }
        
        results[systemName] = success;
        
        if (debugMode) {
          debugPrint('🔧 Provider initialized: $systemName = $success');
        }
        
      } catch (e) {
        results[systemName] = false;
        if (debugMode) {
          debugPrint('❌ Provider initialization failed: $systemName - $e');
        }
      }
    }
    
    return results;
  }
  
  /// リソース解放
  Future<void> disposeAll() async {
    await audioProvider.dispose();
    await adProvider.dispose();
    await analyticsProvider.dispose();
    await gameServicesManager.dispose();
    
    if (debugMode) {
      debugPrint('🧹 All providers disposed');
    }
  }
  
  /// デバッグ情報
  Map<String, dynamic> getDebugInfo() {
    return {
      'profile': profile.name,
      'debug_mode': debugMode,
      'providers': {
        'audio': audioProvider.runtimeType.toString(),
        'input': inputProcessor.runtimeType.toString(),
        'storage': storageProvider.runtimeType.toString(),
        'ad': adProvider.runtimeType.toString(),
        'analytics': analyticsProvider.runtimeType.toString(),
        'gameServices': gameServicesManager.runtimeType.toString(),
      },
    };
  }
}

/// 後方互換性用ヘルパー
class ProviderFactoryHelper {
  /// 環境変数からプロファイル判定
  static ProviderProfile detectProfile() {
    if (kDebugMode) {
      return ProviderProfile.development;
    } else if (kProfileMode) {
      return ProviderProfile.testing;
    } else {
      return ProviderProfile.production;
    }
  }
  
  /// 自動ファクトリー作成
  static ProviderFactory createAuto({bool? debugMode}) {
    final profile = detectProfile();
    return ProviderFactory(
      profile: profile,
      debugMode: debugMode ?? kDebugMode,
    );
  }
}