import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'test_config.dart';

void main() {
  group('汎用設定管理システムテスト', () {
    test('汎用設定管理システム - 設定駆動', () {
      debugPrint('⚙️ 汎用設定管理システムテスト開始...');

      // テスト用設定作成
      final config = TestGameConfig(
        maxTime: Duration(seconds: 60),
        maxLevel: 5,
        messages: {'start': 'ゲーム開始', 'progress': '進行中', 'complete': '完了'},
        colors: {
          'primary': Colors.blue,
          'secondary': Colors.green,
          'danger': Colors.red,
        },
        enablePowerUps: true,
        difficultyMultiplier: 1.5,
      );

      debugPrint('  📝 設定作成完了:');
      debugPrint('    - 最大時間: ${config.maxTime.inSeconds}秒');
      debugPrint('    - 最大レベル: ${config.maxLevel}');
      debugPrint('    - パワーアップ: ${config.enablePowerUps}');
      debugPrint('    - 難易度倍率: ${config.difficultyMultiplier}');

      // 設定オブジェクト作成
      final configuration = TestGameConfiguration(config: config);
      expect(configuration.isValid(), isTrue);
      debugPrint('  ✅ 設定バリデーション成功');

      // JSON変換テスト
      final json = configuration.toJson();
      final restoredConfiguration = TestGameConfiguration.fromJson(json);

      expect(restoredConfiguration.config.maxTime, equals(config.maxTime));
      expect(restoredConfiguration.config.maxLevel, equals(config.maxLevel));
      expect(
        restoredConfiguration.config.enablePowerUps,
        equals(config.enablePowerUps),
      );
      debugPrint('  ✅ JSON変換・復元成功');

      // A/Bテスト設定テスト
      final easyVariant = configuration.getConfigForVariant('easy');
      expect(easyVariant.maxTime.inSeconds, equals(120));
      expect(easyVariant.maxLevel, equals(3));
      expect(easyVariant.difficultyMultiplier, equals(0.5));
      debugPrint(
        '  ✅ A/Bテストバリアント (easy): ${easyVariant.maxTime.inSeconds}秒, レベル${easyVariant.maxLevel}',
      );

      final hardVariant = configuration.getConfigForVariant('hard');
      expect(hardVariant.maxTime.inSeconds, equals(30));
      expect(hardVariant.maxLevel, equals(10));
      expect(hardVariant.difficultyMultiplier, equals(2.0));
      debugPrint(
        '  ✅ A/Bテストバリアント (hard): ${hardVariant.maxTime.inSeconds}秒, レベル${hardVariant.maxLevel}',
      );

      debugPrint('🎉 汎用設定管理システムテスト完了！');
    });
  });
}
