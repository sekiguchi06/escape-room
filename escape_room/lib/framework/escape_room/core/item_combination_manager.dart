import 'package:flutter/foundation.dart';

/// アイテム組み合わせルール
class CombinationRule {
  final String id;
  final List<String> requiredItems;
  final String resultItem;
  final String description;
  final bool consumeItems;
  final Map<String, dynamic> metadata;

  const CombinationRule({
    required this.id,
    required this.requiredItems,
    required this.resultItem,
    required this.description,
    this.consumeItems = true,
    this.metadata = const {},
  });

  /// 組み合わせ可能かチェック
  bool canCombine(List<String> availableItems) {
    return requiredItems.every((item) => availableItems.contains(item));
  }
}

/// ギミック解除ルール
class GimmickRule {
  final String id;
  final String targetObjectId;
  final List<String> requiredItems;
  final String description;
  final String successMessage;
  final String failureMessage;
  final bool consumeItems;
  final Map<String, dynamic> metadata;

  const GimmickRule({
    required this.id,
    required this.targetObjectId,
    required this.requiredItems,
    required this.description,
    required this.successMessage,
    required this.failureMessage,
    this.consumeItems = true,
    this.metadata = const {},
  });

  /// ギミック解除可能かチェック
  bool canActivate(List<String> availableItems) {
    return requiredItems.every((item) => availableItems.contains(item));
  }
}

/// アイテム組み合わせ結果
class CombinationResult {
  final bool success;
  final String? newItemId;
  final List<String> consumedItems;
  final String message;
  final Map<String, dynamic> metadata;

  const CombinationResult({
    required this.success,
    this.newItemId,
    this.consumedItems = const [],
    this.message = '',
    this.metadata = const {},
  });

  static CombinationResult createSuccess({
    String? newItemId,
    List<String> consumedItems = const [],
    String message = '',
    Map<String, dynamic> metadata = const {},
  }) {
    return CombinationResult(
      success: true,
      newItemId: newItemId,
      consumedItems: consumedItems,
      message: message,
      metadata: metadata,
    );
  }

  static CombinationResult createFailure(String message) {
    return CombinationResult(
      success: false,
      message: message,
    );
  }
}

/// アイテム組み合わせ・ギミック管理システム
/// 🎯 目的: アイテム組み合わせとギミック解除ルールの管理
class ItemCombinationManager extends ChangeNotifier {
  final Map<String, CombinationRule> _combinationRules = {};
  final Map<String, GimmickRule> _gimmickRules = {};
  final Set<String> _usedCombinations = <String>{};
  final Set<String> _activatedGimmicks = <String>{};

  /// 組み合わせルール一覧（読み取り専用）
  List<CombinationRule> get combinationRules => _combinationRules.values.toList();

  /// ギミックルール一覧（読み取り専用）
  List<GimmickRule> get gimmickRules => _gimmickRules.values.toList();

  /// 使用済み組み合わせ一覧
  List<String> get usedCombinations => _usedCombinations.toList();

  /// 発動済みギミック一覧
  List<String> get activatedGimmicks => _activatedGimmicks.toList();

  /// 組み合わせルールを追加
  void addCombinationRule(CombinationRule rule) {
    _combinationRules[rule.id] = rule;
    debugPrint('🔧 Combination rule added: ${rule.id} - ${rule.description}');
    notifyListeners();
  }

  /// ギミックルールを追加
  void addGimmickRule(GimmickRule rule) {
    _gimmickRules[rule.id] = rule;
    debugPrint('🔓 Gimmick rule added: ${rule.id} - ${rule.description}');
    notifyListeners();
  }

  /// 複数の組み合わせルールを一括追加
  void addCombinationRules(List<CombinationRule> rules) {
    for (final rule in rules) {
      _combinationRules[rule.id] = rule;
    }
    debugPrint('🔧 ${rules.length} combination rules added');
    notifyListeners();
  }

  /// 複数のギミックルールを一括追加
  void addGimmickRules(List<GimmickRule> rules) {
    for (final rule in rules) {
      _gimmickRules[rule.id] = rule;
    }
    debugPrint('🔓 ${rules.length} gimmick rules added');
    notifyListeners();
  }

