import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';
import 'package:casual_game_template/framework/timer/flame_timer_system.dart';

void main() {
  group('汎用タイマーシステムテスト', () {
    test('汎用タイマーシステム - 各種タイマータイプ', () {
      debugPrint('⏱️ 汎用タイマーシステムテスト開始...');
      
      // カウントダウンタイマー
      debugPrint('  🔻 カウントダウンタイマーテスト...');
      bool countdownCompleted = false; // タイマー完了フラグ
      final countdownTimer = FlameGameTimer('countdown_test', TimerConfiguration(
        duration: Duration(seconds: 3),
        type: TimerType.countdown,
        onComplete: () => countdownCompleted = true,
      ));
      
      expect(countdownTimer.remaining, equals(Duration(seconds: 3)));
      expect(countdownTimer.type, equals(TimerType.countdown));
      debugPrint('    ✅ 初期値: ${countdownTimer.remaining.inSeconds}秒');
      
      // タイマー開始・更新シミュレーション
      countdownTimer.start();
      expect(countdownTimer.isRunning, isTrue);
      
      // 1秒進行をシミュレート
      countdownTimer.update(1.0);
      expect(countdownTimer.remaining.inSeconds, equals(2));
      debugPrint('    ✅ 1秒後: ${countdownTimer.remaining.inSeconds}秒');
      
      // 完了まで進行してフラグをテスト
      expect(countdownCompleted, isFalse);
      countdownTimer.update(2.1); // 残り時間を0にする
      expect(countdownCompleted, isTrue);
      debugPrint('    ✅ タイマー完了フラグ: $countdownCompleted');
      
      // カウントアップタイマー
      debugPrint('  🔺 カウントアップタイマーテスト...');
      bool countupCompleted = false; // タイマー完了フラグ
      final countupTimer = FlameGameTimer('countup_test', TimerConfiguration(
        duration: Duration(seconds: 5),
        type: TimerType.countup,
        onComplete: () => countupCompleted = true,
      ));
      
      expect(countupTimer.remaining, equals(Duration(seconds: 5)));
      expect(countupTimer.type, equals(TimerType.countup));
      
      countupTimer.start();
      countupTimer.update(2.0);
      expect(countupTimer.remaining.inSeconds, equals(3));
      debugPrint('    ✅ 2秒後: ${countupTimer.remaining.inSeconds}秒残り');
      
      // 完了フラグのテスト
      expect(countupCompleted, isFalse);
      countupTimer.update(3.1); // 残り時間を0にする
      expect(countupCompleted, isTrue);
      debugPrint('    ✅ カウントアップタイマー完了フラグ: $countupCompleted');
      
      // インターバルタイマー
      debugPrint('  🔄 インターバルタイマーテスト...');
      int intervalCount = 0;
      final intervalTimer = FlameGameTimer('interval_test', TimerConfiguration(
        duration: Duration(seconds: 2),
        type: TimerType.interval,
        onComplete: () => intervalCount++,
      ));
      
      intervalTimer.start();
      intervalTimer.update(2.5); // 2秒を超えると1回完了
      expect(intervalCount, equals(1));
      debugPrint('    ✅ インターバル完了回数: $intervalCount');
      
      // タイマー制御操作
      debugPrint('  🎛️ タイマー制御テスト...');
      final controlTimer = FlameGameTimer('control_test', const TimerConfiguration(
        duration: Duration(seconds: 10),
        type: TimerType.countdown,
      ));
      
      controlTimer.start();
      expect(controlTimer.isRunning, isTrue);
      
      controlTimer.pause();
      expect(controlTimer.isPaused, isTrue);
      expect(controlTimer.isRunning, isFalse);
      
      controlTimer.resume();
      expect(controlTimer.isPaused, isFalse);
      expect(controlTimer.isRunning, isTrue);
      
      controlTimer.reset();
      expect(controlTimer.isRunning, isFalse);
      expect(controlTimer.remaining, equals(Duration(seconds: 10)));
      debugPrint('    ✅ 制御操作 (開始/一時停止/再開/リセット) 成功');
      
      debugPrint('🎉 汎用タイマーシステムテスト完了！');
    });
  });
}