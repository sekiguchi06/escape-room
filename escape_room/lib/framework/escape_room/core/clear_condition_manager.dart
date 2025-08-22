import 'package:flutter/foundation.dart';

/// クリア条件タイプ
enum ClearConditionType {
  collectItems, // アイテム収集
  solvePuzzles, // パズル解決
  useItemCombination, // アイテム組み合わせ
  interactObjects, // オブジェクト操作
}

/// 個別クリア条件
class ClearCondition {
  final String id;
  final ClearConditionType type;
  final String description;
  final bool isCompleted;
  final Map<String, dynamic> data;

  const ClearCondition({
    required this.id,
    required this.type,
    required this.description,
    this.isCompleted = false,
    this.data = const {},
  });

  ClearCondition copyWith({
    String? id,
    ClearConditionType? type,
    String? description,
    bool? isCompleted,
    Map<String, dynamic>? data,
  }) {
    return ClearCondition(
      id: id ?? this.id,
      type: type ?? this.type,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      data: data ?? this.data,
    );
  }
}

/// クリア条件管理システム
/// 🎯 目的: ゲームクリア条件の定義・追跡・判定
class ClearConditionManager extends ChangeNotifier {
  final Map<String, ClearCondition> _conditions = {};
  final DateTime _gameStartTime = DateTime.now();
  int _completedCount = 0;
  bool _isGameCleared = false;

  /// 現在のクリア条件リスト（読み取り専用）
  List<ClearCondition> get conditions => _conditions.values.toList();

  /// 完了済み条件数
  int get completedCount => _completedCount;

  /// 総条件数
  int get totalCount => _conditions.length;

  /// ゲームクリア済み判定
  bool get isGameCleared => _isGameCleared;

  /// クリア率（0.0-1.0）
  double get clearProgress =>
      totalCount > 0 ? _completedCount / totalCount : 0.0;

  /// ゲーム経過時間（秒）
  int get elapsedTimeSeconds =>
      DateTime.now().difference(_gameStartTime).inSeconds;

  /// クリア条件を追加
  void addCondition(ClearCondition condition) {
    _conditions[condition.id] = condition;
    debugPrint(
      '🎯 Clear condition added: ${condition.id} - ${condition.description}',
    );
    notifyListeners();
  }

  /// 複数のクリア条件を一括追加
  void addConditions(List<ClearCondition> conditions) {
    for (final condition in conditions) {
      _conditions[condition.id] = condition;
    }
    debugPrint('🎯 ${conditions.length} clear conditions added');
    notifyListeners();
  }

  /// クリア条件を完了状態にする
  bool completeCondition(String conditionId) {
    final condition = _conditions[conditionId];
    if (condition == null) {
      debugPrint('❌ Clear condition not found: $conditionId');
      return false;
    }

    if (condition.isCompleted) {
      debugPrint('⚠️ Clear condition already completed: $conditionId');
      return false;
    }

    _conditions[conditionId] = condition.copyWith(isCompleted: true);
    _completedCount++;

    debugPrint(
      '✅ Clear condition completed: $conditionId ($completedCount/$totalCount)',
    );

    // 全条件完了チェック
    _checkGameClear();

    notifyListeners();
    return true;
  }

  /// アイテム収集条件の進捗更新
  bool updateItemCollectionProgress(
    String conditionId,
    List<String> collectedItems,
  ) {
    final condition = _conditions[conditionId];
    if (condition == null ||
        condition.type != ClearConditionType.collectItems) {
      return false;
    }

    final requiredItems = List<String>.from(
      condition.data['requiredItems'] ?? [],
    );
    final hasAllItems = requiredItems.every(
      (item) => collectedItems.contains(item),
    );

    if (hasAllItems && !condition.isCompleted) {
      return completeCondition(conditionId);
    }

    return false;
  }

  /// パズル解決条件の進捗更新
  bool updatePuzzleProgress(String conditionId, List<String> solvedPuzzles) {
    final condition = _conditions[conditionId];
    if (condition == null ||
        condition.type != ClearConditionType.solvePuzzles) {
      return false;
    }

    final requiredPuzzles = List<String>.from(
      condition.data['requiredPuzzles'] ?? [],
    );
    final hasAllPuzzles = requiredPuzzles.every(
      (puzzle) => solvedPuzzles.contains(puzzle),
    );

    if (hasAllPuzzles && !condition.isCompleted) {
      return completeCondition(conditionId);
    }

    return false;
  }

  /// オブジェクト操作条件の進捗更新
  bool updateObjectInteractionProgress(
    String conditionId,
    List<String> interactedObjects,
  ) {
    final condition = _conditions[conditionId];
    if (condition == null ||
        condition.type != ClearConditionType.interactObjects) {
      return false;
    }

    final requiredObjects = List<String>.from(
      condition.data['requiredObjects'] ?? [],
    );
    final hasAllObjects = requiredObjects.every(
      (obj) => interactedObjects.contains(obj),
    );

    if (hasAllObjects && !condition.isCompleted) {
      return completeCondition(conditionId);
    }

    return false;
  }

  /// ゲームクリア判定
  void _checkGameClear() {
    if (_completedCount == totalCount && totalCount > 0 && !_isGameCleared) {
      _isGameCleared = true;
      debugPrint('🎉 Game cleared! All conditions completed.');
    }
  }

  /// 特定条件の完了状態取得
  bool isConditionCompleted(String conditionId) {
    return _conditions[conditionId]?.isCompleted ?? false;
  }

  /// クリア条件の詳細取得
  ClearCondition? getCondition(String conditionId) {
    return _conditions[conditionId];
  }

  /// ゲーム状態リセット
  void resetGame() {
    _conditions.clear();
    _completedCount = 0;
    _isGameCleared = false;
    debugPrint('🔄 Clear condition manager reset');
    notifyListeners();
  }

  /// デバッグ情報取得
  Map<String, dynamic> getDebugInfo() {
    return {
      'totalConditions': totalCount,
      'completedConditions': completedCount,
      'clearProgress': clearProgress,
      'isGameCleared': isGameCleared,
      'elapsedTimeSeconds': elapsedTimeSeconds,
      'conditions': _conditions.values
          .map(
            (c) => {
              'id': c.id,
              'type': c.type.name,
              'description': c.description,
              'isCompleted': c.isCompleted,
            },
          )
          .toList(),
    };
  }
}
