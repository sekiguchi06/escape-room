import 'package:flutter_test/flutter_test.dart';
import 'package:escape_room/framework/game_services/flutter_official_game_services.dart';

/// Flutter公式準拠ゲームサービスシステムの単体テスト
///
/// テスト対象:
/// 1. games_servicesパッケージの正しい使用
/// 2. Game Center/Google Play Games統合
/// 3. サインイン・サインアウト機能
/// 4. リーダーボード機能
/// 5. 実績システム
/// 6. エラーハンドリング
/// 7. Flutter公式準拠性確認

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('🎮 Flutter公式準拠ゲームサービス テスト', () {
    group('FlutterGameServicesManager基本機能テスト', () {
      test('初期化確認', () async {
        final manager = FlutterGameServicesManager();

        // 初期化前の状態確認
        expect(manager.isInitialized, isFalse);
        expect(manager.isSignedIn, isFalse);
        expect(manager.currentPlayer, isNull);

        // 注意: 実際のgames_servicesは実機でのみ動作するため、
        // 単体テストでは初期化失敗が期待される動作
        final result = await manager.initialize();

        // プラットフォーム非対応エラーまたは成功のいずれかが期待される
        expect([
          GameServiceResult.success,
          GameServiceResult.notSupported,
          GameServiceResult.failure,
        ], contains(result));
      });

      test('設定適用確認', () {
        final config = GameServicesConfiguration(
          debugMode: true,
          autoSignInEnabled: false,
          leaderboardIds: {'highScore': 'test_leaderboard'},
          achievementIds: {'firstWin': 'test_achievement'},
          signInRetryCount: 5,
          networkTimeoutSeconds: 60,
        );

        final manager = FlutterGameServicesManager(config: config);
        final debugInfo = manager.getDebugInfo();

        expect(debugInfo['debug_mode'], isTrue);
        expect(debugInfo['auto_signin_enabled'], isFalse);
        expect(
          debugInfo['leaderboard_ids'],
          equals({'highScore': 'test_leaderboard'}),
        );
        expect(
          debugInfo['achievement_ids'],
          equals({'firstWin': 'test_achievement'}),
        );
        expect(debugInfo['retry_count'], equals(5));
        expect(debugInfo['timeout_seconds'], equals(60));
      });

      test('設定更新確認', () {
        final manager = FlutterGameServicesManager();

        final newConfig = GameServicesConfiguration(
          debugMode: true,
          leaderboardIds: {'score': 'new_leaderboard'},
        );

        manager.updateConfiguration(newConfig);
        final debugInfo = manager.getDebugInfo();

        expect(debugInfo['debug_mode'], isTrue);
        expect(
          debugInfo['leaderboard_ids'],
          equals({'score': 'new_leaderboard'}),
        );
      });
    });

    group('GameServicesConfiguration設定テスト', () {
      test('デフォルト設定確認', () {
        const config = GameServicesConfiguration();

        expect(config.debugMode, isFalse);
        expect(config.autoSignInEnabled, isTrue);
        expect(config.leaderboardIds, isEmpty);
        expect(config.achievementIds, isEmpty);
        expect(config.signInRetryCount, equals(3));
        expect(config.networkTimeoutSeconds, equals(30));
      });

      test('カスタム設定確認', () {
        const config = GameServicesConfiguration(
          debugMode: true,
          autoSignInEnabled: false,
          leaderboardIds: {
            'main': 'main_leaderboard',
            'weekly': 'weekly_leaderboard',
          },
          achievementIds: {'beginner': 'beginner_achievement'},
          signInRetryCount: 10,
          networkTimeoutSeconds: 120,
        );

        expect(config.debugMode, isTrue);
        expect(config.autoSignInEnabled, isFalse);
        expect(config.leaderboardIds.length, equals(2));
        expect(config.leaderboardIds['main'], equals('main_leaderboard'));
        expect(
          config.achievementIds['beginner'],
          equals('beginner_achievement'),
        );
        expect(config.signInRetryCount, equals(10));
        expect(config.networkTimeoutSeconds, equals(120));
      });

      test('設定コピー確認', () {
        const originalConfig = GameServicesConfiguration(
          debugMode: false,
          signInRetryCount: 3,
        );

        final copiedConfig = originalConfig.copyWith(
          debugMode: true,
          leaderboardIds: {'test': 'test_id'},
        );

        expect(copiedConfig.debugMode, isTrue);
        expect(copiedConfig.signInRetryCount, equals(3)); // 変更されていない値
        expect(copiedConfig.leaderboardIds['test'], equals('test_id'));
      });
    });

    group('GamePlayer情報テスト', () {
      test('GamePlayer基本機能確認', () {
        const player = GamePlayer(
          playerId: 'test_player_123',
          displayName: 'Test Player',
          avatarUrl: 'https://example.com/avatar.png',
          isSignedIn: true,
        );

        expect(player.playerId, equals('test_player_123'));
        expect(player.displayName, equals('Test Player'));
        expect(player.avatarUrl, equals('https://example.com/avatar.png'));
        expect(player.isSignedIn, isTrue);
      });

      test('GamePlayer JSON変換確認', () {
        const player = GamePlayer(
          playerId: 'player_456',
          displayName: 'JSON Player',
          isSignedIn: true,
        );

        final json = player.toJson();

        expect(json['playerId'], equals('player_456'));
        expect(json['displayName'], equals('JSON Player'));
        expect(json['avatarUrl'], isNull);
        expect(json['isSignedIn'], isTrue);
      });

      test('未サインインプレイヤー確認', () {
        const player = GamePlayer(isSignedIn: false);

        expect(player.playerId, isNull);
        expect(player.displayName, isNull);
        expect(player.isSignedIn, isFalse);
      });
    });

    group('結果クラステスト', () {
      test('LeaderboardResult確認', () {
        const successResult = LeaderboardResult(
          result: GameServiceResult.success,
          leaderboardId: 'test_leaderboard',
        );

        expect(successResult.isSuccess, isTrue);
        expect(successResult.result, equals(GameServiceResult.success));
        expect(successResult.leaderboardId, equals('test_leaderboard'));

        const failureResult = LeaderboardResult(
          result: GameServiceResult.failure,
          message: 'Network error',
        );

        expect(failureResult.isSuccess, isFalse);
        expect(failureResult.message, equals('Network error'));
      });

      test('AchievementResult確認', () {
        const successResult = AchievementResult(
          result: GameServiceResult.success,
          achievementId: 'first_win',
        );

        expect(successResult.isSuccess, isTrue);
        expect(successResult.achievementId, equals('first_win'));

        const cancelledResult = AchievementResult(
          result: GameServiceResult.cancelled,
          message: 'User cancelled',
        );

        expect(cancelledResult.isSuccess, isFalse);
        expect(cancelledResult.result, equals(GameServiceResult.cancelled));
      });
    });

    group('サインイン・サインアウトテスト', () {
      test('未初期化時のサインイン失敗確認', () async {
        final manager = FlutterGameServicesManager();

        // 未初期化状態でのサインイン試行
        final result = await manager.signIn();

        expect(result, equals(GameServiceResult.failure));
        expect(manager.isSignedIn, isFalse);
      });

      test('サインアウト機能確認', () async {
        final manager = FlutterGameServicesManager();

        // サインアウト実行（サインイン状態に関係なく成功すべき）
        final result = await manager.signOut();

        expect(result, equals(GameServiceResult.success));
        expect(manager.isSignedIn, isFalse);
        expect(manager.currentPlayer, isNull);
      });
    });

    group('リーダーボード機能テスト', () {
      test('未サインイン時のスコア送信失敗確認', () async {
        final manager = FlutterGameServicesManager();

        final result = await manager.submitScore(
          leaderboardId: 'test_leaderboard',
          score: 1000,
        );

        expect(result.result, equals(GameServiceResult.notSignedIn));
        expect(result.isSuccess, isFalse);
      });

      test('未サインイン時のリーダーボード表示失敗確認', () async {
        final manager = FlutterGameServicesManager();

        final result = await manager.showLeaderboard(
          leaderboardId: 'test_leaderboard',
        );

        expect(result.result, equals(GameServiceResult.notSignedIn));
        expect(result.isSuccess, isFalse);
      });

      test('リーダーボード全体表示確認', () async {
        final manager = FlutterGameServicesManager();

        final result = await manager.showLeaderboard();

        expect(result.result, equals(GameServiceResult.notSignedIn));
      });
    });

    group('実績システムテスト', () {
      test('未サインイン時の実績解除失敗確認', () async {
        final manager = FlutterGameServicesManager();

        final result = await manager.unlockAchievement(
          achievementId: 'test_achievement',
        );

        expect(result.result, equals(GameServiceResult.notSignedIn));
        expect(result.isSuccess, isFalse);
      });

      test('未サインイン時の実績増分失敗確認', () async {
        final manager = FlutterGameServicesManager();

        final result = await manager.incrementAchievement(
          achievementId: 'progress_achievement',
          steps: 5,
        );

        expect(result.result, equals(GameServiceResult.notSignedIn));
        expect(result.isSuccess, isFalse);
      });

      test('未サインイン時の実績表示失敗確認', () async {
        final manager = FlutterGameServicesManager();

        final result = await manager.showAchievements();

        expect(result.result, equals(GameServiceResult.notSignedIn));
        expect(result.isSuccess, isFalse);
      });
    });

    group('ゲーム専用メソッドテスト', () {
      test('ハイスコア送信確認', () async {
        final config = GameServicesConfiguration(
          leaderboardIds: {'highScore': 'main_leaderboard'},
        );
        final manager = FlutterGameServicesManager(config: config);

        final result = await manager.submitHighScore(5000);

        // 未サインインのため失敗が期待される
        expect(result.result, equals(GameServiceResult.notSignedIn));
      });

      test('レベルクリア実績解除確認', () async {
        final config = GameServicesConfiguration(
          achievementIds: {'level_5': 'level_5_achievement'},
        );
        final manager = FlutterGameServicesManager(config: config);

        final result = await manager.unlockLevelComplete(5);

        // 未サインインのため失敗が期待される
        expect(result.result, equals(GameServiceResult.notSignedIn));
      });

      test('ゲーム開始回数増分確認', () async {
        final config = GameServicesConfiguration(
          achievementIds: {'gameStarts': 'game_starts_achievement'},
        );
        final manager = FlutterGameServicesManager(config: config);

        final result = await manager.incrementGameStartCount();

        // 未サインインのため失敗が期待される
        expect(result.result, equals(GameServiceResult.notSignedIn));
      });
    });

    group('統計・デバッグ情報テスト', () {
      test('統計情報取得確認', () {
        final manager = FlutterGameServicesManager();
        final stats = manager.getStatistics();

        expect(stats, isA<Map<String, dynamic>>());
        expect(stats['initialized'], isFalse);
        expect(stats['signedIn'], isFalse);
        expect(stats['playerId'], isNull);
        expect(stats['cachedScores'], isA<Map<String, int>>());
        expect(stats['leaderboardCount'], equals(0));
        expect(stats['achievementCount'], equals(0));
      });

      test('デバッグ情報構造確認', () {
        final config = GameServicesConfiguration(
          debugMode: true,
          leaderboardIds: {'main': 'main_board'},
        );
        final manager = FlutterGameServicesManager(config: config);

        final debugInfo = manager.getDebugInfo();

        expect(debugInfo, isA<Map<String, dynamic>>());
        expect(debugInfo['flutter_official_compliant'], isTrue);
        expect(debugInfo['package'], equals('games_services'));
        expect(debugInfo['initialized'], isFalse);
        expect(debugInfo['debug_mode'], isTrue);
        expect(debugInfo['signed_in'], isFalse);
        expect(debugInfo['leaderboard_ids'], isA<Map<String, String>>());
        expect(debugInfo['achievement_ids'], isA<Map<String, String>>());
        expect(debugInfo['score_cache'], isA<Map<String, int>>());
      });

      test('設定反映確認', () {
        final config = GameServicesConfiguration(
          leaderboardIds: {'test': 'test_id'},
          achievementIds: {'first': 'first_id'},
          signInRetryCount: 7,
        );
        final manager = FlutterGameServicesManager(config: config);

        final stats = manager.getStatistics();
        expect(stats['leaderboardCount'], equals(1));
        expect(stats['achievementCount'], equals(1));

        final debugInfo = manager.getDebugInfo();
        expect(debugInfo['retry_count'], equals(7));
      });
    });

    group('エラーハンドリングテスト', () {
      test('結果列挙値確認', () {
        const results = GameServiceResult.values;

        expect(results, contains(GameServiceResult.success));
        expect(results, contains(GameServiceResult.failure));
        expect(results, contains(GameServiceResult.cancelled));
        expect(results, contains(GameServiceResult.notSupported));
        expect(results, contains(GameServiceResult.notSignedIn));
        expect(results, contains(GameServiceResult.networkError));
        expect(results, contains(GameServiceResult.permissionDenied));
      });

      test('エラー結果処理確認', () {
        const networkErrorResult = LeaderboardResult(
          result: GameServiceResult.networkError,
          message: 'Network timeout',
        );

        expect(networkErrorResult.isSuccess, isFalse);
        expect(
          networkErrorResult.result,
          equals(GameServiceResult.networkError),
        );

        const notSupportedResult = AchievementResult(
          result: GameServiceResult.notSupported,
          message: 'Platform not supported',
        );

        expect(notSupportedResult.isSuccess, isFalse);
        expect(
          notSupportedResult.result,
          equals(GameServiceResult.notSupported),
        );
      });
    });

    group('メモリ管理テスト', () {
      test('dispose処理確認', () async {
        final manager = FlutterGameServicesManager();

        // dispose前の状態確認
        expect(() => manager.dispose(), returnsNormally);

        // dispose実行
        await manager.dispose();

        // dispose後の状態確認
        expect(manager.isSignedIn, isFalse);
        expect(manager.currentPlayer, isNull);
      });

      test('スコアキャッシュクリア確認', () async {
        final manager = FlutterGameServicesManager();

        // dispose実行
        await manager.dispose();

        final stats = manager.getStatistics();
        expect(stats['cachedScores'], isEmpty);
      });
    });

    group('後方互換性確認', () {
      test('GameServicesManagerエイリアス動作確認', () {
        // typedef GameServicesManager = FlutterGameServicesManager
        final manager = GameServicesManager();

        expect(manager, isA<FlutterGameServicesManager>());
        expect(manager.isInitialized, isFalse);
        expect(manager.isSignedIn, isFalse);

        // 基本機能も正常動作
        final debugInfo = manager.getDebugInfo();
        expect(debugInfo['flutter_official_compliant'], isTrue);
      });
    });

    group('Flutter公式準拠性確認', () {
      test('games_services準拠パターン確認', () {
        final manager = FlutterGameServicesManager();
        final debugInfo = manager.getDebugInfo();

        // Flutter公式準拠であることを明示
        expect(debugInfo['flutter_official_compliant'], isTrue);
        expect(debugInfo['package'], equals('games_services'));
      });

      test('公式推奨設定パターン確認', () {
        const config = GameServicesConfiguration(
          debugMode: true,
          autoSignInEnabled: true,
          signInRetryCount: 3,
          networkTimeoutSeconds: 30,
        );

        final manager = FlutterGameServicesManager(config: config);
        final debugInfo = manager.getDebugInfo();

        // games_servicesパッケージの推奨設定
        expect(debugInfo['auto_signin_enabled'], isTrue);
        expect(debugInfo['retry_count'], equals(3));
        expect(debugInfo['timeout_seconds'], equals(30));
      });
    });

    group('パフォーマンステスト', () {
      test('大量データ処理確認', () {
        final config = GameServicesConfiguration(
          leaderboardIds: Map.fromIterables(
            List.generate(100, (i) => 'board_$i'),
            List.generate(100, (i) => 'board_id_$i'),
          ),
          achievementIds: Map.fromIterables(
            List.generate(200, (i) => 'achievement_$i'),
            List.generate(200, (i) => 'achievement_id_$i'),
          ),
        );

        final manager = FlutterGameServicesManager(config: config);
        final stats = manager.getStatistics();

        expect(stats['leaderboardCount'], equals(100));
        expect(stats['achievementCount'], equals(200));

        // パフォーマンス確認（合理的な時間内で完了）
        final stopwatch = Stopwatch()..start();
        final debugInfo = manager.getDebugInfo();
        stopwatch.stop();

        expect(stopwatch.elapsedMilliseconds, lessThan(100)); // 100ms以内
        expect(debugInfo['leaderboard_ids'], isA<Map<String, String>>());
        expect(debugInfo['achievement_ids'], isA<Map<String, String>>());
      });
    });
  });
}
