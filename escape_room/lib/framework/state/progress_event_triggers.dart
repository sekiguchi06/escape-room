import 'package:flutter/foundation.dart';
import 'game_event_triggers_base.dart';

/// 進行度関連のイベントトリガー
mixin ProgressEventTriggers on GameEventTriggersBase {
  /// レベル/ステージクリアイベント
  Future<bool> onLevelCompleted({
    required int level,
    String? levelName,
    int? score,
    int? timeSeconds,
    double? completionRate,
    Map<String, dynamic>? additionalData,
  }) async {
    if (!isEnabled) return false;

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
      await dataManager.progressManager.updateProgress(
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

      final saveResult = await dataManager.saveSystem.saveOnLevelComplete(
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
    if (!isEnabled) return false;

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
      await dataManager.progressManager.updateProgress(
        gameDataUpdate: {
          'checkpoints': {checkpointId: checkpointData},
          'last_checkpoint': checkpointId,
        },
        statisticsUpdate: {'total_checkpoints_reached': 1},
      );

      final saveResult = await dataManager.saveSystem.saveOnCheckpoint(
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
}