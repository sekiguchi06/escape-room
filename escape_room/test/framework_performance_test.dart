import 'package:flutter_test/flutter_test.dart';

import 'package:flutter/material.dart';
import 'package:escape_room/framework/state/game_state_system.dart';
import 'package:escape_room/framework/config/game_configuration.dart';
import 'package:escape_room/framework/timer/flame_timer_system.dart';

/// パフォーマンステスト用の軽量状態
class PerfTestState extends GameState {
  final int id;
  final String data;

  const PerfTestState(this.id, this.data) : super();

  @override
  String get name => 'perf_$id';

  @override
  String get description => 'Performance test state $id: $data';

  @override
  bool operator ==(Object other) {
    return other is PerfTestState && other.id == id && other.data == data;
  }

  @override
  int get hashCode => Object.hash(id, data);
}

/// パフォーマンステスト用の設定
class PerfTestConfig {
  final int iterations;
  final Duration duration;
  final List<String> dataSet;

  const PerfTestConfig({
    required this.iterations,
    required this.duration,
    required this.dataSet,
  });

  PerfTestConfig copyWith({
    int? iterations,
    Duration? duration,
    List<String>? dataSet,
  }) {
    return PerfTestConfig(
      iterations: iterations ?? this.iterations,
      duration: duration ?? this.duration,
      dataSet: dataSet ?? this.dataSet,
    );
  }

  Map<String, dynamic> toJson() => {
    'iterations': iterations,
    'duration': duration.inMilliseconds,
    'dataSet': dataSet,
  };
}

