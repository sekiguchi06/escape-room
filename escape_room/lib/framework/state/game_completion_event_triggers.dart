import 'package:flutter/foundation.dart';
import 'game_event_triggers_base.dart';

/// ゲーム完了関連のイベントトリガー
mixin GameCompletionEventTriggers on GameEventTriggersBase {
  /// ボス撃破イベント
  Future<bool> onBossDefeated({
    required String bossId,
    required String bossName,
    int? attempts,
    int? battleTimeSeconds,
    Map<String, dynamic>? additionalData,
  }) async {
    if (!isEnabled) return false;

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
      await dataManager.progressManager.updateProgress(
        gameDataUpdate: {
          'bosses': {bossId: bossData},
        },
        statisticsUpdate: {
          'total_bosses_defeated': 1,
          'boss_attempts': attempts ?? 1,
          'total_boss_battle_time': battleTimeSeconds ?? 0,
        },
      );

      final saveResult = await dataManager.saveSystem.manualSave();

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
    if (!isEnabled) return false;

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
      await dataManager.progressManager.updateProgress(
        gameDataUpdate: {
          'achievements': {achievementId: achievementData},
        },
        newAchievements: {achievementId: true},
        statisticsUpdate: {
          'total_achievements_unlocked': 1,
          'achievements_${category ?? 'general'}': 1,
        },
      );

      final saveResult = await dataManager.saveSystem.manualSave();

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
    if (!isEnabled) return false;

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
      await dataManager.progressManager.updateProgress(
        gameDataUpdate: escapeData,
        completionRate: 1.0,
        statisticsUpdate: {
          'games_completed': 1,
          'total_escape_time': totalTimeSeconds ?? 0,
          'best_escape_time': totalTimeSeconds ?? 0,
        },
      );

      final saveResult = await dataManager.saveSystem.manualSave();

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
}