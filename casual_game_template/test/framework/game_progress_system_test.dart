import 'package:flutter_test/flutter_test.dart';
import 'package:casual_game_template/framework/persistence/persistence_system.dart';
import 'package:casual_game_template/framework/state/game_progress_system.dart';
import 'package:casual_game_template/framework/state/game_autosave_system.dart';

void main() {
  group('GameProgress', () {
    test('should create valid GameProgress from JSON', () {
      final json = {
        'gameId': 'test_game',
        'currentLevel': 5,
        'gameData': {'score': 1000, 'items': ['key', 'potion']},
        'lastPlayed': '2024-01-01T12:00:00.000Z',
        'completionRate': 0.5,
        'achievementsUnlocked': {'first_level': true},
        'playTimeSeconds': 3600,
        'statistics': {'deaths': 3, 'puzzles_solved': 10},
      };

      final progress = GameProgress.fromJson(json);

      expect(progress.gameId, 'test_game');
      expect(progress.currentLevel, 5);
      expect(progress.gameData['score'], 1000);
      expect(progress.completionRate, 0.5);
      expect(progress.hasAchievement('first_level'), true);
      expect(progress.getStatistic('deaths'), 3);
      expect(progress.isValid, true);
    });

    test('should convert GameProgress to JSON', () {
      final progress = GameProgress(
        gameId: 'test_game',
        currentLevel: 3,
        lastPlayed: DateTime.parse('2024-01-01T12:00:00.000Z'),
        gameData: const {'score': 500},
        completionRate: 0.3,
      );

      final json = progress.toJson();

      expect(json['gameId'], 'test_game');
      expect(json['currentLevel'], 3);
      expect(json['gameData']['score'], 500);
      expect(json['completionRate'], 0.3);
    });

    test('should copy GameProgress with updated values', () {
      final original = GameProgress(
        gameId: 'test_game',
        currentLevel: 1,
        lastPlayed: DateTime.now(),
        gameData: const {'score': 100},
      );

      final updated = original.copyWith(
        currentLevel: 2,
        gameData: {'score': 200, 'lives': 3},
      );

      expect(updated.gameId, 'test_game');
      expect(updated.currentLevel, 2);
      expect(updated.gameData['score'], 200);
      expect(updated.gameData['lives'], 3);
    });

    test('should validate GameProgress correctly', () {
      final validProgress = GameProgress(
        gameId: 'valid_game',
        currentLevel: 1,
        lastPlayed: DateTime.now(),
        completionRate: 0.5,
      );

      final invalidProgress1 = GameProgress(
        gameId: '',  // 空のゲームID
        currentLevel: 1,
        lastPlayed: DateTime.now(),
      );

      final invalidProgress2 = GameProgress(
        gameId: 'test',
        currentLevel: 0,  // 無効なレベル
        lastPlayed: DateTime.now(),
      );

      expect(validProgress.isValid, true);
      expect(invalidProgress1.isValid, false);
      expect(invalidProgress2.isValid, false);
    });
  });

  group('GameProgressManager', () {
    late DataManager dataManager;
    late GameProgressManager progressManager;

    setUp(() {
      final config = DefaultPersistenceConfiguration(
        debugMode: true,
        autoSaveInterval: 1,  // テスト用に短い間隔
      );
      final provider = MemoryStorageProvider();
      dataManager = DataManager(
        provider: provider,
        configuration: config,
      );
      progressManager = GameProgressManager(dataManager);
    });

    test('should initialize without existing progress', () async {
      await progressManager.initialize();
      
      expect(progressManager.hasProgress, false);
      expect(progressManager.currentProgress, null);
    });

    test('should start new game', () async {
      await progressManager.initialize();
      await progressManager.startNewGame('test_game');

      expect(progressManager.hasProgress, true);
      expect(progressManager.currentProgress?.gameId, 'test_game');
      expect(progressManager.currentProgress?.currentLevel, 1);
    });

    test('should update progress correctly', () async {
      await progressManager.initialize();
      await progressManager.startNewGame('test_game');

      await progressManager.updateProgress(
        currentLevel: 5,
        gameDataUpdate: {'score': 1500},
        completionRate: 0.5,
        statisticsUpdate: {'enemies_defeated': 10},
      );

      final progress = progressManager.currentProgress!;
      expect(progress.currentLevel, 5);
      expect(progress.getData<int>('score'), 1500);
      expect(progress.completionRate, 0.5);
      expect(progress.getStatistic('enemies_defeated'), 10);
    });

    test('should advance level', () async {
      await progressManager.initialize();
      await progressManager.startNewGame('test_game');

      await progressManager.advanceLevel();

      expect(progressManager.currentProgress?.currentLevel, 2);
      expect(progressManager.currentProgress?.getStatistic('levels_completed'), 1);
    });

    test('should record play time', () async {
      await progressManager.initialize();
      await progressManager.startNewGame('test_game');

      await progressManager.recordPlayTime(300);

      expect(progressManager.currentProgress?.playTimeSeconds, 300);
    });

    test('should retry current level', () async {
      await progressManager.initialize();
      await progressManager.startNewGame('test_game');
      
      // レベル固有のデータを追加
      await progressManager.updateProgress(
        gameDataUpdate: {'level_1_attempts': 3, 'global_score': 1000},
      );

      await progressManager.retryCurrentLevel();

      final progress = progressManager.currentProgress!;
      expect(progress.getStatistic('level_retries'), 1);
      // レベル固有データがクリアされていることを確認（この例では該当なし）
      expect(progress.getData<int>('global_score'), 1000);
    });

    test('should reset progress', () async {
      await progressManager.initialize();
      await progressManager.startNewGame('test_game');

      await progressManager.resetProgress();

      expect(progressManager.hasProgress, false);
      expect(progressManager.currentProgress, null);
    });

    test('should persist and load progress', () async {
      await progressManager.initialize();
      await progressManager.startNewGame('test_game');
      await progressManager.updateProgress(
        currentLevel: 3,
        gameDataUpdate: {'score': 2000},
      );

      // 新しいマネージャーインスタンスで読み込み
      final newProgressManager = GameProgressManager(dataManager);
      await newProgressManager.initialize();

      expect(newProgressManager.hasProgress, true);
      expect(newProgressManager.currentProgress?.gameId, 'test_game');
      expect(newProgressManager.currentProgress?.currentLevel, 3);
      expect(newProgressManager.currentProgress?.getData<int>('score'), 2000);
    });
  });

  group('GameProgressUtils', () {
    test('should calculate completion rate correctly', () {
      expect(GameProgressUtils.calculateCompletionRate(5, 10), 0.5);
      expect(GameProgressUtils.calculateCompletionRate(10, 10), 1.0);
      expect(GameProgressUtils.calculateCompletionRate(0, 10), 0.0);
      expect(GameProgressUtils.calculateCompletionRate(15, 10), 1.0); // clamp
      expect(GameProgressUtils.calculateCompletionRate(5, 0), 0.0); // division by zero
    });

    test('should format play time correctly', () {
      expect(GameProgressUtils.formatPlayTime(30), '0:30');
      expect(GameProgressUtils.formatPlayTime(90), '1:30');
      expect(GameProgressUtils.formatPlayTime(3661), '1:01:01');
      expect(GameProgressUtils.formatPlayTime(7200), '2:00:00');
    });

    test('should generate level names correctly', () {
      expect(GameProgressUtils.getLevelName(1), 'Level 1');
      expect(GameProgressUtils.getLevelName(5, prefix: 'Stage'), 'Stage 5');
    });

    test('should validate progress correctly', () {
      final validProgress = GameProgress(
        gameId: 'valid',
        currentLevel: 1,
        lastPlayed: DateTime.now(),
        completionRate: 0.5,
        playTimeSeconds: 100,
      );

      final invalidProgress = GameProgress(
        gameId: 'invalid',
        currentLevel: -1, // 無効
        lastPlayed: DateTime.now(),
        completionRate: 1.5, // 無効（範囲外）
        playTimeSeconds: -10, // 無効
      );

      expect(GameProgressUtils.validateProgress(validProgress), true);
      expect(GameProgressUtils.validateProgress(invalidProgress), false);
    });
  });

  group('GameManualSaveSystem', () {
    late DataManager dataManager;
    late GameProgressManager progressManager;
    late GameManualSaveSystem manualSaveSystem;

    setUp(() {
      final config = DefaultPersistenceConfiguration(
        debugMode: true,
        autoSaveInterval: 1,
      );
      final provider = MemoryStorageProvider();
      dataManager = DataManager(
        provider: provider,
        configuration: config,
      );
      progressManager = GameProgressManager(dataManager);
      manualSaveSystem = GameManualSaveSystem(
        dataManager: dataManager,
        progressManager: progressManager,
      );
    });

    test('should initialize and manage manual save system', () async {
      expect(manualSaveSystem.isEnabled, true);

      manualSaveSystem.initialize();
      expect(manualSaveSystem.isEnabled, true);

      manualSaveSystem.disable();
      expect(manualSaveSystem.isEnabled, false);

      manualSaveSystem.enable();
      expect(manualSaveSystem.isEnabled, true);
    });

    test('should perform manual save successfully', () async {
      await progressManager.initialize();
      await progressManager.startNewGame('test_game');

      // 手動保存を実行
      final saveResult = await manualSaveSystem.manualSave();

      expect(saveResult, true);
      expect(progressManager.hasProgress, true);
      expect(manualSaveSystem.lastSaveTime, isNotNull);
    });

    test('should save on item found', () async {
      await progressManager.initialize();
      await progressManager.startNewGame('test_game');

      // アイテム発見時の保存
      final saveResult = await manualSaveSystem.saveOnItemFound('key_item');

      expect(saveResult, true);
      expect(manualSaveSystem.lastSaveTime, isNotNull);
    });

    test('should save on puzzle solved', () async {
      await progressManager.initialize();
      await progressManager.startNewGame('test_game');

      // パズル解決時の保存
      final saveResult = await manualSaveSystem.saveOnPuzzleSolved('puzzle_01');

      expect(saveResult, true);
      expect(manualSaveSystem.lastSaveTime, isNotNull);
    });

    test('should save on level complete', () async {
      await progressManager.initialize();
      await progressManager.startNewGame('test_game');

      // レベルクリア時の保存
      final saveResult = await manualSaveSystem.saveOnLevelComplete(1);

      expect(saveResult, true);
      expect(manualSaveSystem.lastSaveTime, isNotNull);
    });

    test('should save on checkpoint reached', () async {
      await progressManager.initialize();
      await progressManager.startNewGame('test_game');

      // チェックポイント到達時の保存
      final saveResult = await manualSaveSystem.saveOnCheckpoint('checkpoint_01');

      expect(saveResult, true);
      expect(manualSaveSystem.lastSaveTime, isNotNull);
    });

    test('should handle disabled state correctly', () async {
      await progressManager.initialize();
      await progressManager.startNewGame('test_game');

      // システムを無効化
      manualSaveSystem.disable();

      // 無効化状態では保存が失敗する
      final saveResult = await manualSaveSystem.manualSave();
      expect(saveResult, false);
    });
  });

  group('ProgressAwareDataManager', () {
    late ProgressAwareDataManager manager;

    setUp(() {
      final config = DefaultPersistenceConfiguration(
        debugMode: true,
        autoSaveInterval: 1,
      );
      final provider = MemoryStorageProvider();
      final dataManager = DataManager(
        provider: provider,
        configuration: config,
      );
      manager = ProgressAwareDataManager(dataManager: dataManager);
    });

    test('should initialize all components', () async {
      await manager.initialize();

      expect(manager.progressManager.hasProgress, false);
      expect(manager.saveSystem.isEnabled, true);
    });

    test('should start new game with manual save', () async {
      await manager.initialize();
      await manager.startNewGame('integration_test');

      expect(manager.progressManager.hasProgress, true);
      expect(manager.progressManager.currentProgress?.gameId, 'integration_test');
    });

    test('should continue existing game', () async {
      await manager.initialize();
      await manager.startNewGame('continue_test');

      final progress = await manager.continueGame();
      expect(progress?.gameId, 'continue_test');
    });

    test('should retry level with manual save', () async {
      await manager.initialize();
      await manager.startNewGame('retry_test');

      await manager.retryLevel();
      expect(manager.progressManager.currentProgress?.getStatistic('level_retries'), 1);
    });

    test('should reset progress with manual save', () async {
      await manager.initialize();
      await manager.startNewGame('reset_test');

      await manager.resetProgress();
      expect(manager.progressManager.hasProgress, false);
    });

    test('should handle item found event', () async {
      await manager.initialize();
      await manager.startNewGame('item_test');

      final result = await manager.onItemFound('test_item');
      expect(result, true);
      expect(manager.progressManager.currentProgress?.getStatistic('items_collected'), 1);
    });

    test('should handle puzzle solved event', () async {
      await manager.initialize();
      await manager.startNewGame('puzzle_test');

      final result = await manager.onPuzzleSolved('test_puzzle');
      expect(result, true);
      expect(manager.progressManager.currentProgress?.getStatistic('puzzles_completed'), 1);
    });

    test('should handle level complete event', () async {
      await manager.initialize();
      await manager.startNewGame('level_test');

      final result = await manager.onLevelComplete(1);
      expect(result, true);
      expect(manager.progressManager.currentProgress?.currentLevel, 2);
    });

    test('should handle checkpoint reached event', () async {
      await manager.initialize();
      await manager.startNewGame('checkpoint_test');

      final result = await manager.onCheckpointReached('checkpoint_1');
      expect(result, true);
      expect(manager.progressManager.currentProgress?.getStatistic('checkpoints_reached'), 1);
    });

    test('should perform manual save', () async {
      await manager.initialize();
      await manager.startNewGame('manual_save_test');

      final result = await manager.manualSave();
      expect(result, true);
    });

    test('should handle game exit properly', () async {
      await manager.initialize();
      await manager.startNewGame('exit_test');

      final result = await manager.onGameExit();
      expect(result, true);
      expect(manager.progressManager.hasProgress, true);
    });

    tearDown(() async {
      await manager.dispose();
    });
  });
}