import 'package:flutter_test/flutter_test.dart';

/// 自動ホットスポット生成機能のテスト
/// TODO: ObjectDetectionServiceとHotspotPositionOptimizerの実装後に有効化
void main() {
  group('自動画像認識ホットスポット生成テスト', () {
    testWidgets('テストスキップ - サービス未実装', (WidgetTester tester) async {
      // TODO: 以下のサービスが実装されたらテストを有効化:
      // - ObjectDetectionService
      // - HotspotPositionOptimizer
      expect(true, true); // Placeholder test
    });
  });
}
