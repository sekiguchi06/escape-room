import 'package:flutter/foundation.dart';
import 'game_event_triggers_base.dart';

/// アイテム関連のイベントトリガー
mixin ItemEventTriggers on GameEventTriggersBase {
  /// アイテム発見イベント
  Future<bool> onItemDiscovered({
    required String itemId,
    required String itemName,
    String? itemCategory,
    Map<String, dynamic>? additionalData,
  }) async {
    if (!isEnabled) return false;

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
      await dataManager.progressManager.updateProgress(
        gameDataUpdate: {
          'items': {itemId: itemData},
        },
        statisticsUpdate: {
          'total_items_found': 1,
          'items_${itemCategory ?? 'misc'}': 1,
        },
      );

      final saveResult = await dataManager.saveSystem.saveOnItemFound(itemId);

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
}