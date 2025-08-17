import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';
import 'package:escape_room/framework/state/game_state_system.dart';
import 'test_states.dart';

void main() {
  group('汎用状態管理システムテスト', () {
    test('汎用状態管理システム - 基本動作', () {
      debugPrint('🔧 汎用状態管理システムテスト開始...');
      
      // カスタム状態での状態マシン作成
      final stateMachine = GameStateMachine<GameState>(const TestGameIdleState());
      
      // 状態遷移定義
      stateMachine.defineTransition(StateTransition<GameState>(
        fromState: TestGameIdleState,
        toState: TestGameActiveState,
        condition: (current, target) => 
            current is TestGameIdleState && target is TestGameActiveState,
      ));
      
      // 初期状態確認
      expect(stateMachine.currentState, isA<TestGameIdleState>());
      debugPrint('  ✅ 初期状態: ${stateMachine.currentState.name}');
      
      // 状態遷移実行
      final activeState = TestGameActiveState(level: 1, progress: 0.0);
      final success = stateMachine.transitionTo(activeState);
      
      expect(success, isTrue);
      expect(stateMachine.currentState, isA<TestGameActiveState>());
      debugPrint('  ✅ 状態遷移成功: ${stateMachine.currentState.description}');
      
      // 遷移可能性チェック
      final canTransitionToCompleted = stateMachine.canTransitionTo(
        TestGameCompletedState(finalLevel: 5, completionTime: Duration(seconds: 30))
      );
      expect(canTransitionToCompleted, isFalse); // 遷移定義されていないので失敗
      debugPrint('  ✅ 無効遷移の適切な拒否');
      
      debugPrint('🎉 汎用状態管理システムテスト完了！');
    });
  });
}