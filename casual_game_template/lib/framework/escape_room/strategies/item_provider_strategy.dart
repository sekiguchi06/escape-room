import '../core/interaction_result.dart';
import 'interaction_strategy.dart';

/// アイテム提供戦略
/// 🎯 目的: アイテムを提供するインタラクション行動
class ItemProviderStrategy implements InteractionStrategy {
  final String itemId;
  final String message;
  bool _hasProvided = false;
  
  ItemProviderStrategy({
    required this.itemId,
    required this.message,
  });
  
  @override
  bool canInteract() {
    return !_hasProvided;
  }
  
  @override
  InteractionResult execute() {
    if (!canInteract()) {
      return InteractionResult.failure('既にアイテムを取得済みです');
    }
    
    _hasProvided = true;
    return InteractionResult.success(
      message: message,
      itemsToAdd: [itemId],
      shouldActivate: true,
    );
  }
  
  @override
  String get strategyName => 'ItemProvider';
  
  /// 状態リセット（テスト用）
  void reset() {
    _hasProvided = false;
  }
}