import 'package:flutter_test/flutter_test.dart';
import 'package:casual_game_template/game/providers/game_state_provider.dart';

void main() {
  group('GameStateProvider テスト', () {
    late GameStateProvider provider;

    setUp(() {
      provider = GameStateProvider();
    });

    test('初期状態の確認', () {
      expect(provider.currentState, SimpleGameState.start);
      expect(provider.gameTimer, 5.0);
      expect(provider.gameSessionCount, 0);
      expect(provider.totalGamesPlayed, 0);
    });

    test('ゲーム開始状態遷移', () {
      provider.setPlayingState();
      
      expect(provider.currentState, SimpleGameState.playing);
      expect(provider.gameTimer, 5.0);
      expect(provider.gameSessionCount, 1);
      expect(provider.totalGamesPlayed, 1);
    });

    test('ゲームオーバー状態遷移', () {
      provider.setPlayingState();
      provider.setGameOverState();
      
      expect(provider.currentState, SimpleGameState.gameOver);
      expect(provider.gameTimer, 0.0);
    });

    test('タイマー更新機能', () {
      provider.setPlayingState();
      
      // 通常のタイマー更新
      provider.updateTimer(3.5);
      expect(provider.gameTimer, 3.5);
      expect(provider.currentState, SimpleGameState.playing);
      
      // 0以下になった場合の自動ゲームオーバー
      provider.updateTimer(-0.5);
      expect(provider.currentState, SimpleGameState.gameOver);
      expect(provider.gameTimer, 0.0);
    });

    test('リセット機能', () {
      provider.setPlayingState();
      provider.updateTimer(2.0);
      provider.setGameOverState();
      
      provider.resetGame();
      
      expect(provider.currentState, SimpleGameState.start);
      expect(provider.gameTimer, 5.0);
      // セッション情報は保持される
      expect(provider.gameSessionCount, 1);
    });

    test('セッションリセット機能', () {
      provider.setPlayingState();
      provider.setPlayingState(); // 2回目
      
      expect(provider.gameSessionCount, 2);
      
      provider.resetSession();
      
      expect(provider.currentState, SimpleGameState.start);
      expect(provider.gameTimer, 5.0);
      expect(provider.gameSessionCount, 0);
      // 総ゲーム数は保持される
      expect(provider.totalGamesPlayed, 2);
    });

    test('状態説明テキスト', () {
      expect(provider.getStateDescription(), 'TAP TO START');
      
      provider.setPlayingState();
      expect(provider.getStateDescription(), 'TIME: 5.0');
      
      provider.updateTimer(3.2);
      expect(provider.getStateDescription(), 'TIME: 3.2');
      
      provider.setGameOverState();
      expect(provider.getStateDescription(), 'GAME OVER\nTAP TO RESTART');
    });

    test('パフォーマンス最適化: 0.1秒未満の変更は通知しない', () {
      provider.setPlayingState();
      
      int notificationCount = 0;
      provider.addListener(() {
        notificationCount++;
      });
      
      // 初期通知をクリア
      notificationCount = 0;
      
      // 0.1秒未満の変更
      provider.updateTimer(4.95); // 0.05秒の変化
      expect(notificationCount, 0); // 通知されない
      
      // 0.1秒以上の変更
      provider.updateTimer(4.8); // 0.2秒の変化
      expect(notificationCount, 1); // 通知される
    });

    test('デバッグ情報取得', () {
      provider.setPlayingState();
      provider.updateTimer(3.7);
      
      final debugInfo = provider.getDebugInfo();
      
      expect(debugInfo['currentState'], 'SimpleGameState.playing');
      expect(debugInfo['gameTimer'], 3.7);
      expect(debugInfo['gameSessionCount'], 1);
      expect(debugInfo['totalGamesPlayed'], 1);
    });

    test('複数ゲームセッション', () {
      // 1回目のゲーム
      provider.setPlayingState();
      provider.setGameOverState();
      provider.resetGame();
      
      // 2回目のゲーム
      provider.setPlayingState();
      provider.setGameOverState();
      
      expect(provider.gameSessionCount, 2);
      expect(provider.totalGamesPlayed, 2);
    });
  });
}