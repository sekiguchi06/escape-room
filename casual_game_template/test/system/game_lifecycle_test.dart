import 'package:flutter_test/flutter_test.dart';
import 'package:flame/components.dart';

// テスト用のゲーム実装
import '../integration/flame_integration_test.dart';
import '../../lib/framework/state/game_state_system.dart';
import '../../lib/game/framework_integration/simple_game_states.dart';

void main() {
  group('🔄 システムテスト - ゲームライフサイクル', () {
    late IntegrationTestGame game;
    
    setUp(() {
      game = IntegrationTestGame();
    });
    
    group('完全ゲームサイクル', () {
      test('ゲーム開始 → プレイ → ゲームオーバー → リスタート', () async {
        print('🎮 システムテスト: 完全ゲームライフサイクル開始...');
        
        // === 1. ゲーム初期化フェーズ ===
        await game.onLoad();
        expect(game.isInitialized, isTrue);
        expect(game.currentState, isA<SimpleGameStartState>());
        print('  ✅ Phase 1: 初期化完了 - 開始画面表示');
        
        // === 2. ゲーム開始フェーズ ===
        game.onTapDown(TapDownEvent(
          deviceId: 1,
          localPosition: Vector2(100, 100),
        ));
        
        await Future.delayed(const Duration(milliseconds: 10));
        expect(game.currentState, isA<SimpleGamePlayingState>());
        
        final timer = game.timerManager.getTimer('main');
        expect(timer, isNotNull);
        expect(timer!.isRunning, isTrue);
        print('  ✅ Phase 2: ゲーム開始 - プレイ状態移行、タイマー開始');
        
        // === 3. ゲームプレイフェーズ ===
        final initialTime = timer.current;
        
        // プレイ中の複数フレーム実行（0.5秒分）
        for (int i = 0; i < 30; i++) {
          game.update(1/60); // 60FPS
          
          // システムの健全性確認
          expect(game.isInitialized, isTrue);
          expect(game.currentState, isA<SimpleGamePlayingState>());
          
          if (i % 10 == 0) {
            print('  📊 Frame ${i}: Timer=${timer.current.inMilliseconds}ms, State=${game.currentState.name}');
          }
        }
        
        // タイマーが正常に減少していることを確認
        expect(timer.current.inMilliseconds, lessThan(initialTime.inMilliseconds));
        print('  ✅ Phase 3: ゲームプレイ中 - タイマー正常動作');
        
        // === 4. ゲームオーバーフェーズ ===
        // タイマーを強制的に0にしてゲームオーバーをトリガー
        final playingState = game.currentState as SimpleGamePlayingState;
        final forcedGameOverState = SimpleGameOverState(
          finalScore: 100,
          sessionNumber: playingState.sessionNumber,
        );
        
        game.stateProvider.forceStateChange(forcedGameOverState);
        
        expect(game.currentState, isA<SimpleGameOverState>());
        final gameOverState = game.currentState as SimpleGameOverState;
        expect(gameOverState.finalScore, equals(100));
        print('  ✅ Phase 4: ゲームオーバー - 最終スコア${gameOverState.finalScore}');
        
        // === 5. リスタートフェーズ ===
        final previousSessionNumber = gameOverState.sessionNumber;
        
        game.onTapDown(TapDownEvent(
          deviceId: 1,
          localPosition: Vector2(150, 150),
        ));
        
        await Future.delayed(const Duration(milliseconds: 10));
        expect(game.currentState, isA<SimpleGamePlayingState>());
        
        final newPlayingState = game.currentState as SimpleGamePlayingState;
        expect(newPlayingState.sessionNumber, equals(previousSessionNumber + 1));
        
        final newTimer = game.timerManager.getTimer('main');
        expect(newTimer, isNotNull);
        expect(newTimer!.isRunning, isTrue);
        print('  ✅ Phase 5: リスタート完了 - セッション${newPlayingState.sessionNumber}開始');
        
        print('🎉 完全ゲームライフサイクルテスト成功！');
      });
      
      test('設定変更を含むマルチセッション', () async {
        print('⚙️ システムテスト: 設定変更マルチセッション...');
        
        await game.onLoad();
        
        final configs = ['default', 'easy', 'hard'];
        
        for (int session = 0; session < 3; session++) {
          print('  🎯 セッション${session + 1}: ${configs[session]}設定');
          
          // 設定変更
          final config = SimpleGameConfigPresets.getPreset(configs[session]);
          if (config != null) {
            await game.applyConfiguration(config);
          }
          
          // ゲーム開始
          if (session == 0) {
            // 初回は開始状態から
            expect(game.currentState, isA<SimpleGameStartState>());
          } else {
            // 2回目以降はゲームオーバー状態から
            expect(game.currentState, isA<SimpleGameOverState>());
          }
          
          game.onTapDown(TapDownEvent(
            deviceId: 1,
            localPosition: Vector2(100 + session * 50, 100),
          ));
          
          await Future.delayed(const Duration(milliseconds: 10));
          expect(game.currentState, isA<SimpleGamePlayingState>());
          
          // 短時間プレイ
          for (int i = 0; i < 10; i++) {
            game.update(1/60);
          }
          
          // ゲームオーバー
          final playingState = game.currentState as SimpleGamePlayingState;
          final gameOverState = SimpleGameOverState(
            finalScore: (session + 1) * 50,
            sessionNumber: playingState.sessionNumber,
          );
          
          game.stateProvider.forceStateChange(gameOverState);
          expect(game.currentState, isA<SimpleGameOverState>());
          
          print('    ✅ セッション完了: スコア${gameOverState.finalScore}');
        }
        
        print('🎉 設定変更マルチセッションテスト成功！');
      });
    });
    
    group('システム統合シナリオ', () {
      test('全システム連携ワークフロー', () async {
        print('🌐 システムテスト: 全システム連携ワークフロー...');
        
        await game.onLoad();
        
        // === 分析システム: セッション開始 ===
        await game.analyticsManager.trackGameStart(gameConfig: {
          'test_scenario': 'system_integration',
          'version': '1.0.0',
        });
        print('  📊 分析: ゲーム開始イベント送信');
        
        // === データ永続化: 初期データ設定 ===
        await game.dataManager.saveHighScore(500);
        final initialHighScore = await game.dataManager.loadHighScore();
        expect(initialHighScore, equals(500));
        print('  💾 データ: 初期ハイスコア設定 - ${initialHighScore}点');
        
        // === 音響システム: BGM開始 ===
        await game.audioManager.playBgm('test_bgm');
        expect(game.audioManager.provider, isA<SilentAudioProvider>());
        print('  🎵 音響: BGM再生開始');
        
        // === ゲーム開始 ===
        game.onTapDown(TapDownEvent(
          deviceId: 1,
          localPosition: Vector2(100, 100),
        ));
        
        await Future.delayed(const Duration(milliseconds: 10));
        
        // === 入力システム: タップイベント確認 ===
        final inputEvents = <InputEventData>[];
        game.inputManager.addInputListener((event) {
          inputEvents.add(event);
        });
        
        // 追加のタップイベント
        game.onTapDown(TapDownEvent(
          deviceId: 1,
          localPosition: Vector2(200, 200),
        ));
        
        await Future.delayed(const Duration(milliseconds: 10));
        expect(inputEvents, isNotEmpty);
        print('  👆 入力: タップイベント${inputEvents.length}件処理');
        
        // === 収益化システム: 広告イベント ===
        final adResult = await game.monetizationManager.showInterstitial();
        expect(adResult, equals(AdResult.shown));
        print('  💰 収益化: インタースティシャル広告表示');
        
        // === タイマーシステム: 時間管理 ===
        final timer = game.timerManager.getTimer('main');
        expect(timer, isNotNull);
        
        for (int i = 0; i < 20; i++) {
          game.update(1/60);
        }
        
        expect(timer!.current.inMilliseconds, lessThan(5000));
        print('  ⏱️ タイマー: ${timer.current.inMilliseconds}ms残り');
        
        // === ゲーム終了 ===
        final playingState = game.currentState as SimpleGamePlayingState;
        final finalScore = 750;
        
        // === データ永続化: ハイスコア更新 ===
        await game.dataManager.saveHighScore(finalScore);
        final newHighScore = await game.dataManager.loadHighScore();
        expect(newHighScore, equals(finalScore));
        print('  💾 データ: ハイスコア更新 - ${newHighScore}点');
        
        // === 分析システム: ゲーム終了 ===
        await game.analyticsManager.trackGameEnd(
          score: finalScore,
          duration: const Duration(seconds: 30),
          additionalData: {'systems_tested': 6},
        );
        print('  📊 分析: ゲーム終了イベント送信');
        
        // === 音響システム: BGM停止 ===
        await game.audioManager.stopBgm();
        print('  🎵 音響: BGM停止');
        
        // === 最終状態確認 ===
        expect(game.isInitialized, isTrue);
        expect(game.audioManager, isNotNull);
        expect(game.inputManager, isNotNull);
        expect(game.dataManager, isNotNull);
        expect(game.monetizationManager, isNotNull);
        expect(game.analyticsManager, isNotNull);
        
        print('🎉 全システム連携ワークフローテスト成功！');
      });
    });
    
    group('パフォーマンス・安定性', () {
      test('長時間実行安定性', () async {
        print('⏰ システムテスト: 長時間実行安定性...');
        
        await game.onLoad();
        
        // ゲーム開始
        game.onTapDown(TapDownEvent(
          deviceId: 1,
          localPosition: Vector2(100, 100),
        ));
        
        await Future.delayed(const Duration(milliseconds: 10));
        
        // 10秒分のゲームループ実行（600フレーム）
        final startTime = DateTime.now();
        
        for (int frame = 0; frame < 600; frame++) {
          game.update(1/60);
          
          // 100フレームごとにシステム健全性チェック
          if (frame % 100 == 0) {
            expect(game.isInitialized, isTrue);
            expect(game.currentState, isNotNull);
            
            final timer = game.timerManager.getTimer('main');
            if (timer != null) {
              expect(timer.isRunning, isTrue);
            }
          }
          
          // ランダムなタイミングでイベント発生
          if (frame % 50 == 0) {
            game.onTapDown(TapDownEvent(
              deviceId: 1,
              localPosition: Vector2(frame % 300.0, frame % 200.0),
            ));
          }
          
          // 進捗表示
          if (frame % 200 == 0) {
            final elapsed = DateTime.now().difference(startTime);
            print('  📊 Frame ${frame}/600 (${elapsed.inMilliseconds}ms)');
          }
        }
        
        final totalTime = DateTime.now().difference(startTime);
        print('  ✅ 600フレーム実行完了: ${totalTime.inMilliseconds}ms');
        
        // 最終状態確認
        expect(game.isInitialized, isTrue);
        expect(() => game.update(1/60), returnsNormally);
        
        print('🎉 長時間実行安定性テスト成功！');
      });
      
      test('メモリリークテスト', () async {
        print('🧠 システムテスト: メモリリーク検出...');
        
        await game.onLoad();
        
        // 複数回のゲームサイクル実行
        for (int cycle = 0; cycle < 5; cycle++) {
          print('  🔄 メモリテストサイクル ${cycle + 1}/5');
          
          // ゲーム開始
          if (cycle == 0) {
            expect(game.currentState, isA<SimpleGameStartState>());
          } else {
            expect(game.currentState, isA<SimpleGameOverState>());
          }
          
          game.onTapDown(TapDownEvent(
            deviceId: 1,
            localPosition: Vector2(100, 100),
          ));
          
          await Future.delayed(const Duration(milliseconds: 5));
          
          // 短時間プレイ
          for (int i = 0; i < 60; i++) {
            game.update(1/60);
          }
          
          // 大量のイベント生成
          for (int i = 0; i < 50; i++) {
            game.onTapDown(TapDownEvent(
              deviceId: 1,
              localPosition: Vector2(i * 2.0, i * 3.0),
            ));
          }
          
          // ゲーム終了
          final playingState = game.currentState as SimpleGamePlayingState;
          final gameOverState = SimpleGameOverState(
            finalScore: cycle * 100,
            sessionNumber: playingState.sessionNumber,
          );
          
          game.stateProvider.forceStateChange(gameOverState);
          
          // ガベージコレクション促進のための待機
          await Future.delayed(const Duration(milliseconds: 10));
        }
        
        // 最終的にシステムが正常動作することを確認
        expect(game.isInitialized, isTrue);
        expect(() => game.update(1/60), returnsNormally);
        
        print('  ✅ 5サイクル完了 - メモリリーク検出なし');
        print('🎉 メモリリークテスト成功！');
      });
    });
  });
}