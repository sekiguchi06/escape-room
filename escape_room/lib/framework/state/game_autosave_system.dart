import 'dart:async';
import 'package:flutter/foundation.dart';
import '../persistence/persistence_system.dart';
import 'game_progress_system.dart';

/// ゲーム手動保存システム（旧自動保存システムから変更）
class GameManualSaveSystem {
  final DataManager _dataManager;
  final GameProgressManager _progressManager;
  bool _isEnabled = true;
  DateTime? _lastSaveTime;

  GameManualSaveSystem({
    required DataManager dataManager,
    required GameProgressManager progressManager,
  }) : _dataManager = dataManager,
       _progressManager = progressManager;

  /// 手動保存システムを初期化
  void initialize() {
    if (!_isEnabled) return;

    if (kDebugMode) {
      debugPrint('Manual save system initialized');
    }
  }

  /// 手動保存システムを無効化
  void disable() {
    _isEnabled = false;

    if (kDebugMode) {
      debugPrint('Manual save system disabled');
    }
  }

  /// 手動保存システムを有効化
  void enable() {
    _isEnabled = true;

    if (kDebugMode) {
      debugPrint('Manual save system enabled');
    }
  }

  /// 手動保存実行
  Future<bool> manualSave() async {
    if (!_isEnabled) return false;

    try {
      await _performSave();
      _lastSaveTime = DateTime.now();

      if (kDebugMode) {
        debugPrint('Manual save executed successfully');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Manual save failed: $e');
      }
      return false;
    }
  }

  /// アイテム発見時の保存
  Future<bool> saveOnItemFound(String itemId) async {
    if (!_isEnabled) return false;

    try {
      await _performSave();
      _lastSaveTime = DateTime.now();

      if (kDebugMode) {
        debugPrint('Progress saved on item found: $itemId');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Save on item found failed: $e');
      }
      return false;
    }
  }

  /// ギミッククリア時の保存
  Future<bool> saveOnPuzzleSolved(String puzzleId) async {
    if (!_isEnabled) return false;

    try {
      await _performSave();
      _lastSaveTime = DateTime.now();

      if (kDebugMode) {
        debugPrint('Progress saved on puzzle solved: $puzzleId');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Save on puzzle solved failed: $e');
      }
      return false;
    }
  }

  /// レベルクリア時の保存
  Future<bool> saveOnLevelComplete(int level) async {
    if (!_isEnabled) return false;

    try {
      await _performSave();
      _lastSaveTime = DateTime.now();

      if (kDebugMode) {
        debugPrint('Progress saved on level complete: $level');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Save on level complete failed: $e');
      }
      return false;
    }
  }

  /// チェックポイント到達時の保存
  Future<bool> saveOnCheckpoint(String checkpointId) async {
    if (!_isEnabled) return false;

    try {
      await _performSave();
      _lastSaveTime = DateTime.now();

      if (kDebugMode) {
        debugPrint('Progress saved on checkpoint: $checkpointId');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Save on checkpoint failed: $e');
      }
      return false;
    }
  }

  /// ゲーム終了時の最終保存
  Future<bool> saveOnExit() async {
    try {
      await _performSave();
      _lastSaveTime = DateTime.now();

      if (kDebugMode) {
        debugPrint('Exit save completed');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Exit save failed: $e');
      }
      return false;
    }
  }

  /// 実際の保存処理
  Future<void> _performSave() async {
    // 進行度の保存
    if (_progressManager.currentProgress != null) {
      await _progressManager.saveProgress();
    }

    // DataManagerの保留データを強制保存
    await _dataManager.performAutoSave();
  }

  /// システム状態の取得
  bool get isEnabled => _isEnabled;
  DateTime? get lastSaveTime => _lastSaveTime;

  /// デバッグ情報
  Map<String, dynamic> getDebugInfo() {
    return {
      'enabled': _isEnabled,
      'lastSaveTime': _lastSaveTime?.toIso8601String(),
      'systemType': 'manual_save',
    };
  }

  /// リソース解放
  void dispose() {
    _isEnabled = false;
    if (kDebugMode) {
      debugPrint('Manual save system disposed');
    }
  }
}

/// ゲーム進行度付き手動保存マネージャー（旧自動保存から変更）
/// 既存のDataManagerを拡張し、進行度管理機能を統合
class ProgressAwareDataManager {
  final DataManager _dataManager;
  final GameProgressManager _progressManager;
  final GameManualSaveSystem _saveSystem;

  static ProgressAwareDataManager? _defaultInstance;

