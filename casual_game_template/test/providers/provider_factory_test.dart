import 'package:flutter_test/flutter_test.dart';

import 'package:flutter/foundation.dart';

import '../../lib/framework/providers/provider_factory.dart';
import '../../lib/framework/audio/audio_system.dart';
import '../../lib/framework/audio/providers/flame_audio_provider.dart';
import '../../lib/framework/audio/providers/audioplayers_provider.dart';
import '../../lib/framework/input/flame_input_system.dart';
import '../../lib/framework/persistence/persistence_system.dart';
import '../../lib/framework/persistence/flutter_official_persistence_system.dart';
import '../../lib/framework/monetization/monetization_system.dart';
import '../../lib/framework/monetization/providers/google_ad_provider.dart';
import '../../lib/framework/analytics/analytics_system.dart';
import '../../lib/framework/analytics/providers/firebase_analytics_provider.dart';

/// Flutter公式準拠プロバイダーファクトリーの単体テスト
/// 
/// テスト対象:
/// 1. 環境別プロバイダー選択の正確性
/// 2. 依存関係管理の正確性
/// 3. 初期化順序の保証
/// 4. 設定の一元化
/// 5. ProviderBundleの一括操作
/// 6. Flutter公式準拠性確認
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('🏭 ProviderFactory基本機能テスト', () {
    
    test('開発環境プロバイダー選択確認', () {
      final factory = ProviderFactory.development(debugMode: true);
      
      expect(factory.profile, equals(ProviderProfile.development));
      expect(factory.debugMode, isTrue);
      
      // 開発環境ではFlameAudioProviderを選択
      final audioProvider = factory.createAudioProvider();
      expect(audioProvider, isA<FlameAudioProvider>());
      
      // MockAdProviderを選択
      final adProvider = factory.createAdProvider();
      expect(adProvider, isA<MockAdProvider>());
      
      // ConsoleAnalyticsProviderを選択
      final analyticsProvider = factory.createAnalyticsProvider();
      expect(analyticsProvider, isA<ConsoleAnalyticsProvider>());
    });
    
    test('テスト環境プロバイダー選択確認', () {
      final factory = ProviderFactory.testing(debugMode: false);
      
      expect(factory.profile, equals(ProviderProfile.testing));
      expect(factory.debugMode, isFalse);
      
      // テスト環境ではSilentAudioProviderを選択
      final audioProvider = factory.createAudioProvider();
      expect(audioProvider, isA<SilentAudioProvider>());
      
      // MockAdProviderを選択
      final adProvider = factory.createAdProvider();
      expect(adProvider, isA<MockAdProvider>());
      
      // ConsoleAnalyticsProviderを選択
      final analyticsProvider = factory.createAnalyticsProvider();
      expect(analyticsProvider, isA<ConsoleAnalyticsProvider>());
    });
    
    test('プロダクション環境プロバイダー選択確認', () {
      final factory = ProviderFactory.production(debugMode: false);
      
      expect(factory.profile, equals(ProviderProfile.production));
      expect(factory.debugMode, isFalse);
      
      // プロダクション環境ではAudioPlayersProviderを選択
      final audioProvider = factory.createAudioProvider();
      expect(audioProvider, isA<AudioPlayersProvider>());
      
      // GoogleAdProviderを選択
      final adProvider = factory.createAdProvider();
      expect(adProvider, isA<GoogleAdProvider>());
      
      // FirebaseAnalyticsProviderを選択
      final analyticsProvider = factory.createAnalyticsProvider();
      expect(analyticsProvider, isA<FirebaseAnalyticsProvider>());
    });
    
    test('入力プロセッサー作成確認', () {
      final factory = ProviderFactory.development();
      
      final inputProcessor = factory.createInputProcessor();
      expect(inputProcessor, isA<FlameInputProcessor>());
      
      final inputConfig = factory.createInputConfiguration();
      expect(inputConfig, isA<DefaultInputConfiguration>());
    });
    
    test('永続化プロバイダー作成確認', () {
      final developmentFactory = ProviderFactory.development();
      final productionFactory = ProviderFactory.production();
      
      // 開発環境: MemoryStorageProvider
      final devStorage = developmentFactory.createStorageProvider();
      expect(devStorage, isA<MemoryStorageProvider>());
      
      // プロダクション環境: LocalStorageProvider
      final prodStorage = productionFactory.createStorageProvider();
      expect(prodStorage, isA<LocalStorageProvider>());
    });
  });
  
  group('⚙️ Provider設定テスト', () {
    
    test('音響設定環境別確認', () {
      final devConfig = ProviderFactory.development().createAudioConfiguration();
      final testConfig = ProviderFactory.testing().createAudioConfiguration();
      final prodConfig = ProviderFactory.production().createAudioConfiguration();
      
      // 開発環境: 音声有効、デバッグ音量
      expect(devConfig.bgmEnabled, isTrue);
      expect(devConfig.sfxEnabled, isTrue);
      expect(devConfig.bgmVolume, equals(0.3)); // デバッグ時は控えめ
      expect(devConfig.debugMode, isTrue);
      
      // テスト環境: 音声無効
      expect(testConfig.bgmEnabled, isFalse);
      expect(testConfig.sfxEnabled, isFalse);
      
      // プロダクション環境: 音声有効、通常音量
      expect(prodConfig.bgmEnabled, isTrue);
      expect(prodConfig.sfxEnabled, isTrue);
      expect(prodConfig.bgmVolume, equals(0.6));
      expect(prodConfig.debugMode, isFalse);
    });
    
    test('収益化設定環境別確認', () {
      final devConfig = ProviderFactory.development().createMonetizationConfiguration();
      final testConfig = ProviderFactory.testing().createMonetizationConfiguration();
      final prodConfig = ProviderFactory.production().createMonetizationConfiguration();
      
      // 開発環境: テストモード、短縮間隔
      expect(devConfig.testMode, isTrue);
      expect(devConfig.adsDisabled, isFalse);
      expect(devConfig.minAdInterval, equals(10));
      expect(devConfig.interstitialInterval, equals(30));
      
      // テスト環境: 広告無効
      expect(testConfig.testMode, isTrue);
      expect(testConfig.adsDisabled, isTrue);
      
      // プロダクション環境: 本番モード、通常間隔
      expect(prodConfig.testMode, isFalse);
      expect(prodConfig.adsDisabled, isFalse);
      expect(prodConfig.minAdInterval, equals(30));
      expect(prodConfig.interstitialInterval, equals(60));
    });
    
    test('分析設定環境別確認', () {
      final devConfig = ProviderFactory.development().createAnalyticsConfiguration();
      final testConfig = ProviderFactory.testing().createAnalyticsConfiguration();
      final prodConfig = ProviderFactory.production().createAnalyticsConfiguration();
      
      // 開発環境: 短いバッチ間隔
      expect(devConfig.batchInterval, equals(10));
      expect(devConfig.batchSize, equals(1));
      expect(devConfig.debugMode, isTrue);
      
      // テスト環境: 短いバッチ間隔
      expect(testConfig.batchInterval, equals(10));
      expect(testConfig.batchSize, equals(1));
      
      // プロダクション環境: 長いバッチ間隔
      expect(prodConfig.batchInterval, equals(300));
      expect(prodConfig.batchSize, equals(10));
      expect(prodConfig.debugMode, isFalse);
    });
  });
  
  group('📦 ProviderBundle統合テスト', () {
    
    test('ProviderBundle作成確認', () {
      final factory = ProviderFactory.development(debugMode: true);
      final bundle = factory.createProviderBundle();
      
      expect(bundle.profile, equals(ProviderProfile.development));
      expect(bundle.debugMode, isTrue);
      expect(bundle.audioProvider, isA<FlameAudioProvider>());
      expect(bundle.adProvider, isA<MockAdProvider>());
      expect(bundle.analyticsProvider, isA<ConsoleAnalyticsProvider>());
      expect(bundle.gameServicesManager, isNotNull);
    });
    
    test('初期化順序確認', () {
      final factory = ProviderFactory.development();
      final order = factory.getInitializationOrder();
      
      expect(order, hasLength(6));
      expect(order[0], equals('storage'));      // 永続化が最初
      expect(order[1], equals('analytics'));    // 分析が次
      expect(order[5], equals('gameServices')); // ゲームサービスが最後
    });
    
    test('一括初期化テスト', () async {
      final factory = ProviderFactory.testing(debugMode: true);
      final bundle = factory.createProviderBundle();
      
      final results = await bundle.initializeAll();
      
      // 全システムの初期化結果を確認
      expect(results, hasLength(6));
      expect(results.containsKey('storage'), isTrue);
      expect(results.containsKey('analytics'), isTrue);
      expect(results.containsKey('audio'), isTrue);
      expect(results.containsKey('input'), isTrue);
      expect(results.containsKey('monetization'), isTrue);
      expect(results.containsKey('gameServices'), isTrue);
      
      // テスト環境では多くのシステムが成功するはず
      final successCount = results.values.where((success) => success).length;
      expect(successCount, greaterThanOrEqualTo(4));
    });
    
    test('リソース解放テスト', () async {
      final factory = ProviderFactory.testing(); // テスト用プロファイル使用
      final bundle = factory.createProviderBundle();
      
      // 解放処理が例外なく完了することを確認
      try {
        await bundle.disposeAll();
        expect(true, isTrue); // 例外が発生しなければ成功
      } catch (e) {
        fail('Resource disposal should not throw exception: $e');
      }
    });
  });
  
  group('🔍 ProviderFactoryHelper テスト', () {
    
    test('環境自動検出確認', () {
      final profile = ProviderFactoryHelper.detectProfile();
      
      // テスト環境では開発プロファイルが選択される
      expect(profile, equals(ProviderProfile.development));
    });
    
    test('自動ファクトリー作成確認', () {
      final factory = ProviderFactoryHelper.createAuto();
      
      expect(factory.profile, equals(ProviderProfile.development));
      expect(factory.debugMode, equals(kDebugMode));
    });
    
    test('自動ファクトリー（デバッグモード指定）確認', () {
      final factory = ProviderFactoryHelper.createAuto(debugMode: false);
      
      expect(factory.profile, equals(ProviderProfile.development));
      expect(factory.debugMode, isFalse);
    });
  });
  
  group('📊 デバッグ情報テスト', () {
    
    test('FactoryデバッグInfo確認', () {
      final factory = ProviderFactory.production(debugMode: true);
      final debugInfo = factory.getDebugInfo();
      
      expect(debugInfo['flutter_official_compliant'], isTrue);
      expect(debugInfo['profile'], equals('production'));
      expect(debugInfo['debug_mode'], isTrue);
      expect(debugInfo.containsKey('initialization_order'), isTrue);
      expect(debugInfo.containsKey('provider_types'), isTrue);
      
      final providerTypes = debugInfo['provider_types'] as Map<String, dynamic>;
      expect(providerTypes.containsKey('audio'), isTrue);
      expect(providerTypes.containsKey('ad'), isTrue);
      expect(providerTypes.containsKey('analytics'), isTrue);
    });
    
    test('BundleデバッグInfo確認', () {
      final factory = ProviderFactory.development();
      final bundle = factory.createProviderBundle();
      final debugInfo = bundle.getDebugInfo();
      
      expect(debugInfo['profile'], equals('development'));
      expect(debugInfo['debug_mode'], isTrue);
      expect(debugInfo.containsKey('providers'), isTrue);
      
      final providers = debugInfo['providers'] as Map<String, dynamic>;
      expect(providers.containsKey('audio'), isTrue);
      expect(providers.containsKey('gameServices'), isTrue);
    });
  });
  
  group('🔧 Flutter公式準拠性確認', () {
    
    test('Provider pattern準拠確認', () {
      final factory = ProviderFactory.production();
      
      // 各プロバイダーが適切なインターフェースを実装していることを確認
      expect(factory.createAudioProvider(), isA<AudioProvider>());
      expect(factory.createInputProcessor(), isA<InputProcessor>());
      expect(factory.createStorageProvider(), isA<StorageProvider>());
      expect(factory.createAdProvider(), isA<AdProvider>());
      expect(factory.createAnalyticsProvider(), isA<AnalyticsProvider>());
    });
    
    test('設定クラス準拠確認', () {
      final factory = ProviderFactory.production();
      
      // 各設定クラスが適切なインターフェースを実装していることを確認
      expect(factory.createAudioConfiguration(), isA<AudioConfiguration>());
      expect(factory.createInputConfiguration(), isA<InputConfiguration>());
      expect(factory.createPersistenceConfiguration(), isA<PersistenceConfiguration>());
      expect(factory.createMonetizationConfiguration(), isA<MonetizationConfiguration>());
      expect(factory.createAnalyticsConfiguration(), isA<AnalyticsConfiguration>());
    });
    
    test('Flutter公式準拠マーカー確認', () {
      final factory = ProviderFactory.development();
      final debugInfo = factory.getDebugInfo();
      
      expect(debugInfo['flutter_official_compliant'], isTrue);
      
      final bundle = factory.createProviderBundle();
      final bundleDebugInfo = bundle.getDebugInfo();
      expect(bundleDebugInfo, isA<Map<String, dynamic>>());
    });
  });
}