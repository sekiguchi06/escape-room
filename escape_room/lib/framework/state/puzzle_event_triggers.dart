import 'package:flutter/foundation.dart';
import 'game_event_triggers_base.dart';

/// パズル関連のイベントトリガー
mixin PuzzleEventTriggers on GameEventTriggersBase {
  /// ギミック/パズル解決イベント
  Future<bool> onPuzzleSolved({
    required String puzzleId,
    required String puzzleName,
    String? difficulty,
    int? attempts,
    int? solutionTimeSeconds,
    Map<String, dynamic>? additionalData,
  }) async {
    if (!isEnabled) return false;

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
      await dataManager.progressManager.updateProgress(
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

      final saveResult = await dataManager.saveSystem.saveOnPuzzleSolved(
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
}