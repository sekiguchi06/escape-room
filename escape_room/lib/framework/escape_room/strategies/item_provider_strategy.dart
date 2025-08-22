import '../core/interaction_result.dart';
import 'interaction_strategy.dart';
import '../../ui/japanese_message_system.dart';

/// アイテム提供戦略
/// 🎯 目的: アイテムを提供するインタラクション行動
class ItemProviderStrategy implements InteractionStrategy {
  final String itemId;
  final String message;
  bool _hasProvided = false;

  ItemProviderStrategy({required this.itemId, required this.message});

  @override
  bool canInteract() {
    return !_hasProvided; // 提供済みの場合はインタラクト不可
  }

  @override
  InteractionResult execute() {
    if (!_hasProvided) {
      _hasProvided = true;
      return InteractionResult.success(
        message: message,
        itemsToAdd: [itemId],
        shouldActivate: true,
      );
    } else {
      return InteractionResult.failure(
        '${JapaneseMessageSystem.getMessage('already_examined_prefix')}: $message',
      );
    }
  }

  @override
  String get strategyName => 'ItemProvider';

  /// 状態リセット（テスト用）
  void reset() {
    _hasProvided = false;
  }
}
