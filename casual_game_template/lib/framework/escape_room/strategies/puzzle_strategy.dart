import '../core/interaction_result.dart';
import 'interaction_strategy.dart';

/// パズル戦略
/// 🎯 目的: パズル要求型のインタラクション行動
class PuzzleStrategy implements InteractionStrategy {
  final String requiredItemId;
  final String successMessage;
  final String failureMessage;
  bool _isSolved = false;
  
  PuzzleStrategy({
    required this.requiredItemId,
    required this.successMessage,
    required this.failureMessage,
  });
  
  @override
  bool canInteract() {
    return !_isSolved;
  }
  
  @override
  InteractionResult execute() {
    if (!canInteract()) {
      return InteractionResult.failure('既に解決済みです');
    }
    
    // スケルトン実装: 実際のアイテム保有チェックは後フェーズ
    final hasRequiredItem = _checkRequiredItem();
    
    if (hasRequiredItem) {
      _isSolved = true;
      return InteractionResult.success(
        message: successMessage,
        shouldActivate: true,
      );
    } else {
      return InteractionResult.failure(failureMessage);
    }
  }
  
  @override
  String get strategyName => 'Puzzle';
  
  /// 必要アイテム保有チェック（スケルトン実装）
  bool _checkRequiredItem() {
    // 後フェーズでインベントリシステムと連携
    return true; // テスト用
  }
  
  /// 状態リセット（テスト用）
  void reset() {
    _isSolved = false;
  }
}