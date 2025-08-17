import 'package:flutter_test/flutter_test.dart';
import 'package:escape_room/framework/monetization/monetization_system.dart';

void main() {
  group('収益化システム分割テスト', () {
    test('Monetization system can be imported and used', () {
      // Test that all classes can be imported and instantiated
      final config = DefaultMonetizationConfiguration();
      final provider = MockAdProvider();
      final manager = MonetizationManager(provider: provider, configuration: config);
      
      // Verify basic properties
      expect(config.testMode, isTrue);
      expect(config.interstitialInterval, equals(60));
      expect(config.rewardMultiplier, equals(2.0));
      expect(provider.runtimeType.toString(), equals('MockAdProvider'));
      expect(manager.provider, equals(provider));
      expect(manager.configuration, equals(config));
      
      print('✅ Monetization system refactoring test: SUCCESS');
    });
    
    test('Ad models work correctly', () {
      final eventData = AdEventData(
        adType: AdType.banner,
        result: AdResult.shown,
        adId: 'test_ad',
        timestamp: DateTime.now(),
      );
      
      expect(eventData.adType, equals(AdType.banner));
      expect(eventData.result, equals(AdResult.shown));
      expect(eventData.adId, equals('test_ad'));
      expect(eventData.toString(), contains('AdEventData'));
      
      print('✅ Ad models test: SUCCESS');
    });
    
    test('Configuration can be updated', () {
      const originalConfig = DefaultMonetizationConfiguration();
      final updatedConfig = originalConfig.copyWith(
        interstitialInterval: 120,
        rewardMultiplier: 3.0,
        testMode: false,
      );
      
      expect(updatedConfig.interstitialInterval, equals(120));
      expect(updatedConfig.rewardMultiplier, equals(3.0));
      expect(updatedConfig.testMode, isFalse);
      // Original values should remain unchanged for non-updated fields
      expect(updatedConfig.bannerPosition, equals(originalConfig.bannerPosition));
      
      print('✅ Configuration copyWith test: SUCCESS');
    });
  });
}