import 'package:flutter_test/flutter_test.dart';
import 'package:flame/game.dart';
import 'package:casual_game_template/game/simple_game.dart';

void main() {
  group('SimpleGame Component分離テスト', () {
    late SimpleGame game;

    setUp(() {
      game = SimpleGame();
    });

    testWidgets('ゲーム初期化テスト', (tester) async {
      await tester.pumpWidget(GameWidget(game: game));
      await tester.pump();
      
      // 初期状態の確認
      expect(game.currentState, SimpleGameState.start);
      expect(game.gameTimer.currentTime, 5.0);
      expect(game.gameTimer.isRunning, false);
    });

    testWidgets('ゲーム開始テスト', (tester) async {
      await tester.pumpWidget(GameWidget(game: game));
      await tester.pump();
      
      // ゲーム開始をシミュレート
      await tester.tap(find.byType(GameWidget));
      await tester.pump();
      
      // 状態変更の確認
      expect(game.currentState, SimpleGameState.playing);
      expect(game.gameTimer.isRunning, true);
    });

    testWidgets('タイマー動作テスト', (tester) async {
      await tester.pumpWidget(GameWidget(game: game));
      await tester.pump();
      
      // ゲーム開始
      await tester.tap(find.byType(GameWidget));
      await tester.pump();
      
      // 時間経過をシミュレート
      game.update(1.0); // 1秒経過
      expect(game.gameTimer.currentTime, 4.0);
      
      game.update(4.1); // さらに4.1秒経過（合計5.1秒）
      expect(game.currentState, SimpleGameState.gameOver);
      expect(game.gameTimer.isRunning, false);
    });

    testWidgets('リスタート機能テスト', (tester) async {
      await tester.pumpWidget(GameWidget(game: game));
      await tester.pump();
      
      // ゲーム開始 → ゲームオーバー → リスタート
      await tester.tap(find.byType(GameWidget));
      await tester.pump();
      
      // 強制的にゲームオーバーにする
      game.update(6.0);
      expect(game.currentState, SimpleGameState.gameOver);
      
      // リスタート
      await tester.tap(find.byType(GameWidget));
      await tester.pump();
      
      // リスタート後の状態確認
      expect(game.currentState, SimpleGameState.playing);
      expect(game.gameTimer.currentTime, 5.0);
      expect(game.gameTimer.isRunning, true);
    });
    
    test('GameTimerComponent単体テスト', () {
      final timer = game.gameTimer;
      
      // 初期状態
      expect(timer.currentTime, 5.0);
      expect(timer.isRunning, false);
      expect(timer.isFinished, false);
      
      // 開始
      timer.start();
      expect(timer.isRunning, true);
      
      // 時間更新
      timer.update(2.0);
      expect(timer.currentTime, 3.0);
      
      // 停止
      timer.stop();
      expect(timer.isRunning, false);
      
      // リセット
      timer.reset();
      expect(timer.currentTime, 5.0);
      expect(timer.isRunning, false);
    });
  });
}