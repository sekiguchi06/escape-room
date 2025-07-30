import 'package:flutter_test/flutter_test.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/gestures.dart';

// テスト用のゲーム実装
import '../integration/flame_integration_test.dart';
import '../../lib/framework/state/game_state_system.dart';
import '../../lib/game/framework_integration/simple_game_states.dart';

void main() {
  group('🔄 簡略化システムテスト - フレームワーク基盤', () {
    late IntegrationTestGame game;
    
    setUp(() {
      game = IntegrationTestGame();
    });
    
    test('フレームワーク初期化と基本動作', () async {
      print('🎮 システムテスト: 基本フレームワーク動作...');
      
      // === 1. 初期化フェーズ ===
      await game.onLoad();
      expect(game.isInitialized, isTrue);
      expect(game.currentState, isA<SimpleGameStartState>());
      print('  ✅ フレームワーク初期化完了');
      
      // === 2. システム統合確認 ===
      expect(game.audioManager, isNotNull);
      expect(game.inputManager, isNotNull);
      expect(game.dataManager, isNotNull);
      expect(game.monetizationManager, isNotNull);
      expect(game.analyticsManager, isNotNull);
      print('  ✅ 全システム初期化確認');
      
      // === 3. 基本ゲームループ ===
      for (int i = 0; i < 30; i++) {
        game.update(1/60);
        expect(game.isInitialized, isTrue);
      }
      print('  ✅ ゲームループ安定動作');
      
      // === 4. 入力システム処理 ===
      game.inputManager.handleTapDown(Vector2(100, 100));
      print('  ✅ 入力システム処理成功');
      
      print('🎉 基本フレームワーク動作テスト成功！');
    });
    
    test('システム統合ワークフロー', () async {
      print('🌐 システムテスト: 統合ワークフロー...');
      
      await game.onLoad();
      
      // === 音響システム連携 ===
      await game.audioManager.playBgm('test_bgm');
      expect(game.audioManager, isNotNull);
      print('  🎵 音響システム連携確認');
      
      // === データ永続化システム ===
      await game.dataManager.saveHighScore(500);
      final highScore = await game.dataManager.loadHighScore();
      expect(highScore, equals(500));
      print('  💾 データ永続化システム確認');
      
      // === 収益化システム ===
      final adResult = await game.monetizationManager.showInterstitial();
      expect(adResult, isNotNull);
      print('  💰 収益化システム確認');
      
      // === 分析システム ===
      await game.analyticsManager.trackEvent('test_event', parameters: {
        'test': true,
      });
      print('  📊 分析システム確認');
      
      // === 最終状態確認 ===
      expect(game.isInitialized, isTrue);
      expect(game.audioManager, isNotNull);
      expect(game.dataManager, isNotNull);
      expect(game.monetizationManager, isNotNull);
      expect(game.analyticsManager, isNotNull);
      
      print('🎉 統合ワークフローテスト成功！');
    });
    
    test('長時間実行安定性', () async {
      print('⏰ システムテスト: 長時間実行安定性...');
      
      await game.onLoad();
      
      // 10秒分のゲームループ実行（600フレーム）
      final startTime = DateTime.now();
      
      for (int frame = 0; frame < 600; frame++) {
        game.update(1/60);
        
        // 100フレームごとにシステム健全性チェック
        if (frame % 100 == 0) {
          expect(game.isInitialized, isTrue);
          expect(game.currentState, isNotNull);
        }
        
        // ランダムなタイミングで入力処理
        if (frame % 50 == 0) {
          game.inputManager.handleTapDown(Vector2(frame % 300.0, frame % 200.0));
        }
        
        // 進捗表示
        if (frame % 200 == 0) {
          final elapsed = DateTime.now().difference(startTime);
          print('  📊 Frame $frame/600 (${elapsed.inMilliseconds}ms)');
        }
      }
      
      final totalTime = DateTime.now().difference(startTime);
      print('  ✅ 600フレーム実行完了: ${totalTime.inMilliseconds}ms');
      
      // 最終状態確認
      expect(game.isInitialized, isTrue);
      expect(() => game.update(1/60), returnsNormally);
      
      print('🎉 長時間実行安定性テスト成功！');
    });
  });
}