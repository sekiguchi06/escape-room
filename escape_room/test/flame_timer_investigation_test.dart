import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';

import 'package:flame/components.dart';

/// Flame公式Timer機能調査用テスト
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('Flame公式Timer機能調査', () {
    test('Timer基本機能確認', () {
      debugPrint('=== Flame Timer調査開始 ===');

      // Flame Timer基本構文確認
      final timer = Timer(
        2.0,
        onTick: () {
          debugPrint('Timer fired!');
        },
      );

      debugPrint('Timer作成成功');
      debugPrint('Timer toString: ${timer.toString()}');

      // タイマー開始
      timer.start();
      debugPrint('Timer開始実行');

      // 時間更新テスト
      timer.update(0.5);
      debugPrint('0.5秒更新完了');

      timer.update(1.0);
      debugPrint('1.0秒更新完了');

      timer.update(1.0);
      debugPrint('さらに1.0秒更新完了');
    });

    test('TimerComponent確認', () {
      debugPrint('=== TimerComponent調査 ===');

      int componentTickCount = 0;
      final timerComponent = TimerComponent(
        period: 1.5,
        repeat: true,
        onTick: () {
          componentTickCount++;
          debugPrint('TimerComponent tick: $componentTickCount');
        },
      );

      debugPrint('TimerComponent作成成功');
      debugPrint('TimerComponent toString: ${timerComponent.toString()}');

      // Component更新テスト
      timerComponent.update(0.5);
      debugPrint('0.5秒更新完了');

      timerComponent.update(1.0);
      debugPrint('1.0秒更新完了');

      timerComponent.update(1.0);
      debugPrint('さらに1.0秒更新完了: tickCount=$componentTickCount');
    });
  });
}
