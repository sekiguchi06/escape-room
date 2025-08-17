import 'package:flutter_test/flutter_test.dart';

// 機能別テストファイルをインポート
import 'framework/state_management_test.dart' as state_tests;
import 'framework/configuration_management_test.dart' as config_tests;
import 'framework/timer_system_test.dart' as timer_tests;
import 'framework/ui_theme_test.dart' as theme_tests;
import 'framework/integration_scenario_test.dart' as integration_tests;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('フレームワークコア基盤テスト - 統合実行', () {
    // 各テストグループを実行
    state_tests.main();
    config_tests.main();
    timer_tests.main();
    theme_tests.main();
    integration_tests.main();
  });
}