  /// アイテム組み合わせを試行
  CombinationResult attemptCombination(
    String ruleId,
    List<String> availableItems,
  ) {
    final rule = _combinationRules[ruleId];
    if (rule == null) {
      return CombinationResult.createFailure('組み合わせルールが見つかりません: $ruleId');
    }

    if (_usedCombinations.contains(ruleId)) {
      return CombinationResult.createFailure('この組み合わせは既に使用済みです');
    }

    if (!rule.canCombine(availableItems)) {
      final missingItems = rule.requiredItems
          .where((item) => !availableItems.contains(item))
          .toList();
      return CombinationResult.createFailure(
        '必要なアイテムが不足しています: ${missingItems.join(", ")}',
      );
    }

    // 組み合わせ成功
    _usedCombinations.add(ruleId);
    
    final consumedItems = rule.consumeItems ? rule.requiredItems : <String>[];
    
    debugPrint('✅ Combination successful: ${rule.id} -> ${rule.resultItem}');
    notifyListeners();

    return CombinationResult.createSuccess(
      newItemId: rule.resultItem,
      consumedItems: consumedItems,
      message: rule.description,
      metadata: rule.metadata,
    );
  }

  /// ギミック解除を試行
  CombinationResult attemptGimmickActivation(
    String ruleId,
    List<String> availableItems,
  ) {
    final rule = _gimmickRules[ruleId];
    if (rule == null) {
      return CombinationResult.createFailure('ギミックルールが見つかりません: $ruleId');
    }

    if (_activatedGimmicks.contains(ruleId)) {
      return CombinationResult.createFailure('このギミックは既に解除済みです');
    }

    if (!rule.canActivate(availableItems)) {
      return CombinationResult.createFailure(rule.failureMessage);
    }

    // ギミック解除成功
    _activatedGimmicks.add(ruleId);
    
    final consumedItems = rule.consumeItems ? rule.requiredItems : <String>[];
    
    debugPrint('🔓 Gimmick activated: ${rule.id} on ${rule.targetObjectId}');
    notifyListeners();

    return CombinationResult.createSuccess(
      consumedItems: consumedItems,
      message: rule.successMessage,
      metadata: {
        'targetObjectId': rule.targetObjectId,
        ...rule.metadata,
      },
    );
  }

  /// 利用可能な組み合わせを取得
  List<CombinationRule> getAvailableCombinations(List<String> availableItems) {
    return _combinationRules.values
        .where((rule) => 
          !_usedCombinations.contains(rule.id) && 
          rule.canCombine(availableItems)
        )
        .toList();
  }

  /// 利用可能なギミックを取得
  List<GimmickRule> getAvailableGimmicks(List<String> availableItems) {
    return _gimmickRules.values
        .where((rule) => 
          !_activatedGimmicks.contains(rule.id) && 
          rule.canActivate(availableItems)
        )
        .toList();
  }

  /// 特定の組み合わせが使用済みかチェック
  bool isCombinationUsed(String ruleId) {
    return _usedCombinations.contains(ruleId);
  }

  /// 特定のギミックが発動済みかチェック
  bool isGimmickActivated(String ruleId) {
    return _activatedGimmicks.contains(ruleId);
  }

  /// 組み合わせルールを取得
  CombinationRule? getCombinationRule(String ruleId) {
    return _combinationRules[ruleId];
  }

  /// ギミックルールを取得
  GimmickRule? getGimmickRule(String ruleId) {
    return _gimmickRules[ruleId];
  }

  /// システムをリセット
  void resetSystem() {
    _combinationRules.clear();
    _gimmickRules.clear();
    _usedCombinations.clear();
    _activatedGimmicks.clear();
    debugPrint('🔄 Item combination system reset');
    notifyListeners();
  }

  /// デバッグ情報取得
  Map<String, dynamic> getDebugInfo() {
    return {
      'totalCombinationRules': _combinationRules.length,
      'totalGimmickRules': _gimmickRules.length,
      'usedCombinations': _usedCombinations.length,
      'activatedGimmicks': _activatedGimmicks.length,
      'combinationRules': _combinationRules.keys.toList(),
      'gimmickRules': _gimmickRules.keys.toList(),
      'usedCombinationIds': _usedCombinations.toList(),
      'activatedGimmickIds': _activatedGimmicks.toList(),
    };
  }
}