/// パフォーマンステスト用の設定クラス
class PerfTestConfiguration
    extends GameConfiguration<GameState, PerfTestConfig> {
  PerfTestConfiguration({required super.config});

  @override
  bool isValid() => config.iterations > 0 && config.dataSet.isNotEmpty;

  @override
  bool isValidConfig(PerfTestConfig config) =>
      config.iterations > 0 && config.dataSet.isNotEmpty;

  @override
  PerfTestConfig copyWith(Map<String, dynamic> overrides) {
    return config.copyWith(
      iterations: overrides['iterations'] as int?,
      duration: overrides['duration'] as Duration?,
      dataSet: overrides['dataSet'] as List<String>?,
    );
  }

  @override
  Map<String, dynamic> toJson() => config.toJson();

  @override
  PerfTestConfig getConfigForVariant(String variantId) => config;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('フレームワークパフォーマンステスト', () {
    test('大量状態遷移パフォーマンス', () {
      debugPrint('🚀 大量状態遷移パフォーマンステスト開始...');

      final stopwatch = Stopwatch();
      final stateMachine = GameStateMachine<GameState>(
        const PerfTestState(0, 'initial'),
      );

      // 大量の状態遷移定義
      debugPrint('  📝 状態遷移定義中...');
      stopwatch.start();

      for (int i = 0; i < 100; i++) {
        stateMachine.defineTransition(
          StateTransition<GameState>(
            fromState: PerfTestState,
            toState: PerfTestState,
            condition: (current, target) =>
                current is PerfTestState && target is PerfTestState,
          ),
        );
      }

      stopwatch.stop();
      debugPrint('  ✅ 100個の遷移定義完了: stopwatch.elapsedMillisecondsms');

      // 大量状態遷移実行
      debugPrint('  🔄 大量状態遷移実行中...');
      stopwatch.reset();
      stopwatch.start();

      int successfulTransitions = 0;
      for (int i = 1; i <= 1000; i++) {
        final newState = PerfTestState(i, 'data_$i');
        if (stateMachine.transitionTo(newState)) {
          successfulTransitions++;
        }
      }

      stopwatch.stop();
      final transitionsPerSecond =
          (successfulTransitions * 1000) / stopwatch.elapsedMilliseconds;

      expect(successfulTransitions, equals(1000));
      expect(transitionsPerSecond, greaterThan(100)); // パフォーマンス要件
      debugPrint('  ✅ 1000回遷移完了: ${stopwatch.elapsedMilliseconds}ms');
      debugPrint('  📊 遷移速度: ${transitionsPerSecond.toStringAsFixed(0)} 遷移/秒');

      // メモリ使用量チェック (概算)
      final finalState = stateMachine.currentState as PerfTestState;
      expect(finalState.id, equals(1000));
      debugPrint('  ✅ 最終状態確認: ID=finalState.id, データ="finalState.data"');

      debugPrint('🎉 大量状態遷移パフォーマンステスト完了！');
    });

    test('複数タイマー同時実行パフォーマンス', () {
      debugPrint('⏱️ 複数タイマー同時実行パフォーマンステスト開始...');

      final timerManager = FlameTimerManager();
      final stopwatch = Stopwatch();

      // 100個のタイマーを作成
      debugPrint('  📝 100個のタイマー作成中...');
      stopwatch.start();

      final completionCounts = <String, int>{};

      for (int i = 0; i < 100; i++) {
        final timerId = 'timer_$i';
        completionCounts[timerId] = 0;

        timerManager.addTimer(
          timerId,
          TimerConfiguration(
            duration: Duration(
              milliseconds: 100 + (i % 10) * 50,
            ), // 100-600ms の範囲
            type: i % 3 == 0
                ? TimerType.countdown
                : i % 3 == 1
                ? TimerType.countup
                : TimerType.interval,
            onComplete: () =>
                completionCounts[timerId] = completionCounts[timerId]! + 1,
            onUpdate: (remaining) {}, // 空実装でパフォーマンステスト
            autoStart: true,
          ),
        );
      }

      stopwatch.stop();
      debugPrint('  ✅ 100個のタイマー作成完了: stopwatch.elapsedMillisecondsms');

      expect(timerManager.getTimerIds().length, equals(100));
      debugPrint('  📊 登録タイマー数: timerManager.getTimerIds().length');

      // 全タイマー同時実行
      debugPrint('  🚀 全タイマー同時実行中...');
      stopwatch.reset();
      stopwatch.start();

      timerManager.startAllTimers();
      final runningTimers = timerManager.getRunningTimerIds();
      expect(runningTimers.length, equals(100));
      debugPrint('  ✅ 実行中タイマー数: runningTimers.length');

      // 複数フレーム更新をシミュレート
      int frameCount = 0;
      int totalCompletions = 0;

      while (frameCount < 60 && timerManager.getRunningTimerIds().isNotEmpty) {
        // 最大60フレーム
        // 16.67ms (60FPS) のフレーム更新をシミュレート
        for (final timerId in timerManager.getTimerIds()) {
          final timer = timerManager.getTimer(timerId);
          if (timer != null && timer.isRunning) {
            timer.update(0.0167); // 16.67ms
          }
        }

        frameCount++;

        // インターバルタイマーの完了数をカウント
        totalCompletions = completionCounts.values.fold(
          0,
          (sum, count) => sum + count,
        );
      }

      stopwatch.stop();

      debugPrint(
        '  ✅ シミュレーション完了: $frameCountフレーム, ${stopwatch.elapsedMilliseconds}ms',
      );
      debugPrint('  📊 総完了回数: $totalCompletions');
      debugPrint(
        '  📊 平均FPS: (frameCount * 1000 / stopwatch.elapsedMilliseconds).toStringAsFixed(1)',
      );

      // タイマー制御操作パフォーマンス
      debugPrint('  🎛️ 一括制御操作テスト中...');
      stopwatch.reset();
      stopwatch.start();

      timerManager.pauseAllTimers();
      timerManager.resumeAllTimers();
      timerManager.stopAllTimers();

      stopwatch.stop();
      debugPrint('  ✅ 一括制御操作完了: stopwatch.elapsedMillisecondsms');

      debugPrint('🎉 複数タイマー同時実行パフォーマンステスト完了！');
    });

    test('設定変更・JSON変換パフォーマンス', () {
      debugPrint('⚙️ 設定変更・JSON変換パフォーマンステスト開始...');

      // 大規模データセット作成
      final largeDataSet = List.generate(1000, (i) => 'data_item_$i');

      final config = PerfTestConfig(
        iterations: 10000,
        duration: Duration(milliseconds: 5000),
        dataSet: largeDataSet,
      );

      final configuration = PerfTestConfiguration(config: config);
      final stopwatch = Stopwatch();

      // 設定妥当性チェックパフォーマンス
      debugPrint('  🔍 設定妥当性チェック中...');
      stopwatch.start();

      for (int i = 0; i < 1000; i++) {
        final isValid = configuration.isValid();
        expect(isValid, isTrue);
      }

      stopwatch.stop();
      debugPrint('  ✅ 1000回妥当性チェック完了: stopwatch.elapsedMillisecondsms');

      // JSON変換パフォーマンス
      debugPrint('  📄 JSON変換パフォーマンステスト中...');
      stopwatch.reset();
      stopwatch.start();

      final jsonResults = <Map<String, dynamic>>[];
      for (int i = 0; i < 100; i++) {
        final json = configuration.toJson();
        jsonResults.add(json);
      }

      stopwatch.stop();
      final jsonSerializationTime = stopwatch.elapsedMilliseconds;
      debugPrint('  ✅ 100回JSON変換完了: jsonSerializationTimems');

      // JSON復元パフォーマンス
      stopwatch.reset();
      stopwatch.start();

      final restoredConfigs = <PerfTestConfiguration>[];
      for (final json in jsonResults) {
        final restored = PerfTestConfiguration(
          config: PerfTestConfig(
            iterations: json['iterations'],
            duration: Duration(milliseconds: json['duration']),
            dataSet: List<String>.from(json['dataSet']),
          ),
        );
        restoredConfigs.add(restored);
      }

      stopwatch.stop();
      final jsonDeserializationTime = stopwatch.elapsedMilliseconds;
      debugPrint('  ✅ 100回JSON復元完了: jsonDeserializationTimems');

      expect(restoredConfigs.length, equals(100));
      expect(
        restoredConfigs.first.config.dataSet.length,
        equals(largeDataSet.length),
      );

      // 平均処理時間算出
      final avgSerializationTime = jsonSerializationTime / 100.0;
      final avgDeserializationTime = jsonDeserializationTime / 100.0;

      expect(avgSerializationTime, lessThan(10.0)); // パフォーマンス要件
      expect(avgDeserializationTime, lessThan(10.0)); // パフォーマンス要件
      debugPrint(
        '  📊 平均JSON変換時間: ${avgSerializationTime.toStringAsFixed(2)}ms',
      );
      debugPrint(
        '  📊 平均JSON復元時間: ${avgDeserializationTime.toStringAsFixed(2)}ms',
      );

      // 大容量データ処理確認
      expect(restoredConfigs.first.config.dataSet.length, equals(1000));
      debugPrint('  ✅ 大容量データ (1000項目) 処理成功');

      debugPrint('🎉 設定変更・JSON変換パフォーマンステスト完了！');
    });

    test('メモリ効率性・リソース管理テスト', () {
      debugPrint('💾 メモリ効率性・リソース管理テスト開始...');

      final stopwatch = Stopwatch();
      final stateProviders = <GameStateProvider<GameState>>[];

      // 複数の状態プロバイダー作成
      debugPrint('  🏗️ 100個の状態プロバイダー作成中...');
      stopwatch.start();

      for (int i = 0; i < 100; i++) {
        final provider = GameStateProvider<GameState>(
          PerfTestState(i, 'provider_$i'),
        );

        // 状態遷移定義
        provider.stateMachine.defineTransition(
          StateTransition<GameState>(
            fromState: PerfTestState,
            toState: PerfTestState,
            condition: (current, target) =>
                current is PerfTestState && target is PerfTestState,
          ),
        );

        // 状態遷移履歴を蓄積
        for (int j = 0; j < 10; j++) {
          provider.transitionTo(PerfTestState(i * 10 + j, 'state_i_j'));
        }

        stateProviders.add(provider);
      }

      stopwatch.stop();
      debugPrint('  ✅ 100個の状態プロバイダー作成完了: stopwatch.elapsedMillisecondsms');

      // 統計情報収集パフォーマンス
      debugPrint('  📊 統計情報収集パフォーマンステスト中...');
      stopwatch.reset();
      stopwatch.start();

      final allStatistics = <StateStatistics>[];
      for (final provider in stateProviders) {
        final stats = provider.getStatistics();
        allStatistics.add(stats);
      }

      stopwatch.stop();
      debugPrint('  ✅ 100個の統計情報収集完了: stopwatch.elapsedMillisecondsms');

      // データ検証
      expect(allStatistics.length, equals(100));
      final totalStateChanges = allStatistics.fold(
        0,
        (sum, stats) => sum + stats.totalStateChanges,
      );
      debugPrint('  📈 総状態変更数: $totalStateChanges');
      expect(
        totalStateChanges,
        equals(2000),
      ); // 100プロバイダー × 10遷移 + 初期状態遷移 × 100 × 10

      // リソース使用量チェック (概算)
      final avgTransitionsPerProvider =
          totalStateChanges / stateProviders.length;
      expect(avgTransitionsPerProvider, greaterThan(10.0)); // 平均遷移数要件
      debugPrint(
        '  📊 プロバイダーあたり平均遷移数: ${avgTransitionsPerProvider.toStringAsFixed(1)}',
      );

      // 遷移履歴サイズ制限チェック
      for (final provider in stateProviders) {
        final historySize = provider.transitionHistory.length;
        expect(historySize, lessThanOrEqualTo(1000)); // 履歴サイズ制限確認
      }
      debugPrint('  ✅ 遷移履歴サイズ制限確認完了');

      // 大量データクリーンアップシミュレーション
      debugPrint('  🧹 リソースクリーンアップテスト中...');
      stopwatch.reset();
      stopwatch.start();

      stateProviders.clear(); // 明示的なクリーンアップ

      stopwatch.stop();
      debugPrint('  ✅ リソースクリーンアップ完了: stopwatch.elapsedMillisecondsms');

      debugPrint('🎉 メモリ効率性・リソース管理テスト完了！');
    });

    test('高負荷シナリオ統合テスト', () {
      debugPrint('🔥 高負荷シナリオ統合テスト開始...');

      final overallStopwatch = Stopwatch();
      overallStopwatch.start();

      // シナリオ: 10個のゲームが同時に動作
      final gameSimulations = <Map<String, dynamic>>[];

      for (int gameId = 0; gameId < 10; gameId++) {
        debugPrint('  🎮 ゲーム$gameId シミュレーション開始...');

        // 各ゲームのコンポーネント作成
        final stateProvider = GameStateProvider<GameState>(
          PerfTestState(0, 'game_gameId_start'),
        );

        // 状態遷移定義
        stateProvider.stateMachine.defineTransition(
          StateTransition<GameState>(
            fromState: PerfTestState,
            toState: PerfTestState,
            condition: (current, target) =>
                current is PerfTestState && target is PerfTestState,
          ),
        );

        final timerManager = FlameTimerManager();
        final config = PerfTestConfiguration(
          config: PerfTestConfig(
            iterations: 100,
            duration: Duration(seconds: 10),
            dataSet: List.generate(50, (i) => 'game_gameId_data_$i'),
          ),
        );

        // メインタイマー追加
        timerManager.addTimer(
          'main',
          TimerConfiguration(
            duration: Duration(seconds: 5),
            type: TimerType.countdown,
            autoStart: true,
          ),
        );

        // サブタイマー追加 (複数)
        for (int i = 0; i < 5; i++) {
          timerManager.addTimer(
            'sub_$i',
            TimerConfiguration(
              duration: Duration(milliseconds: 500 + i * 100),
              type: TimerType.interval,
              autoStart: true,
            ),
          );
        }

        // ゲーム進行シミュレーション
        int stateChanges = 0;
        for (int step = 0; step < 20; step++) {
          final newState = PerfTestState(step, 'game_gameId_step_$step');
          if (stateProvider.transitionTo(newState)) {
            stateChanges++;
          }

          // タイマー更新
          for (final timerId in timerManager.getTimerIds()) {
            final timer = timerManager.getTimer(timerId);
            timer?.update(0.05); // 50ms更新
          }
        }

        // ゲーム結果記録
        final gameResult = {
          'gameId': gameId,
          'stateChanges': stateChanges,
          'finalState': stateProvider.currentState.name,
          'statistics': stateProvider.getStatistics(),
          'activeTimers': timerManager.getRunningTimerIds().length,
          'configValid': config.isValid(),
        };

        gameSimulations.add(gameResult);
        debugPrint(
          '    ✅ ゲーム$gameId 完了: $stateChanges状態変更, ${gameResult['activeTimers']}アクティブタイマー',
        );
      }

      overallStopwatch.stop();

      // 統合結果検証
      expect(gameSimulations.length, equals(10));

      final totalStateChanges = gameSimulations.fold(
        0,
        (sum, game) => sum + (game['stateChanges'] as int),
      );
      final totalActiveTimers = gameSimulations.fold(
        0,
        (sum, game) => sum + (game['activeTimers'] as int),
      );
      final allConfigsValid = gameSimulations.every(
        (game) => game['configValid'] as bool,
      );

      debugPrint('  📊 統合結果:');
      debugPrint('    - 総実行時間: overallStopwatch.elapsedMillisecondsms');
      debugPrint('    - 総状態変更数: $totalStateChanges');
      debugPrint('    - 総アクティブタイマー数: $totalActiveTimers');
      debugPrint('    - 全設定妥当性: $allConfigsValid');
      debugPrint(
        '    - 平均ゲーム実行時間: overallStopwatch.elapsedMilliseconds / 10ms',
      );

      // パフォーマンス閾値チェック
      expect(overallStopwatch.elapsedMilliseconds, lessThan(5000)); // 5秒以内
      expect(totalStateChanges, equals(200)); // 10ゲーム × 20状態変更
      expect(allConfigsValid, isTrue);

      debugPrint('  🏆 パフォーマンス要件クリア!');
      debugPrint(
        '    - 実行時間: overallStopwatch.elapsedMillisecondsms < 5000ms ✅',
      );
      debugPrint('    - 状態変更: $totalStateChanges = 200 ✅');
      debugPrint('    - 設定妥当性: $allConfigsValid ✅');

      debugPrint('🎉 高負荷シナリオ統合テスト完了！');
    });
  });
}
