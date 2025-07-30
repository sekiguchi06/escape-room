import 'package:flutter_test/flutter_test.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:casual_game_template/game/simple_game.dart';
import 'package:casual_game_template/game/framework_integration/simple_game_states.dart';
import 'package:casual_game_template/framework/state/game_state_system.dart';
import 'package:flutter/gestures.dart';

void main() {
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
      expect(game.stateProvider, isNotNull);
      expect(game.stateProvider.currentState, isA<SimpleGameStartState>());
      
      // タイマーマネージャーが初期化されているか確認
      expect(game.timerManager, isNotNull);
      
      // テーママネージャーが初期化されているか確認
      expect(game.themeManager, isNotNull);
      
      // 設定が正しく読み込まれているか確認
      expect(game.configuration, isNotNull);
      expect(game.config.gameDuration.inSeconds, equals(5));
    });

    test('コンポーネントの配置確認', () async {
      final game = SimpleGame();
      game.onGameResize(Vector2(400, 600));
      await game.onLoad();
      
      // テキストコンポーネントが追加されているか確認
      final textComponents = game.children.query<TextComponent>();
      expect(textComponents.length, greaterThanOrEqualTo(2)); // ステータスとコンフィグのテキスト
      
      // 各コンポーネントが正しく配置されているか確認
      bool foundStatusText = false;
      bool foundConfigText = false;
      
      for (final component in textComponents) {
        if (component.text.contains('TAP TO START')) {
          foundStatusText = true;
          // 中央配置の確認
          expect(component.anchor, equals(Anchor.center));
          expect(component.position.x, equals(200.0)); // 400/2
          expect(component.position.y, equals(300.0)); // 600/2
        } else if (component.text.contains('Config:')) {
          foundConfigText = true;
          // 左上配置の確認
          expect(component.position.x, equals(20.0));
          expect(component.position.y, equals(20.0));
        }
      }
      
      expect(foundStatusText, isTrue, reason: 'ステータステキストが見つからない');
      expect(foundConfigText, isTrue, reason: 'コンフィグテキストが見つからない');
    });

    test('タップイベントでのゲーム開始', () async {
      final game = SimpleGame();
      game.onGameResize(Vector2(400, 600));
      await game.onLoad();
      
      // 初期状態を確認
      expect(game.stateProvider.currentState, isA<SimpleGameStartState>());
      
      // タップイベントをシミュレート
      game.onTapDown(
        _createTapDownEvent(game, const Offset(200, 300))
      );
      
      // 状態がプレイング状態に変わったことを確認
      expect(game.stateProvider.currentState, isA<SimpleGamePlayingState>());
      
      // タイマーが開始されたことを確認
      expect(game.timerManager.hasTimer('main'), isTrue);
      expect(game.timerManager.isTimerRunning('main'), isTrue);
    });

    test('ゲームアップデートサイクル', () async {
      final game = SimpleGame();
      game.onGameResize(Vector2(400, 600));
      await game.onLoad();
      
      // ゲーム開始
      game.onTapDown(_createTapDownEvent(game, const Offset(200, 300)));
      expect(game.stateProvider.currentState, isA<SimpleGamePlayingState>());
      
      // 時間を進める
      game.update(1.0); // 1秒経過
      
      // 状態がまだプレイング状態であることを確認
      if (game.stateProvider.currentState is SimpleGamePlayingState) {
        final playingState = game.stateProvider.currentState as SimpleGamePlayingState;
        expect(playingState.timeRemaining, lessThan(5.0));
        expect(playingState.timeRemaining, greaterThan(3.0));
        
        // さらに時間を進める
        game.update(2.0); // さらに2秒経過
        
        if (game.stateProvider.currentState is SimpleGamePlayingState) {
          final updatedState = game.stateProvider.currentState as SimpleGamePlayingState;
          expect(updatedState.timeRemaining, lessThan(3.0));
        }
      }
      
      // ゲームオーバーまで時間を進める
      game.update(3.0); // 残り時間を超過
      
      // ゲームオーバー状態になることを確認
      expect(game.stateProvider.currentState, isA<SimpleGameOverState>());
    });

    test('ゲームオーバー後のリスタート', () async {
      final game = SimpleGame();
      game.onGameResize(Vector2(400, 600));
      await game.onLoad();
      
      // 完全なゲームサイクルを実行
      game.onTapDown(_createTapDownEvent(game, const Offset(200, 300)));
      expect(game.stateProvider.currentState, isA<SimpleGamePlayingState>());
      
      // ゲームオーバーまで時間を進める
      game.update(6.0); // ゲーム時間を超過
      expect(game.stateProvider.currentState, isA<SimpleGameOverState>());
      
      // リスタートタップ
      game.onTapDown(_createTapDownEvent(game, const Offset(200, 300)));
      
      // 再びプレイング状態になることを確認
      expect(game.stateProvider.currentState, isA<SimpleGamePlayingState>());
      
      // タイマーがリセットされて開始されていることを確認
      expect(game.timerManager.isTimerRunning('main'), isTrue);
    });

    test('設定切り替え機能', () async {
      final game = SimpleGame();
      game.onGameResize(Vector2(400, 600));
      await game.onLoad();
      
      // 初期設定を確認
      expect(game.config.gameDuration.inSeconds, equals(5));
      
      // ゲーム開始（設定が切り替わる）
      game.onTapDown(_createTapDownEvent(game, const Offset(200, 300)));
      
      // 最初のセッション（_sessionCount = 0）では 'default' 設定が使われる
      final newDuration = game.config.gameDuration.inSeconds;
      expect(newDuration, equals(5)); // default設定
      
      // ゲームオーバー後の次のサイクル
      game.update(15.0); // 十分な時間経過
      expect(game.stateProvider.currentState, isA<SimpleGameOverState>());
      
      game.onTapDown(_createTapDownEvent(game, const Offset(200, 300)));
      
      // 次のセッション（_sessionCount = 1）では 'easy' 設定が使われる
      final thirdDuration = game.config.gameDuration.inSeconds;
      expect(thirdDuration, equals(10)); // easy設定
    });

    test('フレームワーク統合の完全性', () async {
      final game = SimpleGame();
      game.onGameResize(Vector2(400, 600));
      await game.onLoad();
      
      // フレームワークの各システムが統合されていることを確認
      expect(game.stateProvider, isNotNull);
      expect(game.timerManager, isNotNull);
      expect(game.themeManager, isNotNull);
      expect(game.configuration, isNotNull);
      expect(game.audioManager, isNotNull);
      expect(game.inputManager, isNotNull);
      expect(game.dataManager, isNotNull);
      expect(game.monetizationManager, isNotNull);
      expect(game.analyticsManager, isNotNull);
      
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
      expect(game.stateProvider.currentState, isA<GameState>());
      expect(game.children.length, greaterThan(0));
      
      // 連続的なタップイベント
      for (int i = 0; i < 10; i++) {
        game.onTapDown(_createTapDownEvent(game, Offset(200 + i * 10, 300)));
        game.update(0.1);
      }
      
      // ゲームが安定していることを確認
      expect(game.stateProvider.currentState, isA<GameState>());
    });
  });
}

/// テスト用のTapDownEventを作成するヘルパー関数
TapDownEvent _createTapDownEvent(SimpleGame game, Offset position) {
  return TapDownEvent(
    1, // pointerId
    game,
    TapDownDetails(globalPosition: position),
  );
}