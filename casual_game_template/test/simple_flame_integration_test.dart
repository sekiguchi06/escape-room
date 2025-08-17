import 'package:flutter_test/flutter_test.dart';

import 'package:flame/components.dart';
import 'package:casual_game_template/game/simple_game.dart';
import 'package:casual_game_template/game/framework_integration/simple_game_states.dart';
import 'package:casual_game_template/framework/state/game_state_system.dart';
import 'package:casual_game_template/framework/effects/particle_system.dart';
import 'package:casual_game_template/framework/animation/animation_system.dart';

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
      expect(game.managers.stateProvider, isNotNull);
      expect(game.managers.stateProvider.currentState, isA<SimpleGameStartState>());
      
      // タイマーマネージャーが初期化されているか確認
      expect(game.timerManager, isNotNull);
      
      // テーママネージャーが初期化されているか確認
      expect(game.managers.themeManager, isNotNull);
      
      // 設定が正しく読み込まれているか確認
      expect(game.configuration, isNotNull);
      expect(game.config.gameDuration.inSeconds, equals(10)); // defaultConfigurationは10秒
    });

    test('コンポーネントの配置確認', () async {
      final game = SimpleGame();
      game.onGameResize(Vector2(400, 600));
      await game.onLoad();
      
      // SimpleGame固有のコンポーネントが追加されているか確認（ParticleEffectManager、GameComponent）
      final particleManagers = game.children.query<ParticleEffectManager>();
      final gameComponents = game.children.whereType<GameComponent>();
      
      expect(particleManagers.length, equals(1), reason: 'ParticleEffectManagerが見つからない');
      expect(gameComponents.length, greaterThanOrEqualTo(1), reason: 'GameComponent(_testCircle)が見つからない');
      
      // 合計で2つ以上のコンポーネントが配置されていることを確認
      expect(game.children.length, greaterThanOrEqualTo(2));
    });

    test('タップイベントでのゲーム開始', () async {
      final game = SimpleGame();
      game.onGameResize(Vector2(400, 600));
      await game.onLoad();
      
      // 初期状態を確認
      expect(game.managers.stateProvider.currentState, isA<SimpleGameStartState>());
      
      // startGameメソッドを直接呼び出し（SimpleGameではタップによる自動ゲーム開始は無効化されている）
      game.startGame();
      
      // 状態がプレイング状態に変わったことを確認
      expect(game.managers.stateProvider.currentState, isA<SimpleGamePlayingState>());
      
      // タイマーが開始されたことを確認
      final timer = game.timerManager.getTimer('main');
      expect(timer, isNotNull);
      expect(timer!.isRunning, isTrue);
    });

    test('ゲームアップデートサイクル', () async {
      final game = SimpleGame();
      game.onGameResize(Vector2(400, 600));
      await game.onLoad();
      
      // ゲーム開始
      game.startGame();
      expect(game.managers.stateProvider.currentState, isA<SimpleGamePlayingState>());
      
      // 時間を進める
      game.update(1.0); // 1秒経過
      
      // 状態がまだプレイング状態であることを確認
      if (game.managers.stateProvider.currentState is SimpleGamePlayingState) {
        final playingState = game.managers.stateProvider.currentState as SimpleGamePlayingState;
        expect(playingState.timeRemaining, lessThan(10.0));
        expect(playingState.timeRemaining, greaterThan(8.0));
        
        // さらに時間を進める
        game.update(2.0); // さらに2秒経過
        
        if (game.managers.stateProvider.currentState is SimpleGamePlayingState) {
          final updatedState = game.managers.stateProvider.currentState as SimpleGamePlayingState;
          expect(updatedState.timeRemaining, lessThan(8.0));
        }
      }
      
      // ゲームオーバーまで時間を進める
      game.update(8.0); // 残り時間を超過
      
      // ゲームオーバー状態になることを確認
      expect(game.managers.stateProvider.currentState, isA<SimpleGameOverState>());
    });

    test('ゲームオーバー後のリスタート', () async {
      final game = SimpleGame();
      game.onGameResize(Vector2(400, 600));
      await game.onLoad();
      
      // 完全なゲームサイクルを実行
      game.startGame();
      expect(game.managers.stateProvider.currentState, isA<SimpleGamePlayingState>());
      
      // ゲームオーバーまで時間を進める
      game.update(11.0); // ゲーム時間を超過
      expect(game.managers.stateProvider.currentState, isA<SimpleGameOverState>());
      
      // リスタート
      game.restartGame();
      
      // 再びプレイング状態になることを確認
      expect(game.managers.stateProvider.currentState, isA<SimpleGamePlayingState>());
      
      // タイマーがリセットされて開始されていることを確認
      final restartTimer = game.timerManager.getTimer('main');
      expect(restartTimer, isNotNull);
      expect(restartTimer!.isRunning, isTrue);
    });


    test('フレームワーク統合の完全性', () async {
      final game = SimpleGame();
      game.onGameResize(Vector2(400, 600));
      await game.onLoad();
      
      // フレームワークの各システムが統合されていることを確認
      expect(game.managers.stateProvider, isNotNull);
      expect(game.timerManager, isNotNull);
      expect(game.managers.themeManager, isNotNull);
      expect(game.configuration, isNotNull);
      expect(game.managers.audioManager, isNotNull);
      expect(game.managers.dataManager, isNotNull);
      expect(game.managers.monetizationManager, isNotNull);
      expect(game.managers.analyticsManager, isNotNull);
      
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
      expect(game.managers.stateProvider.currentState, isA<GameState>());
      expect(game.children.length, greaterThan(0));
      
      // 連続的なupdate呼び出し（フレームスキップシミュレーション）
      for (int i = 0; i < 10; i++) {
        game.update(0.1);
      }
      
      // ゲームが安定していることを確認
      expect(game.managers.stateProvider.currentState, isA<GameState>());
    });
  });
}

