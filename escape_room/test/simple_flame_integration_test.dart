import 'package:flutter_test/flutter_test.dart';
import 'package:flame/components.dart';
import 'package:escape_room/game/simple_game.dart';
import 'package:escape_room/game/framework_integration/simple_game_states.dart';
import 'package:escape_room/game/framework_integration/simple_game_configuration.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('SimpleGame Flame統合テスト', () {
    test('SimpleGameの基本初期化', () async {
      final game = SimpleGame();

      // ゲームサイズを設定（テスト用）
      game.onGameResize(Vector2(400, 600));

      // onLoadを実行
      await game.onLoad();

      // 初期化が完了していることを確認
      expect(game.isInitialized, isTrue);

      // 状態プロバイダーが正しく初期化されているか確認
      expect(game.managers['stateProvider'], isNotNull);
      expect(
        (game.managers['stateProvider'] as SimpleGameStateProvider)
            .currentState,
        isA<SimpleGameStartState>(),
      );

      // タイマーマネージャーが初期化されているか確認
      expect(game.timerManager, isNotNull);

      // テーママネージャーが初期化されているか確認
      expect(game.managers['themeManager'], isNotNull);

      // 設定が正しく読み込まれているか確認
      expect(game.configuration, isNotNull);
      expect(
        game.config.gameDuration.inSeconds,
        equals(10),
      ); // defaultConfigurationは10秒
    });

    test('ゲーム状態変更', () async {
      final game = SimpleGame();
      game.onGameResize(Vector2(400, 600));
      await game.onLoad();

      // 初期状態を確認
      expect(game.currentState, isA<SimpleGameStartState>());

      // ゲーム開始
      game.startGame();
      expect(game.currentState, isA<SimpleGamePlayingState>());

      // ゲーム終了
      game.endGame();
      expect(game.currentState, isA<SimpleGameOverState>());
    });

    test('タップイベントでのゲーム開始', () async {
      final game = SimpleGame();
      game.onGameResize(Vector2(400, 600));
      await game.onLoad();

      // 初期状態を確認
      final stateProvider =
          game.managers['stateProvider'] as SimpleGameStateProvider;
      expect(stateProvider.currentState, isA<SimpleGameStartState>());

      // startGameメソッドを直接呼び出し
      game.startGame();

      // 状態がプレイング状態に変わったことを確認
      expect(game.currentState, isA<SimpleGamePlayingState>());

      // タイマーが開始されたことを確認
      final timer = game.timerManager['getTimer']('main');
      expect(timer, isNotNull);
    });

    test('ゲームアップデートサイクル', () async {
      final game = SimpleGame();
      game.onGameResize(Vector2(400, 600));
      await game.onLoad();

      // ゲーム開始
      game.startGame();
      expect(game.currentState, isA<SimpleGamePlayingState>());

      // 時間を進める
      game.update(1.0); // 1秒経過

      // 状態がまだプレイング状態であることを確認
      if (game.currentState is SimpleGamePlayingState) {
        final playingState = game.currentState as SimpleGamePlayingState;
        expect(playingState.timeRemaining, greaterThanOrEqualTo(0));

        // さらに時間を進める
        game.update(2.0); // さらに2秒経過

        // ゲームが正常に動作し続けることを確認
        expect(game.currentState, isA<SimpleGameState>());
      }

      // ゲーム終了テスト
      game.endGame();
      expect(game.currentState, isA<SimpleGameOverState>());
    });

    test('ゲームオーバー後のリスタート', () async {
      final game = SimpleGame();
      game.onGameResize(Vector2(400, 600));
      await game.onLoad();

      // 完全なゲームサイクルを実行
      game.startGame();
      expect(game.currentState, isA<SimpleGamePlayingState>());

      // ゲーム終了
      game.endGame();
      expect(game.currentState, isA<SimpleGameOverState>());

      // リスタート
      game.restartGame();

      // 再びプレイング状態になることを確認
      expect(game.currentState, isA<SimpleGamePlayingState>());
    });

    test('基本機能テスト', () async {
      final game = SimpleGame();
      game.onGameResize(Vector2(400, 600));
      await game.onLoad();

      // 一時停止・再開
      game.pauseGame();
      expect(game.paused, isTrue);

      game.resumeGame();
      expect(game.paused, isFalse);

      // リセット
      game.resetGame();
      expect(game.currentState, isA<SimpleGameStartState>());
      expect(game.paused, isFalse);
    });

    test('フレームワーク統合の完全性', () async {
      final game = SimpleGame();
      game.onGameResize(Vector2(400, 600));
      await game.onLoad();

      // フレームワークの各システムが統合されていることを確認
      expect(game.managers['stateProvider'], isNotNull);
      expect(game.timerManager, isNotNull);
      expect(game.managers['themeManager'], isNotNull);
      expect(game.configuration, isNotNull);
      expect(game.managers['audioManager'], isNotNull);
      expect(game.managers['dataManager'], isNotNull);
      expect(game.managers['monetizationManager'], isNotNull);
      expect(game.managers['analyticsManager'], isNotNull);

      // デバッグ情報が取得できることを確認
      final debugInfo = game.getDebugInfo();
      expect(debugInfo, isNotNull);
      expect(debugInfo.containsKey('game_type'), isTrue);
      expect(debugInfo.containsKey('initialized'), isTrue);
      expect(debugInfo.containsKey('current_state'), isTrue);
      expect(debugInfo.containsKey('performance'), isTrue);

      // パフォーマンスメトリクスが取得できることを確認
      final performanceMetrics = game.getPerformanceMetrics();
      expect(performanceMetrics, isNotNull);
      expect(performanceMetrics.containsKey('component_count'), isTrue);
      expect(performanceMetrics.containsKey('timer_count'), isTrue);
    });

    test('エラーハンドリングと安定性', () async {
      final game = SimpleGame();
      game.onGameResize(Vector2(400, 600));
      await game.onLoad();

      // 大きな時間ステップでのアップデート（フレームスキップシミュレーション）
      game.update(100.0); // 異常に大きなdt

      // ゲームが正常に動作し続けることを確認
      expect(game.currentState, isA<SimpleGameState>());
      expect(game.children.length, greaterThanOrEqualTo(0));

      // 連続的なupdate呼び出し（フレームスキップシミュレーション）
      for (int i = 0; i < 10; i++) {
        game.update(0.1);
      }

      // ゲームが安定していることを確認
      expect(game.currentState, isA<SimpleGameState>());
    });

    test('デバッグ情報取得', () async {
      final game = SimpleGame();
      game.onGameResize(Vector2(400, 600));
      await game.onLoad();

      final debugInfo = game.getDebugInfo();
      expect(debugInfo, isNotNull);
      expect(debugInfo.containsKey('currentState'), isTrue);
      expect(debugInfo.containsKey('paused'), isTrue);
      expect(debugInfo.containsKey('game_type'), isTrue);
      expect(debugInfo['game_type'], equals('SimpleGame'));
      expect(debugInfo['initialized'], isTrue);

      final performanceMetrics = game.getPerformanceMetrics();
      expect(performanceMetrics, isNotNull);
      expect(performanceMetrics.containsKey('fps'), isTrue);
      expect(performanceMetrics.containsKey('memory'), isTrue);
      expect(performanceMetrics.containsKey('component_count'), isTrue);
      expect(performanceMetrics.containsKey('timer_count'), isTrue);
    });
  });
}
