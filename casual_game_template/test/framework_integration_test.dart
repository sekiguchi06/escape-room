import 'package:flutter_test/flutter_test.dart';
import 'package:casual_game_template/game/framework_integration/simple_game_framework.dart';
import 'package:casual_game_template/game/framework_integration/simple_game_configuration.dart';
import 'package:casual_game_template/game/framework_integration/simple_game_states.dart';
import 'package:casual_game_template/framework/state/game_state_system.dart';

void main() {
  group('フレームワーク統合テスト', () {
    test('基本初期化テスト', () async {
      // デフォルト設定でゲームを作成
      final game = SimpleGameFrameworkFactory.createDefault();
      
      // 初期化
      await game.onLoad();
      
      // 初期化状態の確認
      expect(game.isInitialized, isTrue, reason: 'ゲーム初期化に失敗');
      
      // 初期状態の確認
      expect(game.currentState, isA<SimpleGameStartState>(), reason: '初期状態が不正');
      
      // フレームワークコンポーネントの確認
      expect(game.timerManager.hasTimer('main'), isTrue, reason: 'メインタイマーが作成されていない');
      
      print('✅ 基本初期化テスト完了');
    });
    
    test('設定システムテスト', () async {
      final game = SimpleGameFrameworkFactory.createDefault();
      await game.onLoad();
      
      // 設定の取得と確認
      final config = game.config;
      expect(config.gameDuration.inSeconds, equals(5), reason: 'デフォルト設定が不正');
      
      // 設定の動的変更
      final newConfig = config.copyWith(
        gameDuration: const Duration(seconds: 10),
      );
      
      await game.applyConfiguration(newConfig);
      
      expect(game.config.gameDuration.inSeconds, equals(10), reason: '設定変更が適用されていない');
      
      // タイマー設定も連動して変更されているか確認
      final mainTimer = game.timerManager.getTimer('main');
      expect(mainTimer?.duration.inSeconds, equals(10), reason: 'タイマー設定が連動していない');
      
      print('✅ 設定システムテスト完了');
    });
    
    test('状態管理システムテスト', () async {
      final game = SimpleGameFrameworkFactory.createDefault();
      await game.onLoad();
      
      final stateProvider = game.stateProvider as SimpleGameStateProvider;
      
      // 初期状態の確認
      expect(stateProvider.isInState<SimpleGameStartState>(), isTrue, reason: '初期状態の検出が不正');
      
      // ゲーム開始状態への遷移テスト
      final success = stateProvider.startGame(5.0);
      expect(success, isTrue, reason: 'playing状態への遷移が失敗');
      expect(stateProvider.isInState<SimpleGamePlayingState>(), isTrue, reason: 'playing状態になっていない');
      
      // playing状態でのタイマー更新テスト
      stateProvider.updateTimer(3.0);
      final playingState = stateProvider.getStateAs<SimpleGamePlayingState>();
      expect(playingState?.timeRemaining, equals(3.0), reason: 'playing状態でのタイマー更新が失敗');
      
      // ゲームオーバー状態への遷移テスト
      stateProvider.updateTimer(0.0);
      expect(stateProvider.isInState<SimpleGameOverState>(), isTrue, reason: 'gameOver状態への遷移が失敗');
      
      // リスタートテスト
      final restartSuccess = stateProvider.restart(5.0);
      expect(restartSuccess, isTrue, reason: 'リスタート機能が失敗');
      expect(stateProvider.isInState<SimpleGamePlayingState>(), isTrue, reason: 'リスタート後の状態が不正');
      
      print('✅ 状態管理システムテスト完了');
    });
    
    test('タイマーシステムテスト', () async {
      final game = SimpleGameFrameworkFactory.createDefault();
      await game.onLoad();
      
      final timerManager = game.timerManager;
      
      // タイマーの基本操作テスト
      expect(timerManager.hasTimer('main'), isTrue, reason: 'メインタイマーが存在しない');
      
      // タイマー開始テスト
      timerManager.startTimer('main');
      expect(timerManager.isTimerRunning('main'), isTrue, reason: 'タイマー開始が失敗');
      
      // タイマー一時停止テスト
      timerManager.pauseTimer('main');
      final mainTimer = timerManager.getTimer('main');
      expect(mainTimer?.isPaused, isTrue, reason: 'タイマー一時停止が失敗');
      
      // タイマー再開テスト
      timerManager.resumeTimer('main');
      expect(mainTimer?.isPaused, isFalse, reason: 'タイマー再開が失敗');
      expect(mainTimer?.isRunning, isTrue, reason: 'タイマーが実行されていない');
      
      // タイマーリセットテスト
      timerManager.resetTimer('main');
      expect(mainTimer?.isRunning, isFalse, reason: 'タイマーリセットが失敗');
      
      print('✅ タイマーシステムテスト完了');
    });
    
    test('UIシステムテスト', () async {
      final game = SimpleGameFrameworkFactory.createDefault();
      await game.onLoad();
      
      // テーママネージャーのテスト
      final themeManager = game.themeManager;
      expect(themeManager.getAvailableThemes().isNotEmpty, isTrue, reason: 'テーマが読み込まれていない');
      
      // テーマ変更テスト
      final originalTheme = themeManager.currentThemeId;
      themeManager.setTheme('dark');
      expect(themeManager.currentThemeId, equals('dark'), reason: 'テーマ変更が失敗');
      
      // 元のテーマに戻す
      themeManager.setTheme(originalTheme);
      
      print('✅ UIシステムテスト完了');
    });
    
    test('プリセットシステムテスト', () async {
      final game = SimpleGameFrameworkFactory.createDefault();
      await game.onLoad();
      
      // 利用可能なプリセットの確認
      final presets = SimpleGameConfigPresets.getAvailablePresets();
      expect(presets.contains('easy'), isTrue, reason: 'easyプリセットが存在しない');
      expect(presets.contains('hard'), isTrue, reason: 'hardプリセットが存在しない');
      
      // easyプリセットの適用テスト
      game.applyPreset('easy');
      expect(game.config.gameDuration.inSeconds, equals(10), reason: 'easyプリセットの適用が失敗');
      
      // hardプリセットの適用テスト
      game.applyPreset('hard');
      expect(game.config.gameDuration.inSeconds, equals(3), reason: 'hardプリセットの適用が失敗');
      
      print('✅ プリセットシステムテスト完了');
    });
    
    test('A/Bテストシステムテスト', () async {
      final game = SimpleGameFrameworkFactory.createDefault();
      await game.onLoad();
      
      // A/Bテスト設定の適用テスト
      game.applyABTestConfig('easy');
      expect(game.config.gameDuration.inSeconds, equals(10), reason: 'A/Bテスト設定の適用が失敗');
      
      print('✅ A/Bテストシステムテスト完了');
    });
    
    test('ファクトリーパターンテスト', () async {
      // デフォルトゲーム
      final defaultGame = SimpleGameFrameworkFactory.createDefault();
      await defaultGame.onLoad();
      expect(defaultGame.config.gameDuration.inSeconds, equals(5));
      
      // イージーモード
      final easyGame = SimpleGameFrameworkFactory.createEasyMode();
      await easyGame.onLoad();
      expect(easyGame.config.gameDuration.inSeconds, equals(10));
      
      // ハードモード
      final hardGame = SimpleGameFrameworkFactory.createHardMode();
      await hardGame.onLoad();
      expect(hardGame.config.gameDuration.inSeconds, equals(3));
      
      // デバッグモード
      final debugGame = SimpleGameFrameworkFactory.createDebugMode();
      await debugGame.onLoad();
      expect(debugGame.debugMode, isTrue);
      
      print('✅ ファクトリーパターンテスト完了');
    });
    
    test('ビルダーパターンテスト', () async {
      final game = SimpleGameFrameworkBuilder()
          .withPreset('easy')
          .withTheme('game')
          .withDebugMode(true)
          .build();
      
      await game.onLoad();
      
      expect(game.config.gameDuration.inSeconds, equals(10), reason: 'プリセット設定が適用されていない');
      expect(game.debugMode, isTrue, reason: 'デバッグモードが有効になっていない');
      expect(game.themeManager.currentThemeId, equals('game'), reason: 'テーマが設定されていない');
      
      print('✅ ビルダーパターンテスト完了');
    });
    
    test('統合シナリオテスト', () async {
      // ゲーム作成
      final game = SimpleGameFrameworkFactory.createDefault();
      await game.onLoad();
      
      final stateProvider = game.stateProvider as SimpleGameStateProvider;
      
      // 完全なゲームサイクルをテスト
      // 1. 初期状態確認
      expect(stateProvider.isInState<SimpleGameStartState>(), isTrue);
      
      // 2. ゲーム開始
      final startSuccess = stateProvider.startGame(5.0);
      expect(startSuccess, isTrue);
      expect(stateProvider.isInState<SimpleGamePlayingState>(), isTrue);
      
      // 3. タイマー更新
      stateProvider.updateTimer(3.0);
      final playingState = stateProvider.getStateAs<SimpleGamePlayingState>();
      expect(playingState?.timeRemaining, equals(3.0));
      
      // 4. ゲームオーバー
      stateProvider.updateTimer(0.0);
      expect(stateProvider.isInState<SimpleGameOverState>(), isTrue);
      
      // 5. リスタート
      final restartSuccess = stateProvider.restart(5.0);
      expect(restartSuccess, isTrue);
      expect(stateProvider.isInState<SimpleGamePlayingState>(), isTrue);
      
      // 6. 設定変更
      game.applyPreset('hard');
      expect(game.config.gameDuration.inSeconds, equals(3));
      
      // 7. セッション統計確認
      final stats = stateProvider.getStatistics();
      expect(stats.sessionCount, greaterThan(0));
      expect(stats.totalStateChanges, greaterThan(0));
      
      print('✅ 統合シナリオテスト完了');
    });
  });
}