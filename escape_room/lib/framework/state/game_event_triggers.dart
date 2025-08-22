import 'package:flutter/foundation.dart';
import 'game_autosave_system.dart';

/// ゲームイベント時の保存トリガー管理
class GameEventTriggers {
  final ProgressAwareDataManager _dataManager;
  bool _isEnabled = true;

  GameEventTriggers(this._dataManager);

  /// システムの有効・無効切り替え
  bool get isEnabled => _isEnabled;

  void enable() {
    _isEnabled = true;
    if (kDebugMode) {
      debugPrint('Game event triggers enabled');
    }
  }

  void disable() {
    _isEnabled = false;
    if (kDebugMode) {
      debugPrint('Game event triggers disabled');
    }
  }

  /// アイテム発見イベント
  Future<bool> onItemDiscovered({
    required String itemId,
    required String itemName,
    String? itemCategory,
    Map<String, dynamic>? additionalData,
  }) async {
    if (!_isEnabled) return false;

    try {
      // アイテム情報を進行度に記録
      final itemData = {
        'item_id': itemId,
        'item_name': itemName,
        'item_category': itemCategory ?? 'misc',
        'discovered_at': DateTime.now().toIso8601String(),
        ...?additionalData,
      };

      // 進行度更新と保存
      await _dataManager.progressManager.updateProgress(
        gameDataUpdate: {
          'items': {itemId: itemData},
        },
        statisticsUpdate: {
          'total_items_found': 1,
          'items_${itemCategory ?? 'misc'}': 1,
        },
      );

      final saveResult = await _dataManager.saveSystem.saveOnItemFound(itemId);

      if (kDebugMode) {
        debugPrint(
          '🎒 Item discovered: $itemName ($itemId) - Saved: $saveResult',
        );
      }

      return saveResult;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Item discovery save failed: $e');
      }
      return false;
    }
  }

  /// ギミック/パズル解決イベント
  Future<bool> onPuzzleSolved({
    required String puzzleId,
    required String puzzleName,
    String? difficulty,
    int? attempts,
    int? solutionTimeSeconds,
    Map<String, dynamic>? additionalData,
  }) async {
    if (!_isEnabled) return false;

    try {
      // パズル情報を進行度に記録
      final puzzleData = {
        'puzzle_id': puzzleId,
        'puzzle_name': puzzleName,
        'difficulty': difficulty ?? 'normal',
        'attempts': attempts ?? 1,
        'solution_time_seconds': solutionTimeSeconds ?? 0,
        'solved_at': DateTime.now().toIso8601String(),
        ...?additionalData,
      };

      // 進行度更新と保存
      await _dataManager.progressManager.updateProgress(
        gameDataUpdate: {
          'puzzles': {puzzleId: puzzleData},
        },
        statisticsUpdate: {
          'total_puzzles_solved': 1,
          'puzzle_attempts': attempts ?? 1,
          'total_solution_time': solutionTimeSeconds ?? 0,
          'puzzles_${difficulty ?? 'normal'}': 1,
        },
      );

      final saveResult = await _dataManager.saveSystem.saveOnPuzzleSolved(
        puzzleId,
      );

      if (kDebugMode) {
        debugPrint(
          '🧩 Puzzle solved: $puzzleName ($puzzleId) - Saved: $saveResult',
        );
      }

      return saveResult;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Puzzle solve save failed: $e');
      }
      return false;
    }
  }

  /// レベル/ステージクリアイベント
  Future<bool> onLevelCompleted({
    required int level,
    String? levelName,
    int? score,
    int? timeSeconds,
    double? completionRate,
    Map<String, dynamic>? additionalData,
  }) async {
    if (!_isEnabled) return false;

    try {
      // レベル情報を進行度に記録
      final levelData = {
        'level': level,
        'level_name': levelName ?? 'Level $level',
        'score': score ?? 0,
        'time_seconds': timeSeconds ?? 0,
        'completion_rate': completionRate ?? 1.0,
        'completed_at': DateTime.now().toIso8601String(),
        ...?additionalData,
      };

      // 進行度更新（レベルアップ）と保存
      await _dataManager.progressManager.updateProgress(
        currentLevel: level + 1,
        gameDataUpdate: {
          'levels': {level.toString(): levelData},
        },
        completionRate: completionRate,
        statisticsUpdate: {
          'total_levels_completed': 1,
          'total_score': score ?? 0,
          'total_play_time': timeSeconds ?? 0,
        },
      );

      final saveResult = await _dataManager.saveSystem.saveOnLevelComplete(
        level,
      );

      if (kDebugMode) {
        debugPrint('🎯 Level completed: $level - Saved: $saveResult');
      }

      return saveResult;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Level complete save failed: $e');
      }
      return false;
    }
  }

  /// チェックポイント到達イベント
  Future<bool> onCheckpointReached({
    required String checkpointId,
    String? checkpointName,
    String? areaName,
    Map<String, dynamic>? additionalData,
  }) async {
    if (!_isEnabled) return false;

    try {
      // チェックポイント情報を進行度に記録
      final checkpointData = {
        'checkpoint_id': checkpointId,
        'checkpoint_name': checkpointName ?? checkpointId,
        'area_name': areaName,
        'reached_at': DateTime.now().toIso8601String(),
        ...?additionalData,
      };

      // 進行度更新と保存
      await _dataManager.progressManager.updateProgress(
        gameDataUpdate: {
          'checkpoints': {checkpointId: checkpointData},
          'last_checkpoint': checkpointId,
        },
        statisticsUpdate: {'total_checkpoints_reached': 1},
      );

      final saveResult = await _dataManager.saveSystem.saveOnCheckpoint(
        checkpointId,
      );

      if (kDebugMode) {
        debugPrint(
          '📍 Checkpoint reached: $checkpointName ($checkpointId) - Saved: $saveResult',
        );
      }

      return saveResult;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Checkpoint save failed: $e');
      }
      return false;
    }
  }

  /// ボス撃破イベント
  Future<bool> onBossDefeated({
    required String bossId,
    required String bossName,
    int? attempts,
    int? battleTimeSeconds,
    Map<String, dynamic>? additionalData,
  }) async {
    if (!_isEnabled) return false;

    try {
      // ボス情報を進行度に記録
      final bossData = {
        'boss_id': bossId,
        'boss_name': bossName,
        'attempts': attempts ?? 1,
        'battle_time_seconds': battleTimeSeconds ?? 0,
        'defeated_at': DateTime.now().toIso8601String(),
        ...?additionalData,
      };

      // 進行度更新と保存
      await _dataManager.progressManager.updateProgress(
        gameDataUpdate: {
          'bosses': {bossId: bossData},
        },
        statisticsUpdate: {
          'total_bosses_defeated': 1,
          'boss_attempts': attempts ?? 1,
          'total_boss_battle_time': battleTimeSeconds ?? 0,
        },
      );

      final saveResult = await _dataManager.saveSystem.manualSave();

      if (kDebugMode) {
        debugPrint(
          '🔥 Boss defeated: $bossName ($bossId) - Saved: $saveResult',
        );
      }

      return saveResult;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Boss defeat save failed: $e');
      }
      return false;
    }
  }

  /// アチーブメント解除イベント
  Future<bool> onAchievementUnlocked({
    required String achievementId,
    required String achievementName,
    String? category,
    Map<String, dynamic>? additionalData,
  }) async {
    if (!_isEnabled) return false;

    try {
      // アチーブメント情報を進行度に記録
      final achievementData = {
        'achievement_id': achievementId,
        'achievement_name': achievementName,
        'category': category ?? 'general',
        'unlocked_at': DateTime.now().toIso8601String(),
        ...?additionalData,
      };

      // 進行度更新と保存
      await _dataManager.progressManager.updateProgress(
        gameDataUpdate: {
          'achievements': {achievementId: achievementData},
        },
        newAchievements: {achievementId: true},
        statisticsUpdate: {
          'total_achievements_unlocked': 1,
          'achievements_${category ?? 'general'}': 1,
        },
      );

      final saveResult = await _dataManager.saveSystem.manualSave();

      if (kDebugMode) {
        debugPrint(
          '🏆 Achievement unlocked: $achievementName ($achievementId) - Saved: $saveResult',
        );
      }

      return saveResult;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Achievement unlock save failed: $e');
      }
      return false;
    }
  }

  /// ゲーム脱出成功イベント
  Future<bool> onGameEscapeSuccess({
    int? totalTimeSeconds,
    int? totalScore,
    double? completionRate,
    Map<String, dynamic>? finalStats,
  }) async {
    if (!_isEnabled) return false;

    try {
      // 脱出成功情報を進行度に記録
      final escapeData = {
        'escaped': true,
        'escape_time_seconds': totalTimeSeconds ?? 0,
        'final_score': totalScore ?? 0,
        'completion_rate': completionRate ?? 1.0,
        'escaped_at': DateTime.now().toIso8601String(),
        'final_stats': finalStats ?? {},
      };

      // 進行度更新と保存
      await _dataManager.progressManager.updateProgress(
        gameDataUpdate: escapeData,
        completionRate: 1.0,
        statisticsUpdate: {
          'games_completed': 1,
          'total_escape_time': totalTimeSeconds ?? 0,
          'best_escape_time': totalTimeSeconds ?? 0,
        },
      );

      final saveResult = await _dataManager.saveSystem.manualSave();

      if (kDebugMode) {
        debugPrint('🎉 Game escape success - Saved: $saveResult');
      }

      return saveResult;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Game escape save failed: $e');
      }
      return false;
    }
  }

  /// カスタムイベント（汎用）
  Future<bool> onCustomEvent({
    required String eventType,
    required String eventId,
    Map<String, dynamic>? eventData,
    Map<String, int>? statisticsUpdate,
  }) async {
    if (!_isEnabled) return false;

    try {
      // カスタムイベント情報を進行度に記録
      final customEventData = {
        'event_type': eventType,
        'event_id': eventId,
        'event_data': eventData ?? {},
        'triggered_at': DateTime.now().toIso8601String(),
      };

      // 進行度更新と保存
      await _dataManager.progressManager.updateProgress(
        gameDataUpdate: {
          'custom_events': {eventId: customEventData},
        },
        statisticsUpdate: statisticsUpdate,
      );

      final saveResult = await _dataManager.saveSystem.manualSave();

      if (kDebugMode) {
        debugPrint(
          '🎮 Custom event: $eventType ($eventId) - Saved: $saveResult',
        );
      }

      return saveResult;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Custom event save failed: $e');
      }
      return false;
    }
  }

  /// デバッグ情報
  Map<String, dynamic> getDebugInfo() {
    return {
      'enabled': _isEnabled,
      'data_manager_info': _dataManager.getDebugInfo(),
    };
  }
}
