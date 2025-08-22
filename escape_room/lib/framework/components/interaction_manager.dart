import 'package:flutter/foundation.dart';

/// インタラクション結果
enum InteractionResult { success, failure, itemRequired, alreadyCompleted }

/// インタラクションイベント
class InteractionEvent {
  final String hotspotId;
  final String? itemId;
  final InteractionResult result;
  final String? message;

  const InteractionEvent({
    required this.hotspotId,
    this.itemId,
    required this.result,
    this.message,
  });
}

/// インタラクションマネージャー
/// ホットスポットとアイテムの相互作用を管理
class InteractionManager {
  final Function(String, String?) onInteraction;
  final List<InteractionEvent> _history = [];

  InteractionManager({required this.onInteraction});

  /// インタラクション実行
  void interact(String hotspotId, String? itemId) {
    debugPrint(
      '🤝 Interaction: $hotspotId ${itemId != null ? 'with $itemId' : '(no item)'}',
    );

    // インタラクション履歴に記録
    final event = InteractionEvent(
      hotspotId: hotspotId,
      itemId: itemId,
      result: InteractionResult.success, // 実際の結果は後で更新
    );
    _history.add(event);

    // 実際のインタラクション処理を委譲
    onInteraction(hotspotId, itemId);
  }

  /// インタラクション履歴
  List<InteractionEvent> get history => List.unmodifiable(_history);

  /// 特定のホットスポットとの最後のインタラクション
  InteractionEvent? getLastInteraction(String hotspotId) {
    try {
      return _history.lastWhere((event) => event.hotspotId == hotspotId);
    } catch (e) {
      return null;
    }
  }

  /// インタラクション回数
  int getInteractionCount(String hotspotId) {
    return _history.where((event) => event.hotspotId == hotspotId).length;
  }

  /// 履歴クリア
  void clearHistory() {
    _history.clear();
    debugPrint('🤝 Interaction history cleared');
  }

  /// アイテムを使用したインタラクション回数
  int get itemInteractionCount {
    return _history.where((event) => event.itemId != null).length;
  }

  /// 成功したインタラクション回数
  int get successfulInteractionCount {
    return _history
        .where((event) => event.result == InteractionResult.success)
        .length;
  }
}
