import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'test_config.dart';
import 'test_state_provider.dart';
import 'test_states.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('統合シナリオテスト', () {
    test('統合シナリオ - 複合ゲームシミュレーション', () {
      debugPrint('🎮 統合シナリオテスト開始...');
      
      // 設定作成
      final config = TestGameConfig(
        maxTime: Duration(seconds: 30),
        maxLevel: 3,
        messages: {
          'start': 'Ready to play?',
          'level_up': 'Level Up!',
          'complete': 'Congratulations!',
        },
        colors: {
          'normal': Colors.blue,
          'warning': Colors.orange,
          'critical': Colors.red,
        },
        enablePowerUps: true,
        difficultyMultiplier: 1.2,
      );
      
      final configuration = TestGameConfiguration(config: config);
      final stateProvider = TestGameStateProvider();
      
      debugPrint('  🎯 ゲームシナリオ実行...');
      
      // Phase 1: ゲーム開始
      expect(stateProvider.currentState, isA<TestGameIdleState>());
      debugPrint('    📍 初期状態: ${stateProvider.currentState.name}');
      
      final startSuccess = stateProvider.startGame(1);
      expect(startSuccess, isTrue);
      expect(stateProvider.currentState, isA<TestGameActiveState>());
      
      final initialState = stateProvider.currentState as TestGameActiveState;
      expect(initialState.level, equals(1));
      expect(initialState.progress, equals(0.0));
      debugPrint('    🚀 ゲーム開始: レベル${initialState.level}');
      
      // Phase 2: 進捗更新・レベルアップ
      stateProvider.updateProgress(1, 0.5);
      stateProvider.updateProgress(2, 0.0); // レベルアップ
      stateProvider.updateProgress(2, 0.8);
      stateProvider.updateProgress(3, 0.0); // レベルアップ
      
      final currentState = stateProvider.currentState as TestGameActiveState;
      expect(currentState.level, equals(3));
      debugPrint('    📈 最終レベル到達: レベル${currentState.level}');
      
      // Phase 3: ゲーム完了
      final completionTime = Duration(seconds: 25);
      final completeSuccess = stateProvider.completeGame(3, completionTime);
      expect(completeSuccess, isTrue);
      expect(stateProvider.currentState, isA<TestGameCompletedState>());
      
      final completedState = stateProvider.currentState as TestGameCompletedState;
      expect(completedState.finalLevel, equals(3));
      expect(completedState.completionTime, equals(completionTime));
      debugPrint('    🏆 ゲーム完了: 最終レベル${completedState.finalLevel}, 時間${completedState.completionTime.inSeconds}秒');
      
      // Phase 4: 統計確認
      final statistics = stateProvider.getStatistics();
      expect(statistics.sessionCount, greaterThan(0));
      expect(statistics.totalStateChanges, greaterThan(0));
      debugPrint('    📊 統計情報:');
      debugPrint('      - セッション数: ${statistics.sessionCount}');
      debugPrint('      - 状態変更数: ${statistics.totalStateChanges}');
      debugPrint('      - 最多訪問状態: ${statistics.mostVisitedState}');
      
      // Phase 5: リセット
      final resetSuccess = stateProvider.resetGame();
      expect(resetSuccess, isTrue);
      expect(stateProvider.currentState, isA<TestGameIdleState>());
      debugPrint('    🔄 ゲームリセット完了');
      
      // Phase 6: A/Bテスト設定変更
      final hardConfig = configuration.getConfigForVariant('hard');
      expect(hardConfig.maxTime.inSeconds, equals(30));
      expect(hardConfig.maxLevel, equals(10));
      expect(hardConfig.difficultyMultiplier, equals(2.0));
      debugPrint('    🧪 A/Bテスト (hard): 時間${hardConfig.maxTime.inSeconds}秒, レベル${hardConfig.maxLevel}, 難易度x${hardConfig.difficultyMultiplier}');
      
      debugPrint('🎉 統合シナリオテスト完了！');
    });
  });
}