  ProgressAwareDataManager({required DataManager dataManager})
    : _dataManager = dataManager,
      _progressManager = GameProgressManager(dataManager),
      _saveSystem = GameManualSaveSystem(
        dataManager: dataManager,
        progressManager: GameProgressManager(dataManager),
      );

  /// デフォルトインスタンスを取得（シングルトン）
  static ProgressAwareDataManager defaultInstance() {
    _defaultInstance ??= ProgressAwareDataManager(
      dataManager: DataManager.defaultInstance(),
    );
    return _defaultInstance!;
  }

  /// 初期化
  Future<void> initialize() async {
    await _progressManager.initialize();
    _saveSystem.initialize();

    if (kDebugMode) {
      debugPrint('ProgressAwareDataManager initialized (manual save mode)');
    }
  }

  /// 各コンポーネントへのアクセス
  DataManager get dataManager => _dataManager;
  GameProgressManager get progressManager => _progressManager;
  GameManualSaveSystem get saveSystem => _saveSystem;

  /// 進行度付きゲーム開始
  Future<void> startNewGame(String gameId) async {
    await _progressManager.startNewGame(gameId);
    await _saveSystem.manualSave();

    if (kDebugMode) {
      debugPrint('New game started with manual save: $gameId');
    }
  }

  /// 進行度付きゲーム継続
  Future<GameProgress?> continueGame() async {
    return _progressManager.currentProgress;
  }

  /// レベルリトライ
  Future<void> retryLevel() async {
    await _progressManager.retryCurrentLevel();
    await _saveSystem.manualSave();

    if (kDebugMode) {
      debugPrint('Level retry with manual save');
    }
  }

  /// 進行度リセット
  Future<void> resetProgress() async {
    await _progressManager.resetProgress();
    await _saveSystem.manualSave();

    if (kDebugMode) {
      debugPrint('Progress reset with manual save');
    }
  }

  /// アイテム発見時の処理
  Future<bool> onItemFound(String itemId) async {
    // 進行度にアイテム情報を追加
    await _progressManager.updateProgress(
      gameDataUpdate: {'items_found': itemId},
      statisticsUpdate: {'items_collected': 1},
    );

    // 保存実行
    final saveResult = await _saveSystem.saveOnItemFound(itemId);

    if (kDebugMode) {
      debugPrint('Item found processed: $itemId, saved: $saveResult');
    }

    return saveResult;
  }

  /// ギミッククリア時の処理
  Future<bool> onPuzzleSolved(String puzzleId) async {
    // 進行度にパズル情報を追加
    await _progressManager.updateProgress(
      gameDataUpdate: {'puzzles_solved': puzzleId},
      statisticsUpdate: {'puzzles_completed': 1},
    );

    // 保存実行
    final saveResult = await _saveSystem.saveOnPuzzleSolved(puzzleId);

    if (kDebugMode) {
      debugPrint('Puzzle solved processed: $puzzleId, saved: $saveResult');
    }

    return saveResult;
  }

  /// レベルクリア時の処理
  Future<bool> onLevelComplete(int level) async {
    // 進行度を更新してレベルアップ
    await _progressManager.advanceLevel();

    // 保存実行
    final saveResult = await _saveSystem.saveOnLevelComplete(level);

    if (kDebugMode) {
      debugPrint('Level complete processed: $level, saved: $saveResult');
    }

    return saveResult;
  }

  /// チェックポイント到達時の処理
  Future<bool> onCheckpointReached(String checkpointId) async {
    // 進行度にチェックポイント情報を追加
    await _progressManager.updateProgress(
      gameDataUpdate: {'last_checkpoint': checkpointId},
      statisticsUpdate: {'checkpoints_reached': 1},
    );

    // 保存実行
    final saveResult = await _saveSystem.saveOnCheckpoint(checkpointId);

    if (kDebugMode) {
      debugPrint(
        'Checkpoint reached processed: $checkpointId, saved: $saveResult',
      );
    }

    return saveResult;
  }

  /// 手動保存の実行
  Future<bool> manualSave() async {
    return await _saveSystem.manualSave();
  }

  /// ゲーム終了時の処理
  Future<bool> onGameExit() async {
    final saveResult = await _saveSystem.saveOnExit();

    if (kDebugMode) {
      debugPrint('Game exit save completed: $saveResult');
    }

    return saveResult;
  }

  /// デバッグ情報
  Map<String, dynamic> getDebugInfo() {
    return {
      'dataManager': _dataManager.getDebugInfo(),
      'progressManager': _progressManager.getDebugInfo(),
      'saveSystem': _saveSystem.getDebugInfo(),
    };
  }

  /// リソース解放
  Future<void> dispose() async {
    _saveSystem.dispose();
    await _dataManager.dispose();
  }
}
