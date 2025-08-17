import 'package:flutter_test/flutter_test.dart';

// このテストファイルは旧アーキテクチャーに基づいており、
// 現在の実装（ConfigurableGame、SimpleGameフレームワーク）と互換性がありません。
// 
// 代替テストファイル:
// - test/integration/flame_integration_test.dart (統合テスト)
// - test/simple_flame_integration_test.dart (SimpleGameテスト)
// - test/framework_integration_test.dart (フレームワーク統合テスト)

void main() {
  group('Template Integration Tests (Disabled)', () {
    test('Legacy template tests are disabled', () {
      // 旧テンプレートシステムのテストは無効化されました
      // 新しいテストファイルをご利用ください：
      // - flame_integration_test.dart
      // - simple_flame_integration_test.dart  
      // - framework_integration_test.dart
      expect(true, isTrue, reason: 'Legacy tests disabled - use new integration tests');
    });
  });
}