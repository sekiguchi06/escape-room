/// 分析イベントの重要度
enum EventPriority {
  critical, // 課金、エラー等
  high, // レベルクリア、ゲームオーバー等
  medium, // ゲーム開始、アイテム使用等
  low, // UI操作、画面表示等
}

/// 分析イベントデータ
class AnalyticsEvent {
  final String name;
  final Map<String, dynamic> parameters;
  final EventPriority priority;
  final DateTime timestamp;
  final String? userId;
  final String? sessionId;

  const AnalyticsEvent({
    required this.name,
    this.parameters = const {},
    this.priority = EventPriority.medium,
    required this.timestamp,
    this.userId,
    this.sessionId,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'parameters': parameters,
      'priority': priority.name,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'user_id': userId,
      'session_id': sessionId,
    };
  }

  @override
  String toString() {
    return 'AnalyticsEvent(name: $name, priority: $priority, params: ${parameters.length})';
  }
}
