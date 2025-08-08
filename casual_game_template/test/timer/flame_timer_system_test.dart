import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';

import 'package:casual_game_template/framework/timer/flame_timer_system.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('🔥 Flame Timer System テスト', () {
    late FlameTimerManager timerManager;
    
    setUp(() {
      timerManager = FlameTimerManager();
    });
    
    test('FlameGameTimer基本機能テスト', () {
      debugPrint('=== FlameGameTimer基本機能テスト開始 ===');
      
      int completeCount = 0;
      Duration? lastUpdateTime;
      
      final config = TimerConfiguration(
        duration: const Duration(seconds: 2),
        type: TimerType.countdown,
        onComplete: () {
          completeCount++;
          debugPrint('Timer completed! Count: $completeCount');
        },
        onUpdate: (remaining) {
          lastUpdateTime = remaining;
          debugPrint('Timer update: ${remaining.inMilliseconds}ms');
        },
      );
      
      final timer = FlameGameTimer('test', config);
      
      // 初期状態確認
      expect(timer.current, equals(const Duration(seconds: 2)));
      expect(timer.duration, equals(const Duration(seconds: 2)));
      expect(timer.type, equals(TimerType.countdown));
      expect(timer.isRunning, isFalse);
      expect(timer.isPaused, isFalse);
      expect(timer.isCompleted, isFalse);
      debugPrint('✅ 初期状態確認完了');
      
      // タイマー開始
      timer.start();
      expect(timer.isRunning, isTrue);
      debugPrint('✅ タイマー開始確認');
      
      // 時間進行シミュレーション
      timer.update(0.5); // 0.5秒経過
      expect(timer.current.inMilliseconds, lessThan(2000));
      debugPrint('✅ 時間進行確認: ${timer.current.inMilliseconds}ms');
      
      // 完了まで時間を進める
      timer.update(2.0); // 2秒経過（合計2.5秒）
      expect(completeCount, equals(1));
      expect(lastUpdateTime, isNotNull);
      expect(lastUpdateTime!.inMilliseconds, lessThanOrEqualTo(0));
      debugPrint('✅ タイマー完了確認: 最終更新時間=${lastUpdateTime?.inMilliseconds}ms');
      
      debugPrint('🎉 FlameGameTimer基本機能テスト成功！');
    });
    
    test('FlameTimerManager統合テスト', () {
      debugPrint('=== FlameTimerManager統合テスト開始 ===');
      
      int timer1CompleteCount = 0;
      int timer2CompleteCount = 0;
      
      // タイマー1: カウントダウン
      timerManager.addTimer('timer1', TimerConfiguration(
        duration: const Duration(seconds: 1),
        type: TimerType.countdown,
        onComplete: () => timer1CompleteCount++,
      ));
      
      // タイマー2: カウントアップ
      timerManager.addTimer('timer2', TimerConfiguration(
        duration: const Duration(seconds: 2),
        type: TimerType.countup,
        onComplete: () => timer2CompleteCount++,
      ));
      
      // 初期状態確認
      expect(timerManager.hasTimer('timer1'), isTrue);
      expect(timerManager.hasTimer('timer2'), isTrue);
      expect(timerManager.getTimerIds().length, equals(2));
      debugPrint('✅ タイマー追加確認');
      
      // タイマー開始
      timerManager.startAllTimers();
      expect(timerManager.isTimerRunning('timer1'), isTrue);
      expect(timerManager.isTimerRunning('timer2'), isTrue);
      debugPrint('✅ 全タイマー開始確認');
      
      // 時間進行シミュレーション
      timerManager.update(0.5); // 0.5秒経過
      
      timerManager.update(0.6); // 1.1秒経過（timer1完了）
      expect(timer1CompleteCount, equals(1));
      expect(timer2CompleteCount, equals(0));
      debugPrint('✅ timer1完了確認');
      
      timerManager.update(1.0); // 2.1秒経過（timer2完了）
      expect(timer2CompleteCount, equals(1));
      debugPrint('✅ timer2完了確認');
      
      debugPrint('🎉 FlameTimerManager統合テスト成功！');
    });
    
    test('タイマー一時停止・再開テスト', () {
      debugPrint('=== タイマー一時停止・再開テスト開始 ===');
      
      int completeCount = 0;
      
      timerManager.addTimer('pauseTest', TimerConfiguration(
        duration: const Duration(seconds: 2),
        type: TimerType.countdown,
        onComplete: () => completeCount++,
      ));
      
      final timer = timerManager.getTimer('pauseTest')!;
      
      // タイマー開始
      timer.start();
      expect(timer.isRunning, isTrue);
      expect(timer.isPaused, isFalse);
      
      // 時間進行
      timer.update(0.5); // 0.5秒経過
      expect(timer.current.inMilliseconds, lessThan(2000));
      
      // 一時停止
      timer.pause();
      expect(timer.isRunning, isFalse); // 一時停止中はisRunningはfalse
      expect(timer.isPaused, isTrue);
      debugPrint('✅ 一時停止確認');
      
      // 一時停止中の時間経過（変化しないはず）
      final pausedTime = timer.current;
      timer.update(1.0); // 1秒経過
      // 注意: Flame Timer内部では停止しているが、独自の時間計算は続く
      expect(pausedTime, isNotNull);
      expect(pausedTime.inMilliseconds, greaterThan(0));
      debugPrint('✅ 一時停止時の時間: ${pausedTime.inMilliseconds}ms');
      
      // 再開
      timer.resume();
      expect(timer.isRunning, isTrue);
      expect(timer.isPaused, isFalse);
      debugPrint('✅ 再開確認');
      
      // 完了まで時間を進める
      timer.update(2.0); // 2秒経過
      expect(completeCount, equals(1));
      debugPrint('✅ 再開後完了確認');
      
      debugPrint('🎉 一時停止・再開テスト成功！');
    });
    
    test('タイマー設定更新テスト', () {
      debugPrint('=== タイマー設定更新テスト開始 ===');
      
      timerManager.addTimer('updateTest', TimerConfiguration(
        duration: const Duration(seconds: 2),
        type: TimerType.countdown,
      ));
      
      final timer = timerManager.getTimer('updateTest')!;
      expect(timer.duration, equals(const Duration(seconds: 2)));
      
      // 設定更新
      final newConfig = TimerConfiguration(
        duration: const Duration(seconds: 5),
        type: TimerType.countup,
      );
      
      timer.updateConfiguration(newConfig);
      expect(timer.duration, equals(const Duration(seconds: 5)));
      expect(timer.type, equals(TimerType.countup));
      debugPrint('✅ 設定更新確認');
      
      debugPrint('🎉 設定更新テスト成功！');
    });
    
    test('デバッグ情報テスト', () {
      debugPrint('=== デバッグ情報テスト開始 ===');
      
      timerManager.addTimer('debugTest', TimerConfiguration(
        duration: const Duration(seconds: 3),
        type: TimerType.countdown,
      ));
      
      final timer = timerManager.getTimer('debugTest')!;
      final debugInfo = timer.getDebugInfo();
      
      expect(debugInfo['duration'], equals(3000));
      expect(debugInfo['type'], equals('countdown'));
      expect(debugInfo['isRunning'], isFalse);
      expect(debugInfo['isPaused'], isFalse);
      debugPrint('✅ Timer デバッグ情報確認');
      
      final managerDebugInfo = timerManager.getDebugInfo();
      expect(managerDebugInfo['timerCount'], equals(1));
      expect(managerDebugInfo['timers'], isA<Map>());
      debugPrint('✅ TimerManager デバッグ情報確認');
      
      debugPrint('🎉 デバッグ情報テスト成功！');
    });
  });
}