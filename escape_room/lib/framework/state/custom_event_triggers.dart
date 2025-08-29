import 'package:flutter/foundation.dart';
import 'game_event_triggers_base.dart';

/// カスタムイベント関連のイベントトリガー
mixin CustomEventTriggers on GameEventTriggersBase {
  /// カスタムイベント（汎用）
  Future<bool> onCustomEvent({
    required String eventType,
    required String eventId,
    Map<String, dynamic>? eventData,
    Map<String, int>? statisticsUpdate,
  }) async {
    if (!isEnabled) return false;

    try {
      // カスタムイベント情報を進行度に記録
      final customEventData = {
        'event_type': eventType,
        'event_id': eventId,
        'event_data': eventData ?? {},
        'triggered_at': DateTime.now().toIso8601String(),
      };

      // 進行度更新と保存
      await dataManager.progressManager.updateProgress(
        gameDataUpdate: {
          'custom_events': {eventId: customEventData},
        },
        statisticsUpdate: statisticsUpdate,
      );

      final saveResult = await dataManager.saveSystem.manualSave();

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
}