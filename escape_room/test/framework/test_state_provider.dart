import 'package:flutter/material.dart';
import 'package:escape_room/framework/state/game_state_system.dart';
import 'test_states.dart';

/// テスト用の状態プロバイダー
class TestGameStateProvider extends GameStateProvider<GameState> {
  TestGameStateProvider() : super(const TestGameIdleState()) {
    _setupTransitions();
  }

  void _setupTransitions() {
    stateMachine.defineTransitions([
      // Idle -> Active
      StateTransition<GameState>(
        fromState: TestGameIdleState,
        toState: TestGameActiveState,
        onTransition: (from, to) {
          final activeState = to as TestGameActiveState;
          debugPrint('ゲーム開始: レベル${activeState.level}');
        },
      ),

      // Active -> Active (進捗更新)
      StateTransition<GameState>(
        fromState: TestGameActiveState,
        toState: TestGameActiveState,
        onTransition: (from, to) {
          final fromActive = from as TestGameActiveState;
          final toActive = to as TestGameActiveState;
          if (toActive.level > fromActive.level) {
            debugPrint('レベルアップ: ${fromActive.level} -> ${toActive.level}');
          }
        },
      ),

      // Active -> Completed
      StateTransition<GameState>(
        fromState: TestGameActiveState,
        toState: TestGameCompletedState,
        onTransition: (from, to) {
          final activeState = from as TestGameActiveState;
          final completedState = to as TestGameCompletedState;
          debugPrint(
            'ゲーム完了: レベル${activeState.level} -> 最終レベル${completedState.finalLevel}',
          );
        },
      ),

      // Completed -> Idle (リセット)
      StateTransition<GameState>(
        fromState: TestGameCompletedState,
        toState: TestGameIdleState,
        onTransition: (from, to) {
          debugPrint('ゲームリセット');
        },
      ),
    ]);
  }

  /// ゲーム開始
  bool startGame(int initialLevel) {
    final newState = TestGameActiveState(level: initialLevel, progress: 0.0);
    final success = transitionTo(newState);
    // Note: startNewSession method is removed as it's not available in the current implementation
    return success;
  }

  /// 進捗更新
  bool updateProgress(int level, double progress) {
    if (currentState is! TestGameActiveState) return false;

    final newState = TestGameActiveState(level: level, progress: progress);
    return transitionTo(newState);
  }

  /// ゲーム完了
  bool completeGame(int finalLevel, Duration completionTime) {
    if (currentState is! TestGameActiveState) return false;

    final completedState = TestGameCompletedState(
      finalLevel: finalLevel,
      completionTime: completionTime,
    );
    return transitionTo(completedState);
  }

  /// リセット
  bool resetGame() {
    if (currentState is! TestGameCompletedState) return false;

    return transitionTo(const TestGameIdleState());
  }
}
