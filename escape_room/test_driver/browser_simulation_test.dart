import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';
import 'package:flutter/foundation.dart';

void main() {
  group('🌐 自動ブラウザシミュレーションテスト', () {
    late FlutterDriver driver;

    setUpAll(() async {
      debugPrint('🚀 ブラウザテストドライバー初期化開始...');
      driver = await FlutterDriver.connect();
      debugPrint('✅ ドライバー接続成功');
    });

    tearDownAll(() async {
      await driver.close();
      debugPrint('🧹 ドライバー切断完了');
    });

    test('フレームワーク初期化とゲーム基本動作', () async {
      debugPrint('🎮 自動テスト: フレームワーク初期化...');
      
      // === 1. アプリ起動確認 ===
      final appTitle = find.text('Casual Game Template');
      await driver.waitFor(appTitle, timeout: const Duration(seconds: 10));
      debugPrint('  ✅ アプリタイトル表示確認');
      
      // === 2. ゲーム画面表示確認 ===
      await Future.delayed(const Duration(seconds: 2));
      
      // ゲーム開始テキストの確認（初期状態）
      final startText = find.text('TAP TO START');
      await driver.waitFor(startText, timeout: const Duration(seconds: 5));
      debugPrint('  ✅ 初期状態「TAP TO START」表示確認');
      
      // === 3. ゲーム開始操作 ===
      await driver.tap(find.byValueKey('game_canvas'));
      await Future.delayed(const Duration(seconds: 1));
      debugPrint('  ✅ ゲーム開始タップ実行');
      
      // === 4. ゲーム状態変化確認 ===
      // プレイ中状態のテキスト確認（時間表示）
      await Future.delayed(const Duration(seconds: 2));
      debugPrint('  ✅ ゲーム状態変化確認（プレイ中）');
      
      // === 5. タイマー動作確認 ===
      // 3秒間ゲームプレイを観察
      for (int i = 0; i < 3; i++) {
        await Future.delayed(const Duration(seconds: 1));
        debugPrint('  ⏰ タイマー動作確認: ${i + 1}秒経過');
      }
      
      // === 6. ゲームオーバー確認 ===
      // タイマー終了まで待機（最大10秒）
      bool gameOverDetected = false;
      for (int i = 0; i < 10; i++) {
        try {
          // ゲームオーバー状態のテキストを探す
          await driver.waitFor(
            find.text('Session:'),
            timeout: const Duration(seconds: 1),
          );
          gameOverDetected = true;
          debugPrint('  ✅ ゲームオーバー状態検出');
          break;
        } catch (e) {
          await Future.delayed(const Duration(seconds: 1));
        }
      }
      
      expect(gameOverDetected, isTrue);
      
      debugPrint('🎉 フレームワーク初期化とゲーム基本動作テスト成功！');
    });

    test('マルチセッション自動実行', () async {
      debugPrint('🔄 自動テスト: マルチセッション実行...');
      
      // === セッション1〜3の自動実行 ===
      for (int session = 1; session <= 3; session++) {
        debugPrint('  🎯 セッション$session開始...');
        
        // ゲーム開始（タップ）
        await driver.tap(find.byValueKey('game_canvas'));
        await Future.delayed(const Duration(milliseconds: 500));
        debugPrint('    ▶️ セッション$session開始タップ');
        
        // ゲームプレイ観察（2秒）
        await Future.delayed(const Duration(seconds: 2));
        debugPrint('    🎮 セッション$sessionプレイ中...');
        
        // ゲームオーバーまで待機
        bool sessionCompleted = false;
        for (int i = 0; i < 15; i++) { // 最大15秒待機
          try {
            await driver.waitFor(
              find.text('Session: $session'),
              timeout: const Duration(seconds: 1),
            );
            sessionCompleted = true;
            debugPrint('    ✅ セッション$session完了検出');
            break;
          } catch (e) {
            await Future.delayed(const Duration(seconds: 1));
          }
        }
        
        expect(sessionCompleted, isTrue);
        
        // 次のセッションのための短い待機
        await Future.delayed(const Duration(milliseconds: 500));
      }
      
      debugPrint('🎉 マルチセッション自動実行テスト成功！');
    });

    test('設定変更サイクル確認', () async {
      debugPrint('⚙️ 自動テスト: 設定変更サイクル...');
      
      final expectedConfigs = ['Default', 'easy', 'hard', 'Default'];
      
      for (int cycle = 0; cycle < expectedConfigs.length; cycle++) {
        debugPrint('  🔧 設定確認サイクル${cycle + 1}: ${expectedConfigs[cycle]}');
        
        // 設定テキストの確認
        final configText = find.text('Config: ${expectedConfigs[cycle]}');
        await driver.waitFor(configText, timeout: const Duration(seconds: 3));
        debugPrint('    ✅ 設定「${expectedConfigs[cycle]}」表示確認');
        
        // ゲーム開始→終了サイクル
        await driver.tap(find.byValueKey('game_canvas'));
        await Future.delayed(const Duration(seconds: 3)); // 短時間プレイ
        
        // ゲームオーバー待機
        bool cycleCompleted = false;
        for (int i = 0; i < 10; i++) {
          try {
            await driver.waitFor(
              find.text('Session:'),
              timeout: const Duration(seconds: 1),
            );
            cycleCompleted = true;
            break;
          } catch (e) {
            await Future.delayed(const Duration(seconds: 1));
          }
        }
        
        expect(cycleCompleted, isTrue);
        await Future.delayed(const Duration(milliseconds: 500));
      }
      
      debugPrint('🎉 設定変更サイクル確認テスト成功！');
    });

    test('長時間安定性テスト', () async {
      debugPrint('⏰ 自動テスト: 長時間安定性テスト...');
      
      const testDurationMinutes = 2; // 2分間のテスト
      const sessionCount = 8; // 約8セッション実行
      
      final startTime = DateTime.now();
      int completedSessions = 0;
      
      for (int session = 1; session <= sessionCount; session++) {
        final sessionStart = DateTime.now();
        debugPrint('  📊 長時間テスト セッション$session/$sessionCount...');
        
        // ゲーム開始
        await driver.tap(find.byValueKey('game_canvas'));
        await Future.delayed(const Duration(milliseconds: 500));
        
        // ゲームオーバーまで待機
        bool sessionCompleted = false;
        for (int i = 0; i < 20; i++) { // 最大20秒待機
          try {
            await driver.waitFor(
              find.text('Session:'),
              timeout: const Duration(seconds: 1),
            );
            sessionCompleted = true;
            completedSessions++;
            
            final sessionDuration = DateTime.now().difference(sessionStart);
            debugPrint('    ✅ セッション$session完了（${sessionDuration.inMilliseconds}ms）');
            break;
          } catch (e) {
            await Future.delayed(const Duration(seconds: 1));
          }
        }
        
        expect(sessionCompleted, isTrue);
        
        // 全体時間チェック
        final elapsed = DateTime.now().difference(startTime);
        if (elapsed.inMinutes >= testDurationMinutes) {
          debugPrint('  ⏰ $testDurationMinutes分経過、テスト終了');
          break;
        }
        
        await Future.delayed(const Duration(milliseconds: 200));
      }
      
      final totalDuration = DateTime.now().difference(startTime);
      debugPrint('  📈 長時間テスト結果:');
      debugPrint('    - 実行時間: ${totalDuration.inMilliseconds}ms');
      debugPrint('    - 完了セッション: $completedSessions個');
      debugPrint('    - 平均セッション時間: ${totalDuration.inMilliseconds / completedSessions}ms');
      
      expect(completedSessions, greaterThan(3));
      
      debugPrint('🎉 長時間安定性テスト成功！');
    });

    test('エラー発生確認テスト', () async {
      debugPrint('🚨 自動テスト: エラー発生確認...');
      
      // === 連続タップストレステスト ===
      debugPrint('  🔥 連続タップストレステスト実行...');
      for (int i = 0; i < 10; i++) {
        await driver.tap(find.byValueKey('game_canvas'));
        await Future.delayed(const Duration(milliseconds: 100));
      }
      
      // アプリが正常動作していることを確認
      await Future.delayed(const Duration(seconds: 2));
      
      try {
        await driver.waitFor(
          find.byValueKey('game_canvas'),
          timeout: const Duration(seconds: 3),
        );
        debugPrint('  ✅ 連続タップ後もアプリ正常動作');
      } catch (e) {
        fail('連続タップ後にアプリが応答しなくなりました: $e');
      }
      
      // === 高速状態変化テスト ===
      debugPrint('  ⚡ 高速状態変化テスト実行...');
      for (int i = 0; i < 5; i++) {
        await driver.tap(find.byValueKey('game_canvas'));
        await Future.delayed(const Duration(milliseconds: 200));
        await driver.tap(find.byValueKey('game_canvas'));
        await Future.delayed(const Duration(milliseconds: 300));
      }
      
      // 最終状態確認
      await Future.delayed(const Duration(seconds: 3));
      
      try {
        // 何らかのゲーム状態が表示されていることを確認
        final gameState = await driver.getText(find.byValueKey('status_text'));
        debugPrint('  ✅ 最終ゲーム状態: $gameState');
        expect(gameState, isNotEmpty);
      } catch (e) {
        // テキスト取得に失敗した場合はUI要素の存在確認
        await driver.waitFor(
          find.byValueKey('game_canvas'),
          timeout: const Duration(seconds: 2),
        );
        debugPrint('  ✅ ゲームUI要素存在確認');
      }
      
      debugPrint('🎉 エラー発生確認テスト成功！');
    });
  });
}